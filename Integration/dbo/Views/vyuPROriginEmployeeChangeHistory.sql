IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'premhmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginEmployeeChangeHistory'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginEmployeeChangeHistory')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginEmployeeChangeHistory]
	AS
	SELECT
		strEmployeeNo		= CAST(premh_emp AS NVARCHAR(200))
		,dtmDate			= CAST(CASE WHEN (ISNULL(premh_period_date, 0) = 0) THEN NULL
								ELSE CAST((premh_period_date / 10000) AS VARCHAR) + ''-'' + 
									CAST((premh_period_date % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((premh_period_date % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,dtmTime			= CAST(CASE WHEN (ISNULL(premh_period_date, 0) = 0) THEN NULL
									ELSE CAST((premh_period_date / 10000) AS VARCHAR) + ''-'' + 
										CAST((premh_period_date % 10000) / 100 AS VARCHAR) + ''-'' + 
										CAST((premh_period_date % 100) AS VARCHAR) + '' '' +
										CAST((premh_time / 1000000) AS VARCHAR) + '':'' +
										CAST((premh_time % 1000000) / 10000 AS VARCHAR) + '':'' +
										CAST(((premh_time % 1000000) % 10000) / 100 AS VARCHAR) + ''.'' + 
										CAST((premh_time % 100) AS VARCHAR)
									END 
								AS DATETIME)
		,strFieldName		= CAST(premh_field_id AS NVARCHAR(200))
		,strOldData			= RTRIM(LTRIM(premh_old_data))
		,strNewData			= RTRIM(LTRIM(premh_new_data))
		,strUserId			= CAST(premh_user_id AS NVARCHAR(200))
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(premh_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((premh_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((premh_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((premh_user_rev_dt % 100) AS VARCHAR)
								END 
							AS DATETIME)
	FROM 
		premhmst')

END

GO