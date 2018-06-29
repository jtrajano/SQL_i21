CREATE PROCEDURE [dbo].[uspWHMBLCheckInSKU] 
				@intOrderHeaderId INT,
				@strUserName NVARCHAR(32),
				@intAddressId INT,
				@intContainerTypeId INT,
				@strStorageLocationName NVARCHAR(32),
				@dblQty NUMERIC(18,6),
				@strLotCode NVARCHAR(32),
				@dtmProductionDate DATETIME,
				@intItemId INT,
				@strContainerNo NVARCHAR(32),
				@strSKUNo NVARCHAR(32) = '', 
				@intOrderLineItemId INT = 0, 
				@intContainerId INT = 0 OUT, 
				@intSKUId INT = 0 OUT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @intLocalTran TINYINT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intStorageLocationId INT
	DECLARE @intCurrentStorageLocationId INT
	DECLARE @intFromStorageLocationId INT
	DECLARE @strTaskNo NVARCHAR(32)
	DECLARE @intOwnerAddressId INT
	DECLARE @intOrderStatusId INT
	DECLARE @intItemControlId INT
	DECLARE @dblFullPalletQty NUMERIC(18,6)
	DECLARE @intCompanyLocationId INT
	DECLARE @intCompanyLocationSubLocationId INT
	DECLARE @intStorageLocationRestrictionId INT
	DECLARE @intUOMId INT
	DECLARE @intUserId INT

	--Lot details         
	DECLARE @strParentLotNo NVARCHAR(MAX)
	DECLARE @strLotNo NVARCHAR(max)
	DECLARE @intLotId INT
	DECLARE @dtmManufactureDate DATETIME
	DECLARE @dtmExpiryDate DATETIME
	DECLARE @intLifeTime INT
	DECLARE @intLifeTimeDatePartId INT
	DECLARE @strAbbreviations CHAR(2)
	DECLARE @ysnLifetimeUnitMonthEndOfMonth BIT
	DECLARE @ysnSubLotAllowed AS BIT
	DECLARE @dblPhysicalCount NUMERIC(18, 6)
	DECLARE @dblConversionFactor NUMERIC(18, 6)
	DECLARE @dblQuantity NUMERIC(18, 6)
	DECLARE @intLotStatus INT
	DECLARE @strVendorNo NVARCHAR(50)
	DECLARE @strVendorLotNo NVARCHAR(50)
	DECLARE @strLotAlias NVARCHAR(50)
	DECLARE @dtmCurrentDateTime DATETIME
	DECLARE @intPhysicalCountUOMId INT
	DECLARE @ysnCreateParentLot BIT
	DECLARE @strParentLotAlias NVARCHAR(50)
	DECLARE @ysnLotCreate BIT
	DECLARE @strDefaultStorageLocationName NVARCHAR(100)
	DECLARE @strJulianDateLotCodeValidation NVARCHAR(100)
	DECLARE @strRawItemReceivingUnits NVARCHAR(max)
	DECLARE @intLotStorageLocationId INTEGER
	DECLARE @intUnitsPerLayer INTEGER
	DECLARE @intLayersPerPallet INTEGER
	DECLARE @ysnValidateSKU INTEGER
	DECLARE @intTransactionId INT

	SET @strErrMsg = ''
	SET @ysnValidateSKU=0  
	

	--SELECT  @ysnSubLotAllowed = SettingValue FROM dbo.iMake_AppSettingValue AV       
	--JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey            
	--WHERE S.SettingName = 'IsSubLotAllowed'        
	--SELECT  @strDefaultStorageLocationName = SettingValue FROM dbo.iMake_AppSettingValue AV            
	--JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey            
	--WHERE S.SettingName = 'DefaultReceivingLocation'        
	--SELECT  @ysnLotCreate = SettingValue FROM dbo.iMake_AppSettingValue AV            
	--JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey            
	--WHERE S.SettingName = 'IsLotCreateInImake'    
	-- SELECT  @strJulianDateLotCodeValidation = SettingValue FROM dbo.iMake_AppSettingValue AV    
	--JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey    
	--WHERE S.SettingName = 'JulianDateLotCcodeValidation'    
	SELECT @intUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName
	
	IF EXISTS (
			SELECT m.intItemId
			FROM tblWHOrderHeader oh
			JOIN tblWHOrderLineItem ol ON oh.intOrderHeaderId = ol.intOrderHeaderId
			JOIN tblICItem m ON m.intItemId = ol.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId
				--AND mt.IsLotAliasDisabledInWH = 0
				AND 1 = 0
				AND ISNULL(LTRIM(RTRIM(ol.strLotAlias)), '') = ''
			WHERE oh.intOrderHeaderId = @intOrderHeaderId
			)
	BEGIN
		RAISERROR ('One of the line item(s) does not have the lot alias. Please provide lot alias to proceed further.', 16, 1)
	END

	IF EXISTS (SELECT * FROM tblICItem WHERE intItemId = @intItemId AND strStatus = 'InActive')
	BEGIN
		RAISERROR ('The material is InActive. The transaction cannot proceed.', 16, 1)
	END

	SET @dtmCurrentDateTime = GETDATE()

	--Lot details        
	--IF @@TRANCOUNT = 0 SET @intLocalTran = 1                                        
	--IF @intLocalTran = 1 BEGIN TRANSACTION                                        
	BEGIN TRANSACTION

	SET @intContainerId = 0
	SET @intStorageLocationId = 0
	SET @intCurrentStorageLocationId = 0
	SET @intItemControlId = 0

	--SET @intOrderLineItemId = 0                                  
	SELECT @strTaskNo = strBOLNo, @intFromStorageLocationId = intStagingLocationId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT TOP 1 @strVendorNo = a.strName
	FROM tblWHOrderHeader oh
	JOIN tblEMEntity a ON oh.intShipFromAddressId = a.intEntityId
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Check that the location exists                                        
	SELECT @intStorageLocationId = intStorageLocationId, 
		   @intCompanyLocationSubLocationId = loc.intCompanyLocationSubLocationId, 
		   @intCompanyLocationId = l.intLocationId
	FROM tblICStorageLocation l
	INNER JOIN tblSMCompanyLocationSubLocation loc ON loc.intCompanyLocationSubLocationId = l.intSubLocationId
	WHERE l.strName = @strStorageLocationName

	--SELECT @strRawItemReceivingUnits = SettingValue
	--FROM dbo.iMake_AppSettingValue AV
	--JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey
	--WHERE S.SettingName = 'RawMaterialReceivingUnits'

	SELECT @strRawItemReceivingUnits = REPLACE(@strRawItemReceivingUnits, '''', '')

	SELECT @intLotStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = 'STAGE10'

	IF @intStorageLocationId = 0
	BEGIN
		RAISERROR ('The selected unit is not available. Please select a valid unit and continue.', 16, 1)
	END

	IF (ISNULL(@intOrderLineItemId, '') = '')
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblICItem m
				JOIN tblICCategory mt ON m.intCategoryId = mt.intCategoryId
				WHERE m.intItemId = @intItemId
					AND mt.ysnWarehouseTracked = 0
				)
		BEGIN
			--IF NOT EXISTS (
			--		SELECT *
			--		FROM tblWHOrderLineItem
			--		WHERE intOrderHeaderId = @intOrderHeaderId
			--			AND intItemId = @intItemId
			--			AND strLotAlias = @strLotCode
			--		)
			--BEGIN
			--	RAISERROR ('The lot code is invalid.', 16, 1)
			--END

			SELECT @intOrderLineItemId = i.intOrderLineItemId
			FROM tblWHOrderLineItem i
			WHERE i.intOrderHeaderId = @intOrderHeaderId
				AND i.intItemId = @intItemId
			--AND strLotAlias = @strLotCode
				AND intOrderHeaderId = @intOrderHeaderId

			IF (ISNULL(@strLotCode, '') = '')
			BEGIN
				SELECT @strLotCode = strLotAlias
				FROM tblWHOrderLineItem
				WHERE intOrderLineItemId = @intOrderLineItemId
			END
		END
		ELSE
		BEGIN
			SELECT @intOrderLineItemId = i.intOrderLineItemId
			FROM tblWHOrderLineItem i
			WHERE i.intOrderHeaderId = @intOrderHeaderId
				AND i.intItemId = @intItemId
		END
	END

	IF (ISNULL(@strLotCode, '') = '')
		AND EXISTS (
			SELECT *
			FROM tblICItem m
			JOIN tblICCategory mt ON m.intCategoryId = mt.intCategoryId
			WHERE m.intItemId = @intItemId
				AND mt.ysnWarehouseTracked = 0
			)
	BEGIN
		SELECT @strLotCode = strLotAlias
		FROM tblWHOrderLineItem
		WHERE intOrderLineItemId = @intOrderLineItemId
	END

	-- Service Request Max dblQty on one container in iStore 8/17/2010                  
	SELECT @dblFullPalletQty = intUnitsPerLayer * intLayersPerPallet, @strVendorLotNo = strSupplierLotNo
	FROM tblWHOrderLineItem
	WHERE intOrderLineItemId = @intOrderLineItemId
	
	IF @dblQty > @dblFullPalletQty
	BEGIN
		RAISERROR ('Check-In quantity cannot be more than Cases Per Pallet.  Please check order line item details for Cases Per Pallet.', 16, 1)
	END

	--If the container code in empty or null then generate a container code                                        
	IF (@strContainerNo IS NULL)
		OR (@strContainerNo = '')
	BEGIN
		WHILE (1 = 1)
		BEGIN
			EXEC dbo.uspSMGetStartingNumber 74, @strContainerNo OUTPUT
			
			SET @intContainerId = 0

			SELECT @intContainerId = c.intContainerId, @intCurrentStorageLocationId = c.intStorageLocationId
			FROM tblWHContainer c
			INNER JOIN tblICStorageLocation l ON l.intStorageLocationId = c.intStorageLocationId
			INNER JOIN tblSMCompanyLocationSubLocation loc ON loc.intCompanyLocationSubLocationId = l.intSubLocationId
			WHERE c.strContainerNo = @strContainerNo

			IF @intContainerId <= 0
				BREAK;
		END
	END

	--Check if the tblWHContainer already exists in this warehouse                                        
	SELECT @intContainerId = c.intContainerId, @intCurrentStorageLocationId = c.intStorageLocationId
	FROM tblWHContainer c
	INNER JOIN tblICStorageLocation l ON l.intStorageLocationId = c.intStorageLocationId
	INNER JOIN tblSMCompanyLocationSubLocation loc ON loc.intCompanyLocationSubLocationId = l.intSubLocationId
		--AND loc.AddressID = @intAddressId
	WHERE c.strContainerNo = @strContainerNo

	-- For Mobile application check-in                              
	IF (@intContainerId > 0)
	BEGIN
		IF NOT EXISTS (
				SELECT s.intContainerId
				FROM tblWHOrderLineItem i
				LEFT JOIN tblWHOrderManifest m ON m.intOrderLineItemId = i.intOrderLineItemId
					AND i.intOrderHeaderId = @intOrderHeaderId
				JOIN tblWHSKU s ON s.intSKUId = m.intSKUId
					AND s.intContainerId = @intContainerId
				)
		BEGIN
			SET @strErrMsg = 'The scanned container [' + @strContainerNo + '] already exists.'
			RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
		END
	END

	--IF @intContainerTypeId = 0
	--BEGIN
	--	SELECT @intContainerTypeId = lc.intContainerTypeId
	--	FROM tblWHOrderHeader h
	--	INNER JOIN tblWHOrderLineItem li ON li.intOrderHeaderId = h.intOrderHeaderId
	--		AND li.intItemId = @intItemId
	--	INNER JOIN tblICItem p ON p.intItemId = li.intItemId
	--	INNER JOIN tblWHContainer lc ON lc.strContainerNo = a.strContainerNo
	--	WHERE li.intOrderHeaderId = @intOrderHeaderId

	--	IF @intContainerTypeId = 0
	--		SELECT TOP 1 @intContainerTypeId = TypeKey
	--		FROM ContainerType
	--		WHERE IsDefault = 1
	--END

	--IF (@intContainerTypeId = 0)
	--BEGIN
	--	EXECUTE [dbo].[GetErrorMessage] 1000009, NULL, @strUserName, @strErrMsg OUTPUT

	--	RAISERROR (@strErrMsg, 16, 1)
	--END
	
	SELECT @intContainerTypeId = intContainerTypeId FROM tblWHContainerType WHERE ysnIsDefault = 1
	
	IF @intContainerId = 0
	BEGIN
		--Create the container                                        
		INSERT INTO tblWHContainer (strContainerNo, intConcurrencyId, intContainerTypeId, intStorageLocationId, intCreatedUserId, dtmCreated, intLastModifiedUserId, dtmLastModified)
		VALUES (@strContainerNo, 0, @intContainerTypeId, @intStorageLocationId, @intUserId, GETDATE(),@intUserId, GETDATE())

		SET @intContainerId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		--Update the container                                        
		UPDATE tblWHContainer
		SET strContainerNo = @strContainerNo, 
			intContainerTypeId = @intContainerTypeId, 
			intStorageLocationId = @intStorageLocationId, 
			intLastModifiedUserId = @intUserId, 
			dtmLastModified = GETDATE()
		WHERE intContainerId = @intContainerId
	END

	--If the SKU code in empty or null then generate a SKU code                                        
	IF (@strSKUNo IS NULL)
		OR (@strSKUNo = '')
	BEGIN
		WHILE (1 = 1)
		BEGIN
			EXEC dbo.uspSMGetStartingNumber 73, @strSKUNo OUTPUT
			SET @intSKUId = 0

			SELECT @intSKUId = intSKUId
			FROM tblWHSKU s
			WHERE strSKUNo = @strSKUNo

			IF @intSKUId <= 0
				BREAK;
		END
	END

	SELECT @intSKUId = intSKUId
	FROM tblWHSKU s
	INNER JOIN tblWHContainer c ON c.intContainerId = s.intContainerId
	INNER JOIN tblICStorageLocation l ON l.intStorageLocationId = c.intStorageLocationId
	WHERE strSKUNo = @strSKUNo

	SELECT @intOwnerAddressId = intOwnerAddressId
	FROM tblWHOrderHeader h
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--Get the tracking type                          
	--SELECT @intItemControlId = p.MaterialControlKey
	--FROM tblICItem p
	--WHERE p.intItemId = @intItemId

	IF @intItemControlId = 3
		SET @dtmProductionDate = GETDATE()

	IF @intSKUId = 0
	BEGIN
		IF EXISTS (
				SELECT intSKUId
				FROM tblWHSKU
				WHERE intContainerId = @intContainerId
				)
		BEGIN
			SET @strErrMsg = 'The scanned Container already exists. Please scan again.'
			RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
		END

		SELECT @intStorageLocationRestrictionId = intRestrictionId
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intStorageLocationId

		--=== --=== --=== --=== --=== --=== --=== --=== --=== --===           
		--=== Create SKU on the indicated container     --===            
		--=== UnitRestrictionKey 1 = STOCK, 5 = QUARANTINED   --===           
		--=== SKUStstusKey 1 =  STOCK, 8 = In-Transit    --===           
		--=== --=== --=== --=== --=== --=== --=== --=== --=== --===       
		--Getting tblICCategory      
		DECLARE @ysnWarehouseTracked NVARCHAR(10)

		SELECT @ysnWarehouseTracked = mt.ysnWarehouseTracked
		FROM tblICItem m
		JOIN tblICCategory mt ON m.intCategoryId = mt.intCategoryId
		WHERE m.intItemId = @intItemId

		DECLARE @dblWeightPerUnit NUMERIC(18,6)
		DECLARE @intWeightPerUnitUOMId INT

		SELECT @intUOMId = intPhysicalCountUOMId, 
			   @dblWeightPerUnit = ISNULL(dblWeightPerUnit,1), 
			   @intWeightPerUnitUOMId = ISNULL(intWeightPerUnitUOMId,1), 
			   @intUnitsPerLayer = CASE WHEN ISNULL(li.intUnitsPerLayer,0) = 0 THEN ISNULL(i.intUnitPerLayer,1) ELSE li.intUnitsPerLayer END, 
			   @intLayersPerPallet = CASE WHEN ISNULL(li.intLayersPerPallet,0) = 0 THEN ISNULL(i.intLayerPerPallet,1) ELSE li.intLayersPerPallet END
		FROM tblWHOrderLineItem li
		JOIN tblICItem i ON i.intItemId = li.intItemId 
		WHERE intOrderLineItemId = @intOrderLineItemId
		
		IF ISNULL(@intUnitsPerLayer,0) = 0 
		BEGIN
			SELECT @intUnitsPerLayer = intUnitPerLayer FROM tblICItem WHERE intItemId = @intItemId
		END
				
		IF ISNULL(@intLayersPerPallet,0) = 0 
		BEGIN
			SELECT @intLayersPerPallet = intLayerPerPallet FROM tblICItem WHERE intItemId = @intItemId
		END
		
		IF (ISNULL(@intLayersPerPallet,0) = 0) OR (ISNULL(@intLayersPerPallet,0) = 0)
		BEGIN
			RAISERROR('UNIT PER LAYER/LAYER PER PALLET NOT SET FOR THE ITEM.',16,1)
		END
		
		IF ISNULL(@intUOMId,0) IS NULL
		BEGIN
			SELECT @intUOMId = iu.intItemUOMId
			FROM tblICItem i
			JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId 
			WHERE iu.ysnStockUnit = 1 AND i.intItemId = @intItemId
		END

		INSERT INTO tblWHSKU (strSKUNo, 
							  intConcurrencyId, 
							  intSKUStatusId, 
							  strLotCode, 
							  dblQty, 
							  dtmReceiveDate, 
							  dblWeightPerUnit, 
							  intWeightPerUnitUOMId, 
							  dtmProductionDate, 
							  intItemId, 
							  intContainerId, 
							  intOwnerId, 
							  intLastModifiedUserId, 
							  dtmLastModified, 
							  intUOMId, 
							  intUnitsPerLayer, 
							  intLayersPerPallet)
							VALUES (
							  @strSKUNo,
							  0,
							  CASE 
								WHEN @intStorageLocationRestrictionId = 5
									THEN 2
								WHEN @intStorageLocationRestrictionId = 1
									THEN 1
								ELSE 1
								END, 
							  @strLotCode, 
							  @dblQty, 
							  GETDATE(),
							  ISNULL(@dblWeightPerUnit,1), 
							  ISNULL(@intWeightPerUnitUOMId,1), 
							  @dtmProductionDate, 
							  @intItemId, 
							  @intContainerId, 
							  @intOwnerAddressId, 
							  @intUserId, 
							  GETDATE(), 
							  @intUOMId, 
							  @intUnitsPerLayer, 
							  @intLayersPerPallet
			)

		SET @intSKUId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE tblWHSKU
		SET strLotCode = @strLotCode, dblQty = @dblQty, dtmReceiveDate = GETDATE(), dtmProductionDate = @dtmProductionDate, intItemId = @intItemId, intContainerId = @intContainerId, intOwnerId = @intOwnerAddressId, intLastModifiedUserId = @intUserId, dtmLastModified = GETDATE()
		WHERE intSKUId = @intSKUId
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblWHOrderManifest
			WHERE intSKUId = @intSKUId
			)
	BEGIN
		INSERT INTO tblWHOrderManifest (intOrderLineItemId,intOrderHeaderId,intConcurrencyId, strManifestItemNote, intSKUId, intLastUpdateId, dtmLastUpdateOn)
		VALUES (@intOrderLineItemId,@intOrderHeaderId, 0, '', @intSKUId, @intUserId, GETDATE())
	END
	ELSE
	BEGIN
		UPDATE tblWHOrderManifest
		SET intOrderLineItemId = @intOrderLineItemId, intSKUId = @intSKUId, intLastUpdateId = @intUserId, dtmLastUpdateOn = GETDATE()
		WHERE intSKUId = @intSKUId
	END

	--Create history record                                        
	PRINT 'EXEC WM_CreateSKUHistory @intSKUId = @intSKUId, @TaskTypeKey = 9, @strUserName = @strUserName'

	SELECT @intSKUId

	SELECT @intOrderStatusId = intOrderStatusId
	FROM tblWHOrderStatus
	WHERE strOrderStatus = 'CHECK-IN'

	UPDATE tblWHOrderHeader
	SET intOrderStatusId = @intOrderStatusId
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Create lot in iMake for lineitem.        
	--DECLARE @SettingValue NVARCHAR(10)

	--SELECT @SettingValue = SettingValue
	--FROM iMake_AppSettingValue
	--WHERE SettingKey = (
	--		SELECT SettingKey
	--		FROM iMake_AppSetting
	--		WHERE SettingName = 'AllowCreateSKU/tblWHContainer'
	--		)
	--	AND intCompanyLocationId = @intCompanyLocationId

	--DECLARE @MaterialTypeName NVARCHAR(50)

	--SELECT @MaterialTypeName = mt.MaterialTypeName
	--FROM tblICItem m
	--JOIN tblICCategory mt ON m.intCategoryId = mt.intCategoryId
	--WHERE m.intItemId = @intItemId

	--DECLARE @OrderTypeKey INT, @InternalCode NVARCHAR(50)

	--SELECT @OrderTypeKey = OrderTypeKey
	--FROM tblWHOrderHeader
	--WHERE intOrderHeaderId = @intOrderHeaderId

	--SELECT @InternalCode = InternalCode
	--FROM dbo.WM_OrderType
	--WHERE TYPEKey = @OrderTypeKey

	--IF @ysnLotCreate = 1
	--	AND @SettingValue = 'True'
	--	AND EXISTS (
	--		SELECT *
	--		FROM tblICCategory
	--		WHERE MaterialTypeName = @MaterialTypeName
	--			AND InWarehouseTransactionAllowed = 0
	--		)
	--	AND @InternalCode = 'PO'
	--BEGIN
	--	DECLARE @ContractLineItemKey INT

	--	SELECT @dblPhysicalCount = @dblQty, @intPhysicalCountUOMId = intPhysicalCountUOMId, @dblQuantity = dblQty, @dblConversionFactor = weightperunit, @ContractLineItemKey = ContractLineItemKey, @dtmManufactureDate = dtmProductionDate
	--	FROM tblWHOrderLineItem
	--	WHERE intOrderLineItemId = @intOrderLineItemId

	--	SELECT @intLotStatus = LotstatusMask
	--	FROM LotStatus
	--	WHERE SecondaryStatusCode = 'QUARANTINED'

	--	IF ISNULL(@strLotCode, '') = ''
	--	BEGIN
	--		SELECT @strLotAlias = strLotAlias
	--		FROM tblWHOrderLineItem
	--		WHERE intOrderLineItemId = @intOrderLineItemId
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT @strLotAlias = @strLotCode
	--	END

	--	SET @dtmManufactureDate = @dtmManufactureDate

	--	--Expiry date calculation        
	--	SELECT @intLifeTime = LifeTime, @intLifeTimeDatePartId = LifeTimeDatePartKey
	--	FROM tblICItem
	--	WHERE intItemId = @intItemId

	--	SELECT @strAbbreviations = Abbreviations
	--	FROM dbo.iMake_Datepart
	--	WHERE DatepartKey = @intLifeTimeDatePartId

	--	SELECT @ysnLifetimeUnitMonthEndOfMonth = SettingValue
	--	FROM dbo.iMake_AppSetting S
	--	JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey = SV.SettingKey
	--	WHERE SettingName = 'Lifetime-UnitMonth-EndofMonth'

	--	SET @ysnCreateParentLot = 'True'

	--	SELECT @ysnCreateParentLot = AV.SettingValue
	--	FROM iMake_Appsetting A
	--	JOIN iMake_AppsettingValue AV ON A.SettingKey = AV.SettingKey
	--	WHERE A.SettingName = 'IsCreateParentLot'

	--	IF @strAbbreviations = 'yy'
	--		SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmManufactureDate)
	--	ELSE IF @strAbbreviations = 'mm'
	--		SET @dtmExpiryDate = CASE 
	--				WHEN @ysnLifetimeUnitMonthEndOfMonth = 1
	--					THEN DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, @dtmManufactureDate)) + 1, 0))
	--				ELSE DateAdd(mm, @intLifeTime, @dtmManufactureDate)
	--				END
	--	ELSE IF @strAbbreviations = 'dd'
	--		SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, @dtmManufactureDate)
	--	ELSE IF @strAbbreviations = 'hh'
	--		SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, @dtmManufactureDate)
	--	ELSE IF @strAbbreviations = 'mi'
	--		SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, @dtmManufactureDate)

	--	SELECT @intStorageLocationId = unitkey, @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
	--	FROM tblICStorageLocation
	--	WHERE unitName = @strDefaultStorageLocationName
	--		AND intCompanyLocationId = @intCompanyLocationId

	--	IF (
	--			SELECT count(*)
	--			FROM tblWHOrderManifest
	--			WHERE OrderLineItemkey = @intOrderLineItemId
	--			) = 1
	--	BEGIN
	--		IF NOT EXISTS (
	--				SELECT 1
	--				FROM ParentLot
	--				WHERE intItemId = @intItemId
	--					AND intCompanyLocationId = @intCompanyLocationId
	--				)
	--		BEGIN
	--			EXEC Pattern_GenerateID @intItemId, @intCompanyLocationId, @intCompanyLocationSubLocationId, @intStorageLocationId, 0, 0, @strParentLotNo OUTPUT, 0, 'Parent Lot ID Pattern'
	--		END
	--		ELSE
	--			SELECT TOP 1 @strParentLotNo = Parentlotid
	--			FROM Parentlot
	--			WHERE intItemId = @intItemId
	--				AND Factorykey = @intCompanyLocationId

	--		DECLARE @StandardUOMKey INT

	--		SELECT @StandardUOMKey = StandardUOMKey
	--		FROM tblICItem
	--		WHERE intItemId = @intItemId

	--		EXEC Pattern_GenerateID @intItemId, @intCompanyLocationId, @intCompanyLocationSubLocationId, @intStorageLocationId, 0, 0, @strLotNo OUTPUT

	--		EXEC Lot_Create @strLotNo, @strUserName, @intItemId, @intCompanyLocationId, @intCompanyLocationSubLocationId, @dblPhysicalCount, @intPhysicalCountUOMId, @dblConversionFactor, @intLotStatus, @dtmCurrentDateTime, @dtmCurrentDateTime, @dtmExpiryDate, NULL, @intLotStorageLocationId, @strVendorNo, @strVendorLotNo, 0, NULL, NULL, NULL, NULL, NULL, @strLotAlias, @strParentLotNo, '', @ysnSubLotAllowed

	--		DECLARE @QueuedQty NUMERIC(18, 6)

	--		SELECT @intLotId = Lotkey, @dtmProductionDate = CreateDate, @QueuedQty = QueuedQty
	--		FROM Lot
	--		WHERE LotID = @strLotNo
	--			AND Unitkey = @intLotStorageLocationId

	--		DECLARE @Grade NVARCHAR(100), @Receipt_Origin NVARCHAR(100), @Receipt_GardenName NVARCHAR(100), @Receipt_WeightPerUnit DECIMAL(24, 10), @Receipt_WeightPerUnitUOMKey INT, @NetWeight DECIMAL(24, 10), @TruckKey INT, @IsWeightCertified BIT, @CustOrderNo NVARCHAR(50), @SealNo NVARCHAR(50), @CarrierID NVARCHAR(max), @UnLoadedBy NVARCHAR(100), @dtmReceiveDate DATETIME, @Note NVARCHAR(250), @PORefNo NVARCHAR(50)

	--		SELECT TOP 1 @Grade = rl.Grade, @Receipt_Origin = pc.Country, @Receipt_GardenName = rl.Garden, @Receipt_WeightPerUnit = rl.dblWeightPerUnit, @Receipt_WeightPerUnitUOMKey = rl.WeightPerUnitUOMKey, @NetWeight = rl.NetWeight, @IsWeightCertified = IsWeightCertified, @Note = LineItemNote
	--		FROM tblWHOrderLineItem rl
	--		LEFT JOIN PAP_CountryCode pc ON pc.CountryCodeID = rl.OriginKey
	--		WHERE intOrderLineItemId = @intOrderLineItemId

	--		SELECT @TruckKey = t.TruckKey, @CustOrderNo = CustOrderNo, @SealNo = t.SealNo, @UnLoadedBy = t.LastUpdateBy, @dtmReceiveDate = t.LastUpdateOn
	--		FROM tblWHOrderHeader oh
	--		JOIN WM_TruckOrder wt ON wt.intOrderHeaderId = oh.intOrderHeaderId
	--		JOIN WM_Truck t ON wt.TruckKey = t.TruckKey
	--		WHERE oh.intOrderHeaderId = @intOrderHeaderId

	--		SELECT TOP 1 @CarrierID = a.AddressTitle
	--		FROM WM_Truck t
	--		JOIN PAP_Address a ON t.CarrierAddressID = a.AddressID
	--		WHERE t.TruckKey = @TruckKey

	--		SELECT @PORefNo = PONumber
	--		FROM WM_OrderHeaderContainerMapping
	--		WHERE intOrderHeaderId = @intOrderHeaderId

	--		UPDATE LotExtendedproperty
	--		SET IsWeightCertified = @IsWeightCertified, CustReceiptNo = @CustOrderNo, ReceivedFrom = @strVendorNo, Receipt_VendorID = @strVendorNo, Receipt_BOL = @strTaskNo, IsReceiveCompleted = 1, SealNo = @SealNo, CarrierID = @CarrierID, UnLoadedBy = @UnLoadedBy, ReceivedDate = @dtmReceiveDate, Note = @Note, PORefNo = @PORefNo, Grade = @Grade, Receipt_Origin = @Receipt_Origin, Receipt_GardenName = @Receipt_GardenName, Receipt_WeightPerUnit = @Receipt_WeightPerUnit, NetWeight = @NetWeight, GrossWeight = @NetWeight, TruckKey = @TruckKey, ManifestQuantity = @QueuedQty
	--		WHERE LotKey = @LotKey

	--		UPDATE tblWHSKU
	--		SET Lotkey = @intLotId, dtmProductionDate = @dtmProductionDate
	--		WHERE intSKUId = @intSKUId

	--		UPDATE tblWHOrderManifest
	--		SET Lotkey = @intLotId
	--		WHERE OrderLineItemkey = @intOrderLineItemId
	--			AND Lotkey IS NULL
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT TOP 1 @intLotId = Lotkey
	--		FROM tblWHOrderManifest
	--		WHERE OrderLineItemkey = @intOrderLineItemId
	--			AND Lotkey IS NOT NULL

	--		SELECT @dtmProductionDate = CreateDate
	--		FROM Lot
	--		WHERE LotKey = @intLotId

	--		UPDATE tblWHSKU
	--		SET Lotkey = @intLotId, dtmProductionDate = @dtmProductionDate
	--		WHERE intSKUId = @intSKUId

	--		UPDATE tblWHOrderManifest
	--		SET Lotkey = @intLotId
	--		WHERE OrderLineItemkey = @intOrderLineItemId
	--			AND Lotkey IS NULL

	--		DECLARE @LotQty NUMERIC(18, 6), @LotUOMKey INT, @SKUQty NUMERIC(18, 6)
	--		DECLARE @IsNegativeQtyAllowed AS BIT

	--		SELECT @IsNegativeQtyAllowed = SettingValue
	--		FROM dbo.iMake_AppSettingValue AV
	--		JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey
	--		WHERE S.SettingName = 'IsNegativeQtyAllowed'

	--		IF @LotKey > 0
	--		BEGIN
	--			SELECT @dblWeightPerUnit = Receipt_WeightPerUnit
	--			FROM LotExtendedProperty
	--			WHERE LotKey = @intLotId

	--			SELECT @LotQty = QueuedQty, @strLotNo = LotID, @LotUOMKey = PrimaryUOMKey
	--			FROM Lot
	--			WHERE LotKey = @intLotId

	--			SELECT @SKUQty = SUM(CASE 
	--						WHEN @LotUOMKey = intUOMId
	--							THEN dblQty
	--						ELSE dblQty * @dblWeightPerUnit
	--						END)
	--			FROM tblWHSKU
	--			WHERE LotKey = @intLotId

	--			IF @SKUQty <> @LotQty
	--			BEGIN
	--				--@intLotId,@SKUQty, @LotUOMKey, @strUserName,'', 'SKU quantity adjusted',@intTransactionId output,@ysnValidateSKU, 1   
	--				EXEC dbo.Lot_AdjustQueuedQty @LotKey = @intLotId, @NewQueuedQty = @SKUQty, @NewQueuedUOMKey = @LotUOMKey, @strUserName = @strUserName, @ReasonCode = '', @Comment = 'SKU quantity adjusted/deleted', @intTransactionId = @intTransactionId OUTPUT, @ysnValidateSKU = @ysnValidateSKU, @IsNegativeQtyAllowed = @IsNegativeQtyAllowed, @ReceiveInProgress = 1
	--			END
	--		END
	--	END
	--END

	--IF EXISTS (
	--		SELECT *
	--		FROM tblICCategory
	--		WHERE MaterialTypeName = @MaterialTypeName
	--			AND InWarehouseTransactionAllowed = 1
	--		)
	--BEGIN
	--	SELECT @LotKey = LotKey
	--	FROM tblWHSKU
	--	WHERE intSKUId = @intSKUId

	--	IF @LotKey > 0
	--	BEGIN
	--		SELECT @dblWeightPerUnit = Receipt_WeightPerUnit
	--		FROM LotExtendedProperty
	--		WHERE LotKey = @intLotId

	--		SELECT @LotQty = QueuedQty, @strLotNo = LotID, @LotUOMKey = PrimaryUOMKey
	--		FROM Lot
	--		WHERE LotKey = @intLotId

	--		SELECT @SKUQty = SUM(CASE 
	--					WHEN @LotUOMKey = intUOMId
	--						THEN dblQty
	--					ELSE dblQty * @dblWeightPerUnit
	--					END)
	--		FROM tblWHSKU
	--		WHERE LotKey = @intLotId

	--		IF @SKUQty <> @LotQty
	--		BEGIN
	--			--@intLotId,@SKUQty, @LotUOMKey, @strUserName,'', 'SKU quantity adjusted',@intTransactionId output,@ysnValidateSKU, 1   
	--			EXEC dbo.Lot_AdjustQueuedQty @LotKey = @intLotId, @NewQueuedQty = @SKUQty, @NewQueuedUOMKey = @LotUOMKey, @strUserName = @strUserName, @ReasonCode = '', @Comment = 'SKU quantity adjusted/deleted', @intTransactionId = @intTransactionId OUTPUT, @ysnValidateSKU = @ysnValidateSKU, @IsNegativeQtyAllowed = @IsNegativeQtyAllowed, @ReceiveInProgress = 1
	--		END
	--	END
	--END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF xact_State() <> 0
		ROLLBACK TRANSACTION

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCheckInSKU: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH