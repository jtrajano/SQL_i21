CREATE VIEW [dbo].[vyuMFGetInventoryByItemAndStatus]
	AS 
SELECT 
strItemNo AS strItemNo,
strDescription AS strDescription,
ISNULL([Active],0) AS dblActiveQty, 
ISNULL([Quarantine],0) AS dblQuarantineQty,
ISNULL([On Hold],0) AS dblOnHoldQty,
strLocationName,
ISNULL(dblReorderPoint,0) AS dblReorderPoint,
ISNULL([Active],0) + ISNULL([Quarantine],0) + ISNULL([On Hold],0) AS dblOnHandQty,
Reserve.dblReservedQty,
Reserve.dblAvailableQty,
intLocationId,
PivotTable.intItemId,
PivotTable.strUOM
FROM
(
	SELECT 
	l.strItemNo,
	l.strDescription,
	l.strPrimaryStatus,
	SUM(l.dblQty) AS dblQty,
	l.intLocationId,
	l.dblReorderPoint,
	l.strLocationName,
	l.intItemId,
	l.strUOM
	From
	(
	Select 
	v.intLotId,
	v.strPrimaryStatus,
	[dbo].[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId,iu.intItemUOMId,v.dblQty) dblQty,
	v.strItemNo,
	v.strItemDescription AS strDescription,
	i.intItemId,
	il.dblReorderPoint,
	v.intLocationId,
	v.strCompanyLocationName AS strLocationName,
	um.strUnitMeasure AS strUOM
	FROM vyuMFInventoryView v 
	Join tblICItem i on v.intItemId=i.intItemId
	Join tblICItemUOM iu on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemLocation il on i.intItemId=il.intItemId AND v.intLocationId=il.intLocationId
	Where v.dblQty>0 AND v.dtmExpiryDate>GETDATE()
	) l
	Group By l.intLocationId,l.strItemNo,l.strDescription,l.strPrimaryStatus,l.dblReorderPoint,l.strLocationName,l.intItemId,l.strUOM
) AS SourceTable  
PIVOT  
(  
MAX(dblQty)   
FOR strPrimaryStatus IN ([Active], [Quarantine], [On Hold])  
) AS PivotTable
LEFT JOIN
(
	SELECT 
	l.intItemId,
	SUM(l.dblReservedQty) AS dblReservedQty,
	SUM(l.dblAvailableQty) AS dblAvailableQty
	From
	(
	Select 
	i.intItemId,
	[dbo].[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId,iu.intItemUOMId,v.dblReservedNoOfPacks) dblReservedQty,
	[dbo].[fnMFConvertQuantityToTargetItemUOM](v.intItemUOMId,iu.intItemUOMId,v.dblAvailableNoOfPacks) dblAvailableQty,
	v.intLocationId
	FROM vyuMFInventoryView v 
	Join tblICItem i on v.intItemId=i.intItemId
	Join tblICItemUOM iu on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
	Join tblICItemLocation il on i.intItemId=il.intItemId AND v.intLocationId=il.intLocationId
	Where v.dblQty>0 AND v.dtmExpiryDate>GETDATE()
	) l
	Group By l.intLocationId,l.intItemId,l.intLocationId
) AS Reserve ON PivotTable.intItemId=Reserve.intItemId
