CREATE PROCEDURE uspQMGetSampleProperty @intProductTypeId INT
	,@intProductValueId INT
	,@intItemId INT
	,@intControlPointId INT
	,@intSampleTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @intProductId INT
	DECLARE @intCategoryId INT
	DECLARE @intValidDate INT

	SET @intCategoryId = 0
	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	SELECT @intControlPointId = intControlPointId
	FROM tblQMSampleType
	WHERE intSampleTypeId = @intSampleTypeId

	IF @intProductTypeId = 3
		OR @intProductTypeId = 4
		OR @intProductTypeId = 5
	BEGIN
		SET @intProductId = (
				SELECT P.intProductId
				FROM tblQMProduct AS P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = @intProductTypeId
					AND P.intProductValueId IS NULL
					AND PC.intSampleTypeId = @intSampleTypeId
					AND P.ysnActive = 1
				)
	END
	ELSE
	BEGIN
		SET @intProductId = (
				SELECT P.intProductId
				FROM tblQMProduct AS P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = 2 -- Item
					AND P.intProductValueId = @intItemId
					AND PC.intSampleTypeId = @intSampleTypeId
					AND P.ysnActive = 1
				)

		IF @intProductId IS NULL
		BEGIN
			SET @intCategoryId = (
					SELECT intCategoryId
					FROM dbo.tblICItem
					WHERE intItemId = @intItemId
					)
			SET @intProductId = (
					SELECT P.intProductId
					FROM tblQMProduct AS P
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
					WHERE P.intProductTypeId = 1 -- Item Category
						AND P.intProductValueId = @intCategoryId
						AND PC.intSampleTypeId = @intSampleTypeId
						AND P.ysnActive = 1
					)
		END
	END

	IF @intControlPointId IN (
			11
			,12
			)
	BEGIN
		DECLARE @strLotCode NVARCHAR(50)
			,@dtmPlannedDate DATETIME
			,@intPlannedShiftId INT
			,@intLocationId INT
			,@strPackagingCategory NVARCHAR(50)
			,@intPMCategoryId INT
			,@intSubLocationId INT
			,@intManufacturingProcessId INT
			,@strItemNo NVARCHAR(50)
			,@intLifeTime INT
			,@strLifeTimeType NVARCHAR(50)
			,@dtmExpiryDate DATETIME
			,@strRawMaterial NVARCHAR(100)
			,@strPackingMaterial NVARCHAR(100)
			,@strPackingMaterial1 NVARCHAR(100)
			
			,@strPalletId1 NVARCHAR(MAX)
			,@intTaskId INT
			,@intOriginId INT
			,@intStatusId INT
			,@intRecipeId INT
			
			,@strPackagingLotCode1 NVARCHAR(50)
			,@strPackagingLotCode2 NVARCHAR(50)
			,@strPackagingLotCode3 NVARCHAR(50)
			,@strTargetWeight NVARCHAR(50)
			,@intShiftId INT
			,@strLotCode1 NVARCHAR(50)
			,@strScreenSize NVARCHAR(50)
			,@intProductionStageLocationId INT
			,@intStageLocationId INT
			,@intPMStageLocationId INT

		SELECT @dtmPlannedDate = dtmPlannedDate
			,@intPlannedShiftId = intPlannedShiftId
			,@intLocationId = intLocationId
			,@intSubLocationId = intSubLocationId
			,@intManufacturingProcessId = intManufacturingProcessId
			,@intStatusId = intStatusId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intProductValueId

		SELECT @strItemNo = strItemNo
			,@strScreenSize = strWeightControlCode
			,@strTargetWeight = Convert(NUMERIC(18, 0), dblBlendWeight)
		FROM tblICItem
		WHERE intItemId = @intItemId

		IF @strScreenSize IS NULL
			SELECT @strScreenSize = ''

		IF @strTargetWeight IS NULL
			SELECT @strTargetWeight = ''

		SELECT @strLotCode1 = ''

		SELECT @intShiftId = MIN(intShiftId)
		FROM dbo.tblMFShift

		WHILE @intShiftId IS NOT NULL
		BEGIN
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = NULL
				,@intSubLocationId = @intSubLocationId
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 78
				,@ysnProposed = 0
				,@strPatternString = @strLotCode OUTPUT
				,@intShiftId = @intShiftId
				,@dtmDate = @dtmPlannedDate

			SELECT @strLotCode1 = @strLotCode1 + @strLotCode + ', '

			SELECT @intShiftId = MIN(intShiftId)
			FROM dbo.tblMFShift
			WHERE intShiftId > @intShiftId
		END

		IF @strLotCode1 <> ''
			SELECT @strLotCode = Left(@strLotCode1, len(@strLotCode1) - 1)

		SELECT @intPMCategoryId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 46 --Packaging Category

		SELECT @strRawMaterial = ''

		DECLARE @tblMFRawItem TABLE (intItemId INT)
		DECLARE @tblMFPackingItem1 TABLE (intItemId INT)
		DECLARE @tblMFPackingItem2 TABLE (intItemId INT)
		DECLARE @tblMFPackingItem3 TABLE (intItemId INT)
		DECLARE @strPackingCategory1 NVARCHAR(50)
		DECLARE @strPackingCategory2 NVARCHAR(50)
		DECLARE @strPackingCategory3 NVARCHAR(50)
		DECLARE @strPackingCategory4 NVARCHAR(50)
		DECLARE @strPackingCategory5 NVARCHAR(50)
		DECLARE @strPackingCategory6 NVARCHAR(50)

		SELECT @strPackingCategory1 = strValue
		FROM tblMFPackingItemCategory
		WHERE strName = 'PM1'

		SELECT @strPackingCategory2 = strValue
		FROM tblMFPackingItemCategory
		WHERE strName = 'PM2'

		SELECT @strPackingCategory3 = strValue
		FROM tblMFPackingItemCategory
		WHERE strName = 'PM3'

		SELECT @strPackingCategory4 = strValue
		FROM tblMFPackingItemCategory
		WHERE strName = 'PM4'

		SELECT @strPackingCategory5 = strValue
		FROM tblMFPackingItemCategory
		WHERE strName = 'PM5'

		SELECT @strPackingCategory6 = strValue
		FROM tblMFPackingItemCategory
		WHERE strName = 'PM6'

		IF @intStatusId <> 10
		BEGIN
			SELECT @intRecipeId = intRecipeId
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intLocationId = @intLocationId
				AND ysnActive = 1

			INSERT INTO @tblMFRawItem (intItemId)
			SELECT I.intItemId
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeItemTypeId = 1
				AND RI.intRecipeId = @intRecipeId
			WHERE I.intCategoryId <> @intPMCategoryId

			INSERT INTO @tblMFRawItem (intItemId)
			SELECT I.intItemId
			FROM tblMFRecipeSubstituteItem RI
			JOIN tblICItem I ON I.intItemId = RI.intSubstituteItemId
				AND RI.intRecipeId = @intRecipeId
			WHERE I.intCategoryId <> @intPMCategoryId

			INSERT INTO @tblMFPackingItem1 (intItemId)
			SELECT I.intItemId
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
			WHERE (
					I.strDescription LIKE @strPackingCategory1
					OR I.strDescription LIKE @strPackingCategory2
					OR I.strDescription LIKE @strPackingCategory3
					)

			INSERT INTO @tblMFPackingItem2 (intItemId)
			SELECT I.intItemId
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
			WHERE I.strDescription LIKE @strPackingCategory4

			INSERT INTO @tblMFPackingItem3 (intItemId)
			SELECT I.intItemId
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
			WHERE I.strDescription LIKE @strPackingCategory5

			SELECT @strPackingMaterial = ''

			SELECT @strPackingMaterial = I.strItemNo
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			And RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				Where I.strDescription LIKE @strPackingCategory1

			IF @strPackingMaterial IS NULL
				SELECT @strPackingMaterial = ''

			SELECT @strPackingMaterial1 = ''

			SELECT @strPackingMaterial1 = I.strItemNo
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			And RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				Where I.strDescription LIKE @strPackingCategory6

			IF @strPackingMaterial1 IS NULL
				SELECT @strPackingMaterial1 = ''
		END
		ELSE
		BEGIN
			SELECT @intRecipeId = intRecipeId
			FROM tblMFWorkOrderRecipe
			WHERE intItemId = @intItemId
				AND intLocationId = @intLocationId
				AND ysnActive = 1
				AND intWorkOrderId = @intProductValueId

			INSERT INTO @tblMFRawItem (intItemId)
			SELECT I.intItemId
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeItemTypeId = 1
				AND RI.intRecipeId = @intRecipeId
				AND RI.intWorkOrderId = @intProductValueId
			WHERE I.intCategoryId <> @intPMCategoryId

			INSERT INTO @tblMFRawItem (intItemId)
			SELECT I.intItemId
			FROM tblMFWorkOrderRecipeSubstituteItem RI
			JOIN tblICItem I ON I.intItemId = RI.intSubstituteItemId
			WHERE RI.intRecipeId = @intRecipeId
				AND RI.intWorkOrderId = @intProductValueId
				AND I.intCategoryId <> @intPMCategoryId

			INSERT INTO @tblMFPackingItem1 (intItemId)
			SELECT I.intItemId
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND RI.intWorkOrderId = @intProductValueId
			WHERE (
					I.strDescription LIKE @strPackingCategory1
					OR I.strDescription LIKE @strPackingCategory2
					OR I.strDescription LIKE @strPackingCategory3
					)

			INSERT INTO @tblMFPackingItem2 (intItemId)
			SELECT I.intItemId
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND RI.intWorkOrderId = @intProductValueId
			WHERE I.strDescription LIKE @strPackingCategory4

			INSERT INTO @tblMFPackingItem3 (intItemId)
			SELECT I.intItemId
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND RI.intWorkOrderId = @intProductValueId
			WHERE I.strDescription LIKE @strPackingCategory5

			SELECT @strPackingMaterial = ''

			SELECT @strPackingMaterial = I.strItemNo
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			and RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND RI.intWorkOrderId = @intProductValueId
				Where I.strDescription LIKE @strPackingCategory1

			IF @strPackingMaterial IS NULL
				SELECT @strPackingMaterial = ''

			SELECT @strPackingMaterial1 = ''

			SELECT @strPackingMaterial1 = I.strItemNo
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			and RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND RI.intWorkOrderId = @intProductValueId
				Where I.strDescription LIKE @strPackingCategory6

			IF @strPackingMaterial1 IS NULL
				SELECT @strPackingMaterial1 = ''
		END

		SELECT @strRawMaterial = @strRawMaterial + I.strItemNo + ', '
		FROM @tblMFRawItem RI
		JOIN tblICItem I ON I.intItemId = RI.intItemId

		IF @strRawMaterial IS NULL
			SELECT @strRawMaterial = ''

		IF @strRawMaterial <> ''
		BEGIN
			SELECT @strRawMaterial = Left(@strRawMaterial, Len(@strRawMaterial) - 1)
		END

		

		SELECT @strPalletId1 = ''

		SELECT @intProductionStageLocationId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 75 --Production Staging Location

		SELECT @intStageLocationId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 76 --Staging Location

		SELECT @intPMStageLocationId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 90 --PM Staging Location

		SELECT @strPalletId1 = @strPalletId1 + DT.strParentLotNumber + ', '
		FROM (
			SELECT DISTINCT strParentLotNumber
			FROM @tblMFRawItem I
			JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
				AND L.dblQty > 0
				AND L.intStorageLocationId IN (
					@intProductionStageLocationId
					,@intStageLocationId
					)
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			) AS DT

		
		IF @strPalletId1 IS NULL
			SELECT @strPalletId1 = ''

		IF @strPalletId1 <> ''
		BEGIN
			SELECT @strPalletId1 = Left(@strPalletId1, Len(@strPalletId1) - 1)
		END

		SELECT @strPalletId1 = @strPalletId1 + ', N/A'

		SELECT @strPackagingLotCode1 = ''
			,@strPackagingLotCode2 = ''

		SELECT @strPackagingLotCode1 = @strPackagingLotCode1 + DT.strParentLotNumber + ', '
		FROM (
			SELECT DISTINCT strParentLotNumber
			FROM @tblMFPackingItem1 I
			JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
				AND L.dblQty > 0
				AND L.intStorageLocationId = @intPMStageLocationId
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			) AS DT

		IF @strPackagingLotCode1 IS NULL
			SELECT @strPackagingLotCode1 = ''

		IF @strPackagingLotCode1 <> ''
		BEGIN
			SELECT @strPackagingLotCode1 = Left(@strPackagingLotCode1, Len(@strPackagingLotCode1) - 1)
		END


		SELECT @strPackagingLotCode2 = @strPackagingLotCode2 + DT.strParentLotNumber + ', '
		FROM (
			SELECT DISTINCT strParentLotNumber
			FROM @tblMFPackingItem2 I
			JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
				AND L.dblQty > 0
				AND L.intStorageLocationId = @intPMStageLocationId
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			) AS DT

		IF @strPackagingLotCode2 IS NULL
			SELECT @strPackagingLotCode2 = ''

		IF @strPackagingLotCode2 <> ''
		BEGIN
			SELECT @strPackagingLotCode2 = Left(@strPackagingLotCode2, Len(@strPackagingLotCode2) - 1)
		END


		SELECT @strPackagingLotCode3 = @strPackagingLotCode3 + DT.strParentLotNumber + ', '
		FROM (
			SELECT DISTINCT strParentLotNumber
			FROM @tblMFPackingItem3 I
			JOIN dbo.tblICLot L ON L.intItemId = I.intItemId
				AND L.dblQty > 0
				AND L.intStorageLocationId = @intPMStageLocationId
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			) AS DT

		IF @strPackagingLotCode3 IS NULL
			SELECT @strPackagingLotCode3 = ''

		IF @strPackagingLotCode3 <> ''
		BEGIN
			SELECT @strPackagingLotCode3 = Left(@strPackagingLotCode3, Len(@strPackagingLotCode3) - 1)
		END

		SELECT DISTINCT 0 AS intSampleId
			,0 AS intTestResultId
			,@intProductId AS intProductId
			,@intProductTypeId AS intProductTypeId
			,@intProductValueId AS intProductValueId
			,T.intTestId
			,T.strTestName
			,PRT.intPropertyId
			,PRT.strPropertyName
			,PRT.strDescription
			,'' AS strPropertyValue
			,GETDATE() AS dtmCreateDate
			,'' AS strResult
			,cast(0 AS BIT) AS ysnFinal
			,'' AS strComment
			,PP.intSequenceNo
			,PPV.dtmValidFrom
			,PPV.dtmValidTo
			,Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace((
																		CASE 
																			WHEN PRT.strDefaultValue = ''
																				THEN PPV.strPropertyRangeText
																			ELSE PRT.strDefaultValue
																			END
																		), '{Lot Code}', @strLotCode), '{Product}', @strItemNo), '{Raw Material}', @strRawMaterial), '{Packing Material - Pouch}', @strPackingMaterial), '{Packing Material - Case}', @strPackingMaterial1), '{Raw Material Lot Code 1}', @strPalletId1), '{Raw Material Lot Code 2}', @strPalletId1), '{Raw Material Lot Code 3}', @strPalletId1), '{Packing Material Lot Code 1}', @strPackagingLotCode1), '{Packing Material Lot Code 2}', @strPackagingLotCode2), '{Packing Material Lot Code 3}', @strPackagingLotCode3), '{Target Weight}', @strTargetWeight), '{Screen Size}', @strScreenSize) AS strPropertyRangeText
			,PPV.dblMinValue
			,PPV.dblMaxValue
			,PPV.dblLowValue
			,PPV.dblHighValue
			,U.intUnitMeasureId AS intUnitMeasureId
			,U.strUnitMeasure AS strUnitMeasure
			,PPV.intProductPropertyValidityPeriodId
			,PC.intControlPointId
			,0 AS intParentPropertyId
			,0 AS intRepNo
			,PP.strIsMandatory
			,PRT.intItemId AS intPropertyItemId
			,PRT.intDataTypeId
			,PRT.intDecimalPlaces
			,PRT.intListId
			,L.strListName
			,T.intReplications
			,PP.strFormulaField AS strFormula
			,PP.strFormulaParser
			,0 AS intPropertyValidityPeriodId
			,'' AS strConditionalResult
			,PRTI.strItemNo AS strPropertyItemNo
		FROM dbo.tblQMProduct AS PRD
		JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
		JOIN dbo.tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
		JOIN dbo.tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
			AND PT.intProductId = PRD.intProductId
		JOIN dbo.tblQMTest AS T ON T.intTestId = PP.intTestId
			AND T.intTestId = PT.intTestId
		JOIN dbo.tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
			AND TP.intTestId = PP.intTestId
			AND TP.intTestId = T.intTestId
			AND TP.intTestId = PT.intTestId
		JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
			AND PRT.intPropertyId = TP.intPropertyId
		JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		LEFT JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = PPV.intUnitMeasureId
		LEFT JOIN dbo.tblQMList AS L ON L.intListId = PRT.intListId
		LEFT JOIN tblICItem PRTI ON PRTI.intItemId = PRT.intItemId
		WHERE PRD.intProductId = @intProductId
			AND PC.intSampleTypeId = @intSampleTypeId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo
	END
	ELSE
	BEGIN
		SELECT DISTINCT 0 AS intSampleId
			,0 AS intTestResultId
			,@intProductId AS intProductId
			,@intProductTypeId AS intProductTypeId
			,@intProductValueId AS intProductValueId
			,T.intTestId
			,T.strTestName
			,PRT.intPropertyId
			,PRT.strPropertyName
			,PRT.strDescription
			,'' AS strPropertyValue
			,GETDATE() AS dtmCreateDate
			,'' AS strResult
			,cast(0 AS BIT) AS ysnFinal
			,'' AS strComment
			,PP.intSequenceNo
			,PPV.dtmValidFrom
			,PPV.dtmValidTo
			,PPV.strPropertyRangeText
			,PPV.dblMinValue
			,PPV.dblMaxValue
			,PPV.dblLowValue
			,PPV.dblHighValue
			,U.intUnitMeasureId AS intUnitMeasureId
			,U.strUnitMeasure AS strUnitMeasure
			,PPV.intProductPropertyValidityPeriodId
			,PC.intControlPointId
			,0 AS intParentPropertyId
			,0 AS intRepNo
			,PP.strIsMandatory
			,PRT.intItemId AS intPropertyItemId
			,PRT.intDataTypeId
			,PRT.intDecimalPlaces
			,PRT.intListId
			,L.strListName
			,T.intReplications
			,PP.strFormulaField AS strFormula
			,PP.strFormulaParser
			,0 AS intPropertyValidityPeriodId
			,'' AS strConditionalResult
			,PRTI.strItemNo AS strPropertyItemNo
		FROM dbo.tblQMProduct AS PRD
		JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
		JOIN dbo.tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
		JOIN dbo.tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
			AND PT.intProductId = PRD.intProductId
		JOIN dbo.tblQMTest AS T ON T.intTestId = PP.intTestId
			AND T.intTestId = PT.intTestId
		JOIN dbo.tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
			AND TP.intTestId = PP.intTestId
			AND TP.intTestId = T.intTestId
			AND TP.intTestId = PT.intTestId
		JOIN dbo.tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
			AND PRT.intPropertyId = TP.intPropertyId
		JOIN dbo.tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		LEFT JOIN dbo.tblICUnitMeasure AS U ON U.intUnitMeasureId = PPV.intUnitMeasureId
		LEFT JOIN dbo.tblQMList AS L ON L.intListId = PRT.intListId
		LEFT JOIN tblICItem PRTI ON PRTI.intItemId = PRT.intItemId
		WHERE PRD.intProductId = @intProductId
			AND PC.intSampleTypeId = @intSampleTypeId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo
	END
END
