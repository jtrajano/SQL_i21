CREATE PROCEDURE [dbo].[uspIPProcessERPProductionOrder] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
	,@strSessionId NVARCHAR(50) = ''
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @intProductionOrderStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @intUserId INT
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strError NVARCHAR(MAX)
		,@dtmCreatedDate DATETIME
		,@intLocationId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@strOrderNo NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@dblNoOfPack NUMERIC(18, 6)
		,@strNoOfPackUOM NVARCHAR(50)
		,@dblWeight NUMERIC(18, 6)
		,@strWeightUOM NVARCHAR(50)
		,@intDocNo BIGINT
		,@intWorkOrderId INT
		,@strLocationNumber NVARCHAR(50)
		,@intPackItemUOMId INT
		,@intPackUnitMeasureId INT
		,@strCreatedBy NVARCHAR(50)
		,@intLotId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@intManufacturingCellId INT
		,@intMachineId INT
		,@intBlendRequirementId INT
		,@intExecutionOrder INT
		,@dtmCurrentDate DATETIME
		,@dblOrderQuantity NUMERIC(18, 6)
		,@strOrderQuantityUOM NVARCHAR(50)
		,@dblNoOfMixes NUMERIC(18, 6)
		,@dtmPlanDate DATETIME
		,@intWokrOrderId INT
		,@intBlendItemId INT
		,@intBlendUOMId INT
		,@intBlendItemUOMId INT
		,@strReferenceNo NVARCHAR(50)
		,@intWeightUOMId INT
		,@dblTeaTaste NUMERIC(18, 6)
		,@dblTeaHue NUMERIC(18, 6)
		,@dblTeaIntensity NUMERIC(18, 6)
		,@dblTeaMouthFeel NUMERIC(18, 6)
		,@dblTeaAppearance NUMERIC(18, 6)
		,@dblTeaVolume NUMERIC(18, 6)
		,@intValidDate INT
		,@intPrevWorkOrderId INT = 0
		,@dblLowerTolerance NUMERIC(18, 6)
		,@dblUpperTolerance NUMERIC(18, 6)
	DECLARE @tblProductProperty AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intPropertyId INT
		,strPropertyName NVARCHAR(100)
		,dblMinValue NUMERIC(18, 6)
		,dblMaxValue NUMERIC(18, 6)
		,intTestId INT
		,strTestName NVARCHAR(100)
		,intSequenceNo INT
		)
	DECLARE @intTestId INT
		,@dblTotal NUMERIC(18, 6)

	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	DECLARE @tblMFProductionOrderStage TABLE (intProductionOrderStageId INT)

	INSERT INTO @tblMFProductionOrderStage (intProductionOrderStageId)
	SELECT intProductionOrderStageId
	FROM tblMFProductionOrderStage
	WHERE intStatusId IS NULL AND strSessionId=@strSessionId

	SELECT @intProductionOrderStageId = MIN(intProductionOrderStageId)
	FROM @tblMFProductionOrderStage

	IF @intProductionOrderStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblMFProductionOrderStage
	SET intStatusId = - 1
	WHERE intProductionOrderStageId IN (
			SELECT DS.intProductionOrderStageId
			FROM @tblMFProductionOrderStage DS
			)

	SELECT @strInfo1 = ''

	SELECT @strInfo2 = ''

	SELECT @dtmCurrentDate = GETDATE()

	WHILE @intProductionOrderStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strOrderNo = NULL
				,@strBatchId = NULL
				,@dblNoOfPack = NULL
				,@strNoOfPackUOM = NULL
				,@dblWeight = NULL
				,@strWeightUOM = NULL
				,@intDocNo = NULL
				,@strLocationNumber = NULL
				,@dblOrderQuantity = NULL
				,@strOrderQuantityUOM = NULL
				,@dblNoOfMixes = NULL
				,@dblTeaTaste = NULL
				,@dblTeaHue = NULL
				,@dblTeaIntensity = NULL
				,@dblTeaMouthFeel = NULL
				,@dblTeaAppearance = NULL
				,@dblTeaVolume = NULL

			SELECT @strOrderNo = strOrderNo
				,@strLocationNumber = strLocationCode
				,@strBatchId = strBatchId
				,@dblNoOfPack = dblNoOfPack
				,@strNoOfPackUOM = strNoOfPackUOM
				,@dblWeight = dblWeight
				,@strWeightUOM = strWeightUOM
				,@intDocNo = intDocNo
				,@dblOrderQuantity = dblOrderQuantity
				,@strOrderQuantityUOM = strOrderQuantityUOM
				,@dblNoOfMixes = dblNoOfMixes
				,@dblTeaTaste = dblTeaTaste
				,@dblTeaHue = dblTeaHue
				,@dblTeaIntensity = dblTeaIntensity
				,@dblTeaMouthFeel = dblTeaMouthFeel
				,@dblTeaAppearance = dblTeaAppearance
				,@dblTeaVolume = dblTeaVolume
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			--IF EXISTS (
			--		SELECT 1
			--		FROM dbo.tblMFProductionOrderArchive
			--		WHERE intDocNo = @intDocNo
			--		)
			--BEGIN
			--	SELECT @strError = 'Document number ' + ltrim(@intDocNo) + ' is already processed in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			SELECT @intUserId = NULL

			SELECT @intUserId = intEntityId
			FROM dbo.tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = @strCreatedBy

			IF @intUserId IS NULL
				SELECT @intUserId = intEntityId
				FROM dbo.tblSMUserSecurity WITH (NOLOCK)
				WHERE strUserName = 'IRELYADMIN'

			SELECT @intLocationId = intCompanyLocationId
				,@dblLowerTolerance=dblSanitizationOrderInputQtyTolerancePercentage 
				,@dblUpperTolerance=dblSanitizationOrderOutputQtyTolerancePercentage 
			FROM dbo.tblSMCompanyLocation
			WHERE strVendorRefNoPrefix = @strLocationNumber
				AND strLocationType = 'Plant'

			IF @intLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location cannot be blank.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblMFBlendRequirement
					WHERE strReferenceNo = @strOrderNo
						AND intLocationId = @intLocationId
					)
			BEGIN
				SELECT @strError = 'Production Order ' + @strOrderNo + ' is not available in i21'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblICLot
					WHERE strLotNumber = @strBatchId
						AND intLocationId = @intLocationId
					)
			BEGIN
				SELECT @strError = 'Batch No ' + @strBatchId + ' is not availble in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intItemId = NULL
				,@intLotId = NULL
				,@intWeightUOMId = NULL
				,@intItemUOMId = NULL

			SELECT @intItemId = intItemId
				,@intLotId = intLotId
				,@intWeightUOMId = intWeightUOMId
				,@intItemUOMId = intItemUOMId
			FROM tblICLot
			WHERE strLotNumber = @strBatchId
				AND intLocationId = @intLocationId

			SELECT @intManufacturingCellId = NULL
				,@intMachineId = NULL
				,@intBlendItemId = NULL
				,@intBlendUOMId = NULL
				,@strReferenceNo = NULL
				,@dtmPlanDate = NULL

			SELECT @intManufacturingCellId = intManufacturingCellId
				,@intMachineId = intMachineId
				,@intBlendRequirementId = intBlendRequirementId
				,@intBlendItemId = intItemId
				,@intBlendUOMId = intUOMId
				,@strReferenceNo = strReferenceNo
				,@dtmPlanDate = dtmDueDate
			FROM tblMFBlendRequirement
			WHERE strReferenceNo = @strOrderNo
				AND intLocationId = @intLocationId

			--IF @strWeightUOM = ''
			--BEGIN
			--	SELECT @strError = 'Weight UOM ' + @strWeightUOM + ' cannot be blank.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--SELECT @intUnitMeasureId = NULL
			--SELECT @intUnitMeasureId = intUnitMeasureId
			--FROM dbo.tblICUnitMeasure
			--WHERE strUnitMeasure = @strWeightUOM
			--IF @intUnitMeasureId IS NULL
			--BEGIN
			--	SELECT @strError = 'Weight UOM ' + @strWeightUOM + ' is not availble in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--SELECT @intItemUOMId = NULL
			--SELECT @intItemUOMId = intItemUOMId
			--FROM tblICItemUOM IU
			--WHERE intItemId = @intItemId
			--	AND intUnitMeasureId = @intUnitMeasureId
			--IF @intItemUOMId IS NULL
			--BEGIN
			--	SELECT @strError = 'UOM ' + @strWeightUOM + ' is not configured in the item level in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--IF @strNoOfPackUOM = ''
			--BEGIN
			--	SELECT @strError = 'Pack UOM ' + @strNoOfPackUOM + ' cannot be blank.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--SELECT @intPackUnitMeasureId = NULL
			--SELECT @intPackUnitMeasureId = intUnitMeasureId
			--FROM dbo.tblICUnitMeasure
			--WHERE strUnitMeasure = @strNoOfPackUOM
			--IF @intPackUnitMeasureId IS NULL
			--BEGIN
			--	SELECT @strError = 'Pack UOM ' + @strNoOfPackUOM + ' is not availble in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--SELECT @intPackItemUOMId = NULL
			--SELECT @intPackItemUOMId = intItemUOMId
			--FROM tblICItemUOM IU
			--WHERE intItemId = @intItemId
			--	AND intUnitMeasureId = @intPackUnitMeasureId
			--IF @intPackItemUOMId IS NULL
			--BEGIN
			--	SELECT @strError = 'UOM ' + @strNoOfPackUOM + ' is not configured in the item level in i21.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			SELECT @intWorkOrderId = NULL

			SELECT @intWorkOrderId = intWorkOrderId
			FROM tblMFWorkOrder
			WHERE intBlendRequirementId = @intBlendRequirementId

			BEGIN TRAN

			IF @intWorkOrderId IS NULL
			BEGIN
				EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = @intBlendItemId
					,@intManufacturingId = @intManufacturingCellId
					,@intSubLocationId = 0
					,@intLocationId = @intLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = @intBlendRequirementId
					,@intPatternCode = 93
					,@ysnProposed = 0
					,@strPatternString = @strWorkOrderNo OUTPUT

				SELECT @intExecutionOrder = Count(1)
				FROM tblMFWorkOrder
				WHERE intManufacturingCellId = @intManufacturingCellId
					AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmPlanDate)
					AND intBlendRequirementId IS NOT NULL
					AND intStatusId NOT IN (
						2
						,13
						)

				SET @intExecutionOrder = @intExecutionOrder + 1

				SELECT @intBlendItemUOMId = NULL

				SELECT @intBlendItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intBlendItemId
					AND intUnitMeasureId = @intBlendUOMId

				IF @dblNoOfMixes = 0
					OR @dblNoOfMixes IS NULL
					SELECT @dblNoOfMixes = 1

				INSERT INTO tblMFWorkOrder (
					strWorkOrderNo
					,intItemId
					,dblQuantity
					,intItemUOMId
					,intStatusId
					,intManufacturingCellId
					,intMachineId
					,intLocationId
					,dblBinSize
					,dtmExpectedDate
					,intExecutionOrder
					,intProductionTypeId
					,dblPlannedQuantity
					,intBlendRequirementId
					,ysnKittingEnabled
					,intKitStatusId
					,ysnUseTemplate
					,strComment
					,dtmCreated
					,intCreatedUserId
					,dtmLastModified
					,intLastModifiedUserId
					,dtmReleasedDate
					,intManufacturingProcessId
					,intSalesOrderLineItemId
					,intSalesRepresentativeId
					,intInvoiceDetailId
					,intLoadDistributionDetailId
					,dtmPlannedDate
					,intPlannedShiftId
					,intCustomerId
					,intConcurrencyId
					,intTransactionFrom
					,strERPOrderNo
					,dblLowerTolerance
					,dblUpperTolerance
					,dblCalculatedLowerTolerance
					,dblCalculatedUpperTolerance
					)
				SELECT @strWorkOrderNo
					,@intBlendItemId
					,@dblOrderQuantity
					,@intBlendItemUOMId
					,2 AS intWorkOrderStatusId
					,@intManufacturingCellId
					,@intMachineId
					,@intLocationId
					,@dblOrderQuantity / @dblNoOfMixes
					,@dtmPlanDate
					,@intExecutionOrder
					,1
					,@dblOrderQuantity
					,@intBlendRequirementId
					,0 AS ysnKittingEnabled
					,NULL AS intKitStatusId
					,0
					,''
					,@dtmCurrentDate
					,@intUserId
					,@dtmCurrentDate
					,@intUserId
					,@dtmCurrentDate
					,1 AS intManufacturingProcessId
					,NULL AS intSalesOrderDetailId
					,NULL AS intSalesRepresentativeId
					,NULL AS intInvoiceDetailId
					,NULL AS intLoadDistributionDetailId
					,@dtmPlanDate
					,NULL intPlannedShiftId
					,NULL AS intCustomerId
					,1
					,NULL AS intTransactionFrom
					,@strReferenceNo
					,@dblLowerTolerance
					,@dblUpperTolerance
					,@dblOrderQuantity-(@dblOrderQuantity*@dblLowerTolerance/100)
					,@dblOrderQuantity+(@dblOrderQuantity*@dblUpperTolerance/100)

				SELECT @intWorkOrderId = SCOPE_IDENTITY()

				EXEC dbo.uspMFCopyRecipe @intItemId = @intBlendItemId
					,@intLocationId = @intLocationId
					,@intUserId = @intUserId
					,@intWorkOrderId = @intWorkOrderId

				SELECT @intTestId = strAttributeValue
				FROM tblMFManufacturingProcessAttribute pa
				JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
				WHERE pa.intManufacturingProcessId = 1
					AND pa.intLocationId = @intLocationId
					AND at.strAttributeName = 'Test Name'

				DELETE
				FROM @tblProductProperty

				INSERT INTO @tblProductProperty
				SELECT DISTINCT PRT.intPropertyId
					,PRT.strPropertyName
					,MIN(PPV.dblMinValue)
					,MAX(PPV.dblMaxValue)
					,TST.intTestId
					,TST.strTestName
					,PP.intSequenceNo
				FROM tblQMProduct PRD
				JOIN tblQMProductProperty PP ON PP.intProductId = PRD.intProductId
				JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
				JOIN tblQMProperty PRT ON PRT.intPropertyId = PP.intPropertyId
				JOIN tblQMTestProperty TP ON TP.intPropertyId = PRT.intPropertyId
					AND PP.intTestId = TP.intTestId
				JOIN tblQMTest TST ON TST.intTestId = TP.intTestId
				WHERE PRD.intProductValueId = @intBlendItemId
					AND PRD.intProductTypeId = 2
					AND PRD.ysnActive = 1
					AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
						AND DATEPART(dy, PPV.dtmValidTo)
				GROUP BY PRT.intPropertyId
					,PRT.strPropertyName
					,TST.intTestId
					,TST.strTestName
					,PP.intSequenceNo
				ORDER BY PP.intSequenceNo

				INSERT INTO tblMFWorkOrderRecipeComputation (
					intWorkOrderId
					,intTestId
					,intPropertyId
					,dblComputedValue
					,dblMinValue
					,dblMaxValue
					,intTypeId
					,intMethodId
					)
				SELECT DISTINCT @intWorkOrderId
					,intTestId
					,intPropertyId
					,CASE 
						WHEN strPropertyName = 'Taste'
							THEN @dblTeaTaste
						WHEN strPropertyName = 'Hue '
							THEN @dblTeaHue
						WHEN strPropertyName = 'Intensity'
							THEN @dblTeaIntensity
						WHEN strPropertyName = 'Mouth feel'
							THEN @dblTeaMouthFeel
						WHEN strPropertyName = 'Appearance'
							THEN @dblTeaAppearance
						WHEN strPropertyName = 'Volumne'
							THEN @dblTeaVolume
						END
					,dblMinValue
					,dblMaxValue
					,1
					,1
				FROM @tblProductProperty
				WHERE intTestId = @intTestId
			END

			IF NOT EXISTS (
					SELECT *
					FROM tblMFWorkOrderInputLot
					WHERE intWorkOrderId = @intWorkOrderId
						AND intLotId = @intLotId
					)
			BEGIN
				INSERT INTO tblMFWorkOrderInputLot (
					intWorkOrderId
					,intItemId
					,intLotId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intConcurrencyId
					)
				SELECT @intWorkOrderId
					,@intItemId
					,@intLotId
					,@dblWeight
					,@intWeightUOMId
					,@dblNoOfPack
					,@intItemUOMId
					,1
			END

			MOVE_TO_ARCHIVE:

			--Move to Archive
			INSERT INTO dbo.tblMFProductionOrderArchive (
				intDocNo
				,strOrderNo
				,strLocationCode
				,dblOrderQuantity
				,strOrderQuantityUOM
				,dblNoOfMixes
				,dtmPlanDate
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
				)
			SELECT intDocNo
				,strOrderNo
				,strLocationCode
				,dblOrderQuantity
				,strOrderQuantityUOM
				,dblNoOfMixes
				,dtmPlanDate
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			DELETE
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			IF NOT EXISTS (
					SELECT *
					FROM tblMFProductionOrderStage
					WHERE strOrderNo = @strOrderNo
					)
			BEGIN
				DELETE
				FROM @tblProductProperty

				INSERT INTO @tblProductProperty
				SELECT DISTINCT PRT.intPropertyId
					,PRT.strPropertyName
					,MIN(PPV.dblMinValue)
					,MAX(PPV.dblMaxValue)
					,TST.intTestId
					,TST.strTestName
					,PP.intSequenceNo
				FROM tblQMProduct PRD
				JOIN tblQMProductProperty PP ON PP.intProductId = PRD.intProductId
				JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
				JOIN tblQMProperty PRT ON PRT.intPropertyId = PP.intPropertyId
				JOIN tblQMTestProperty TP ON TP.intPropertyId = PRT.intPropertyId
					AND PP.intTestId = TP.intTestId
				JOIN tblQMTest TST ON TST.intTestId = TP.intTestId
				WHERE PRD.intProductValueId = @intBlendItemId
					AND PRD.intProductTypeId = 2
					AND PRD.ysnActive = 1
					AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
						AND DATEPART(dy, PPV.dtmValidTo)
				GROUP BY PRT.intPropertyId
					,PRT.strPropertyName
					,TST.intTestId
					,TST.strTestName
					,PP.intSequenceNo
				ORDER BY PP.intSequenceNo

				SELECT @dblTotal = SuM(dblQuantity)
				FROM tblMFWorkOrderInputLot
				WHERE intWorkOrderId = @intWorkOrderId

				INSERT INTO tblMFWorkOrderRecipeComputation (
					intWorkOrderId
					,intTestId
					,intPropertyId
					,dblComputedValue
					,dblMinValue
					,dblMaxValue
					,intTypeId
					,intMethodId
					)
				SELECT @intWorkOrderId
					,PP.intTestId
					,PP.intPropertyId
					,CAST(IsNULL((Type1.dblQty / @dblTotal) * 100, 0) AS DECIMAL(18, 4)) AS dblComputedValue
					,PP.dblMinValue
					,PP.dblMaxValue
					,1
					,1
				FROM @tblProductProperty PP
				OUTER APPLY (
					SELECT CA.strDescription
						,sum(L.dblQuantity) dblQty
					FROM tblMFWorkOrderInputLot L
					JOIN tblICLot Lot ON Lot.intLotId = L.intLotId
						AND L.intWorkOrderId = @intWorkOrderId
					JOIN tblICItem I ON I.intItemId = Lot.intItemId
					JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intProductTypeId
					WHERE CA.strDescription COLLATE Latin1_General_CI_AS = PP.strPropertyName
					GROUP BY CA.strDescription
					) Type1
				WHERE PP.strTestName = 'Type'

				INSERT INTO tblMFWorkOrderRecipeComputation (
					intWorkOrderId
					,intTestId
					,intPropertyId
					,dblComputedValue
					,dblMinValue
					,dblMaxValue
					,intTypeId
					,intMethodId
					)
				SELECT @intWorkOrderId
					,PP.intTestId
					,PP.intPropertyId
					,CAST(IsNULL((Type1.dblQty / @dblTotal) * 100, 0) AS DECIMAL(18, 4)) AS dblComputedValue
					,PP.dblMinValue
					,PP.dblMaxValue
					,1
					,1
				FROM @tblProductProperty PP
				OUTER APPLY (
					SELECT C.strISOCode
						,sum(L.dblQuantity) dblQty
					FROM tblMFWorkOrderInputLot L
					JOIN tblICLot Lot ON Lot.intLotId = L.intLotId
						AND L.intWorkOrderId = @intWorkOrderId
					JOIN tblICItem I ON I.intItemId = Lot.intItemId
					JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
					JOIN tblSMCountry C ON C.intCountryID = CA.intCountryID
					WHERE C.strISOCode COLLATE Latin1_General_CI_AS = PP.strPropertyName
					GROUP BY C.strISOCode
					) Type1
				WHERE PP.strTestName = 'Origin'

				INSERT INTO tblMFWorkOrderRecipeComputation (
					intWorkOrderId
					,intTestId
					,intPropertyId
					,dblComputedValue
					,dblMinValue
					,dblMaxValue
					,intTypeId
					,intMethodId
					)
				SELECT @intWorkOrderId
					,PP.intTestId
					,PP.intPropertyId
					,CAST(IsNULL((Type1.dblQty / @dblTotal) * 100, 0) AS DECIMAL(18, 4)) AS dblComputedValue
					,PP.dblMinValue
					,PP.dblMaxValue
					,1
					,1
				FROM @tblProductProperty PP
				OUTER APPLY (
					SELECT B.strBrandCode
						,sum(L.dblQuantity) dblQty
					FROM tblMFWorkOrderInputLot L
					JOIN tblICLot Lot ON Lot.intLotId = L.intLotId
						AND L.intWorkOrderId = @intWorkOrderId
					JOIN tblICItem I ON I.intItemId = Lot.intItemId
					JOIN tblICBrand B ON B.intBrandId = I.intBrandId
					WHERE B.strBrandCode COLLATE Latin1_General_CI_AS = PP.strPropertyName
					GROUP BY B.strBrandCode
					) Type1
				WHERE PP.strTestName = 'Size'
			END

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO dbo.tblMFProductionOrderError (
				intDocNo
				,strOrderNo
				,strLocationCode
				,dblOrderQuantity
				,strOrderQuantityUOM
				,dblNoOfMixes
				,dtmPlanDate
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
				,strMessage
				)
			SELECT intDocNo
				,strOrderNo
				,strLocationCode
				,dblOrderQuantity
				,strOrderQuantityUOM
				,dblNoOfMixes
				,dtmPlanDate
				,strBatchId
				,dblNoOfPack
				,strNoOfPackUOM
				,dblWeight
				,strWeightUOM
				,dtmFeedDate
				,@ErrMsg
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId

			DELETE
			FROM dbo.tblMFProductionOrderStage
			WHERE intProductionOrderStageId = @intProductionOrderStageId
		END CATCH

		SELECT @intProductionOrderStageId = MIN(intProductionOrderStageId)
		FROM @tblMFProductionOrderStage
		WHERE intProductionOrderStageId > @intProductionOrderStageId
	END

	UPDATE tblMFProductionOrderStage
	SET intStatusId = NULL
	WHERE intProductionOrderStageId IN (
			SELECT PS.intProductionOrderStageId
			FROM @tblMFProductionOrderStage PS
			)
		AND intStatusId = - 1

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
