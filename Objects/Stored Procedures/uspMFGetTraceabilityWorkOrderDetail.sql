CREATE PROCEDURE [dbo].[uspMFGetTraceabilityWorkOrderDetail] @intLotId INT
	,@intDirectionId INT
	,@ysnParentLot BIT = 0
AS
SET NOCOUNT ON;

DECLARE @strLotNumber NVARCHAR(50)

SELECT @strLotNumber = strLotNumber
FROM tblICLot
WHERE intLotId = @intLotId

IF @intDirectionId = 1
BEGIN
	IF @ysnParentLot = 0
		SELECT 'Consume' AS strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,SUM(t.dblQuantity) AS dblQuantity
			,MAX(t.strUOM) AS strUOM
			,MAX(t.dtmTransactionDate) AS dtmTransactionDate
			,t.strProcessName
			,'W' AS strType
			,t.intAttributeTypeId
			,''
			,dblWOQty
		FROM (
			SELECT DISTINCT 'Consume' AS strTransactionName
				,wi.intLotId
				,w.intWorkOrderId
				,w.strWorkOrderNo
				,i.intItemId
				,i.strItemNo
				,i.strDescription
				,mt.intCategoryId
				,mt.strCategoryCode
				,w.dblQuantity
				,um.strUnitMeasure AS strUOM
				,wi.dtmCreated AS dtmTransactionDate
				,ps.strProcessName
				,ps.intAttributeTypeId
				,w.dblQuantity AS dblWOQty
			FROM tblMFWorkOrder w
			JOIN tblMFWorkOrderConsumedLot wi ON w.intWorkOrderId = wi.intWorkOrderId
			JOIN tblMFManufacturingProcess ps ON ps.intManufacturingProcessId = w.intManufacturingProcessId
			JOIN tblICItem i ON w.intItemId = i.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
			JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
			JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
			WHERE wi.intLotId IN (
					SELECT intLotId
					FROM tblICLot
					WHERE strLotNumber = @strLotNumber
					)
			) t
		GROUP BY t.strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,t.intLotId
			,t.strProcessName
			,t.intAttributeTypeId
			,t.dblWOQty

	IF @ysnParentLot = 1
		SELECT 'Consume' AS strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,SUM(t.dblQuantity) AS dblQuantity
			,MAX(t.strUOM) AS strUOM
			,MAX(t.dtmTransactionDate) AS dtmTransactionDate
			,t.strProcessName
			,'W' AS strType
			,t.intAttributeTypeId
			,''
			,dblWOQty
		FROM (
			SELECT DISTINCT 'Consume' AS strTransactionName
				,l.intParentLotId AS intLotId
				,w.intWorkOrderId
				,w.strWorkOrderNo
				,i.intItemId
				,i.strItemNo
				,i.strDescription
				,mt.intCategoryId
				,mt.strCategoryCode
				,w.dblQuantity
				,um.strUnitMeasure AS strUOM
				,wi.dtmCreated AS dtmTransactionDate
				,ps.strProcessName
				,ps.intAttributeTypeId
				,w.dblQuantity AS dblWOQty
			FROM tblMFWorkOrder w
			JOIN tblMFWorkOrderConsumedLot wi ON w.intWorkOrderId = wi.intWorkOrderId
			JOIN tblMFManufacturingProcess ps ON ps.intManufacturingProcessId = w.intManufacturingProcessId
			JOIN tblICItem i ON w.intItemId = i.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
			JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
			JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
			JOIN tblICLot l ON wi.intLotId = l.intLotId
			WHERE l.intParentLotId = @intLotId
			) t
		GROUP BY t.strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,t.intLotId
			,t.strProcessName
			,t.intAttributeTypeId
			,t.dblWOQty
END
ELSE
BEGIN
	IF @ysnParentLot = 0
		SELECT 'Produce' AS strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,SUM(t.dblQuantity) AS dblQuantity
			,MAX(t.strUOM) AS strUOM
			,MAX(t.dtmTransactionDate) AS dtmTransactionDate
			,t.strProcessName
			,'W' AS strType
			,t.intAttributeTypeId
			,'Produce ' + Ltrim(Convert(DECIMAL(24, 2), SUM(t.dblQuantity))) + Ltrim(MAX(t.strProducedUnitMeasure))
			,dblWOQty
		FROM (
			SELECT DISTINCT 'Produce' AS strTransactionName
				,wi.intLotId
				,w.intWorkOrderId
				,w.strWorkOrderNo
				,i.intItemId
				,i.strItemNo
				,i.strDescription
				,mt.intCategoryId
				,mt.strCategoryCode
				,wi.dblQuantity
				,um.strUnitMeasure AS strUOM
				,wi.dtmCreated AS dtmTransactionDate
				,ps.strProcessName
				,ps.intAttributeTypeId
				,w.dblQuantity AS dblWOQty
				,um1.strUnitMeasure as strProducedUnitMeasure
			FROM tblMFWorkOrder w
			JOIN tblMFWorkOrderProducedLot wi ON w.intWorkOrderId = wi.intWorkOrderId
			JOIN tblMFManufacturingProcess ps ON ps.intManufacturingProcessId = w.intManufacturingProcessId
			JOIN tblICItem i ON w.intItemId = i.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
			JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
			JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
						JOIN tblICItemUOM iu1 ON wi.intItemUOMId = iu1.intItemUOMId
			JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
			WHERE wi.intLotId IN (
					SELECT intLotId
					FROM tblICLot
					WHERE strLotNumber = @strLotNumber
					)
				AND ISNULL(wi.ysnProductionReversed, 0) = 0
			) t
		GROUP BY t.strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,t.intLotId
			,t.strProcessName
			,t.intAttributeTypeId
			,t.dblWOQty

	IF @ysnParentLot = 1
		SELECT 'Produce' AS strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,SUM(t.dblQuantity) AS dblQuantity
			,MAX(t.strUOM) AS strUOM
			,MAX(t.dtmTransactionDate) AS dtmTransactionDate
			,t.strProcessName
			,'W' AS strType
			,t.intAttributeTypeId
			,'Produce ' + Ltrim(Convert(DECIMAL(24, 2), SUM(t.dblQuantity))) + Ltrim(MAX(t.strProducedUnitMeasure))
			,dblWOQty
		FROM (
			SELECT DISTINCT 'Produce' AS strTransactionName
				,l.intParentLotId AS intLotId
				,w.intWorkOrderId
				,w.strWorkOrderNo
				,i.intItemId
				,i.strItemNo
				,i.strDescription
				,mt.intCategoryId
				,mt.strCategoryCode
				,w.dblQuantity
				,um.strUnitMeasure AS strUOM
				,wi.dtmCreated AS dtmTransactionDate
				,ps.strProcessName
				,ps.intAttributeTypeId
				,w.dblQuantity AS dblWOQty
				,um1.strUnitMeasure as strProducedUnitMeasure
			FROM tblMFWorkOrder w
			JOIN tblMFWorkOrderProducedLot wi ON w.intWorkOrderId = wi.intWorkOrderId
			JOIN tblMFManufacturingProcess ps ON ps.intManufacturingProcessId = w.intManufacturingProcessId
			JOIN tblICItem i ON w.intItemId = i.intItemId
			JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
			JOIN tblICItemUOM iu ON w.intItemUOMId = iu.intItemUOMId
			JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
			JOIN tblICItemUOM iu1 ON wi.intItemUOMId = iu1.intItemUOMId
			JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
			JOIN tblICLot l ON wi.intLotId = l.intLotId
			WHERE l.intParentLotId = @intLotId
				AND ISNULL(wi.ysnProductionReversed, 0) = 0
			) t
		GROUP BY t.strTransactionName
			,t.intWorkOrderId
			,t.strWorkOrderNo
			,t.intItemId
			,t.strItemNo
			,t.strDescription
			,t.intCategoryId
			,t.strCategoryCode
			,t.intLotId
			,t.strProcessName
			,t.intAttributeTypeId
			,t.dblWOQty
END
