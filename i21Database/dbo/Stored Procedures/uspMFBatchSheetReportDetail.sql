CREATE PROCEDURE uspMFBatchSheetReportDetail @intWorkOrderId INT
AS
DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	DECLARE @intManufacturingProcessId INT
		,@intManufacturingCellId INT
		,@intStdUnitMeasureId INT
		,@intProductId INT
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@intLocationId INT
		,@dblConvertedWOQty NUMERIC(18, 6)
		,@dblBatchSize NUMERIC(18, 6)
		,@dblPartialQuantity NUMERIC(18, 6)
		,@intNoOfBatches INT
	DECLARE @tblMFItems TABLE (
		intId INT IDENTITY(1, 1)
		,intItemId INT
		,dblQuantity NUMERIC(18, 6)
		,ysnAdditionalItem BIT
		,dblPartialQuantity NUMERIC(18, 6)
		)
	DECLARE @strBatches NVARCHAR(MAX)
		,@startnum INT
		,@endnum INT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intManufacturingProcessId = W.intManufacturingProcessId
		,@intManufacturingCellId = W.intManufacturingCellId
		,@intProductId = W.intItemId
		,@intLocationId = W.intLocationId
		,@dblBatchSize = W.dblBatchSize
	FROM tblMFWorkOrder W
	WHERE W.intWorkOrderId = @intWorkOrderId

	SELECT @dblConvertedWOQty = dbo.fnCTConvertQuantityToTargetItemUOM(W.intItemId, IUOM.intUnitMeasureId, MC.intStdUnitMeasureId, W.dblQuantity)
		,@intStdUnitMeasureId = MC.intStdUnitMeasureId
	FROM tblMFWorkOrder W
	JOIN tblMFManufacturingCell MC ON MC.intManufacturingCellId = W.intManufacturingCellId
	JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = W.intItemUOMId
	WHERE W.intWorkOrderId = @intWorkOrderId

	SELECT @intNoOfBatches = @dblConvertedWOQty / @dblBatchSize

	SELECT @startnum = 1
		,@endnum = @intNoOfBatches;

	WITH CTE
	AS (
		SELECT @startnum AS num
		
		UNION ALL
		
		SELECT num + 1
		FROM CTE
		WHERE num + 1 <= @endnum
		)
	SELECT @strBatches = COALESCE(@strBatches + ' ', '') + CONVERT(NVARCHAR, num)
	FROM CTE

	IF @intNoOfBatches = 0
		SELECT @strBatches = ''

	SELECT @dblPartialQuantity = @dblConvertedWOQty % @dblBatchSize

	DELETE
	FROM @tblMFItems

	INSERT INTO @tblMFItems (
		intItemId
		,dblQuantity
		,ysnAdditionalItem
		,dblPartialQuantity
		)
	SELECT I.intItemId
		,(
			CASE 
				WHEN ISNULL(UM.strUnitType, '') = 'Weight'
					THEN dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, UM.intUnitMeasureId, @intStdUnitMeasureId, (ri.dblCalculatedQuantity / dbo.fnCTConvertQuantityToTargetItemUOM(r.intItemId, @intStdUnitMeasureId, UM1.intUnitMeasureId, r.dblQuantity))) * @dblBatchSize
				ELSE (@dblBatchSize / dbo.fnCTConvertQuantityToTargetItemUOM(r.intItemId, @intStdUnitMeasureId, UM1.intUnitMeasureId, r.dblQuantity)) * ri.dblCalculatedQuantity
				END
			)
		,(
			CASE 
				WHEN ISNULL(UM.strUnitType, '') = 'Weight'
					THEN 0
				ELSE 1
				END
			) AS ysnAdditionalItem
		,(
			CASE 
				WHEN ISNULL(UM.strUnitType, '') = 'Weight'
					THEN dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, UM.intUnitMeasureId, @intStdUnitMeasureId, (ri.dblCalculatedQuantity / dbo.fnCTConvertQuantityToTargetItemUOM(r.intItemId, @intStdUnitMeasureId, UM1.intUnitMeasureId, r.dblQuantity))) * @dblPartialQuantity
				ELSE (@dblPartialQuantity / dbo.fnCTConvertQuantityToTargetItemUOM(r.intItemId, @intStdUnitMeasureId, UM1.intUnitMeasureId, r.dblQuantity)) * ri.dblCalculatedQuantity
				END
			)
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intLocationId = @intLocationId
		AND r.ysnActive = 1
		AND r.intItemId = @intProductId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = r.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	WHERE ri.intRecipeItemTypeId = 1
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

	SELECT I.strItemNo
		,I.strDescription
		,CASE 
			WHEN @intNoOfBatches > 0
				THEN t.dblQuantity
			ELSE 0
			END AS dblFullQty
		,CASE 
			WHEN @intNoOfBatches > 0
				THEN CASE 
						WHEN t.ysnAdditionalItem = 0
							THEN SUM(t.dblQuantity) OVER (
									PARTITION BY t.ysnAdditionalItem ORDER BY t.intId
									)
						ELSE NULL
						END
			ELSE 0
			END AS dblFullQtyAcc
		,@strBatches AS strBatches
		,t.dblPartialQuantity AS dblPartialQty
		,CASE 
			WHEN t.ysnAdditionalItem = 0
				THEN SUM(t.dblPartialQuantity) OVER (
						PARTITION BY t.ysnAdditionalItem ORDER BY t.intId
						)
			ELSE NULL
			END AS dblPartialQtyAcc
		,@intNoOfBatches AS intNoOfBatches
		,CASE 
			WHEN t.ysnAdditionalItem = 0
				THEN ISNULL((t.dblQuantity * @intNoOfBatches), 0) + ISNULL(t.dblPartialQuantity, 0)
			ELSE NULL
			END AS dblTotal
		,CASE 
			WHEN t.ysnAdditionalItem = 0
				THEN 'Input Items'
			ELSE 'Additional Items'
			END AS strItemType
		,t.ysnAdditionalItem
		,t.intId
	FROM @tblMFItems t
	JOIN dbo.tblICItem I ON I.intItemId = t.intItemId
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
