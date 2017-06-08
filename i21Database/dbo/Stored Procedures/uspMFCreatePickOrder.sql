CREATE PROCEDURE [dbo].uspMFCreatePickOrder (
	@strXML NVARCHAR(MAX)
	,@intOrderHeaderId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intLocationId INT
		,@dtmCurrentDate DATETIME
		,@intOwnerId INT
		,@strBlendProductionStagingLocation NVARCHAR(50)
		,@intOrderTermsId INT
		,@strUserName NVARCHAR(50)
		,@strBOLNo NVARCHAR(50)
		,@intEntityId INT
		,@strItemNo NVARCHAR(50)
		,@intBlendProductionStagingUnitId INT
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@intDayOfYear INT
		,@intStageLocationTypeId INT
		,@strStageLocationType NVARCHAR(50)
		,@intProductionStagingId INT
		,@intProductionStageLocationId INT
		,@intStagingId INT
		,@intStageLocationId INT
		,@intItemId INT
		,@dblQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intLineNo INT
		,@dblAvailableQty NUMERIC(18, 6)
		,@dblRequiredQty NUMERIC(18, 6)
		,@dblSubstituteRatio NUMERIC(18, 6)
		,@dblMaxSubstituteRatio NUMERIC(18, 6)
		,@dblPlannedQty NUMERIC(18, 6)
		,@intWorkOrderId INT
		,@intItemRecordId INT
		,@dblQtyCanBeProduced NUMERIC(18, 6)
		,@dblMinQtyCanBeProduced NUMERIC(18, 6)
		,@strRequiredQty NVARCHAR(50)
		,@strAvailableQty NVARCHAR(50)
		,@intUnitMeasureId INT
		,@strUnitMeasure NVARCHAR(50)
		,@strMinQtyCanBeProduced NVARCHAR(50)
		,@intProductId INT
		,@intSubstituteItemId INT
		,@intSubstituteItemUOMId INT
		,@intPMCategoryId INT
		,@intPMStageLocationId INT
		,@intStagingLocationId INT
		,@strPickByUpperToleranceQty NVARCHAR(50)
		,@ysnPickRemainingQty bit

	SELECT @dtmCurrentDate = GetDate()

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDate)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = x.intLocationId
		,@intUserId = intUserId
		,@ysnPickRemainingQty=ysnPickRemainingQty
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingProcessId INT
			,intLocationId INT
			,intUserId INT
			,ysnPickRemainingQty Bit
			) x

	DECLARE @tblMFWorkOrder TABLE (
		intWorkOrderId INT
		,intItemId INT
		,dblPlannedQty NUMERIC(18, 6)
		,dtmPlannedDate DATETIME
		,intPlannedShift INT
		)

	INSERT INTO @tblMFWorkOrder (
		intWorkOrderId
		,intItemId
		,dblPlannedQty
		,dtmPlannedDate
		,intPlannedShift
		)
	SELECT x.intWorkOrderId
		,x.intItemId
		,x.dblPlannedQty
		,x.dtmPlannedDate
		,x.intPlannedShift
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intWorkOrderId INT
			,intItemId INT
			,dblPlannedQty NUMERIC(18, 6)
			,dtmPlannedDate DATETIME
			,intPlannedShift INT
			) x

	DECLARE @tblMFWorkOrderFinal TABLE (
		intItemId INT
		,dblPlannedQty NUMERIC(18, 6)
		)

	INSERT INTO @tblMFWorkOrderFinal (
		intItemId
		,dblPlannedQty
		)
	SELECT intItemId
		,SUM(dblPlannedQty)
	FROM @tblMFWorkOrder
	GROUP BY intItemId

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	SELECT @intPMCategoryId = intCategoryId
	FROM tblICCategory
	WHERE strCategoryCode = @strPackagingCategory

	SELECT @intBlendProductionStagingUnitId = intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @strPickByUpperToleranceQty = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId

	IF @strPickByUpperToleranceQty IS NULL
	BEGIN
		SELECT @strPickByUpperToleranceQty = 'False'
	END

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @intUserId

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
		,@intItemId = NULL
		,@intManufacturingId = NULL
		,@intSubLocationId = NULL
		,@intLocationId = @intLocationId
		,@intOrderTypeId = 6
		,@intBlendRequirementId = NULL
		,@intPatternCode = 75
		,@ysnProposed = 0
		,@strPatternString = @strBOLNo OUTPUT

	DECLARE @tblMFOrderHeader TABLE (intOrderHeaderId INT)

	SELECT @intStageLocationTypeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Staging Location Type'

	SELECT @strStageLocationType = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intStageLocationTypeId

	SELECT @intProductionStagingId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Production Staging Location'

	SELECT @intProductionStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intProductionStagingId

	SELECT @intStagingId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Staging Location'

	SELECT @intStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intStagingId

	SELECT @intPMStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 90 --PM Staging Location

	DECLARE @tblMFStageLocation TABLE (intStageLocationId INT)

	INSERT INTO @tblMFStageLocation
	SELECT intStagingLocationId
	FROM tblMFManufacturingProcessMachine
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intProductionStagingLocationId IS NOT NULL
	
	UNION
	
	SELECT strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 76
	
	UNION
	
	SELECT @intPMStageLocationId

	BEGIN TRANSACTION

	DECLARE @OrderHeaderInformation AS OrderHeaderInformation

	INSERT INTO @OrderHeaderInformation (
		intOrderStatusId
		,intOrderTypeId
		,intOrderDirectionId
		,strOrderNo
		,strReferenceNo
		,intStagingLocationId
		,strComment
		,dtmOrderDate
		,strLastUpdateBy
		)
	SELECT 1
		,1
		,2
		,@strBOLNo
		,''
		,CASE 
			WHEN @strStageLocationType = 'Alternate Staging Location'
				THEN NULL
			WHEN @strStageLocationType = 'Production Staging Location'
				THEN @intProductionStageLocationId
			ELSE @intStageLocationId
			END
		,''
		,@dtmCurrentDate
		,@strUserName

	INSERT INTO @tblMFOrderHeader
	EXEC dbo.uspMFCreateStagingOrder @OrderHeaderInformation = @OrderHeaderInformation

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblMFOrderHeader

	DECLARE @OrderDetail AS OrderDetailInformation
	DECLARE @OrderDetailInformation AS OrderDetailInformation

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrder W
			JOIN @tblMFWorkOrder W1 ON W.intWorkOrderId = W1.intWorkOrderId
			WHERE intTransactionFrom = 1
			)
	BEGIN
		INSERT INTO @OrderDetailInformation (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,intLotId
			,strLotAlias
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,dtmProductionDate
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			)
		SELECT @intOrderHeaderId
			,CL.intItemId
			,SUm(L.dblQty)
			,L.intItemUOMId
			,SUm(L.dblWeight)
			,L.intWeightUOMId
			,L.dblWeightPerQty
			,L.intLotId
			,L.strLotAlias
			,I.intUnitPerLayer
			,intLayerPerPallet
			,(
				SELECT TOP 1 intPickListPreferenceId
				FROM tblMFPickListPreference
				)
			,L.dtmDateCreated
			,Row_Number() OVER (
				ORDER BY CL.intItemId
				)
			,NULL
			,''
		FROM dbo.tblMFWorkOrderConsumedLot CL
		JOIN dbo.tblICLot L ON L.intLotId = CL.intLotId
		JOIN dbo.tblICItem I ON I.intItemId = CL.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = CL.intItemUOMId
		JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = CL.intItemIssuedUOMId
		WHERE CL.intWorkOrderId IN (
				SELECT x.intWorkOrderId
				FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
				)
		GROUP BY CL.intItemId
			,L.intItemUOMId
			,L.intWeightUOMId
			,L.dblWeightPerQty
			,L.intLotId
			,L.strLotAlias
			,I.intUnitPerLayer
			,intLayerPerPallet
			,L.dtmDateCreated
	END
	ELSE
	BEGIN
		INSERT INTO @OrderDetail (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,dblRequiredQty
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			,intStagingLocationId
			)
		SELECT @intOrderHeaderId
			,ri.intItemId
			,SUM(CASE 
					WHEN C.strCategoryCode = @strPackagingCategory
						THEN CAST(CEILING((
										(
											CASE 
												WHEN @strPickByUpperToleranceQty = 'True'
													THEN ri.dblCalculatedUpperTolerance
												ELSE ri.dblCalculatedQuantity
												END
											) * (W.dblPlannedQty / r.dblQuantity)
										)) AS NUMERIC(38, 2))
					ELSE (
							(
								CASE 
									WHEN @strPickByUpperToleranceQty = 'True'
										THEN ri.dblCalculatedUpperTolerance
									ELSE ri.dblCalculatedQuantity
									END
								) * (W.dblPlannedQty / r.dblQuantity)
							)
					END)
			,ri.intItemUOMId
			,SUM(CASE 
					WHEN C.strCategoryCode = @strPackagingCategory
						THEN CAST(CEILING((
										(
											CASE 
												WHEN @strPickByUpperToleranceQty = 'True'
													THEN ri.dblCalculatedUpperTolerance
												ELSE ri.dblCalculatedQuantity
												END
											) * (W.dblPlannedQty / r.dblQuantity)
										)) AS NUMERIC(38, 2))
					ELSE (
							(
								CASE 
									WHEN @strPickByUpperToleranceQty = 'True'
										THEN ri.dblCalculatedUpperTolerance
									ELSE ri.dblCalculatedQuantity
									END
								) * (W.dblPlannedQty / r.dblQuantity)
							)
					END)
			,ri.intItemUOMId
			,MAX(IU.dblUnitQty)
			,SUM(CASE 
					WHEN C.strCategoryCode = @strPackagingCategory
						THEN CAST(CEILING((
										(
											CASE 
												WHEN @strPickByUpperToleranceQty = 'True'
													THEN ri.dblCalculatedUpperTolerance
												ELSE ri.dblCalculatedQuantity
												END
											) * (W.dblPlannedQty / r.dblQuantity)
										)) AS NUMERIC(38, 2))
					ELSE (
							(
								CASE 
									WHEN @strPickByUpperToleranceQty = 'True'
										THEN ri.dblCalculatedUpperTolerance
									ELSE ri.dblCalculatedQuantity
									END
								) * (W.dblPlannedQty / r.dblQuantity)
							)
					END)
			,ISNULL(NULL, I.intUnitPerLayer)
			,ISNULL(NULL, I.intLayerPerPallet)
			,(
				SELECT TOP 1 intPickListPreferenceId
				FROM tblMFPickListPreference
				)
			,Row_Number() OVER (
				ORDER BY MAX(ri.intRecipeItemId)
				)
			,NULL
			,''
			,CASE 
				WHEN C.intCategoryId = @intPMCategoryId
					THEN @intPMStageLocationId
				ELSE NULL
				END
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.ysnActive = 1
			AND r.intLocationId = @intLocationId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		JOIN @tblMFWorkOrderFinal W ON W.intItemId = r.intItemId
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
			AND ri.intConsumptionMethodId IN (
				1
				--,2
				)
		GROUP BY ri.intItemId
			,ri.intItemUOMId
			,I.intUnitPerLayer
			,I.intLayerPerPallet
			,C.intCategoryId

		DECLARE @tblMFRequiredQty TABLE (
			intItemId INT
			,dblRequiredQty DECIMAL(38, 20)
			)

		INSERT INTO @tblMFRequiredQty (
			intItemId
			,dblRequiredQty
			)
		SELECT OD1.intItemId
			,IsNULL(sum(OD.dblRequiredQty), 0)
		FROM @OrderDetail OD1
		LEFT JOIN tblMFOrderDetail OD ON OD1.intItemId = OD.intItemId
			AND OD.intOrderHeaderId IN (
				SELECT OH.intOrderHeaderId
				FROM tblMFOrderHeader OH
				WHERE OH.intOrderTypeId = 1
					AND OH.intOrderStatusId <> 10
				)
		GROUP BY OD1.intItemId

		If @ysnPickRemainingQty=1
		Begin

			DECLARE @tblMFStagedQty TABLE (
				intItemId INT
				,dblStagedQty DECIMAL(38, 20)
				)

			INSERT INTO @tblMFStagedQty (
				intItemId
				,dblStagedQty
				)
			SELECT OD1.intItemId
				,IsNULL(sum(CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END), 0)
			FROM @OrderDetail OD1
			LEFT JOIN dbo.tblICLot L ON L.intItemId = OD1.intItemId
			WHERE L.intStorageLocationId IN (
					SELECT intStageLocationId
					FROM @tblMFStageLocation
					)
			GROUP BY OD1.intItemId

			DECLARE @tblMFRemainingQty TABLE (
				intItemId INT
				,dblRemainingQty DECIMAL(38, 20)
				)

			INSERT INTO @tblMFRemainingQty (
				intItemId
				,dblRemainingQty
				)
			SELECT R.intItemId
				,(
					CASE 
						WHEN IsNULL(dblStagedQty, 0) - IsNULL(dblRequiredQty, 0) > 0
							THEN IsNULL(dblStagedQty, 0) - IsNULL(dblRequiredQty, 0)
						ELSE 0
						END
					)
			FROM @tblMFRequiredQty R
			LEFT JOIN @tblMFStagedQty S ON S.intItemId = R.intItemId

			UPDATE OD
			SET dblQty = CASE 
					WHEN dblQty - R.dblRemainingQty < 0
						THEN 0
					ELSE dblQty - R.dblRemainingQty
					END
				,dblWeight = CASE 
					WHEN dblWeight - R.dblRemainingQty < 0
						THEN 0
					ELSE dblWeight - R.dblRemainingQty
					END
			FROM @OrderDetail OD
			LEFT JOIN @tblMFRemainingQty R ON R.intItemId = OD.intItemId
		End

		SELECT @intWorkOrderId = intWorkOrderId
			,@intProductId = intItemId
			,@dblPlannedQty = dblPlannedQty
		FROM @tblMFWorkOrder

		INSERT INTO @OrderDetailInformation (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,dblRequiredQty
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			,intStagingLocationId
			)
		SELECT intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,dblRequiredQty
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			,intStagingLocationId
		FROM @OrderDetail

		SELECT @dblMinQtyCanBeProduced = - 1

		SELECT @intLineNo = MIn(intLineNo)
		FROM @OrderDetail

		WHILE @intLineNo IS NOT NULL
		BEGIN
			SELECT @intItemId = NULL
				,@dblQty = NULL
				,@dblRequiredQty = NULL
				,@intItemUOMId = NULL
				,@intStagingLocationId = NULL

			SELECT @intItemId = intItemId
				,@dblQty = dblQty
				,@dblRequiredQty = dblRequiredQty
				,@intItemUOMId = intItemUOMId
				,@intStagingLocationId = intStagingLocationId
			FROM @OrderDetailInformation
			WHERE intLineNo = @intLineNo

			SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty))
			FROM dbo.tblICLot L
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
				AND R.strInternalCode = 'STOCK'
			JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
			JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
				AND BS.strPrimaryStatus = 'Active'
			WHERE L.intItemId = @intItemId
				AND L.intLocationId = @intLocationId
				AND L.intLotStatusId = 1
				AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
				AND L.intStorageLocationId NOT IN (
					SELECT intStageLocationId
					FROM @tblMFStageLocation
					)

			--Select @dblAvailableQty=@dblAvailableQty- IsNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(OD.intItemUOMId, @intItemUOMId, OD.dblRequiredQty )), 0)
			--from tblMFOrderDetail OD 
			--Where OD.intItemId = @intItemId and OD.intOrderHeaderId in (Select OH.intOrderHeaderId from tblMFOrderHeader OH Where OH.intOrderStatusId <>10)
			IF @dblAvailableQty IS NULL
				OR @dblAvailableQty < 0
			BEGIN
				SELECT @dblAvailableQty = 0

				DELETE
				FROM @OrderDetailInformation
				WHERE intLineNo = @intLineNo
					AND dblQty = dblRequiredQty
			END

			IF @dblQty - @dblAvailableQty > 0
			BEGIN
				SELECT @dblQty = @dblQty - @dblAvailableQty

				UPDATE @OrderDetailInformation
				SET dblQty = @dblAvailableQty
					,dblWeight = @dblAvailableQty
					,dblRequiredQty = dblRequiredQty - dblQty + @dblAvailableQty
				WHERE intLineNo = @intLineNo

				DECLARE @tblSubstituteItem TABLE (
					intItemRecordId INT Identity(1, 1)
					,intSubstituteItemId INT
					,dblSubstituteRatio NUMERIC(18, 6)
					,dblMaxSubstituteRatio NUMERIC(18, 6)
					)

				INSERT INTO @tblSubstituteItem (
					intSubstituteItemId
					,dblSubstituteRatio
					,dblMaxSubstituteRatio
					)
				SELECT rs.intSubstituteItemId
					,dblSubstituteRatio
					,dblMaxSubstituteRatio
				FROM dbo.tblMFRecipe r
				JOIN dbo.tblMFRecipeItem ri ON r.intRecipeId = ri.intRecipeId
				JOIN dbo.tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId = ri.intRecipeItemId
				WHERE r.intItemId = @intProductId
					AND r.intLocationId = @intLocationId
					AND r.ysnActive = 1
					AND ri.intItemId = @intItemId

				SELECT @intItemRecordId = MIN(intItemRecordId)
				FROM @tblSubstituteItem

				WHILE @intItemRecordId IS NOT NULL
				BEGIN
					SELECT @dblSubstituteRatio = NULL
						,@dblMaxSubstituteRatio = NULL
						,@intSubstituteItemId = NULL

					SELECT @dblSubstituteRatio = dblSubstituteRatio
						,@dblMaxSubstituteRatio = dblMaxSubstituteRatio
						,@intSubstituteItemId = intSubstituteItemId
					FROM @tblSubstituteItem
					WHERE intItemRecordId = @intItemRecordId

					SELECT @intUnitMeasureId = intUnitMeasureId
					FROM dbo.tblICItemUOM
					WHERE intItemUOMId = @intItemUOMId

					SELECT @intSubstituteItemUOMId = intItemUOMId
					FROM tblICItemUOM
					WHERE intItemId = @intSubstituteItemId
						AND intUnitMeasureId = @intUnitMeasureId

					SELECT @dblAvailableQty = 0

					SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty))
					FROM dbo.tblICLot L
					JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
						AND R.strInternalCode = 'STOCK'
					JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
					JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
						AND BS.strPrimaryStatus = 'Active'
					JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
					WHERE L.intItemId = @intSubstituteItemId
						AND L.intLocationId = @intLocationId
						AND LS.strPrimaryStatus = 'Active'
						AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate
						AND L.intStorageLocationId NOT IN (
							SELECT intStageLocationId
							FROM @tblMFStageLocation
							)

					--Select @dblAvailableQty=@dblAvailableQty- IsNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(OD.intItemUOMId, @intItemUOMId, OD.dblRequiredQty )), 0)
					--from tblMFOrderDetail OD 
					--Where OD.intItemId = @intItemId and OD.intOrderHeaderId in (Select OH.intOrderHeaderId from tblMFOrderHeader OH Where OH.intOrderStatusId <>10)
					IF @dblAvailableQty IS NULL
					BEGIN
						SELECT @dblAvailableQty = 0

						GOTO x
					END

					SELECT @dblQty = @dblQty * (@dblMaxSubstituteRatio / 100) * @dblSubstituteRatio

					IF @dblAvailableQty - @dblQty >= 0
					BEGIN
						INSERT INTO @OrderDetailInformation (
							intOrderHeaderId
							,intItemId
							,dblQty
							,intItemUOMId
							,dblWeight
							,intWeightUOMId
							,dblWeightPerUnit
							,dblRequiredQty
							,intUnitsPerLayer
							,intLayersPerPallet
							,intPreferenceId
							,intLineNo
							,intSanitizationOrderDetailsId
							,strLineItemNote
							,intStagingLocationId
							)
						SELECT @intOrderHeaderId
							,intItemId
							,@dblQty
							,@intSubstituteItemUOMId
							,@dblQty
							,@intSubstituteItemUOMId
							,1
							,@dblQty
							,ISNULL(NULL, intUnitPerLayer)
							,ISNULL(NULL, intLayerPerPallet)
							,(
								SELECT TOP 1 intPickListPreferenceId
								FROM tblMFPickListPreference
								)
							,(
								SELECT MAX(intLineNo) + 1
								FROM @OrderDetailInformation
								)
							,NULL
							,''
							,@intStagingLocationId
						FROM tblICItem
						WHERE intItemId = @intSubstituteItemId

						SELECT @dblQty = 0

						BREAK
					END
					ELSE
					BEGIN
						INSERT INTO @OrderDetailInformation (
							intOrderHeaderId
							,intItemId
							,dblQty
							,intItemUOMId
							,dblWeight
							,intWeightUOMId
							,dblWeightPerUnit
							,dblRequiredQty
							,intUnitsPerLayer
							,intLayersPerPallet
							,intPreferenceId
							,intLineNo
							,intSanitizationOrderDetailsId
							,strLineItemNote
							,intStagingLocationId
							)
						SELECT @intOrderHeaderId
							,intItemId
							,@dblAvailableQty
							,@intSubstituteItemUOMId
							,@dblAvailableQty
							,@intSubstituteItemUOMId
							,1
							,@dblAvailableQty
							,ISNULL(NULL, intUnitPerLayer)
							,ISNULL(NULL, intLayerPerPallet)
							,(
								SELECT TOP 1 intPickListPreferenceId
								FROM tblMFPickListPreference
								)
							,(
								SELECT MAX(intLineNo) + 1
								FROM @OrderDetailInformation
								)
							,NULL
							,''
							,@intStagingLocationId
						FROM tblICItem
						WHERE intItemId = @intSubstituteItemId

						SELECT @dblQty = @dblQty - @dblAvailableQty
					END

					x:

					SELECT @intItemRecordId = MIN(intItemRecordId)
					FROM @tblSubstituteItem
					WHERE intItemRecordId > @intItemRecordId
				END

				IF @dblQty > 0
				BEGIN
					SELECT @dblQtyCanBeProduced = (@dblRequiredQty - @dblQty) * @dblPlannedQty / @dblRequiredQty

					IF @dblQtyCanBeProduced < @dblMinQtyCanBeProduced
						OR @dblQtyCanBeProduced = 0
						OR @dblMinQtyCanBeProduced = - 1
					BEGIN
						SELECT @dblMinQtyCanBeProduced = @dblQtyCanBeProduced

						SELECT @strItemNo = strItemNo
						FROM tblICItem
						WHERE intItemId = @intItemId

						SELECT @intUnitMeasureId = intUnitMeasureId
						FROM tblICItemUOM
						WHERE intItemUOMId = @intItemUOMId

						SELECT @strUnitMeasure = strUnitMeasure
						FROM tblICUnitMeasure
						WHERE intUnitMeasureId = @intUnitMeasureId

						SELECT @strRequiredQty = Ltrim(@dblRequiredQty) + ' ' + @strUnitMeasure

						SELECT @strAvailableQty = Ltrim(@dblRequiredQty - @dblQty) + ' ' + @strUnitMeasure

						SELECT @strMinQtyCanBeProduced = Ltrim(Floor(@dblMinQtyCanBeProduced))
					END
				END

				SELECT @intLineNo = MIn(intLineNo)
				FROM @OrderDetailInformation
				WHERE @intLineNo > intLineNo
			END

			SELECT @intLineNo = MIn(intLineNo)
			FROM @OrderDetail
			WHERE intLineNo > @intLineNo
		END
	END

	IF @dblMinQtyCanBeProduced > - 1
	BEGIN
		SELECT @intItemUOMId = intItemUOMId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		SELECT @strUnitMeasure = strUnitMeasure
		FROM tblICUnitMeasure
		WHERE intUnitMeasureId = @intUnitMeasureId

		SELECT @strMinQtyCanBeProduced = @strMinQtyCanBeProduced + ' ' + @strUnitMeasure

		RAISERROR (
				'Available qty for item %s is %s which is less than the required qty %s. %s can be produced with the available inputs. Please change the work order quantity and try again.'
				,11
				,1
				,@strItemNo
				,@strAvailableQty
				,@strRequiredQty
				,@strMinQtyCanBeProduced
				)

		RETURN
	END

	--DELETE
	--FROM @OrderDetailInformation
	--WHERE dblQty <= 0
	EXEC dbo.uspMFCreateStagingOrderDetail @OrderDetailInformation = @OrderDetailInformation

	INSERT INTO tblMFStageWorkOrder (
		intWorkOrderId
		,intItemId
		,dtmPlannedDate
		,intPlannnedShiftId
		,intOrderHeaderId
		,intConcurrencyId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT intWorkOrderId
		,intItemId
		,dtmPlannedDate
		,intPlannedShift
		,@intOrderHeaderId
		,0
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
	FROM @tblMFWorkOrder

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
