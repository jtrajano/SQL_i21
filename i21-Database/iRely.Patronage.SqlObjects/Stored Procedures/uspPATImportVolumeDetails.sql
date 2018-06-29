CREATE PROCEDURE [dbo].[uspPATImportVolumeDetails]
	@checking BIT = 0,
	@total INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


	DECLARE @customerVolumeTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[intCustomerPatronId] INT,
		[dtmLastActivityDate] DATETIME,
		[intFiscalYearId] INT,
		[intPatronageCategoryId] INT,
		[dblVolume] NUMERIC(18,6)
	)


	----------------------- BEGIN - INITIALIZE FISCAL YEAR -----------------------------
	DECLARE @currentDate INT,
			@fiscalYear INT,
			@fiscalYearId INT,
			@nextFiscalYear INT,
			@nextFiscalYearId INT;

	SET @currentDate = (SELECT CAST(CONVERT(varchar(8), GETDATE(),112)as int));
	SET @fiscalYear =	(SELECT glfyp_yr FROM glfypmst WHERE (glfyp_beg_date_1 <= @currentDate and glfyp_end_date_1 >= @currentDate) or 
						(glfyp_beg_date_2 <= @currentDate and glfyp_end_date_2 >= @currentDate) or 
						(glfyp_beg_date_3 <= @currentDate and glfyp_end_date_3 >= @currentDate) or 
						(glfyp_beg_date_4 <= @currentDate and glfyp_end_date_4 >= @currentDate) or 
						(glfyp_beg_date_5 <= @currentDate and glfyp_end_date_5 >= @currentDate) or 
						(glfyp_beg_date_6 <= @currentDate and glfyp_end_date_6 >= @currentDate) or 
						(glfyp_beg_date_7 <= @currentDate and glfyp_end_date_7 >= @currentDate) or 
						(glfyp_beg_date_8 <= @currentDate and glfyp_end_date_8 >= @currentDate) or 
						(glfyp_beg_date_9 <= @currentDate and glfyp_end_date_9 >= @currentDate) or 
						(glfyp_beg_date_10 <= @currentDate and glfyp_end_date_10 >= @currentDate) or 
						(glfyp_beg_date_11 <= @currentDate and glfyp_end_date_11 >= @currentDate) or 
						(glfyp_beg_date_12 <= @currentDate and glfyp_end_date_12 >= @currentDate));
	SET @fiscalYearId = (SELECT intFiscalYearId FROM tblGLFiscalYear WHERE strFiscalYear = @fiscalYear);
	SET @nextFiscalYear = @fiscalYear + 1;
	SET @nextFiscalYearId = (SELECT intFiscalYearId FROM tblGLFiscalYear WHERE strFiscalYear = @nextFiscalYear);
	----------------------- END - INITIALIZE FISCAL YEAR -----------------------------

	----------------------- BEGIN - INSERT INTO CUSTOMER VOLUME TEMPORARY TABLE -----------------------------
	INSERT INTO @customerVolumeTable(intCustomerPatronId, dtmLastActivityDate, intFiscalYearId, intPatronageCategoryId, dblVolume)
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_1
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_1 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_1 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_2
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_2 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_2 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_3
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_3 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_3 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_4
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_4 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_4 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_5
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_5 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_5 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_6
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_6 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_6 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_7
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_7 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_7 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_8
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_8 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_8 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_9
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_9 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_9 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_10
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_10 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_10 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_11
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_11 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_11 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_12
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_12 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_12 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_13
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_13 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_13 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_14
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_14 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_14 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_15
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_15 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_15 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_16
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_16 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_16 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_17
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_17 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_17 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_18
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_18 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_18 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_19
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_19 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_19 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_20
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_20 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_20 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_1
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_1 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_1 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_2
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_2 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_2 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_3
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_3 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_3 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_4
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_4 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_4 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_5
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_5 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_5 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId,
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate, 
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_6
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_6 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_6 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId,
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate, 
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_7
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_7 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_7 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_8
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_8 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_8 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_9
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_9 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_9 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_10
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_10 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_10 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_11
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_11 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_11 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_12
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_12 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_12 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_13
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_13 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_13 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_14
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_14 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_14 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_15
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_15 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_15 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_16
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_16 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_16 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_17
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_17 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_17 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_18
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_18 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_18 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_19
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_19 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_19 is not NULL
	) PC
	UNION
	SELECT	EM.intEntityId, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYearId,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_20
	FROM pacusmst PACV
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor') 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_20 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_20 is not NULL
	) PC
	----------------------- END - INSERT INTO CUSTOMER VOLUME TEMPORARY TABLE -----------------------------

	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	IF(@checking = 1)
	BEGIN
		SELECT @total = COUNT(*) FROM @customerVolumeTable tempCV
		LEFT OUTER JOIN tblPATCustomerVolume CV
			ON CV.intCustomerPatronId = tempCV.intCustomerPatronId AND CV.intFiscalYear = tempCV.intFiscalYearId AND CV.intPatronageCategoryId = tempCV.intPatronageCategoryId
		WHERE tempCV.dblVolume <> 0 AND CV.intCustomerVolumeId IS NULL
		
		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------


	------------------- BEGIN - INSERT ORIGIN ROWS INTO CUSTOMER VOLUME TABLE ----------------------------
	INSERT INTO tblPATCustomerVolume(intCustomerPatronId, intFiscalYear, intPatronageCategoryId, dblVolume, intConcurrencyId)
	SELECT tempCV.intCustomerPatronId, tempCV.intFiscalYearId, tempCV.intPatronageCategoryId, tempCV.dblVolume, 1
	FROM @customerVolumeTable tempCV
	LEFT OUTER JOIN tblPATCustomerVolume CV
		ON CV.intCustomerPatronId = tempCV.intCustomerPatronId AND CV.intFiscalYear = tempCV.intFiscalYearId AND CV.intPatronageCategoryId = tempCV.intPatronageCategoryId
	WHERE tempCV.dblVolume <> 0 AND CV.intCustomerVolumeId IS NULL
	------------------- END - INSERT ORIGIN ROWS INTO CUSTOMER VOLUME TABLE ----------------------------


	------------------- BEGIN - UPDATE LAST ACTIVITY DATE ----------------------------
	UPDATE ARC
	SET ARC.dtmLastActivityDate = CASE WHEN ISNULL(tempCV.dtmLastActivityDate, '') = '' OR ARC.dtmLastActivityDate < tempCV.dtmLastActivityDate THEN tempCV.dtmLastActivityDate ELSE ARC.dtmLastActivityDate END
	FROM tblARCustomer AS ARC
	INNER JOIN @customerVolumeTable tempCV
		ON tempCV.intCustomerPatronId = ARC.[intEntityId]
	------------------- END - UPDATE LAST ACTIVITY DATE ----------------------------
END