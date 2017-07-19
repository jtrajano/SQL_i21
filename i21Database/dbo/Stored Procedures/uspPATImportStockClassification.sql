CREATE PROCEDURE [dbo].[uspPATImportStockClassification]
	@checking BIT = 0,
	@total INT = 0 OUTPUT
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @stockClassificationTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[strStockName] NVARCHAR(100),
		[dblParValue] NUMERIC(18, 6), 
		[dblDividendsPerShare] NUMERIC(18, 6),
		[intDividendsGLAccount] INT
	) 

	------------------- BEGIN - INSERT INTO TEMPORARY TABLE ----------------------------
	INSERT INTO @stockClassificationTable(strStockName, dblParValue, dblDividendsPerShare, intDividendsGLAccount)
	SELECT	PDEC.pactl_stock_desc_1 AS [strStockName], 
			PPAR.pactl_stock_par_value_1 AS [dblParValue], 
			PSTOCKDIV.pactl_stock_div_1 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC
	CROSS JOIN (SELECT pactl_stock_par_value_1 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_1 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_1 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR (PGLDIV.pact3_gl_div_1) AND GLAC.glact_acct9_16 = RIGHT (PGLDIV.pact3_gl_div_1, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_2 AS [strStockName],
			PPAR.pactl_stock_par_value_2 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_2 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_2 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_2 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_2 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_2) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_2, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_3 AS [strStockName],
			PPAR.pactl_stock_par_value_3 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_3 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_3 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_3 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_3 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_3) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_3, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_4 AS [strStockName],
			PPAR.pactl_stock_par_value_4 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_4 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_4 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_4 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_4 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_4) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_4, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_5 AS [strStockName],
			PPAR.pactl_stock_par_value_5 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_5 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_5 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_5 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_5 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_5) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_5, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_6 AS [strStockName],
			PPAR.pactl_stock_par_value_6 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_6 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_6 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_6 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_6 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_6) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_6, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_7 AS [strStockName],
			PPAR.pactl_stock_par_value_7 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_7 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_7 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_7 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_7 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_7) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_7, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_8 AS [strStockName],
			PPAR.pactl_stock_par_value_8 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_8 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_8 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_8 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_8 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_8) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_8, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_9 AS [strStockName],
			PPAR.pactl_stock_par_value_9 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_9 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_9 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_9 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_9 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_9) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_9, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	UNION
	SELECT	PDEC.pactl_stock_desc_10 AS [strStockName],
			PPAR.pactl_stock_par_value_10 AS [dblParValue],
			PSTOCKDIV.pactl_stock_div_10 AS [dblDividendsPerShare],
			CASE WHEN GL.intAccountId IS NULL THEN CP.intDividendsGLAccount ELSE GL.intAccountId END AS [intDividendsGLAccount]
	FROM pactlmst PDEC 
	CROSS JOIN (SELECT pactl_stock_par_value_10 FROM pactlmst WHERE pactl_key ='01') PPAR
	CROSS JOIN (SELECT pactl_stock_div_10 FROM pactlmst WHERE pactl_key ='01') PSTOCKDIV
	CROSS JOIN (SELECT pact3_gl_div_10 FROM pactlmst WHERE pactl_key ='03') PGLDIV
	LEFT OUTER JOIN (SELECT RTRIM(glact_desc) AS strDescription, glact_acct1_8, glact_acct9_16 FROM glactmst) GLAC
		ON GLAC.glact_acct1_8 = FLOOR(PGLDIV.pact3_gl_div_10) AND GLAC.glact_acct9_16 = RIGHT(PGLDIV.pact3_gl_div_10, 8)
	OUTER APPLY (
		SELECT TOP 1 intAccountId
		FROM tblGLAccount GL
		WHERE GL.strDescription LIKE '%' + GLAC.strDescription COLLATE Latin1_General_CI_AS + '%'
	) GL
	CROSS JOIN tblPATCompanyPreference CP
	WHERE PDEC.pactl_key ='01'
	------------------- END - INSERT INTO TEMPORARY TABLE ----------------------------



	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	IF(@checking = 1)
	BEGIN
		SELECT @total = COUNT(*) FROM @stockClassificationTable tempSC
		LEFT OUTER JOIN tblPATStockClassification SC
			ON tempSC.strStockName COLLATE Latin1_General_CI_AS = SC.strStockName
		WHERE tempSC.strStockName COLLATE Latin1_General_CI_AS NOT IN (SELECT strStockName FROM tblPATStockClassification) AND tempSC.strStockName IS NOT NULL

		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------


	---------------------------- BEGIN - INSERT ORIGIN DATA -----------------------
	INSERT INTO tblPATStockClassification(strStockName, strStockDescription, dblParValue, intDividendsGLAccount, dblDividendsPerShare, intSort, intConcurrencyId)
	SELECT tempSC.strStockName, tempSC.strStockName, tempSC.dblParValue, tempSC.intDividendsGLAccount, tempSC.dblDividendsPerShare, 0, 1
	FROM @stockClassificationTable tempSC
	LEFT OUTER JOIN tblPATStockClassification SC
		ON tempSC.strStockName COLLATE Latin1_General_CI_AS = SC.strStockName
	WHERE tempSC.strStockName COLLATE Latin1_General_CI_AS NOT IN (SELECT strStockName FROM tblPATStockClassification) AND tempSC.strStockName IS NOT NULL AND tempSC.intDividendsGLAccount IS NOT NULL
	---------------------------- END - INSERT ORIGIN DATA -----------------------
END