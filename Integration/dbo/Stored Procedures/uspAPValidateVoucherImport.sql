CREATE PROCEDURE [dbo].[uspAPValidateVoucherImport]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@isValid BIT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL,
	[intLogType] INT NOT NULL,
	[ysnSuccess] BIT NOT NULL
)

IF(NOT EXISTS(SELECT 1 FROM tblSMUserSecurity A WHERE A.intEntityUserSecurityId = @UserId))
BEGIN
	INSERT INTO @log
	SELECT 'Invalid user provided.', @UserId, GETDATE(), 1, 0
END

--MAKE SURE USER HAS DEFAULT LOCATION
DECLARE @userLocation INT;
SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
		INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intEntityUserSecurityId = @UserId

IF(@userLocation IS NULL OR @userLocation <= 0)
BEGIN
	INSERT INTO @log
	SELECT 'Please setup default location on user screen.', @UserId, GETDATE(), 2, 0
END

--VALIDATE THE AP ACCOUNT IF NO VALUE
INSERT INTO @log
SELECT 
	CAST(A.apcbk_gl_ap AS NVARCHAR) + ' is not a valid AP Account.', @UserId, GETDATE(), 3, 0
FROM apcbkmst A INNER JOIN aptrxmst B ON A.apcbk_no = B.aptrx_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
			THEN
				CASE WHEN CONVERT(DATE, CAST(B.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
			ELSE 1 END)
UNION ALL
SELECT 
	CAST(A.apcbk_gl_ap AS NVARCHAR)+ ' is not a valid AP Account.', @UserId, GETDATE(), 3, 0 
FROM apcbkmst A INNER JOIN apivcmst B ON A.apcbk_no = B.apivc_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
			THEN
				CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
					AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1 ELSE 0 END
			ELSE 1 END)


--VALIDATE THE AP ACCOUNT IF NOT EXISTS
INSERT INTO @log
SELECT
	'AP Account ' + CAST(A.apcbk_gl_ap AS NVARCHAR) + ' in apcbkmst does not exists in i21.', @UserId, GETDATE(), 3, 0
FROM apcbkmst A
WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND A.apcbk_no IN (
	SELECT apivc_cbk_no FROM apivcmst B
	WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
					THEN
						CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
							AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1 ELSE 0 END
					ELSE 1 END)
)
UNION ALL
SELECT
	'AP Account ' + CAST(A.apcbk_gl_ap AS NVARCHAR) + ' in apcbkmst does not exists in i21.', @UserId, GETDATE(), 3, 0
FROM apcbkmst A
WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND A.apcbk_no IN (
	SELECT aptrx_cbk_no FROM aptrxmst C
	WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
					THEN
						CASE WHEN CONVERT(DATE, CAST(C.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
					ELSE 1 END)
)

INSERT INTO @log
SELECT 
	 'Invalid GL Account ' + CAST(A.apegl_gl_acct AS NVARCHAR)  + ' found in origin table apeglmst.', @UserId, GETDATE(), 5, 0
FROM apeglmst A
INNER JOIN aptrxmst B ON A.apegl_vnd_no = B.aptrx_vnd_no AND A.apegl_ivc_no = B.aptrx_ivc_no
WHERE A.apegl_gl_acct NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN CONVERT(DATE, CAST(B.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
		ELSE 1 END)
UNION ALL
SELECT
	'Invalid GL Account ' + CAST(A.aphgl_gl_acct AS NVARCHAR) + ' found in origin table aphglmst.', @UserId, GETDATE(), 5, 0
FROM aphglmst A
INNER JOIN apivcmst B ON A.aphgl_vnd_no = B.apivc_vnd_no AND A.aphgl_ivc_no = B.apivc_ivc_no
WHERE A.aphgl_gl_acct NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
		THEN
			CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
				AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1 ELSE 0 END
		ELSE 1 END)

--Check if there is check book that was not exists on tblCMBankAccount
DECLARE @missingCheckBook NVARCHAR(4), @error NVARCHAR(200);
IF @DateFrom IS NULL
BEGIN
	INSERT INTO @log
	SELECT 
		'Check book number ' + CAST(A.apchk_cbk_no AS NVARCHAR) + ' was not imported.', @UserId, GETDATE(), 6, 0
	FROM apchkmst A 
	LEFT JOIN tblCMBankAccount B
		ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
	WHERE B.strCbkNo IS NULL
END
ELSE
BEGIN
	INSERT INTO @log
	SELECT 
		'Check book number ' + CAST(A.apchk_cbk_no AS NVARCHAR)  + ' was not imported.', @UserId, GETDATE(), 6, 0
	FROM apchkmst A 
	INNER JOIN apivcmst C ON A.apchk_cbk_no = C.apivc_cbk_no
	LEFT JOIN tblCMBankAccount B
		ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
	WHERE B.strCbkNo IS NULL
	AND 1 = (CASE WHEN CONVERT(DATE, CAST(C.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END)
END

--VERIFY IF VOUCHER'S VENDOR ORDER NUMBER HAVEN'T USED IN i21
INSERT INTO @log
SELECT
	A.aptrx_ivc_no + ' already used in i21.'
	,@UserId
	,GETDATE()
	,7
	,0
FROM aptrxmst A
CROSS APPLY (
	SELECT 
		B.intBillId
	FROM tblAPBill B
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.intEntityVendorId
	WHERE B.strVendorOrderNumber COLLATE Latin1_General_CS_AS = A.aptrx_ivc_no
	AND C.strVendorId COLLATE Latin1_General_CS_AS = A.aptrx_vnd_no
) Vouchers
WHERE 1 = (CASE WHEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END)
UNION ALL
SELECT
	A.apivc_ivc_no + ' already used in i21.'
	,@UserId
	,GETDATE()
	,7
	,0
FROM apivcmst A
CROSS APPLY (
	SELECT 
		B.intBillId
	FROM tblAPBill B
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.intEntityVendorId
	WHERE B.strVendorOrderNumber COLLATE Latin1_General_CS_AS = A.apivc_ivc_no
	AND C.strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no
) Vouchers
WHERE 1 = (CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
				AND A.apivc_comment = 'CCD Reconciliation' AND A.apivc_status_ind = 'U' THEN 1 ELSE 0 END)


INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate], 
    [intLogType], 
    [ysnSuccess]
)
SELECT * FROM @log

IF EXISTS(SELECT 1 FROM @log) SET @isValid = 0;
ELSE SET @isValid = 1

END TRY
BEGIN CATCH
	DECLARE @errorValidating NVARCHAR(500) = ERROR_MESSAGE();
	RAISERROR(@errorValidating, 16, 1);
END CATCH