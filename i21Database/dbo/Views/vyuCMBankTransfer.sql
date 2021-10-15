CREATE VIEW vyuCMBankTransfer  
AS  
SELECT A.*,  
D.*,
E.*,
C.strPeriod,  
F.strCurrencyExchangeRateType ,  
G.strCurrency  strCurrencyIdFeesFrom,
H.strCurrency strCurrencyIdFeesTo,
I.strAccountId  strGLAccountIdFeesFrom,
CASE WHEN B.dtmDateReconciled IS NOT NULL THEN 1 ELSE 0 END ysnReconciled,  
CASE WHEN intBankTransferTypeId = 1 THEN 'Bank Transfer'  
 WHEN intBankTransferTypeId = 2 THEN 'Bank Transfer With In transit'   
 WHEN intBankTransferTypeId = 3 THEN 'Bank Forward'   
 WHEN intBankTransferTypeId = 4 THEN 'Swap In'   
 WHEN intBankTransferTypeId = 5 THEN 'Swap Out'   
 WHEN intBankTransferTypeId = 6 THEN 'Create Loan'   
END strBankTransferTypeId,
CASE WHEN A.intRateTypeIdAmountFrom = 99999 THEN 'Historic Rate' ELSE J.strCurrencyExchangeRateType  END strRateTypeAmountFrom,
K.strCurrencyExchangeRateType strRateTypeAmountTo,
L.strCurrencyExchangeRateType strRateTypeFeesFrom,
M.strCurrencyExchangeRateType strRateTypeFeesTo
FROM tblCMBankTransfer A 
OUTER APPLY(
	SELECT TOP 1 dtmDateReconciled FROM tblCMBankTransaction WHERE strLink = A.strTransactionId
)B  
OUTER APPLY(  
 SELECT TOP 1 strPeriod FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = A.intFiscalPeriodId  
 )C  
  
OUTER APPLY(  
 SELECT TOP 1 strBankAccountNo strBankAccountNoFrom, strCurrency strCurrencyFrom, strGLAccountId strGLAccountIdFrom
 FROM vyuCMBankAccount 
 WHERE intBankAccountId =  A.intBankAccountIdFrom  
)D  
OUTER APPLY(  
 SELECT TOP 1 strBankAccountNo strBankAccountNoTo, strCurrency strCurrencyTo, strGLAccountId strGLAccountIdTo
 FROM vyuCMBankAccount WHERE intBankAccountId =  A.intBankAccountIdTo  
)E  
OUTER APPLY(  
 SELECT TOP 1 strCurrencyExchangeRateType FROM tblSMCurrencyExchangeRateType WHERE intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId  
)F
OUTER APPLY(  
 	SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = A.intCurrencyIdFeesFrom  
)G
OUTER APPLY(  
 	SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = A.intCurrencyIdFeesTo  
)H  
OUTER APPLY(  
 	SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intGLAccountIdFeesFrom  
)I 
OUTER APPLY(  
 SELECT TOP 1 strCurrencyExchangeRateType FROM tblSMCurrencyExchangeRateType WHERE intCurrencyExchangeRateTypeId = A.intRateTypeIdAmountFrom  
)J  
OUTER APPLY(  
 SELECT TOP 1 strCurrencyExchangeRateType FROM tblSMCurrencyExchangeRateType WHERE intCurrencyExchangeRateTypeId = A.intRateTypeIdAmountTo  
)K  
OUTER APPLY(  
 SELECT TOP 1 strCurrencyExchangeRateType FROM tblSMCurrencyExchangeRateType WHERE intCurrencyExchangeRateTypeId = A.intRateTypeIdFeesFrom  
)L  
OUTER APPLY(  
 SELECT TOP 1 strCurrencyExchangeRateType FROM tblSMCurrencyExchangeRateType WHERE intCurrencyExchangeRateTypeId = A.intRateTypeIdFeesTo  
)M
  
  