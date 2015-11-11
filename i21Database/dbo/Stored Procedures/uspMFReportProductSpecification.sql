CREATE PROCEDURE uspMFReportProductSpecification @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strWorkOrderNo NVARCHAR(50)
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

	SELECT @strWorkOrderNo = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strWorkOrderNo'

	SELECT W.intWorkOrderId
		,W.strWorkOrderNo
		,W.dblQuantity
		,U.strUnitMeasure
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,PS.strParameterName
		,PS.strParameterValue
		,Case When PS.strParameterName='BOM Item' Then dblCalculatedQuantity + dblShrinkage Else NULL End AS dblInputQuantity
		,Case When PS.strParameterName='BOM Item' Then U1.strUnitMeasure Else NULL End AS strInputUnitMeasure
	FROM dbo.tblMFWorkOrder W 
	JOIN dbo.tblICItem I ON W.intItemId = I.intItemId AND W.strWorkOrderNo = @strWorkOrderNo
	JOIN dbo.tblICItemUOM IU ON W.intItemUOMId = IU.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON IU.intUnitMeasureId = U.intUnitMeasureId
	LEFT JOIN dbo.tblMFWorkOrderProductSpecification PS ON W.intWorkOrderId = PS.intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderItem WI ON W.intWorkOrderId = WI.intWorkOrderId
	LEFT JOIN dbo.tblICItem I1 ON WI.intItemId = I1.intItemId
		AND (
			I1.strItemNo = left(PS.strParameterValue, 4)
			OR I1.strItemNo = left(PS.strParameterValue, 8)
			OR I1.strItemNo = left(PS.strParameterValue, 9)
			OR I1.strItemNo = left(PS.strParameterValue, 11)
			)
		AND PS.strParameterName = 'BOM Item'
	LEFT JOIN dbo.tblICItemUOM IU1 ON WI.intItemUOMId = IU1.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure U1 ON IU1.intUnitMeasureId = U1.intUnitMeasureId
	ORDER BY PS.strParameterName

	EXEC sp_xml_removedocument @xmlDocumentId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFReportProductSpecification - ' + ERROR_MESSAGE()

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


