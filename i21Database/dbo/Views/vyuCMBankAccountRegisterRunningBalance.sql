CREATE VIEW vyuCMBankAccountRegisterRunningBalance
AS
WITH cteOrdered as
(
	select * 
	from [tblCMBankAccountRegisterRunningBalance]
),
cteRunningTotal as (
select a.rowId, sum(b.dblAmount) balance from cteOrdered a join cteOrdered b on a.rowId>= b.rowId 
group by a.rowId , a.intBankAccountId
),

cteBalance as(
select 
a.intRunningBalanceId,
a.rowId, 
a.intTransactionId, 
a.dtmDate, 
intBankAccountId,
ISNULL(BankRecon.dblStatementOpeningBalance, 0) + 
( b.balance - a.dblAmount)   dblOpeningBalance,
CASE WHEN a.dblAmount >= 0 THEN a.dblAmount ELSE 0 END dblDeposit,
CASE WHEN a.dblAmount < 0 THEN a.dblAmount ELSE 0 END dblPayment,
ISNULL(BankRecon.dblStatementOpeningBalance, 0) + 
b.balance dblEndingBalance,
a.intConcurrencyId

FROM cteOrdered a 
JOIN cteRunningTotal b on a.rowId = b.rowId 
OUTER APPLY (
    SELECT TOP 1 dblStatementOpeningBalance FROM tblCMBankReconciliation WHERE intBankAccountId = a.intBankAccountId

) BankRecon
)
select Balance.*,
dtmDateReconciled,
CM.intBankTransactionTypeId,
CM.intCompanyLocationId,
T.strBankTransactionTypeName,
L.strLocationName,
strMemo,
strPayee,
strReferenceNo,
strTransactionId,
ysnCheckVoid,
ysnClr
FROM tblCMBankTransaction CM 
JOIN cteBalance Balance ON CM.intTransactionId= Balance.intTransactionId
LEFT JOIN tblCMBankTransactionType T on T.intBankTransactionTypeId = CM.intBankTransactionTypeId
LEFT JOIN tblSMCompanyLocation L on L.intCompanyLocationId = CM.intCompanyLocationId


