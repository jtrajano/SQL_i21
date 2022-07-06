CREATE PROCEDURE uspCMUpdateTransactionLinks
(
    @BankTransactionIds Id READONLY,
    @intType INT = 1,
    @ysnAdd BIT = 1
    -- 1 Check Print 
    -- 2 Bank Deposit Detail
)
AS
DECLARE @TransactionLinks udtICTransactionLinks

INSERT INTO @TransactionLinks
(
    intSrcId,
    strSrcTransactionNo,
    strSrcTransactionType,
    strSrcModuleName,
    intDestId,
    strDestTransactionNo,
    strDestTransactionType,
    strDestModuleName,
    strOperation
)
SELECT
intId,
B.strTransactionId,
C.strBankTransactionTypeName,
'Cash Management',
intCheckNumberAuditId,
strCheckNo,
'Process Payment',
'Cash Management',
'Create'
FROM
@BankTransactionIds A JOIN
tblCMBankTransaction B ON
A.intId = B.intTransactionId
JOIN tblCMBankTransactionType C
ON C.intBankTransactionTypeId = B.intBankTransactionTypeId
JOIN tblCMCheckNumberAudit D 
ON D.intTransactionId = A.intId
WHERE @intType = 1
UNION
SELECT
A.intSourceTransactionId,
A.strSourceTransactionId,
CASE WHEN SUBSTRING(A.strSourceTransactionId, 1,4) = 'RCV-' THEN 'Cash Receipts'
     WHEN SUBSTRING(A.strSourceTransactionId, 1,3) = 'SI-' THEN 'Invoice'
     WHEN SUBSTRING(A.strSourceTransactionId, 1,4) = 'EOD-' THEN 'End Of Day'
     ELSE '' END,
'Accounts Receivable',
C.intTransactionId,
C.strTransactionId,
'Bank Deposit',
'Cash Management',
'Create'
FROM
tblCMUndepositedFund A 
JOIN tblCMBankTransactionDetail B ON A.intUndepositedFundId = B.intUndepositedFundId
JOIN tblCMBankTransaction C ON C.intTransactionId =  B.intTransactionId
JOIN @BankTransactionIds D ON D.intId = B.intUndepositedFundId
WHERE @intType = 2

IF @ysnAdd = 1 
    EXEC [dbo].uspICAddTransactionLinks @TransactionLinks
ELSE  
    EXEC [dbo].uspICDeleteTransactionLink @TransactionLinks