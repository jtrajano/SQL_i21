CREATE PROCEDURE uspMFGetRecipeInputAndOutputItem (@strXML NVARCHAR(MAX) = '')
AS
BEGIN TRY
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
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intItemId INT
		,@dblQuantity NUMERIC(24, 10)
		,@intQuantityItemUOMId INT
		,@intLocationId INT
		,@intWorkOrderId INT
		,@dblPartialQuantity NUMERIC(24, 10)
		,@strType NVARCHAR(1)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intWorkOrderId = intWorkOrderId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intWorkOrderId INT
			)

	DECLARE @tblMFProduceItem TABLE (
		intId INT identity(1, 1)
		,intItemId INT
		,dblQuantity NUMERIC(24, 10)
		,intQuantityItemUOMId INT
		,dblTareWeight NUMERIC(24, 10)
		,dblGrossWeight NUMERIC(24, 10)
		,dblNetWeight NUMERIC(24, 10)
		,intWeightItemUOMId INT
		,dblWeightPerUnit NUMERIC(24, 10)
		,ysnFillPartialPallet BIT
		,ysnSelected BIT
		,intStorageLocationId INT
		,strLotNumber NVARCHAR(50)
		,strParentLotNumber NVARCHAR(50)
		,strContainerId NVARCHAR(50)
		,strReferenceNo NVARCHAR(50)
		,strRemarks NVARCHAR(MAX)
		)
	DECLARE @tblMFConsumeItem TABLE (
		intId INT identity(1, 1)
		,intItemId INT
		,dblQuantity NUMERIC(24, 10)
		,intQuantityItemUOMId INT
		,ysnSelected BIT
		,intStorageLocationId INT
		,intContainerId INT
		,strLotNumber NVARCHAR(50)
		,ysnEmptyOutSource BIT
		,dtmFeedTime DATETIME
		,strReferenceNo NVARCHAR(50)
		)

	INSERT INTO @tblMFProduceItem (
		intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,ysnFillPartialPallet
		,ysnSelected
		,dblTareWeight
		,dblGrossWeight
		,dblNetWeight
		,intWeightItemUOMId
		,dblWeightPerUnit
		,intStorageLocationId
		,strLotNumber
		,strParentLotNumber
		,strContainerId
		,strReferenceNo
		,strRemarks
		)
	SELECT intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,IsNULL(ysnFillPartialPallet,0)
		,IsNULL(ysnSelected,0)
		,dblTareWeight
		,dblGrossWeight
		,dblNetWeight
		,intWeightItemUOMId
		,dblWeightPerUnit
		,intStorageLocationId
		,strLotNumber
		,strParentLotNumber
		,strContainerId
		,strReferenceNo
		,strRemarks
	FROM OPENXML(@idoc, 'root/Produces/Produce', 2) WITH (
			intItemId INT
			,dblQuantity NUMERIC(24, 10)
			,intQuantityItemUOMId INT
			,ysnFillPartialPallet BIT
			,ysnSelected BIT
			,dblTareWeight NUMERIC(24, 10)
			,dblGrossWeight NUMERIC(24, 10)
			,dblNetWeight NUMERIC(24, 10)
			,intWeightItemUOMId INT
			,dblWeightPerUnit NUMERIC(24, 10)
			,intStorageLocationId INT
			,strLotNumber NVARCHAR(50)
			,strParentLotNumber NVARCHAR(50)
			,strContainerId NVARCHAR(50)
			,strReferenceNo NVARCHAR(50)
			,strRemarks NVARCHAR(MAX)
			)

	INSERT INTO @tblMFConsumeItem (
		intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,ysnSelected
		,intStorageLocationId
		,intContainerId
		,strLotNumber
		,ysnEmptyOutSource
		,dtmFeedTime
		,strReferenceNo
		)
	SELECT intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,IsNULL(ysnSelected,0)
		,intStorageLocationId
		,intContainerId
		,strLotNumber
		,IsNULL(ysnEmptyOutSource,0)
		,dtmFeedTime
		,strReferenceNo
	FROM OPENXML(@idoc, 'root/Consumes/Consume', 2) WITH (
			intItemId INT
			,dblQuantity NUMERIC(24, 10)
			,intQuantityItemUOMId INT
			,ysnSelected BIT
			,intStorageLocationId INT
			,intContainerId INT
			,strLotNumber NVARCHAR(50)
			,ysnEmptyOutSource BIT
			,dtmFeedTime DATETIME
			,strReferenceNo NVARCHAR(50)
			)

	SELECT @intItemId = intItemId
		,@dblQuantity = CASE 
			WHEN ysnFillPartialPallet = 0
				THEN dblQuantity
			ELSE 0
			END
		,@intQuantityItemUOMId = intQuantityItemUOMId
		,@dblPartialQuantity = CASE 
			WHEN ysnFillPartialPallet = 1
				THEN dblQuantity
			ELSE 0
			END
		,@strType = 'O'
	FROM @tblMFProduceItem
	WHERE ysnSelected = 1

	IF @intItemId IS NULL
	BEGIN
		SELECT @intItemId = intItemId
			,@dblQuantity = dblQuantity
			,@intQuantityItemUOMId = intQuantityItemUOMId
			,@strType = 'I'
		FROM @tblMFConsumeItem
		WHERE ysnSelected = 1
	END

	IF @intItemId IS NULL
	BEGIN
		RAISERROR (
				'Item can not be blank. Please choose an item and click on auto fill.'
				,16
				,1
				,'WITH NOWAIT'
				)
	END

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

	SELECT Prod.intStorageLocationId
		,SL.strName AS strStorageUnit
		,SL.intSubLocationId AS intSubLocationId
		,I.intItemId
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
		,IU.intItemUOMId AS intUnitItemUOMId
		,UM.intUnitMeasureId AS intUnitUOMId
		,UM.strUnitMeasure AS strUnitUOM
		,Prod.strLotNumber
		,Prod.strParentLotNumber
		,Prod.strContainerId
		,Prod.dblTareWeight
		,Prod.dblGrossWeight
		,Prod.dblNetWeight
		,IU.intItemUOMId AS intWeightItemUOMId
		,UM.intUnitMeasureId AS intWeightUOMId
		,UM.strUnitMeasure AS strWeightUOM
		,Prod.dblWeightPerUnit
		,Prod.strReferenceNo AS strReferenceNo
		,Prod.strRemarks AS strRemarks
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
	LEFT JOIN @tblMFProduceItem Prod ON Prod.intItemId = I.intItemId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = Prod.intStorageLocationId
	LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = Prod.intWeightItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 2

	SELECT Cont.intContainerId
		,Cont.strContainerId
		,Cons.intStorageLocationId
		,SL.strName AS strStorageUnit
		,SL.intSubLocationId AS intSubLocationId
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
			END AS dblInputQuantity
		,IU.intItemUOMId
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,Cons.strLotNumber AS strInputLot
		,0 AS dblAvailableQuantity
		,UM.strUnitMeasure AS strUOM
		,Cons.ysnEmptyOutSource
		,Cons.dtmFeedTime
		,Cons.strReferenceNo
		,GETDATE() AS dtmActualInputDateTime
	FROM dbo.tblMFWorkOrderRecipeItem ri
	JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
		AND r.intWorkOrderId = ri.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
	JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
	LEFT JOIN @tblMFConsumeItem Cons ON Cons.intItemId = I.intItemId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = Cons.intStorageLocationId
	LEFT JOIN tblICContainer Cont ON Cont.intContainerId = Cons.intContainerId
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

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
