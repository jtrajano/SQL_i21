CREATE VIEW [dbo].[vyuCMMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Cash Balances',
	strTransactionId		=	BA.strBankAccountNo,
	strTransactionDate		=	EOMONTH(dtmDate),
	strTransactionDueDate	=	'',
	strVendorName			=	'',
	strCommodity			=	'',
	strLineOfBusiness		=	'',
	strLocation				=	'',
	strTicket				=	'',
	strContractNumber		=	'',
	strItemId				=	'',
	dblQuantity				=	'',
	dblUnitPrice			=	'',
	dblAmount				=	[dbo].[fnGetBankBalance] (BT.intBankAccountId, EOMONTH(dtmDate)),
	intCurrencyId			=	BA.intCurrencyId,
	intForexRateType		=	'',
	strForexRateType		=	'',
	dblForexRate			=	[dbo].[fnGetForexRate] (EOMONTH(dtmDate),BA.intCurrencyId,MC.intCashManagementRateTypeId),
	dblHistoricAmount		=	[dbo].[fnGetBankBalance] (BT.intBankAccountId, EOMONTH(dtmDate)) * [dbo].[fnGetForexRate] (EOMONTH(dtmDate),BA.intCurrencyId,MC.intCashManagementRateTypeId),
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