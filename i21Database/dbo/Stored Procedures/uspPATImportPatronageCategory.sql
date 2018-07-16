CREATE PROCEDURE [dbo].[uspPATImportPatronageCategory]
	@checking BIT = 0,
	@total INT = 0 OUTPUT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @patronageTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[strCategoryCode] NVARCHAR(50),
		[strDescription] NVARCHAR(50), 
		[strPurchaseSale] NVARCHAR(50),
		[strUnitAmount] NVARCHAR(50)
	);
	DECLARE @saleTxt NVARCHAR(50);
	DECLARE @purchaseTxt NVARCHAR(50);
	DECLARE @amountTxt NVARCHAR(50);
	DECLARE @unitTxt NVARCHAR(50);

	SELECT @saleTxt = 'Sale', @purchaseTxt = 'Purchase', @amountTxt = 'Amount', @unitTxt = 'Unit';
	
	---------------------- BEGIN - INSERT ORIGIN DATA TO TEMPORARY TABLE -----------------------
	INSERT INTO @patronageTable (strCategoryCode, strDescription, strPurchaseSale, strUnitAmount)
	SELECT pact2_cat_code_1 AS [strCategoryCode], pact2_cat_lit_1 AS [strDescription], 
			(CASE UPPER(pact2_cat_ps_1) WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
			(CASE UPPER(pact2_cat_ua_1) WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_1 is not NULL
	UNION
	SELECT pact2_cat_code_2 AS [strCategoryCode], pact2_cat_lit_2 AS [strDescription], 
		(CASE UPPER(pact2_cat_ps_2)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_2)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_2 is not NULL
	UNION
	SELECT pact2_cat_code_3 AS [strCategoryCode], pact2_cat_lit_3 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_3)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_3)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_3 is not NULL
	UNION
	SELECT pact2_cat_code_4 AS [strCategoryCode], pact2_cat_lit_4 AS [strDescription], 
		(CASE UPPER(pact2_cat_ps_4)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_4)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_4 is not NULL
	UNION
	SELECT pact2_cat_code_5 AS [strCategoryCode], pact2_cat_lit_5 AS [strDescription], 
		(CASE UPPER(pact2_cat_ps_5)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_5)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_5 is not NULL
	UNION
	SELECT pact2_cat_code_6 AS [strCategoryCode], pact2_cat_lit_6 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_6)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_6)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_6 is not NULL
	UNION
	SELECT pact2_cat_code_7 AS [strCategoryCode], pact2_cat_lit_7 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_7)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_7)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_7 is not NULL
	UNION
	SELECT pact2_cat_code_8 AS [strCategoryCode], pact2_cat_lit_8 AS [strDescription], 
		(CASE UPPER(pact2_cat_ps_8)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_8)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_8 is not NULL
	UNION
	SELECT pact2_cat_code_9 AS [strCategoryCode], pact2_cat_lit_9 AS [strDescription], 
		(CASE UPPER(pact2_cat_ps_9)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_9)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_9 is not NULL
	UNION
	SELECT pact2_cat_code_10 AS [strCategoryCode], pact2_cat_lit_10 AS [strDescription], 
		(CASE UPPER(pact2_cat_ps_10)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale], 
		(CASE UPPER(pact2_cat_ua_10)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount] 
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_10 is not NULL
	UNION
	SELECT pact2_cat_code_11 AS [strCategoryCode], pact2_cat_lit_11 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_11)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_11)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_11 is not NULL
	UNION
	SELECT pact2_cat_code_12 AS [strCategoryCode], pact2_cat_lit_12 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_12)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_12)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_12 is not NULL
	UNION
	SELECT pact2_cat_code_13 AS [strCategoryCode], pact2_cat_lit_13 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_13)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_13)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_13 is not NULL
	UNION
	SELECT pact2_cat_code_14 AS [strCategoryCode], pact2_cat_lit_14 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_14)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_14)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_14 is not NULL
	UNION
	SELECT pact2_cat_code_15 AS [strCategoryCode], pact2_cat_lit_15 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_15)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_15)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_15 is not NULL
	UNION
	SELECT pact2_cat_code_16 AS [strCategoryCode], pact2_cat_lit_16 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_16)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_16) WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_16 is not NULL
	UNION
	SELECT pact2_cat_code_17 AS [strCategoryCode], pact2_cat_lit_17 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_17)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_17)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_17 is not NULL
	UNION
	SELECT pact2_cat_code_18 AS [strCategoryCode], pact2_cat_lit_18 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_18)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_18)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_18 is not NULL
	UNION
	SELECT pact2_cat_code_19 AS [strCategoryCode], pact2_cat_lit_19 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_19)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_19)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_19 is not NULL
	UNION
	SELECT pact2_cat_code_20 AS [strCategoryCode], pact2_cat_lit_20 AS [strDescription],
		(CASE UPPER(pact2_cat_ps_20)  WHEN 'S' THEN @saleTxt WHEN 'P' THEN @purchaseTxt END) AS [strPurchaseSale],
		(CASE UPPER(pact2_cat_ua_20)  WHEN 'A' THEN @amountTxt WHEN 'U' THEN @unitTxt END) AS [strUnitAmount]
	FROM pactlmst WHERE pactl_key ='02' and pact2_cat_code_20 is not NULL
	---------------------- END - INSERT ORIGIN DATA TO TEMPORARY TABLE -----------------------


	
	---------------------------- BEGIN - COUNT ORIGIN DATA TO BE IMPORTED -----------------------
	IF(@checking = 1)
	BEGIN
		SELECT @total = COUNT(*) FROM @patronageTable tempPC
		LEFT OUTER JOIN tblPATPatronageCategory PC
			ON tempPC.strCategoryCode COLLATE Latin1_General_CI_AS = PC.strCategoryCode
		WHERE tempPC.strCategoryCode COLLATE Latin1_General_CI_AS NOT IN (SELECT strCategoryCode FROM tblPATPatronageCategory)
		
		RETURN @total;
	END
	---------------------------- END - COUNT ORIGIN DATA TO BE IMPORTED -----------------------


	---------------------------- BEGIN - INSERT ORIGIN DATA -----------------------
	INSERT INTO tblPATPatronageCategory(strCategoryCode, strDescription, strPurchaseSale, strUnitAmount, intConcurrencyId)
	SELECT tempPC.strCategoryCode, tempPC.strDescription, tempPC.strPurchaseSale, tempPC.strUnitAmount, 1
	FROM @patronageTable tempPC
	LEFT OUTER JOIN tblPATPatronageCategory PC
		ON tempPC.strCategoryCode COLLATE Latin1_General_CI_AS = PC.strCategoryCode
	WHERE tempPC.strCategoryCode COLLATE Latin1_General_CI_AS NOT IN (SELECT strCategoryCode FROM tblPATPatronageCategory)
	---------------------------- END - INSERT ORIGIN DATA -----------------------

END