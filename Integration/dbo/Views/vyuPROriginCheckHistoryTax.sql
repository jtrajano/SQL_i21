IF (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prhstmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginCheckHistoryTax'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginCheckHistoryTax')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginCheckHistoryTax]
	AS
	SELECT
		strEmployeeNo		= CAST(prhst_emp_no AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strLastName		= CAST(premp_last_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strFirstName		= CAST(premp_first_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strMiddleName		= CAST(premp_initial AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCode			= CAST(prhst_code AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckNumber		= CAST(prhst_no AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckType		= CAST(CASE prhst_chk_type WHEN ''I'' THEN ''Individual'' ELSE ''Regular'' END AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strTaxCode			= CAST(prhst_tax AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strType			= CAST(prhst_tax_type AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strDepartment		= CAST(prhst_dept AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblAmount			= CAST(prhst_amt AS NUMERIC(18, 6))
		,ysnCredit			= CAST(CASE prhst_credit_yn WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,strPaidBy			= CAST(CASE prhst_paid_by WHEN ''C'' THEN ''Company'' ELSE ''Employee'' END AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckLiteral	= CAST(prhst_literal AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblTaxable			= CAST(prhst_taxable_wages AS NUMERIC(18, 6))
		,dblTotalWages		= CAST(prhst_total_wages AS NUMERIC(18, 6))
		,strUserId			= CAST(prhst_user_id AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(prhst_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((prhst_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((prhst_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((prhst_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(prhstmst.A4GLIdentity AS INT), -999)
	FROM
		prhstmst
		left join prempmst on prhstmst.prhst_emp_no = prempmst.premp_emp')

END

GO