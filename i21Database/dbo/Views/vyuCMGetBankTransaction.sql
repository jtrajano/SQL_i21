CREATE VIEW vyuCMGetBankTransaction
AS
SELECT BT.*,
BA.strBankAccountNo,
CU.strCurrency,
CL.strLocationName,
BL.strBankLoanId,
RT.strCurrencyExchangeRateType,
BTT.strBankTransactionTypeName,
FP.strPeriod
FROM tblCMBankTransaction BT 
LEFT JOIN vyuCMBankAccount BA on BA.intBankAccountId = BT.intBankAccountId
LEFT JOIN tblCMBankTransactionType BTT ON BTT.intBankTransactionTypeId = BT.intBankTransactionTypeId
LEFT JOIN tblSMCompanyLocation CL on CL.intCompanyLocationId = BT.intCompanyLocationId
LEFT JOIN tblSMCurrency CU on CU.intCurrencyID = BT.intCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = BT.intCurrencyExchangeRateTypeId
LEFT JOIN tblCMBankLoan BL ON BL.intBankLoanId = BT.intBankLoanId
LEFT JOIN tblGLFiscalPeriod FP on FP.intGLFiscalYearPeriodId = BT.intFiscalPeriodId
