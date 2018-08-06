CREATE PROC uspMFGetRecipeItemByProduct (
	@intItemId INT
	,@intLocationId INT
	,@intWorkOrderId INT = 0
	)
AS
BEGIN
	--To get all the input item for the selected workorder
	DECLARE @dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@intManufacturingProcessId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intPMCategoryId INT
		,@dblCalculatedQuantity decimal(24,10)
		,@intItemUOMId int
		,@intUnitMeasureId int

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	IF @intWorkOrderId = 0
	BEGIN
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
			,CONVERT(BIT, 0) AS ysnSubstituteItem
			,I.strItemNo AS strMainRecipeItem
			,ri.intRecipeItemId
			,rt.strName as strRecipeItemType
			,ri.intRecipeId
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.intEntityId = ri.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.intEntityId = ri.intLastModifiedUserId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		JOIN tblMFRecipeItemType rt on rt.intRecipeItemTypeId =ri.intRecipeItemTypeId
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
			,rt.strName as strRecipeItemType
			,ri.intRecipeId
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
		JOIN tblMFRecipeItemType rt on rt.intRecipeItemTypeId =ri.intRecipeItemTypeId
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
		ORDER BY rt.strName,ri.intRecipeItemId
	END
	ELSE
	BEGIN
		SELECT @intManufacturingProcessId = intManufacturingProcessId
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intPMCategoryId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 46 --Packaging Category

		Select @intItemUOMId=intItemUOMId 
		from tblMFWorkOrderRecipe
		Where intWorkOrderId =@intWorkOrderId

		Select @intUnitMeasureId=intUnitMeasureId 
		From tblICItemUOM 
		Where intItemUOMId=@intItemUOMId 

		Select @dblCalculatedQuantity=SUM(dbo.fnMFConvertQuantityToTargetItemUOM(RI.intItemUOMId ,IU.intItemUOMId,RI.dblCalculatedQuantity))
		from tblMFWorkOrderRecipeItem RI
		JOIN tblICItemUOM IU on IU.intItemId=RI.intItemId and IU.intUnitMeasureId=@intUnitMeasureId 
		Where RI.intWorkOrderId =@intWorkOrderId and RI.intRecipeItemTypeId =2 and RI.ysnConsumptionRequired =1 and RI.intItemId <>@intItemId 

		If @dblCalculatedQuantity is null
		Begin
			Select @dblCalculatedQuantity=0
		End

		SELECT I.strItemNo
			,I.strDescription
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					THEN CEILING((ri.dblCalculatedQuantity / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity)
				ELSE (ri.dblCalculatedQuantity / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity
				END AS dblCalculatedQuantity
			,UM.strUnitMeasure
			,ri.strItemGroupName
			,ri.dblUpperTolerance
			,ri.dblLowerTolerance
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					THEN (ri.dblCalculatedUpperTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity
				ELSE CEILING((ri.dblCalculatedUpperTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity)
				END AS dblCalculatedUpperTolerance
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					THEN (ri.dblCalculatedLowerTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity
				ELSE CEILING((ri.dblCalculatedLowerTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity)
				END AS dblCalculatedLowerTolerance
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
			,rt.strName as strRecipeItemType
			,ri.intRecipeId
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
		JOIN tblMFRecipeItemType rt on rt.intRecipeItemTypeId =ri.intRecipeItemTypeId
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
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					THEN CEILING((ri.dblCalculatedQuantity / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity)
				ELSE (ri.dblCalculatedQuantity / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity
				END AS dblCalculatedQuantity
			,UM.strUnitMeasure
			,ri.strItemGroupName
			,ri.dblUpperTolerance
			,ri.dblLowerTolerance
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					THEN (ri.dblCalculatedUpperTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity
				ELSE CEILING((ri.dblCalculatedUpperTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity)
				END AS dblCalculatedUpperTolerance
			,CASE 
				WHEN I.intCategoryId = @intPMCategoryId
					THEN (ri.dblCalculatedLowerTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity
				ELSE CEILING((ri.dblCalculatedLowerTolerance / (r.dblQuantity-@dblCalculatedQuantity)) * W.dblQuantity)
				END AS dblCalculatedLowerTolerance
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
			,rt.strName as strRecipeItemType
			,ri.intRecipeId
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
		JOIN tblMFRecipeItemType rt on rt.intRecipeItemTypeId =ri.intRecipeItemTypeId
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
		ORDER BY rt.strName,ri.intRecipeItemId
	END
END
