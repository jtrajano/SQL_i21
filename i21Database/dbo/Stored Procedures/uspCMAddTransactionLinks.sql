CREATE PROCEDURE uspCMAddPrintTransactionLinks
(@BankTransactionIds Id READONLY)
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

EXEC [dbo].uspICAddTransactionLinks @TransactionLinks