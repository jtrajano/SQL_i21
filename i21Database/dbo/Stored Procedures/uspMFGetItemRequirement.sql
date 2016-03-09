﻿CREATE PROCEDURE dbo.uspMFGetItemRequirement @dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@strManufacturingCellId NVARCHAR(MAX)
	,@intLocationId INT
AS
BEGIN
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
		,SUM(SWD.dblPlannedQty) dblPlannedQty
		,UM.intUnitMeasureId 
		,UM.strUnitMeasure
		,W.dtmExpectedDate
		,W.dtmEarliestDate
		,W.dtmLatestDate
		,SW.dtmPlannedStartDate
		,SW.dtmPlannedEndDate
		,0 as intConcurrencyId
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
		AND S.ysnStandard = 1
		AND S.intLocationId = @intLocationId
	JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN dbo.tblARCustomer C ON C.intEntityCustomerId = W.intCustomerId
	LEFT JOIN dbo.tblEntity E ON E.intEntityId = C.intEntityCustomerId
	LEFT JOIN dbo.tblEntityType ET ON ET.intEntityId = E.intEntityId
		AND ET.strType = 'Customer'
	WHERE ((SW.dtmPlannedStartDate >= @dtmStartDate
		AND SW.dtmPlannedEndDate <= @dtmEndDate)
		OR (@dtmStartDate BETWEEN SW.dtmPlannedStartDate AND SW.dtmPlannedEndDate OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate AND SW.dtmPlannedEndDate))
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

	SELECT Distinct
		I.intItemId 
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,SUM(SWD.dblPlannedQty * RI.dblCalculatedQuantity / R.dblQuantity) dblPlannedQty
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
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = RI.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE(( SW.dtmPlannedStartDate >= @dtmStartDate
		AND SW.dtmPlannedEndDate <= @dtmEndDate)
		OR (@dtmStartDate BETWEEN SW.dtmPlannedStartDate AND SW.dtmPlannedEndDate OR @dtmEndDate BETWEEN SW.dtmPlannedStartDate AND SW.dtmPlannedEndDate))
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
