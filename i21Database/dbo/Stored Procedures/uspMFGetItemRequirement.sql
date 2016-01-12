CREATE PROCEDURE dbo.uspMFGetItemRequirement @dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@strManufacturingCellId NVARCHAR(MAX)
	,@intLocationId INT
AS
BEGIN
	SELECT W.strSalesOrderNo
		,W.strCustomerOrderNo
		,E.strName AS strCustomerName
		,'' AS strAdditive
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,SUM(SWD.dblPlannedQty) dblPlannedQty
		,UM.strUnitMeasure
		,W.dtmExpectedDate
		,W.dtmEarliestDate
		,W.dtmLatestDate
		,SW.dtmPlannedStartDate
		,SW.dtmPlannedEndDate
	FROM dbo.tblMFSchedule S
	JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intScheduleId = S.intScheduleId
		AND S.ysnStandard = 1
		AND S.intLocationId = @intLocationId
	JOIN dbo.tblMFScheduleWorkOrderDetail SWD ON SWD.intScheduleWorkOrderId = SW.intScheduleWorkOrderId
	JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = SW.intWorkOrderId
	JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblARCustomer C ON C.intEntityCustomerId = W.intCustomerId
	JOIN dbo.tblEntity E ON E.intEntityId = C.intEntityCustomerId
	JOIN dbo.tblEntityType ET ON ET.intEntityId = E.intEntityId
		AND ET.strType = 'Customer'
	WHERE SW.dtmPlannedStartDate >= @dtmStartDate
		AND SW.dtmPlannedEndDate <= @dtmEndDate
		AND W.intManufacturingCellId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strManufacturingCellId, ',')
			)
	GROUP BY W.strSalesOrderNo
		,W.strCustomerOrderNo
		,E.strName
		,I.strItemNo
		,I.strShortName
		,I.strDescription
		,UM.strUnitMeasure
		,W.dtmExpectedDate
		,W.dtmEarliestDate
		,W.dtmLatestDate
		,SW.dtmPlannedStartDate
		,SW.dtmPlannedEndDate
	ORDER BY W.strSalesOrderNo

	SELECT I.strItemNo
		,I.strShortName
		,I.strDescription
		,SUM(SWD.dblPlannedQty * RI.dblCalculatedQuantity / R.dblQuantity) dblPlannedQty
		,UM.strUnitMeasure
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
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE SW.dtmPlannedStartDate >= @dtmStartDate
		AND SW.dtmPlannedEndDate <= @dtmEndDate
		AND W.intManufacturingCellId IN (
			SELECT Item
			FROM dbo.fnSplitString(@strManufacturingCellId, ',')
			)
	GROUP BY I.strItemNo
		,I.strShortName
		,I.strDescription
		,UM.strUnitMeasure
	ORDER BY I.strItemNo
END
