CREATE PROCEDURE [dbo].[uspAPCreateMissingVendorFromOrigin]
	@UserId INT,
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@totalCreated INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @missingVendor TABLE(strVendorId NVARCHAR(100));
DECLARE @missingVendorId NVARCHAR(100);
DECLARE @missingVendorError NVARCHAR(500);
DECLARE @transCount INT = @@TRANCOUNT;

IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspAPCreateMissingVendor

INSERT INTO @missingVendor
SELECT dbo.fnTrim(apivc_vnd_no) FROM (
		SELECT DISTINCT apivc_vnd_no FROM apivcmst A
			LEFT JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
			WHERE B.strVendorId IS NULL
			AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL THEN 
						(CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
							AND A.apivc_comment = 'CCD Reconciliation' AND A.apivc_status_ind = 'U' THEN 1 ELSE 0 END)
					ELSE 1 END)
		UNION ALL
		SELECT DISTINCT aptrx_vnd_no FROM aptrxmst A
			LEFT JOIN tblAPVendor B ON A.aptrx_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
			WHERE B.strVendorId IS NULL
			AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL THEN 
						(CASE WHEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo 
							THEN 1 ELSE 0 END)
					ELSE 1 END)

) MissingVendors

SET @totalCreated = @@ROWCOUNT

IF EXISTS(SELECT 1 FROM @missingVendor)
BEGIN
	WHILE EXISTS(SELECT 1 FROM @missingVendor)
	BEGIN
		SELECT TOP 1 @missingVendorId = strVendorId FROM @missingVendor;
		EXEC uspEMCreateEntityById @Id = @missingVendorId, @Type = 'Vendor', @UserId = @UserId, @Message = @missingVendorError OUTPUT
		IF (@missingVendorError IS NOT NULL)
		BEGIN
			RAISERROR(@missingVendorError, 16, 1);
		END
		DELETE FROM @missingVendor WHERE strVendorId = @missingVendorId;
	END
END

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate], 
	[strLogKey]
)
SELECT 
	A.strVendorId + ' created.', 
    @UserId, 
    GETDATE(), 
	@key
FROM @missingVendor A
IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorCreatingVoucher NVARCHAR(500) = ERROR_MESSAGE();
	IF XACT_STATE() = -1
		ROLLBACK TRANSACTION;
	IF @transCount = 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION
	IF @transCount > 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION uspAPCreateMissingVendor
	RAISERROR(@errorCreatingVoucher, 16, 1);
END CATCH
