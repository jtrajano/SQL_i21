
-- Create a stub view
-- The real view is in the integration script. A stub view is used to avoid errors in the undeposited screen process when the 
-- origin AP module is not installed. 

CREATE VIEW [dbo].[vyuCMOriginUndepositedFund]
AS

SELECT
id = CAST(ROW_NUMBER() OVER (ORDER BY intUndepositedFundId) AS INT), 
intUndepositedFundId, 
intBankAccountId, 
intGLAccountId = (SELECT intAccountId FROM tblARPayment WHERE  intPaymentId = tblCMUndepositedFund.intSourceTransactionId),
strAccountDescription = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = (SELECT intAccountId FROM tblARPayment WHERE  intPaymentId = tblCMUndepositedFund.intSourceTransactionId)),
dblAmount,
strName, 
intEntityCustomerId = (SELECT intEntityCustomerId FROM tblARPayment WHERE  intPaymentId = tblCMUndepositedFund.intSourceTransactionId),
dtmDate
FROM tblCMUndepositedFund

