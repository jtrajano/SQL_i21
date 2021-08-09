CREATE PROCEDURE uspLGBillOfLadingReport 
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF ISNULL(@xmlParam, '') = ''
	BEGIN
		SELECT 
			'' AS 'strLoadNumber'
			,'' AS 'dtmScheduledDate'
			,'' AS 'intInventoryShipmentId'
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
			,'' AS 'strOrderType'
			,'' AS 'strCompanyHeaderInfo'
			,'' AS 'strCompanyHeaderContact'
			,'' AS 'strCompanyLocationName'
			,'' AS 'strCompanyLocationAddress'
			,'' AS 'strCompanyLocationCity' 
			,'' AS 'strCompanyLocationState' 
			,'' AS 'strCompanyLocationZip'
			,'' AS 'strCompanyLocationPhone'
			,'' AS 'strCompanyLocationEmail'
			,'' AS 'strManufacturer'
			,'' AS 'strCommodityInfo'
			,'' AS 'strShipperInfo'
			,'' AS 'strConsigneeInfo'
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

		IF (@strOrderType IS NULL) SET @strOrderType = 'Outbound'

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
				,strShipFromAddress = LTRIM(RTRIM(CASE WHEN ISNULL(CL.strAddress, '') = '' THEN '' ELSE CL.strAddress + CHAR(13) END 
					+ CASE WHEN ISNULL(CL.strCity, '') = '' THEN '' ELSE CL.strCity + ', ' END 
					+ CASE WHEN ISNULL(CL.strStateProvince, '') = '' THEN '' ELSE CL.strStateProvince + ', ' END 
					+ CASE WHEN ISNULL(CL.strZipPostalCode, '') = '' THEN '' ELSE CL.strZipPostalCode + ', ' END 
					+ CASE WHEN ISNULL(CL.strCountry, '') = '' THEN '' ELSE CL.strCountry END))
				,strShipToAddress = LTRIM(RTRIM(CASE WHEN ISNULL(EL.strLocationName, '') = '' THEN '' ELSE EL.strLocationName + ' ' END 
					+ CASE WHEN ISNULL(EL.strAddress, '') = '' THEN '' ELSE EL.strAddress + CHAR(13) END 
					+ CASE WHEN ISNULL(EL.strCity, '') = '' THEN '' ELSE EL.strCity + ', ' END 
					+ CASE WHEN ISNULL(EL.strState, '') = '' THEN '' ELSE EL.strState + ', ' END 
					+ CASE WHEN ISNULL(EL.strZipCode, '') = '' THEN '' ELSE EL.strZipCode + ', ' END 
					+ CASE WHEN ISNULL(EL.strCountry, '') = '' THEN '' ELSE EL.strCountry END))
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
				,strCompanyName = CS.strCompanyName
				,strCompanyAddress = LTRIM(RTRIM(CASE WHEN ISNULL(CL.strAddress, '') = '' THEN '' ELSE CL.strAddress + ', ' END 
					+ CASE WHEN ISNULL(CL.strCity, '') = '' THEN '' ELSE CL.strCity + ', ' END 
					+ CASE WHEN ISNULL(CL.strStateProvince, '') = '' THEN '' ELSE CL.strStateProvince + ', ' END 
					+ CASE WHEN ISNULL(CL.strZipPostalCode, '') = '' THEN '' ELSE CL.strZipPostalCode + ', ' END 
					+ CASE WHEN ISNULL(CL.strCountry, '') = '' THEN '' ELSE CL.strCountry END))
				,ParentLot.strParentLotNumber
				,strCustomerName = E.strName
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
				,strOrderType = CASE WHEN (E.intEntityId = LoadDetail.intVendorEntityId) THEN 'Inbound' ELSE 'Outbound' END
				,strCompanyHeaderInfo = CASE WHEN ISNULL(CS.strWebSite, '') = '' THEN '' ELSE CS.strWebSite + CHAR(13) END 
					+ CASE WHEN ISNULL(CS.strAddress, '') = '' THEN '' ELSE CS.strAddress + CHAR(13) END
					+ CASE WHEN ISNULL(CS.strCity, '') = '' THEN '' ELSE CS.strCity + CASE WHEN ISNULL(CS.strState, '') = '' THEN CHAR(13) ELSE ', ' END END
					+ CASE WHEN ISNULL(CS.strState, '') = '' THEN '' ELSE CS.strState + CHAR(13) END
					+ CASE WHEN ISNULL(CS.strZip, '') = '' THEN '' ELSE CS.strZip END
				,strCompanyHeaderContact = CASE WHEN ISNULL(CS.strPhone, '') = '' THEN '' ELSE 'Phone: ' + CS.strPhone + CHAR(13) END
					+ CASE WHEN ISNULL(CS.strFax, '') = '' THEN '' ELSE 'Fax: ' + CS.strFax + CHAR(13) END
					+ CASE WHEN ISNULL(CS.strEmail, '') = '' THEN '' ELSE CS.strEmail + CHAR(13) END
				,strCompanyLocationName = CL.strLocationName
				,strCompanyLocationAddress = CL.strAddress
				,strCompanyLocationCity = CL.strCity
				,strCompanyLocationState = CL.strStateProvince
				,strCompanyLocationZip = CL.strZipPostalCode
				,strCompanyLocationPhone = CL.strPhone
				,strCompanyLocationEmail = CL.strEmail
				,strManufacturer = Manu.strManufacturer
				,strCommodityInfo = dbo.fnICFormatNumber(LoadDetail.dblQuantity) + ' ' + UOM.strUnitMeasure + ' of ' + Item.strItemNo
				,strShipperInfo = CASE WHEN (E.intEntityId = LoadDetail.intVendorEntityId) 
					THEN E.strName + CHAR(13)
						+ 'Contact:' + EC.strName + ' ' + EC.strPhone + CHAR(13)
						+ CASE WHEN ISNULL(EL.strAddress, '') = '' THEN '' ELSE EL.strAddress + CHAR(13) END
						+ CASE WHEN ISNULL(EL.strCity, '') = '' THEN '' ELSE EL.strCity + CASE WHEN ISNULL(EL.strState, '') = '' THEN '' ELSE ', ' END END
						+ CASE WHEN ISNULL(EL.strState, '') = '' THEN '' ELSE EL.strState END
					ELSE CS.strCompanyName + CHAR(13)
						+ CL.strLocationName + CASE WHEN ISNULL(CL.strAddress, '') = '' THEN CHAR(13) ELSE ' / ' END
						+ CASE WHEN ISNULL(CL.strAddress, '') = '' THEN '' ELSE CL.strAddress + CHAR(13) END
						+ CASE WHEN ISNULL(CL.strCity, '') = '' THEN '' ELSE CL.strCity + CASE WHEN ISNULL(CL.strStateProvince, '') = '' THEN '' ELSE ', ' END END
						+ CASE WHEN ISNULL(CL.strStateProvince, '') = '' THEN '' ELSE CL.strStateProvince END
					END
				,strConsigneeInfo = CASE WHEN (E.intEntityId = LoadDetail.intVendorEntityId) 
					THEN CS.strCompanyName + CHAR(13)
						+ CL.strLocationName + CASE WHEN ISNULL(CL.strAddress, '') = '' THEN CHAR(13) ELSE ' / ' END
						+ CASE WHEN ISNULL(CL.strAddress, '') = '' THEN '' ELSE CL.strAddress + CHAR(13) END
						+ CASE WHEN ISNULL(CL.strCity, '') = '' THEN '' ELSE CL.strCity + CASE WHEN ISNULL(CL.strStateProvince, '') = '' THEN '' ELSE ', ' END END
						+ CASE WHEN ISNULL(CL.strStateProvince, '') = '' THEN '' ELSE CL.strStateProvince END
					ELSE E.strName + CHAR(13)
						+ CASE WHEN ISNULL(EL.strAddress, '') = '' THEN '' ELSE EL.strAddress + CHAR(13) END
						+ CASE WHEN ISNULL(EL.strCity, '') = '' THEN '' ELSE EL.strCity + CASE WHEN ISNULL(EL.strState, '') = '' THEN '' ELSE ', ' END END
						+ CASE WHEN ISNULL(EL.strState, '') = '' THEN '' ELSE EL.strState END
					END
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
			LEFT JOIN tblICManufacturer Manu ON Manu.intManufacturerId = Item.intManufacturerId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
			LEFT JOIN tblEMEntity E ON  
					(@strOrderType = 'Outbound' AND E.intEntityId = LoadDetail.intCustomerEntityId)
					OR (@strOrderType = 'Inbound' AND E.intEntityId = LoadDetail.intVendorEntityId)
					OR (@strOrderType = 'Drop Ship' AND E.intEntityId IN (LoadDetail.intCustomerEntityId, LoadDetail.intVendorEntityId))
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = CASE WHEN (E.intEntityId = LoadDetail.intVendorEntityId) THEN LoadDetail.intVendorEntityId ELSE LoadDetail.intCustomerEntityId END
				AND EL.intEntityLocationId = CASE WHEN (E.intEntityId = LoadDetail.intVendorEntityId) THEN LoadDetail.intVendorEntityLocationId ELSE LoadDetail.intCustomerEntityLocationId END	
			LEFT JOIN tblEMEntityToContact ETC ON ETC.intEntityId = E.intEntityId AND ETC.ysnDefaultContact = 1
			LEFT JOIN tblEMEntity EC ON EC.intEntityId = ETC.intEntityContactId
			LEFT JOIN tblEMEntity Via ON Via.intEntityId = L.intHaulerEntityId
			LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = L.intFreightTermId
			CROSS APPLY tblSMCompanySetup CS
			CROSS APPLY tblLGCompanyPreference CP
			) AS a
		WHERE intLoadId = @intLoadId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspLGBillOfLadingReport - ' + ERROR_MESSAGE()

	RAISERROR (@strErrMsg,18,1,'WITH NOWAIT')
END CATCH
