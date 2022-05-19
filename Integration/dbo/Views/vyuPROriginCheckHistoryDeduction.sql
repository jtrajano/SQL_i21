IF (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prhsdmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginCheckHistoryDeduction'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginCheckHistoryDeduction')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginCheckHistoryDeduction]
	AS
	SELECT
		strEmployeeNo		= CAST(prhsd_emp_no AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strLastName		= CAST(premp_last_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strFirstName		= CAST(premp_first_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strMiddleName		= CAST(premp_initial AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCode			= CAST(prhsd_code AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckNumber		= CAST(prhsd_no AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckType		= CAST(CASE prhsd_chk_type WHEN ''I'' THEN ''Individual'' ELSE ''Regular'' END AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strDeductionCode	= CAST(prhsd_ded AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strType			= CAST(prhsd_type AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strDepartment		= CAST(prhsd_dept AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblAmount			= CAST(prhsd_amt AS NUMERIC(18, 6))
		,strAccountNo		= CAST(prhsd_acct_no AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strBankCode		= CAST(prhsd_ddp_bnk_code AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strPaidBy			= CAST(CASE prhsd_co_emp_cd WHEN ''C'' THEN ''Company'' ELSE ''Employee'' END AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckLiteral	= CAST(prhsd_literal AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strAccountType		= CAST(CASE prhsd_acct_type_cs WHEN ''C'' THEN ''Checking'' ELSE ''Savings'' END AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblTaxableEarning	= CAST(prhsd_taxable_earnings AS NUMERIC(18, 6))
		,strUserId			= CAST(prhsd_user_id AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(prhsd_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((prhsd_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((prhsd_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((prhsd_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(prhsdmst.A4GLIdentity AS INT), -999)
	FROM
		prhsdmst
		left join prempmst on prhsdmst.prhsd_emp_no = prempmst.premp_emp')

END

GO