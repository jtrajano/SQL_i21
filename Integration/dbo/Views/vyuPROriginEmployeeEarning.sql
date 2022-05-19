IF (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prememst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginEmployeeEarning'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginEmployeeEarning')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginEmployeeEarning]
	AS
	SELECT
		intYear				= CAST(preme_year AS INT)
		,intQuarter			= CAST(preme_qtrno AS INT)
		,strEmployeeNo		= CAST(preme_emp AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strLastName		= CAST(premp_last_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strFirstName		= CAST(premp_first_name AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strMiddleName		= CAST(premp_initial AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strEarningCode		= CAST(preme_code AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strStateId			= CAST(preme_stid AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckLiteral	= CAST(preme_literal AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblRegHours		= CAST(preme_reg_hrs AS NUMERIC(18, 6))
		,dblRegEarning		= CAST(preme_reg_earn AS NUMERIC(18, 6))
		,dtmLastCheckDate	= CAST(CASE WHEN (ISNULL(preme_last_chk_dt, 0) = 0) THEN NULL
								ELSE CAST((preme_last_chk_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((preme_last_chk_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((preme_last_chk_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,strEarningClass	= CAST(preme_prern_class AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strMemoType		= CAST(preme_memo_type_tw AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strUserId			= CAST(preme_user_id AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(preme_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((preme_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((preme_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((preme_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(prememst.A4GLIdentity AS INT), -999)
	FROM
		prememst
		left join prempmst on prememst.preme_emp = prempmst.premp_emp')

END

GO