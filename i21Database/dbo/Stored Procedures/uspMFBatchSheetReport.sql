CREATE PROCEDURE uspMFBatchSheetReport @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@xmlDocumentId INT
	DECLARE @intWorkOrderId INT
		,@dblConvertedWOQty NUMERIC(18, 6)

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

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2) WITH (
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

	SELECT @dblConvertedWOQty = dbo.fnCTConvertQuantityToTargetItemUOM(W.intItemId, IUOM.intUnitMeasureId, MC.intStdUnitMeasureId, W.dblQuantity)
	FROM tblMFWorkOrder W
	JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = W.intItemUOMId
	WHERE W.intWorkOrderId = @intWorkOrderId

	SELECT W.intWorkOrderId
		,W.strWorkOrderNo
		,I.strItemNo
		,I.strDescription
		,W.dblQuantity
		,UOM.strUnitMeasure
		,NULL AS dblActual
		,W.dblBatchSize
		,MCUOM.strUnitMeasure AS strBatchSizeUOM
		,(@dblConvertedWOQty / W.dblBatchSize) AS dblNoOfBatches
		,@strCompanyName AS strCompanyName
	FROM tblMFWorkOrder W
	JOIN tblICItem I ON I.intItemId = W.intItemId
		AND W.intWorkOrderId = @intWorkOrderId
	JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = W.intItemUOMId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	JOIN tblICUnitMeasure MCUOM ON MCUOM.intUnitMeasureId = MC.intStdUnitMeasureId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFBatchSheetReport - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
