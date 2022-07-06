CREATE PROCEDURE [dbo].[uspApiSchemaTRTransformProductSearch]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN
	
	DECLARE @intImportedRowsCount INT = 0

	-- VALIDATE Vendor Entity
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Vendor Entity Number'
		, strValue = PS.strVendorEntityNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PS.intRowNumber
		, strMessage = 'Could not find the Vendor Entity Number ''' + PS.strVendorEntityNo + ''' in i21 Vendors'
	FROM tblApiSchemaTRProductSearch PS
	LEFT JOIN tblEMEntity E ON E.strEntityNo = PS.strVendorEntityNo
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	WHERE V.intEntityId IS NULL
	AND PS.guiApiUniqueId = @guiApiUniqueId


	-- VALIDATE Location Name
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Location Name'
		, strValue = PS.strLocationName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PS.intRowNumber
		, strMessage = 'Could not find the Location Name ''' + PS.strLocationName + ''' in i21 Vendor Locations'
	FROM tblApiSchemaTRProductSearch PS
	LEFT JOIN tblEMEntity E ON E.strEntityNo = PS.strVendorEntityNo
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = PS.strLocationName
	WHERE EL.intEntityLocationId IS NULL
	AND PS.guiApiUniqueId = @guiApiUniqueId


	-- VALIDATE Item
	INSERT INTO tblApiImportLogDetail (
		guiApiImportLogDetailId
		, guiApiImportLogId
		, strField
		, strValue
		, strLogLevel
		, strStatus
		, intRowNo
		, strMessage
	)
	SELECT guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Item Number'
		, strValue = PS.strItemNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = PS.intRowNumber
		, strMessage = 'Cannot find the Item Number ''' + PS.strItemNo + ''' in i21 Items'
	FROM tblApiSchemaTRProductSearch PS
	LEFT JOIN tblICItem I ON I.strItemNo = PS.strItemNo
	WHERE I.intItemId IS NULL
	AND PS.guiApiUniqueId = @guiApiUniqueId


	DECLARE @intVendorEntityId INT = NULL
	, @intEntityLocationId INT = NULL
	, @intItemId INT = NULL
	, @strLocationName NVARCHAR(100) = NULL
	, @strSearchValue NVARCHAR(100) = NULL
	, @intRowNumber INT = NULL


	DECLARE DataCursor CURSOR	
    FOR 
	SELECT V.intEntityId AS intVendorEntityId
		, EL.intEntityLocationId AS intEntityLocationId
		, I.intItemId
		, EL.strLocationName AS strLocationName
		, PS.strSearchValue
		, PS.intRowNumber
	FROM tblApiSchemaTRProductSearch PS
	INNER JOIN tblEMEntity E ON E.strEntityNo = PS.strVendorEntityNo
	INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
	INNER JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId AND EL.strLocationName = PS.strLocationName
	INNER JOIN tblICItem I ON I.strItemNo = PS.strItemNo
	WHERE PS.guiApiUniqueId = @guiApiUniqueId


	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO
	  @intVendorEntityId 
	, @intEntityLocationId
	, @intItemId
	, @strLocationName 
	, @strSearchValue
	, @intRowNumber 

	WHILE @@FETCH_STATUS = 0
    BEGIN

		DECLARE @ysnCreated BIT = 0
		DECLARE @intSupplyPointId INT = NULL
		SELECT @intSupplyPointId = intSupplyPointId FROM tblTRSupplyPoint WHERE intEntityVendorId = @intVendorEntityId AND intEntityLocationId = @intEntityLocationId

		IF(@intSupplyPointId IS NOT NULL)
		BEGIN
			DECLARE @strImportResultMsg NVARCHAR(50) = NULL
			DECLARE @intSupplyPointProductSearchHeaderId INT = NULL
			SELECT @intSupplyPointProductSearchHeaderId = intSupplyPointProductSearchHeaderId FROM tblTRSupplyPointProductSearchHeader WHERE intSupplyPointId = @intSupplyPointId AND intItemId = @intItemId

			IF(@intSupplyPointProductSearchHeaderId IS NULL)
			BEGIN
				INSERT INTO tblTRSupplyPointProductSearchHeader (intItemId
					, intSupplyPointId
					, intConcurrencyId)
				VALUES (@intItemId
					, @intSupplyPointId
					, 1)

				
				SET @ysnCreated = 1
				SET @intSupplyPointProductSearchHeaderId = SCOPE_IDENTITY()
			END

			
			DECLARE @intSupplyPointProductSearchDetailId INT = NULL
			SELECT @intSupplyPointProductSearchDetailId = intSupplyPointProductSearchDetailId FROM tblTRSupplyPointProductSearchDetail WHERE intSupplyPointProductSearchHeaderId = @intSupplyPointProductSearchHeaderId AND strSearchValue = @strSearchValue

			IF(@intSupplyPointProductSearchDetailId IS NULL)
			BEGIN
				INSERT INTO tblTRSupplyPointProductSearchDetail (intSupplyPointProductSearchHeaderId
						, strSearchValue
						, intConcurrencyId)
				VALUES (@intSupplyPointProductSearchHeaderId
						, @strSearchValue
						, 1)

				SET @ysnCreated = 1
				SET @intImportedRowsCount += 1
			END

			

			INSERT INTO tblApiImportLogDetail (
				guiApiImportLogDetailId
				, guiApiImportLogId
				, strField
				, strValue
				, strLogLevel
				, strStatus
				, intRowNo
				, strMessage)
			SELECT guiApiImportLogDetailId = NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = ''
				, strValue = '' 
				, strLogLevel ='Success'
				, strStatus = CASE WHEN @ysnCreated = 1 THEN 'Success' ELSE 'Skipped' END
				, intRowNo = @intRowNumber
				, strMessage = CASE WHEN @ysnCreated = 1 THEN 'Record successfully added.' ELSE 'Record already exists.' END

		END
		ELSE
		BEGIN
			INSERT INTO tblApiImportLogDetail (
				guiApiImportLogDetailId
				, guiApiImportLogId
				, strField
				, strValue
				, strLogLevel
				, strStatus
				, intRowNo
				, strMessage
			)
			SELECT guiApiImportLogDetailId = NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = ''
				, strValue = '' 
				, strLogLevel = 'Error'
				, strStatus = 'Failed'
				, intRowNo = @intRowNumber
				, strMessage = 'Cannot find the Supply point ''' + @strLocationName + ''' in i21 Supply Points'
		END
		FETCH NEXT FROM DataCursor INTO
		  @intVendorEntityId 
		, @intEntityLocationId
		, @intItemId
		, @strLocationName 
		, @strSearchValue
		, @intRowNumber 
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor


	UPDATE log
	SET log.intTotalRowsImported = @intImportedRowsCount
	FROM tblApiImportLog log
	WHERE log.guiApiImportLogId = @guiLogId
END



