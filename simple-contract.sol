// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.8.3/access/Ownable.sol";

contract MyToken is ERC20, ERC20Burnable, Ownable {

    address[] private _frozenAddresses;
    
    constructor() ERC20("TestToken2", "TST2") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * - the 'to' or 'from' is not belong to frozen list. 
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        require(!isFrozen(owner));
        require(!isFrozen(to));

        _transfer(owner, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /* 验证是否属于冻结地址 */
    function isFrozen(address account) public view returns(bool) {
        for (uint i = 0; i < _frozenAddresses.length; i++){
            if (account == _frozenAddresses[i]){
                return true;
            }
        }
        return false;
    }

    /* 添加冻结地址 */
    function setFrozenAccount(address account, bool status)public returns(bool) {
        for (uint i = 0; i < _frozenAddresses.length; i++){
            if (account == _frozenAddresses[i]){
                if (status == true){ // 存在 且 允许
                    // pop
                    _frozenAddresses[i] = _frozenAddresses[_frozenAddresses.length - 1];
                    _frozenAddresses.pop();
                    break;
                }
            }
        }
        // 不存在
        if (status == false){
            // push
            _frozenAddresses.push(account);
        }
        return true;
    }
}
