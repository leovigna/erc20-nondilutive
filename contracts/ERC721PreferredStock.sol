pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Enumerable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Mintable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC721/ERC721Burnable.sol";

contract ERC721PreferredStock is ERC721, ERC721Enumerable, ERC721Mintable, ERC721Burnable {
    function initialize(address sender) public initializer {
        ERC721.initialize();
        ERC721Enumerable.initialize();
        ERC721Mintable.initialize(sender);
    }

    function burn(uint256 tokenId) public onlyMinter {
        _burn(tokenId);
    }

}