CREATE PROCEDURE [dbo].[uspMFGetRecipeItemByProduct] 
(
	@intItemId		INT
  , @intLocationId	INT
  , @intWorkOrderId INT = 0
)
AS
BEGIN

DECLARE @dtmCurrentDate				DATETIME = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))
	  , @dtmCurrentDateTime			DATETIME = GETDATE()
	  , @intDayOfYear				INT = DATEPART(dy, GETDATE())

/* Existing Record. */
IF @intWorkOrderId = 0
	BEGIN
		SELECT I.strItemNo
			 , I.strDescription
			 , ri.dblCalculatedQuantity
			 , UM.strUnitMeasure
			 , ri.strItemGroupName
			 , ri.dblUpperTolerance
			 , ri.dblLowerTolerance
			 , ri.dblCalculatedUpperTolerance
			 , ri.dblCalculatedLowerTolerance
			 , ri.dblShrinkage
			 , ri.ysnScaled
			 , CM.strName AS strConsumptionMethodName
			 , SL.strName AS strStorageLocationName
			 , ri.dtmValidFrom
			 , ri.dtmValidTo
			 , ri.ysnYearValidationRequired
			 , U.strUserName AS strCreatedUserName
			 , ri.dtmCreated
			 , U1.strUserName AS strLastModifiedUserName
			 , ri.dtmLastModified
			 , r.intVersionNo
			 , ri.ysnPartialFillConsumption
			 , CONVERT(BIT, 0) AS ysnSubstituteItem
			 , I.strItemNo AS strMainRecipeItem
			 , ri.intRecipeItemId
			 , rt.strName AS strRecipeItemType
			 , ri.intRecipeId
			 , Convert(NVARCHAR(50), 'I' + Ltrim(ROW_NUMBER() OVER (ORDER BY ri.intRecipeItemId ASC))) AS strId
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.intEntityId = ri.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.intEntityId = ri.intLastModifiedUserId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		JOIN tblMFRecipeItemType rt ON rt.intRecipeItemTypeId = ri.intRecipeItemTypeId
		WHERE r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			--AND r.ysnActive = 1
			AND (ri.intRecipeItemTypeId = 2
				OR (
					ri.intRecipeItemTypeId = 1
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
					)
				)
		
		UNION
		
		SELECT I.strItemNo
			,I.strDescription
			,ri.dblCalculatedQuantity
			,UM.strUnitMeasure
			,ri.strItemGroupName
			,ri.dblUpperTolerance
			,ri.dblLowerTolerance
			,ri.dblCalculatedUpperTolerance
			,ri.dblCalculatedLowerTolerance
			,ri.dblShrinkage
			,ri.ysnScaled
			,CM.strName AS strConsumptionMethodName
			,SL.strName AS strStorageLocationName
			,ri.dtmValidFrom
			,ri.dtmValidTo
			,ri.ysnYearValidationRequired
			,U.strUserName AS strCreatedUserName
			,ri.dtmCreated
			,U1.strUserName AS strLastModifiedUserName
			,ri.dtmLastModified
			,r.intVersionNo
			,ri.ysnPartialFillConsumption
			,CONVERT(BIT, 1) AS ysnSubstituteItem
			,I1.strItemNo AS strMainRecipeItem
			,ri.intRecipeItemId
			,rt.strName AS strRecipeItemType
			,ri.intRecipeId
			,Convert(NVARCHAR(50), 'S' + Ltrim(ROW_NUMBER() OVER (
						ORDER BY RSI.intRecipeSubstituteItemId ASC
						)))
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipeSubstituteItem RSI ON RSI.intRecipeItemId = ri.intRecipeItemId
			AND ri.intRecipeId = RSI.intRecipeId
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = RSI.intSubstituteItemId
		JOIN dbo.tblICItem I1 ON I1.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON RSI.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.intEntityId = RSI.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.intEntityId = RSI.intLastModifiedUserId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		JOIN tblMFRecipeItemType rt ON rt.intRecipeItemTypeId = ri.intRecipeItemTypeId
		WHERE r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND r.ysnActive = 1
			AND (
				ri.intRecipeItemTypeId = 2
				OR (
					ri.intRecipeItemTypeId = 1
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
					)
				)
		ORDER BY rt.strName
			,ri.intRecipeItemId
	END
ELSE
	BEGIN
		DECLARE @intManufacturingProcessId INT
			  , @intPMCategoryId		   INT
			  , @intItemUOMId			   INT
			  , @dblCalculatedQuantity	   DECIMAL(24, 10)
			  , @intUnitMeasureId		   INT

		

		SELECT @intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intPMCategoryId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 46 --Packaging Category

		SELECT @intItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		SELECT @dblCalculatedQuantity = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(RI.intItemUOMId, IU.intItemUOMId, RI.dblCalculatedQuantity))
		FROM tblMFWorkOrderRecipeItem RI
		JOIN tblICItemUOM IU ON IU.intItemId = RI.intItemId
			AND IU.intUnitMeasureId = @intUnitMeasureId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND RI.intRecipeItemTypeId = 2
			AND RI.ysnConsumptionRequired = 1
			AND RI.intItemId <> @intItemId

		IF @dblCalculatedQuantity IS NULL
			BEGIN
				SELECT @dblCalculatedQuantity = 0;
			END

		SELECT I.strItemNo
			,I.strDescription
			,(
				CASE 
					WHEN ri.ysnScaled = 1
						THEN (
								CASE 
									WHEN I.intCategoryId = @intPMCategoryId
										THEN Convert(DECIMAL(18, 2), CEILING((ri.dblCalculatedQuantity / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity))
									ELSE ri.dblCalculatedQuantity
									END
								)
					ELSE (
							CASE 
								WHEN I.intCategoryId = @intPMCategoryId
									THEN Convert(DECIMAL(18, 2), CEILING(ri.dblCalculatedQuantity))
								ELSE ri.dblCalculatedQuantity
								END
							)
					END
				) AS dblCalculatedQuantity
			,UM.strUnitMeasure
			,ri.strItemGroupName
			,ri.dblUpperTolerance
			,ri.dblLowerTolerance
			,(
				CASE 
					WHEN ri.ysnScaled = 1
						THEN (
								CASE 
									WHEN I.intCategoryId <> @intPMCategoryId
										THEN (ri.dblCalculatedUpperTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity
									ELSE Convert(DECIMAL(18, 2), CEILING((ri.dblCalculatedUpperTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity))
									END
								)
					ELSE (
							CASE 
								WHEN I.intCategoryId = @intPMCategoryId
									THEN Convert(DECIMAL(18, 2), CEILING(ri.dblCalculatedUpperTolerance))
								ELSE ri.dblCalculatedUpperTolerance
								END
							)
					END
				) AS dblCalculatedUpperTolerance
			,(
				CASE 
					WHEN ri.ysnScaled = 1
						THEN (
								CASE 
									WHEN I.intCategoryId <> @intPMCategoryId
										THEN (ri.dblCalculatedLowerTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity
									ELSE Convert(DECIMAL(18, 2), CEILING((ri.dblCalculatedLowerTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity))
									END
								)
					ELSE (
							CASE 
								WHEN I.intCategoryId = @intPMCategoryId
									THEN Convert(DECIMAL(18, 2), CEILING(ri.dblCalculatedLowerTolerance))
								ELSE ri.dblCalculatedLowerTolerance
								END
							)
					END
				) AS dblCalculatedLowerTolerance
			,ri.dblShrinkage
			,ri.ysnScaled
			,CM.strName AS strConsumptionMethodName
			,SL.strName AS strStorageLocationName
			,ri.dtmValidFrom
			,ri.dtmValidTo
			,ri.ysnYearValidationRequired
			,U.strUserName AS strCreatedUserName
			,ri.dtmCreated
			,U1.strUserName AS strLastModifiedUserName
			,ri.dtmLastModified
			,r.intVersionNo
			,ri.ysnPartialFillConsumption
			,CONVERT(BIT, 0) AS ysnSubstituteItem
			,I.strItemNo AS strMainRecipeItem
			,ri.intRecipeItemId
			,rt.strName AS strRecipeItemType
			,ri.intRecipeId
			,Convert(NVARCHAR(50), 'I' + Ltrim(ROW_NUMBER() OVER (
						ORDER BY ri.intRecipeItemId ASC
						))) AS strId
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.intEntityId = ri.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.intEntityId = ri.intLastModifiedUserId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = r.intWorkOrderId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		JOIN tblMFRecipeItemType rt ON rt.intRecipeItemTypeId = ri.intRecipeItemTypeId
		WHERE r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND r.ysnActive = 1
			AND (
				ri.intRecipeItemTypeId = 2
				OR (
					ri.intRecipeItemTypeId = 1
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
					)
				)
			AND r.intWorkOrderId = @intWorkOrderId
		
		UNION
		
		SELECT I.strItemNo
			,I.strDescription
			,(
				CASE 
					WHEN ri.ysnScaled = 1
						THEN (
								CASE 
									WHEN I.intCategoryId = @intPMCategoryId
										THEN Convert(DECIMAL(18, 2), CEILING((ri.dblCalculatedQuantity / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity))
									ELSE (ri.dblCalculatedQuantity / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity
									END
								)
					ELSE (
							CASE 
								WHEN I.intCategoryId = @intPMCategoryId
									THEN Convert(DECIMAL(18, 2), CEILING(ri.dblCalculatedQuantity))
								ELSE ri.dblCalculatedQuantity
								END
							)
					END
				) AS dblCalculatedQuantity
			,UM.strUnitMeasure
			,ri.strItemGroupName
			,ri.dblUpperTolerance
			,ri.dblLowerTolerance
			,(
				CASE 
					WHEN ri.ysnScaled = 1
						THEN (
								CASE 
									WHEN I.intCategoryId <> @intPMCategoryId
										THEN (ri.dblCalculatedUpperTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity
									ELSE Convert(DECIMAL(18, 2), CEILING((ri.dblCalculatedUpperTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity))
									END
								)
					ELSE (
							CASE 
								WHEN I.intCategoryId = @intPMCategoryId
									THEN Convert(DECIMAL(18, 2), CEILING(ri.dblCalculatedUpperTolerance))
								ELSE ri.dblCalculatedUpperTolerance
								END
							)
					END
				) AS dblCalculatedUpperTolerance
			,(
				CASE 
					WHEN ri.ysnScaled = 1
						THEN (
								CASE 
									WHEN I.intCategoryId <> @intPMCategoryId
										THEN (ri.dblCalculatedLowerTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity
									ELSE Convert(DECIMAL(18, 2), CEILING((ri.dblCalculatedLowerTolerance / (r.dblQuantity - @dblCalculatedQuantity)) * W.dblQuantity))
									END
								)
					ELSE (
							CASE 
								WHEN I.intCategoryId = @intPMCategoryId
									THEN Convert(DECIMAL(18, 2), CEILING(ri.dblCalculatedLowerTolerance))
								ELSE ri.dblCalculatedLowerTolerance
								END
							)
					END
				) AS dblCalculatedLowerTolerance
			,ri.dblShrinkage
			,ri.ysnScaled
			,CM.strName AS strConsumptionMethodName
			,SL.strName AS strStorageLocationName
			,ri.dtmValidFrom
			,ri.dtmValidTo
			,ri.ysnYearValidationRequired
			,U.strUserName AS strCreatedUserName
			,ri.dtmCreated
			,U1.strUserName AS strLastModifiedUserName
			,ri.dtmLastModified
			,r.intVersionNo
			,ri.ysnPartialFillConsumption
			,CONVERT(BIT, 1) AS ysnSubstituteItem
			,I1.strItemNo AS strMainRecipeItem
			,ri.intRecipeItemId
			,rt.strName AS strRecipeItemType
			,ri.intRecipeId
			,Convert(NVARCHAR(50), 'S' + Ltrim(ROW_NUMBER() OVER (
						ORDER BY RSI.intRecipeSubstituteItemId ASC
						)))
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intRecipeItemId = ri.intRecipeItemId
			AND ri.intWorkOrderId = RSI.intWorkOrderId
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = RSI.intSubstituteItemId
		JOIN dbo.tblICItem I1 ON I1.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON RSI.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.intEntityId = RSI.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.intEntityId = RSI.intLastModifiedUserId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = r.intWorkOrderId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		JOIN tblMFRecipeItemType rt ON rt.intRecipeItemTypeId = ri.intRecipeItemTypeId
		WHERE r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND r.ysnActive = 1
			AND (
				ri.intRecipeItemTypeId = 2
				OR (
					ri.intRecipeItemTypeId = 1
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
					)
				)
			AND r.intWorkOrderId = @intWorkOrderId
		ORDER BY rt.strName
			,ri.intRecipeItemId
	END
END