CREATE PROCEDURE uspMFWOStagingPickListReport
			@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @intOrderHeaderId			INT
		   ,@idoc						INT
	DECLARE @strCompanyName				NVARCHAR(100),
			@strCompanyAddress			NVARCHAR(100),
			@strContactName				NVARCHAR(50),
			@strCounty					NVARCHAR(25),
			@strCity					NVARCHAR(25),
			@strState					NVARCHAR(50),
			@strZip						NVARCHAR(12),
			@strCountry					NVARCHAR(25),
			@strPhone					NVARCHAR(50)
						
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
		,L.strLotNumber
		,L.intLotId
		,PL.strParentLotNumber
		,T.intFromStorageLocationId
		,FSL.strName AS strFromStorageLocation
		,T.intToStorageLocationId
		,TSL.strName AS strToStorageLocation
		,OH.strOrderNo
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
	FROM tblMFOrderHeader OH
	JOIN tblMFTask T ON T.intOrderHeaderId = OH.intOrderHeaderId
	JOIN tblMFTaskType TT ON TT.intTaskTypeId = T.intTaskTypeId
	JOIN tblICItem I ON I.intItemId = T.intItemId
	JOIN tblICLot L ON L.intLotId = T.intLotId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = T.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN tblICStorageLocation FSL ON FSL.intStorageLocationId = T.intFromStorageLocationId
	LEFT JOIN tblICStorageLocation TSL ON TSL.intStorageLocationId = T.intToStorageLocationId
	LEFT JOIN tblSMUserSecurity US ON US.intEntityUserSecurityId = T.intAssigneeId
	WHERE OH.intOrderHeaderId = @intOrderHeaderId
END