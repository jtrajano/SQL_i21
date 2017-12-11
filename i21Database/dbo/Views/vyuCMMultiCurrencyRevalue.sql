CREATE VIEW [dbo].[vyuCMMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Cash Balances',
	strTransactionId		=	BA.strBankAccountNo,
	strTransactionDate		=	(SELECT CAST(DATEADD(MONTH,DATEDIFF(MONTH,0,dtmDate)+1,0)-1 AS DATE)),--EOMONTH(dtmDate),
	strTransactionDueDate	=	'',
	strVendorName			=	'',
	strCommodity			=	'',
	strLineOfBusiness		=	'',
	strLocation				=	'',
	strTicket				=	'',
	strContractNumber		=	'',
	strItemId				=	'',
	dblQuantity				=	0,
	dblUnitPrice			=	0,
	dblAmount				=	[dbo].[fnGetBankBalance] (BT.intBankAccountId, (SELECT CAST(DATEADD(MONTH,DATEDIFF(MONTH,0,dtmDate)+1,0)-1 AS DATE))),
	intCurrencyId			=	BA.intCurrencyId,
	intForexRateType		=	'',
	strForexRateType		=	'',
	dblForexRate			=	[dbo].[fnGetForexRate] ((SELECT CAST(DATEADD(MONTH,DATEDIFF(MONTH,0,dtmDate)+1,0)-1 AS DATE)),BA.intCurrencyId,MC.intCashManagementRateTypeId),
	dblHistoricAmount		=	[dbo].[fnGetBankBalance] (BT.intBankAccountId, (SELECT CAST(DATEADD(MONTH,DATEDIFF(MONTH,0,dtmDate)+1,0)-1 AS DATE))) * [dbo].[fnGetForexRate] ((SELECT CAST(DATEADD(MONTH,DATEDIFF(MONTH,0,dtmDate)+1,0)-1 AS DATE)),BA.intCurrencyId,MC.intCashManagementRateTypeId),
	dblNewForexRate         =    0, --Calcuate By GL
    dblNewAmount            =    0, --Calcuate By GL
    dblUnrealizedDebitGain  =    0, --Calcuate By GL
    dblUnrealizedCreditGain =    0, --Calcuate By GL
    dblDebit                =    0, --Calcuate By GL
    dblCredit               =    0  --Calcuate By GL
FROM
  tblCMBankTransaction BT
  INNER JOIN vyuCMBankAccount BA ON BT.intBankAccountId = BA.intBankAccountId
  LEFT JOIN tblSMMultiCurrency MC ON MC.intMultiCurrencyId = 1
WHERE
  dtmDate IN (
    SELECT   MAX(dtmDate)
    FROM     tblCMBankTransaction
    GROUP BY MONTH(dtmDate), YEAR(dtmDate), intBankAccountId
  )