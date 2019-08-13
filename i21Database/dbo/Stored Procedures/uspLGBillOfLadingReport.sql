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
			,'' AS 'strBLNumber'
			,'' AS 'strBookingReference'
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
			,'' AS 'strTrailerNo1'
			,'' AS 'strTrailerNo2'
			,'' AS 'strSealNumber'
			,'' AS 'strCustomCustomerPO'
			,'' AS 'intPalletsCount'
			,'' AS 'strTruckNo'
			,'' AS 'strBOLText' 
			,'' AS 'strLoadDirectionMsg' 
			,'' AS 'strBOLInstructions'
			,'' AS 'strContainerNumbers'
			,'' AS 'strCarrier'
			
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
			SELECT L.intLoadId
				,L.strLoadNumber
				,strShipFromAddress = LTRIM(RTRIM(CASE 
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
							END))
				,strShipToAddress = LTRIM(RTRIM(CASE 
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
							END))
				,L.strBLNumber
				,L.strBookingReference
				,strOrderNumber = ''
				,strCustomerPO = L.strCustomerReference
				,L.dtmScheduledDate
				,strShipVia = Via.strName
				,L.strTruckNo
				,L.strComments
				,FreightTerm.strFreightTerm
				,Item.strItemNo
				,strItemDescription = Item.strDescription
				,Lot.strLotNumber
				,Lot.strLotAlias
				,dblQty = ISNULL(LoadDetailLot.dblLotQuantity, ISNULL(LoadDetail.dblQuantity, 0))
				,strUOM = ISNULL(LUOM.strUnitMeasure, UOM.strUnitMeasure)
				,dblNetWeight = 
					CASE WHEN ISNULL(LDLC.intCount, 0) > 0 THEN
						CASE WHEN ISNULL(LUOM.strUnitMeasure, '') <> COALESCE(MWUOM.strUnitMeasure, LWUOM.strUnitMeasure, '')
							THEN (ISNULL(LoadDetailLot.dblLotQuantity, ISNULL(LoadDetail.dblQuantity, 0))
								* dbo.fnCalculateQtyBetweenUOM(LotItemUOM.intItemUOMId, COALESCE(MWUOM.intItemUOMId, LoadDetailLot.intWeightUOMId, LotWeightUOM.intItemUOMId), 1))
						ELSE 
							ISNULL(ISNULL(LoadDetailLot.dblGross, 0) - ISNULL(LoadDetailLot.dblTare, 0), ISNULL(LoadDetail.dblNet, 0))
						END
					ELSE
						ISNULL(ISNULL(LoadDetail.dblGross, 0) - ISNULL(LoadDetail.dblTare, 0), ISNULL(LoadDetail.dblNet, 0))
					END
				,dblTotalWeight = 
					CASE WHEN ISNULL(LDLC.intCount, 0) > 0 THEN
						SUM(ISNULL(LoadDetailLot.dblGross, 0) - ISNULL(LoadDetailLot.dblTare, 0)) OVER () 
					ELSE 
						SUM(ISNULL(LoadDetail.dblGross, 0) - ISNULL(LoadDetail.dblTare, 0)) OVER () 
					END
				,intWarehouseInstructionHeaderId = 0
				,strCompanyName = (
					SELECT TOP 1 strCompanyName
					FROM tblSMCompanySetup
					)
				,strCompanyAddress = LTRIM(RTRIM(CASE 
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
							END))
				,ParentLot.strParentLotNumber
				,strCustomerName = Entity.strName
				,strShipFromLocation = CL.strLocationName
				,strReferenceNumber = L.strExternalLoadNumber
				,L.strMVessel
				,L.strMarks
				,L.strTrailerNo1
				,L.strTrailerNo2
				,strSealNumber = L.strTrailerNo3
				,strDeliveryInstruction = LoadDetail.strLoadDirectionMsg
				,strCustomCustomerPO = ISNULL('', '')
				,blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')
				,blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
				,CP.strBOLText
				,L.strBOLInstructions
				,LoadDetail.strLoadDirectionMsg
				,LoadDetail.strContainerNumbers
				,strCarrier = CASE WHEN (ISNULL(L.strGenerateLoadHauler, '') <> '') THEN L.strGenerateLoadHauler ELSE Via.strName END
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intLoadId = L.intLoadId
			LEFT JOIN tblLGLoadDetailLot LoadDetailLot ON LoadDetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
			OUTER APPLY (SELECT intCount = COUNT(1) FROM tblLGLoadDetailLot WHERE intLoadDetailId = LoadDetail.intLoadDetailId) LDLC
			LEFT JOIN tblICItem Item ON Item.intItemId = LoadDetail.intItemId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
			LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Item.intWeightUOMId
			OUTER APPLY (SELECT TOP 1 intItemUOMId, strUnitMeasure FROM tblICItemUOM u1
				INNER JOIN tblICUnitMeasure u2 ON u1.intUnitMeasureId = u2.intUnitMeasureId
				WHERE u1.intItemId = Item.intItemId AND u1.intUnitMeasureId = Item.intWeightUOMId) MWUOM
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICLot Lot ON Lot.intLotId = LoadDetailLot.intLotId
			LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
			LEFT JOIN tblICUnitMeasure LUOM ON LUOM.intUnitMeasureId = LotItemUOM.intUnitMeasureId
			LEFT JOIN tblICParentLot ParentLot ON Lot.intParentLotId = ParentLot.intParentLotId
			LEFT JOIN tblICItemUOM LotWeightUOM ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
			LEFT JOIN tblICUnitMeasure LWUOM ON LWUOM.intUnitMeasureId = LotWeightUOM.intUnitMeasureId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
			LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = LoadDetail.intCustomerEntityId
			LEFT JOIN tblEMEntity Via ON Via.intEntityId = L.intHaulerEntityId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = L.intFreightTermId
				AND L.intPurchaseSale = 2 -- 'Outbound Order'
			CROSS APPLY tblLGCompanyPreference CP
			) AS a
		WHERE strLoadNumber =  @strShipmentNo
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspLGBillOfLadingReport - ' + ERROR_MESSAGE()

	RAISERROR (@strErrMsg,18,1,'WITH NOWAIT')
END CATCH
