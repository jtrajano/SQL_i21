CREATE PROCEDURE [dbo].[uspAPVendorExportTransformSynergy]
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
DECLARE @SavePoint NVARCHAR(32) = 'uspAPVendorExportTransformSynergy';
DECLARE @insertedData TABLE(intVendorStagingId INT, intEntityId INT);

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF NOT (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'tblEMEntityStaging'))
BEGIN
    RAISERROR('Vendor export staging not yet executed.', 16, 1);
END

MERGE INTO tblAPVendorStagingSynergy
USING
(
	SELECT
		intEntityId				=	entStg.intEntityId,
		strVendorId				=	dbo.fnTrim(vndStg.strVendorId),
		strDescription			=	dbo.fnTrim(entStg.strName),
		strContact				=	dbo.fnTrim(cntcDataStg.strName),
		ysnUserShipperWeight	=	0,
		intVendorType			=	0,
		strVendorType			=	'Both'
	FROM tblEMEntityStaging entStg
	INNER JOIN tblAPVendorStaging vndStg
		ON entStg.intEntityId = vndStg.intEntityId
	INNER JOIN tblEMEntityToContactStaging cntcStg
		ON entStg.intEntityId = cntcStg.intEntityId
	INNER JOIN tblEMEntityContactDataStaging cntcDataStg
		ON cntcStg.intEntityContactId = cntcDataStg.intEntityId
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	strVendorId,
	strDescription,
	strContact,
	ysnUserShipperWeight,
	intVendorType,
	strVendorType
)
VALUES
(
	strVendorId,
	strDescription,
	strContact,
	ysnUserShipperWeight,
	intVendorType,
	strVendorType
)
OUTPUT
	inserted.intVendorStagingId,
	SourceData.intEntityId
INTO @insertedData;

MERGE INTO tblAPVendorContactInfoSynergy
USING
(
	SELECT
		intVendorStagingId	=	stg.intVendorStagingId,
		strContact			=	cntcDataStg.strName,
		strFirstName		=	CASE WHEN intVendorType = 0 
									THEN cntcDataStg.strName
								ELSE
									SUBSTRING(cntcDataStg.strName,0,dbo.fnLastIndex(cntcDataStg.strName,' '))
								END,
		strLastName			=	CASE WHEN intVendorType = 0 
									THEN cntcDataStg.strName
								ELSE
									SUBSTRING(cntcDataStg.strName, dbo.fnLastIndex(cntcDataStg.strName,' '), DATALENGTH(cntcDataStg.strName))
								END,
		strAddress1			=	CAST(CASE WHEN CHARINDEX(CHAR(10), cntcLocDataStg.strAddress) > 0 
													THEN SUBSTRING(cntcLocDataStg.strAddress, 0, CHARINDEX(CHAR(10),cntcLocDataStg.strAddress)) 
													ELSE cntcLocDataStg.strAddress END AS VARCHAR(30)),
		strAddress2			=	CAST(CASE WHEN CHARINDEX(CHAR(10), cntcLocDataStg.strAddress) > 0 
													THEN SUBSTRING(cntcLocDataStg.strAddress, CHARINDEX(CHAR(10),cntcLocDataStg.strAddress), LEN(cntcLocDataStg.strAddress)) 
													ELSE '' END AS VARCHAR(30)),
		strCity				=	ISNULL(cntcLocDataStg.strCity,''),
		strStateProv		=	ISNULL(cntcLocDataStg.strState,''),
		strPostalCode		=	ISNULL(cntcLocDataStg.strZipCode,''),
		strPhone			=	ISNULL(cntcPhoneDataStg.strPhone,''),
		strMobile			=	ISNULL(cntcDataStg.strMobile,''),
		strFax				=	ISNULL(cntcDataStg.strFax,''),
		strEmail			=	ISNULL(cntcDataStg.strEmail,''),
		strWebsite			=	ISNULL(cntcDataStg.strWebsite,'')
	FROM @insertedData stg
	INNER JOIN tblEMEntityStaging entStg
		ON stg.intEntityId = entStg.intEntityId
	INNER JOIN tblAPVendorStaging vndStg
		ON entStg.intEntityId = vndStg.intEntityId
	INNER JOIN tblEMEntityToContactStaging cntcStg
		ON entStg.intEntityId = cntcStg.intEntityId
	INNER JOIN tblEMEntityContactDataStaging cntcDataStg
		ON cntcStg.intEntityContactId = cntcDataStg.intEntityId
	LEFT JOIN tblEMEntityContactLocationDataStaging cntcLocDataStg
		ON cntcStg.intEntityLocationId = cntcLocDataStg.intEntityLocationId
	LEFT JOIN tblEMEntityContactPhoneDataStaging cntcPhoneDataStg
		ON cntcPhoneDataStg.intEntityId = cntcStg.intEntityContactId
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	intVendorStagingId,
	strContact,
	strFirstName,
	strLastName,
	strAddress1,
	strAddress2,
	strCity,
	strStateProv,
	strPostalCode,
	strPhone,
	strMobile,
	strFax,
	strEmail,
	strWebsite
)
VALUES
(
	intVendorStagingId,
	strContact,
	strFirstName,
	strLastName,
	strAddress1,
	strAddress2,
	strCity,
	strStateProv,
	strPostalCode,
	strPhone,
	strMobile,
	strFax,
	strEmail,
	strWebsite
);


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

	SET @ErrorMessage  = 'Error transforming vendor export.' + CHAR(13) + 
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