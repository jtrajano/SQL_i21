CREATE VIEW [dbo].[vwclsmst]
AS
SELECT
vwcls_desc				=CAST(agcls_desc AS CHAR(20))		 		
,vwcls_sls_acct_no		=agcls_sls_acct_no	
,vwcls_pur_acct_no		=agcls_pur_acct_no	
,vwcls_var_acct_no		=agcls_var_acct_no	
,vwcls_inv_acct_no		=agcls_inv_acct_no	
,vwcls_beg_inv_acct_no	=agcls_beg_inv_acct_no	
,vwcls_end_inv_acct_no	=agcls_end_inv_acct_no	
,vwcls_cd =agcls_cd
,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
FROM agclsmst