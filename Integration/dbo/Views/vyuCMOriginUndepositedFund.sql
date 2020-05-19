
-- The purpose of this view is to retrieve the G/L and amount associated to the Deposit Entry from origin. 
-- Records from this view will be used as detail items in the Bank Deposit. 

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'apeglmst') = 1
BEGIN
	EXEC ('
		IF OBJECT_ID(''vyuCMOriginUndepositedFund'', ''V'') IS NOT NULL 
			DROP VIEW vyuCMOriginUndepositedFund
	')

EXEC(
'CREATE VIEW [dbo].[vyuCMOriginUndepositedFund]
AS

WITH AR AS (
	SELECT    
		     	dbo.fnGetGLAccountIdFromOriginToi21(gl.apegl_gl_acct) intAccountId
				,null intEntityCustomerId 
				,DefaultCurrency.Val intCurrencyId
				,null intSourceTransactionId
				, CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
				+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
				+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
				+ CAST(v.aptrx_chk_no AS NVARCHAR(8))  COLLATE Latin1_General_CI_AS strSourceTransactionId 
				,'''' strType
				,CAST(1 AS NUMERIC(18,6)) dblWeightRate
				,null intCurrencyExchangeRateTypeId
	FROM	apeglmst gl INNER JOIN vyuCMOriginDepositEntry v
	ON gl.apegl_cbk_no COLLATE Latin1_General_CI_AS = v.aptrx_cbk_no
	AND gl.apegl_vnd_no COLLATE Latin1_General_CI_AS = v.aptrx_vnd_no
	AND gl.apegl_ivc_no COLLATE Latin1_General_CI_AS = v.aptrx_ivc_no
	OUTER APPLY (
		SELECT TOP 1 intDefaultCurrencyId Val FROM tblSMCompanyPreference
	)DefaultCurrency
	UNION
	SELECT intAccountId,  intEntityCustomerId,intCurrencyId, 
	intPaymentId intSourceTransactionId, strRecordNumber strSourceTransactionId , ''Payment''  strType 
	,dblExchangeRate dblWeightRate,
	intCurrencyExchangeRateTypeId
	FROM tblARPayment UNION
	SELECT intAccountId,  intEntityCustomerId,intCurrencyId, intInvoiceId intSourceTransactionId, strInvoiceNumber strSourceTransactionId, ''Invoice'' strType 
	,dblCurrencyExchangeRate dblWeightRate
	,null intCurrencyExchangeRateTypeId
	FROM tblARInvoice UNION
	SELECT intUndepositedFundsId intAccountId,intEntityId intEntityCustomerId,intCurrencyId, intPOSEndOfDayId intSourceTransactionId, strEODNo strSourceTransactionId, ''EndOfDay'' strType 
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
		dblWeightRate			= CASE WHEN strType = ''Payment''
										THEN 
											CASE WHEN F.dblWeightRate is null THEN 1 ELSE F.dblWeightRate END
								  WHEN strType = ''Invoice''
										THEN
											case WHEN G.dblWeightRate is null THEN 1 ELSE G.dblWeightRate END
								  ELSE
										1
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
			SUM(CASE WHEN ARPD.dblCurrencyExchangeRate > 0 
				THEN ARPD.dblCurrencyExchangeRate
				ELSE 1 END * ARPD.dblPayment )/
			NULLIF(SUM(ARPD.dblPayment), 0) 
		FROM tblARPaymentDetail ARPD WHERE ARPD.intPaymentId = ARP.intSourceTransactionId
	)F
	OUTER APPLY(
		SELECT dblWeightRate = 
			SUM(CASE WHEN ARID.dblCurrencyExchangeRate > 0 
				THEN ARID.dblCurrencyExchangeRate
				ELSE 1 END * ARID.dblTotal )/
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
)Account'
)
END
GO