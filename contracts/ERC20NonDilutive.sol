pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Mintable.sol";
import "./ERC721PreferredStock.sol";

contract ERC20NonDilutive is ERC20Mintable {

    uint256 public commonStockSupply;
    uint256 public preferredStockSupply; //TBD burning reduce supply causing index misalignment?
    ERC721PreferredStock preferredStock;

    uint256 public authorizedPerShare;
    uint256 public totalClaimed;
    uint256 public totalClaimable;
    mapping (uint256 => uint256) claimed;

    event PreferredStockClaim(uint256 indexed tokenId, uint256 amount);

    function initialize() public initializer {
        // Supply is 0
        ERC20Mintable.initialize(_msgSender());
        // Initialize preffered stock contract
        preferredStock = new ERC721PrefferedStock();
        preferredStock.initialize(address(this));

        authorizedPerShare = 0;
        commonStockSupply = 0;
        totalClaimed = 0;
        totalClaimable = 0;
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
        uint256 mintCommon = amount.mul(commonStockSupply);

        // Mint common stock tokens
        _mint(account, mintCommon);
        // Increase authorized claim per share
        authorizedPerShare = authorizedPerShare.add(mintPerShare);
        // Mint preferred stock tokens
        uint256 mintPreffered = mintPerShare.mul(preferredSupply);
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
    function mintPrefferedStock(address account, uint256 amount) public onlyMinter returns (uint256) {
        uint256 preferredSupply = _preferredStockSupply();

        for (uint256 tokenId = preferredSupply; tokenId < preferredSupply.add(amount); tokenId++) {
            preferredStock.mint(account, tokenId);
            claimed[tokenId] = authorizedPerShare; //Only right to future inflation.
        }

        return _preferredStockSupply();
    }

    function burnPrefferedStock(uint256[] calldata tokenIds) external returns (bool) {
        address sender = _msgSender();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address tokenOwner = preferredStock.ownerOf(tokenId);
            require(sender == tokenOwner, "Sender does not own preferred share.");
            require(claimed[tokenId] == authorizedPerShare, "Must claim all tokens");

            delete(claimed[tokenId]);
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

    function claimByIndex(uint256 tokenIndex) public returns (bool) {
        uint256 tokenId = preferredStock.tokenByIndex(tokenIndex);
        return _claimById(tokenId);
    }

    function claimByIndex(uint256[] calldata tokenIndexes) external returns (bool) {
        for (uint256 i = 0; i < tokenIndexes.length; i++) {
            uint256 tokenId = preferredStock.tokenByIndex(tokenIndexes[i]);
            _claimById(tokenId);
        }

        return true;
    }

    function claimById(uint256 tokenId) public returns (bool) {
        return _claimById(tokenId);
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