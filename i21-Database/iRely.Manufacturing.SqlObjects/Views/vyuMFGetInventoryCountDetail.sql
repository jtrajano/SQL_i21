CREATE VIEW vyuMFGetInventoryCountDetail
AS
SELECT IC.dtmCountDate AS [Count Date]
	,strCountNo AS [Count No]
	,ICD.strItemNo AS [Item No]
	,ICD.strItemDescription AS [Item Desc]
	,ICD.strCategory [Category]
	,ICD.strStorageLocationName AS [Storage Location]
	,ICD.strLotNo AS [Pallet No]
	,ICD.strLotAlias AS [Pallet Alias]
	,ICD.dblSystemCount AS [System Count]
	,ICD.strCountLine AS [Count Line No]
	,ICD.dblPhysicalCount AS [Physical Count]
	,ICD.strUnitMeasure AS [Unit Measure]
	,ICD.dblPhysicalCountStockUnit AS [Physical Count Stock Unit]
	,ICD.dblVariance AS [Variance]
	,ICD.strUserName AS [UserName]
FROM [vyuICGetInventoryCount] IC
JOIN [vyuICGetInventoryCountDetail] ICD ON IC.intInventoryCountId = ICD.intInventoryCountId
