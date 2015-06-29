CREATE PROC uspMFGetRecipeItemByProduct (
	@intItemId INT
	,@intLocationId INT
	)
AS
BEGIN
	--To get all the input item for the selected workorder
	DECLARE @dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

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
	FROM dbo.tblMFRecipeItem ri
	JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = ri.intUOMId
	JOIN dbo.tblMFConsumptionMethod CM ON CM.intConsumptionMethodId = ri.intConsumptionMethodId
	JOIN dbo.tblSMUserSecurity U ON U.intUserSecurityID = ri.intCreatedUserId
	JOIN dbo.tblSMUserSecurity U1 ON U1.intUserSecurityID = ri.intLastModifiedUserId
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
END
GO


