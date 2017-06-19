CREATE PROCEDURE uspMFBillOfLadingReport @xmlParam NVARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF ISNULL(@xmlParam, '') = ''
	BEGIN
		SELECT '' AS 'intInventoryShipmentId'
			,'' AS 'strShipToAddress'
			,'' AS 'strShipmentNumber'
			,'' AS 'strShipFromAddress'
			,'' AS 'strBOLNumber'
			,'' AS 'strOrderNumber'
			,'' AS 'strCustomerPO'
			,'' AS 'dtmShipDate'
			,'' AS 'strShipVia'
			,'' AS 'strDeliveryInstruction'
			,'' AS 'strFreightTerm'
			,'' AS 'strItemNo'
			,'' AS 'strItemDescription'
			,'' AS 'strLotNumber'
			,'' AS 'strLotAlias'
			,'' AS 'dblQty'
			,'' AS 'strUOM'
			,'' AS 'intWarehouseInstructionHeaderId'
			,'' AS 'dblNetWeight'
			,'' AS 'dblTotalWeight'
			,'' AS 'strCompanyName'
			,'' AS 'strCompanyAddress'
			,'' AS 'strParentLotNumber'
			,'' AS 'strCustomerName'
			,'' AS 'strShipFromLocation'
			,'' AS 'strReferenceNumber'
			,'' AS 'strVessel'
			,'' AS 'strSealNumber'
			,'' AS 'strCustomCustomerPO'
			,'' AS 'intPalletsCount'

		RETURN
	END

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @xmlDocumentId INT
	DECLARE @strShipmentNo NVARCHAR(100)
	DECLARE @strCustomCustomerPO NVARCHAR(50)
	DECLARE @intInventoryShipmentId INT

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strShipmentNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strShipmentNumber'

	SELECT @strOrderType = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strOrderType'

	IF @strShipmentNo IS NOT NULL
	BEGIN
		SELECT @intInventoryShipmentId = intInventoryShipmentId
		FROM tblICInventoryShipment
		WHERE strShipmentNumber = @strShipmentNo

		-- Taking 'Customer PO No' value from custom tab
		SELECT @strCustomCustomerPO = FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'customer po no'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = @intInventoryShipmentId

		SELECT *
			,COUNT(1) OVER () AS intPalletsCount
		--,SUM(CEILING(dblQty / intCasesPerPallet)) OVER () AS intPalletsCount
		FROM (
			SELECT Shipment.intInventoryShipmentId
				,Shipment.strShipmentNumber
				,strShipFromAddress = Shipment.strShipFromAddress
				,strShipToAddress = Shipment.strShipToLocation + ' ' + Shipment.strShipToAddress
				,Shipment.strBOLNumber
				,ShipmentItem.strOrderNumber
				,strCustomerPO = SO.strPONumber
				,Shipment.dtmShipDate
				,ShipVia.strShipVia
				,Shipment.strDeliveryInstruction
				,FreightTerm.strFreightTerm
				,ShipmentItem.strItemNo
				,ShipmentItem.strItemDescription
				,Lot.strLotNumber
				,Lot.strLotAlias
				,ISNULL(ShipmentItemLot.dblLotQty, ISNULL(ShipmentItem.dblQtyToShip, 0)) AS dblQty
				,ISNULL(ShipmentItemLot.strLotUOM, ShipmentItem.strUnitMeasure) AS strUOM
				--,ISNULL(ShipmentItemLot.dblNetWeight, 0) AS dblNetWeight
				,(
					CASE 
						WHEN strLotUOM <> IsNULL(UM.strUnitMeasure, '')
							THEN (ISNULL(ShipmentItemLot.dblLotQty, ISNULL(ShipmentItem.dblQtyToShip, 0)) * Item.dblWeight)
						ELSE ISNULL(ShipmentItemLot.dblLotQty, ISNULL(ShipmentItem.dblQtyToShip, 0))
						END
					) AS dblNetWeight
				,SUM(ShipmentItemLot.dblNetWeight) OVER () AS dblTotalWeight
				,intWarehouseInstructionHeaderId = ISNULL(WarehouseInstruction.intWarehouseInstructionHeaderId, 0)
				,Shipment.strCompanyName
				,Shipment.strCompanyAddress
				,ParentLot.strParentLotNumber
				,Shipment.strCustomerName
				,strShipFromLocation = Shipment.strShipFromLocation
				,Shipment.strReferenceNumber
				,Shipment.strVessel
				,Shipment.strSealNumber
				,ISNULL(@strCustomCustomerPO, '') AS strCustomCustomerPO
			--,(
			--	CASE 
			--		WHEN ISNULL((Item.intLayerPerPallet * Item.intUnitPerLayer), 0) = 0
			--			THEN 1
			--		ELSE (Item.intLayerPerPallet * Item.intUnitPerLayer)
			--		END
			--	) AS intCasesPerPallet
			FROM vyuICGetInventoryShipment Shipment
			LEFT JOIN vyuICGetInventoryShipmentItem ShipmentItem ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			LEFT JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			LEFT JOIN tblICItem Item ON Item.intItemId = SI.intItemId
			LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = Item.intWeightUOMId
			LEFT JOIN vyuICGetInventoryShipmentItemLot ShipmentItemLot ON ShipmentItemLot.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = ShipmentItemLot.intLotId
			LEFT JOIN tblICParentLot ParentLot ON Lot.intParentLotId = ParentLot.intParentLotId
			LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityShipViaId = Shipment.intShipViaId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId
			LEFT JOIN tblLGWarehouseInstructionHeader WarehouseInstruction ON WarehouseInstruction.intInventoryShipmentId = Shipment.intInventoryShipmentId
			LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = ShipmentItem.intOrderId
				AND ShipmentItem.strOrderType = 'Sales Order'
			) AS a
		WHERE strShipmentNumber = @strShipmentNo
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFBillOfLadingReport - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
