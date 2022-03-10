CREATE PROCEDURE uspCMProcessTradeFinanceLog
    @intUndepositedFundIds NVARCHAR(MAX), --intTransactionIds in string
    @strAction NVARCHAR(40),
    @intUserId  INT
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

DECLARE @TradeFinanceLogs TRFLog
DECLARE @dtmNow DATETIME = GETDATE()

;WITH BankTrans AS (
    SELECT
    strTransactionNumber = F.strSourceTransactionId,
    A.strTransactionId,
    A.intTransactionId,
    B.intTransactionDetailId,
    A.dtmDate,
    A.intBankAccountId,
    A.intBankTransactionTypeId
    FROM tblCMBankTransaction A
    JOIN tblCMBankTransactionDetail B ON A.intTransactionId = B.intTransactionId
    JOIN tblCMUndepositedFund F ON F.intUndepositedFundId = B.intUndepositedFundId
    WHERE F.intUndepositedFundId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@intUndepositedFundIds))
),
BankInfo AS (
    SELECT A.*,
    C.intBankId,
    B.strBankAccountNo,
    C.strBankName,
    D.strBankTransactionTypeName
    FROM BankTrans A 
    JOIN vyuCMBankAccount B ON
    A.intBankAccountId = A.intBankAccountId
    JOIN tblCMBank C ON C.intBankId = B.intBankId
    JOIN tblCMBankTransactionType D ON D.intBankTransactionTypeId = A.intBankTransactionTypeId
),
GetLastOne AS (
    SELECT 
    strRowId = ROW_NUMBER() OVER(PARTITION BY A.strTransactionNumber ORDER BY dtmAppliedToTransactionDate DESC )
    , strAction = @strAction
    , strTransactionType = B.strBankTransactionTypeName
    , intTradeFinanceTransactionId
    , strTradeFinanceTransaction
    , intTransactionHeaderId = B.intTransactionId
    , intTransactionDetailId = B.intTransactionDetailId
    , strTransactionNumber = B.strTransactionId
    , dtmTransactionDate = B.dtmDate
    , intBankTransactionId =  B.intTransactionId
    , strBankTransactionId = B.strTransactionId
    , intBankId = B.intBankId
    , strBank = B.strBankName
    , intBankAccountId = B.intBankAccountId
    , strBankAccount = B.strBankAccountNo
    , intBorrowingFacilityId 
    , strBorrowingFacility 
    , strBorrowingFacilityBankRefNo
    , dblTransactionAmountAllocated
    , dblTransactionAmountActual
    , intLoanLimitId
    , strLoanLimitNumber
    , strLoanLimitType
    , intLimitId
    , strLimit
    , dblLimit 
    , intSublimitId 
    , strSublimit
    , dblSublimit
    , strBankTradeReference 
    , dblFinanceQty 
    , dblFinancedAmount 
    , strBankApprovalStatus 
    , dtmAppliedToTransactionDate = @dtmNow
    , intStatusId
    , intWarrantId
    , strWarrantId
    , intUserId =@intUserId
    , intConcurrencyId = 1
    , intContractHeaderId
    , intContractDetailId
    FROM tblTRFTradeFinanceLog A JOIN
    BankInfo B ON A.strTransactionNumber = A.strTransactionNumber
    WHERE strAction = 'Posted Payment'
)
INSERT INTO @TradeFinanceLogs (
    strAction
    , strTransactionType
    , intTradeFinanceTransactionId
    , strTradeFinanceTransaction
    , intTransactionHeaderId
    , intTransactionDetailId
    , strTransactionNumber
    , dtmTransactionDate
    , intBankTransactionId
    , strBankTransactionId
    , intBankId
    , strBank
    , intBankAccountId
    , strBankAccount
    , intBorrowingFacilityId 
    , strBorrowingFacility 
    , strBorrowingFacilityBankRefNo
    , dblTransactionAmountAllocated
    , dblTransactionAmountActual
    , intLoanLimitId
    , strLoanLimitNumber
    , strLoanLimitType
    , intLimitId
    , strLimit
    , dblLimit 
    , intSublimitId 
    , strSublimit
    , dblSublimit
    , strBankTradeReference 
    , dblFinanceQty 
    , dblFinancedAmount 
    , strBankApprovalStatus 
    , dtmAppliedToTransactionDate
    , intStatusId
    , intWarrantId
    , strWarrantId
    , intUserId
    , intConcurrencyId
    , intContractHeaderId
    , intContractDetailId
)

SELECT 
    strAction
    , strTransactionType
    , intTradeFinanceTransactionId
    , strTradeFinanceTransaction
    , intTransactionHeaderId
    , intTransactionDetailId
    , strTransactionNumber
    , dtmTransactionDate
    , intBankTransactionId
    , strBankTransactionId
    , intBankId
    , strBank
    , intBankAccountId
    , strBankAccount
    , intBorrowingFacilityId 
    , strBorrowingFacility 
    , strBorrowingFacilityBankRefNo
    , dblTransactionAmountAllocated
    , dblTransactionAmountActual
    , intLoanLimitId
    , strLoanLimitNumber
    , strLoanLimitType
    , intLimitId
    , strLimit
    , dblLimit 
    , intSublimitId 
    , strSublimit
    , dblSublimit
    , strBankTradeReference 
    , dblFinanceQty 
    , dblFinancedAmount 
    , strBankApprovalStatus 
    , dtmAppliedToTransactionDate
    , intStatusId
    , intWarrantId
    , strWarrantId
    , intUserId
    , intConcurrencyId
    , intContractHeaderId
    , intContractDetailId
 FROM GetLastOne A 
 WHERE strRowId = 1

 
IF EXISTS (SELECT 1 FROM @TradeFinanceLogs )
    EXEC uspTRFLogTradeFinance @TradeFinanceLogs

RETURN 0