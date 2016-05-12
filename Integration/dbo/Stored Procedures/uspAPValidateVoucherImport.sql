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
IF (EXISTS(
	SELECT 1 FROM apcbkmst A INNER JOIN aptrxmst B ON A.apcbk_no = B.aptrx_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
	AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
				THEN
					CASE WHEN CONVERT(DATE, CAST(B.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
				ELSE 1 END)
	UNION ALL
	SELECT 1 FROM apcbkmst A INNER JOIN apivcmst B ON A.apcbk_no = B.apivc_cbk_no WHERE ISNULL(A.apcbk_gl_ap,0) = 0
	AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
				THEN
					CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
				ELSE 1 END)
	)
)
BEGIN
	INSERT INTO @log
	SELECT 'Invalid AP Account found in origin table apcbkmst. Please call iRely assistance.', @UserId, GETDATE(), 3, 0
END

--VALIDATE THE AP ACCOUNT IF NOT EXISTS
IF EXISTS(
		SELECT 1 FROM apcbkmst A
		WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
		AND A.apcbk_no IN (
			SELECT apivc_cbk_no FROM apivcmst B
			WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
				AND 1 = (CASE WHEN @DateFrom IS NULL AND B.apivc_comment = 'CCD Reconciliation' AND B.apivc_status_ind = 'U' THEN 1
							WHEN @DateFrom = 0 THEN 1	
						ELSE 0 END)
		)
		UNION ALL
		SELECT 1 FROM apcbkmst A
		WHERE A.apcbk_gl_ap NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
		AND A.apcbk_no IN (
			SELECT aptrx_cbk_no FROM aptrxmst C
			WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(C.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
		)
	)
BEGIN
	INSERT INTO @log
	SELECT 'Invalid AP Account found in origin table apcbkmst. Please call iRely assistance.', @UserId, GETDATE(), 4, 0
END

IF EXISTS(
			SELECT 1 FROM apeglmst A
			WHERE A.apegl_gl_acct NOT IN (SELECT strExternalId FROM tblGLCOACrossReference)
		)
BEGIN
	INSERT INTO @log
	SELECT 'Invalid GL Account found in origin table apeglmst. Please call iRely assistance.', @UserId, GETDATE(), 5, 0
END

--Check if there is check book that was not exists on tblCMBankAccount
DECLARE @missingCheckBook NVARCHAR(4), @error NVARCHAR(200);
IF @DateFrom IS NULL
BEGIN
	SELECT TOP 1 @missingCheckBook = A.apchk_cbk_no FROM apchkmst A 
	LEFT JOIN tblCMBankAccount B
		ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
	WHERE B.strCbkNo IS NULL
END
ELSE
BEGIN
	SELECT TOP 1 @missingCheckBook = A.apchk_cbk_no FROM apchkmst A 
	INNER JOIN apivcmst C ON A.apchk_cbk_no = C.apivc_cbk_no
	LEFT JOIN tblCMBankAccount B
		ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
	WHERE B.strCbkNo IS NULL
	AND 1 = (CASE WHEN CONVERT(DATE, CAST(C.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END)

END

IF @missingCheckBook IS NOT NULL
BEGIN
	SET @error = 'Check book number ' + @missingCheckBook + ' was not imported.'
	INSERT INTO @log
	SELECT @error, @UserId, GETDATE(), 6, 0
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