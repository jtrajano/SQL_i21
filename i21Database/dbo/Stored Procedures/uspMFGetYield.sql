CREATE PROCEDURE uspMFGetYield (@intWorkOrderId INT)
AS
BEGIN
	DECLARE @intItemId INT
		,@strItemNo NVARCHAR(50)
		,@strDescription NVARCHAR(100)
		,@strType nvarchar(50)
		,@intAttributeId int
		,@strAttributeValue nvarchar(50)
		,@intManufacturingProcessId int
		,@intLocationId int
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intCategoryId int

	Select @intManufacturingProcessId=intManufacturingProcessId, @intLocationId=intLocationId From dbo.tblMFWorkOrder Where intWorkOrderId =@intWorkOrderId 

	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Display actual consumption in WM'

	Select @strAttributeValue=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId
	SELECT @intItemId = intItemId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strItemNo = strItemNo
		,@strDescription = strDescription
		,@strType=strType
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	SELECT @intCategoryId=intCategoryId FROM dbo.tblICCategory WHERE strCategoryCode =@strPackagingCategory

	IF @intCategoryId IS NULL
	SELECT @intCategoryId=0
	
	IF @strAttributeValue='True'
	BEGIN
		SELECT 0 as intProductionSummaryId,@intWorkOrderId AS intWorkOrderId
			,@intItemId AS intItemId
			,@strItemNo AS strItemNo
			,@strDescription AS strDescription
			,@strType as strType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblConsumedQuantity) AS dblInputQuantity
			,SUM(dblOutputQuantity) AS dblOutputQuantity
			,SUM(dblCountQuantity) AS dblCountQuantity
			,SUM(dblCountOutputQuantity) AS dblCountOutputQuantity
			,SUM(dblOutputQuantity + dblCountQuantity + dblCountOutputQuantity) - Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblConsumedQuantity) AS dblYieldQuantity
			,CASE 
				WHEN Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblConsumedQuantity) > 0
					THEN Round(SUM(dblOutputQuantity + dblCountQuantity + dblCountOutputQuantity) / Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblConsumedQuantity) * 100, 2)
				ELSE 100
				END AS dblYieldPercentage
		FROM dbo.tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId=PS.intItemId AND I.intCategoryId <> @intCategoryId
		WHERE intWorkOrderId = @intWorkOrderId
	END
	ELSE
	BEGIN
		SELECT 0 as intProductionSummaryId,@intWorkOrderId AS intWorkOrderId
			,@intItemId AS intItemId
			,@strItemNo AS strItemNo
			,@strDescription AS strDescription
			,@strType as strType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblInputQuantity) AS dblInputQuantity
			,SUM(dblOutputQuantity) AS dblOutputQuantity
			,SUM(dblCountQuantity) AS dblCountQuantity
			,SUM(dblCountOutputQuantity) AS dblCountOutputQuantity
			,SUM(dblOutputQuantity + dblCountQuantity + dblCountOutputQuantity) - Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) AS dblYieldQuantity
			,CASE 
				WHEN Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) > 0
					THEN Round(SUM(dblOutputQuantity + dblCountQuantity + dblCountOutputQuantity) / Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) * 100, 2)
				ELSE 100
				END AS dblYieldPercentage
		FROM tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId=PS.intItemId AND I.intCategoryId <> @intCategoryId
		WHERE intWorkOrderId = @intWorkOrderId
	END
END

