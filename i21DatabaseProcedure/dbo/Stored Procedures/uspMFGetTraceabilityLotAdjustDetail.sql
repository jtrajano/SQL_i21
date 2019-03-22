CREATE PROCEDURE uspMFGetTraceabilityLotAdjustDetail @intLotId INT
	,@intDirectionId INT
	,@ysnParentLot BIT = 0
	,@ysnDetail BIT = 0
AS
BEGIN
	SELECT 'Qty Adjust' AS strTransactionName
		,l.intLotId
		,l.strLotNumber
		,l.strLotAlias
		,l.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,IA.dblQty AS dblQuantity
		,um.strUnitMeasure AS strUOM
		,IA.dtmDate AS dtmTransactionDate
		,l.intParentLotId
		,'LA'
		,2 AS intImageTypeId
		,'Qty Adjust ' + Ltrim(Convert(DECIMAL(24, 2), IA.dblQty)) + um.strUnitMeasure
	FROM tblICLot l
	JOIN tblICItem i ON l.intItemId = i.intItemId
	JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
	JOIN tblMFInventoryAdjustment IA ON IA.intSourceLotId = l.intLotId
		AND IA.intTransactionTypeId = 10
	JOIN tblICItemUOM iu ON IA.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	WHERE IA.intSourceLotId = @intLotId
END
