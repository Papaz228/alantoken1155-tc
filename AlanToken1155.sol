// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract AlanToken1155 is ERC1155, AccessControl, ERC1155Supply {
    using Strings for uint256;
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");
    uint256 public price = 0.1 ether;

    constructor()
        ERC1155("ipfs://QmYAiRCT8kW9si9FRzrkiGo5S5rDV5uzuw41er6vQgraDT/")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setBaseURI(string memory _baseURI) public onlyRole(URI_SETTER_ROLE) {
        _setURI(_baseURI);
    }

    function changePrice(uint256 _price) public onlyRole(DEFAULT_ADMIN_ROLE){
        price = _price;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(0), _id.toString(), ".json"));
    }

    function addWhitelist(address _address) external onlyRole(DEFAULT_ADMIN_ROLE){
        grantRole(WHITELISTED_ROLE, _address);
    }

    function removeWhitelist(address _address) external  onlyRole(DEFAULT_ADMIN_ROLE){
        revokeRole(WHITELISTED_ROLE, _address);
    }

    function isWhitelisted(address _address) external view returns (bool) {
        return hasRole(WHITELISTED_ROLE, _address);
    }

    function addSetter(address _address) external onlyRole(DEFAULT_ADMIN_ROLE){
        grantRole(URI_SETTER_ROLE, _address);
    }

    function removeSetter(address _address) external onlyRole(DEFAULT_ADMIN_ROLE){
        revokeRole(URI_SETTER_ROLE, _address);
    }

    function addMinter(address _address) external onlyRole(DEFAULT_ADMIN_ROLE){
        grantRole(MINTER_ROLE, _address);
    }

    function removeMinter(address _address) external onlyRole(DEFAULT_ADMIN_ROLE){
        revokeRole(MINTER_ROLE, _address);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(msg.sender).transfer(address(this).balance);
    }

    function buyNft(uint256 tokenId, uint256 amount) public payable onlyRole(WHITELISTED_ROLE){
        require(msg.value == price * amount, "Incorrect price");
        _mint(msg.sender, tokenId, amount, "");
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
