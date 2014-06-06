
-- The purpose of this view is to retrieve the G/L and amount associated to the Deposit Entry from origin. 
-- Records from this view will be used as detail items in the Bank Deposit. 

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
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

	')
END

GO