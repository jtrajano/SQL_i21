CREATE PROCEDURE [dbo].[uspPATImportVolumeDetails]
	@checking BIT = 0,
	@isImported BIT = 0 OUTPUT,
	@isDisabled BIT = 0 OUTPUT,
	@total INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT @isImported = ysnIsImported FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 7;

IF(@isImported = 0)
BEGIN

	IF EXISTS(SELECT 1 FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 1 AND ysnIsImported = 0)
	BEGIN
		SET @isDisabled = 1;
		RETURN @isDisabled;
	END

	DECLARE @EntityType_Customer AS NVARCHAR(50) = 'Customer' COLLATE Latin1_General_CI_AS;

	CREATE TABLE #customerVolumeOriginStaging(
		[intTempId]					INT IDENTITY PRIMARY KEY,
		[strCustomerNo]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
		[dtmLastActivityDate]		DATETIME NULL,
		[strFiscalYear]				NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL, 
		[intPatronageCategoryId]	INT NULL,
		[dblVolume]					NUMERIC(18,6) NOT NULL
	)

	CREATE TABLE #customerVolumei21Staging(
		[intTempId]					INT IDENTITY PRIMARY KEY,
		[intEntityId]		INT NULL,
		[strCustomerNo]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
		[dtmLastActivityDate]		DATETIME NULL,
		[intFiscalYearId]			INT NULL,
		[strFiscalYear]				NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL, 
		[intPatronageCategoryId]	INT NULL,
		[dblVolume]					NUMERIC(18,6)
	)


	----------------------- BEGIN - INITIALIZE FISCAL YEAR -----------------------------
	DECLARE @currentDate INT,
			@fiscalYear INT,
			@nextFiscalYear INT;

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
	SET @nextFiscalYear = @fiscalYear + 1;
	----------------------- END - INITIALIZE FISCAL YEAR -----------------------------

	----------------------- BEGIN - INSERT INTO CUSTOMER VOLUME ORIGIN STAGING -----------------------------
	INSERT INTO #customerVolumeOriginStaging(strCustomerNo, dtmLastActivityDate, strFiscalYear, intPatronageCategoryId, dblVolume)
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_1
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_1 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_1 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_1 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_2
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_2 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_2 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_2 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_3
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_3 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_3 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_3 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS,
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_4
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_4 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_4 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_4 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_5
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_5 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_5 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_5 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS,
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_6
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_6 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_6 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_6 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_7
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_7 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_7 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_7 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_8
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_8 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_8 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_8 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_9
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_9 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_9 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_9 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_10
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_10 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_10 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_10 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_11
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_11 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_11 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_11 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_12
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_12 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_12 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_12 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_13
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_13 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_13 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_13 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_14
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_14 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_14 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_14 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_15
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_15 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_15 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_15 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_16
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_16 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_16 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_16 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_17
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_17 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_17 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_17 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_18
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_18 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_18 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_18 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_19
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_19 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_19 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_19 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@fiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_ytd_vol_amt_20
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_20 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_20 is not NULL
	) PC
	WHERE PACV.pacus_ytd_vol_amt_20 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_1
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_1 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_1 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_1 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_2
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_2 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_2 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_2 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_3
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_3 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_3 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_3 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_4
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_4 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_4 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_4 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_5
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_5 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_5 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_5 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS,
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate, 
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_6
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_6 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_6 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_6 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS,
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate, 
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_7
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_7 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_7 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_7 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_8
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_8 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_8 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_8 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_9
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_9 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_9 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_9 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_10
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_10 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_10 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_10 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_11
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_11 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_11 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_11 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_12
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_12 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_12 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_12 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_13
	FROM pacusmst PACV 
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_13 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_13 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_13 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_14
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_14 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_14 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_14 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_15
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_15 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_15 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_15 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_16
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_16 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_16 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_16 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_17
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_17 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_17 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_17 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_18
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_18 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_18 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_18 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_19
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_19 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_19 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_19 > 0
	UNION
	SELECT	strCustomerNo = RTRIM(PACV.pacus_no) COLLATE Latin1_General_CI_AS, 
			(CASE WHEN PACV.pacus_last_activ_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PACV.pacus_last_activ_rev_dt AS CHAR (12)), 112)) ELSE NULL END) AS dtmLastActivityDate,
			@nextFiscalYear,
			PC.intPatronageCategoryId,
			PACV.pacus_nyr_vol_amt_20
	FROM pacusmst PACV
	CROSS APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_20 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_20 is not NULL
	) PC
	WHERE PACV.pacus_nyr_vol_amt_20 > 0
	----------------------- END - INSERT INTO CUSTOMER VOLUME ORIGIN STAGING -----------------------------

	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	SELECT @total = COUNT(*) FROM #customerVolumeOriginStaging tempCV
	IF(@checking = 1)
	BEGIN
		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------

	----------------------- BEGIN - INSERT INTO CUSTOMER VOLUME i21 STAGING -----------------------------
	INSERT INTO #customerVolumei21Staging(intEntityId, strCustomerNo, dtmLastActivityDate, intFiscalYearId, strFiscalYear, intPatronageCategoryId, dblVolume)
	SELECT	CustomerEntity.intEntityId,
			originStaging.strCustomerNo,
			originStaging.dtmLastActivityDate,
			FiscalYear.intFiscalYearId,
			originStaging.strFiscalYear,
			originStaging.intPatronageCategoryId,
			originStaging.dblVolume
	FROM #customerVolumeOriginStaging originStaging
	LEFT JOIN vyuEMEntity CustomerEntity
		ON CustomerEntity.strEntityNo = originStaging.strCustomerNo AND CustomerEntity.strType = @EntityType_Customer  
	LEFT JOIN tblGLFiscalYear FiscalYear
		ON FiscalYear.strFiscalYear = originStaging.strFiscalYear
	----------------------- END - INSERT INTO CUSTOMER VOLUME i21 STAGING -----------------------------

	------------------- BEGIN - INSERT ORIGIN ROWS INTO CUSTOMER VOLUME TABLE ----------------------------
	MERGE
	INTO	dbo.tblPATCustomerVolume
	WITH	(HOLDLOCK)
	AS		CustomerVolume
	USING (SELECT * FROM #customerVolumei21Staging WHERE intEntityId IS NOT NULL) CustomerVolumeStaging
		ON CustomerVolumeStaging.intEntityId = CustomerVolume.intCustomerPatronId
		AND CustomerVolumeStaging.intFiscalYearId = CustomerVolume.intFiscalYear
		AND CustomerVolumeStaging.intPatronageCategoryId = CustomerVolume.intPatronageCategoryId
		AND CustomerVolume.ysnRefundProcessed <> 0
	WHEN MATCHED THEN
		UPDATE SET
			CustomerVolume.dblVolume = CustomerVolume.dblVolume + CustomerVolumeStaging.dblVolume
	WHEN NOT MATCHED THEN
		INSERT (
			intCustomerPatronId,
			intPatronageCategoryId,
			intFiscalYear,
			dblVolume
		)
		VALUES(
			CustomerVolumeStaging.intEntityId,
			CustomerVolumeStaging.intPatronageCategoryId,
			CustomerVolumeStaging.intFiscalYearId,
			CustomerVolumeStaging.dblVolume
		)
	;
	--------------------- END - INSERT ORIGIN ROWS INTO CUSTOMER VOLUME TABLE ----------------------------


	--------------------- BEGIN - UPDATE LAST ACTIVITY DATE ----------------------------
	UPDATE ARC
	SET ARC.dtmLastActivityDate = CASE WHEN ISNULL(tempCV.dtmLastActivityDate, '') = '' OR ARC.dtmLastActivityDate < tempCV.dtmLastActivityDate THEN tempCV.dtmLastActivityDate ELSE ARC.dtmLastActivityDate END
	FROM tblARCustomer AS ARC
	INNER JOIN #customerVolumei21Staging tempCV
		ON tempCV.intEntityId = ARC.[intEntityId]
	--------------------- END - UPDATE LAST ACTIVITY DATE ----------------------------

	

	------------------- BEGIN - UPDATE ORIGIN FLAGGING TABLE ----------------------------
	UPDATE tblPATImportOriginFlag
	SET ysnIsImported = 1, intImportCount = @total
	WHERE intImportOriginLogId = 7

	SET @isImported = CAST(1 AS BIT);
	------------------- END - UPDATE ORIGIN FLAGGING TABLE ----------------------------

END
END