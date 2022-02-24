CREATE VIEW [dbo].[vyuCMBankAccountRegisterRunningBalance]
AS
WITH cteSum as
(
	SELECT 
	CM.dblAmount,
	CM.intTransactionId,
	CM.intBankAccountId,
	CM.dtmDate,
	SUM(ISNULL(CMD.dblCreditForeign,0) - ISNULL(CMD.dblDebitForeign,0)) dblDetailAmountForeign,
	AVG(CMD.dblExchangeRate) dblExchangeRate, 
	dblPayment = 
		CASE WHEN CM.intBankTransactionTypeId IN ( 3, 9, 12, 13, 14, 15, 16, 20, 21, 22, 23 ) THEN CM.dblAmount 
		WHEN CM.intBankTransactionTypeId IN ( 2, 5,51,52) AND ISNULL(CM.dblAmount,0) < 0 THEN CM.dblAmount * -1 ELSE 0 END                        , 
	dblDeposit = 
		CASE WHEN CM.intBankTransactionTypeId IN ( 1, 10, 11, 18, 19, 103, 116, 121, 122, 123 ) THEN CM.dblAmount 
		WHEN CM.intBankTransactionTypeId = 5 AND ISNULL(CM.dblAmount,0) > 0 THEN CM.dblAmount ELSE 0 END
	FROM
	tblCMBankTransaction CM
	LEFT JOIN tblCMBankTransactionDetail CMD ON CM.intTransactionId = CMD.intTransactionId
	where CM.ysnPosted = 1
	GROUP BY CM.intTransactionId,dblAmount,intBankAccountId,CM.dtmDate, CM.intBankTransactionTypeId
),
cteOrdered AS(
	SELECT row_number() over(PARTITION by intBankAccountId ORDER BY dtmDate, intTransactionId) rowId, 
	dblDebitForeign = CASE WHEN ISNULL(A.dblDetailAmountForeign,0) <0 THEN  ABS(A.dblDetailAmountForeign)  ELSE 0 END,
	dblCreditForeign = CASE WHEN ISNULL(A.dblDetailAmountForeign,0) >0 THEN  A.dblDetailAmountForeign ELSE 0 END,
	dblAmount,
	intTransactionId,
	intBankAccountId,
	dtmDate,
	dblExchangeRate,
	dblPayment,
	dblDeposit
	from cteSum A
),
cteRunningTotal as 
(
	SELECT a.rowId, a.intBankAccountId, sum(b.dblDeposit - b.dblPayment) balance 
	FROM cteOrdered a join cteOrdered b on a.rowId>= b.rowId AND a.intBankAccountId = b.intBankAccountId
	GROUP BY a.rowId , a.intBankAccountId
)
SELECT
Ordered.rowId, 
dblPayment = Ordered.dblPayment,
dblDeposit = Ordered.dblDeposit,
Ordered.dblCreditForeign,
Ordered.dblDebitForeign,
Ordered.dblExchangeRate,
ISNULL(BankRecon.dblStatementOpeningBalance, 0) + ( Total.balance - (Ordered.dblDeposit-Ordered.dblPayment) )   dblOpeningBalance,
ISNULL(BankRecon.dblStatementOpeningBalance, 0) +  Total.balance dblEndingBalance,
Ordered.intTransactionId, 
Ordered.dtmDate, 
Ordered.intBankAccountId,
CM.dtmDateReconciled,
CM.intBankTransactionTypeId,
CM.intCompanyLocationId,
CM.strBankTransactionTypeName,
CM.strLocationName,
strMemo = 
	CASE WHEN CM.strMemo = '' AND CM.ysnCheckVoid = 1 THEN 'Void' 
	ELSE ISNULL(CM.strMemo, '') END,
strPayee = 
	CASE WHEN Employee.ysnMaskEmployeeName = 1 AND CM.intBankTransactionTypeId IN ( 21, 23 ) THEN '(restricted information)' 
	ELSE ISNULL(CM.strPayee, '') END,
CM.strReferenceNo,
CM.strTransactionId,
CM.ysnCheckVoid,
CM.ysnClr,
CM.strPeriod
FROM vyuCMGetBankTransaction CM 
JOIN cteOrdered Ordered ON CM.intTransactionId= Ordered.intTransactionId
JOIN cteRunningTotal Total ON Ordered.rowId = Total.rowId AND Total.intBankAccountId = Ordered.intBankAccountId
OUTER APPLY 
(
    SELECT TOP 1 ysnMaskEmployeeName 
    FROM   tblPRCompanyPreference 
) Employee
OUTER APPLY (
    SELECT TOP 1 dblStatementOpeningBalance FROM tblCMBankReconciliation WHERE intBankAccountId = CM.intBankAccountId

) BankRecon
GO

