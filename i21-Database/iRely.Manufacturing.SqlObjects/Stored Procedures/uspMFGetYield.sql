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
		,@intItemCategoryId INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
		,@intItemId = intItemId
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

	SELECT @strItemNo = strItemNo
		,@strDescription = strDescription
		,@strType = strType
		,@intItemCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @intCategoryId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	IF @intCategoryId IS NULL
		SELECT @intCategoryId = 0

	DECLARE @tblMFMachine TABLE (intMachineId INT)

	INSERT INTO @tblMFMachine (intMachineId)
	SELECT DISTINCT intMachineId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND ysnProductionReversed = 0

	IF @strAttributeValue = 'True'
	BEGIN
		SELECT 0 AS intProductionSummaryId
			,@intWorkOrderId AS intWorkOrderId
			,I.intItemId AS intItemId
			,I.strItemNo AS strItemNo
			,I.strDescription AS strDescription
			,I.strType AS strType
			,'Output' AS strTransactionType
			,Sum(dblOpeningQuantity + dblOpeningOutputQuantity) AS dblOpeningQuantity
			,SUM(dblInputQuantity) AS dblInputQuantity
			,SUM(dblConsumedQuantity) AS dblConsumedQuantity
			,SUM(dblOutputQuantity) AS dblOutputQuantity
			,SUM(dblCountQuantity) AS dblCountQuantity
			,SUM(dblCountOutputQuantity) AS dblCountOutputQuantity
			,SUM(dblConsumedQuantity + dblCountQuantity + dblCountOutputQuantity) - Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) AS dblYieldQuantity
			,CASE 
				WHEN Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) > 0
					THEN Round(SUM(dblOutputQuantity + dblCountQuantity + dblCountOutputQuantity) / Sum(dblOpeningQuantity + dblOpeningOutputQuantity + dblInputQuantity) * 100, 2)
				ELSE 100
				END AS dblYieldPercentage
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription AS strCategoryDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,IsNULL(M.strName, (
					SELECT STUFF((
								SELECT ', ' + M.strName
								FROM tblMFMachine M
								JOIN @tblMFMachine M1 ON M.intMachineId = M1.intMachineId
								FOR XML PATH('')
								), 1, 1, '')
					)) strMachineName
		FROM dbo.tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN tblMFMachine M ON M.intMachineId = PS.intMachineId
		WHERE PS.intWorkOrderId = @intWorkOrderId
			AND PS.intItemTypeId IN (
				2
				,4
				,5
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strDescription
			,I.strType
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,M.strName
		
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
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription AS strCategoryDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,IsNULL(M.strName, (
					SELECT STUFF((
								SELECT ', ' + M.strName
								FROM tblMFMachine M
								JOIN @tblMFMachine M1 ON M.intMachineId = M1.intMachineId
								FOR XML PATH('')
								), 1, 1, '')
					)) strMachineName
		FROM tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN tblMFMachine M ON M.intMachineId = PS.intMachineId
		WHERE PS.intWorkOrderId = @intWorkOrderId
			AND PS.intItemTypeId IN (
				1
				,3
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strDescription
			,I.strType
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,M.strName
		ORDER BY strTransactionType
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
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription AS strCategoryDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,IsNULL(M.strName, (
					SELECT STUFF((
								SELECT ', ' + M.strName
								FROM tblMFMachine M
								JOIN @tblMFMachine M1 ON M.intMachineId = M1.intMachineId
								FOR XML PATH('')
								), 1, 1, '')
					)) strMachineName
		FROM tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN tblMFMachine M ON M.intMachineId = PS.intMachineId
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemTypeId IN (
				2
				,4
				,5
				)
		GROUP BY C.intCategoryId
			,C.strCategoryCode
			,C.strDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,M.strName
		
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
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription AS strCategoryDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,IsNULL(M.strName, (
					SELECT STUFF((
								SELECT ', ' + M.strName
								FROM tblMFMachine M
								JOIN @tblMFMachine M1 ON M.intMachineId = M1.intMachineId
								FOR XML PATH('')
								), 1, 1, '')
					)) strMachineName
		FROM tblMFProductionSummary PS
		JOIN dbo.tblICItem I ON I.intItemId = PS.intItemId
		JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
		JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
			AND IU.ysnStockUnit = 1
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN tblMFMachine M ON M.intMachineId = PS.intMachineId
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemTypeId IN (
				1
				,3
				)
		GROUP BY I.intItemId
			,I.strItemNo
			,I.strDescription
			,I.strType
			,C.intCategoryId
			,C.strCategoryCode
			,C.strDescription
			,UM.strUnitMeasure
			,M.intMachineId
			,M.strName
		ORDER BY strTransactionType
	END
END
