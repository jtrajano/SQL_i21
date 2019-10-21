-- Exec uspQMReportLotQualityComparison '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intWorkOrderId</fieldname><condition>EQUAL TO</condition><from>8552</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspQMReportLotQualityComparison
 @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strProcessName NVARCHAR(50) = NULL
		,@strShiftName NVARCHAR(50) = NULL
		,@strItemNo NVARCHAR(50) = NULL
		,@dtmPlannedDate DATETIME = NULL
	DECLARE @intWorkOrderId INT
		,@xmlDocumentId INT
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM dbo.tblSMCompanySetup

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	IF (@xmlParam IS NULL)
	BEGIN
		SELECT NULL intWorkOrderId
			,'INPUT' strInputLot
			,'OUTPUT' strOutputLot
			,NULL strProcessName
			,NULL strShiftName
			,NULL strItemNo
			,NULL dtmPlannedDate
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
			,@strCountry AS strCompanyCountry

		RETURN
	END

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

	SELECT @intWorkOrderId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intWorkOrderId'

	SELECT @strProcessName = MP.strProcessName
		,@strShiftName = S.strShiftName
		,@strItemNo = I.strItemNo
		,@dtmPlannedDate = W.dtmPlannedDate
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE W.intWorkOrderId = @intWorkOrderId
		AND W.dtmPlannedDate IS NOT NULL

	SELECT @intWorkOrderId AS intWorkOrderId
		,'INPUT' AS strInputLot
		,'OUTPUT' AS strOutputLot
		,@strProcessName AS strProcessName
		,@strShiftName AS strShiftName
		,@strItemNo AS strItemNo
		,@dtmPlannedDate AS dtmPlannedDate
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
		,@strCountry AS strCompanyCountry
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportLotQualityComparison - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
