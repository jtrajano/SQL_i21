CREATE PROCEDURE [dbo].[uspApiSchemaTMDevice]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @tmpOwnership TABLE (
		strOwnership NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	)

	DECLARE @tmpMeterStatus TABLE (
		strMeterStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	)

	INSERT INTO @tmpOwnership (strOwnership) VALUES ('Customer Owned')
	INSERT INTO @tmpOwnership (strOwnership) VALUES ('Company Owned')
	INSERT INTO @tmpOwnership (strOwnership) VALUES ('Lease')
	INSERT INTO @tmpOwnership (strOwnership) VALUES ('Lease to Own')

	INSERT INTO @tmpMeterStatus (strMeterStatus) VALUES ('Active')
	INSERT INTO @tmpMeterStatus (strMeterStatus) VALUES ('Inactive')

	-- VALIDATE Device Type
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
		, strField = 'Device Type'
		, strValue = D.strDeviceType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Device Type ''' + D.strDeviceType + ''' in i21 Device Types'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMDeviceType DT ON DT.strDeviceType = D.strDeviceType
	WHERE DT.intDeviceTypeId IS NULL
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Ownership
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
		, strField = 'Ownership'
		, strValue = D.strOwnership
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Ownership ''' + D.strOwnership + ''' in i21 Ownerships'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN @tmpOwnership O ON O.strOwnership = D.strOwnership
	WHERE O.strOwnership IS NULL
	AND ISNULL(D.strOwnership, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Bulk Plant 
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
		, strField = 'Bulk Plant Number'
		, strValue = D.strBulkPlant
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Bulk Plant Number ''' + D.strBulkPlant + ''' in i21 Company Locations'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = D.strBulkPlant
	WHERE CL.intCompanyLocationId IS NULL
	AND ISNULL(D.strBulkPlant, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Inventory Status
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
		, strField = 'Inventory Status'
		, strValue = D.strInventoryStatus
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Inventory Status ''' + D.strInventoryStatus + ''' in i21 Inventory Status'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMInventoryStatusType C ON C.strInventoryStatusType = D.strInventoryStatus
	WHERE C.intInventoryStatusTypeId IS NULL
	AND ISNULL(D.strInventoryStatus, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Installed on Tank
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
		, strField = 'Installed on Tank'
		, strValue = D.strInstalledOnTank
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Installed on Tank ''' + D.strInstalledOnTank + ''' in i21 Devices'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMDevice C ON C.strSerialNumber = D.strInstalledOnTank
	WHERE C.intDeviceId IS NULL
	AND ISNULL(D.strInstalledOnTank, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Regulator Type
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
		, strField = 'Regulator Type'
		, strValue = D.strRegulatorType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Regulator Type ''' + D.strRegulatorType + ''' in i21 Regulator Types'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMRegulatorType C ON C.strRegulatorType = D.strRegulatorType
	WHERE C.intRegulatorTypeId IS NULL
	AND ISNULL(D.strRegulatorType, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Tank Type
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
		, strField = 'Tank Type'
		, strValue = D.strTankType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Tank Type ''' + D.strTankType + ''' in i21 Tank Types'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMTankType TT ON TT.strTankType = D.strTankType
	WHERE TT.intTankTypeId IS NULL
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Manufacturer
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
		, strField = 'Manufacturer'
		, strValue = D.strManufacturer
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Manufacturer ''' + D.strManufacturer + ''' in i21 Manufacturers'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMManufacturer C ON C.strManufacturerId = D.strManufacturer
	WHERE C.intManufacturerId IS NULL
	AND ISNULL(D.strManufacturer, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Meter Type
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
		, strField = 'Meter Type'
		, strValue = D.strMeterType
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Meter Type ''' + D.strMeterType + ''' in i21 Meter Types'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblTMMeterType C ON C.strMeterType = D.strMeterType
	WHERE C.intMeterTypeId IS NULL
	AND ISNULL(D.strMeterType, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Meter Status
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
		, strField = 'Meter Status'
		, strValue = D.strMeterStatus
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Meter Status ''' + D.strMeterStatus + ''' in i21 Meter Status'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN @tmpMeterStatus C ON C.strMeterStatus = D.strMeterStatus
	WHERE C.strMeterStatus IS NULL
	AND ISNULL(D.strMeterStatus, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Customer Entity No
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
		, strField = 'Customer Entity No'
		, strValue = D.strCustomerEntityNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Customer Entity No ''' + D.strCustomerEntityNo + ''' in i21 Customers'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblEMEntity E ON E.strEntityNo = D.strCustomerEntityNo
	LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
	LEFT JOIN tblTMCustomer T ON T.intCustomerNumber = E.intEntityId
	WHERE (C.intEntityId IS NULL OR T.intCustomerID IS NULL)
	AND ISNULL(D.strCustomerEntityNo, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Site Number
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
		, strField = 'Site Number'
		, strValue = CONVERT(NVARCHAR(10),D.intSiteNumber)
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = D.intRowNumber
		, strMessage = 'Cannot find the Site Number ''' + CONVERT(NVARCHAR(10),D.intSiteNumber) + ''' in i21 Sites'
	FROM tblApiSchemaTMDevice D
	LEFT JOIN tblEMEntity E ON E.strEntityNo = D.strCustomerEntityNo
	LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
	LEFT JOIN tblTMCustomer T ON T.intCustomerNumber = E.intEntityId
	LEFT JOIN tblTMSite S ON S.intSiteNumber = D.intSiteNumber
	WHERE S.intSiteID IS NULL
	AND D.intSiteNumber IS NOT NULL
	AND (C.intEntityId IS NULL OR T.intCustomerID IS NULL)
	AND ISNULL(D.strCustomerEntityNo, '') != ''
	AND D.guiApiUniqueId = @guiApiUniqueId
	
	-- PROCESS
	DECLARE @intDeviceTypeId INT = NULL
		, @strDescription NVARCHAR(300) = NULL
		, @strOwnership NVARCHAR(300) = NULL
		, @intCompanyLocationId INT = NULL
		, @intInventoryStatusTypeId INT = NULL
		, @strComment NVARCHAR(300) = NULL
		, @intParentDeviceID INT = NULL
		, @intRegulatorTypeId INT = NULL
		--, @strLeaseNumber NVARCHAR(100) = NULL

		, @dblCapacity NUMERIC(18, 6) = NULL
		, @dblReserve NUMERIC(18, 6) = NULL
		, @intTankTypeId INT = NULL
		, @dblEstGallonInTank NUMERIC(18, 6) = NULL
		, @ysnUnderground BIT = NULL

		, @strSerialNumber NVARCHAR(50) = NULL
		, @intManufacturerId INT = NULL
		, @dtmManufacturedDate DATETIME = NULL
		, @strModelNumber NVARCHAR(100) = NULL
		, @strAssetNumber NVARCHAR(100) = NULL
		, @dblPurchasePrice NUMERIC(18, 6) = NULL
		, @dtmPurchaseDate DATETIME = NULL

		, @intMeterTypeId INT = NULL
		, @intMeterCycle INT = NULL
		, @strMeterStatus NVARCHAR(50) = NULL
		, @dblMeterReading NUMERIC(18, 6) = NULL

		, @intRowNumber INT = NULL

		, @intCustomerId INT = NULL
		, @intSiteId INT = NULL

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR
	SELECT DT.intDeviceTypeId AS intDeviceTypeId
		, D.strDescription AS strDescription
		, O.strOwnership AS strOwnership
		, CL.intCompanyLocationId AS intCompanyLocationId
		, ST.intInventoryStatusTypeId AS intInventoryStatusTypeId
		, D.strComment AS strComment
		, C.intDeviceId AS intParentDeviceID
		, RT.intRegulatorTypeId  AS intRegulatorTypeId
		--, D.strLeaseNumber
		, D.dblCapacity AS dblCapacity
		, D.dblReserve AS dblReserve
		, TT.intTankTypeId AS intTankTypeId
		, D.dblEstGallonInTank AS dblEstGallonInTank
		, D.ysnUnderground AS ysnUnderground

		, D.strSerialNumber AS strSerialNumber
		, M.intManufacturerId AS intManufacturerId
		, D.dtmManufacturedDate AS dtmManufacturedDate
		, D.strModelNumber AS strModelNumber
		, D.strAssetNumber AS strAssetNumber
		, D.dblPurchasePrice AS dblPurchasePrice
		, D.dtmPurchaseDate AS dtmPurchaseDate

		, MT.intMeterTypeId AS intMeterTypeId
		, D.intMeterCycle AS intMeterCycle
		, MS.strMeterStatus AS strMeterStatus
		, D.dblMeterReading AS dblMeterReading
		, D.intRowNumber
		, T.intCustomerID AS intCustomerId
		, S.intSiteID AS intSiteId
		FROM tblApiSchemaTMDevice D
		INNER JOIN tblTMDeviceType DT ON DT.strDeviceType = D.strDeviceType
		INNER JOIN tblTMTankType TT ON TT.strTankType = D.strTankType
		LEFT JOIN @tmpOwnership O ON O.strOwnership = D.strOwnership
		LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = D.strBulkPlant
		LEFT JOIN tblTMInventoryStatusType ST ON ST.strInventoryStatusType = D.strInventoryStatus
		LEFT JOIN tblTMDevice C ON C.strSerialNumber = D.strInstalledOnTank
		LEFT JOIN tblTMRegulatorType RT ON RT.strRegulatorType = D.strRegulatorType
		LEFT JOIN tblTMManufacturer M ON M.strManufacturerId = D.strManufacturer
		LEFT JOIN tblTMMeterType MT ON MT.strMeterType = D.strMeterType
		LEFT JOIN @tmpMeterStatus MS ON MS.strMeterStatus = D.strMeterStatus
		LEFT JOIN tblEMEntity E ON E.strEntityNo = D.strCustomerEntityNo
		LEFT JOIN tblARCustomer CR ON CR.intEntityId = E.intEntityId AND CR.ysnActive = 1
		LEFT JOIN tblTMCustomer T ON T.intCustomerNumber = E.intEntityId
		LEFT JOIN tblTMSite S ON S.intSiteNumber = D.intSiteNumber AND S.intCustomerID = T.intCustomerID
	WHERE D.guiApiUniqueId = @guiApiUniqueId
		AND (ISNULL(D.strOwnership, '') = '' OR (O.strOwnership IS NOT NULL AND ISNULL(D.strOwnership, '') != ''))
		AND (ISNULL(D.strBulkPlant, '') = '' OR (CL.intCompanyLocationId IS NOT NULL AND ISNULL(D.strBulkPlant, '') != ''))
		AND (ISNULL(D.strInventoryStatus, '') = '' OR (ST.intInventoryStatusTypeId IS NOT NULL AND ISNULL(D.strInventoryStatus, '') != ''))
		AND (ISNULL(D.strInstalledOnTank, '') = '' OR (C.intDeviceId IS NOT NULL AND ISNULL(D.strInstalledOnTank, '') != ''))
		AND (ISNULL(D.strRegulatorType, '') = '' OR (RT.intRegulatorTypeId IS NOT NULL AND ISNULL(D.strRegulatorType, '') != ''))
		AND (ISNULL(D.strManufacturer, '') = '' OR (M.intManufacturerId IS NOT NULL AND ISNULL(D.strManufacturer, '') != ''))
		AND (ISNULL(D.strMeterType, '') = '' OR (MT.intMeterTypeId IS NOT NULL AND ISNULL(D.strMeterType, '') != ''))
		AND (ISNULL(D.strMeterStatus, '') = '' OR (MS.strMeterStatus IS NOT NULL AND ISNULL(D.strMeterStatus, '') != ''))
		AND (ISNULL(D.strCustomerEntityNo, '') = '' OR (T.intCustomerID IS NOT NULL AND ISNULL(D.strCustomerEntityNo, '') != ''))
		AND (ISNULL(D.intSiteNumber, '') = '' OR (S.intSiteNumber IS NOT NULL AND ISNULL(D.intSiteNumber, '') != ''))

	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intDeviceTypeId, @strDescription, @strOwnership, @intCompanyLocationId, @intInventoryStatusTypeId, @strComment, @intParentDeviceID
		, @intRegulatorTypeId, @dblCapacity, @dblReserve, @intTankTypeId, @dblEstGallonInTank, @ysnUnderground, @strSerialNumber, @intManufacturerId
		, @dtmManufacturedDate, @strModelNumber, @strAssetNumber, @dblPurchasePrice, @dtmPurchaseDate, @intMeterTypeId, @intMeterCycle, @strMeterStatus
		, @dblMeterReading, @intRowNumber, @intCustomerId, @intSiteId
	WHILE @@FETCH_STATUS = 0
    BEGIN
	
		IF (@strSerialNumber IS NOT NULL)
		BEGIN		
			DECLARE @intDeviceId INT = NULL
			SELECT @intDeviceId = intDeviceId FROM tblTMDevice WHERE strSerialNumber = @strSerialNumber
		
			IF(@intDeviceId IS NULL)
			BEGIN
				-- INSERT DEVICE
				INSERT INTO tblTMDevice(intDeviceTypeId
					, strDescription
					, strOwnership
					, intLocationId
					, intInventoryStatusTypeId
					, strComment
					, intParentDeviceID
					, intRegulatorTypeId

					, dblTankCapacity
					, dblTankReserve
					, intTankTypeId
					, dblEstimatedGalTank
					, ysnUnderground

					, strSerialNumber
					, intManufacturerId
					, dtmManufacturedDate
					, strModelNumber
					, strAssetNumber
					, dblPurchasePrice
					, dtmPurchaseDate

					, intMeterTypeId
					, intMeterCycle
					, strMeterStatus
					, dblMeterReading
					
					, guiApiUniqueId
					, intRowNumber)
				VALUES(@intDeviceTypeId
					, @strDescription
					, @strOwnership
					, @intCompanyLocationId
					, @intInventoryStatusTypeId
					, @strComment
					, @intParentDeviceID
					, @intRegulatorTypeId

					, @dblCapacity
					, @dblReserve
					, @intTankTypeId
					, @dblEstGallonInTank
					, @ysnUnderground

					, @strSerialNumber
					, @intManufacturerId
					, @dtmManufacturedDate
					, @strModelNumber
					, @strAssetNumber
					, @dblPurchasePrice
					, @dtmPurchaseDate
					
					, @intMeterTypeId
					, @intMeterCycle
					, @strMeterStatus
					, @dblMeterReading

					, @guiLogId
					, @intRowNumber
				)

				SET @intDeviceId = SCOPE_IDENTITY()

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
					, strLogLevel = 'Success'
					, strStatus = 'Success'
					, intRowNo = @intRowNumber
					, strMessage = 'Successfully added'	
			END
			ELSE 
			BEGIN
				-- UPDATE DEVICE
				UPDATE tblTMDevice SET intDeviceTypeId = @intDeviceTypeId
					, strDescription = @strDescription
					, strOwnership = @strOwnership
					, intLocationId = @intCompanyLocationId
					, intInventoryStatusTypeId = @intInventoryStatusTypeId
					, strComment = @strComment
					, intParentDeviceID = @intParentDeviceID
					, intRegulatorTypeId = @intRegulatorTypeId

					, dblTankCapacity = @dblCapacity
					, dblTankReserve = @dblReserve
					, intTankTypeId = @intTankTypeId
					, dblEstimatedGalTank = @dblEstGallonInTank
					, ysnUnderground = @ysnUnderground

					, strSerialNumber = @strSerialNumber
					, intManufacturerId = @intManufacturerId
					, dtmManufacturedDate = @dtmManufacturedDate
					, strModelNumber = @strModelNumber
					, strAssetNumber = @strAssetNumber
					, dblPurchasePrice = @dblPurchasePrice
					, dtmPurchaseDate = @dtmPurchaseDate

					, intMeterTypeId = @intMeterTypeId
					, intMeterCycle = @intMeterCycle
					, strMeterStatus = @strMeterStatus
					, dblMeterReading = @dblMeterReading
					, guiApiUniqueId = @guiLogId
					, intRowNumber = @intRowNumber
				WHERE intDeviceId = @intDeviceId

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
					, strLogLevel = 'Success'
					, strStatus = 'Success'
					, intRowNo = @intRowNumber
					, strMessage = 'Successfully updated'
			END

			-- ATTACH TO SITE
			IF(@intDeviceId IS NOT NULL)
			BEGIN	
				IF (@intCustomerId IS NOT NULL AND @intSiteId IS NOT NULL)
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblTMSiteDevice SD
						INNER JOIN tblTMSite S ON S.intSiteID = SD.intSiteID
						INNER JOIN tblTMDevice D ON D.intDeviceId = SD.intDeviceId
						WHERE D.intDeviceId = @intDeviceId
						AND S.intCustomerID = @intCustomerId
						AND SD.intSiteID = @intSiteId)
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
							, strMessage = 'Device already attached to the site'			
					END
					ELSE IF EXISTS(SELECT TOP 1 1 FROM tblTMSiteDevice SD
						INNER JOIN tblTMSite S ON S.intSiteID = SD.intSiteID
						INNER JOIN tblTMDevice D ON D.intDeviceId = SD.intDeviceId
						WHERE D.intDeviceId = @intDeviceId)
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
							, strMessage = 'Device already attached to the other site'
					END
					ELSE
					BEGIN
						INSERT INTO tblTMSiteDevice(intSiteID, intDeviceId, intConcurrencyId, guiApiUniqueId, intRowNumber)
						VALUES(@intSiteId, @intDeviceId, 1, @guiLogId, @intRowNumber)

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
							, strLogLevel = 'Success'
							, strStatus = 'Success'
							, intRowNo = @intRowNumber
							, strMessage = 'Successfully attached the device to the site'
					END
				END
			END

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
				, strMessage = 'Serial Number is required'
		END

		FETCH NEXT FROM DataCursor INTO @intDeviceTypeId, @strDescription, @strOwnership, @intCompanyLocationId, @intInventoryStatusTypeId, @strComment, @intParentDeviceID
			, @intRegulatorTypeId, @dblCapacity, @dblReserve, @intTankTypeId, @dblEstGallonInTank, @ysnUnderground, @strSerialNumber, @intManufacturerId
			, @dtmManufacturedDate, @strModelNumber, @strAssetNumber, @dblPurchasePrice, @dtmPurchaseDate, @intMeterTypeId, @intMeterCycle, @strMeterStatus
			, @dblMeterReading, @intRowNumber, @intCustomerId, @intSiteId
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor
END
