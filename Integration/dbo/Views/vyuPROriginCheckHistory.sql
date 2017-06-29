IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prhsmmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginCheckHistory'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginCheckHistory')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginCheckHistory]
	AS
	SELECT
		strCode			= CAST(prhsm_code AS NVARCHAR(200))
		,strCheckNumber		= CAST(prhsm_no AS NVARCHAR(200))
		,strCheckType		= CAST(CASE prhsm_chk_type WHEN ''I'' THEN ''Individual'' ELSE ''Regular'' END AS NVARCHAR(200))
		,strEmployeeNo		= CAST(prhsm_emp AS NVARCHAR(200))
		,dtmCheckDate		= CAST(CASE WHEN (ISNULL(prhsm_chk_date, 0) = 0) THEN NULL
								ELSE CAST((prhsm_chk_date / 10000) AS VARCHAR) + ''-'' + 
									CAST((prhsm_chk_date % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((prhsm_chk_date % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,intQuarter			= CAST(prhsm_qtrno AS INT)
		,dtmPeriodDate		= CAST(CASE WHEN (ISNULL(prhsm_period_date, 0) = 0) THEN NULL
								ELSE CAST((prhsm_period_date / 10000) AS VARCHAR) + ''-'' + 
									CAST((prhsm_period_date % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((prhsm_period_date % 100) AS VARCHAR)
								END 
								AS DATETIME)
		,strBankCode		= CAST(prhsm_dir_dep_bank AS NVARCHAR(200))
		,strAccountNo		= CAST(prhsm_dir_dep_acct AS NVARCHAR(200))
		,dblGrossPay		= CAST(prhsm_gross AS NUMERIC(18, 6))
		,dblDeductions		= CAST(prhsm_deductions AS NUMERIC(18, 6))
		,dblTaxes			= CAST(prhsm_taxes AS NUMERIC(18, 6))
		,dblNetPay			= CAST(prhsm_net_pay AS NUMERIC(18, 6))
		,dblFedTaxable		= CAST(prhsm_fed_taxable AS NUMERIC(18, 6))
		,dblSSWage			= CAST(prhsm_ss_taxable AS NUMERIC(18, 6))
		,dblMedicareWage	= CAST(prhsm_med_taxable AS NUMERIC(18, 6))
		,dblFUITaxable		= CAST(prhsm_fui_taxable AS NUMERIC(18, 6))
		,dblSUITaxable		= CAST(prhsm_sui_taxable AS NUMERIC(18, 6))
		,dblStateTaxable	= CAST(prhsm_state_taxable AS NUMERIC(18, 6))
		,dblCityTaxable		= CAST(prhsm_city_taxable AS NUMERIC(18, 6))
		,dblCountyTaxable	= CAST(prhsm_cnty_taxable AS NUMERIC(18, 6))
		,dblSchoolTaxable	= CAST(prhsm_schdist_taxable AS NUMERIC(18, 6))
		,strDepartment		= CAST(prhsm_dept AS NVARCHAR(200))
		,ysnPrenoteSent		= CAST(CASE prhsm_prenote_yn WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,strUserId			= CAST(prhsm_user_id AS NVARCHAR(200))
		,dtmUserRevision	= CAST(CASE WHEN (ISNULL(prhsm_user_rev_dt, 0) = 0) THEN NULL
								ELSE CAST((prhsm_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
									CAST((prhsm_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
									CAST((prhsm_user_rev_dt % 100) AS VARCHAR)
								END 
								AS DATETIME)
	FROM
		prhsmmst')

END

GO