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
		,@intTransferStorageLocationId INT
		,@intProductId INT
		,@dblCalculatedQuantity DECIMAL(24, 10)
		,@ysnSubstituteItem BIT
		,@intMainItemId INT
		,@strWorkOrderNo NVARCHAR(50) 
		,@dblTareWeight DECIMAL(24, 10)
		,@dblGrossWeight DECIMAL(24, 10)
		,@dblNetWeight DECIMAL(24, 10)
		,@intWeightItemUOMId int
		,@dblWeightPerUnit DECIMAL(24, 10)
		,@intActualItemUnitMeasureId int
		,@strActualItemUnitMeasure nvarchar(50)
		,@intQuantityUnitMeasureId int
		,@strQuantityUnitMeasure nvarchar(50)

	CREATE TABLE #tblMFConsumptionDetail (
		intContainerId INT
		,strContainerId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intStorageLocationId INT
		,strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intStorageSubLocationId INT
		,intInputItemId INT
		,strInputItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strInputItemDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblInputQuantity NUMERIC(38, 20) NULL
		,intInputItemUOMId INT
		,intUnitMeasureId INT
		,strInputItemUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intInputLotId INT
		,strInputLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblInputLotQuantity NUMERIC(38, 20) NULL
		,strInputLotUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,ysnEmptyOutSource BIT
		,dtmFeedTime DATETIME
		,strReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmActualInputDateTime DATETIME
		,intRowNo INT IDENTITY(1, 1)
		,strInventoryTracking NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,ysnInputItem BIT
		,intMainItemId INT
		)

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

	DELETE
	FROM @tblMFProduceItem
	WHERE ysnSelected = 0
		AND intItemId IN (
			SELECT intItemId
			FROM @tblMFProduceItem
			WHERE ysnSelected = 1
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
		,@dblTareWeight = dblTareWeight
		,@dblGrossWeight = dblGrossWeight
		,@dblNetWeight = dblNetWeight
		,@intWeightItemUOMId = intWeightItemUOMId
		,@dblWeightPerUnit = dblWeightPerUnit
	FROM @tblMFProduceItem
	WHERE ysnSelected = 1

	IF @strType = 'O'
	BEGIN
		SELECT @intActualItemUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intWeightItemUOMId

		SELECT @strActualItemUnitMeasure = strUnitMeasure
		FROM tblICUnitMeasure
		WHERE intUnitMeasureId = @intActualItemUnitMeasureId

		SELECT @intQuantityUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intQuantityItemUOMId

		SELECT @strQuantityUnitMeasure = strUnitMeasure
		FROM tblICUnitMeasure
		WHERE intUnitMeasureId = @intQuantityUnitMeasureId
	END

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
		,@intTransferStorageLocationId = intStorageLocationId
		,@intProductId = intItemId
		,@strWorkOrderNo = strWorkOrderNo
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

	SELECT @ysnSubstituteItem = 0

	IF @strType = 'I'
	BEGIN
		SELECT @dblCalculatedOutputQuantity = dblQuantity
			,@intQuantityItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipeItem
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intProductId
			AND intRecipeItemTypeId = 2

		SELECT @dblCalculatedInputQuantity = dblCalculatedQuantity
			,@ysnSubstituteItem = CASE 
				WHEN rs.intRecipeItemId IS NULL
					THEN 0
				ELSE 1
				END
			,@intMainItemId = rs.intItemId
		FROM tblMFWorkOrderRecipeItem ri
		LEFT JOIN tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND (
				ri.intItemId = @intItemId
				OR rs.intSubstituteItemId = @intItemId
				)

		SELECT @dblQuantity = (@dblCalculatedOutputQuantity / @dblCalculatedInputQuantity) * @dblQuantity
	END

	SELECT @dblCalculatedQuantity = RI.dblCalculatedQuantity
	FROM tblMFWorkOrderRecipeItem RI
	WHERE RI.intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND RI.intItemId = CASE 
			WHEN @strType = 'I'
				THEN @intProductId
			ELSE @intItemId
			END

	IF @dblCalculatedQuantity IS NULL
		SELECT @dblCalculatedQuantity = 1

	SELECT (
			CASE 
				WHEN SL.intStorageLocationId IS NULL
					AND r.intItemId = ri.intItemId
					THEN SL1.intStorageLocationId
				ELSE SL.intStorageLocationId
				END
			) AS intStorageLocationId
		,(
			CASE 
				WHEN SL.intStorageLocationId IS NULL
					AND r.intItemId = ri.intItemId
					THEN SL1.strName
				ELSE SL.strName
				END
			) AS strStorageLocationName
		,(
			CASE 
				WHEN SL.intStorageLocationId IS NULL
					AND r.intItemId = ri.intItemId
					THEN SL1.intSubLocationId
				ELSE SL.intSubLocationId
				END
			) AS intStorageSubLocationId
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
										CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / @dblCalculatedQuantity)) + CASE 
													WHEN ri.ysnPartialFillConsumption = 1
														THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / @dblCalculatedQuantity))
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
													THEN @dblCalculatedQuantity
												ELSE 1
												END
											)
										) + CASE 
										WHEN ri.ysnPartialFillConsumption = 1
											THEN ri.dblCalculatedQuantity * (
													dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / (
														CASE 
															WHEN r.intRecipeTypeId = 1
																THEN @dblCalculatedQuantity
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
		,IsNULL(IU1.intItemUOMId, IU2.intItemUOMId) AS intActualItemUOMId
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
		,IsNULL(IU1.intItemUOMId, IU2.intItemUOMId) AS intProduceUnitMeasureId
		,Prod.intWeightItemUOMId
		,IsNULL(I.intUnitPerLayer * I.intLayerPerPallet, 0) AS intCasesPerPallet
	INTO #ProductionDetail
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
	LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = @intTransferStorageLocationId
	LEFT JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = Prod.intWeightItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IsNULL(IU1.intUnitMeasureId, I.intWeightUOMId)
	LEFT JOIN dbo.tblICItemUOM IU2 ON IU2.intItemId = I.intItemId
		AND IU2.intUnitMeasureId = UM1.intUnitMeasureId
	LEFT JOIN tblICContainer Cont ON Cont.intContainerId = Prod.intContainerId
	WHERE r.intWorkOrderId = @intWorkOrderId
		AND ri.intRecipeItemTypeId = 2

	IF NOT EXISTS (
			SELECT *
			FROM #ProductionDetail
			WHERE intCasesPerPallet > 0
			)
	BEGIN
		SELECT intStorageLocationId
			,strStorageLocationName
			,intStorageSubLocationId
			,intActualItemId
			,strActualItemNo
			,strActualItemDescription
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @dblQuantity
					ELSE dblPhysicalCount
					END
				) AS dblPhysicalCount
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @intQuantityItemUOMId
					ELSE intPhysicalItemUOMId
					END
				) AS intPhysicalItemUOMId
			,intUnitUOMId
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @strQuantityUnitMeasure
					ELSE strPhysicalItemUOM
					END
				)strPhysicalItemUOM
			,strOutputLotNumber
			,strParentLotNumber
			,intContainerId
			,strContainerId
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @dblTareWeight
					ELSE dblTareWeight
					END
				) dblTareWeight
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @dblGrossWeight
					ELSE dblPhysicalCount * dblWeight
					END
				) AS dblGrossWeight
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @dblNetWeight
					ELSE dblPhysicalCount * dblWeight
					END
				) AS dblProduceQty
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @intWeightItemUOMId
					ELSE intActualItemUOMId
					END
				) intActualItemUOMId
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @intActualItemUnitMeasureId
					ELSE intActualItemUnitMeasureId
					END
				) intActualItemUnitMeasureId
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @strActualItemUnitMeasure
					ELSE strActualItemUnitMeasure
					END
				) strActualItemUnitMeasure
			,(
				CASE 
					WHEN intActualItemId = @intItemId
						AND @strType = 'O'
						THEN @dblWeightPerUnit
					ELSE dblWeight
					END
				) AS dblUnitQty
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
		FROM #ProductionDetail DT
	END
	ELSE
	BEGIN
		DECLARE @tblMFItem TABLE (
			intItemId INT
			,intNoOfRow INT
			)
		DECLARE @tblMFFinalItem TABLE (
			intItemId INT
			,ysnLastRow BIT
			)
		DECLARE @intItemId2 INT
			,@intNoOfRow INT

		INSERT INTO @tblMFItem
		SELECT intActualItemId
			,CASE 
				WHEN intCasesPerPallet = 0
					THEN 1
				ELSE Ceiling(dblPhysicalCount / intCasesPerPallet)
				END
		FROM #ProductionDetail

		SELECT @intItemId2 = min(intItemId)
		FROM @tblMFItem

		WHILE @intItemId2 IS NOT NULL
		BEGIN
			SELECT @intNoOfRow = 0

			SELECT @intNoOfRow = intNoOfRow
			FROM @tblMFItem
			WHERE intItemId = @intItemId2

			WHILE @intNoOfRow > 0
			BEGIN
				INSERT INTO @tblMFFinalItem (
					intItemId
					,ysnLastRow
					)
				SELECT @intItemId2
					,CASE 
						WHEN @intNoOfRow = 1
							THEN 1
						ELSE 0
						END

				SELECT @intNoOfRow = @intNoOfRow - 1
			END

			SELECT @intItemId2 = min(intItemId)
			FROM @tblMFItem
			WHERE intItemId > @intItemId2
		END

		SELECT intStorageLocationId
			,strStorageLocationName
			,intStorageSubLocationId
			,intActualItemId
			,strActualItemNo
			,strActualItemDescription
			,CASE 
				WHEN ysnLastRow = 1
					AND dblPhysicalCount % intCasesPerPallet <> 0
					THEN dblPhysicalCount % intCasesPerPallet
				ELSE intCasesPerPallet
				END AS dblPhysicalCount
			,intPhysicalItemUOMId
			,intUnitUOMId
			,strPhysicalItemUOM
			,strOutputLotNumber
			,strParentLotNumber
			,intContainerId
			,strContainerId
			,dblTareWeight
			,(
				CASE 
					WHEN ysnLastRow = 1
						AND dblPhysicalCount % intCasesPerPallet <> 0
						THEN dblPhysicalCount % intCasesPerPallet
					ELSE intCasesPerPallet
					END
				) * dblWeight AS dblGrossWeight
			,(
				CASE 
					WHEN ysnLastRow = 1
						AND dblPhysicalCount % intCasesPerPallet <> 0
						THEN dblPhysicalCount % intCasesPerPallet
					ELSE intCasesPerPallet
					END
				) * dblWeight AS dblProduceQty
			,intActualItemUOMId
			,intActualItemUnitMeasureId
			,strActualItemUnitMeasure
			,CASE 
				WHEN intWeightItemUOMId IS NULL
					THEN dblWeight
				ELSE dblUnitQty
				END AS dblUnitQty
			,strReferenceNo
			,strComment
			,CONVERT(INT, Row_Number() OVER (
					ORDER BY DT.intRowNo DESC
					)) AS intRowNo
			,strLotAlias
			,intCategoryId
			,strLotTracking
			,CASE 
				WHEN ysnLastRow = 1
					AND dblPhysicalCount % intCasesPerPallet <> 0
					THEN dblPhysicalCount % intCasesPerPallet
				ELSE intCasesPerPallet
				END AS dblReadingQuantity
			,ysnFillPartialPallet
			,intParentLotId
			,strLotNumber
			,intLotId
			,intProduceUnitMeasureId
		FROM #ProductionDetail DT
		JOIN @tblMFFinalItem I ON I.intItemId = DT.intActualItemId
	END

	IF EXISTS (
			SELECT *
			FROM tblMFStageWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			)
		AND EXISTS (
			SELECT intItemId
			FROM @tblMFProduceItem
			WHERE ysnSelected = 1
			)
	BEGIN
		SELECT NULL AS intContainerId
			,NULL AS strContainerId
			,SL.intStorageLocationId
			,SL.strName AS strStorageLocationName
			,SL.intSubLocationId AS intStorageSubLocationId
			,I.intItemId AS intInputItemId
			,I.strItemNo AS strInputItemNo
			,I.strDescription AS strInputItemDescription
			,T.dblPickQty AS dblInputQuantity
			,T.intItemUOMId AS intInputItemUOMId
			,UM.intUnitMeasureId
			,UM.strUnitMeasure strInputItemUnitMeasure
			,L.intLotId intInputLotId
			,L.strLotNumber strInputLotNumber
			,L.dblQty dblInputLotQuantity
			,UM.strUnitMeasure strInputLotUnitMeasure
			,Convert(BIT, 0) ysnEmptyOutSource
			,GETDATE() AS dtmFeedTime
			,NULL strReferenceNo
			,GETDATE() dtmActualInputDateTime
			,T.intTaskId AS intRowNo
			,T.dblPickQty dblReadingQuantity
			,I.intItemId AS intMainItemId
		FROM tblMFTask T
		JOIN tblMFStageWorkOrder SW ON T.intOrderHeaderId = SW.intOrderHeaderId
			AND SW.intWorkOrderId = @intWorkOrderId
		JOIN tblICLot L ON L.intLotId = T.intLotId
		JOIN tblICItem I ON I.intItemId = L.intItemId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
	END
	ELSE
	BEGIN
		IF @ysnSubstituteItem = 1
			AND @strType = 'I'
		BEGIN
			INSERT INTO #tblMFConsumptionDetail (
				intContainerId
				,strContainerId
				,intStorageLocationId
				,strStorageLocationName
				,intStorageSubLocationId
				,intInputItemId
				,strInputItemNo
				,strInputItemDescription
				,dblInputQuantity
				,intInputItemUOMId
				,intUnitMeasureId
				,strInputItemUnitMeasure
				,intInputLotId
				,strInputLotNumber
				,dblInputLotQuantity
				,strInputLotUnitMeasure
				,ysnEmptyOutSource
				,dtmFeedTime
				,strReferenceNo
				,dtmActualInputDateTime
				,strInventoryTracking
				,ysnInputItem
				,intMainItemId
				)
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
												CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / @dblCalculatedQuantity)) + CASE 
															WHEN ri.ysnPartialFillConsumption = 1
																THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / @dblCalculatedQuantity))
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
															THEN @dblCalculatedQuantity
														ELSE 1
														END
													)
												) + CASE 
												WHEN ri.ysnPartialFillConsumption = 1
													THEN ri.dblCalculatedQuantity * (
															dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / (
																CASE 
																	WHEN r.intRecipeTypeId = 1
																		THEN @dblCalculatedQuantity
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
				,I.strInventoryTracking
				,CONVERT(BIT, 1) AS ysnInputItem
				,I.intItemId
			FROM dbo.tblMFWorkOrderRecipeItem ri
			JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
				AND r.intWorkOrderId = ri.intWorkOrderId
				AND ri.intItemId <> @intMainItemId
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

			INSERT INTO #tblMFConsumptionDetail (
				intContainerId
				,strContainerId
				,intStorageLocationId
				,strStorageLocationName
				,intStorageSubLocationId
				,intInputItemId
				,strInputItemNo
				,strInputItemDescription
				,dblInputQuantity
				,intInputItemUOMId
				,intUnitMeasureId
				,strInputItemUnitMeasure
				,intInputLotId
				,strInputLotNumber
				,dblInputLotQuantity
				,strInputLotUnitMeasure
				,ysnEmptyOutSource
				,dtmFeedTime
				,strReferenceNo
				,dtmActualInputDateTime
				,strInventoryTracking
				,ysnInputItem
				,intMainItemId
				)
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
												CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / @dblCalculatedQuantity)) + CASE 
															WHEN ri.ysnPartialFillConsumption = 1
																THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / @dblCalculatedQuantity))
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
															THEN @dblCalculatedQuantity
														ELSE 1
														END
													)
												) + CASE 
												WHEN ri.ysnPartialFillConsumption = 1
													THEN ri.dblCalculatedQuantity * (
															dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / (
																CASE 
																	WHEN r.intRecipeTypeId = 1
																		THEN @dblCalculatedQuantity
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
				,I.strInventoryTracking
				,CONVERT(BIT, 0) AS ysnInputItem
				,rs.intItemId
			FROM dbo.tblMFWorkOrderRecipeItem ri
			JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
				AND r.intWorkOrderId = ri.intWorkOrderId
				AND ri.intItemId = @intMainItemId
			JOIN dbo.tblMFWorkOrderRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
				AND r.intWorkOrderId = rs.intWorkOrderId
				AND rs.intSubstituteItemId = @intItemId
			JOIN dbo.tblICItem I ON I.intItemId = rs.intSubstituteItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = rs.intItemUOMId
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
		END
		ELSE
		BEGIN
			INSERT INTO #tblMFConsumptionDetail (
				intContainerId
				,strContainerId
				,intStorageLocationId
				,strStorageLocationName
				,intStorageSubLocationId
				,intInputItemId
				,strInputItemNo
				,strInputItemDescription
				,dblInputQuantity
				,intInputItemUOMId
				,intUnitMeasureId
				,strInputItemUnitMeasure
				,intInputLotId
				,strInputLotNumber
				,dblInputLotQuantity
				,strInputLotUnitMeasure
				,ysnEmptyOutSource
				,dtmFeedTime
				,strReferenceNo
				,dtmActualInputDateTime
				,strInventoryTracking
				,ysnInputItem
				,intMainItemId
				)
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
												CAST(CEILING((ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblQuantity) / @dblCalculatedQuantity)) + CASE 
															WHEN ri.ysnPartialFillConsumption = 1
																THEN (ri.dblCalculatedQuantity * (dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / @dblCalculatedQuantity))
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
															THEN @dblCalculatedQuantity
														ELSE 1
														END
													)
												) + CASE 
												WHEN ri.ysnPartialFillConsumption = 1
													THEN ri.dblCalculatedQuantity * (
															dbo.fnMFConvertQuantityToTargetItemUOM(@intQuantityItemUOMId, r.intItemUOMId, @dblPartialQuantity) / (
																CASE 
																	WHEN r.intRecipeTypeId = 1
																		THEN @dblCalculatedQuantity
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
				,I.strInventoryTracking
				,CONVERT(BIT, 1) AS ysnInputItem
				,ri.intItemId
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
		END

		DECLARE @intRowNo INT
			,@dblRequiredQty NUMERIC(24, 10)
			,@intInputItemId INT
			,@strInventoryTracking NVARCHAR(50)
			,@dblAvailableQty NUMERIC(24, 10)
			,@dblShortQty NUMERIC(24, 10)
			,@intInputItemUOMId INT
		DECLARE @tblSubstituteItem TABLE (
			intItemRecordId INT Identity(1, 1)
			,intSubstituteItemId INT
			,dblSubstituteRatio NUMERIC(18, 6)
			,dblMaxSubstituteRatio NUMERIC(18, 6)
			,strInventoryTracking NVARCHAR(50)
			,intSubstituteItemUOMId INT
			)
		DECLARE @intItemRecordId INT
			,@dblSubstituteRatio NUMERIC(18, 6)
			,@dblMaxSubstituteRatio NUMERIC(18, 6)
			,@intSubstituteItemId INT
			,@intSubstituteItemUOMId INT
			,@intUnitMeasureId INT

		SELECT @intRowNo = MIN(intRowNo)
		FROM #tblMFConsumptionDetail
		WHERE ysnInputItem = 1

		WHILE @intRowNo IS NOT NULL
		BEGIN
			SELECT @intInputItemId = NULL
				,@dblRequiredQty = NULL
				,@strInventoryTracking = NULL
				,@intUnitMeasureId = NULL
				,@intInputItemUOMId = NULL
				,@dblAvailableQty = NULL

			SELECT @intInputItemId = intInputItemId
				,@dblRequiredQty = dblInputQuantity
				,@strInventoryTracking = strInventoryTracking
				,@intUnitMeasureId = intUnitMeasureId
				,@intInputItemUOMId = intInputItemUOMId
			FROM #tblMFConsumptionDetail
			WHERE intRowNo = @intRowNo

			IF @strInventoryTracking = 'Lot Level'
			BEGIN
				SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intInputItemUOMId, L.dblQty))
				FROM tblICLot L
				JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					AND SL.ysnAllowConsume = 1
					AND L.dblQty > 0
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId)
					AND R.strInternalCode = 'STOCK'
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE L.intItemId = @intInputItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
			END
			ELSE
			BEGIN
				SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, @intInputItemUOMId, S.dblOnHand - S.dblUnitReserved))
				FROM dbo.tblICItemStockUOM S
				JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
					AND S.dblOnHand - S.dblUnitReserved > 0
				JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
					AND IU.ysnStockUnit = 1
				JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
				WHERE S.intItemId = @intInputItemId
					AND IL.intLocationId = @intLocationId
			END

			IF @dblAvailableQty IS NULL
				SELECT @dblAvailableQty = 0

			IF @dblAvailableQty < @dblRequiredQty
			BEGIN
				SELECT @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

				DELETE
				FROM @tblSubstituteItem

				INSERT INTO @tblSubstituteItem (
					intSubstituteItemId
					,dblSubstituteRatio
					,dblMaxSubstituteRatio
					,strInventoryTracking
					,intSubstituteItemUOMId
					)
				SELECT rs.intSubstituteItemId
					,dblSubstituteRatio
					,dblMaxSubstituteRatio
					,I.strInventoryTracking
					,IU.intItemUOMId
				FROM dbo.tblMFRecipe r
				JOIN dbo.tblMFRecipeItem ri ON r.intRecipeId = ri.intRecipeId
				JOIN dbo.tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
				JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
				JOIN dbo.tblICItemUOM IU ON IU.intItemId = rs.intSubstituteItemId
					AND IU.intUnitMeasureId = @intUnitMeasureId
				WHERE r.intItemId = @intProductId
					AND r.intLocationId = @intLocationId
					AND r.ysnActive = 1
					AND ri.intItemId = @intInputItemId

				IF EXISTS (
						SELECT *
						FROM @tblSubstituteItem
						)
				BEGIN
					SELECT @intItemRecordId = MIN(intItemRecordId)
					FROM @tblSubstituteItem

					WHILE @intItemRecordId IS NOT NULL
					BEGIN
						SELECT @dblSubstituteRatio = NULL
							,@dblMaxSubstituteRatio = NULL
							,@intSubstituteItemId = NULL
							,@strInventoryTracking = NULL
							,@intSubstituteItemUOMId = NULL
							,@dblAvailableQty = NULL

						SELECT @dblSubstituteRatio = dblSubstituteRatio
							,@dblMaxSubstituteRatio = dblMaxSubstituteRatio
							,@intSubstituteItemId = intSubstituteItemId
							,@strInventoryTracking = strInventoryTracking
							,@intSubstituteItemUOMId = intSubstituteItemUOMId
						FROM @tblSubstituteItem
						WHERE intItemRecordId = @intItemRecordId

						SELECT @dblAvailableQty = 0

						IF @strInventoryTracking = 'Item Level'
						BEGIN
							SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(S.intItemUOMId, @intSubstituteItemUOMId, S.dblOnHand - S.dblUnitReserved))
							FROM dbo.tblICItemStockUOM S
							JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
								AND S.dblOnHand - S.dblUnitReserved > 0
							JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
								AND IU.ysnStockUnit = 1
							JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
							WHERE S.intItemId = @intSubstituteItemId
								AND IL.intLocationId = @intLocationId
						END
						ELSE
						BEGIN
							SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intSubstituteItemUOMId, L.dblQty))
							FROM dbo.tblICLot L
							JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
							JOIN dbo.tblICRestriction R ON R.intRestrictionId = IsNULL(SL.intRestrictionId, R.intRestrictionId)
								AND R.strInternalCode = 'STOCK'
							JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
							JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
								AND BS.strPrimaryStatus = 'Active'
							JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
							WHERE L.intItemId = @intSubstituteItemId
								AND L.intLocationId = @intLocationId
								AND LS.strPrimaryStatus = 'Active'
								AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
						END

						IF @dblAvailableQty IS NULL
							SELECT @dblAvailableQty = 0

						IF @dblRequiredQty - @dblAvailableQty > 0
						BEGIN
							--Consume detail
							INSERT INTO #tblMFConsumptionDetail (
								intContainerId
								,strContainerId
								,intStorageLocationId
								,strStorageLocationName
								,intStorageSubLocationId
								,intInputItemId
								,strInputItemNo
								,strInputItemDescription
								,dblInputQuantity
								,intInputItemUOMId
								,intUnitMeasureId
								,strInputItemUnitMeasure
								,intInputLotId
								,strInputLotNumber
								,dblInputLotQuantity
								,strInputLotUnitMeasure
								,ysnEmptyOutSource
								,dtmFeedTime
								,strReferenceNo
								,dtmActualInputDateTime
								,strInventoryTracking
								,ysnInputItem
								,intMainItemId
								)
							SELECT Cont.intContainerId
								,Cont.strContainerId
								,Cons.intStorageLocationId
								,SL.strName AS strStorageLocationName
								,SL.intSubLocationId AS intStorageSubLocationId
								,I.intItemId AS intInputItemId
								,I.strItemNo AS strInputItemNo
								,I.strDescription AS strInputItemDescription
								,@dblAvailableQty AS dblInputQuantity
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
								,I.strInventoryTracking
								,CONVERT(BIT, 0) AS ysnInputItem
								,@intInputItemId
							FROM dbo.tblICItem I
							JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
							JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
								AND UM.intUnitMeasureId = @intUnitMeasureId
							JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
							LEFT JOIN @tblMFConsumeItem Cons ON Cons.intItemId = I.intItemId
							LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = Cons.intStorageLocationId
							LEFT JOIN tblICContainer Cont ON Cont.intContainerId = Cons.intContainerId
							WHERE I.intItemId = @intSubstituteItemId

							SELECT @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

							UPDATE #tblMFConsumptionDetail
							SET dblInputQuantity = dblInputQuantity - @dblAvailableQty
							WHERE intInputItemId = @intInputItemId
						END
						ELSE
						BEGIN
							--Consume detail
							INSERT INTO #tblMFConsumptionDetail (
								intContainerId
								,strContainerId
								,intStorageLocationId
								,strStorageLocationName
								,intStorageSubLocationId
								,intInputItemId
								,strInputItemNo
								,strInputItemDescription
								,dblInputQuantity
								,intInputItemUOMId
								,intUnitMeasureId
								,strInputItemUnitMeasure
								,intInputLotId
								,strInputLotNumber
								,dblInputLotQuantity
								,strInputLotUnitMeasure
								,ysnEmptyOutSource
								,dtmFeedTime
								,strReferenceNo
								,dtmActualInputDateTime
								,strInventoryTracking
								,ysnInputItem
								,intMainItemId
								)
							SELECT Cont.intContainerId
								,Cont.strContainerId
								,Cons.intStorageLocationId
								,SL.strName AS strStorageLocationName
								,SL.intSubLocationId AS intStorageSubLocationId
								,I.intItemId AS intInputItemId
								,I.strItemNo AS strInputItemNo
								,I.strDescription AS strInputItemDescription
								,@dblRequiredQty AS dblInputQuantity
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
								,I.strInventoryTracking
								,CONVERT(BIT, 0) AS ysnInputItem
								,@intInputItemId
							FROM dbo.tblICItem I
							JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
							JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
								AND UM.intUnitMeasureId = @intUnitMeasureId
							JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
							LEFT JOIN @tblMFConsumeItem Cons ON Cons.intItemId = I.intItemId
							LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = Cons.intStorageLocationId
							LEFT JOIN tblICContainer Cont ON Cont.intContainerId = Cons.intContainerId
							WHERE I.intItemId = @intSubstituteItemId

							UPDATE #tblMFConsumptionDetail
							SET dblInputQuantity = dblInputQuantity - @dblRequiredQty
							WHERE intInputItemId = @intInputItemId

							SELECT @dblRequiredQty = 0

							BREAK
						END

						SELECT @intItemRecordId = MIN(intItemRecordId)
						FROM @tblSubstituteItem
						WHERE intItemRecordId > @intItemRecordId
					END
				END
			END

			SELECT @intRowNo = MIN(intRowNo)
			FROM #tblMFConsumptionDetail
			WHERE intRowNo > @intRowNo
				AND ysnInputItem = 1
		END

		DECLARE @intRecordId INT
			,@dblInputQuantity NUMERIC(38, 20)
			,@ysnPickByLotCode BIT
			,@intLotCodeStartingPosition INT
			,@intLotCodeNoOfDigits INT
			,@dblRequiredQuantity NUMERIC(38, 20)
			,@intRequiredQuantityItemUOMId INT
			,@intLotRecordId INT
			,@intLotId INT
			,@dblQty NUMERIC(38, 20)
			,@intItemUOMId INT
			,@strStorageLocationId NVARCHAR(MAX)
		DECLARE @tblMFLot TABLE (
			intLotRecordId INT Identity(1, 1)
			,intLotId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,dblWeightPerQty NUMERIC(38, 20)
			)
		DECLARE @tblMFPickLots TABLE (
			intLotRecordId INT Identity(1, 1)
			,intItemId INT
			,intLotId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			)

		SELECT @strStorageLocationId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 80

		SELECT @ysnPickByLotCode = ysnPickByLotCode
			,@intLotCodeStartingPosition = intLotCodeStartingPosition
			,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
		FROM tblMFCompanyPreference

		SELECT @intRecordId = min(intRowNo)
		FROM #tblMFConsumptionDetail CD
		WHERE dblInputQuantity > 0
			AND CD.intInputItemId NOT IN (
				SELECT CI.intItemId
				FROM @tblMFConsumeItem CI
				)

		WHILE @intRecordId IS NOT NULL
		BEGIN
			SELECT @intInputItemId = NULL
				,@dblRequiredQuantity = NULL
				,@intRequiredQuantityItemUOMId = NULL

			SELECT @intInputItemId = intInputItemId
				,@dblRequiredQuantity = dblInputQuantity
				,@intRequiredQuantityItemUOMId = intInputItemUOMId
			FROM #tblMFConsumptionDetail
			WHERE intRowNo = @intRecordId

			DELETE
			FROM @tblMFLot

			IF @strStorageLocationId IS NULL
				OR @strStorageLocationId = ''
			BEGIN
				INSERT INTO @tblMFLot (
					intLotId
					,dblQty
					,intItemUOMId
					,dblWeight
					,intWeightUOMId
					,dblWeightPerQty
					)
				SELECT L.intLotId
					,L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)))
					,L.intItemUOMId
					,L.dblWeight - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0)))
					,L.intWeightUOMId
					,L.dblWeightPerQty
				FROM tblICLot L
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
					AND UT.ysnAllowPick = 1
				LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
					AND SR.intTransactionId <> @intWorkOrderId
					AND SR.strTransactionId <> @strWorkOrderNo
					AND SR.ysnPosted = 0
				LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
				LEFT JOIN tblMFStageWorkOrder SW ON T.intOrderHeaderId = SW.intOrderHeaderId
					AND SW.intWorkOrderId = @intWorkOrderId
				WHERE L.intLocationId = @intLocationId
					AND L.intItemId = @intInputItemId
					AND L.dblQty > 0
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND SL.intRestrictionId NOT IN (
						SELECT RT.intRestrictionId
						FROM tblMFInventoryShipmentRestrictionType RT
						)
					AND LI.ysnPickAllowed = 1
				GROUP BY L.intLotId
					,L.intItemId
					,L.dblQty
					,L.intItemUOMId
					,L.dblWeight
					,L.intWeightUOMId
					,L.dblWeightPerQty
					,L.dtmDateCreated
					,L.dtmManufacturedDate
					,PL.strParentLotNumber
					,SW.intWorkOrderId
				HAVING (
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END
						) - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, IsNULL(L.intWeightUOMId, L.intItemUOMId), SR.dblQty), 0))) > 0
				ORDER BY CASE 
						WHEN SW.intWorkOrderId IS NOT NULL
							THEN 1
						ELSE 2
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE '1900-01-01'
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 1
							THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
						ELSE '1'
						END ASC
					,L.dtmDateCreated ASC
			END
			ELSE
			BEGIN
				INSERT INTO @tblMFLot (
					intLotId
					,dblQty
					,intItemUOMId
					,dblWeight
					,intWeightUOMId
					,dblWeightPerQty
					)
				SELECT L.intLotId
					,L.dblQty - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intItemUOMId, SR.dblQty), 0)))
					,L.intItemUOMId
					,L.dblWeight - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, L.intWeightUOMId, SR.dblQty), 0)))
					,L.intWeightUOMId
					,L.dblWeightPerQty
				FROM tblICLot L
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
					AND UT.ysnAllowPick = 1
				LEFT JOIN tblICStockReservation SR ON SR.intLotId = L.intLotId
					AND SR.intTransactionId <> @intWorkOrderId
					AND SR.strTransactionId <> @strWorkOrderNo
					AND SR.ysnPosted = 0
				LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
				LEFT JOIN tblMFStageWorkOrder SW ON T.intOrderHeaderId = SW.intOrderHeaderId
					AND SW.intWorkOrderId = @intWorkOrderId
				WHERE L.intLocationId = @intLocationId
					AND SL.intStorageLocationId IN (
						SELECT Item Collate Latin1_General_CI_AS
						FROM [dbo].[fnSplitString](@strStorageLocationId, ',')
						)
					AND L.intItemId = @intInputItemId
					AND L.dblQty > 0
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND SL.intRestrictionId NOT IN (
						SELECT RT.intRestrictionId
						FROM tblMFInventoryShipmentRestrictionType RT
						)
					AND LI.ysnPickAllowed = 1
				GROUP BY L.intLotId
					,L.intItemId
					,L.dblQty
					,L.intItemUOMId
					,L.dblWeight
					,L.intWeightUOMId
					,L.dblWeightPerQty
					,L.dtmDateCreated
					,L.dtmManufacturedDate
					,PL.strParentLotNumber
					,SW.intWorkOrderId
				HAVING (
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END
						) - (SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, IsNULL(L.intWeightUOMId, L.intItemUOMId), SR.dblQty), 0))) > 0
				ORDER BY CASE 
						WHEN SW.intWorkOrderId IS NOT NULL
							THEN 1
						ELSE 2
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE '1900-01-01'
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 1
							THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
						ELSE '1'
						END ASC
					,L.dtmDateCreated ASC
			END

			SELECT @intLotRecordId = NULL

			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblMFLot

			WHILE @intLotRecordId IS NOT NULL
				AND @dblRequiredQuantity > 0
			BEGIN
				SELECT @intLotId = NULL
					,@dblQty = NULL
					,@intItemUOMId = NULL

				SELECT @intLotId = intLotId
					,@dblQty = dblQty
					,@intItemUOMId = intItemUOMId
				FROM @tblMFLot
				WHERE intLotRecordId = @intLotRecordId

				IF (@dblQty >= [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRequiredQuantityItemUOMId, @intItemUOMId, @dblRequiredQuantity))
				BEGIN
					INSERT INTO @tblMFPickLots (
						intItemId
						,intLotId
						,dblQty
						,intItemUOMId
						)
					SELECT @intInputItemId
						,@intLotId
						,[dbo].[fnMFConvertQuantityToTargetItemUOM](@intRequiredQuantityItemUOMId, @intItemUOMId, @dblRequiredQuantity)
						,@intItemUOMId

					SELECT @dblRequiredQuantity = 0

					BREAK
				END
				ELSE
				BEGIN
					INSERT INTO @tblMFPickLots (
						intItemId
						,intLotId
						,dblQty
						,intItemUOMId
						)
					SELECT @intInputItemId
						,@intLotId
						,@dblQty
						,@intItemUOMId

					SELECT @dblRequiredQuantity = @dblRequiredQuantity - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intItemUOMId, @intRequiredQuantityItemUOMId, @dblQty)
				END

				SELECT @intLotRecordId = MIN(intLotRecordId)
				FROM @tblMFLot
				WHERE intLotRecordId > @intLotRecordId
					AND @dblRequiredQuantity > 0
			END

			SELECT @intRecordId = min(intRowNo)
			FROM #tblMFConsumptionDetail CD
			WHERE dblInputQuantity > 0
				AND intRowNo > @intRecordId
				AND CD.intInputItemId NOT IN (
					SELECT CI.intItemId
					FROM @tblMFConsumeItem CI
					)
		END

		SELECT WC.intContainerId
			,WC.strContainerId
			,SL.intStorageLocationId
			,SL.strName AS strStorageLocationName
			,SL.intSubLocationId AS intStorageSubLocationId
			,WC.intInputItemId
			,WC.strInputItemNo
			,WC.strInputItemDescription
			,WC.dblInputQuantity
			,WC.intInputItemUOMId
			,WC.intUnitMeasureId
			,WC.strInputItemUnitMeasure
			,L.intLotId intInputLotId
			,L.strLotNumber strInputLotNumber
			,IsNULL(PL.dblQty, WC.dblInputQuantity) dblInputLotQuantity
			,UM.strUnitMeasure strInputLotUnitMeasure
			,WC.ysnEmptyOutSource
			,WC.dtmFeedTime
			,WC.strReferenceNo
			,WC.dtmActualInputDateTime
			,WC.intRowNo
			,IsNULL(PL.dblQty, WC.dblInputQuantity) dblReadingQuantity
			,WC.intMainItemId
		FROM #tblMFConsumptionDetail WC
		LEFT JOIN @tblMFPickLots PL ON PL.intItemId = WC.intInputItemId
		LEFT JOIN tblICLot L ON L.intLotId = IsNULL(PL.intLotId, WC.intInputLotId)
		LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = IsNULL(L.intStorageLocationId, WC.intStorageLocationId)
		WHERE dblInputQuantity > 0
	END

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
