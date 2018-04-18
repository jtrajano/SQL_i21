CREATE VIEW [dbo].[vyuICGetItemRunningStock]
	AS
WITH InvTransaction AS(
	SELECT	intItemId,
			intItemUOMId,
			intItemLocationId,
			intSubLocationId,
			intStorageLocationId,
			intLotId,
			intCostingMethod,
			dtmDate				= CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime),
			dblQty				= dblQty,
			dblUnitStorage		= 0,
			dblCost,
			intOwnershipType	= 1
	FROM tblICInventoryTransaction
	UNION ALL
		SELECT	intItemId,
			intItemUOMId,
			intItemLocationId,
			intSubLocationId,
			intStorageLocationId,
			intLotId,
			intCostingMethod,
			dtmDate				= CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime),
			dblQty				= 0,
			dblUnitStorage		= dblQty,
			dblCost,
			intOwnershipType	= 2
	FROM tblICInventoryTransactionStorage
)
SELECT intKey						= CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, ItemLocation.intLocationId) AS INT)
	,i.intItemId
	,i.strItemNo 
	,ItemUOM.intItemUOMId
	,strItemUOM = iUOM.strUnitMeasure
	,strItemUOMType = iUOM.strUnitType
	,ItemUOM.ysnStockUnit
	,ItemUOM.dblUnitQty
	,t.intCostingMethod
	,CostMethod.strCostingMethod
	,ItemLocation.intLocationId
	,strLocationName				= CompanyLocation.strLocationName
	,t.intSubLocationId
	,SubLocation.strSubLocationName
	,t.intStorageLocationId
	,strStorageLocationName			= strgLoc.strName
	,Lot.intLotId
	,Lot.strLotNumber
	,t.intOwnershipType
	,strOwnershipType				= dbo.fnICGetOwnershipType(t.intOwnershipType)
	,Lot.dtmExpiryDate
	,Lot.intItemOwnerId
	,intWeightUOMId					= Lot.intWeightUOMId
	,strWeightUOM					= wUOM.strUnitMeasure
	,dblWeightUOMConvF				= LotWeightUOM.dblUnitQty
	,Lot.dblWeight
	,Lot.dblWeightPerQty
	,intLotStatusId					= Lot.intLotStatusId
	,strLotStatus					= LotStatus.strSecondaryStatus
	,strLotPrimaryStatus			= LotStatus.strPrimaryStatus
	,ItemOwner.intOwnerId
	,strOwner = LotEntity.strName
	,dtmAsOfDate					= t.dtmDate
	,dblQty							= CASE WHEN Lot.intLotId IS NOT NULL THEN SUM(t.dblUnitStorage + t.dblQty) ELSE SUM(t.dblQty) END
	,dblUnitStorage					= CASE WHEN Lot.intLotId IS NOT NULL THEN 0 ELSE SUM(t.dblUnitStorage) END
	,dblCost = CASE 
			WHEN t.intCostingMethod = 1 THEN dbo.fnGetItemAverageCost(i.intItemId, ItemLocation.intItemLocationId, ItemUOM.intItemUOMId)
			WHEN t.intCostingMethod = 2 THEN FIFO.dblCost
			ELSE MAX(t.dblCost) 
		END
FROM InvTransaction t 
LEFT JOIN tblICItem i 
	ON i.intItemId = t.intItemId
INNER JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
			ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
	) ON ItemUOM.intItemUOMId = t.intItemUOMId
OUTER APPLY(
	SELECT TOP 1 *
	FROM (SELECT intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblCost
			,dblOnHand = SUM(dblStockIn) - SUM(dblStockOut) 
	FROM tblICInventoryFIFO
	GROUP BY intItemId, intItemLocationId, intItemUOMId, dtmDate, dblCost) FIFO
	WHERE FIFO.dblOnHand > 0 AND  t.intItemId = FIFO.intItemId AND t.intItemLocationId = FIFO.intItemLocationId AND t.intItemUOMId = FIFO.intItemUOMId
	ORDER BY dtmDate ASC
) FIFO 
LEFT JOIN tblICItemLocation ItemLocation 
	ON ItemLocation.intItemLocationId = t.intItemLocationId
LEFT JOIN tblICCostingMethod CostMethod
	ON CostMethod.intCostingMethodId = t.intCostingMethod
LEFT JOIN tblSMCompanyLocation CompanyLocation 
	ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
	ON SubLocation.intCompanyLocationSubLocationId = t.intSubLocationId
LEFT JOIN tblICStorageLocation strgLoc 
	ON strgLoc.intStorageLocationId = t.intStorageLocationId
LEFT JOIN tblICLot Lot
	ON Lot.intLotId = t.intLotId
LEFT JOIN (
		tblICItemUOM LotWeightUOM INNER JOIN tblICUnitMeasure wUOM
			ON LotWeightUOM.intUnitMeasureId = wUOM.intUnitMeasureId
	) ON LotWeightUOM.intItemUOMId = Lot.intItemUOMId
LEFT JOIN tblICLotStatus LotStatus
	ON LotStatus.intLotStatusId = Lot.intLotStatusId
LEFT JOIN tblICItemOwner ItemOwner
	ON ItemOwner.intItemOwnerId = Lot.intItemOwnerId
LEFT JOIN tblEMEntity LotEntity
	ON LotEntity.intEntityId = ItemOwner.intOwnerId
GROUP BY i.intItemId
		,i.strItemNo
		,ItemUOM.intItemUOMId
		,iUOM.strUnitMeasure 
		,iUOM.strUnitType
		,ItemUOM.ysnStockUnit
		,ItemUOM.dblUnitQty
		,ItemLocation.intLocationId
		,ItemLocation.intItemLocationId
		,CompanyLocation.strLocationName
		,t.intSubLocationId
		,SubLocation.strSubLocationName
		,t.intStorageLocationId
		,strgLoc.strName
		,Lot.intLotId
		,Lot.strLotNumber
		,t.intOwnershipType
		,Lot.dtmExpiryDate
		,Lot.intItemOwnerId
		,Lot.dblWeight
		,Lot.dblWeightPerQty
		,Lot.intWeightUOMId
		,wUOM.strUnitMeasure
		,LotWeightUOM.dblUnitQty
		,Lot.intLotStatusId
		,LotStatus.strSecondaryStatus
		,LotStatus.strPrimaryStatus
		,ItemOwner.intOwnerId
		,LotEntity.strName
		,t.intCostingMethod	
		,CostMethod.strCostingMethod	
		,FIFO.dblCost		
		,t.dtmDate