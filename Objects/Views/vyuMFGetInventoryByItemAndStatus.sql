CREATE VIEW [dbo].[vyuMFGetInventoryByItemAndStatus]
AS
SELECT strItemNo AS strItemNo
	,strDescription AS strDescription
	,ISNULL([Active], 0) AS dblActiveQty
	,ISNULL([Quarantine], 0) AS dblQuarantineQty
	,ISNULL([On Hold], 0) AS dblOnHoldQty
	,strLocationName
	,ISNULL(dblReorderPoint, 0) AS dblReorderPoint
	,ISNULL([Active], 0) + ISNULL([Quarantine], 0) + ISNULL([On Hold], 0) AS dblOnHandQty
	,Reserve.dblReservedQty
	,Reserve.dblAvailableQty
	,PivotTable.intLocationId
	,PivotTable.intItemId
	,PivotTable.strUOM
	,strItemCategory
	,strItemType
	,strCommodityCode
	,strCommodityDescription
	,strShortName
	,strOwner
	,strSubLocationName
	,strStorageLocationName
	,PivotTable.intStorageLocationId
	,PivotTable.intSubLocationId
FROM (
	SELECT l.strItemNo
		,l.strDescription
		,l.strPrimaryStatus
		,SUM(l.dblQty) AS dblQty
		,l.intLocationId
		,l.dblReorderPoint
		,l.strLocationName
		,l.intItemId
		,l.strUOM
		,l.strItemCategory
		,l.strItemType
		,l.strCommodityCode
		,l.strCommodityDescription
		,l.strShortName
		,l.strOwner
		,l.strSubLocationName
		,l.strStorageLocationName
		,l.intStorageLocationId
		,l.intSubLocationId
	FROM (
		SELECT v.intLotId
			,v.strPrimaryStatus
			,[dbo].[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId, iu.intItemUOMId, v.dblQty) dblQty
			,v.strItemNo
			,v.strItemDescription AS strDescription
			,i.intItemId
			,il.dblReorderPoint
			,v.intLocationId
			,v.strCompanyLocationName AS strLocationName
			,um.strUnitMeasure AS strUOM
			,v.strItemCategory
			,v.strItemType
			,C.strCommodityCode
			,C.strDescription AS strCommodityDescription
			,i.strShortName
			,v.strOwner
			,v.strSubLocationName
			,v.strStorageLocationName
			,ISNULL(v.intStorageLocationId, 0) AS intStorageLocationId
			,ISNULL(v.intSubLocationId, 0) AS intSubLocationId
		FROM vyuMFInventoryView v
		JOIN tblICItem i ON v.intItemId = i.intItemId
		JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
			AND iu.ysnStockUnit = 1
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblICItemLocation il ON i.intItemId = il.intItemId
			AND v.intLocationId = il.intLocationId
		LEFT JOIN tblICCommodity C ON C.intCommodityId = i.intCommodityId
		WHERE v.dblQty > 0
			AND v.dtmExpiryDate > GETDATE()
		) l
	GROUP BY l.intLocationId
		,l.strItemNo
		,l.strDescription
		,l.strPrimaryStatus
		,l.dblReorderPoint
		,l.strLocationName
		,l.intItemId
		,l.strUOM
		,l.strItemCategory
		,l.strItemType
		,l.strCommodityCode
		,l.strCommodityDescription
		,l.strShortName
		,l.strOwner
		,l.strSubLocationName
		,l.strStorageLocationName
		,l.intStorageLocationId
		,l.intSubLocationId
	) AS SourceTable
PIVOT(MAX(dblQty) FOR strPrimaryStatus IN (
			[Active]
			,[Quarantine]
			,[On Hold]
			)) AS PivotTable
LEFT JOIN (
	SELECT l.intItemId
		,SUM(l.dblReservedQty) AS dblReservedQty
		,SUM(l.dblAvailableQty) AS dblAvailableQty
		,l.intLocationId
		,l.intStorageLocationId
		,l.intSubLocationId
	FROM (
		SELECT i.intItemId
			,[dbo].[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId, iu.intItemUOMId, v.dblReservedNoOfPacks) dblReservedQty
			,[dbo].[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId, iu.intItemUOMId, v.dblAvailableNoOfPacks) dblAvailableQty
			,v.intLocationId
			,ISNULL(v.intStorageLocationId, 0) AS intStorageLocationId
			,ISNULL(v.intSubLocationId, 0) AS intSubLocationId
		FROM vyuMFInventoryView v
		JOIN tblICItem i ON v.intItemId = i.intItemId
		JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
			AND iu.ysnStockUnit = 1
		JOIN tblICItemLocation il ON i.intItemId = il.intItemId
			AND v.intLocationId = il.intLocationId
		WHERE v.dblQty > 0
			AND v.dtmExpiryDate > GETDATE()
		) l
	GROUP BY l.intItemId
		,l.intLocationId
		,l.intStorageLocationId
		,l.intSubLocationId
	) AS Reserve ON PivotTable.intItemId = Reserve.intItemId
	AND PivotTable.intStorageLocationId = Reserve.intStorageLocationId
	AND PivotTable.intSubLocationId = Reserve.intSubLocationId
