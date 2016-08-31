﻿CREATE PROCEDURE [dbo].[uspAPValidateVoucherImport]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@logKey NVARCHAR(100) OUTPUT,
	@isValid BIT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()
SET @logKey = @key;

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

IF(NOT EXISTS(SELECT 1 FROM tblSMUserSecurity A WHERE A.intEntityUserSecurityId = @UserId))
BEGIN
	INSERT INTO @log
	SELECT 'Invalid user provided.'
END

--MAKE SURE USER HAS DEFAULT LOCATION
DECLARE @userLocation INT;
SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
		INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intEntityUserSecurityId = @UserId

IF(@userLocation IS NULL OR @userLocation <= 0)
BEGIN
	INSERT INTO @log
	SELECT 'Please setup default location on user screen.'
END

--MAKE SURE apivc_gl_rev_dt IS VALID
INSERT INTO @log
SELECT TOP 1 
	'There are invalid date value on apivc_gl_rev_dt of apivcmst.'
FROM apivcmst A WHERE ISDATE(A.apivc_gl_rev_dt) = 1
UNION ALL
SELECT TOP 1 
	'There are invalid date value on aptrx_gl_rev_dt of aptrxmst'
FROM aptrxmst A WHERE ISDATE(A.aptrx_gl_rev_dt) = 1

--VALIDATE THE AP ACCOUNT IF NO VALUE
INSERT INTO @log
SELECT DISTINCT
	CAST(A.apcbk_gl_ap AS NVARCHAR) + ' is not a valid AP Account.'
FROM apcbkmst A INNER JOIN aptrxmst B ON A.apcbk_no = B.aptrx_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
			THEN
				CASE WHEN ISDATE(B.aptrx_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(B.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
			ELSE 1 END)
UNION ALL
SELECT DISTINCT
	CAST(A.apcbk_gl_ap AS NVARCHAR)+ ' is not a valid AP Account.'
FROM apcbkmst A INNER JOIN apivcmst B ON A.apcbk_no = B.apivc_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
			THEN
				CASE WHEN ISDATE(B.apivc_gl_rev_dt) = 1  AND CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
					AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1 ELSE 0 END
			ELSE 1 END)


--VALIDATE THE AP ACCOUNT IF NOT EXISTS
INSERT INTO @log
SELECT DISTINCT
	'AP Account ' + CAST(A.apcbk_gl_ap AS NVARCHAR) + ' in apcbkmst does not exists in i21.'
FROM apcbkmst A
WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND A.apcbk_no IN (
	SELECT apivc_cbk_no FROM apivcmst B
	WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
					THEN
						CASE WHEN ISDATE(B.apivc_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
							AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1 ELSE 0 END
					ELSE 1 END)
)
UNION ALL
SELECT DISTINCT
	'AP Account ' + CAST(A.apcbk_gl_ap AS NVARCHAR) + ' in apcbkmst does not exists in i21.'
FROM apcbkmst A
WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND A.apcbk_no IN (
	SELECT aptrx_cbk_no FROM aptrxmst C
	WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
					THEN
						CASE WHEN ISDATE(C.aptrx_gl_rev_dt) = 1  AND CONVERT(DATE, CAST(C.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
					ELSE 1 END)
)

--GET ALL INVALID GL ACCOUNT DETAIL
INSERT INTO @log
SELECT DISTINCT
	 'Invalid GL Account ' + CAST(A.apegl_gl_acct AS NVARCHAR)  + ' found in origin table apeglmst.'
FROM apeglmst A
INNER JOIN aptrxmst B ON A.apegl_vnd_no = B.aptrx_vnd_no AND A.apegl_ivc_no = B.aptrx_ivc_no
WHERE A.apegl_gl_acct NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN ISDATE(B.aptrx_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(B.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
		ELSE 1 END)
UNION ALL
SELECT DISTINCT
	'Invalid GL Account ' + CAST(A.aphgl_gl_acct AS NVARCHAR) + ' found in origin table aphglmst.'
FROM aphglmst A
INNER JOIN apivcmst B ON A.aphgl_vnd_no = B.apivc_vnd_no AND A.aphgl_ivc_no = B.apivc_ivc_no
WHERE A.aphgl_gl_acct NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN ISDATE(B.apivc_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
				AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1 ELSE 0 END
		ELSE 1 END)

--Check if there is check book that was not exists on tblCMBankAccount
DECLARE @missingCheckBook NVARCHAR(4), @error NVARCHAR(200);
IF @DateFrom IS NULL
BEGIN
	INSERT INTO @log
	SELECT DISTINCT
		'Check book number ' + CAST(A.apchk_cbk_no AS NVARCHAR) + ' was not imported.'
	FROM apchkmst A 
	LEFT JOIN tblCMBankAccount B
		ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
	WHERE B.strCbkNo IS NULL
END
ELSE
BEGIN
	INSERT INTO @log
	SELECT DISTINCT
		'Check book number ' + CAST(A.apchk_cbk_no AS NVARCHAR)  + ' was not imported.'
	FROM apchkmst A 
	INNER JOIN apivcmst C ON A.apchk_cbk_no = C.apivc_cbk_no
	LEFT JOIN tblCMBankAccount B
		ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
	WHERE B.strCbkNo IS NULL
	AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN ISDATE(C.apivc_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(C.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
				AND C.apivc_comment = 'CCD Reconciliation' AND C.apivc_status_ind = 'U' THEN 1 ELSE 0 END
		ELSE 1 END)
END

--VERIFY IF VOUCHER'S VENDOR ORDER NUMBER HAVEN'T USED IN i21
INSERT INTO @log
SELECT
	A.aptrx_ivc_no + ' already used in i21.'
FROM aptrxmst A
CROSS APPLY (
	SELECT 
		B.intBillId
	FROM tblAPBill B
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.intEntityVendorId
	WHERE B.strVendorOrderNumber COLLATE Latin1_General_CS_AS = A.aptrx_ivc_no
	AND C.strVendorId COLLATE Latin1_General_CS_AS = A.aptrx_vnd_no
) Vouchers
WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
		ELSE 1 END)
UNION ALL
SELECT
	A.apivc_ivc_no + ' already used in i21.'
FROM apivcmst A
CROSS APPLY (
	SELECT 
		B.intBillId
	FROM tblAPBill B
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.intEntityVendorId
	WHERE B.strVendorOrderNumber COLLATE Latin1_General_CS_AS = A.apivc_ivc_no
	AND C.strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no
) Vouchers
WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
				AND A.apivc_comment = 'CCD Reconciliation' AND A.apivc_status_ind = 'U' THEN 1 ELSE 0 END
		ELSE 1 END)

--DO NOT ALLOW TO IMPORT IF THERE ARE CHECK NO 00000000 AND IT IS PREPAYMENT
INSERT INTO @log
SELECT DISTINCT
	'Please fix the payment for check # ''00000000'' and for vendor ' + dbo.fnTrim(A.apivc_vnd_no)
FROM apivcmst A
WHERE A.apivc_chk_no = '00000000' AND A.apivc_trans_type = 'A'
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
					THEN
						CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 AND CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
					ELSE 1 END)

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate], 
	[strLogKey]
)
SELECT 
	[strDescription], 
    @UserId, 
    @logDate, 
	@key
FROM @log

IF EXISTS(SELECT 1 FROM @log) SET @isValid = 0;
ELSE SET @isValid = 1

END TRY
BEGIN CATCH
	DECLARE @errorValidating NVARCHAR(500) = ERROR_MESSAGE();
	RAISERROR(@errorValidating, 16, 1);
END CATCH