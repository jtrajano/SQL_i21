CREATE PROCEDURE uspMFWOStagingPickListReport @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @intOrderHeaderId INT
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
		,@strInventoryShipmentNo NVARCHAR(100)
		,@intInventoryShipmentId INT
		,@strShipmentPickListNotes NVARCHAR(MAX) = ''
		,@intCustomerEntityId INT

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

	SELECT @intOrderHeaderId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intOrderHeaderId'

	SELECT @strInventoryShipmentNo = strReferenceNo
	FROM tblMFOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @intInventoryShipmentId = intInventoryShipmentId
		,@intCustomerEntityId = intEntityCustomerId
	FROM tblICInventoryShipment
	WHERE strShipmentNumber = @strInventoryShipmentNo

	IF ISNULL(@intCustomerEntityId, 0) <> 0
	BEGIN
		SELECT TOP 1 @strShipmentPickListNotes = Replace(Replace(CONVERT(VARCHAR(max), blbMessage), '<p>', ''), '</p>', '')
		FROM tblSMDocumentMaintenance DM
		JOIN tblSMDocumentMaintenanceMessage DMM ON DM.intDocumentMaintenanceId = DMM.intDocumentMaintenanceId
		WHERE intEntityCustomerId = @intCustomerEntityId
	END

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

	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,T.dblQty
		,TT.strTaskType
		,UM.strUnitMeasure AS strPickQtyUnitMeasure
		,T.dblWeight
		,WUM.strUnitMeasure AS strPickWeightUnitMeasure
		,L.strLotNumber
		,L.intLotId
		,PL.strParentLotNumber
		,T.intFromStorageLocationId
		,FSL.strName AS strFromStorageLocation
		,T.intToStorageLocationId
		,TSL.strName AS strToStorageLocation
		--,CASE WHEN OH.intOrderTypeId = 5 THEN OH.strReferenceNo ELSE OH.strOrderNo END strOrderNo
		,OH.strOrderNo AS strOrderNo
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strContactName AS strCompanyContactName
		,@strCounty AS strCompanyCounty
		,@strCity AS strCompanyCity
		,@strState AS strCompanyState
		,@strZip AS strCompanyZip
		,@strCountry AS strCompanyCountry
		,@strPhone AS strCompanyPhone
		,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
		,US.strUserName AS strAssignedTo
		,@strShipmentPickListNotes AS strShipmentPickListNotes
		,OH.strReferenceNo
		,OH.strComment AS strInstruction
	FROM tblMFOrderHeader OH
	JOIN tblMFTask T ON T.intOrderHeaderId = OH.intOrderHeaderId
	JOIN tblMFTaskType TT ON TT.intTaskTypeId = T.intTaskTypeId
	JOIN tblICItem I ON I.intItemId = T.intItemId
	JOIN tblICLot L ON L.intLotId = T.intLotId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = T.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItemUOM WIU ON WIU.intItemUOMId = T.intWeightUOMId
	LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WIU.intUnitMeasureId
	LEFT JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN tblICStorageLocation FSL ON FSL.intStorageLocationId = T.intFromStorageLocationId
	LEFT JOIN tblICStorageLocation TSL ON TSL.intStorageLocationId = T.intToStorageLocationId
	LEFT JOIN tblSMUserSecurity US ON US.intEntityUserSecurityId = T.intAssigneeId
	WHERE OH.intOrderHeaderId = @intOrderHeaderId
END
