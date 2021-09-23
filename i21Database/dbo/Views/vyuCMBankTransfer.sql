CREATE VIEW vyuCMBankTransfer  
AS  
SELECT A.*,  
C.strPeriod,  
D.strBankAccountNo strBankAccountNoFrom,  
E.strBankAccountNo strBankAccountNoTo,  
D.strCurrency  strCurrencyFrom,  
E.strCurrency strCurrencyTo,  
F.strCurrencyExchangeRateType ,  
D.strGLAccountId strGLAccountIdFrom,  
E.strGLAccountId strGLAccountIdTo, 
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
END strBankTransferTypeId  
FROM tblCMBankTransfer A 
OUTER APPLY(
	SELECT TOP 1 dtmDateReconciled FROM tblCMBankTransaction WHERE strLink = A.strTransactionId
)B  
OUTER APPLY(  
 SELECT TOP 1 strPeriod FROM tblGLFiscalYearPeriod WHERE intGLFiscalYearPeriodId = A.intFiscalPeriodId  
 )C  
  
OUTER APPLY(  
 SELECT TOP 1 strBankAccountNo, strCurrency, strGLAccountId FROM vyuCMBankAccount WHERE intBankAccountId =  A.intBankAccountIdFrom  
)D  
OUTER APPLY(  
 SELECT TOP 1 strBankAccountNo, strCurrency, strGLAccountId FROM vyuCMBankAccount WHERE intBankAccountId =  A.intBankAccountIdTo  
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
  
  
  
  