// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import './Context.sol';

contract MyToken is Context{
    //1.代币信息
    //代币名称name
    string private _name;

    //代币标识symbol
    string private _symbol;

    //代币小数位数 decimals
    uint8 private _decimals;

    //代币总发行量 totalSupply
    uint256 private _totalSupply;

    //某个账号下代币数量 balance
    mapping (address => uint256) private _balances;

    //授权代币数量（授权可以转发的代币数量） allowance
    mapping (address => mapping(address => uint256)) private _allowances;
    /*
        {
            dhajhdiqwiudhhqdiu(虚拟货币发行者,发送者）：{
                h8df23rn237yr2398mu： 3000（收到）
                h7d82h3yte7823hyerf: 2000
            }
        }
    */
    

    //2.初始化
    constructor (){
        _name = "PandaKingCoin";
        _symbol = "PKC";
        _decimals = 18;
        //初始化货币池
        _mint(_msgSender(), 900*10000*10**_decimals);
    }

    //3.取值器
    //返回代币的名字name（）
    function name() public view returns (string memory) {
        return _name;
    }
    //返回代币标识
    function symbol() public  view  returns (string memory){
        return _symbol;
    }
    //返回代币的小数位数
    function decimals() public view  returns (uint8) {
        return _decimals;
    }
    //返回代币总发行量
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }
    //返回账户拥有的代币数量
    function balanceOf(address account) public view  returns (uint256) {
        return _balances[account];
    }
    //返回授权代币数量
    function allowanceOf(address owner ,address spender) public view returns (uint256){
        return _allowances[owner][spender];
    }





    //4.函数
   
    function transfer(address to, uint256 amount) public returns (bool ) {
        address owner = _msgSender();
        _transfer(owner,to,amount);
        return true;
    }

    function approve(address spender,uint256 amount) public returns(bool){
        //银行授权给我（银行贷款给我）部署合约的账号才是银行，应为里面有钱
        address owner = _msgSender();
        //owner 表示授权人，spender表示被授权人
        _approve(owner,spender,amount);
        return true;
    }
    //授权代币转发（智能合约实际花出去）
    function transferFrom(address from,address to,uint256 amount) public returns(bool){
        address owner = _msgSender();
        //更新授权账户信息
        _spendAllowance(from,owner,amount);
        //执行转账
        //from：我的钱，
        //to：可能是我自己，也可能会是其他
        _transfer(from, to, amount);
        return true;
       
    }


    //5.事件（告诉外界信息）
    event Transfer(address from,address to, uint256 amount);
    event Approval(address owner,address spender,uint256 amount);



    //合约内部函数
    //internal 只在内部使用
    function _mint(address account, uint256 amount) internal{
        //如果账号非法或者不等于初始主账号，就报错
        require(account != address(0),"ERC20: mintto the zero address");
        //初始化货币数量
        _totalSupply += amount;
        //给某个账号注入起始资金(unchecked里面的不做调验）
        unchecked{
             _balances[account] += amount;
        }
       
        
    }
    function _transfer(address from, address to, uint256 amount) internal{
        require(from != address(0),"ERC20: transfer from the zero address");
        require(to != address(0),"ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount,unicode"余额不够！！！！！！！！！！！！！！");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
                                                                                                                                                                                        
    }
    function _approve(address owner ,address spender,uint256 amount) internal {
        require(owner != address(0) , "ERC20: approve from the zero address");
        require(spender != address(0) , "ERC20: approve from the zero address");
        //执行授权
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function  _spendAllowance(address owner,address spender,uint256 amount ) internal {
        uint256 currentAllowance = allowanceOf(owner, spender);
        if (currentAllowance != type(uint256).max){ 
            require(currentAllowance >= amount,unicode"ERC20：余额不足够");
            unchecked{
                //还剩下的钱
                _approve(owner, spender, currentAllowance-amount);
            }

        }
    }

    

   
}
//账号一0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//账号二0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

//用transferfrom的时候要切换到approve授权的账号，
//transferFrom  里面的from是授权发起者，也就是切换前的账号
//to可以是任何想转的人，包括自己
//allowance是授权给可以转账的钱还剩多少
//转账成功后授权方才会实打实地扣钱