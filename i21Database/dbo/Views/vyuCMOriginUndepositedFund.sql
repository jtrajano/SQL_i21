
-- Create a stub view
-- The real view is in the integration script. A stub view is used to avoid errors in the undeposited screen process when the 
-- origin AP module is not installed. 

CREATE VIEW [dbo].[vyuCMOriginUndepositedFund]
AS

SELECT
	id						= CAST(ROW_NUMBER() OVER (ORDER BY CMUF.intUndepositedFundId) AS INT), 
	intUndepositedFundId	= CMUF.intUndepositedFundId, 
	intBankAccountId		= CMUF.intBankAccountId, 
	intGLAccountId			= CASE WHEN ARP.intPaymentId IS NOT NULL THEN ARP.intAccountId ELSE ARI.intAccountId END,
	strAccountDescription	= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = (CASE WHEN ARP.intPaymentId IS NOT NULL THEN ARP.intAccountId ELSE ARI.intAccountId END)),
	dblAmount				= CMUF.dblAmount,
	strName					= CMUF.strName, 
	intEntityCustomerId		= CASE WHEN ARP.intPaymentId IS NOT NULL THEN ARP.intEntityCustomerId ELSE ARI.intEntityCustomerId END,
	dtmDate					= CMUF.dtmDate,
	intCurrencyId			= ARP.intCurrencyId,
	dblWeightRate			= _Functional.Val/_Foreign.Val
FROM
	tblCMUndepositedFund CMUF
LEFT OUTER JOIN
	tblARPayment ARP
		ON CMUF.intSourceTransactionId = ARP.intPaymentId
		AND CMUF.strSourceTransactionId = ARP.strRecordNumber
LEFT OUTER JOIN
	tblARInvoice ARI
		ON CMUF.intSourceTransactionId = ARI.intInvoiceId
		AND CMUF.strSourceTransactionId = ARI.strInvoiceNumber 
outer APPLY(
	SELECT SUM(dblPayment *  CASE WHEN  dblCurrencyExchangeRate > 0 THEN dblCurrencyExchangeRate ELSE 1 END )Val
	from tblARPaymentDetail A where intPaymentId = ARP.intPaymentId
)_Functional

outer APPLY(
	SELECT SUM(dblPayment) Val
	from tblARPaymentDetail where intPaymentId = ARP.intPaymentId
) _Foreign


