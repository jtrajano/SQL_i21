CREATE PROCEDURE uspMFInventoryReceiptReport @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @strReceiptNo NVARCHAR(50)
		,@idoc INT
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strContactName NVARCHAR(50)
		,@strCounty NVARCHAR(25)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)
		,@strPhone NVARCHAR(50)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strReceiptNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strReceiptNo'

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strContactName = strContactName
		,@strCounty = strCounty
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
		,@strPhone = strPhone
	FROM tblSMCompanySetup

	SELECT @strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCountry AS strCompanyCountry
		,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
		,LTRIM(RTRIM(CASE 
					WHEN ISNULL(CL.strLocationName, '') = ''
						THEN ''
					ELSE CL.strLocationName + CHAR(13)
					END + CASE 
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
					ELSE CL.strStateProvince + ' '
					END + CASE 
					WHEN ISNULL(CL.strZipPostalCode, '') = ''
						THEN ''
					ELSE CL.strZipPostalCode + CHAR(13)
					END + CASE 
					WHEN ISNULL(CL.strCountry, '') = ''
						THEN ''
					ELSE CL.strCountry
					END)) AS strDepositor
		,LTRIM(RTRIM(CASE 
					WHEN ISNULL(E.strName, '') = ''
						THEN ''
					ELSE E.strName + CHAR(13)
					END + CASE 
					WHEN ISNULL(EL.strLocationName, '') = ''
						THEN ''
					ELSE EL.strLocationName + CHAR(13)
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
					ELSE EL.strState + ' '
					END + CASE 
					WHEN ISNULL(EL.strZipCode, '') = ''
						THEN ''
					ELSE EL.strZipCode + CHAR(13)
					END + CASE 
					WHEN ISNULL(EL.strCountry, '') = ''
						THEN ''
					ELSE EL.strCountry
					END)) AS strReceivedFrom
		,R.strReceiptNumber
		,R.strWarehouseRefNo AS strOrderShipmentNo
		,CONVERT(VARCHAR(10), R.dtmReceiptDate, 101) AS dtmReceiptDate
		,R.strVendorRefNo AS strCustomerOrderNo
		,S.strShipVia AS strCarrier
		,R.strVessel AS strTrailer
		,I.strItemNo
		,I.strDescription
		,(
			CASE 
				WHEN ISNULL(RIL.strContainerNo, '') = ''
					THEN RIL.strGarden
				ELSE RIL.strContainerNo + ' / ' + RIL.strGarden
				END
			) AS strContainerSealNo
		,RIL.strParentLotNumber
		,RIL.strLotNumber
		,RIL.dblGrossWeight
		,(ISNULL(RIL.dblGrossWeight, 0) - ISNULL(RIL.dblTareWeight, 0)) AS dblNetWeight
		,RIL.dblQuantity
		,UOM.strUnitMeasure
	FROM tblICInventoryReceipt R
	LEFT JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = R.intInventoryReceiptId
	LEFT JOIN tblICInventoryReceiptItemLot RIL ON RIL.intInventoryReceiptItemId = RI.intInventoryReceiptItemId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = R.intLocationId
	LEFT JOIN tblEMEntity E ON E.intEntityId = R.intEntityVendorId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = E.intEntityId
	LEFT JOIN tblSMShipVia S ON S.intEntityShipViaId = R.intShipViaId
	LEFT JOIN tblICItem I ON I.intItemId = RI.intItemId
	LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = RIL.intItemUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	WHERE R.strReceiptNumber = @strReceiptNo
END
