﻿CREATE PROCEDURE uspMFGetRecipeInputAndOutputItem (@strXML NVARCHAR(MAX) = '')
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
		,@intTransferStorageLocationId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intWorkOrderId = intWorkOrderId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intWorkOrderId INT
			)

	SELECT @intTransferStorageLocationId = intStorageLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

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
		,intContainerId INT
		,strReferenceNo NVARCHAR(50)
		,strRemarks NVARCHAR(MAX)
		,strLotAlias NVARCHAR(50)
		,intParentLotId INT
		,strThirdPartyLotNumber NVARCHAR(50)
		,intThirdPartyLotId INT
		)
	DECLARE @tblMFConsumeItem TABLE (
		intId INT identity(1, 1)
		,intItemId INT
		,dblQuantity NUMERIC(24, 10)
		,intQuantityItemUOMId INT
		,ysnSelected BIT
		,intStorageLocationId INT
		,intContainerId INT
		,intInputLotId INT
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
		,intContainerId
		,strReferenceNo
		,strRemarks
		,strLotAlias
		,intParentLotId
		,strThirdPartyLotNumber
		,intThirdPartyLotId
		)
	SELECT intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,IsNULL(ysnFillPartialPallet, 0)
		,IsNULL(ysnSelected, 0)
		,dblTareWeight
		,dblGrossWeight
		,dblNetWeight
		,intWeightItemUOMId
		,dblWeightPerUnit
		,intStorageLocationId
		,strLotNumber
		,strParentLotNumber
		,intContainerId
		,strReferenceNo
		,strRemarks
		,strLotAlias
		,intParentLotId
		,strThirdPartyLotNumber
		,intThirdPartyLotId
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
			,intContainerId INT
			,strReferenceNo NVARCHAR(50)
			,strRemarks NVARCHAR(MAX)
			,strLotAlias NVARCHAR(50)
			,intParentLotId INT
			,strThirdPartyLotNumber NVARCHAR(50)
			,intThirdPartyLotId INT
			)

	INSERT INTO @tblMFConsumeItem (
		intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,ysnSelected
		,intStorageLocationId
		,intContainerId
		,intInputLotId
		,strLotNumber
		,ysnEmptyOutSource
		,dtmFeedTime
		,strReferenceNo
		)
	SELECT intItemId
		,dblQuantity
		,intQuantityItemUOMId
		,IsNULL(ysnSelected, 0)
		,IsNULL(intStorageLocationId, @intTransferStorageLocationId)
		,intContainerId
		,intInputLotId
		,strLotNumber
		,IsNULL(ysnEmptyOutSource, 0)
		,dtmFeedTime
		,strReferenceNo
	FROM OPENXML(@idoc, 'root/Consumes/Consume', 2) WITH (
			intItemId INT
			,dblQuantity NUMERIC(24, 10)
			,intQuantityItemUOMId INT
			,ysnSelected BIT
			,intStorageLocationId INT
			,intContainerId INT
			,intInputLotId INT
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
			,@dblPartialQuantity = 0
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

	SELECT intStorageLocationId
		,strStorageLocationName
		,intStorageSubLocationId
		,intActualItemId
		,strActualItemNo
		,strActualItemDescription
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,intUnitUOMId
		,strPhysicalItemUOM
		,strOutputLotNumber
		,strParentLotNumber
		,intContainerId
		,strContainerId
		,dblTareWeight
		,Case When intWeightItemUOMId is null then dblPhysicalCount*dblWeight Else dblGrossWeight End AS dblGrossWeight
		,Case When intWeightItemUOMId is null then dblPhysicalCount*dblWeight Else dblProduceQty End AS dblProduceQty
		,intActualItemUOMId
		,intActualItemUnitMeasureId
		,strActualItemUnitMeasure
		,Case When intWeightItemUOMId is null then dblWeight Else dblUnitQty End AS dblUnitQty
		,strReferenceNo
		,strComment
		,intRowNo
		,strLotAlias
		,intCategoryId
		,strLotTracking
		,dblPhysicalCount AS dblReadingQuantity
		,ysnFillPartialPallet
		,intParentLotId
		,strLotNumber
		,intLotId
		,intProduceUnitMeasureId
	FROM (
		SELECT SL.intStorageLocationId
			,SL.strName AS strStorageLocationName
			,SL.intSubLocationId AS intStorageSubLocationId
			,I.intItemId AS intActualItemId
			,I.strItemNo AS strActualItemNo
			,I.strDescription AS strActualItemDescription
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
				END AS dblPhysicalCount
			,IU.intItemUOMId AS intPhysicalItemUOMId
			,UM.intUnitMeasureId AS intUnitUOMId
			,UM.strUnitMeasure AS strPhysicalItemUOM
			,Prod.strLotNumber AS strOutputLotNumber
			,Prod.strParentLotNumber
			,Prod.intContainerId
			,Cont.strContainerId
			,Prod.dblTareWeight
			,Prod.dblGrossWeight
			,Prod.dblNetWeight AS dblProduceQty
			,IsNULL(IU1.intItemUOMId,IU2.intItemUOMId) AS intActualItemUOMId
			,UM1.intUnitMeasureId AS intActualItemUnitMeasureId
			,UM1.strUnitMeasure AS strActualItemUnitMeasure
			,Prod.dblWeightPerUnit AS dblUnitQty
			,Prod.strReferenceNo
			,Prod.strRemarks AS strComment
			,CONVERT(INT, Row_Number() OVER (
					ORDER BY ri.intRecipeId DESC
					)) AS intRowNo
			,Prod.strLotAlias
			,C.intCategoryId
			,I.strLotTracking
			,I.dblWeight
			,Prod.ysnFillPartialPallet
			,Prod.intParentLotId
			,Prod.strThirdPartyLotNumber AS strLotNumber
			,Prod.intThirdPartyLotId AS intLotId
			,IsNULL(IU1.intItemUOMId,IU2.intItemUOMId) AS intProduceUnitMeasureId
			,Prod.intWeightItemUOMId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		LEFT JOIN @tblMFProduceItem Prod ON Prod.intItemId = I.intItemId
		LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = IsNULL(Prod.intStorageLocationId,@intTransferStorageLocationId)
		LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId =Prod.intWeightItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId =  IsNULL(IU1.intUnitMeasureId, I.intWeightUOMId)
		LEFT JOIN dbo.tblICItemUOM IU2 ON IU2.intItemId =I.intItemId and IU2.intUnitMeasureId=UM1.intUnitMeasureId
		LEFT JOIN tblICContainer Cont ON Cont.intContainerId = Prod.intContainerId
		WHERE r.intWorkOrderId = @intWorkOrderId
			AND ri.intRecipeItemTypeId = 2
		) AS DT

	SELECT Cont.intContainerId
		,Cont.strContainerId
		,Cons.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,SL.intSubLocationId AS intStorageSubLocationId
		,I.intItemId AS intInputItemId
		,I.strItemNo AS strInputItemNo
		,I.strDescription AS strInputItemDescription
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
		,IU.intItemUOMId AS intInputItemUOMId
		,UM.intUnitMeasureId
		,UM.strUnitMeasure AS strInputItemUnitMeasure
		,Cons.intInputLotId AS intInputLotId
		,Cons.strLotNumber AS strInputLotNumber
		,0.0 AS dblInputLotQuantity
		,UM.strUnitMeasure AS strInputLotUnitMeasure
		,Cons.ysnEmptyOutSource
		,Cons.dtmFeedTime
		,Cons.strReferenceNo
		,GETDATE() AS dtmActualInputDateTime
		,CONVERT(INT, Row_Number() OVER (
				ORDER BY ri.intRecipeId DESC
				)) AS intRowNo
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
			END AS dblReadingQuantity
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
