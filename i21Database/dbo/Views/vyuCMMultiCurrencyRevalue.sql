CREATE VIEW [dbo].[vyuCMMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Cash Balances',
	strTransactionId		=	BA.strBankAccountNo,
	strTransactionDate		=	EOM.Value,
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
	dblAmount				=	BankBalance.Value/Rate.Value, -- this is in functional currency
	intCurrencyId			=	BA.intCurrencyId,
	intForexRateType		=	NewRateTypeId.intCashManagementRateTypeId,
	strForexRateType		=	NewRateTypeId.strCurrencyExchangeRateType,
	dblForexRate			=	Rate.Value,
	dblHistoricAmount		=	BankBalance.Value, -- foreign currency
	dblNewForexRate         =   NewRate.dblRate,  --0, --Calcuate By GL
    dblNewAmount            =    0,-- (BankBalance.Value/Rate.Value) * NewRate.dblRate, --  0, --Calcuate By GL
    dblUnrealizedDebitGain  =    0, --Calcuate By GL
    dblUnrealizedCreditGain =    0, --Calcuate By GL
    dblDebit                =    0, --Calcuate By GL
    dblCredit               =    0  --Calcuate By GL
	
FROM
  tblCMBankTransaction BT
  JOIN vyuCMBankAccount BA ON BT.intBankAccountId = BA.intBankAccountId
  OUTER APPLY(
		SELECT CAST(DATEADD(MONTH,DATEDIFF(MONTH,0,dtmDate)+1,0)-1 AS DATE) Value
  )EOM
  OUTER APPLY(
	SELECT TOP 1 intCashManagementRateTypeId, Rt.strCurrencyExchangeRateType FROM tblSMMultiCurrency MC
	JOIN tblSMCurrencyExchangeRateType Rt ON MC.intCashManagementRateTypeId = Rt.intCurrencyExchangeRateTypeId
	WHERE intMultiCurrencyId = 1
  ) NewRateTypeId
  OUTER APPLY(
		SELECT dblRate from [dbo].[fnSMGetForexRate] (BA.intCurrencyId,NewRateTypeId.intCashManagementRateTypeId,EOM.Value)
  )NewRate
 
  OUTER APPLY(
		SELECT [dbo].[fnGetBankBalance] (BT.intBankAccountId, EOM.Value) Value
  ) BankBalance
  OUTER APPLY (
		SELECT [dbo].fnGLGetCMGLDetailBalance(EOM.Value, BA.intGLAccountId) Value -- this is in us / functional currency
  )GLBalance
  OUTER APPLY(
		Select GLBalance.Value / BankBalance.Value Value
  )Rate
	
WHERE
  dtmDate IN (
    SELECT   MAX(dtmDate)
    FROM     tblCMBankTransaction
    GROUP BY MONTH(dtmDate), YEAR(dtmDate), intBankAccountId
  )
GO