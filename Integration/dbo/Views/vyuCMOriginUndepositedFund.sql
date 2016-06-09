
-- The purpose of this view is to retrieve the G/L and amount associated to the Deposit Entry from origin. 
-- Records from this view will be used as detail items in the Bank Deposit. 

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'apeglmst') = 1
BEGIN
	EXEC ('
		IF OBJECT_ID(''vyuCMOriginUndepositedFund'', ''V'') IS NOT NULL 
			DROP VIEW vyuCMOriginUndepositedFund
	')

	EXEC ('
		CREATE VIEW [dbo].[vyuCMOriginUndepositedFund]
		AS

		SELECT	id = CAST( ROW_NUMBER() OVER( ORDER BY intUndepositedFundId ) AS INT) 
				,uf.intUndepositedFundId
				,uf.intBankAccountId
				,intGLAccountId = dbo.fnGetGLAccountIdFromOriginToi21(gl.apegl_gl_acct)
				,strAccountDescription = (SELECT strDescription FROM tblGLAccount WHERE intAccountId = dbo.fnGetGLAccountIdFromOriginToi21(gl.apegl_gl_acct))
				,dblAmount = gl.apegl_gl_amt * -1
				,uf.strName
				,intEntityCustomerId = null
				,uf.dtmDate
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

		UNION SELECT
			id						= CAST(ROW_NUMBER() OVER (ORDER BY CMUF.intUndepositedFundId) AS INT), 
			intUndepositedFundId	= CMUF.intUndepositedFundId, 
			intBankAccountId		= CMUF.intBankAccountId, 
			intGLAccountId			= CASE WHEN ARP.intPaymentId IS NOT NULL THEN ARP.intAccountId ELSE ARI.intAccountId END,
			strAccountDescription	= (SELECT strDescription FROM tblGLAccount WHERE intAccountId = (CASE WHEN ARP.intPaymentId IS NOT NULL THEN ARP.intAccountId ELSE ARI.intAccountId END)),
			dblAmount				= CMUF.dblAmount,
			strName					= CMUF.strName, 
			intEntityCustomerId		= CASE WHEN ARP.intPaymentId IS NOT NULL THEN ARP.intEntityCustomerId ELSE ARI.intEntityCustomerId END,
			dtmDate					= CMUF.dtmDate
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


	')
END

GO