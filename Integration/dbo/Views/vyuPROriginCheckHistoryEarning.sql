IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prhsemst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginCheckHistoryEarning'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginCheckHistoryEarning')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginCheckHistoryEarning]
	AS
	SELECT
		strEmployeeNo		= CAST(prhse_emp_no AS NVARCHAR(200))
		,strCode			= CAST(prhse_code AS NVARCHAR(200))
		,strCheckNumber		= CAST(prhse_no AS NVARCHAR(200))
		,strCheckType		= CAST(CASE prhse_chk_type WHEN ''I'' THEN ''Individual'' ELSE ''Regular'' END AS NVARCHAR(200))
		,intSequenceNo		= CAST(prhse_seq_no AS INT)
		,strEarningCode		= CAST(prhse_earn AS NVARCHAR(200))
		,strStateId			= CAST(prhse_stid AS NVARCHAR(200))
		,strDepartment		= CAST(prhse_dept AS NVARCHAR(200))
		,dblRate			= CAST(prhse_rate AS NUMERIC(18, 6))
		,dblRegHours		= CAST(prhse_reg_hrs AS NUMERIC(18, 6))
		,dblRegEarning		= CAST(prhse_reg_earn AS NUMERIC(18, 6))
		,strCheckLiteral	= CAST(prhse_literal AS NVARCHAR(200))
		,strWCCode			= CAST(prhse_prwcc AS NVARCHAR(200))
		,strEarningClass	= CAST(prhse_class AS NVARCHAR(200))
		,strMemoType		= CAST(prhse_memo_type_tw AS NVARCHAR(200))
		,strUserId			= CAST(prhse_user_id AS NVARCHAR(200))
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(prhse_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((prhse_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((prhse_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((prhse_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(A4GLIdentity AS INT), -999)
	FROM
		prhsemst')

END

GO