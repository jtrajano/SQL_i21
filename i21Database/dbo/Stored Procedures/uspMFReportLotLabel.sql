CREATE PROCEDURE uspMFReportLotLabel @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strLotNumber NVARCHAR(50)
		,@xmlDocumentId INT

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

	SELECT @strLotNumber = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLotNumber'

	DECLARE @strCaffeineValue NVARCHAR(10)
		,@strMoistureValue NVARCHAR(10)
		,@intLotId INT
		,@strDensityValue NVARCHAR(10)
		,@strColorValue NVARCHAR(10)
		,@strReworkCommentsValue NVARCHAR(10)

	SELECT @intLotId = intLotId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strLotNumber

	SELECT @strCaffeineValue = ISNULL(QTR.strPropertyValue, '')
	FROM dbo.tblQMTestResult QTR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = QTR.intPropertyId
	WHERE P.strPropertyName = 'Caffeine'
		AND QTR.intProductValueId = @intLotId

	SELECT @strMoistureValue = ISNULL(QTR.strPropertyValue, '')
	FROM dbo.tblQMTestResult QTR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = QTR.intPropertyId
	WHERE P.strPropertyName = 'Moisture'
		AND QTR.intProductValueId = @intLotId

	SELECT @strDensityValue = ISNULL(QTR.strPropertyValue, '')
	FROM dbo.tblQMTestResult QTR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = QTR.intPropertyId
	WHERE P.strPropertyName = 'Density'
		AND QTR.intProductValueId = @intLotId

	SELECT @strColorValue = ISNULL(QTR.strPropertyValue, '')
	FROM dbo.tblQMTestResult QTR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = QTR.intPropertyId
	WHERE P.strPropertyName = 'Color'
		AND QTR.intProductValueId = @intLotId

	SELECT @strReworkCommentsValue = ISNULL(QTR.strPropertyValue, '')
	FROM dbo.tblQMTestResult QTR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = QTR.intPropertyId
	WHERE P.strPropertyName = 'Rework Comments'
		AND QTR.intProductValueId = @intLotId

	SELECT DISTINCT L.dtmDateCreated
		,US.strUserName
		,I.strItemNo
		,I.strDescription
		,I.strShortName
		,S.intShiftSequence
		,IC.strName
		,CASE 
			WHEN L.intWeightUOMId IS NOT NULL
				THEN L.dblWeight
			ELSE dblQty
			END dblWeight
		,L.strVendorLotNo
		,WP.strParentLotNumber
		,UM.strUnitMeasure
		,L.strLotNumber
		,@strCaffeineValue strCaffeineValue
		,@strMoistureValue strMoistureValue
		,WP.dblTareWeight
		,WP.dblQuantity + ISNULL(WP.dblTareWeight, 0) AS dblGrossWeight
		,Ltrim(S.intShiftSequence) + ' ' + '(' + CONVERT(NVARCHAR, L.dtmDateCreated, 108) + ')' AS strShiftName
		,strContainerNo
		,@strDensityValue AS strDensityValue
		,@strColorValue AS strColorValue
		,@strReworkCommentsValue AS strReworkCommentsValue
	FROM dbo.tblICLot AS L
	JOIN dbo.tblSMUserSecurity US ON L.intCreatedUserId = US.intEntityUserSecurityId
	JOIN dbo.tblICItem I ON L.intItemId = I.intItemId
	JOIN dbo.tblMFWorkOrderProducedLot AS WP ON L.intLotId = WP.intLotId
	LEFT JOIN dbo.tblMFShift S ON WP.intShiftId = S.intShiftId
	LEFT JOIN dbo.tblICStorageLocation AS IC ON WP.intStorageLocationId = IC.intStorageLocationId
	LEFT JOIN dbo.tblWHContainer C ON WP.intContainerId = C.intContainerId
	JOIN dbo.tblICItemUOM IU ON IsNULL(L.intWeightUOMId, L.intItemUOMId) = IU.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
	WHERE L.intLotId = @intLotId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportLotLabel - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


