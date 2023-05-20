// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken{

    // 关键字 "public" 使变量可以从其他合约中访问。
    address public _owner;  // 合约创建者地址
    string public name;     // token名称
    string public symbol;   // token符号
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public  balanceOf;  // 每个账户所持有的代币数量
    mapping(address => mapping(address => uint)) private _allowed;
    mapping(address => mapping(address => uint256)) private _allowance;

    /*****************************************************/
    address[] private _frozenAddresses;      // 被冻结的账户数组，只有合约创建者可以添加或删除账户
    /*****************************************************/

    event Transfer(address from, address to, uint256 value);         // 转账事件
    event Approval(address indexed owner, address indexed spender, uint256 value);   // 授权交易事件

    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        _owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); // 防止发送到 0x0 地址
        require(!isFrozen(msg.sender));   // 检查发送地址是否未被冻结
        require(!isFrozen(_to));  // 检查接收地址是否未被冻结

        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        uint256 previousBAL = balanceOf[msg.sender] + balanceOf[_to];
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        assert(balanceOf[msg.sender] + balanceOf[_to] == previousBAL);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); // 防止发送到 0x0 地址
        require(!isFrozen(msg.sender));   // 检查发送地址是否未被冻结
        require(!isFrozen(_to));  // 检查接收地址是否未被冻结
        
        require(balanceOf[_from] >= _value);
        require(_allowed[_from][msg.sender] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        _allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function setAllowance(address _spender, uint256 _value) public returns(bool) {
        require(_spender != address(0));
        require(!isFrozen(_spender));
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function getAllowance(address owner, address _spender) public view returns (uint256) {
        return _allowed[owner][_spender];
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
}