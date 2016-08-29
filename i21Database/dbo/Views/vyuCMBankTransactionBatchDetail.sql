CREATE VIEW [dbo].[vyuCMBankTransactionBatchDetail]
AS
SELECT        
BTB.intBankTransactionBatchId, 
BT.intTransactionId, 
BT.strTransactionId, 
BTD.dtmDate, 
BTD.intGLAccountId, 
GL.strAccountId, 
BTD.strDescription, 
BT.strPayee AS strName,
BTD.dblCredit, 
BTD.dblDebit, 
BTD.intConcurrencyId, 
BT.ysnPosted
FROM tblCMBankTransactionBatch AS BTB INNER JOIN
    tblCMBankTransaction AS BT ON BTB.strBankTransactionBatchId = BT.strLink INNER JOIN
    tblCMBankTransactionDetail AS BTD ON BT.intTransactionId = BTD.intTransactionId INNER JOIN
    vyuGLAccountDetail AS GL ON BTD.intGLAccountId = GL.intAccountId


