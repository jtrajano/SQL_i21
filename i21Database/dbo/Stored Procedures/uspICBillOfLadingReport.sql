CREATE PROCEDURE uspICBillOfLadingReport @xmlParam NVARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN TRY
	IF ISNULL(@xmlParam, '') = ''
	BEGIN
		SELECT '' AS 'intInventoryShipmentId'
			,'' AS 'strShipToFullAddress'
			,'' AS 'strShipToLocation'
			,'' AS 'strShipToAddress'
			,'' AS 'strShipToCity'
			,'' AS 'strShipToZip'
			,'' AS 'strShipToCityZip'
			,'' AS 'strShipToState'
			,'' AS 'strShipToCountry'
			,'' AS 'strShipToStateCountry'
		 	,'' AS 'strShipmentNumber'
			,'' AS 'strShipFromFullAddress'
			,'' AS 'strShipFromLocation'
			,'' AS 'strShipFromAddress'
			,'' AS 'strShipFromCity'
			,'' AS 'strShipFromZip'
			,'' AS 'strShipFromCityZip'
			,'' AS 'strShipFromState'
			,'' AS 'strShipFromCountry'
			,'' AS 'strShipFromStateCountry'
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
				,Shipment.strShipFromAddress AS strShipFromFullAddress
				,Shipment.strShipToAddress AS strShipToFullAddress
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strLocationName ELSE shipTo.strLocationName END AS [strShipToLocation]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strAddress ELSE shipTo.strAddress END AS [strShipToAddress]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strCity ELSE shipTo.strCity END AS [strShipToCity]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strZipCode ELSE shipTo.strZipPostalCode END AS [strShipToZip]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strCity ELSE shipTo.strCity END + ', ' + CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strZipCode ELSE shipTo.strZipPostalCode END AS [strShipToCityZip]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strState ELSE shipTo.strStateProvince END AS [strShipToState]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strCountry ELSE shipTo.strCountry END AS [strShipToCountry]
				,CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strState ELSE shipTo.strStateProvince END + ', ' + CASE WHEN Shipment.intOrderType <> 3 THEN shipToTransfer.strCountry ELSE shipTo.strCountry END AS [strShipToStateCountry]
				,shipFrom.strLocationName AS [strShipFromLocation]
				,shipFrom.strAddress AS [strShipFromAddress]
				,shipFrom.strCity AS [strShipFromCity]
				,shipFrom.strZipPostalCode AS [strShipFromZip]
				,shipFrom.strCity + ', ' + shipFrom.strZipPostalCode AS [strShipFromCityZip]
				,shipFrom.strStateProvince AS [strShipFromState]
				,shipFrom.strCountry AS [strShipFromCountry]
				,shipFrom.strStateProvince + ', ' + shipFrom.strCountry AS [strShipFromStateCountry]
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
				,ISNULL(ShipmentItemLot.dblQuantityShipped, ISNULL(ShipmentItem.dblQtyToShip, 0)) AS dblQty
				,ISNULL(ShipmentItemLot.strLotUOM, ShipmentItem.strUnitMeasure) AS strUOM
				,ISNULL(ShipmentItemLot.dblNetWeight,0) AS dblNetWeight
				,SUM(ShipmentItemLot.dblNetWeight) OVER() AS dblTotalWeight
				,intWarehouseInstructionHeaderId = ISNULL(WarehouseInstruction.intWarehouseInstructionHeaderId, 0)
				,Shipment.strCompanyName
				,Shipment.strCompanyAddress
				,ParentLot.strParentLotNumber
				,Shipment.strCustomerName
				,Shipment.strReferenceNumber, Shipment.intShipToCompanyLocationId, Shipment.intShipToLocationId
			FROM vyuICGetInventoryShipmentBillOfLading Shipment
			LEFT JOIN vyuICGetInventoryShipmentItem ShipmentItem ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			LEFT JOIN vyuICGetInventoryShipmentItemLot ShipmentItemLot ON ShipmentItemLot.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = ShipmentItemLot.intLotId
			LEFT JOIN tblICParentLot ParentLot ON Lot.intParentLotId = ParentLot.intParentLotId
			LEFT JOIN tblSMShipVia ShipVia ON ShipVia.[intEntityId] = Shipment.intShipViaId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Shipment.intFreightTermId
			LEFT JOIN tblLGWarehouseInstructionHeader WarehouseInstruction ON WarehouseInstruction.intInventoryShipmentId = Shipment.intInventoryShipmentId
		    LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = ShipmentItem.intOrderId AND ShipmentItem.strOrderType = 'Sales Order'
			LEFT JOIN tblSMCompanyLocation shipFrom ON shipFrom.intCompanyLocationId = Shipment.intShipFromLocationId
			LEFT JOIN tblSMCompanyLocation shipTo ON shipTo.intCompanyLocationId = Shipment.intShipToCompanyLocationId
			LEFT JOIN [tblEMEntityLocation] shipToTransfer ON shipToTransfer.intEntityLocationId = Shipment.intShipToLocationId
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