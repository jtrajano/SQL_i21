CREATE PROCEDURE uspMFGetYield (@intWorkOrderId INT)
AS
BEGIN
	DECLARE @intItemId INT
		,@strItemNo NVARCHAR(50)
		,@strDescription NVARCHAR(100)
		,@strType NVARCHAR(50)
		,@intAttributeId INT
		,@strAttributeValue NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@intLocationId INT
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intCategoryId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Display actual consumption in WM'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	SELECT @intItemId = intItemId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strItemNo = strItemNo
		,@strDescription = strDescription
		,@strType = strType
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

	SELECT @intCategoryId = intCategoryId
	FROM dbo.tblICCategory
	WHERE strCategoryCode = @strPackagingCategory

	IF @intCategoryId IS NULL
		SELECT @intCategoryId = 0

	IF @strAttributeValue = 'True'
	BEGIN
		SELECT 0 AS intProductionSummaryId
			,@intWorkOrderId AS intWorkOrderId
			,@intItemId AS intItemId
			,@strItemNo AS strItemNo
			,@strDescription AS strDescription
			,@strType AS strType
			,'Output' AS strTransactionType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblConsumedQuantity) AS dblInputQuantity
			,SUM(dblConsumedQuantity) AS dblConsumedQuantity
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
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
			AND I.intCategoryId <> @intCategoryId
		WHERE intWorkOrderId = @intWorkOrderId
		
		UNION
		
		SELECT 0 AS intProductionSummaryId
			,@intWorkOrderId AS intWorkOrderId
			,I.intItemId AS intItemId
			,I.strItemNo AS strItemNo
			,I.strDescription AS strDescription
			,I.strType AS strType
			,'Input' AS strTransactionType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblInputQuantity) AS dblInputQuantity
			,SUM(dblConsumedQuantity) AS dblConsumedQuantity
			,0 AS dblOutputQuantity
			,SUM(dblCountQuantity) AS dblCountQuantity
			,SUM(dblCountOutputQuantity) AS dblCountOutputQuantity
			,SUM(dblConsumedQuantity + dblCountQuantity + dblCountOutputQuantity) - Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) AS dblYieldQuantity
			,CASE 
				WHEN Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) > 0
					THEN Round(SUM(dblConsumedQuantity + dblCountQuantity + dblCountOutputQuantity) / Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) * 100, 2)
				ELSE 100
				END AS dblYieldPercentage
		FROM tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
			AND I.intCategoryId <> @intCategoryId
			AND I.intItemId <> @intItemId
		WHERE intWorkOrderId = @intWorkOrderId
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strDescription
			,I.strType
	END
	ELSE
	BEGIN
		SELECT 0 AS intProductionSummaryId
			,@intWorkOrderId AS intWorkOrderId
			,@intItemId AS intItemId
			,@strItemNo AS strItemNo
			,@strDescription AS strDescription
			,@strType AS strType
			,'Output' AS strTransactionType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblInputQuantity) AS dblInputQuantity
			,SUM(dblConsumedQuantity) AS dblConsumedQuantity
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
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
			AND I.intCategoryId <> @intCategoryId
		WHERE intWorkOrderId = @intWorkOrderId
		
		UNION
		
		SELECT 0 AS intProductionSummaryId
			,@intWorkOrderId AS intWorkOrderId
			,I.intItemId AS intItemId
			,I.strItemNo AS strItemNo
			,I.strDescription AS strDescription
			,I.strType AS strType
			,'Input' AS strTransactionType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblInputQuantity) AS dblInputQuantity
			,SUM(dblConsumedQuantity) AS dblConsumedQuantity
			,0 AS dblOutputQuantity
			,SUM(dblCountQuantity) AS dblCountQuantity
			,SUM(dblCountOutputQuantity) AS dblCountOutputQuantity
			,SUM(dblConsumedQuantity + dblCountQuantity + dblCountOutputQuantity) - Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) AS dblYieldQuantity
			,CASE 
				WHEN Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) > 0
					THEN Round(SUM(dblConsumedQuantity + dblCountQuantity + dblCountOutputQuantity) / Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) * 100, 2)
				ELSE 100
				END AS dblYieldPercentage
		FROM tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
			AND I.intCategoryId <> @intCategoryId
			AND I.intItemId <> @intItemId
		WHERE intWorkOrderId = @intWorkOrderId
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strDescription
			,I.strType
	END
END
