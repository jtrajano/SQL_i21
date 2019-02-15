IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PR') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'prtaxmst') = 1
BEGIN
	EXEC ('
	IF OBJECT_ID(''vyuPROriginTaxTable'', ''V'') IS NOT NULL 
	DROP VIEW vyuPROriginTaxTable')

	EXEC('
	CREATE VIEW [dbo].[vyuPROriginTaxTable]
	AS
	SELECT
		intYear					= CAST(prtax_year AS INT)
		,strType				= CAST(prtax_tax_type AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strTaxCode				= CAST(prtax_code AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strDescription			= CAST(prtax_desc AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strCheckLiteral		= CAST(prtax_literal AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblExemptionAllowance	= CAST(prtax_exmpt_allow AS NUMERIC(18, 6))
		,dblDeductionAllowance	= CAST(prtax_ded_allow AS NUMERIC(18, 6))
		,dblExemptionReduce		= CAST(prtax_exmpt_reduce AS NUMERIC(18, 6))
		,ysnTaxSick				= CAST(CASE prtax_tax_sick WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,strPaidBy				= CAST(CASE prtax_paid_by WHEN ''C'' THEN ''Company'' ELSE ''Employee'' END AS NVARCHAR(200))
		,strCompMethod			= CAST(prtax_comp_method_pt AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,ysnCredit				= CAST(CASE prtax_credit_yn WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,strGLLiability			= CAST(prtax_gl_bs AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,strGLExpense			= CAST(prtax_gl_exp AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblTaxPercent			= CAST(prtax_percent AS NUMERIC(18, 6))			
		,dblWageCutOff			= CAST(prtax_wage_cutoff AS NUMERIC(18, 6))
		,dblWithholdCutOff		= CAST(prtax_whld_cutoff AS NUMERIC(18, 6))
		,dblWageBasis			= CAST(prtax_wage_basis AS NUMERIC(18, 6))
		,dblSuppPercent			= CAST(prtax_supp_pct AS NUMERIC(18, 6))
		,dblTaxTableMax1		= CAST(prtax_tbl_max_1 AS NUMERIC(18, 6))
		,dblTaxTableMax2		= CAST(prtax_tbl_max_2 AS NUMERIC(18, 6))
		,dblTaxTableMax3		= CAST(prtax_tbl_max_3 AS NUMERIC(18, 6))
		,dblTaxTableMax4		= CAST(prtax_tbl_max_4 AS NUMERIC(18, 6))
		,dblTaxTableMax5		= CAST(prtax_tbl_max_5 AS NUMERIC(18, 6))
		,dblTaxTableMax6		= CAST(prtax_tbl_max_6 AS NUMERIC(18, 6))
		,dblTaxTableMax7		= CAST(prtax_tbl_max_7 AS NUMERIC(18, 6))
		,dblTaxTableMax8		= CAST(prtax_tbl_max_8 AS NUMERIC(18, 6))
		,dblTaxTableMax9		= CAST(prtax_tbl_max_9 AS NUMERIC(18, 6))
		,dblTaxTableMax10		= CAST(prtax_tbl_max_10 AS NUMERIC(18, 6))
		,dblTaxTableMax11		= CAST(prtax_tbl_max_11 AS NUMERIC(18, 6))
		,dblTaxTableMax12		= CAST(prtax_tbl_max_12 AS NUMERIC(18, 6))
		,dblTaxTableMax13		= CAST(prtax_tbl_max_13 AS NUMERIC(18, 6))
		,dblTaxTableMax14		= CAST(prtax_tbl_max_14 AS NUMERIC(18, 6))
		,dblTaxTableMax15		= CAST(prtax_tbl_max_15 AS NUMERIC(18, 6))
		,dblTaxTableMax16		= CAST(prtax_tbl_max_16 AS NUMERIC(18, 6))
		,dblTaxTableWhld1		= CAST(prtax_tbl_whld_1 AS NUMERIC(18, 6))
		,dblTaxTableWhld2		= CAST(prtax_tbl_whld_2 AS NUMERIC(18, 6))
		,dblTaxTableWhld3		= CAST(prtax_tbl_whld_3 AS NUMERIC(18, 6))
		,dblTaxTableWhld4		= CAST(prtax_tbl_whld_4 AS NUMERIC(18, 6))
		,dblTaxTableWhld5		= CAST(prtax_tbl_whld_5 AS NUMERIC(18, 6))
		,dblTaxTableWhld6		= CAST(prtax_tbl_whld_6 AS NUMERIC(18, 6))
		,dblTaxTableWhld7		= CAST(prtax_tbl_whld_7 AS NUMERIC(18, 6))
		,dblTaxTableWhld8		= CAST(prtax_tbl_whld_8 AS NUMERIC(18, 6))
		,dblTaxTableWhld9		= CAST(prtax_tbl_whld_9 AS NUMERIC(18, 6))
		,dblTaxTableWhld10		= CAST(prtax_tbl_whld_10 AS NUMERIC(18, 6))
		,dblTaxTableWhld11		= CAST(prtax_tbl_whld_11 AS NUMERIC(18, 6))
		,dblTaxTableWhld12		= CAST(prtax_tbl_whld_12 AS NUMERIC(18, 6))
		,dblTaxTableWhld13		= CAST(prtax_tbl_whld_13 AS NUMERIC(18, 6))
		,dblTaxTableWhld14		= CAST(prtax_tbl_whld_14 AS NUMERIC(18, 6))
		,dblTaxTableWhld15		= CAST(prtax_tbl_whld_15 AS NUMERIC(18, 6))
		,dblTaxTableWhld16		= CAST(prtax_tbl_whld_16 AS NUMERIC(18, 6))
		,dblTaxTablePct1		= CAST(prtax_tbl_pct_1 AS NUMERIC(18, 6))
		,dblTaxTablePct2		= CAST(prtax_tbl_pct_2 AS NUMERIC(18, 6))
		,dblTaxTablePct3		= CAST(prtax_tbl_pct_3 AS NUMERIC(18, 6))
		,dblTaxTablePct4		= CAST(prtax_tbl_pct_4 AS NUMERIC(18, 6))
		,dblTaxTablePct5		= CAST(prtax_tbl_pct_5 AS NUMERIC(18, 6))
		,dblTaxTablePct6		= CAST(prtax_tbl_pct_6 AS NUMERIC(18, 6))
		,dblTaxTablePct7		= CAST(prtax_tbl_pct_7 AS NUMERIC(18, 6))
		,dblTaxTablePct8		= CAST(prtax_tbl_pct_8 AS NUMERIC(18, 6))
		,dblTaxTablePct9		= CAST(prtax_tbl_pct_9 AS NUMERIC(18, 6))
		,dblTaxTablePct10		= CAST(prtax_tbl_pct_10 AS NUMERIC(18, 6))
		,dblTaxTablePct11		= CAST(prtax_tbl_pct_11 AS NUMERIC(18, 6))
		,dblTaxTablePct12		= CAST(prtax_tbl_pct_12 AS NUMERIC(18, 6))
		,dblTaxTablePct13		= CAST(prtax_tbl_pct_13 AS NUMERIC(18, 6))
		,dblTaxTablePct14		= CAST(prtax_tbl_pct_14 AS NUMERIC(18, 6))
		,dblTaxTablePct15		= CAST(prtax_tbl_pct_15 AS NUMERIC(18, 6))
		,dblTaxTablePct16		= CAST(prtax_tbl_pct_16 AS NUMERIC(18, 6))
		,intMagMediaId			= CAST(prtax_mag_media_id AS INT)
		,ysnAPTransaction		= CAST(CASE prtax_aptrx_yn WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,strVendor				= CAST(prtax_vendor AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dblStdDeductionMin		= CAST(prtax_std_ded_min AS NUMERIC(18, 6))
		,dblStdDeductionMax		= CAST(prtax_std_ded_max AS NUMERIC(18, 6))
		,dblFwtDeduct			= CAST(prtax_fwt_deduct_9 AS NUMERIC(18, 6))
		,dblFwtAllowMax			= CAST(prtax_fwt_allow_max AS NUMERIC(18, 6))
		,dblTaxableMin			= CAST(prtax_min_taxable_wage AS NUMERIC(18, 6))
		,dblPctOfFwt			= CAST(prtax_pct_of_fwt AS NUMERIC(18, 6))
		,dblStatePercent		= CAST(prtax_state_pct AS NUMERIC(18, 6))
		,ysnRndStateWh			= CAST(CASE prtax_rnd_state_wh_yn WHEN ''Y'' THEN 1 ELSE 0 END AS BIT)
		,dblMedSuppMin			= CAST(prtax_med_supp_min AS NUMERIC(18, 6))	
		,strUserId				= CAST(prtax_user_id AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
		,dtmUserRevision		= CAST(CASE WHEN (ISNULL(prtax_user_rev_dt, 0) = 0) THEN NULL
									ELSE CAST((prtax_user_rev_dt / 10000) AS VARCHAR) + ''-'' + 
										CAST((prtax_user_rev_dt % 10000) / 100 AS VARCHAR) + ''-'' + 
										CAST((prtax_user_rev_dt % 100) AS VARCHAR)
									END 
									AS DATETIME)
		,intIdentityKey		= ISNULL(CAST(A4GLIdentity AS INT), -999)
	FROM
		prtaxmst')

END

GO