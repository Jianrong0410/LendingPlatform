// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Lender.sol";

contract Borrower {
    address public borrower; // 借款人地址
    uint256 public loanAmount; // 借款金額
    uint256 public loanTime; // 借款時間（時間戳記）
    address payable public lenderContract; // 出借人合約地址

    constructor() {
        borrower = msg.sender;
    }

    // 設定借款參數
    function requestLoan(address payable _lenderContract, uint256 _amount) external {
        require(msg.sender == borrower, "Only borrower can request a loan.");
        lenderContract = _lenderContract;
        loanAmount = _amount;
        loanTime = block.timestamp;

        // 向出借人合約借款
        (bool success,) = lenderContract.call(
            abi.encodeWithSignature("provideLoan(address,uint256)", payable(address(this)), loanAmount)
        );
        require(success, "Loan request failed.");

        // 將款項轉給借款人
        payable(borrower).transfer(loanAmount);
    }

    // 還款
    function repayLoan() external payable {
        require(msg.sender == borrower, "Only borrower can repay the loan.");
        require(msg.value >= loanAmount, "Insufficient repayment amount.");

        // 還本金及利息
        uint256 interest = (loanAmount * Lender(lenderContract).interestRate()) / 100;
        uint256 totalRepayment = loanAmount + interest;

        require(msg.value >= totalRepayment, "Not enough to cover loan and interest.");

        (bool success,) = lenderContract.call{value: totalRepayment}("");
        require(success, "Repayment failed.");
    }

    // 接收出借人合約匯入的款項
    receive() external payable {}
}
