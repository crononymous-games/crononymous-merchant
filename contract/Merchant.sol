// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Merchant is ERC1155, Ownable, Pausable, ERC1155Supply {
    mapping(uint256 => uint256) private priceById;

    constructor() ERC1155("https://raw.githubusercontent.com/crononymous-games/crononymous-merchant/master/metadata/{id}.json") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getPrice(uint256 id) external view returns (uint256) {
        require(priceById[id] != 0, "Unknown token id");

        return priceById[id];
    }

    function setPrice(uint256 id, uint256 value) external onlyOwner {
        priceById[id] = value;
    }

    function mint(uint256 id) 
        public 
        payable 
    {
        require(priceById[id] != 0, "Unknown token id");
        require(priceById[id] == msg.value, "Not enough money send");
        require(balanceOf(msg.sender, id) == 0, "You already own this token");
        
        _mint(msg.sender, id, 1, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function withdraw(address to) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}