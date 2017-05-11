CREATE PROCEDURE uspICBillOfLadingReport @xmlParam NVARCHAR(MAX) = NULL
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
			, '' AS 'dblNetWeight'
			,'' AS 'dblTotalWeight'
			, '' AS 'strCompanyName'
			, '' AS 'strCompanyAddress'
			, '' AS 'strParentLotNumber'
			, '' AS 'strCustomerName'
			, '' AS 'strShipFromLocation'
			, '' AS 'strReferenceNumber'
		RETURN
	END

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @xmlDocumentId INT
	DECLARE @strShipmentNo NVARCHAR(100)

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
		SELECT *
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
				,ISNULL(ShipmentItemLot.dblNetWeight,0) AS dblNetWeight
				,SUM(ShipmentItemLot.dblNetWeight) OVER() AS dblTotalWeight
				,intWarehouseInstructionHeaderId = ISNULL(WarehouseInstruction.intWarehouseInstructionHeaderId, 0)
				,Shipment.strCompanyName
				,Shipment.strCompanyAddress
				,ParentLot.strParentLotNumber
				,Shipment.strCustomerName
				,strShipFromLocation = Shipment.strShipFromLocation
				,Shipment.strReferenceNumber
			FROM vyuICGetInventoryShipmentBillOfLading Shipment
			LEFT JOIN vyuICGetInventoryShipmentItem ShipmentItem ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			LEFT JOIN vyuICGetInventoryShipmentItemLot ShipmentItemLot ON ShipmentItemLot.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = ShipmentItemLot.intLotId
			LEFT JOIN tblICParentLot ParentLot ON Lot.intParentLotId = ParentLot.intParentLotId
			LEFT JOIN tblSMShipVia ShipVia ON ShipVia.[intEntityId] = Shipment.intShipViaId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId
			LEFT JOIN tblLGWarehouseInstructionHeader WarehouseInstruction ON WarehouseInstruction.intInventoryShipmentId = Shipment.intInventoryShipmentId
		    LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = ShipmentItem.intOrderId AND ShipmentItem.strOrderType = 'Sales Order'
				
			) AS a
		WHERE strShipmentNumber = @strShipmentNo 
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspICBillOfLadingReport - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH