CREATE PROCEDURE uspMFBatchSheetReportDetail @intWorkOrderId INT
AS
DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	DECLARE @intManufacturingProcessId INT
		,@intManufacturingCellId INT
		,@intProductId INT
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intManufacturingProcessId = W.intManufacturingProcessId
		,@intManufacturingCellId = W.intManufacturingCellId
		,@intProductId = W.intItemId
	FROM tblMFWorkOrder W
	WHERE W.intWorkOrderId = @intWorkOrderId

	SELECT I.strItemNo
		,I.strDescription
		,ri.dblQuantity AS dblFullQty
		,ri.dblQuantity AS dblFullQtyAcc
		,'1 2 3 4 5 ' AS strBatches
		,ri.dblQuantity AS dblPartialQty
		,ri.dblQuantity AS dblPartialQtyAcc
		,ri.dblQuantity AS dblTotal
		,'Input Items' AS strItemType
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
		AND ri.intConsumptionMethodId <> 4
	
	UNION
	
	SELECT I.strItemNo
		,I.strDescription
		,ri.dblQuantity AS dblFullQty
		,ri.dblQuantity AS dblFullQtyAcc
		,'1 2 3 4 5 ' AS strBatches
		,ri.dblQuantity AS dblPartialQty
		,ri.dblQuantity AS dblPartialQtyAcc
		,ri.dblQuantity AS dblTotal
		,'Additional Items' AS strItemType
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 1
		AND (
			(
				ri.ysnYearValidationRequired = 1
				AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
					AND ri.dtmValidTo
				)
			OR (
				ri.ysnYearValidationRequired = 0
				AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
					AND DATEPART(dy, ri.dtmValidTo)
				)
			)
		AND ri.intConsumptionMethodId = 4
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspMFBatchSheetReportDetail - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
