CREATE VIEW [dbo].[vyuCMBankTransactionBatchDetail]
AS
SELECT        
BTB.intBankTransactionBatchId, 
BT.intTransactionId, 
BT.strTransactionId, 
BT.intBankLoanId,
BL.strBankLoanId,
BTD.dtmDate, 
BTD.intGLAccountId, 
GL.strAccountId, 
BTD.strDescription, 
BT.strPayee AS strName,
BTD.dblCredit, 
BTD.dblDebit, 
BTD.dblCreditForeign, 
BTD.dblDebitForeign, 
BTD.intCurrencyExchangeRateTypeId,
SMR.strCurrencyExchangeRateType,
BTD.dblExchangeRate,
BT.dblAmount,
BTD.intConcurrencyId, 
BT.ysnPosted,
strRowState = ''
FROM tblCMBankTransactionBatch AS BTB INNER JOIN
    tblCMBankTransaction AS BT ON BTB.strBankTransactionBatchId = BT.strLink INNER JOIN
    tblCMBankTransactionDetail AS BTD ON BT.intTransactionId = BTD.intTransactionId INNER JOIN
    vyuGLAccountDetail AS GL ON BTD.intGLAccountId = GL.intAccountId
	LEFT JOIN tblCMBankLoan BL on BL.intBankLoanId = BT.intBankLoanId
    LEFT JOIN tblSMCurrencyExchangeRateType SMR ON SMR.intCurrencyExchangeRateTypeId = BTD.intCurrencyExchangeRateTypeId
GO


