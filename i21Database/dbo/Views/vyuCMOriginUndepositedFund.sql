
-- Create a stub view
-- The real view is in the integration script. A stub view is used to avoid errors in the undeposited screen process when the 
-- origin AP module is not installed. 


CREATE VIEW [dbo].[vyuCMOriginUndepositedFund]
AS
WITH AR AS (
	SELECT intAccountId,  intEntityCustomerId,intCurrencyId, intPaymentId intSourceTransactionId, strRecordNumber strSourceTransactionId, 'Payment' strType,
	dblExchangeRate dblWeightRate,
	intCurrencyExchangeRateTypeId
	FROM tblARPayment UNION
	SELECT intAccountId,  intEntityCustomerId,intCurrencyId, intInvoiceId intSourceTransactionId, strInvoiceNumber strSourceTransactionId, 'Invoice' strType 
	,dblCurrencyExchangeRate dblWeightRate
	,null intCurrencyExchangeRateTypeId
	FROM tblARInvoice UNION
	SELECT intUndepositedFundsId intAccountId,intEntityId intEntityCustomerId,intCurrencyId, intPOSEndOfDayId intSourceTransactionId, strEODNo strSourceTransactionId, 'EndOfDay' strType 
	,CAST(1 AS NUMERIC(18,6)) dblWeightRate
	,null intCurrencyExchangeRateTypeId
	FROM tblARPOSEndOfDay
),

C AS (
	SELECT
		id						= CAST(ROW_NUMBER() OVER (ORDER BY CMUF.intUndepositedFundId) AS INT), 
		intUndepositedFundId	= CMUF.intUndepositedFundId, 
		intBankAccountId		= CMUF.intBankAccountId, 
		intGLAccountId			= ARP.intAccountId ,
		dblAmount				= CMUF.dblAmount,
		strName					= CMUF.strName, 
		intEntityCustomerId		= ARP.intEntityCustomerId,
		dtmDate					= CMUF.dtmDate,
		intCurrencyId			= ARP.intCurrencyId,
		dblWeightRate			= 
		CASE WHEN strType = 'Payment'
										THEN 
											 CASE WHEN ARP.dblWeightRate IS NULL OR ARP.dblWeightRate = 0 THEN CAST(1 AS NUMERIC(18,6)) ELSE ARP.dblWeightRate END
								  WHEN strType = 'Invoice'
										THEN
											CASE WHEN G.dblWeightRate IS NULL OR G.dblWeightRate = 0 THEN CAST(1 AS NUMERIC(18,6)) ELSE G.dblWeightRate END
											
								  ELSE
										CAST(1 AS NUMERIC(18,6))
								  END
		,intCurrencyExchangeRateTypeId
		,CMUF.strSourceTransactionId
	FROM
		tblCMUndepositedFund CMUF
	INNER JOIN
		AR ARP
			ON CMUF.intSourceTransactionId = ARP.intSourceTransactionId
			AND CMUF.strSourceTransactionId = ARP.strSourceTransactionId
	OUTER APPLY(
		SELECT dblWeightRate = 
			SUM(CASE WHEN ARID.dblCurrencyExchangeRate > 0 
				THEN ARID.dblCurrencyExchangeRate
				ELSE CAST(1 AS NUMERIC(18,6)) END * ARID.dblTotal )/
			NULLIF(SUM(ARID.dblTotal), 0)
		FROM tblARInvoiceDetail ARID WHERE ARID.intInvoiceId = ARP.intSourceTransactionId
	)G
	
)
SELECT
	id,
	intUndepositedFundId,
	intBankAccountId,
	intGLAccountId,
	Account.strDescription strAccountDescription,
	dblAmount,
	strName,		
	intEntityCustomerId,
	dtmDate,			
	intCurrencyId,
	dblWeightRate,
	intCurrencyExchangeRateTypeId,
	strSourceTransactionId
	FROM C c
OUTER APPLY(
	SELECT GL.strDescription FROM tblGLAccount GL WHERE GL.intAccountId = c.intGLAccountId
)Account
GO