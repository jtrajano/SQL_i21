CREATE VIEW [dbo].[vyuCMMultiCurrencyRevalue]
AS
SELECT DISTINCT
	strTransactionType		=	'Cash Balances' COLLATE Latin1_General_CI_AS,
	strTransactionId		=	BA.strBankAccountNo,
	strTransactionDate		=	replace(convert( varchar(10), EOP.Value, 102),'.', '-') COLLATE Latin1_General_CI_AS,
	strTransactionDueDate	=	NULL,
	strVendorName			=	'' COLLATE Latin1_General_CI_AS,
	strCommodity			=	'' COLLATE Latin1_General_CI_AS,
	strLineOfBusiness		=	'' COLLATE Latin1_General_CI_AS,
	strLocation				=	'' COLLATE Latin1_General_CI_AS,
	strTicket				=	'' COLLATE Latin1_General_CI_AS,
	strContractNumber		=	'' COLLATE Latin1_General_CI_AS,
	strItemId				=	'' COLLATE Latin1_General_CI_AS,
	dblQuantity				=	NULL,
	dblUnitPrice			=	NULL,
	dblAmount    			=   CASE WHEN Rate.Value IS NULL THEN 0 else BankBalance.Value/Rate.Value end, -- this is in functional currency  
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
    dblCredit               =    0,  --Calcuate By GL
	intCompanyLocationId	=	BT.intCompanyLocationId
FROM
  tblCMBankTransaction BT
  JOIN vyuCMBankAccount BA ON BT.intBankAccountId = BA.intBankAccountId
  OUTER APPLY(
		select dtmEndDate Value from tblGLFiscalYearPeriod where dtmDate between dtmStartDate and dtmEndDate
  )EOP
  OUTER APPLY(
	SELECT TOP 1 intCashManagementRateTypeId, Rt.strCurrencyExchangeRateType FROM tblSMMultiCurrency MC
	JOIN tblSMCurrencyExchangeRateType Rt ON MC.intCashManagementRateTypeId = Rt.intCurrencyExchangeRateTypeId
	WHERE intMultiCurrencyId = 1
  ) NewRateTypeId
  OUTER APPLY(
		SELECT dblRate from [dbo].[fnSMGetForexRate] (BA.intCurrencyId,NewRateTypeId.intCashManagementRateTypeId,EOP.Value)
  )NewRate
 
  OUTER APPLY(
		SELECT [dbo].[fnCMGetBankBalance] (BT.intBankAccountId, EOP.Value) Value
  ) BankBalance
  OUTER APPLY (
		SELECT [dbo].fnGLGetCMGLDetailBalance(EOP.Value, BA.intGLAccountId) Value -- this is in us / functional currency
  )GLBalance
  OUTER APPLY(
		SELECT case when BankBalance.Value = 0 then NULL else GLBalance.Value / BankBalance.Value  END  Value
  )Rate
	
WHERE
  dtmDate IN (
    SELECT   MAX(dtmDate)
    FROM     tblCMBankTransaction
    GROUP BY MONTH(dtmDate), YEAR(dtmDate), intBankAccountId
  )
GO