// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts@4.8.3/access/AccessControl.sol";
import "@openzeppelin/contracts@4.8.3/security/Pausable.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC20/extensions/ERC20FlashMint.sol";

contract TestToken is ERC20, ERC20Burnable, ERC20Snapshot, AccessControl, Pausable, ERC20Permit, ERC20Votes, ERC20FlashMint {
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address[] private _frozenAddresses;      // 被冻结的账户数组，只有合约创建者可以添加或删除账户
    address public _owner;  // 合约创建者地址

    constructor() ERC20("TestToken", "TST") ERC20Permit("TestToken") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SNAPSHOT_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 1000000 * 10 ** decimals());
        _grantRole(MINTER_ROLE, msg.sender);
        _owner = msg.sender;
    }

    // 冻结和解除冻结账户的函数
    function setFrozenAccount(address account, bool status) public returns (bool success) {
        require(msg.sender == _owner);   // 只有合约创建者可以冻结或解除冻结账户
        
        // 如果账户被冻结，则将其添加到 _frozenAddresses 数组中，否则从该数组中删除它
        if (status == false && isFrozen(account)) {
            for (uint i = 0; i < _frozenAddresses.length; i++) {
                if (_frozenAddresses[i] == account) {
                    _frozenAddresses[i] = _frozenAddresses[_frozenAddresses.length - 1];
                    _frozenAddresses.pop();
                    break;
                }
            }
        } else if (status == true) {
            _frozenAddresses.push(account);
        }
        return true;
    }

    // 检查一个地址是否已被冻结的函数
    function isFrozen(address account) public view returns(bool) {
        for (uint i = 0; i < _frozenAddresses.length; i++) {
            if (_frozenAddresses[i] == account) {
                return true;
            }
        }
        return false;
    }
    /*function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(!isFrozen(msg.sender));   // 检查发送地址是否未被冻结
        require(!isFrozen(to));  // 检查接收地址是否未被冻结

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }*/
    function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
