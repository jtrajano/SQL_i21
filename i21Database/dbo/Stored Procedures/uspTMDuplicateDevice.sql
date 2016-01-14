CREATE PROCEDURE [dbo].uspTMDuplicateDevice
	@DeviceId INT,
	@NewDeviceId INT OUTPUT
AS
BEGIN
	--DECLARE @DeviceId INT 
	--DECLARE @NewDeviceId INT

	--SET @DeviceId = 4

	DECLARE @strOriginalSerialNumber NVARCHAR(50)
	DECLARE @strSerialNumberToUse NVARCHAR(50)
	DECLARE @intSerialSuffix INT
	SET @intSerialSuffix = 1

	SET @strOriginalSerialNumber = (SELECT TOP 1 strSerialNumber FROM tblTMDevice WHERE intDeviceId = @DeviceId)
	SET @strSerialNumberToUse = ISNULL(@strOriginalSerialNumber,'') + '-' + CAST(@intSerialSuffix AS NVARCHAR(5))

	WHILE EXISTS(SELECT TOP 1 1 FROM tblTMDevice WHERE strSerialNumber = @strSerialNumberToUse)
	BEGIN
		SET @intSerialSuffix = @intSerialSuffix + 1
		SET @strSerialNumberToUse = ISNULL(@strOriginalSerialNumber,'') + '-' + CAST(@intSerialSuffix AS NVARCHAR(5))
	END

	INSERT INTO tblTMDevice(
		strSerialNumber 
		,strManufacturerID
		,strManufacturerName
		,strModelNumber
		,strBulkPlant
		,strDescription
		,strOwnership
		,strAssetNumber
		,dtmPurchaseDate
		,dblPurchasePrice
		,dtmManufacturedDate
		,strComment
		,ysnUnderground
		,dblTankCapacity
		,dblTankReserve
		,dblEstimatedGalTank
		,intMeterCycle
		,intDeviceTypeId
		,intDeployedStatusID
		,intParentDeviceID
		,intInventoryStatusTypeId
		,intTankTypeId
		,intMeterTypeId
		,intRegulatorTypeId
		,intLinkedToTankID
		,strMeterStatus
		,dblMeterReading
		,ysnAppliance
		,intApplianceTypeID
		,intLocationId
		,intLeaseId
	)
	SELECT 
		strSerialNumber = @strSerialNumberToUse
		,strManufacturerID
		,strManufacturerName
		,strModelNumber
		,strBulkPlant
		,strDescription
		,strOwnership
		,strAssetNumber
		,dtmPurchaseDate
		,dblPurchasePrice
		,dtmManufacturedDate
		,strComment
		,ysnUnderground
		,dblTankCapacity
		,dblTankReserve
		,dblEstimatedGalTank
		,intMeterCycle
		,intDeviceTypeId
		,intDeployedStatusID
		,intParentDeviceID
		,intInventoryStatusTypeId = (SELECT TOP 1 intInventoryStatusTypeId FROM tblTMInventoryStatusType WHERE strInventoryStatusType = 'In')
		,intTankTypeId
		,intMeterTypeId
		,intRegulatorTypeId
		,intLinkedToTankID
		,strMeterStatus
		,dblMeterReading
		,ysnAppliance
		,intApplianceTypeID
		,intLocationId
		,intLeaseId = NULL
	FROM tblTMDevice
	WHERE intDeviceId = @DeviceId
	
	SET @NewDeviceId = SCOPE_IDENTITY()
END