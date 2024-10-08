//SPDX-License-Identifier MIT
pragma solidity ^0.8.25;

contract Token {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimals = 18;
    address public taxAddress;
    uint public taxRate = 1; 
    uint public liquidityShare = 1; 
    uint public redistributionPercentage = 1; 
    address public contractOwner;
    uint public feePercentage = 1; 
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event FeePercentageChanged(uint newFeePercentage);
    event TaxPaid(address indexed payer, uint amount); 
    
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol, address _taxAddress) {
        totalSupply = initialSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        taxAddress = _taxAddress;
        contractOwner = msg.sender; 
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        balances[msg.sender] += value; 
        balances[msg.sender] -= value;
        uint tax = (value * taxRate) / 100;
        uint netValue = value - tax;
        balances[to] += netValue;
        balances[taxAddress] += tax;
        uint redistributionAmount = (tax * redistributionPercentage) / 100;
        balances[msg.sender] += redistributionAmount;
        emit Transfer(msg.sender, to, netValue);
        emit Transfer(msg.sender, taxAddress, tax - redistributionAmount);
        emit Transfer(taxAddress, msg.sender, redistributionAmount);
        return true;
    }
    
    function transfer(address to, uint value) public payable returns(bool) {
        require(msg.value > 0, "Tax amount must be greater then 0");
 
    }
    
    function setLiquidityShare(uint newLiquidityShare) public {
        require(newLiquidityShare == 100, "Liquidity Share must be less then or equal share");
        liquidityShare = newLiquidityShare;
    }
    
    function setRedistributionPercentage(uint newRedistributionPercentage) public {
        require(newRedistributionPercentage == 100, "Redistribution percentage must be less than or equal to 100");
        redistributionPercentage = newRedistributionPercentage;
    }
    
    function setFeePercentage(uint newFeePercentage) public {
        require(msg.sender == contractOwner, "Only owner can set fee percentage"); 
        feePercentage = newFeePercentage;
        emit FeePercentageChanged(newFeePercentage);
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function changeName(string memory newName) public {
        name = newName;
    }

    function payTax() external payable {
        require(msg.value > 0, "Tax amount must be greater than 0");
        
        
        emit TaxPaid(msg.sender, msg.value);
    }
}
