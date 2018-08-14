
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
		WITH C AS(
		SELECT    id = CAST( ROW_NUMBER() OVER( ORDER BY intUndepositedFundId ) AS INT) 
		     	,uf.intUndepositedFundId
				,uf.intBankAccountId
				,intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(gl.apegl_gl_acct)
				,strAccountDescription = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetGLAccountIdFromOriginToi21(gl.apegl_gl_acct))
				,dblAmount = gl.apegl_gl_amt * -1
				,uf.strName
				,intEntityCustomerId = null
				,uf.dtmDate
				,intCurrencyId = null
				,dblWeightRate = 1
		FROM	apeglmst gl INNER JOIN vyuCMOriginDepositEntry v
					ON gl.apegl_cbk_no = v.aptrx_cbk_no
					AND gl.apegl_vnd_no = v.aptrx_vnd_no
					AND gl.apegl_ivc_no = v.aptrx_ivc_no
				INNER JOIN tblCMUndepositedFund uf
					ON uf.strSourceTransactionId = ( 
						CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS

		UNION 
		SELECT
			id						= CAST(ROW_NUMBER() OVER (ORDER BY CMUF.intUndepositedFundId) AS INT), 
			intUndepositedFundId	= CMUF.intUndepositedFundId, 
			intBankAccountId		= CMUF.intBankAccountId, 
			intGLAccountId			= ARP.intAccountId,
			strAccountDescription   = Account.strDescription,
			dblAmount				= CMUF.dblAmount,
			strName					= CMUF.strName, 
			intEntityCustomerId		= ARP.intEntityCustomerId,
			dtmDate					= CMUF.dtmDate,
			intCurrencyId			= ARP.intCurrencyId,
			dblWeightRate			= F.dblWeightRate
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
		OUTER APPLY(
			SELECT GL.strDescription FROM tblGLAccount GL WHERE GL.intAccountId = ARP.intAccountId
		)Account
		UNION
		SELECT
		    id						= CAST(ROW_NUMBER() OVER (ORDER BY CMUF.intUndepositedFundId) AS INT), 
			intUndepositedFundId	= CMUF.intUndepositedFundId, 
			intBankAccountId		= CMUF.intBankAccountId, 
			intGLAccountId			= ARI.intAccountId,
			strAccountDescription   = Account.strDescription,
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
		OUTER APPLY(
			SELECT GL.strDescription FROM tblGLAccount GL WHERE GL.intAccountId = ARI.intAccountId
		)Account
		)
		SELECT
			id,
			intUndepositedFundId,
			intBankAccountId,
			intGLAccountId,
			strAccountDescription,
			dblAmount,
			strName,		
			intEntityCustomerId,
			dtmDate,			
			intCurrencyId,
			dblWeightRate
			FROM C c
		')


END

GO