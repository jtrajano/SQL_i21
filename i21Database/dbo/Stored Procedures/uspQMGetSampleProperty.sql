﻿CREATE PROCEDURE uspQMGetSampleProperty @intProductTypeId INT
	,@intProductValueId INT
	,@intItemId INT
	,@intControlPointId INT
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
					AND PC.intControlPointId = @intControlPointId
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
					AND PC.intControlPointId = @intControlPointId
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
						AND PC.intControlPointId = @intControlPointId
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
			,@strCountryOfOrigin NVARCHAR(50)
			,@strPalletId1 NVARCHAR(50)
			,@strPalletId2 NVARCHAR(50)
			,@strPalletId3 NVARCHAR(50)
			,@intTaskId INT
			,@intOriginId INT
			,@intStatusId INT
			,@intRecipeId INT
			,@strLotNumber nvarchar(50)
			,@strPackagingLotCode1 nvarchar(50)
			,@strPackagingLotCode2 nvarchar(50)
			,@strTargetWeight nvarchar(50)

		SELECT @dtmPlannedDate = dtmPlannedDate
			,@intPlannedShiftId = intPlannedShiftId
			,@intLocationId = intLocationId
			,@intSubLocationId = intSubLocationId
			,@intManufacturingProcessId = intManufacturingProcessId
			,@intStatusId = intStatusId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intProductValueId

		SELECT @strItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

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
			,@intShiftId = @intPlannedShiftId
			,@dtmDate = @dtmPlannedDate

		SELECT @strLifeTimeType = strLifeTimeType
			,@intLifeTime = intLifeTime
			,@strTargetWeight=strWeightControlCode
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		IF @strLifeTimeType = 'Years'
			SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Months'
			SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Days'
			SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Hours'
			SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Minutes'
			SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, GetDate())
		ELSE
			SET @dtmExpiryDate = DateAdd(yy, 1, GetDate())

		SELECT @strPackagingCategory = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 46 --Packaging Category

		SELECT @intPMCategoryId = intCategoryId
		FROM tblICCategory
		WHERE strCategoryCode = @strPackagingCategory

		SELECT @strRawMaterial = ''

		IF @intStatusId <>10
		BEGIN
			SELECT @intRecipeId = intRecipeId
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intLocationId = @intLocationId
				AND ysnActive = 1

			SELECT @strRawMaterial = @strRawMaterial + I.strItemNo + ','
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeItemTypeId = 1
			WHERE RI.intRecipeId = @intRecipeId
				AND I.intCategoryId <> @intPMCategoryId

			SELECT @strRawMaterial = @strRawMaterial + I.strItemNo + ','
			FROM tblMFRecipeSubstituteItem RI
			JOIN tblICItem I ON I.intItemId = RI.intSubstituteItemId
			WHERE RI.intRecipeId = @intRecipeId
				AND I.intCategoryId <> @intPMCategoryId

			IF @strRawMaterial <> ''
			BEGIN
				SELECT @strRawMaterial = Left(@strRawMaterial, Len(@strRawMaterial) - 1)
			END

			SELECT @strPackingMaterial = ''

			SELECT @strPackingMaterial =  I.strItemNo 
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			WHERE RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND I.strDescription Like 'Pch-%'

			SELECT @strPackingMaterial1 = ''

			SELECT @strPackingMaterial1 =  I.strItemNo 
			FROM tblMFRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			WHERE RI.intRecipeId = @intRecipeId
				AND I.intCategoryId = @intPMCategoryId
				AND I.strDescription Like 'Cs-%'
		END
		ELSE
		BEGIN
			SELECT @strRawMaterial = @strRawMaterial + I.strItemNo + ','
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
				AND RI.intRecipeItemTypeId = 1
			WHERE intWorkOrderId = @intProductValueId
				AND I.intCategoryId <> @intPMCategoryId

			SELECT @strRawMaterial = @strRawMaterial + I.strItemNo + ','
			FROM tblMFWorkOrderRecipeSubstituteItem RI
			JOIN tblICItem I ON I.intItemId = RI.intSubstituteItemId
			WHERE intWorkOrderId = @intProductValueId
				AND I.intCategoryId <> @intPMCategoryId

			IF @strRawMaterial <> ''
			BEGIN
				SELECT @strRawMaterial = Left(@strRawMaterial, Len(@strRawMaterial) - 1)
			END

			SELECT @strPackingMaterial = ''

			SELECT @strPackingMaterial = I.strItemNo
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			WHERE intWorkOrderId = @intProductValueId
				AND I.intCategoryId = @intPMCategoryId
				AND I.strDescription Like 'Pch-%'

			SELECT @strPackingMaterial1 = ''

			SELECT @strPackingMaterial1 = I.strItemNo
			FROM tblMFWorkOrderRecipeItem RI
			JOIN tblICItem I ON I.intItemId = RI.intItemId
			WHERE intWorkOrderId = @intProductValueId
				AND I.intCategoryId = @intPMCategoryId
				AND I.strDescription Like 'Cs-%'
		END

		

		SELECT @strCountryOfOrigin = ''

		SELECT @strPalletId1 = ''
			,@strPalletId2 = ''
			,@strPalletId3 = ''

		SELECT TOP 1 @strPalletId1 = PL.strParentLotNumber,@strLotNumber=strLotNumber 
			,@intTaskId = T.intTaskId
		FROM tblMFStageWorkOrder SW
		JOIN dbo.tblMFTask T ON T.intOrderHeaderId = SW.intOrderHeaderId
		JOIN dbo.tblICLot L ON L.intLotId = T.intLotId
		JOIN dbo.tblICParentLot PL on PL.intParentLotId =L.intParentLotId 
		JOIN tblICItem I ON I.intItemId = T.intItemId
		WHERE intWorkOrderId = @intProductValueId
			AND I.intCategoryId <> @intPMCategoryId
		ORDER BY T.intTaskId

		IF @strPalletId1 IS NULL
			SELECT @strPalletId1 = ''

		SELECT TOP 1 @strPalletId2 = PL.strParentLotNumber
			,@intTaskId = T.intTaskId
		FROM tblMFStageWorkOrder SW
		JOIN dbo.tblMFTask T ON T.intOrderHeaderId = SW.intOrderHeaderId
		JOIN dbo.tblICLot L ON L.intLotId = T.intLotId
		JOIN dbo.tblICParentLot PL on PL.intParentLotId =L.intParentLotId 
		JOIN tblICItem I ON I.intItemId = T.intItemId
		WHERE intWorkOrderId = @intProductValueId
			AND I.intCategoryId <> @intPMCategoryId
			AND T.intTaskId > @intTaskId
		ORDER BY T.intTaskId

		IF @strPalletId2 IS NULL
			SELECT @strPalletId2 = ''

		SELECT TOP 1 @strPalletId3 = PL.strParentLotNumber
			,@intTaskId = T.intTaskId
		FROM tblMFStageWorkOrder SW
		JOIN dbo.tblMFTask T ON T.intOrderHeaderId = SW.intOrderHeaderId
		JOIN dbo.tblICLot L ON L.intLotId = T.intLotId
		JOIN dbo.tblICParentLot PL on PL.intParentLotId =L.intParentLotId 
		JOIN tblICItem I ON I.intItemId = T.intItemId
		WHERE intWorkOrderId = @intProductValueId
			AND I.intCategoryId <> @intPMCategoryId
			AND T.intTaskId > @intTaskId
		ORDER BY T.intTaskId

		IF @strPalletId3 IS NULL
			SELECT @strPalletId3 = ''

			SELECT @strPackagingLotCode1 = ''
			,@strPackagingLotCode2 = ''

		SELECT TOP 1 @strPackagingLotCode1 = PL.strParentLotNumber 
			,@intTaskId = T.intTaskId
		FROM tblMFStageWorkOrder SW
		JOIN dbo.tblMFTask T ON T.intOrderHeaderId = SW.intOrderHeaderId
		JOIN dbo.tblICLot L ON L.intLotId = T.intLotId
		JOIN dbo.tblICParentLot PL on PL.intParentLotId =L.intParentLotId 
		JOIN tblICItem I ON I.intItemId = T.intItemId
		WHERE intWorkOrderId = @intProductValueId
		AND I.strDescription Like 'Pch-%'
		ORDER BY T.intTaskId

		IF @strPackagingLotCode1 IS NULL
			SELECT @strPackagingLotCode1 = ''

		SELECT TOP 1 @strPackagingLotCode2 = PL.strParentLotNumber
		FROM tblMFStageWorkOrder SW
		JOIN dbo.tblMFTask T ON T.intOrderHeaderId = SW.intOrderHeaderId
		JOIN dbo.tblICLot L ON L.intLotId = T.intLotId
		JOIN dbo.tblICParentLot PL on PL.intParentLotId =L.intParentLotId 
		JOIN tblICItem I ON I.intItemId = T.intItemId
		WHERE intWorkOrderId = @intProductValueId
			AND I.strDescription Like 'Pch-%'
			AND T.intTaskId > @intTaskId
		ORDER BY T.intTaskId

		IF @strPackagingLotCode2 IS NULL
			SELECT @strPackagingLotCode2 = ''

		SELECT @intOriginId = intOriginId
		FROM tblICInventoryReceiptItemLot
		WHERE strLotNumber = @strLotNumber

		SELECT @strCountryOfOrigin = strCountry
		FROM tblSMCountry
		WHERE intCountryID = @intOriginId

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
			,Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace((Case When PRT.strDefaultValue='' Then PPV.strPropertyRangeText Else PRT.strDefaultValue End), '{Lot Code}', @strLotCode), '{Product}', @strItemNo), '{Product Expiration Date}', @dtmExpiryDate), '{Raw Material}', @strRawMaterial), '{Packing Material - Pouch}', @strPackingMaterial), '{Packing Material - Case}', @strPackingMaterial1), '{Country of Origin}', @strCountryOfOrigin), '{Raw Material Lot Code 1}', @strPalletId1), '{Raw Material Lot Code 2}', @strPalletId2), '{Raw Material Lot Code 3}', @strPalletId3) , '{Packing Material Lot Code 1}', @strPackagingLotCode1 ), '{Packing Material Lot Code 2}', @strPackagingLotCode2), '{Target Weight}', @strTargetWeight)AS strPropertyRangeText
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
			,PRT.intDataTypeId
			,PRT.intDecimalPlaces
			,PRT.intListId
			,L.strListName
			,T.intReplications
			,PP.strFormulaField AS strFormula
			,PP.strFormulaParser
			,0 AS intPropertyValidityPeriodId
			,'' AS strConditionalResult
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
		WHERE PRD.intProductId = @intProductId
			AND PC.intControlPointId = @intControlPointId
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
			,PRT.intDataTypeId
			,PRT.intDecimalPlaces
			,PRT.intListId
			,L.strListName
			,T.intReplications
			,PP.strFormulaField AS strFormula
			,PP.strFormulaParser
			,0 AS intPropertyValidityPeriodId
			,'' AS strConditionalResult
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
		WHERE PRD.intProductId = @intProductId
			AND PC.intControlPointId = @intControlPointId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo
	END
END
