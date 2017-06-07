CREATE PROCEDURE dbo.uspMFGetItemRequirement @dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@strManufacturingCellId NVARCHAR(MAX)
	,@intLocationId INT
AS
BEGIN
	SELECT @dtmStartDate = convert(DATETIME, Convert(CHAR, @dtmStartDate, 101))

	SELECT @dtmEndDate = convert(DATETIME, Convert(CHAR, @dtmEndDate, 101)) + 1

	SELECT W.intWorkOrderId
		,W.strWorkOrderNo
		,W.strSalesOrderNo
		,W.strCustomerOrderNo
		,E.strName AS strCustomerName
		,'' AS strAdditive
		,I.intItemId
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,ROUND(SUM(SWD.dblPlannedQty), 0) dblPlannedQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,W.dtmExpectedDate
		,W.dtmEarliestDate
		,W.dtmLatestDate
		,SW.dtmPlannedStartDate
		,SW.dtmPlannedEndDate
		,0 AS intConcurrencyId
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
		AND S.ysnStandard = 1
		AND S.intLocationId = @intLocationId
	JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN dbo.tblARCustomer C ON C.[intEntityId] = W.intCustomerId
	LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = C.[intEntityId]
	LEFT JOIN dbo.[tblEMEntityType] ET ON ET.intEntityId = E.intEntityId
		AND ET.strType = 'Customer'
	WHERE (
			(
				SW.dtmPlannedStartDate >= @dtmStartDate
				AND SW.dtmPlannedEndDate <= @dtmEndDate
				)
			OR (
				@dtmStartDate BETWEEN SW.dtmPlannedStartDate
					AND SW.dtmPlannedEndDate
				OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate
					AND SW.dtmPlannedEndDate
				)
			)
		AND W.intManufacturingCellId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strManufacturingCellId, ',')
			)
	GROUP BY W.intWorkOrderId
		,W.strWorkOrderNo
		,W.strSalesOrderNo
		,W.strCustomerOrderNo
		,E.strName
		,I.intItemId
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,W.dtmExpectedDate
		,W.dtmEarliestDate
		,W.dtmLatestDate
		,SW.dtmPlannedStartDate
		,SW.dtmPlannedEndDate
	ORDER BY W.strSalesOrderNo

	SELECT DISTINCT I.intItemId
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,Round(SUM(SWD.dblPlannedQty * RI.dblCalculatedQuantity / R.dblQuantity), 0) AS dblPlannedQty
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,0 AS intConcurrencyId
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
		AND S.ysnStandard = 1
		AND S.intLocationId = @intLocationId
	JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
	JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
		AND R.intLocationId = @intLocationId
		AND R.ysnActive = 1
	JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
		AND RI.intRecipeItemTypeId = 1
	JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		AND I.strType <> 'Other Charge'
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE (
			(
				SW.dtmPlannedStartDate >= @dtmStartDate
				AND SW.dtmPlannedEndDate <= @dtmEndDate
				)
			OR (
				@dtmStartDate BETWEEN SW.dtmPlannedStartDate
					AND SW.dtmPlannedEndDate
				OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate
					AND SW.dtmPlannedEndDate
				)
			)
		AND W.intManufacturingCellId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strManufacturingCellId, ',')
			)
	GROUP BY I.intItemId
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
	ORDER BY I.strItemNo
END
