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
			,'' AS 'strTruckNo'

		RETURN
	END

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @xmlDocumentId INT
	DECLARE @strShipmentNo NVARCHAR(100)
	DECLARE @strCustomCustomerPO NVARCHAR(50)
	DECLARE @intLoadId INT

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
		SELECT @intLoadId = intLoadId
		FROM tblLGLoad
		WHERE strLoadNumber = @strShipmentNo

		-- Taking 'Customer PO No' value from custom tab
		SELECT @strCustomCustomerPO = FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'customer po no'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryShipment'
		WHERE T.intRecordId = @intLoadId

		SELECT *
			,COUNT(1) OVER () AS intPalletsCount
		FROM (
			SELECT Load.intLoadId
				,Load.strLoadNumber
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
				,Load.strBLNumber
				,'' AS strOrderNumber
				,strCustomerPO = Load.strCustomerReference
				,Load.dtmScheduledDate
				,Via.strName AS strShipVia
				,Load.strTruckNo
				,Load.strComments
				,FreightTerm.strFreightTerm
				,Item.strItemNo
				,strItemDescription = Item.strDescription
				,Lot.strLotNumber
				,Lot.strLotAlias
				,ISNULL(LoadDetailLot.dblLotQuantity, ISNULL(LoadDetail.dblQuantity, 0)) AS dblQty
				,ISNULL(LUOM.strUnitMeasure, UOM.strUnitMeasure) AS strUOM
				,(
					CASE 
						WHEN LUOM.strUnitMeasure <> ISNULL(WUOM.strUnitMeasure, '')
							THEN (ISNULL(LoadDetailLot.dblLotQuantity, ISNULL(LoadDetail.dblQuantity, 0)) * Item.dblWeight)
						ELSE ISNULL(LoadDetailLot.dblLotQuantity, ISNULL(LoadDetail.dblQuantity, 0))
						END
					) AS dblNetWeight
				,SUM(ISNULL(LoadDetailLot.dblGross, 0) - ISNULL(LoadDetailLot.dblTare, 0)) OVER () AS dblTotalWeight
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
				,Load.strExternalLoadNumber AS strReferenceNumber
				,Load.strMVessel
				,Load.strMarks
				,Load.strTrailerNo3 AS strSealNumber
				,ISNULL('', '') AS strCustomCustomerPO
				,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
				,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
			FROM tblLGLoad Load
			JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intLoadId = Load.intLoadId
			LEFT JOIN tblLGLoadDetailLot LoadDetailLot ON LoadDetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
			LEFT JOIN tblICItem Item ON Item.intItemId = LoadDetail.intItemId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICLot Lot ON Lot.intLotId = LoadDetailLot.intLotId
			LEFT JOIN tblICItemUOM ItemUOM1 ON ItemUOM1.intItemUOMId = Lot.intItemUOMId
			LEFT JOIN tblICUnitMeasure LUOM ON LUOM.intUnitMeasureId = ItemUOM1.intUnitMeasureId
			LEFT JOIN tblICParentLot ParentLot ON Lot.intParentLotId = ParentLot.intParentLotId
			LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Item.intWeightUOMId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
			LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = LoadDetail.intCustomerEntityId
			LEFT JOIN	tblEMEntity Via ON Via.intEntityId = Load.intHaulerEntityId
			--LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityId = Shipment.intShipViaId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Load.intFreightTermId
				AND Load.intPurchaseSale = 2 -- 'Outbound Order'
			) AS a
		WHERE strLoadNumber =  @strShipmentNo
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspLGBillOfLadingReport - ' + ERROR_MESSAGE()

	RAISERROR (@strErrMsg,18,1,'WITH NOWAIT')
END CATCH
