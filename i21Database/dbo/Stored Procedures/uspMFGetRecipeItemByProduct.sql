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
		,@intManufacturingProcessId int,@strPackagingCategory nvarchar(50),@intPMCategoryId int
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
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.[intEntityId] = ri.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.[intEntityId] = ri.intLastModifiedUserId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		WHERE r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND r.ysnActive = 1
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
		ORDER BY ri.intRecipeItemId
	END
	ELSE
	BEGIN
	
		Select @intManufacturingProcessId=intManufacturingProcessId
		from tblMFWorkOrder
		Where intWorkOrderId =@intWorkOrderId 

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 46--Packaging Category

	SELECT @intPMCategoryId = intCategoryId
	FROM tblICCategory
	WHERE strCategoryCode = @strPackagingCategory

		SELECT I.strItemNo
			,I.strDescription
			,Case When I.intCategoryId =@intPMCategoryId then CEILING((ri.dblCalculatedQuantity / r.dblQuantity) * W.dblQuantity)
			else (ri.dblCalculatedQuantity / r.dblQuantity) * W.dblQuantity End AS dblCalculatedQuantity
			,UM.strUnitMeasure
			,ri.strItemGroupName
			,ri.dblUpperTolerance
			,ri.dblLowerTolerance
			,Case When I.intCategoryId =@intPMCategoryId then (ri.dblCalculatedUpperTolerance / r.dblQuantity) * W.dblQuantity Else  CEILING((ri.dblCalculatedUpperTolerance / r.dblQuantity) * W.dblQuantity) End AS dblCalculatedUpperTolerance
			,Case When I.intCategoryId =@intPMCategoryId then (ri.dblCalculatedLowerTolerance / r.dblQuantity) * W.dblQuantity Else CEILING((ri.dblCalculatedLowerTolerance / r.dblQuantity) * W.dblQuantity) End AS dblCalculatedLowerTolerance
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
		FROM dbo.tblMFWorkOrderRecipeItem ri
		JOIN dbo.tblMFWorkOrderRecipe r ON r.intRecipeId = ri.intRecipeId
			AND r.intWorkOrderId = ri.intWorkOrderId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN tblICItemUOM iu ON ri.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure UM ON iu.intUnitMeasureId = UM.intUnitMeasureId
		JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
		JOIN dbo.tblSMUserSecurity U ON U.[intEntityId] = ri.intCreatedUserId
		JOIN dbo.tblSMUserSecurity U1 ON U1.[intEntityId] = ri.intLastModifiedUserId
		JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = r.intWorkOrderId
		LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = ri.intStorageLocationId
		WHERE r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND r.ysnActive = 1
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
			AND r.intWorkOrderId = @intWorkOrderId
		ORDER BY ri.intRecipeItemId
	END
END
GO


