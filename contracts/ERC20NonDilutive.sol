pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Mintable.sol";
import "./ERC721PreferredStock.sol";

contract ERC20NonDilutive is ERC20Mintable {

    // Virtual "common stock", has no ownership
    // serves to compute ownership of protected stock
    uint256 public commonStockSupply;
    ERC721PreferredStock preferredStock; //ERC721 inflation-protection preferred stock
    // Used to keep track of mint tokenId since burning
    // makes supply unreliable for usage as min tokenId
    uint256 public preferredStockMaxId;

    // Authorized claim per preferred share
    uint256 public authorizedPerShare;
    // Total claimed
    // (not equal to preferredStock * authorizedPerShare since preferredStock can be minted)
    uint256 public totalClaimed;
    // Total minted claimable
    uint256 public totalClaimable;
    // Claimed tokens by share. New shares are minted as having
    //    claimed[tokenId] = authorizedPerShare
    // such as to allow only future inflation protection
    mapping (uint256 => uint256) claimed;

    // Emits event when preferredStock holder claims tokens
    event PreferredStockClaim(uint256 indexed tokenId, uint256 amount);

    function initialize() public initializer {
        // Supply is 0
        ERC20Mintable.initialize(_msgSender());
        // Initialize preffered stock contract
        preferredStock = new ERC721PreferredStock();
        preferredStock.initialize(address(this));

        authorizedPerShare = 0;
        commonStockSupply = 0;
        totalClaimed = 0;
        totalClaimable = 0;
        preferredStockMaxId = 0;
    }

    function preferredStockSupply() public view returns (uint256) {
        return _preferredStockSupply();
    }

    function preferredStockAddress() public view returns (address) {
        return address(preferredStock);
    }

    function _preferredStockSupply() internal view returns (uint256) {
        return preferredStock.totalSupply();
    }

    /**
     * @dev Overrieds the standard ERC20Mintable mint function. See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        // No prefferred stock
        uint256 preferredSupply = _preferredStockSupply();
        if (preferredSupply == 0) {
            _mint(account, amount);
            return true;
        }

        uint256 mintPerShare = amount.div(commonStockSupply);
        // Reverse operation to avoid rounding errors and the creation of dust
        uint256 mintCommon = mintPerShare.mul(commonStockSupply);

        // Mint common stock tokens
        _mint(account, mintCommon);
        // Increase authorized claim per share
        authorizedPerShare = authorizedPerShare.add(mintPerShare);
        // Mint preferred stock tokens
        uint256 mintPreffered = mintPerShare.mul(preferredSupply);
        // Tokens are held on the contracts balance
        // Loss of the ERC721 token holder will permanently lock that claim
        _mint(address(this), mintPreffered);
        totalClaimable = totalClaimable.add(mintPreffered);

        return true;
    }

    /**
   * @notice Mints preferred stock.
   * @dev Preferred stock has a claim on future inflation.
   * @param account Address to mint to
   * @param amount Amount of ERC-721 tokens to mint
   */
    function mintPrefferedStock(address account, uint256 amount) public onlyMinter returns (bool) {
        uint256 preferredStockEndId = preferredStockMaxId.add(amount);
        for (uint256 tokenId = preferredStockMaxId; tokenId < preferredStockEndId; tokenId++) {
            preferredStock.mint(account, tokenId);
            claimed[tokenId] = authorizedPerShare; //Only right to future inflation.
        }

        // Update min id for future minting
        preferredStockMaxId = preferredStockEndId;

        return true;
    }

    function burnPrefferedStock(uint256[] calldata tokenIds) external returns (bool) {
        return _burnPrefferedStock(tokenIds);
    }
    function burnPrefferedStockByIndex(uint256[] calldata tokenIndexes) external returns (bool) {
        uint256[] memory tokenIds = new uint256[](tokenIndexes.length);

        for (uint256 i = 0; i < tokenIndexes.length; i++) {
            tokenIds[i] = preferredStock.tokenByIndex(tokenIndexes[i]);
        }

        return _burnPrefferedStock(tokenIds);
    }

    function _burnPrefferedStock(uint256[] memory tokenIds) internal returns (bool) {
        address sender = _msgSender();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address tokenOwner = preferredStock.ownerOf(tokenId);
            require(sender == tokenOwner, "Sender does not own preferred share.");
            require(claimed[tokenId] == authorizedPerShare, "Must claim all tokens before burn");

            delete(claimed[tokenId]); // No longer needed to keep track of claim
            // deleting ERC721 token reduces its supply, does not impact max token id
            preferredStock.burn(tokenId);
        }

        return true;
    }

    function mintCommonStock(uint256 amount) public onlyMinter returns (uint256) {
        commonStockSupply = commonStockSupply.add(amount);
        return commonStockSupply;
    }

    function burnCommonStock(uint256 amount) public onlyMinter returns (uint256) {
        commonStockSupply = commonStockSupply.sub(amount);
        return commonStockSupply;
    }

    function claimByIndex(uint256[] calldata tokenIndexes) external returns (bool) {
        for (uint256 i = 0; i < tokenIndexes.length; i++) {
            uint256 tokenId = preferredStock.tokenByIndex(tokenIndexes[i]);
            _claimById(tokenId);
        }

        return true;
    }

    function claimById(uint256[] calldata tokenIds) external returns (bool) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            _claimById(tokenId);
        }

        return true;
    }

    function _claimById(uint256 tokenId) internal returns (bool) {
        address sender = _msgSender();
        address tokenOwner = preferredStock.ownerOf(tokenId);
        require(sender == tokenOwner, "Sender does not own preferred share.");
        require(authorizedPerShare > claimed[tokenId], "Tokens already claimed.");

        uint256 authorizedAmount = authorizedPerShare.sub(claimed[tokenId]);
        //Update claimed amount
        claimed[tokenId] = claimed[tokenId].add(authorizedAmount);
        totalClaimed = totalClaimed.add(authorizedAmount);

        emit PreferredStockClaim(tokenId, authorizedAmount);
        //Transfer claimed tokens
        _transfer(address(this), sender, authorizedAmount);

        return true;
    }

}