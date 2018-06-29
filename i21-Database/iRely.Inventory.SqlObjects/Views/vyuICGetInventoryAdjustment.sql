CREATE VIEW [dbo].[vyuICGetInventoryAdjustment]
	AS 

SELECT 
	Adj.intInventoryAdjustmentId
	, Adj.intLocationId
	, Location.strLocationName
	, Adj.dtmAdjustmentDate
	, Adj.intAdjustmentType
	, strAdjustmentType = (
		CASE WHEN Adj.intAdjustmentType = 1 THEN 'Quantity Change'
			WHEN Adj.intAdjustmentType = 2 THEN 'UOM Change'
			WHEN Adj.intAdjustmentType = 3 THEN 'Item Change'
			WHEN Adj.intAdjustmentType = 4 THEN 'Lot Status Change' 
			WHEN Adj.intAdjustmentType = 5 THEN 'Split Lot'
			WHEN Adj.intAdjustmentType = 6 THEN 'Expiry Date Change'
			WHEN Adj.intAdjustmentType = 7 THEN 'Lot Merge'
			WHEN Adj.intAdjustmentType = 8 THEN 'Lot Move'
			WHEN Adj.intAdjustmentType = 9 THEN 'Lot Owner Change'
			WHEN Adj.intAdjustmentType = 10 THEN 'Opening Inventory'
			WHEN Adj.intAdjustmentType = 11 THEN 'Change Lot Weight'
		END)
	, Adj.strAdjustmentNo
	, Adj.strDescription
	, Adj.intSort
	, Adj.ysnPosted
	, Adj.intEntityId
	, strUser = UserEntity.strName
	, Adj.dtmPostedDate
	, Adj.dtmUnpostedDate
	, Adj.intSourceId
	, Adj.intSourceTransactionTypeId
	, Adj.intConcurrencyId
FROM tblICInventoryAdjustment Adj
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Adj.intLocationId
LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = Adj.intEntityId