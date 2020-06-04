CREATE VIEW [dbo].[vyuCMBankAccountRegisterRunningBalanceCount]
AS

select
intTransactionId,
dtmDate, 
intBankAccountId,
dtmDateReconciled,
intBankTransactionTypeId,
intCompanyLocationId,
strBankTransactionTypeName,
strLocationName,
strMemo = 
	CASE WHEN strMemo = '' AND ysnCheckVoid = 1 THEN 'Void' 
	ELSE ISNULL(strMemo, '') END,
strPayee = 
	CASE WHEN Employee.ysnMaskEmployeeName = 1 AND intBankTransactionTypeId IN ( 21, 23 ) THEN '(restricted information)' 
	ELSE ISNULL(strPayee, '') END,
dblPayment = 
	CASE WHEN intBankTransactionTypeId IN ( 3, 9, 12, 13, 14, 15, 16, 20, 21, 22, 23 ) THEN dblAmount 
	WHEN intBankTransactionTypeId IN ( 2, 5, 51 ) AND ISNULL(dblAmount,0) < 0 THEN dblAmount * -1 ELSE 0 END                        , 
dblDeposit = CASE WHEN intBankTransactionTypeId IN ( 1, 10, 11, 18, 19, 103, 116, 121, 122, 123 ) THEN dblAmount 
	WHEN intBankTransactionTypeId = 5 AND ISNULL(dblAmount,0) > 0 THEN dblAmount ELSE 0 END, 
strReferenceNo,
strTransactionId,
ysnCheckVoid,
ysnClr,
strPeriod
FROM vyuCMGetBankTransaction CM 
OUTER APPLY 
(
 
    SELECT TOP 1 ysnMaskEmployeeName 
    FROM   tblPRCompanyPreference 
) Employee
WHERE ysnPosted = 1
GO
