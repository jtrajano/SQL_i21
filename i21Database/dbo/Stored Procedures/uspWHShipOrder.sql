CREATE PROCEDURE [dbo].[uspWHShipOrder]
				@intOrderHeaderId INT, 
				@strUserName NVARCHAR(32), 
				@intCreateTruckId INT OUT, 
				@intWorkOrderId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strErrMsg NVARCHAR(MAX)

	SET @strErrMsg = ''

	DECLARE @intNewTruckId INT
	DECLARE @intTruckId INT
	DECLARE @intOrderTypeId INT
	DECLARE @strBOLText NVARCHAR(64)
	DECLARE @strBOLNo NVARCHAR(32)
	DECLARE @intNewOrderHeaderId INT
	DECLARE @strSequenceCode NVARCHAR(4)
	DECLARE @strSequenceText NVARCHAR(32)
	DECLARE @intStagingLocationId INT
	DECLARE @intShipToAddressId INT
	DECLARE @strShipFromPhoneNo NVARCHAR(32)
	DECLARE @strShipToPhoneNo NVARCHAR(32)
	DECLARE @strCarrierContact NVARCHAR(128)
	DECLARE @intSKUId INT
	DECLARE @intSequenceNumber INT
	DECLARE @strEDI945 NVARCHAR(255)
	DECLARE @intComapnyLocationId INT
	DECLARE @intCompanyLocationDestId INT
	DECLARE @intCompantLocationSubLocationId INT
	DECLARE @intOrderLineItemId INT
	DECLARE @intWHCompanyLocationId INT
	DECLARE @intLocalTran TINYINT
	DECLARE @strLotNumber AS NVARCHAR(30)
	DECLARE @intUOMId AS INT
	DECLARE @intSKUUOMId AS INT
	DECLARE @dblSKUQty AS DECIMAL(24, 10)
	DECLARE @strReasonCode AS NVARCHAR(Max)
	DECLARE @intTransactionId INT
	DECLARE @dblLotQty AS DECIMAL(24, 10)
	DECLARE @dblAdjustQty AS DECIMAL(24, 10)
	DECLARE @intLotId INT
	DECLARE @strShipToAddressTitle NVARCHAR(64)
	DECLARE @intWHFGLotStatus INT
	DECLARE @dtmShipDate DATETIME
	DECLARE @intItemId INT
	DECLARE @intContainerId INT
	DECLARE @ysnLifetimeUnitMonthEndofMonth BIT
	DECLARE @intEntityUserId INT

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION
		
	SELECT @intEntityUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName

	SELECT @intComapnyLocationId = ISNULL(a.intCompanyLocationId, 0)
	FROM tblWHOrderHeader h
	INNER JOIN tblSMCompanyLocation a ON a.intCompanyLocationId = h.intShipFromAddressId
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--get the BOL description and the order type id                              
	SELECT @strBOLNo = strBOLNo, 
		   @strBOLText = strBOLNo + 'SHIPPED ORDER ' + strBOLNo, 
		   @intOrderTypeId = intOrderTypeId, 
		   @intShipToAddressId = intShipToAddressId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	DECLARE @strOrderType NVARCHAR(50)

	SELECT @strOrderType = strInternalCode
	FROM dbo.tblWHOrderType
	WHERE intOrderTypeId = @intOrderTypeId

	--Get the Shipdate from Truck   
	SELECT @dtmShipDate = t.dtmShipDate
	FROM tblWHTruck t
	JOIN tblWHOrderHeader wt ON wt.intTruckId = t.intTruckId
		AND wt.intOrderHeaderId = @intOrderHeaderId

	--Update the ship date for the truck if Shipdate is a future date.      
	UPDATE tblWHOrderHeader
	SET dtmShipDate = @dtmShipDate
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Update the ship date in the order header                              
	UPDATE tblWHOrderHeader
	SET intOrderStatusId = 10
	WHERE intOrderHeaderId = @intOrderHeaderId;

	IF @strOrderType NOT IN ('WO','PS','SS')
	BEGIN
		--Update the SKU status                              
		UPDATE tblWHSKU
		SET intSKUStatusId = 5, 
			intLastModifiedUserId = @intEntityUserId, 
			dtmLastModified = GETUTCDATE(), 
			strReasonCode = '', 
			strComment = ''
		WHERE EXISTS (
				SELECT *
				FROM tblWHOrderHeader h
				INNER JOIN tblWHOrderLineItem i ON i.intOrderHeaderId = h.intOrderHeaderId
				INNER JOIN tblWHOrderManifest m ON m.intOrderLineItemId = i.intOrderLineItemId
					AND tblWHSKU.intSKUId = m.intSKUId
				WHERE h.intOrderHeaderId = @intOrderHeaderId
				);
	END
	
	--============
	-- EDI SP HERE 
	--============
	--Export the EDI 945 information   
	----IF @strOrderType NOT IN ('WO','PS','SS')
	----BEGIN
	----	IF @strEDI945 = 'True'
	----		EXEC iMake_EDI.dbo.EDI945 @strBOLNo = @strBOLNo
	----END

	--Get the ship from phone number              
	SELECT TOP 1 @strShipFromPhoneNo = a.strPhone
	FROM tblWHOrderHeader h
	INNER JOIN tblSMCompanyLocation a ON a.intCompanyLocationId = h.intShipFromAddressId
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--Get the ship to phone number              
	SELECT TOP 1 @strShipFromPhoneNo = a.strPhone
	FROM tblWHOrderHeader h
	INNER JOIN tblEMEntity a ON a.intEntityId = h.intShipToAddressId
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--Get the carrier contact              
	SELECT TOP 1 @strCarrierContact = a.strName + ' ' + a.strPhone, 
				 @intTruckId = o.intTruckId
	FROM tblWHOrderHeader h
	INNER JOIN tblWHOrderHeader o ON o.intOrderHeaderId = h.intOrderHeaderId
	INNER JOIN tblWHTruck t ON t.intTruckId = o.intTruckId
	INNER JOIN tblEMEntity a ON a.intEntityId = t.intCarrierAddressID
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	DECLARE @intLocAddress AS INT

	SET @intLocAddress = 0

	SELECT @intLocAddress = ISNULL(intCompanyLocationId, 0)
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intShipToAddressId

	IF @strOrderType = 'WT'
		AND @intLocAddress > 0 --warehouse transfer                              
	BEGIN
		SELECT @intCompanyLocationDestId = ISNULL(a.intCompanyLocationId, 0)
		FROM tblWHOrderHeader h
		INNER JOIN tblSMCompanyLocation a ON a.intCompanyLocationId = h.intShipToAddressId
		WHERE h.intOrderHeaderId = @intOrderHeaderId;

		DECLARE @strAllowCreateSKUContainer NVARCHAR(50)

		--SELECT @strAllowCreateSKUContainer = SettingValue
		--FROM dbo.iMake_AppSetting S
		--INNER JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey = SV.SettingKey
		--WHERE SettingName = 'AllowCreateSKU/Container'
		--	AND ISNULL(intCompanyLocationId, @intCompanyLocationDestId) = @intCompanyLocationDestId
		IF @strAllowCreateSKUContainer = 'False'
			AND EXISTS (
				SELECT 1
				FROM tblWHOrderLineItem L
				INNER JOIN dbo.tblWHOrderManifest M ON M.intOrderLineItemId = L.intOrderLineItemId
				INNER JOIN dbo.tblICItem M1 ON M1.intItemId = L.intItemId
				INNER JOIN dbo.tblICCategory MT ON MT.intCategoryId = M1.intCategoryId
					AND MT.strCategoryCode <> 'Finished Goods'
				WHERE L.intOrderHeaderId = @intOrderHeaderId
				)
		BEGIN
			--EXEC Lot_ReserveRelease @strBOLNo, 4
			PRINT 'SHIP LOT'
			--EXEC iMake_WarehouseTransfer_Outbound @intOrderHeaderId, @strUserName
		END
		ELSE
		BEGIN
			--Get a new BOL code          
			--SELECT @intCompanyLocationDestId = ISNULL(l.intCompanyLocationId, 0)
			--FROM tblWHOrderHeader h
			--INNER JOIN tblEMEntity a ON a.intEntityId = h.intShipToAddressId
			--LEFT OUTER JOIN tblSMCompanyLocationSubLocation l ON l.intCompanyLocationId = a.intEntityId
			--WHERE h.intOrderHeaderId = @intOrderHeaderId;

			----EXEC GEN_GetNextSequence @strSequenceCode, @intSequenceNumber OUT, @strSequenceText out                              
			----EXEC dbo.Pattern_GenerateID @intItemId = 0, @intComapnyLocationId = @intCompanyLocationDestId, @intCompantLocationSubLocationId = 0, @intStorageLocationId = 0, @CellKey = 0, @UserKey = 0, @PatternString = @strSequenceText OUTPUT, @IsProposed = 0, @PatternSettingName = 'WHPatternOrder', @WMOrderTypeKey = 1

			----Get the default staging location from the ship to address record       
			--SET @intStagingLocationId = 0

			--SELECT @intStagingLocationId = ISNULL(InboundStagingID, 0), @strShipToAddressTitle = AddressTitle
			--FROM PAP_Address
			--WHERE AddressID = @intStagingLocationId

			--IF @intStagingLocationId = 0
			--BEGIN
			--	RAISERROR ('Destination warehouse''s, staging unit not configured.', 16, 1)
			--END

			--Create a new inbound order based on the outbound warehouse transfer                              
			INSERT INTO tblWHOrderHeader (intOrderStatusId, intOrderTypeId, intOrderDirectionId, strBOLNo, strCustOrderNo, strReferenceNo, intOwnerAddressId, intStagingLocationId, strComment, dtmRAD, dtmShipDate, intFreightTermId, intChep, intShipFromAddressId, intShipToAddressId, intPallets, intCreatedById, dtmCreatedOn, intLastUpdateById, dtmLastUpdateOn, strProNo)
			SELECT 4,--IN_TRANSIT                              
				intOrderTypeId, 1,--INBOUND                              
				@strSequenceText,
				--The new BOL number                           
				strCustOrderNo, strBOLNo,
				--Reference Number becomes the OUTBOUND BOL number            
				intOwnerAddressId, @intStagingLocationId, strComment, dtmRAD, dtmShipDate, intFreightTermId, intChep, intShipFromAddressId, @intShipToAddressId, intPallets, intCreatedById, dtmCreatedOn, intLastUpdateById, dtmLastUpdateOn, strProNo
			FROM tblWHOrderHeader h
			WHERE h.intOrderHeaderId = @intOrderHeaderId

			SET @intNewOrderHeaderId = SCOPE_IDENTITY()
			--- Create New InBound Truck                          
			SET @intNewTruckId = 0

			SELECT @intNewTruckId = intTruckId
			FROM tblWHTruck
			WHERE intTruckId = @intCreateTruckId

			IF @intNewTruckId = 0
			BEGIN
				INSERT INTO tblWHTruck (intConcurrencyId, strTruckNo, intAddressID, intDirectionId, strMasterBOLNo, intCarrierAddressID, dtmScheduledDate, dtmStartLoadTime, dtmEndLoadTime, dtmShipDate, strDriverInfo, intDockDoorLocationId, strVehicleNo, strSealNo, dblCost, intLastModifiedUserId, dtmLastModified)
				SELECT 1, strTruckNo + '_IN' + CONVERT(NVARCHAR, @intNewOrderHeaderId), @intStagingLocationId, 1, strMasterBOLNo, intCarrierAddressID, dtmScheduledDate, dtmStartLoadTime, dtmEndLoadTime, dtmShipDate, strDriverInfo, intDockDoorLocationId, strVehicleNo, strSealNo, dblCost, intLastModifiedUserId, dtmLastModified
				FROM tblWHTruck
				WHERE intTruckId = @intTruckId

				SET @intCreateTruckId = SCOPE_IDENTITY()

				UPDATE tblWHOrderHeader
				SET intTruckId = @intCreateTruckId
				WHERE intOrderHeaderId = @intNewOrderHeaderId
			END
			ELSE
			BEGIN
				UPDATE tblWHOrderHeader
				SET intTruckId = @intCreateTruckId
				WHERE intOrderHeaderId = @intNewOrderHeaderId
			END

			--Create the order line items                              
			INSERT INTO tblWHOrderLineItem (intOrderHeaderId, intConcurrencyId, intItemId, strLineItemNote, dblQty, intReceiptQtyUOMId, dblPhysicalCount, intPhysicalCountUOMId, dblWeightPerUnit, ysnIsWeightCertified, intOriginId, intUnitsPerLayer, intLayersPerPallet, dtmProductionDate, intLastUpdateId, dtmLastUpdateOn)
			SELECT @intNewOrderHeaderId intOrderHeaderId, 0, li.intItemId, li.strLineItemNote, CAST(ISNULL(SUM(s.dblQty), 0) AS DECIMAL(10, 2)) [PickedQty], li.intReceiptQtyUOMId, li.dblPhysicalCount, li.intPhysicalCountUOMId, li.dblWeightPerUnit, li.ysnIsWeightCertified, li.intOriginId, li.intUnitsPerLayer, li.intLayersPerPallet, li.dtmProductionDate, li.intLastUpdateId, li.dtmLastUpdateOn
			FROM tblWHOrderLineItem li
			JOIN tblWHOrderManifest m ON m.intOrderLineItemId = li.intOrderLineItemId
			JOIN tblWHSKU s ON s.intItemId = li.intItemId
				AND s.intSKUId = m.intSKUId
			WHERE li.intOrderHeaderId = @intOrderHeaderId
			GROUP BY li.intOrderLineItemId, li.intItemId, li.strLineItemNote, li.dblQty, li.intReceiptQtyUOMId, li.dblPhysicalCount, li.intPhysicalCountUOMId, li.dblWeightPerUnit, li.ysnIsWeightCertified, li.intOriginId, li.intUnitsPerLayer, li.intLayersPerPallet, li.dtmProductionDate, li.intLastUpdateId, li.dtmLastUpdateOn

			---- Update the SKU status as 'STOCK' if it is Warehouse Transfer (iStore)    
			UPDATE tblWHSKU
			SET intSKUStatusId = 1 -- STOCK  
				, intLastModifiedUserId = @intEntityUserId, dtmLastModified = GETUTCDATE()
			WHERE intSKUId IN (
					SELECT s.intSKUId
					FROM tblWHSKU s
					JOIN tblWHTask t ON t.intSKUId = s.intSKUId
					WHERE t.intOrderHeaderId = @intOrderHeaderId
					)

			INSERT INTO tblWHOrderManifest (intOrderLineItemId,intOrderHeaderId, intConcurrencyId, strManifestItemNote, intSKUId, intLastUpdateId, dtmLastUpdateOn)
			SELECT l2.intOrderLineItemId,@intOrderHeaderId, 0, m1.strManifestItemNote, m1.intSKUId, 'dbo', GETUTCDATE()
			FROM tblWHOrderManifest m1
			JOIN tblWHOrderLineItem l1 ON m1.intOrderLineItemId = l1.intOrderLineItemId
				AND l1.intOrderHeaderId = @intOrderHeaderId
			JOIN tblWHSKU s ON m1.intSKUId = s.intSKUId
			JOIN tblWHOrderLineItem l2 ON l2.intOrderHeaderId = @intNewOrderHeaderId
				AND l2.intItemId = s.intItemId

			DECLARE CUR_Container CURSOR LOCAL
			FOR
			SELECT intContainerId
			FROM tblWHSKU s
			JOIN tblWHOrderManifest m ON s.intSKUId = m.intSKUId
			JOIN tblWHOrderLineItem li ON li.intOrderLineItemId = m.intOrderLineItemId
				AND li.intOrderHeaderId = @intNewOrderHeaderId

			OPEN CUR_Container

			FETCH NEXT
			FROM CUR_Container
			INTO @intContainerId

			WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE tblWHContainer
				SET intStorageLocationId = @intStagingLocationId
				WHERE intContainerId = @intContainerId

				FETCH NEXT
				FROM CUR_Container
				INTO @intContainerId
			END

			CLOSE CUR_Container

			DEALLOCATE CUR_Container

			--Delete the order manifest                              
			DELETE
			FROM tblWHOrderManifest
			WHERE EXISTS (
					SELECT *
					FROM tblWHOrderHeader h
					INNER JOIN tblWHOrderLineItem i ON i.intOrderHeaderId = h.intOrderHeaderId
					WHERE h.intOrderHeaderId = @intOrderHeaderId
						AND tblWHOrderManifest.intOrderLineItemId = i.intOrderLineItemId
					)
		END
	END
	ELSE IF @strOrderType = 'SO'
		--Delete the SKUs if this is not a warehouse transfer                              
	BEGIN
		DECLARE @MaterialKey1 INT

		DECLARE sku_cursor CURSOR LOCAL FAST_FORWARD
		FOR
		SELECT s.intSKUId
		FROM tblWHSKU s
		INNER JOIN tblWHTask t ON t.intSKUId = s.intSKUId
		WHERE t.intOrderHeaderId = @intOrderHeaderId
			AND intSKUStatusId = 5

		OPEN sku_cursor

		FETCH NEXT
		FROM sku_cursor
		INTO @intSKUId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF EXISTS (
					SELECT intLotId
					FROM tblICLot
					WHERE intLotId IN (
							SELECT intLotId
							FROM tblWHSKU
							WHERE intSKUId = @intSKUId
							)
					)
			BEGIN
				SET @intWHFGLotStatus = 0
				SET @MaterialKey1 = NULL

				SELECT @dblSKUQty = dblQty, @intLotId = intLotId, @intSKUUOMId = intUOMId, @MaterialKey1 = intItemId
				FROM tblWHSKU
				WHERE intSKUId = @intSKUId

				SELECT @strLotNumber = strLotNumber, @intUOMId = intItemUOMId, @dblLotQty = dblQty
				FROM tblICLot
				WHERE intLotId = @intLotId

				SELECT @intWHFGLotStatus = intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = 'IN_WAREHOUSE'

				-- Adjust the lot quantity  
				--SET @dblAdjustQty=@dblLotQty-@dblSKUQty  
				--EXEC dbo.Lot_SetLotStatus @intLotId = @intLotId, @NewLotStatusMask = 1, @strUserName = @strUserName, @IsStatusAllowedToChange = 1
				IF @intSKUUOMId <> @intUOMId
				BEGIN
					SELECT @dblSKUQty = (dblQty * dblWeightPerUnit)
					FROM tblWHSKU
					WHERE intSKUId = @intSKUId
				END

				--EXEC dbo.Lot_Ship @intLotId = @intLotId, @ShipQty = @dblSKUQty, @ShipUOMKey = @intUOMId, @CustomerName = @strShipToAddressTitle, @strUserName = @strUserName, @EntityID = NULL, @EntityTypeKey = 2, @IsForced = 1
				--EXEC dbo.Lot_AdjustQueuedQty @strLotNumber, @dblAdjustQty, @intUOMId, @strUserName, 'WAREHOUSE SHIPMENT', 'SKU shipped from the warehouse', @intTransactionId output        
				--IF @dblLotQty <> @dblSKUQty
				--	AND EXISTS (
				--		SELECT *
				--		FROM tblICItem M
				--		JOIN tblICCategory MT ON MT.intCategoryId = M.intCategoryId
				--		WHERE MT.strCategoryCode = 'Finished Goods'
				--			AND M.intItemId = @MaterialKey1
				--		)
				--BEGIN
				--	EXEC dbo.Lot_SetLotStatus @intLotId = @intLotId, @NewLotStatusMask = @intWHFGLotStatus, @strUserName = @strUserName, @IsStatusAllowedToChange = 1
				--END
			END

			EXEC uspWHDeleteSKUForWarehouse @intSKUId = @intSKUId, @strUserName = @strUserName

			FETCH NEXT
			FROM sku_cursor
			INTO @intSKUId
		END

		CLOSE sku_cursor

		DEALLOCATE sku_cursor
	END

	--Delete the order line items                              
	DELETE
	FROM tblWHOrderLineItem
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Delete the order                              
	DELETE
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	--EXEC Lot_ReserveRelease @strBOLNo, 4
	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF CURSOR_STATUS('local', 'sku_cursor') > - 1
		CLOSE sku_cursor;

	IF CURSOR_STATUS('local', 'sku_cursor') > - 2
		DEALLOCATE sku_cursor;

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg + ' Source: ' + 'uspWHShipOrder'

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH