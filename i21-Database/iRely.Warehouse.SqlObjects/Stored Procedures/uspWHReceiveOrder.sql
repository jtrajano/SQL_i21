CREATE PROCEDURE [dbo].[uspWHReceiveOrder]
				@intOrderHeaderId INT, 
				@strUserName NVARCHAR(32), 
				@intCompanyLocationId INT = NULL, 
				@strCompanyId NVARCHAR(3) = NULL, 
				@strWarehouseId NVARCHAR(6) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRANSACTION

	DECLARE @strErrMsg NVARCHAR(MAX)

	SET @strErrMsg = ''

	DECLARE @intTruckId INT
	DECLARE @intBadManifestRecordCount INT
	DECLARE @intManifestRecordCount INT
	DECLARE @intSerialNoBadManifestRecordCount INT
	DECLARE @intShipFromAddressId INT
	DECLARE @intShipToAddressId INT
	DECLARE @strShipFromPhoneNo NVARCHAR(32)
	DECLARE @strShipToPhoneNo NVARCHAR(32)
	DECLARE @strCarrierContact NVARCHAR(128)
	DECLARE @strEDI944 NVARCHAR(255)
	DECLARE @strLotTrackingBySerialNo NVARCHAR(10)
	DECLARE @ysnLifeTimeUnitMonthEndOfMonth BIT
	DECLARE @intContractContainerId INT
	DECLARE @intDecimalPlaces INT
	DECLARE @ysniProcessERPFeedEnabled BIT
	DECLARE @ysnQAApprove BIT
	DECLARE @intStatusId INT
	DECLARE @strContractNo NVARCHAR(64)
	DECLARE @intContractLineItemId INT
	DECLARE @intContractHeaderId INT
	DECLARE @intContainerId INT
	DECLARE @ysnReceiptFeedToERP BIT
	DECLARE @dblTollerenceQty NUMERIC(18, 6)
	DECLARE @dblTotalReceivedQty NUMERIC(18, 6)
	DECLARE @dblArrivedQty NUMERIC(18, 6)
	DECLARE @dblReceivedQty NUMERIC(18, 6)
	DECLARE @dblSumQty NUMERIC(18, 6)
	DECLARE @intReceiptQtyUOMId INT
	DECLARE @dblFinalQty NUMERIC(18, 6)
	DECLARE @strCompanyLocationName NVARCHAR(50)
	DECLARE @strAddressTitle NVARCHAR(100)
	DECLARE @strOrderType NVARCHAR(32)
	DECLARE @intItemCategoryId INT
	DECLARE @intUserId INT

	SET @ysnReceiptFeedToERP = 0

	SELECT @strCompanyLocationName = strLocationName
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intCompanyLocationId
	
	SELECT @intUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName

	--SELECT @ysnLifeTimeUnitMonthEndOfMonth=SettingValue  
	--FROM dbo.iMake_AppSetting S  
	--JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey=SV.SettingKey  
	--WHERE SettingName='Lifetime-UnitMonth-EndofMonth'  
	--For contract receipt fetch the details
	--SELECT @ysnReceiptFeedToERP = v.SettingValue FROM iMake_AppSettingValue v JOIN iMake_AppSetting s ON v.SettingKey = s.SettingKey     
	--   AND s.SettingName = 'ReceiptFeedToERP' And FactoryKey=@intCompanyLocationId
	--SELECT @intDecimalPlaces = v.SettingValue FROM iMake_AppSettingValue v JOIN iMake_AppSetting s ON v.SettingKey = s.SettingKey     
	--  AND s.SettingName = 'NumberofDecimalPlaces'
	--Select @intContractContainerId=ContractContainerkey From tblWHOrderHeader Where intOrderHeaderId = @intOrderHeaderId	
	-- SELECT @ysnQAApprove=SettingValue      
	--FROM dbo.iMake_AppSetting S      
	--JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey=SV.SettingKey      
	--WHERE UPPER(SettingName)='Quality Approval Required'         
	--SELECT @ysniProcessERPFeedEnabled = SettingValue FROM dbo.iMake_AppSettingValue AV      
	--JOIN dbo.iMake_AppSetting S ON S.SettingKey = AV.SettingKey      
	--WHERE S.SettingName = 'IsiProcessERPFeedEnabled' 
	SELECT @strOrderType = strInternalCode, @intStatusId = intOrderStatusId
	FROM dbo.tblWHOrderHeader OH
	JOIN dbo.tblWHOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	WHERE OH.intOrderHeaderId = @intOrderHeaderId

	IF EXISTS (
			SELECT DISTINCT oh.intOrderHeaderId, 
						    ol.intOrderLineItemId
			FROM tblWHOrderHeader oh
			JOIN tblWHOrderLineItem ol ON oh.intOrderHeaderId = ol.intOrderHeaderId AND ISNULL(ysnIsPhysicalCountVerified, 0) = 0
			JOIN tblICItem m ON ol.intItemId = m.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = m.intCategoryId AND mt.ysnWarehouseTracked = 0
			WHERE oh.intOrderHeaderId = @intOrderHeaderId
			)
		AND @strOrderType <> 'PR'
	BEGIN
	SELECT 'Receipt has lots without certified weights, Please ensure all weights are certified before completing receipt.'
	END

	IF @intStatusId = 4096
	BEGIN
		RAISERROR ('Order already closed.', 16, 1)
	END

	-- IF @CurrentUpdateCounter > @UpdateCounter  
	--BEGIN  
	-- SET @SubstituteValueList = @CurrentUpdateBy + CHAR(182)  
	-- EXECUTE [dbo].[GetErrorMessage] 1062, @SubstituteValueList, @CurrentUpdateBy, @strErrMsg OUTPUT  
	-- RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')   
	--END 
	--end of contract receipt fetch details
	--Get the EDI945 parameter                    
	--SELECT @strEDI944 = [Value] FROM GEN_Parameter WHERE [Key] = 'EDI944'        
	      
	--SELECT @strEDI944 = SettingValue
	--FROM iMake_AppSetting apps
	--INNER JOIN iMake_AppSettingValue appsv ON apps.SettingKey = appsv.SettingKey
	--WHERE SettingName = 'EDI944'
	--	AND appsv.FactoryKey = @intCompanyLocationId

	SET @intBadManifestRecordCount = 0
	SET @intManifestRecordCount = 0
	SET @intSerialNoBadManifestRecordCount = 0
	SET @strLotTrackingBySerialNo = 'Yes'

	--Check for manifest items                         
	SELECT @intManifestRecordCount = COUNT(*)
	FROM tblWHOrderHeader h
	INNER JOIN tblWHOrderLineItem li ON li.intOrderHeaderId = h.intOrderHeaderId
	INNER JOIN tblWHOrderManifest m ON m.intOrderLineItemId = li.intOrderLineItemId
	INNER JOIN tblWHSKU s ON s.intSKUId = m.intSKUId
	WHERE h.intOrderHeaderId = @intOrderHeaderId

	IF @intManifestRecordCount = 0
	BEGIN
		RAISERROR ('No manifest record were found.  You cannot receive an order that does not have any manifest records. You cannot receive an order without completing all the put-away tasks.', 16, 1)
	END

	--Check Put-Away tasks have been completed.                          
	IF (
			SELECT intOrderStatusId
			FROM tblWHOrderHeader
			WHERE intOrderHeaderId = @intOrderHeaderId
			) <> 256
	BEGIN
		SELECT 1
		--RAISERROR ('One or more manifest items do not have a valid lot code or production date.', 16, 1)
	END

	--BugID:1923
	IF EXISTS (SELECT * FROM tblWHTask WHERE intOrderHeaderId = @intOrderHeaderId AND intTaskStateId = 3)
	BEGIN
		RAISERROR ('You cannot receive an order without completing all the put-away tasks.', 16, 1, 'WITH NOWAIT')
	END

	--Check for any manifest items without a lot code or an invalid production date.                          
	SELECT @intBadManifestRecordCount = COUNT(*)
	FROM tblWHOrderHeader h
	INNER JOIN tblWHOrderLineItem li ON li.intOrderHeaderId = h.intOrderHeaderId
	INNER JOIN tblWHOrderManifest m ON m.intOrderLineItemId = li.intOrderLineItemId
	INNER JOIN tblICItem p ON p.intItemId = li.intItemId
		--AND p.MaterialControlKey = 1 --Lot Tracked                          
	INNER JOIN tblWHSKU s ON s.intSKUId = m.intSKUId
		AND s.intItemId = p.intItemId
		AND (
			LEN(s.strLotCode) = 0
			OR s.dtmProductionDate < '1/1/1991'
			)
	WHERE h.intOrderHeaderId = @intOrderHeaderId

	IF @intBadManifestRecordCount > 0
	BEGIN
		SELECT 1
		--RAISERROR ('One or more manifest items do not have a valid lot code or production date.', 16, 1, 'WITH NOWAIT')
	END

	--DECLARE @strAllowCreateSKUContainer NVARCHAR(50), 
	--		@strOrderHeaderID NVARCHAR(50), 
	--		@intCompanyLocationSubLocationId NUMERIC(18, 0), 
	--		@strDestinationStorageLocationId NUMERIC(18, 0), 
	--		@intAuditLocationId NUMERIC(18, 0), 
	--		@intAddressId INT

	--SELECT @strAllowCreateSKUContainer = SettingValue
	--FROM dbo.iMake_AppSetting S
	--INNER JOIN dbo.iMake_AppSettingValue SV ON S.SettingKey = SV.SettingKey
	--WHERE SettingName = 'AllowCreateSKU/Container'
	--	AND ISNULL(FactoryKey, @intCompanyLocationId) = @intCompanyLocationId

	--SELECT @strOrderHeaderID = ExternalSystemID, @intAddressId = ShipToAddressID
	--FROM WM_orderHeader
	--WHERE intOrderHeaderId = @intOrderHeaderId

	--IF @strOrderType = 'WT'
	--	AND @strAllowCreateSKUContainer = 'True'
	--	AND @strOrderHeaderID IS NOT NULL
	--BEGIN
	--	SELECT @intCompanyLocationSubLocationId = LocationKey
	--		,@strDestinationStorageLocationId = NewLotUnitKey
	--		,@intAuditLocationId = AuditUnitKey
	--	FROM Location
	--	WHERE AddressID = @intAddressId
	--	Declare @ParamValue NVARCHAR(Max)      
	--	SELECT @ParamValue =ParamValue      
	--	FROM dbo.irely_menuitem a       
	--	JOIN dbo.iRely_FormParameter b on a.menuitemkey=b.menuitemkey       
	--	WHERE  MenuitemName = 'Green Transfer' and b.ParamName='LotStatus'
	--	EXEC [iMake_OrderReceive] @strOrderHeaderID = @strOrderHeaderID
	--		,@intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId
	--		,@strDestinationStorageLocationId = @strDestinationStorageLocationId
	--		,@intAuditLocationId = @intAuditLocationId
	--		,@strUserName = @strUserName
	--		,@LotStatusMask = @ParamValue
	--		,@IsReceiveAlertEnabled=0
	--		,@IsForced=1
	--END
	--                       
	-- SELECT [Value]                 
	-- FROM GEN_Parameter where [Key] = 'LotTrackingBySerialNo'                
	-- IF @intSerialNoBadManifestRecordCount > 0 AND @strLotTrackingBySerialNo = 'Yes'                        
	--  BEGIN                          
	--   RAISERROR('One or more manifest items do not have a valid serial number or production date.', 16, 1, 'WITH NOWAIT')                          
	--  END                    
	--================================================================--        
	--====UPDATE THE SKU STATUS TO STOCK WHILE RECEIVING THE ORDER====--        
	--================================================================--  

	UPDATE tblWHSKU
	SET intSKUStatusId = 1, 
		intLastModifiedUserId = @intUserId, 
		dtmLastModified = GETDATE()
	WHERE intSKUId IN (SELECT intSKUId FROM tblWHOrderManifest 
					   WHERE intOrderHeaderId = @intOrderHeaderId)

	SELECT @intTruckId = intTruckId
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	DECLARE @strMessage NVARCHAR(64)
	DECLARE @strBOLNo NVARCHAR(32)

	SELECT @strMessage = 'RECEIVED ORDER ' + strBOLNo, @strBOLNo = strBOLNo
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Make a log entry                          
	-- INSERT INTO LOG_Data                          
	-- (LogTypeMask, Source, [Message], UserName)                          
	-- VALUES                          
	-- (16, 'uspWHReceiveOrder', @strMessage, @strUserName)                          
	--get the ship from address                    
	SELECT @intShipFromAddressId = intShipFromAddressId
	FROM tblWHOrderHeader h
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--Update the ship date in the order header                          
	UPDATE tblWHOrderHeader
	SET dtmShipDate = GETDATE(), 
		intOrderStatusId = 10
	WHERE intOrderHeaderId = @intOrderHeaderId

	--Declare @IsEDIAllowed INT                       
	----SELECT @IsEDIAllowed=intOrderHeaderId from WM_OrderHeaderContainerMapping where intOrderHeaderId=@intOrderHeaderId  
	--SELECT @IsEDIAllowed=CreatedByEDI FROM tblWHOrderHeader WHERE intOrderHeaderId=@intOrderHeaderId                   
	--Export the EDI 944 information                        
	--IF @strEDI944 = 'True'
	--	AND @strOrderType NOT IN (
	--		'PR'
	--		,'SP'
	--		)
	--	AND EXISTS (
	--		SELECT *
	--		FROM tblWHOrderHeader oh
	--		JOIN tblWHOrderLineItem ol ON oh.orderHeaderKey = ol.orderHeaderKey
	--		JOIN tblICItem m ON m.intItemId = ol.intItemId
	--		JOIN tblICCategory mt ON m.intCategoryId = mt.intCategoryId
	--		WHERE oh.intOrderHeaderId = @intOrderHeaderId
	--		)
	--	EXEC iMake_EDI.dbo.EDI944 @strBOLNo

	--Get the ship from phone number                  
	SELECT TOP 1 @strShipFromPhoneNo = e.strPhone
	FROM tblWHOrderHeader h
	INNER JOIN tblEMEntity e ON e.intEntityId = h.intShipFromAddressId
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--Get the carrier contact                  
	SELECT TOP 1 @strCarrierContact = a.strTitle + ' ' + a.strName + ' ' + a.strPhone
	FROM tblWHOrderHeader h
	INNER JOIN tblWHTruck t ON t.intTruckId = h.intTruckId
	INNER JOIN tblEMEntity a ON a.intEntityId = t.intCarrierAddressID
	WHERE h.intOrderHeaderId = @intOrderHeaderId;

	--Contract status changes and send feed to Feed Table
	--IF @strAllowCreateSKUContainer = 'True'
	--	AND EXISTS (
	--		SELECT *
	--		FROM WM_OrderHeaderContainerMapping
	--		WHERE intOrderHeaderId = @intOrderHeaderId
	--		)
	--BEGIN
	--	DECLARE @CurrentUpdateBy NVARCHAR(50)

	--	SELECT @CurrentUpdateBy = LastUpdateBy
	--	FROM tblWHOrderHeader
	--	WHERE intOrderHeaderId = @intOrderHeaderId

	--	DECLARE @ContainerNo NVARCHAR(100)

	--	SELECT TOP 1 @ContainerNo = wtt.ContainerNo
	--	FROM WM_TruckOrder wt
	--	JOIN tblWHTruck wtt ON wtt.intTruckId = wt.intTruckId
	--	WHERE wt.intOrderHeaderId = @intOrderHeaderId

	--	UPDATE LotExtendedProperty
	--	SET IsReceiveCompleted = 0, Receipt_ContainerNo = @ContainerNo
	--	WHERE LotKey IN (
	--			SELECT DISTINCT WM.LotKey
	--			FROM tblWHOrderHeader WH
	--			JOIN tblWHOrderLineItem WLI ON WH.intOrderHeaderId = WLI.intOrderHeaderId
	--			JOIN tblWHOrderManifest WM ON WLI.OrderLineItemkey = WM.OrderLineItemkey
	--			WHERE WH.intOrderHeaderId = @intOrderHeaderId
	--			)

	--	IF EXISTS (
	--			SELECT *
	--			FROM tblWHOrderHeader
	--			WHERE IsSimpleContract = 1
	--			)
	--	BEGIN
	--		SELECT TOP 1 @strContractNo = CH.ContractNo, @intContractHeaderId = CH.ContractHeaderKey
	--		FROM tblWHOrderHeader oh
	--		JOIN WM_OrderHeaderContainerMapping ccm ON ccm.intOrderHeaderId = oh.intOrderHeaderId
	--		JOIN CM_ContractHeader ch ON ch.ContractHeaderKey = ch.ContractHeaderKey
	--		WHERE oh.intOrderHeaderId = @intOrderHeaderId
	--	END
	--	ELSE
	--	BEGIN
	--		SELECT TOP 1 @strContractNo = CH.ContractNo
	--		FROM tblWHOrderHeader oh
	--		JOIN WM_OrderHeaderContainerMapping ccm ON ccm.intOrderHeaderId = oh.intOrderHeaderId
	--		JOIN CM_Container c ON ccm.ContainerKey = c.ContainerKey
	--		JOIN CM_ContractContainerMap cm ON cm.ContainerKey = c.ContainerKey
	--		JOIN CM_ContractHeader ch ON ch.ContractHeaderKey = cm.ContractHeaderKey
	--		WHERE oh.intOrderHeaderId = @intOrderHeaderId
	--	END

	--	UPDATE tblWHOrderLineItem
	--	SET StatusID = 4096
	--	WHERE intOrderHeaderId = @intOrderHeaderId

	--	DECLARE @MaterialKey1 AS NUMERIC(18, 0)

	--	DECLARE cur_updatearrivedqty CURSOR LOCAL
	--	FOR
	--	SELECT wl.intItemId, cl.ArrivedQty, wl.Qty AS Qty, wl.ReceiptQtyUOMKey, wl.ContractLineItemKey
	--	FROM tblWHOrderLineItem wl
	--	JOIN CM_ContractLineItem cl ON wl.ContractLineItemKey = cl.ContractLineItemKey
	--	WHERE wl.intOrderHeaderId = @intOrderHeaderId

	--	OPEN cur_updatearrivedqty

	--	FETCH NEXT
	--	FROM cur_updatearrivedqty
	--	INTO @MaterialKey1, @dblArrivedQty, @dblReceivedQty, @intReceiptQtyUOMId, @intContractLineItemId

	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN
	--		SET @dblSumQty = ISNULL(@dblArrivedQty, 0) + @dblReceivedQty
	--		SET @dblFinalQty = @dblSumQty

	--		UPDATE CM_ContractLineItem
	--		SET ArrivedQty = @dblFinalQty
	--		WHERE ContractLineItemKey = @intContractLineItemId

	--		UPDATE CSS
	--		SET CSS.ArrivedQty = iSNull(css.ArrivedQty, 0) + CASE 
	--				WHEN @intReceiptQtyUOMId = PackingTypeUOMKey
	--					THEN @dblReceivedQty * WeightPerUnit
	--				ELSE dbo.FN_ConvertToTargetUOM(@dblReceivedQty, @intReceiptQtyUOMId, CSS.QuantityUOMKey)
	--				END
	--		FROM CM_ContractHeader CH
	--		JOIN CM_ContractLineItem CLI ON CH.ContractHeaderKey = CLI.ContractHeaderKey
	--		JOIN CM_ShippingSchedule CSS ON CSS.ContractLineItemKey = CLI.ContractLineItemKey
	--		WHERE CSS.ContractLineItemKey = @intContractLineItemId

	--		FETCH NEXT
	--		FROM cur_updatearrivedqty
	--		INTO @MaterialKey1, @dblArrivedQty, @dblReceivedQty, @intReceiptQtyUOMId, @intContractLineItemId
	--	END

	--	CLOSE cur_updatearrivedqty

	--	DEALLOCATE cur_updatearrivedqty
	--		-------------End of container status update
	--END

	-- --end of contract receipt send the feed to MAS500 and send the mail	
	--DECLARE @Lot TABLE (RecordKey INT IDENTITY(1, 1), LotKey INT)

	--INSERT INTO @Lot (LotKey)
	--SELECT DISTINCT S.LotKey
	--FROM dbo.tblWHOrderHeader OH
	--JOIN dbo.tblWHOrderLineItem LI ON LI.intOrderHeaderId = OH.intOrderHeaderId
	--JOIN dbo.tblWHOrderManifest OM ON OM.intOrderLineItemId = LI.intOrderLineItemId
	--JOIN dbo.tblWHSKU S ON S.intSKUId = OM.intSKUId
	--JOIN dbo.tblICItem M ON M.intItemId = S.intItemId
	--	AND S.LotKey IS NOT NULL
	--JOIN tblICCategory mt ON m.intCategoryId = mt.intCategoryId
	--	AND mt.ysnWarehouseTracked = 0
	--JOIN dbo.tblWHOrderType OT ON OT.TypeKey = OH.intOrderTypeId
	--WHERE OH.intOrderHeaderId = @intOrderHeaderId
	--	AND OT.strInternalCode IN (
	--		'PO'
	--		,'WT'
	--		)

	--DECLARE @strPrimaryStatusCode NVARCHAR(MAX), 
	--		@strLotStatusMask INT, 
	--		@intmRecordKey INT, 
	--		@intLotId INT
	--DECLARE @intMenuItemId INT

	--SELECT @intMenuItemId = MenuItemKey
	--FROM iRely_MenuItem
	--WHERE MenuItemName = 'Green Receipts'

	--SELECT @strLotStatusMask = ParamValue
	--FROM iRely_FormParameter
	--WHERE MenuItemKey = @intMenuItemId
	--	AND ParamName = 'LotStatus'

	--SELECT @strLotStatusMask = LotStatusMask
	--FROM LotStatus
	--WHERE SecondaryStatusCode = @strPrimaryStatusCode

	--SELECT @intmRecordKey = NULL

	--SELECT @intmRecordKey = MIN(RecordKey)
	--FROM @Lot

	--WHILE @intmRecordKey IS NOT NULL
	--BEGIN
	--	SELECT @intLotId = NULL

	--	SELECT @intLotId = LotKey
	--	FROM @Lot
	--	WHERE RecordKey = @intmRecordKey

	--	UPDATE LotExtendedProperty
	--	SET IsReceiveCompleted = 0
	--	WHERE LotKey = @intLotId

	--	EXEC dbo.Lot_SetLotStatus @intLotId = @intLotId, @NewLotStatusMask = @strLotStatusMask, @strUserName = @strUserName, @IsStatusAllowedToChange = 1

	--	SELECT @intmRecordKey = MIN(RecordKey)
	--	FROM @Lot
	--	WHERE RecordKey > @intmRecordKey
	--END

	--Delete the tasks                          
	
	--DELETE
	--FROM tblWHTask
	--WHERE intOrderHeaderId = @intOrderHeaderId

	--Delete the order detail                          
	--DELETE
	--FROM tblWHOrderManifest
	--WHERE EXISTS (
	--		SELECT *
	--		FROM tblWHOrderHeader h
	--		INNER JOIN tblWHOrderLineItem i ON i.intOrderHeaderId = h.intOrderHeaderId
	--		WHERE h.intOrderHeaderId = @intOrderHeaderId
	--			AND tblWHOrderManifest.intOrderLineItemId = i.intOrderLineItemId
	--		)
	-- DELETE FROM tblWHOrderLineItem WHERE intOrderHeaderId = @intOrderHeaderId     
	
	--UPDATE tblWHTruck SET intTruckStatusId = 256 WHERE intTruckId = @intTruckId        
	
	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	--SET IMPLICIT_TRANSACTIONS OFF                      
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHReceiveOrder: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
	---=======================================
GO