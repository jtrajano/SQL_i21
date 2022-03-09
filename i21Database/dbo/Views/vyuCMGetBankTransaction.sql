CREATE VIEW vyuCMGetBankTransaction
AS
SELECT BT.*,
BA.strBankAccountNo,
CU.strCurrency,
CL.strLocationName,
RT.strCurrencyExchangeRateType,
FP.strPeriod,
CASE WHEN CHARINDEX ('-F', Related.strTransactionId) > 0 THEN Related.strTransactionId ELSE '' END strBankFeesId,
CASE WHEN CHARINDEX ('-F', Related.strTransactionId) > 0 THEN ISNULL(Related.dblAmount,0) ELSE CAST(0 AS BIT) END dblAmountFees,
CASE WHEN CHARINDEX ('-F', Related.strTransactionId) > 0 THEN ISNULL(Related.ysnPosted,0) ELSE CAST(0 AS BIT) END ysnPostedFees,
CASE WHEN CHARINDEX ('-F', Related.strTransactionId) > 0 THEN Related.strMemo ELSE '' END strDescFees,
CASE WHEN CHARINDEX ('-F', Related.strTransactionId) > 0 THEN (ISNULL(Related.dblAmount,0) +  BT.dblAmount   ) ELSE 0  END dblTotalAmount,
CASE WHEN CHARINDEX ('-F', Related.strTransactionId) > 0 THEN Related.strAccountId  ELSE '' END strAccountIdFees,
BTT.strBankTransactionTypeName,
BL.strBankLoanId,
strRelatedId = Related.strTransactionId,
intRelatedBankTypeId = Related.intBankTransactionTypeId
FROM tblCMBankTransaction BT 
OUTER APPLY(
    SELECT TOP 1 
	strTransactionId,
	GL.strAccountId,
    ysnPosted, 
    dblAmount,
    strMemo,
	strType,
	intBankTransactionTypeId
    FROM tblCMBankTransaction A JOIN tblCMBankTransactionAdjustment B
	ON A.intTransactionId =	B.intRelatedId
	LEFT JOIN tblCMBankTransactionDetail BTD ON
	BTD.intTransactionId = A.intTransactionId
	LEFT JOIN tblGLAccount GL ON GL.intAccountId = BTD.intGLAccountId	
	WHERE
	BT.intTransactionId = 
	B.intTransactionId

)Related
LEFT JOIN vyuCMBankAccount BA on BA.intBankAccountId = BT.intBankAccountId
LEFT JOIN tblCMBankTransactionType BTT ON BTT.intBankTransactionTypeId = BT.intBankTransactionTypeId
LEFT JOIN tblSMCompanyLocation CL on CL.intCompanyLocationId = BT.intCompanyLocationId
LEFT JOIN tblSMCurrency CU on CU.intCurrencyID = BT.intCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = BT.intCurrencyExchangeRateTypeId
LEFT JOIN tblCMBankLoan BL ON BL.intBankLoanId = BT.intBankLoanId
LEFT JOIN tblGLFiscalYearPeriod FP on FP.intGLFiscalYearPeriodId = BT.intFiscalPeriodId

