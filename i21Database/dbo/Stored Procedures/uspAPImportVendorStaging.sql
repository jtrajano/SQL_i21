CREATE PROCEDURE [dbo].[uspAPExportVendorStagingSynergy]
	@dateCreated DATETIME
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
DECLARE @SavePoint NVARCHAR(32) = 'uspAPExportVendorStagingSynergy';

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

--DROP TABLE THAT WE ARE USING FOR STAGING, THERE SHOULD BE NO OTHER USER IMPORTING
DROP TABLE tblEMEntityStaging
DROP TABLE tblAPVendorStaging
DROP TABLE tblEMEntityToContactStaging

SELECT
*
INTO tblEMEntityStaging
FROM tblEMEntity entity

SELECT
*
INTO tblEMEntityToContactStaging
FROM tblEMEntityToContact

SELECT
*
INTO tblAPVendorStaging
FROM tblAPVendor vendor


IF @transCount = 0 COMMIT TRANSACTION;

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	SET @ErrorProc     = ERROR_PROCEDURE()

	SET @ErrorMessage  = 'Error creating voucher.' + CHAR(13) + 
		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage

	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount > 0
	BEGIN
		ROLLBACK TRANSACTION  @SavePoint
	END

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END