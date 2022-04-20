CREATE FUNCTION [dbo].[fnARCashFlowTransactions]
(
	@dtmDateFrom DATETIME = NULL,
	@dtmDateTo DATETIME = NULL
)
RETURNS TABLE
AS
RETURN SELECT
	 intTransactionId		= ARI.intInvoiceId
	,strTransactionId		= ARI.strInvoiceNumber
	,strTransactionType		= ARI.strTransactionType
	,intCurrencyId			= ARI.intCurrencyId
	,dtmDate				= ISNULL(ARI.dtmCashFlowDate, ARI.dtmDate)
	,dblAmount				= CASE WHEN ARI.strTransactionType NOT IN ('Invoice', 'Debit Memo') THEN ISNULL(ARI.dblAmountDue, 0) * -1 ELSE ISNULL(ARI.dblAmountDue, 0) END
	,intBankAccountId		= CMUF.intBankAccountId
	,intGLAccountId			= ARI.intAccountId
	,intCompanyLocationId	= ARI.intCompanyLocationId
	,ysnPosted				= ISNULL(ARI.ysnPosted, 0)
FROM tblARInvoice ARI
LEFT JOIN tblCMUndepositedFund CMUF ON ARI.strInvoiceNumber = CMUF.strSourceTransactionId AND strSourceSystem = 'AR'
LEFT JOIN tblARPaymentDetail ARPD ON ARI.intInvoiceId = ARPD.intInvoiceId
LEFT JOIN tblARPayment ARP ON ARPD.intPaymentId = ARP.intPaymentId
WHERE (@dtmDateFrom IS NULL OR ISNULL(ARI.dtmCashFlowDate, ARI.dtmDate) >= @dtmDateFrom)
  AND (@dtmDateTo IS NULL OR ISNULL(ARI.dtmCashFlowDate, ARI.dtmDate) <= @dtmDateTo)
  AND (
	(ARI.ysnPaid = 0 AND ARI.strTransactionType <> 'Customer Prepayment')
	OR
	(ARP.ysnPosted = 1 AND ARI.strTransactionType = 'Customer Prepayment')
  )

GO