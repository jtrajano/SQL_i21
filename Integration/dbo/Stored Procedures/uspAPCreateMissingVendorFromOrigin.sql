CREATE PROCEDURE [dbo].[uspAPCreateMissingVendorFromOrigin]
	@UserId INT,
	@dateFrom DATETIME,
	@dateTo DATETIME,
	@totalCreated INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

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
		SELECT apivc_vnd_no FROM apivcmst A
			LEFT JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
			WHERE B.strVendorId IS NULL
		UNION ALL
		SELECT aptrx_vnd_no FROM aptrxmst A
			LEFT JOIN tblAPVendor B ON A.aptrx_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
			WHERE B.strVendorId IS NULL
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
