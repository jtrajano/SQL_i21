GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwclsmst')
	DROP VIEW vwclsmst

GO
--AG view
IF  ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'agclsmst') = 1)
BEGIN
	EXEC ('
		CREATE VIEW [dbo].[vwclsmst]
		AS
			SELECT
			vwcls_desc				=CAST(agcls_desc AS CHAR(20))	COLLATE Latin1_General_CI_AS   	  		
			,vwcls_sls_acct_no		=agcls_sls_acct_no	
			,vwcls_pur_acct_no		=agcls_pur_acct_no	
			,vwcls_var_acct_no		=agcls_var_acct_no	
			,vwcls_inv_acct_no		=agcls_inv_acct_no	
			,vwcls_beg_inv_acct_no	=agcls_beg_inv_acct_no	
			,vwcls_end_inv_acct_no	=agcls_end_inv_acct_no	
			,vwcls_cd =agcls_cd COLLATE Latin1_General_CI_AS   	  		
			,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
			FROM agclsmst
		')
END
GO

--PT view
IF  ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ptclsmst') = 1)
BEGIN
	EXEC ('
		CREATE VIEW [dbo].[vwclsmst]
			AS
			SELECT
			vwcls_desc				=CAST(ptcls_desc AS CHAR(20))	COLLATE Latin1_General_CI_AS   	
			,vwcls_sls_acct_no		=ptcls_sls_acct_no	
			,vwcls_pur_acct_no		=ptcls_pur_acct_no	
			,vwcls_var_acct_no		=ptcls_var_acct_no	
			,vwcls_inv_acct_no		=ptcls_inv_acct_no	
			,vwcls_beg_inv_acct_no	=ptcls_beg_inv_acct_no	
			,vwcls_end_inv_acct_no	=ptcls_end_inv_acct_no	
			,vwcls_cd				=ptcls_class COLLATE Latin1_General_CI_AS   	  		
			,A4GLIdentity			=CAST(A4GLIdentity   AS INT)
			FROM ptclsmst
	')
END
GO

