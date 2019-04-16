CREATE VIEW [dbo].[vyuCMBankAccountRegisterRunningBalance]
AS
WITH cteOrdered as
(
	select row_number() over(order by dtmDate, intTransactionId) rowId, 
	dblAmount, 
	b.intTransactionId,
	b.intBankAccountId,
	b.dtmDate 
	from
	tblCMBankTransaction b
	where b.ysnPosted = 1
),
cteRunningTotal as (
select a.rowId, sum(b.dblAmount) balance from cteOrdered a join cteOrdered b on a.rowId>= b.rowId 
group by a.rowId , a.intBankAccountId
),
cteBalance as(
	select 
	a.rowId, 
	a.intTransactionId, 
	a.dtmDate, 
	intBankAccountId,
	( b.balance - a.dblAmount)   dblOpeningBalance,
	b.balance dblEndingBalance
FROM cteOrdered a 
JOIN cteRunningTotal b on a.rowId = b.rowId 
OUTER APPLY (
    SELECT TOP 1 dblStatementOpeningBalance FROM tblCMBankReconciliation WHERE intBankAccountId = a.intBankAccountId

) BankRecon
)
select --TOP 100
Balance.rowId, 
Balance.intTransactionId, 
Balance.dtmDate, 
Balance.intBankAccountId,
Balance.dblOpeningBalance,
Balance.dblEndingBalance,
CM.dtmDateReconciled,
CM.intBankTransactionTypeId,
CM.intCompanyLocationId,
T.strBankTransactionTypeName,
L.strLocationName,
strMemo = 
	CASE WHEN CM.strMemo = '' AND CM.ysnCheckVoid = 1 THEN 'Void' 
	ELSE ISNULL(CM.strMemo, '') END,
strPayee = 
	CASE WHEN Employee.ysnMaskEmployeeName = 1 AND CM.intBankTransactionTypeId IN ( 21, 23 ) THEN '(restricted information)' 
	ELSE ISNULL(CM.strPayee, '') END,
dblPayment = 
	CASE WHEN CM.intBankTransactionTypeId IN ( 3, 9, 12, 13, 14, 15, 16, 20, 21, 22, 23 ) THEN CM.dblAmount 
	WHEN CM.intBankTransactionTypeId IN ( 2, 5 ) AND ISNULL(CM.dblAmount,0) < 0 THEN CM.dblAmount * -1 ELSE 0 END                        , 
dblDeposit = CASE WHEN CM.intBankTransactionTypeId IN ( 1, 10, 11, 18, 19, 103, 116, 121, 122, 123 ) THEN CM.dblAmount 
	WHEN CM.intBankTransactionTypeId = 5 AND ISNULL(CM.dblAmount,0) > 0 THEN dblAmount ELSE 0 END, 
CM.strReferenceNo,
CM.strTransactionId,
CM.ysnCheckVoid,
CM.ysnClr
FROM tblCMBankTransaction CM 
JOIN cteBalance Balance ON CM.intTransactionId= Balance.intTransactionId
LEFT JOIN tblCMBankTransactionType T on T.intBankTransactionTypeId = CM.intBankTransactionTypeId
LEFT JOIN tblSMCompanyLocation L on L.intCompanyLocationId = CM.intCompanyLocationId
OUTER APPLY 
(
 
    SELECT TOP 1 ysnMaskEmployeeName 
    FROM   tblPRCompanyPreference 
) Employee
GO


