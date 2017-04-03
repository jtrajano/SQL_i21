CREATE PROCEDURE uspMFReportToteLabel @xmlParam NVARCHAR(MAX) = NULL
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
		,@intPropertyId1 INT
		,@strPropertyName1 NVARCHAR(100)
		,@strPropertyValue1 NVARCHAR(50)
		,@intPropertyId2 INT
		,@strPropertyName2 NVARCHAR(100)
		,@strPropertyValue2 NVARCHAR(50)
		,@intPropertyId3 INT
		,@strPropertyName3 NVARCHAR(100)
		,@strPropertyValue3 NVARCHAR(50)
		,@intPropertyId4 INT
		,@strPropertyName4 NVARCHAR(100)
		,@strPropertyValue4 NVARCHAR(50)

	SELECT @intLotId = intLotId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strLotNumber

	SELECT @intPropertyId1 = P.intPropertyId
		,@strPropertyName1 = P.strPropertyName
	FROM tblQMReportProperty RP
	JOIN dbo.tblQMProperty P ON P.intPropertyId = RP.intPropertyId
	WHERE strReportName = 'Tote Label'
		AND intSequenceNo = 1

	SELECT @intPropertyId2 = P.intPropertyId
		,@strPropertyName2 = P.strPropertyName
	FROM tblQMReportProperty RP
	JOIN dbo.tblQMProperty P ON P.intPropertyId = RP.intPropertyId
	WHERE strReportName = 'Tote Label'
		AND intSequenceNo = 2

	SELECT @intPropertyId3 = P.intPropertyId
		,@strPropertyName3 = P.strPropertyName
	FROM tblQMReportProperty RP
	JOIN dbo.tblQMProperty P ON P.intPropertyId = RP.intPropertyId
	WHERE strReportName = 'Tote Label'
		AND intSequenceNo = 3

	SELECT @intPropertyId4 = P.intPropertyId
		,@strPropertyName4 = P.strPropertyName
	FROM tblQMReportProperty RP
	JOIN dbo.tblQMProperty P ON P.intPropertyId = RP.intPropertyId
	WHERE strReportName = 'Tote Label'
		AND intSequenceNo = 4

	SELECT @strPropertyValue1 = QTR.strPropertyValue
	FROM dbo.tblQMTestResult QTR
	WHERE QTR.intProductValueId = @intLotId
		AND QTR.intPropertyId = @intPropertyId1

	SELECT @strPropertyValue2 = QTR.strPropertyValue
	FROM dbo.tblQMTestResult QTR
	WHERE QTR.intProductValueId = @intLotId
		AND QTR.intPropertyId = @intPropertyId2

	SELECT @strPropertyValue3 = QTR.strPropertyValue
	FROM dbo.tblQMTestResult QTR
	WHERE QTR.intProductValueId = @intLotId
		AND QTR.intPropertyId = @intPropertyId3

	SELECT @strPropertyValue4 = QTR.strPropertyValue
	FROM dbo.tblQMTestResult QTR
	WHERE QTR.intProductValueId = @intLotId
		AND QTR.intPropertyId = @intPropertyId4

	SELECT DISTINCT L.strLotNumber
		,L.dtmDateCreated
		,US.strUserName
		,I.strItemNo
		,SUBSTRING(I.strDescription, 1, 26) AS strDescription
		,I.strShortName
		,Isnull(C.strContainerNo,SL.strName) AS strName
		,WP.dblQuantity AS dblWeight
		,WP.dblTareWeight
		,WP.dblQuantity + ISNULL(WP.dblTareWeight, 0) AS dblGrossWeight
		,Ltrim(S.intShiftSequence) + ' ' + '(' + CONVERT(NVARCHAR, L.dtmDateCreated, 108) + ')' AS strShiftName
		,ISNULL(@strPropertyName1,'') AS strPropertyName1
		,@strPropertyValue1 AS strPropertyValue1
		,ISNULL(@strPropertyName2,'') AS strPropertyName2
		,@strPropertyValue2 AS strPropertyValue2
		,ISNULL(@strPropertyName3,'') AS strPropertyName3
		,@strPropertyValue3 AS strPropertyValue3
		,ISNULL(@strPropertyName4,'') AS strPropertyName4
		,@strPropertyValue4 AS strPropertyValue4
	FROM dbo.tblICLot AS L
	JOIN dbo.tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityId]
	JOIN dbo.tblICItem I ON L.intItemId = I.intItemId
	JOIN dbo.tblMFWorkOrderProducedLot AS WP ON L.intLotId = WP.intLotId 
	AND WP.intWorkOrderProducedLotId =(Select MAX(WP1.intWorkOrderProducedLotId) From tblMFWorkOrderProducedLot  WP1 Where L.intLotId = WP1.intLotId )
	LEFT JOIN dbo.tblMFShift S ON WP.intShiftId = S.intShiftId
	LEFT JOIN dbo.tblICStorageLocation AS SL ON WP.intStorageLocationId = SL.intStorageLocationId
	LEFT JOIN dbo.tblWHContainer C ON WP.intContainerId = C.intContainerId
	WHERE L.intLotId = @intLotId

	EXEC sp_xml_removedocument @xmlDocumentId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportToteLabel - ' + ERROR_MESSAGE()

	IF @xmlDocumentId <> 0
		EXEC sp_xml_removedocument @xmlDocumentId

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


