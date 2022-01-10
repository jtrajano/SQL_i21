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
	,dblAmount				= ARI.dblInvoiceTotal
	,intBankAccountId		= CMUF.intBankAccountId
	,intGLAccountId			= ARI.intAccountId
	,intCompanyLocationId	= ARI.intCompanyLocationId
	,ysnPosted				= ISNULL(ARI.ysnPosted, 0)
FROM tblARInvoice ARI
LEFT JOIN tblCMUndepositedFund CMUF
ON ARI.strInvoiceNumber = CMUF.strSourceTransactionId
AND strSourceSystem = 'AR'
WHERE (@dtmDateFrom IS NULL OR ISNULL(ARI.dtmCashFlowDate, ARI.dtmDate) >= @dtmDateFrom)
  AND (@dtmDateTo IS NULL OR ISNULL(ARI.dtmCashFlowDate, ARI.dtmDate) <= @dtmDateTo)

GO