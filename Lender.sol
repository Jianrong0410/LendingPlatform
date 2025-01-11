// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lender {
    address public lender; // 出借人地址
    uint256 public balance; // 出借人合約餘額
    uint256 public interestRate; // 出借利率 (以百分比表示，例如5表示5%)

    constructor() {
        lender = msg.sender;
    }

    // 存錢到合約
    function deposit() external payable {
        require(msg.sender == lender, "Only lender can deposit.");
        balance += msg.value;
    }

    // 設定出借利率
    function setInterestRate(uint256 _rate) external {
        require(msg.sender == lender, "Only lender can set interest rate.");
        interestRate = _rate;
    }

    // 提供借款
    function provideLoan(address payable borrowerContract, uint256 amount) external {
        require(msg.sender == lender, "Only lender can provide loans.");
        require(balance >= amount, "Insufficient balance in lender contract.");
        
        (bool success,) = borrowerContract.call{value: amount}("");
        require(success, "Loan transfer failed.");
        balance -= amount;
    }

    // 接收還款
    receive() external payable {
        balance += msg.value;
    }
}