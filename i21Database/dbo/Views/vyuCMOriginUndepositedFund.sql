
-- Create a stub view
-- The real view is in the integration script. A stub view is used to avoid errors in the undeposited screen process when the 
-- origin AP module is not installed. 

CREATE VIEW vyuCMOriginUndepositedFund
AS
WITH C AS (
	SELECT
		intUndepositedFundId	= CMUF.intUndepositedFundId, 
		intBankAccountId		= CMUF.intBankAccountId, 
		intGLAccountId			= ARP.intAccountId ,
		dblAmount				= CMUF.dblAmount,
		strName					= CMUF.strName, 
		intEntityCustomerId		= ARP.intEntityCustomerId,
		dtmDate					= CMUF.dtmDate,
		intCurrencyId			= ARP.intCurrencyId,
		 dblWeightRate			= case when F.dblWeightRate is null then 1 else F.dblWeightRate end
	FROM
		tblCMUndepositedFund CMUF
	INNER JOIN
		tblARPayment ARP
			ON CMUF.intSourceTransactionId = ARP.intPaymentId
			AND CMUF.strSourceTransactionId = ARP.strRecordNumber
	OUTER APPLY(
		SELECT dblWeightRate = 
			SUM(CASE WHEN ARPD.dblCurrencyExchangeRate > 0 
				THEN ARPD.dblCurrencyExchangeRate
				ELSE 1 END * ARPD.dblPayment )/
			NULLIF(SUM(ARPD.dblPayment), 0) 
		FROM tblARPaymentDetail ARPD WHERE ARPD.intPaymentId = ARP.intPaymentId
	)F
	UNION
	SELECT
		intUndepositedFundId	= CMUF.intUndepositedFundId, 
		intBankAccountId		= CMUF.intBankAccountId, 
		intGLAccountId			= ARI.intAccountId,
		dblAmount				= CMUF.dblAmount,
		strName					= CMUF.strName, 
		intEntityCustomerId		= ARI.intEntityCustomerId,
		dtmDate					= CMUF.dtmDate,
		intCurrencyId			= ARI.intCurrencyId,
		 dblWeightRate			= case when G.dblWeightRate is null then 1 else G.dblWeightRate end
	FROM
		tblCMUndepositedFund CMUF
	INNER JOIN
		tblARInvoice ARI
			ON CMUF.intSourceTransactionId = ARI.intInvoiceId
			AND CMUF.strSourceTransactionId = ARI.strInvoiceNumber
	OUTER APPLY(
		SELECT dblWeightRate = 
			SUM(CASE WHEN ARID.dblCurrencyExchangeRate > 0 
				THEN ARID.dblCurrencyExchangeRate
				ELSE 1 END * ARID.dblTotal )/
			NULLIF(SUM(ARID.dblTotal), 0)
		FROM tblARInvoiceDetail ARID WHERE ARID.intInvoiceId = ARI.intInvoiceId
	)G
)
SELECT
	intUndepositedFundId,
	intBankAccountId,
	intGLAccountId,
	Account.strDescription strAccountDescription,
	dblAmount,
	strName,		
	intEntityCustomerId,
	dtmDate,			
	intCurrencyId,
	dblWeightRate
	FROM C c
OUTER APPLY(
	SELECT GL.strDescription FROM tblGLAccount GL WHERE GL.intAccountId = c.intGLAccountId
)Account