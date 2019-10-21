CREATE PROCEDURE [dbo].[uspPATImportRefundRate]
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

SELECT @isImported = ysnIsImported FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 4;

IF(@isImported = 0)
BEGIN

	IF EXISTS(SELECT 1 FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 1 AND ysnIsImported = 0)
	BEGIN
		SET @isDisabled = 1;
		RETURN @isDisabled;
	END
	
	DECLARE @refundRateTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[strRefundType] CHAR(5),
		[strRefundDescription] NVARCHAR(MAX),
		[ysnQualified] BIT,
		[intGeneralReserveId] INT,
		[intAllocatedReserveId] INT,
		[intUndistributedEquityId] INT,
		[dblCashPayout] NUMERIC(18, 6)
	);

	---------------------------- BEGIN - INSERT INTO REFUND RATE TEMPORARY TABLE -----------------------
	INSERT INTO @refundRateTable(strRefundType, strRefundDescription, ysnQualified, intGeneralReserveId, intAllocatedReserveId, intUndistributedEquityId, dblCashPayout)
	SELECT PARF.parfd_key, PARF.parfd_description, CASE UPPER(PARF.parfd_equity_qual_yn) WHEN 'Y' THEN 1 WHEN 'N' THEN 0 END, GR.intAccountId, AR.intAccountId, UE.intAccountId, PARF.parfd_cash_pct 
	FROM parfdmst PARF
	LEFT OUTER JOIN (SELECT RTRIM([glact_desc]) AS strDescription,glact_acct1_8, glact_acct9_16 FROM glactmst) GRGL
		 ON GRGL.glact_acct1_8 = FLOOR(PARF.parfd_gl_general_reserve) AND GRGL.glact_acct9_16 = RIGHT(PARF.parfd_gl_general_reserve,8)
	OUTER APPLY(
		SELECT TOP 1 GL.intAccountId 
		FROM tblGLAccount GL	
		WHERE GL.strDescription LIKE '%' + GRGL.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GR
	LEFT OUTER JOIN (SELECT RTRIM([glact_desc]) AS strDescription,glact_acct1_8, glact_acct9_16 FROM glactmst) ARGL
		 ON ARGL.glact_acct1_8 = FLOOR(PARF.parfd_gl_alloc_reserve) AND ARGL.glact_acct9_16 = RIGHT(PARF.parfd_gl_alloc_reserve,8)
	OUTER APPLY(
		SELECT TOP 1 GL.intAccountId 
		FROM tblGLAccount GL	
		WHERE GL.strDescription LIKE '%' + ARGL.strDescription COLLATE Latin1_General_CI_AS + '%'
	) AR
	LEFT OUTER JOIN (SELECT RTRIM([glact_desc]) AS strDescription,glact_acct1_8, glact_acct9_16 FROM glactmst) UEGL
		 ON UEGL.glact_acct1_8 = FLOOR(PARF.parfd_gl_undist_rfd) AND UEGL.glact_acct9_16 = RIGHT(PARF.parfd_gl_undist_rfd,8)
	OUTER APPLY(
		SELECT TOP 1 GL.intAccountId 
		FROM tblGLAccount GL	
		WHERE GL.strDescription LIKE '%' + UEGL.strDescription COLLATE Latin1_General_CI_AS + '%'
	) UE
	---------------------------- END - INSERT INTO  REFUND RATE TEMPORARY TABLE -----------------------

	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	SELECT @total = COUNT(*) FROM @refundRateTable tempRR
	LEFT OUTER JOIN tblPATRefundRate RR
		ON tempRR.strRefundType COLLATE Latin1_General_CI_AS = RR.strRefundType
	WHERE tempRR.strRefundType COLLATE Latin1_General_CI_AS NOT IN (SELECT strRefundType FROM tblPATRefundRate) AND tempRR.strRefundType IS NOT NULL

	IF(@checking = 1)
	BEGIN
		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------
	
	---------------------------- BEGIN - INSERT INTO REFUND RATE TABLE -----------------------
	INSERT INTO tblPATRefundRate(strRefundType, strRefundDescription, ysnQualified, intGeneralReserveId, intAllocatedReserveId, intUndistributedEquityId, dblCashPayout, intConcurrencyId)
	SELECT tempRR.strRefundType, tempRR.strRefundDescription, tempRR.ysnQualified, tempRR.intGeneralReserveId, tempRR.intAllocatedReserveId, tempRR.intUndistributedEquityId, tempRR.dblCashPayout, 1
	FROM @refundRateTable tempRR
	LEFT OUTER JOIN tblPATRefundRate RR
		ON tempRR.strRefundType COLLATE Latin1_General_CI_AS = RR.strRefundType
	WHERE tempRR.strRefundType COLLATE Latin1_General_CI_AS NOT IN (SELECT strRefundType FROM tblPATRefundRate) AND tempRR.strRefundType IS NOT NULL
	---------------------------- END - INSERT INTO REFUND RATE TABLE -----------------------


	DECLARE @refundRateDetailTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY, 
		[intRefundTypeId] INT, 
		[intPatronageCategoryId] INT, 
		[strPurchaseSale] NVARCHAR(50),
		[strDescription] NVARCHAR(50),
		[dblRate] NUMERIC(18, 6)
	)

	---------------------------- BEGIN - INSERT INTO REFUND RATE DETAIL TEMPORARY TABLE -----------------------
	INSERT INTO @refundRateDetailTable
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_1 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_1 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_1 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_2 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_2 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_2 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_3 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_3 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_3 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_4 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_4 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_4 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_5 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_5 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_5 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_6 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_6 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_6 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_7 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_7 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_7 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_8 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_8 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_8 is not NULL
	) PC
		UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_9 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_9 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_9 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_10 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_10 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_10 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_11 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_11 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_11 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_12 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_12 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_12 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_13 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_13 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_13 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_14 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_14 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_14 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_15 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_15 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_15 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_16 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_16 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_16 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_17 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_17 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_17 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_18 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_18 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_18 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_19 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_19 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_19 is not NULL
	) PC
	UNION
	SELECT PARF.parfd_key, PC.intPatronageCategoryId, PC.strPurchaseSale, PC.strDescription, PARF.parfd_rate_20 AS dblRate
	FROM parfdmst PARF
	OUTER APPLY(
		SELECT PC.intPatronageCategoryId, PC.strCategoryCode, PC.strDescription, PC.strPurchaseSale, PC.strUnitAmount
		FROM pactlmst PACT
		INNER JOIN tblPATPatronageCategory PC
			ON PACT.pact2_cat_code_20 COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE PACT.pactl_key ='02' and PACT.pact2_cat_code_20 is not NULL
	) PC
	---------------------------- END - INSERT INTO  REFUND RATE DETAIL TEMPORARY TABLE -----------------------


	
	---------------------------- BEGIN - INSERT INTO REFUND RATE DETAIL TABLE -----------------------
	INSERT INTO tblPATRefundRateDetail(intRefundTypeId, intPatronageCategoryId, strPurchaseSale, strDescription, dblRate, intConcurrencyId)
	SELECT RR.intRefundTypeId, tempRRD.intPatronageCategoryId, tempRRD.strPurchaseSale, tempRRD.strDescription, tempRRD.dblRate, 1
	FROM @refundRateDetailTable tempRRD
	INNER JOIN tblPATRefundRate RR
		ON RR.strRefundType = CONVERT(CHAR(5), tempRRD.intRefundTypeId)
	WHERE tempRRD.intPatronageCategoryId IS NOT NULL
	---------------------------- END - INSERT INTO REFUND RATE DETAIL TABLE -----------------------

	
	UPDATE tblPATImportOriginFlag
	SET ysnIsImported = 1, intImportCount = @total
	WHERE intImportOriginLogId = 4

	SET @isImported = CAST(1 AS BIT);
END
END