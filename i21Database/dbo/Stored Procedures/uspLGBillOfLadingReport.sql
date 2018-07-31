CREATE PROCEDURE uspLGBillOfLadingReport 
	@xmlParam NVARCHAR(MAX) = NULL
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
		FROM (
			SELECT Shipment.intInventoryShipmentId
				,Shipment.strShipmentNumber
				,LTRIM(RTRIM(CASE 
							WHEN ISNULL(CL.strAddress, '') = ''
								THEN ''
							ELSE CL.strAddress + CHAR(13)
							END + CASE 
							WHEN ISNULL(CL.strCity, '') = ''
								THEN ''
							ELSE CL.strCity + ', '
							END + CASE 
							WHEN ISNULL(CL.strStateProvince, '') = ''
								THEN ''
							ELSE CL.strStateProvince + ', '
							END + CASE 
							WHEN ISNULL(CL.strZipPostalCode, '') = ''
								THEN ''
							ELSE CL.strZipPostalCode + ', '
							END + CASE 
							WHEN ISNULL(CL.strCountry, '') = ''
								THEN ''
							ELSE CL.strCountry
							END)) AS strShipFromAddress
				,LTRIM(RTRIM(CASE 
							WHEN ISNULL(EL.strLocationName, '') = ''
								THEN ''
							ELSE EL.strLocationName + ' '
							END + CASE 
							WHEN ISNULL(EL.strAddress, '') = ''
								THEN ''
							ELSE EL.strAddress + CHAR(13)
							END + CASE 
							WHEN ISNULL(EL.strCity, '') = ''
								THEN ''
							ELSE EL.strCity + ', '
							END + CASE 
							WHEN ISNULL(EL.strState, '') = ''
								THEN ''
							ELSE EL.strState + ', '
							END + CASE 
							WHEN ISNULL(EL.strZipCode, '') = ''
								THEN ''
							ELSE EL.strZipCode + ', '
							END + CASE 
							WHEN ISNULL(EL.strCountry, '') = ''
								THEN ''
							ELSE EL.strCountry
							END)) AS strShipToAddress
				,Shipment.strBOLNumber
				,'' AS strOrderNumber
				,strCustomerPO = SO.strPONumber
				,Shipment.dtmShipDate
				,ShipVia.strShipVia
				,Shipment.strDeliveryInstruction
				,FreightTerm.strFreightTerm
				,Item.strItemNo
				,strItemDescription = Item.strDescription
				,Lot.strLotNumber
				,Lot.strLotAlias
				,ISNULL(ShipmentItemLot.dblQuantityShipped, ISNULL(ShipmentItem.dblQuantity, 0)) AS dblQty
				,ISNULL(LUOM.strUnitMeasure, UOM.strUnitMeasure) AS strUOM
				,(
					CASE 
						WHEN LUOM.strUnitMeasure <> ISNULL(WUOM.strUnitMeasure, '')
							THEN (ISNULL(ShipmentItemLot.dblQuantityShipped, ISNULL(ShipmentItem.dblQuantity, 0)) * Item.dblWeight)
						ELSE ISNULL(ShipmentItemLot.dblQuantityShipped, ISNULL(ShipmentItem.dblQuantity, 0))
						END
					) AS dblNetWeight
				,SUM(ISNULL(ShipmentItemLot.dblGrossWeight, 0) - ISNULL(ShipmentItemLot.dblTareWeight, 0)) OVER () AS dblTotalWeight
				,intWarehouseInstructionHeaderId = 0
				,strCompanyName = (
					SELECT TOP 1 strCompanyName
					FROM tblSMCompanySetup
					)
				,LTRIM(RTRIM(CASE 
							WHEN ISNULL(CL.strAddress, '') = ''
								THEN ''
							ELSE CL.strAddress + ', '
							END + CASE 
							WHEN ISNULL(CL.strCity, '') = ''
								THEN ''
							ELSE CL.strCity + ', '
							END + CASE 
							WHEN ISNULL(CL.strStateProvince, '') = ''
								THEN ''
							ELSE CL.strStateProvince + ', '
							END + CASE 
							WHEN ISNULL(CL.strZipPostalCode, '') = ''
								THEN ''
							ELSE CL.strZipPostalCode + ', '
							END + CASE 
							WHEN ISNULL(CL.strCountry, '') = ''
								THEN ''
							ELSE CL.strCountry
							END)) AS strCompanyAddress
				,ParentLot.strParentLotNumber
				,Entity.strName AS strCustomerName
				,strShipFromLocation = CL.strLocationName
				,Shipment.strReferenceNumber
				,Shipment.strVessel
				,Shipment.strSealNumber
				,ISNULL(@strCustomCustomerPO, '') AS strCustomCustomerPO
			FROM tblICInventoryShipment Shipment
			JOIN tblICInventoryShipmentItem ShipmentItem ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			JOIN tblICItem Item ON Item.intItemId = ShipmentItem.intItemId
			JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId
			JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			JOIN tblICInventoryShipmentItemLot ShipmentItemLot ON ShipmentItemLot.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			JOIN tblICLot Lot ON Lot.intLotId = ShipmentItemLot.intLotId
			JOIN tblICItemUOM ItemUOM1 ON ItemUOM1.intItemUOMId = Lot.intItemUOMId
			JOIN tblICUnitMeasure LUOM ON LUOM.intUnitMeasureId = ItemUOM1.intUnitMeasureId
			JOIN tblICParentLot ParentLot ON Lot.intParentLotId = ParentLot.intParentLotId
			LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Item.intWeightUOMId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = Shipment.intShipFromLocationId
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = Shipment.intShipToLocationId
			LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = Shipment.intEntityCustomerId
			LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityId = Shipment.intShipViaId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId
			LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = ShipmentItem.intOrderId
				AND Shipment.intOrderType = 2 -- 'Sales Order'
			) AS a
		WHERE strShipmentNumber = @strShipmentNo
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFBillOfLadingReport - ' + ERROR_MESSAGE()

	RAISERROR (@strErrMsg,18,1,'WITH NOWAIT')
END CATCH
