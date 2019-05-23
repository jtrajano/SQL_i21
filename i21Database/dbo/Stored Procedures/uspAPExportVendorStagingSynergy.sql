CREATE PROCEDURE [dbo].[uspAPExportVendorStagingSynergy]
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
IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'tblEMEntityStaging'))
BEGIN
	DELETE FROM tblAPVendorStagingSynergy
	DELETE FROM tblAPVendorContactInfoSynergy
    DROP TABLE tblEMEntityStaging
	DROP TABLE tblAPVendorStaging
	DROP TABLE tblEMEntityToContactStaging
	DROP TABLE tblEMEntityContactDataStaging
	DROP TABLE tblEMEntityContactLocationDataStaging
	DROP TABLE tblEMEntityContactPhoneDataStaging
END

--GET ALL ENTITY VENDOR INFO
SELECT
	entity.*
INTO tblEMEntityStaging
FROM tblEMEntity entity
LEFT JOIN tblAPVendorSynergyExported exported
	ON entity.intEntityId = exported.intVendorId
WHERE exported.intVendorId IS NULL

--GET ALL THE LINKING OF CONTACT FROM ENTITY
SELECT
	contact.*
INTO tblEMEntityToContactStaging
FROM tblEMEntityToContact contact
INNER JOIN tblEMEntityStaging entStg
	ON contact.intEntityId = entStg.intEntityId

--GET ALL OF CONTACT DATA
SELECT
	contactData.*
INTO tblEMEntityContactDataStaging
FROM tblEMEntity contactData
INNER JOIN tblEMEntityToContactStaging cntcStg
	ON contactData.intEntityId = cntcStg.intEntityContactId

--GET ALL OF CONTACT LOCATION DATA
SELECT
	contactLocData.*
INTO tblEMEntityContactLocationDataStaging
FROM tblEMEntityLocation contactLocData
INNER JOIN tblEMEntityToContactStaging cntcStg
	ON contactLocData.intEntityLocationId = cntcStg.intEntityLocationId

--GET ALL OF CONTACT PHONE DATA
SELECT
	contactPhoneData.*
INTO tblEMEntityContactPhoneDataStaging
FROM tblEMEntityPhoneNumber contactPhoneData
INNER JOIN tblEMEntityToContactStaging cntcStg
	ON contactPhoneData.intEntityId = cntcStg.intEntityContactId

--GET ALL OF VENDOR INFO
SELECT
	vendor.*
INTO tblAPVendorStaging
FROM tblAPVendor vendor
INNER JOIN tblEMEntityStaging entStg
	ON vendor.intEntityId = entStg.intEntityId

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

	SET @ErrorMessage  = 'Error staging vendor export.' + CHAR(13) + 
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