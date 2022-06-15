IF (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'premtmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginEmployeeTax'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginEmployeeTax')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginEmployeeTax]
	AS
	SELECT
		intYear				= CAST(premt_year AS INT)
		,intQuarter			= CAST(premt_qtrno AS INT)
		,strEmployeeNo		= CAST(premt_emp AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strLastName		= CAST(premp_last_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strFirstName		= CAST(premp_first_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strMiddleName		= CAST(premp_initial AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strType			= CAST(premt_tax_type AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strTaxCode			= CAST(premt_code AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckLiteral	= CAST(premt_literal AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,ysnCredit			= CAST(CASE premt_credit_yn WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,dblTaxable			= CAST(premt_taxable AS NUMERIC(18, 6))
		,dblWithheld		= CAST(premt_withheld AS NUMERIC(18, 6))
		,dblTotalWages		= CAST(premt_total_wages AS NUMERIC(18, 6))
		,strUserId			= CAST(premt_user_id AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(premt_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((premt_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((premt_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((premt_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(premtmst.A4GLIdentity AS INT), -999)
	FROM
		premtmst
		left join prempmst on premtmst.premt_emp = prempmst.premp_emp')

END

GO