CREATE PROCEDURE uspMFGetTraceabilityLotMergeDetail @intLotId INT
	,@intDirectionId INT
	,@ysnParentLot BIT = 0
AS
DECLARE @strLotNumber NVARCHAR(50)

SELECT @strLotNumber = strLotNumber
FROM tblICLot
WHERE intLotId = @intLotId

IF @intDirectionId = 1
BEGIN
	IF @ysnParentLot = 0
		SELECT 'Merge' AS strTransactionName
			,l.intLotId
			,l.strLotNumber
			,l.strLotAlias
			,l.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,ABS(IA.dblQty) AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,l.dtmDateCreated AS dtmTransactionDate
			,l.intParentLotId
			,'L'
			,2 AS intImageTypeId
			,'Merge ' + Ltrim(Convert(DECIMAL(24, 2), ABS(IA.dblQty))) + um.strUnitMeasure
		FROM tblICLot l
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblMFInventoryAdjustment IA ON IA.intDestinationLotId = l.intLotId
		JOIN tblICItemUOM iu ON IA.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE IA.intSourceLotId = @intLotId

	IF @ysnParentLot = 1
		SELECT 'Merge' AS strTransactionName
			,pl.intParentLotId
			,pl.strParentLotNumber
			,pl.strParentLotAlias
			,l.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,ABS(IA.dblQty) AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,l.dtmDateCreated AS dtmTransactionDate
			,l.intParentLotId
			,'L'
			,2 AS intImageTypeId
			,'Merge ' + Ltrim(Convert(DECIMAL(24, 2), ABS(IA.dblQty))) + um.strUnitMeasure
		FROM tblICLot l
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
		JOIN tblMFInventoryAdjustment IA ON IA.intDestinationLotId = l.intLotId
		JOIN tblICItemUOM iu ON IA.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE IA.intSourceLotId = @intLotId
END

IF @intDirectionId = 2
BEGIN
	IF @ysnParentLot = 0
		SELECT 'Merge' AS strTransactionName
			,l.intLotId
			,l.strLotNumber
			,l.strLotAlias
			,l.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,ABS(IA.dblQty) AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,l.dtmDateCreated AS dtmTransactionDate
			,l.intParentLotId
			,'L'
			,2 AS intImageTypeId
			,'Merge In ' + Ltrim(Convert(DECIMAL(24, 2), ABS(IA.dblQty))) + um.strUnitMeasure
		FROM tblICLot l
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblMFInventoryAdjustment IA ON IA.intSourceLotId = l.intLotId
		JOIN tblICItemUOM iu ON IA.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE IA.intDestinationLotId = @intLotId
		
		UNION
		
		SELECT 'Merge' AS strTransactionName
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
			,l.dtmDateCreated AS dtmTransactionDate
			,l.intParentLotId
			,'L'
			,2 AS intImageTypeId
			,'Merge Out ' + Ltrim(Convert(DECIMAL(24, 2), IA.dblQty)) + um.strUnitMeasure
		FROM tblICLot l
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblMFInventoryAdjustment IA ON IA.intDestinationLotId = l.intLotId
		JOIN tblICItemUOM iu ON IA.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE IA.intSourceLotId = @intLotId

	IF @ysnParentLot = 1
		SELECT 'Merge' AS strTransactionName
			,pl.intParentLotId
			,pl.strParentLotNumber
			,pl.strParentLotAlias
			,l.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,ABS(IA.dblQty) AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,l.dtmDateCreated AS dtmTransactionDate
			,l.intParentLotId
			,'L'
			,2 AS intImageTypeId
			,'Merge In' + Ltrim(Convert(DECIMAL(24, 2), ABS(IA.dblQty))) + um.strUnitMeasure
		FROM tblICLot l
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
		JOIN tblMFInventoryAdjustment IA ON IA.intSourceLotId = l.intLotId
		JOIN tblICItemUOM iu ON IA.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE IA.intDestinationLotId = @intLotId
END
