IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'premdmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginEmployeeDeduction'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginEmployeeDeduction')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginEmployeeDeduction]
	AS
	SELECT
		intYear				= CAST(premd_year AS INT)
		,intQuarter			= CAST(premd_qtrno AS INT)
		,strEmployeeNo		= CAST(premd_emp AS NVARCHAR(200))
		,strDeductionCode	= CAST(premd_code AS NVARCHAR(200))
		,strType			= CAST(premd_type AS NVARCHAR(200))
		,strCheckLiteral	= CAST(premd_literal AS NVARCHAR(200))
		,dtmLastCheckDate	= CAST(CASE WHEN (ISNULL(premd_last_chk_dt, 0) = 0) THEN NULL
								ELSE CAST((premd_last_chk_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((premd_last_chk_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((premd_last_chk_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,dblAmountYTD		= CAST(premd_ytd_amt AS NUMERIC(18, 6))
		,dblTaxableToDate	= CAST(premd_taxable_earn_to_date AS NUMERIC(18, 6))
		,strUserId			= CAST(premd_user_id AS NVARCHAR(200))
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(premd_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((premd_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((premd_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((premd_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(A4GLIdentity AS INT), -999)
	FROM
		premdmst')

END

GO