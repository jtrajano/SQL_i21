CREATE VIEW vyuCMMultiCurrencyRevalue  
AS
WITH QUERY AS(
	SELECT   
	strTransactionType  = 'Cash Balances' COLLATE Latin1_General_CI_AS,  
	strTransactionId  = BA.strBankAccountNo,  
	EOP.Value dtmDate,
	strTransactionDate  = replace(convert( varchar(10), EOP.Value, 102),'.', '-') COLLATE Latin1_General_CI_AS,  
	strTransactionDueDate = NULL,  
	strVendorName   = '' COLLATE Latin1_General_CI_AS,  
	strCommodity   = '' COLLATE Latin1_General_CI_AS,  
	strLineOfBusiness  = '' COLLATE Latin1_General_CI_AS,  
	strLocation    = '' COLLATE Latin1_General_CI_AS,  
	strTicket    = '' COLLATE Latin1_General_CI_AS,  
	strContractNumber  = '' COLLATE Latin1_General_CI_AS,  
	strItemId    = '' COLLATE Latin1_General_CI_AS,  
	dblQuantity    = NULL,  
	dblUnitPrice   = NULL,  
	dblAmount       =  BankBalance.Value, -- this is in foreign currency    
	intCurrencyId   = BA.intCurrencyId,  
	intForexRateType  = NewRateTypeId.intCashManagementRateTypeId,  
	strForexRateType  = NewRateTypeId.strCurrencyExchangeRateType,  
	dblForexRate   = Rate.Value,  
	dblHistoricAmount  =  GLBalance.Value, -- functional currency  
	dblNewForexRate         =   NewRate.dblRate,  --0, --Calcuate By GL  
	dblNewAmount            =    0,-- (BankBalance.Value/Rate.Value) * NewRate.dblRate, --  0, --Calcuate By GL  
	dblUnrealizedDebitGain  =    0, --Calcuate By GL  
	dblUnrealizedCreditGain =    0, --Calcuate By GL  
	dblDebit                =    0, --Calcuate By GL  
	dblCredit               =    0,  --Calcuate By GL  
	intCompanyLocationId = NULL, -- BT.intCompanyLocationId,  
	intAccountId   = BA.intGLAccountId  
	FROM  
	vyuCMBankAccount BA --ON BT.intBankAccountId = BA.intBankAccountId  
	OUTER APPLY(  
	select dtmEndDate Value from tblGLFiscalYearPeriod --where dtmDate between dtmStartDate and dtmEndDate  
	)EOP  
	OUTER APPLY(  
	SELECT TOP 1 intCashManagementRateTypeId, Rt.strCurrencyExchangeRateType FROM tblSMMultiCurrency MC  
	JOIN tblSMCurrencyExchangeRateType Rt ON MC.intCashManagementRateTypeId = Rt.intCurrencyExchangeRateTypeId  
	WHERE intMultiCurrencyId = 1  
	) NewRateTypeId  
	OUTER APPLY(  
	SELECT top 1 dblRate from [dbo].[fnSMGetForexRate] (BA.intCurrencyId,NewRateTypeId.intCashManagementRateTypeId,EOP.Value)  
	)NewRate  
	OUTER APPLY(  
	SELECT top 1 [dbo].[fnCMGetBankBalance] (BA.intBankAccountId, EOP.Value) Value  
	) BankBalance  
	OUTER APPLY (  
	SELECT top 1 [dbo].fnGLGetCMGLDetailBalance(EOP.Value, BA.intGLAccountId) Value -- this is in us / functional currency  
	)GLBalance  
	OUTER APPLY(  
	SELECT top 1 case when BankBalance.Value = 0 or  GLBalance.Value = 0 then NULL else  GLBalance.Value/BankBalance.Value   END  Value  
	)Rate  
)
SELECT * from QUERY WHERE dblHistoricAmount <> 0


   --select dtmEndDate from tblGLFiscalYearPeriod
