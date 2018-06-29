CREATE PROCEDURE [dbo].[uspWHCheckInSKU] 
			@intOrderHeaderId INT, 
			@strUserName NVARCHAR(32), 
			@intAddressId INT, 
			@strContainerNo NVARCHAR(32),
			@intContainerTypeId INT, 
			@strStorageLocationName NVARCHAR(32), 
			@strSKUNo NVARCHAR(32), 
			@dblQty NUMERIC(18,6), 
			@strLotCode NVARCHAR(32), 
			@dtmProductionDate DATETIME, 
			@intItemId INT, 
			@intContainerId INT = 0 OUT, 
			@intOrderLineItemId INT = 0, 
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
			IF NOT EXISTS (
					SELECT *
					FROM tblWHOrderLineItem
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intItemId = @intItemId
						AND strLotAlias = @strLotCode
					)
			BEGIN
				RAISERROR ('The lot code is invalid.', 16, 1)
			END

			SELECT @intOrderLineItemId = i.intOrderLineItemId
			FROM tblWHOrderLineItem i
			WHERE i.intOrderHeaderId = @intOrderHeaderId
				AND i.intItemId = @intItemId
				AND strLotAlias = @strLotCode
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
				AND intOrderHeaderId = @intOrderHeaderId
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
							  @dblWeightPerUnit, 
							  @intWeightPerUnitUOMId, 
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
