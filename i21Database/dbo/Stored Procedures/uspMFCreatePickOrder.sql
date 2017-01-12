﻿CREATE PROCEDURE [dbo].uspMFCreatePickOrder (
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

	SELECT @dtmCurrentDate = GetDate()

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDate)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = x.intLocationId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingProcessId INT
			,intLocationId INT
			,intUserId INT
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

	SELECT @intBlendProductionStagingUnitId = intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

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
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			)
		SELECT @intOrderHeaderId
			,ri.intItemId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 2))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,ri.intItemUOMId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 2))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,ri.intItemUOMId
			,IU.dblUnitQty
			,ISNULL(NULL, I.intUnitPerLayer)
			,ISNULL(NULL, I.intLayerPerPallet)
			,(
				SELECT TOP 1 intPickListPreferenceId
				FROM tblMFPickListPreference
				)
			,Row_Number() OVER (
				ORDER BY ri.intRecipeItemId
				)
			,NULL
			,''
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
			AND ri.intConsumptionMethodId = 1

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
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			)
		SELECT intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
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

			SELECT @intItemId = intItemId
				,@dblQty = dblQty
				,@dblRequiredQty = dblQty
				,@intItemUOMId = intItemUOMId
			FROM @OrderDetailInformation
			WHERE intLineNo = @intLineNo

			SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty)) - IsNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId, @intItemUOMId, T.dblQty)), 0)
			FROM dbo.tblICLot L
			JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
				AND R.strInternalCode = 'STOCK'
			LEFT JOIN dbo.tblMFTask T ON T.intLotId = L.intLotId
			WHERE L.intItemId = @intItemId
				AND L.intLocationId = @intLocationId
				AND L.intLotStatusId = 1
				AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate

			IF @dblAvailableQty IS NULL OR @dblAvailableQty < 0
			BEGIN
				SELECT @dblAvailableQty = 0

				DELETE
				FROM @OrderDetailInformation
				WHERE intLineNo = @intLineNo
			END

			IF @dblQty - @dblAvailableQty > 0
			BEGIN
				SELECT @dblQty = @dblQty - @dblAvailableQty

				UPDATE @OrderDetailInformation
				SET dblQty = @dblAvailableQty
					,dblWeight = @dblAvailableQty
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

					SELECT @dblAvailableQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId, @intItemUOMId, L.dblQty)) - IsNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId, @intItemUOMId, T.dblQty)), 0)
					FROM dbo.tblICLot L
					JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
					JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
						AND R.strInternalCode = 'STOCK'
					LEFT JOIN dbo.tblMFTask T ON T.intLotId = L.intLotId
					WHERE L.intItemId = @intSubstituteItemId
						AND L.intLocationId = @intLocationId
						AND L.intLotStatusId = 1
						AND ISNULL(dtmExpiryDate, @dtmCurrentDate) >= @dtmCurrentDate

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
							,intUnitsPerLayer
							,intLayersPerPallet
							,intPreferenceId
							,intLineNo
							,intSanitizationOrderDetailsId
							,strLineItemNote
							)
						SELECT @intOrderHeaderId
							,intItemId
							,@dblQty
							,@intSubstituteItemUOMId
							,@dblQty
							,@intSubstituteItemUOMId
							,1
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
							,intUnitsPerLayer
							,intLayersPerPallet
							,intPreferenceId
							,intLineNo
							,intSanitizationOrderDetailsId
							,strLineItemNote
							)
						SELECT @intOrderHeaderId
							,intItemId
							,@dblAvailableQty
							,@intSubstituteItemUOMId
							,@dblAvailableQty
							,@intSubstituteItemUOMId
							,1
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
				90026
				,11
				,1
				,@strItemNo
				,@strAvailableQty
				,@strRequiredQty
				,@strMinQtyCanBeProduced
				)

		RETURN
	END

	DELETE
	FROM @OrderDetailInformation
	WHERE dblQty <= 0

	EXEC dbo.uspMFCreateStagingOrderDetail @OrderDetailInformation = @OrderDetailInformation

	INSERT INTO tblMFStageWorkOrder (
		intWorkOrderId
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
