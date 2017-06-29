IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prempmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginEmployee'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginEmployee')

	EXEC ('
	CREATE VIEW [dbo].[vyuPROriginEmployee]
	AS
	SELECT
		strEmployeeNo			= CAST(premp_emp AS NVARCHAR(200))
		,strLastName			= CAST(premp_last_name AS NVARCHAR(200))
		,strFirstName			= CAST(premp_first_name AS NVARCHAR(200))
		,strMiddleName			= CAST(premp_initial AS NVARCHAR(200))
		,strAddress				= CAST(premp_addr1 AS NVARCHAR(1000))
		,strAddress2			= CAST(premp_addr2 AS NVARCHAR(1000))
		,strCity				= CAST(premp_city AS NVARCHAR(200))
		,strState				= CAST(premp_state AS NVARCHAR(100))
		,strZip					= CAST(premp_zip AS NVARCHAR(100))
		,strWorkState			= CAST(premp_work_state AS NVARCHAR(100))
		,strSSN					= CAST(premp_ssn AS NVARCHAR(100))
		,strPhone				= CAST(premp_phone AS NVARCHAR(100))
		,dblPayRate				= CAST(premp_rate AS NUMERIC(18, 6))
		,strDepartment			= CAST(premp_dept AS NVARCHAR(100))
		,strEmploymentType		= CASE WHEN (premp_employment = ''F'') THEN ''Full-Time'' 
									WHEN (premp_employment = ''P'') THEN ''Part-Time'' 
									ELSE premp_employment END
		,strStatus				= CASE WHEN (premp_status = ''T'') THEN ''Terminated'' 
									WHEN (premp_status = ''A'') THEN ''Active''
									ELSE premp_status END
		,strPayType				= CASE WHEN (premp_pay_type = ''S'') THEN ''Salary''
									WHEN (premp_pay_type = ''H'') THEN ''Hourly''
									ELSE premp_pay_type END
		,strPayCycle			= CASE WHEN (premp_pay_cycle = ''D'') THEN ''Daily''
									WHEN (premp_pay_cycle = ''W'') THEN ''Weekly''
									WHEN (premp_pay_cycle = ''B'') THEN ''Bi-Weekly''
									WHEN (premp_pay_cycle = ''S'') THEN ''Semi-Monthly''
									WHEN (premp_pay_cycle = ''M'') THEN ''Monthly''
									WHEN (premp_pay_cycle = ''Q'') THEN ''Quarterly''
									WHEN (premp_pay_cycle = ''A'') THEN ''Annual''
									ELSE premp_pay_cycle END
		,dtmLastCheckDate		= CAST(CASE WHEN (ISNULL(premp_last_chk_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_last_chk_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_last_chk_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_last_chk_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dblStandardHours		= CAST(premp_std_hrs AS NUMERIC(18, 6))
		,ysnVacAwardCalculated	= CAST(CASE WHEN (premp_vac_awards_calcd_yn = ''Y'') THEN 1 ELSE 0 END AS BIT)
		,strVacAwardAnnivOrYtd	= CASE WHEN(premp_vac_awards_anniv_ytd_ay = ''A'') THEN ''Anniversary Date'' ELSE ''Start of Year'' END
		,strVacMethod			= CASE WHEN(premp_vac_method = 1) THEN ''Standard'' ELSE ''Accrual'' END
		,dblAccrual				= CAST(premp_vac_std_accrual AS NUMERIC(18, 6))
		,dblCurrentAccrual		= CAST(premp_vac_curr_accrual AS NUMERIC(18, 6))
		,dtmVacationEligDate	= CAST(CASE WHEN (ISNULL(premp_vac_elig_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_vac_elig_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_vac_elig_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_vac_elig_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,ysnVacAwarded			= CAST(CASE WHEN (premp_vac_award_yn = ''Y'') THEN 1 ELSE 0 END AS BIT)
		,dtmVacationAwardDate	= CAST(CASE WHEN (ISNULL(premp_vac_award_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_vac_award_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_vac_award_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_vac_award_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dblVacationCarried		= CAST(premp_vac_carried AS NUMERIC(18, 6))
		,dblVacationEarned		= CAST(premp_vac_earned AS NUMERIC(18, 6))
		,dblVacHrsPd			= CAST(premp_vac_hrs_pd AS NUMERIC(18, 6))
		,strSicAwardAnnivorYtd	= CASE WHEN(premp_sic_awards_anniv_ytd_ay = ''A'') THEN ''Anniversary Date'' ELSE ''Start of Year'' END
		,ysnSicAwardCalculated	= CAST(CASE WHEN (premp_sic_awards_calcd_yn = ''Y'') THEN 1 ELSE 0 END AS BIT)
		,strJobTitle			= premp_job_title
		,strEEOC				= premp_eeo_code
		,strEthnicity			= premp_race
		,strGender				= CASE WHEN(premp_sex = ''M'') THEN ''Male'' ELSE ''Female'' END
		,strMaritalStatus		= CASE WHEN(premp_marital_status = ''M'') THEN ''Married'' ELSE ''Single'' END
		,dtmBirthDate			= CAST(CASE WHEN (ISNULL(premp_birth_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_birth_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_birth_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_birth_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dtmTermDate			= CAST(CASE WHEN (ISNULL(premp_term_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_term_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_term_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_term_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,strTermCode			= premp_term_code
		,dtmOriginalHireDate	= CAST(CASE WHEN (ISNULL(premp_orig_hire_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_orig_hire_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_orig_hire_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_orig_hire_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dtmLastHireDate		= CAST(CASE WHEN (ISNULL(premp_last_hire_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_last_hire_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_last_hire_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_last_hire_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dtmReviewDate			= CAST(CASE WHEN (ISNULL(premp_last_review_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_last_review_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_last_review_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_last_review_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dtmNextReviewDate		= CAST(CASE WHEN (ISNULL(premp_next_review_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_next_review_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_next_review_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_next_review_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,dtmInsuranceDate		= CAST(CASE WHEN (ISNULL(premp_insur_dt, 0) = 0) THEN NULL
										ELSE CAST((premp_insur_dt / 10000) AS VARCHAR) + ''-'' + 
											CAST((premp_insur_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
											CAST((premp_insur_dt % 100) AS VARCHAR)
										END 
								  AS DATETIME)
		,intIdentityKey			= ISNULL(CAST(A4GLIdentity AS INT), -999)
	FROM
		prempmst')

END

GO