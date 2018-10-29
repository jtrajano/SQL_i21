CREATE PROCEDURE uspMFGetRecipeInputAndOutputItem (
	@intItemId INT
	,@dblQuantity NUMERIC(24, 10)
	,@intQuantityItemUOMId INT
	,@intLocationId INT
	,@intWorkOrderId INT
	,@strType NVARCHAR(1)
	,@dblPartialQuantity NUMERIC(24, 10) = 0
	)
AS
BEGIN
	DECLARE @strPackagingCategory NVARCHAR(50)
		,@intPackagingCategoryId INT
		,@intPMCategoryId INT
		,@intManufacturingProcessId INT
		,@ysnProducedQtyByWeight BIT = 1
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@dblCalculatedOutputQuantity NUMERIC(24, 10)
		,@dblCalculatedInputQuantity NUMERIC(24, 10)

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @intPMCategoryId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	IF @intPMCategoryId IS NULL
	BEGIN
		SELECT @intPMCategoryId = 0
			,@strPackagingCategory = ''
	END

	SELECT @strPackagingCategory = strCategoryCode
	FROM tblICCategory
	WHERE intCategoryId = @intPMCategoryId

	IF @intPMCategoryId IS NULL
	BEGIN
		SELECT @intPMCategoryId = 0
			,@strPackagingCategory = ''
	END

	IF @strType = 'I'
	BEGIN
		SELECT @dblCalculatedOutputQuantity = dblQuantity
			,@intQuantityItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblCalculatedInputQuantity = dblCalculatedQuantity
		FROM tblMFWorkOrderRecipeItem
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intItemId

		SELECT @dblQuantity = (@dblCalculatedOutputQuantity / @dblCalculatedInputQuantity) * @dblQuantity
	END

	SELECT 
		I.intItemId
		,I.strItemNo AS strActualItem
		,I.strDescription AS strActualDescription
		,CASE 
			WHEN C.strCategoryCode = @strPackagingCategory
				AND @ysnProducedQtyByWeight = 1
				AND P.dblMaxWeightPerPack > 0
				THEN (
						CASE 
							WHEN 1 = 1
								THEN (
										CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / P.dblMaxWeightPerPack)) + CASE 
													WHEN ri.ysnPartialFillConsumption = 1
														THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / P.dblMaxWeightPerPack))
													ELSE 0
													END) AS NUMERIC(38, 20))
										)
							ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
							END
						)
			WHEN C.strCategoryCode = @strPackagingCategory
				THEN (
						CASE 
							WHEN 1 = 1
								THEN (
										CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / r.dblQuantity)) + CASE 
													WHEN ri.ysnPartialFillConsumption = 1
														THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / r.dblQuantity))
													ELSE 0
													END) AS NUMERIC(38, 20))
										)
							ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
							END
						)
			ELSE (
					CASE 
						WHEN 1 = 1
							THEN (
									ri.dblCalculatedQuantity * (
										dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / (
											CASE 
												WHEN r.intRecipeTypeId = 1
													THEN r.dblQuantity
												ELSE 1
												END
											)
										) + CASE 
										WHEN ri.ysnPartialFillConsumption = 1
											THEN ri.dblCalculatedQuantity * (
													dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / (
														CASE 
															WHEN r.intRecipeTypeId = 1
																THEN r.dblQuantity
															ELSE 1
															END
														)
													)
										ELSE 0
										END
									)
						ELSE ri.dblCalculatedQuantity
						END
					)
			END AS dblNumberOfUnits
		,IU.intItemUOMId 
		,UM.intUnitMeasureId 
		,UM.strUnitMeasure AS strUnitUOM
		,'' AS strLotNumber
		,'' AS strParentLotNumber
		,'' AS strContainerId
		,0 AS dblTareWeight
		,0 AS dblGrossWeight
		,0 AS dblNetWeight
		,'' AS strWeightUOM
		,0 AS dblWeightPerUnit
		,'' AS strReferenceNo
		,'' AS strRemarks
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 2

	SELECT 0 as intStorageLocationId 
		,'' AS strStorageUnit
		,I.intItemId
		,I.strItemNo
		,I.strDescription
		,CASE 
			WHEN C.strCategoryCode = @strPackagingCategory
				AND @ysnProducedQtyByWeight = 1
				AND P.dblMaxWeightPerPack > 0
				THEN (
						CASE 
							WHEN ri.ysnScaled = 1
								THEN (
										CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / P.dblMaxWeightPerPack)) + CASE 
													WHEN ri.ysnPartialFillConsumption = 1
														THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / P.dblMaxWeightPerPack))
													ELSE 0
													END) AS NUMERIC(38, 20))
										)
							ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
							END
						)
			WHEN C.strCategoryCode = @strPackagingCategory
				THEN (
						CASE 
							WHEN ri.ysnScaled = 1
								THEN (
										CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / r.dblQuantity)) + CASE 
													WHEN ri.ysnPartialFillConsumption = 1
														THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / r.dblQuantity))
													ELSE 0
													END) AS NUMERIC(38, 20))
										)
							ELSE CAST(CEILING(ri.dblCalculatedQuantity) AS NUMERIC(38, 20))
							END
						)
			ELSE (
					CASE 
						WHEN ri.ysnScaled = 1
							THEN (
									ri.dblCalculatedQuantity * (
										dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / (
											CASE 
												WHEN r.intRecipeTypeId = 1
													THEN r.dblQuantity
												ELSE 1
												END
											)
										) + CASE 
										WHEN ri.ysnPartialFillConsumption = 1
											THEN ri.dblCalculatedQuantity * (
													dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / (
														CASE 
															WHEN r.intRecipeTypeId = 1
																THEN r.dblQuantity
															ELSE 1
															END
														)
													)
										ELSE 0
										END
									)
						ELSE ri.dblCalculatedQuantity
						END
					)
			END AS dblInputQty
		,IU.intItemUOMId 
		,UM.intUnitMeasureId 
		,UM.strUnitMeasure
		,'' AS strInputLot
		,0 AS dblAvailableQuantity
		,'' AS strUOM
		,0 AS ysnEmptyOutSource
		,'' AS strFeedTime
		,'' AS strReferenceNo
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
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
END

