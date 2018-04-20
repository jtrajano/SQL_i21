CREATE VIEW [dbo].[vyuICGetItemRunningStock]
	AS
WITH InvTransaction AS(
		SELECT	t.intItemId,
			intItemUOMId		= CASE WHEN t.intLotId IS NULL THEN t.intItemUOMId ELSE Lot.intItemUOMId END,
			intItemLocationId	= CASE WHEN t.intLotId IS NULL THEN t.intItemLocationId ELSE Lot.intItemLocationId END,
			intSubLocationId	= CASE WHEN t.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END,
			intStorageLocationId= CASE WHEN t.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END,
			t.intLotId,
			dtmDate				= CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime),
			dblQty				= CASE WHEN t.intLotId IS NULL THEN t.dblQty ELSE Lot.dblQty END,
			dblUnitStorage		= CAST(0 AS NUMERIC(38, 20)),
			dblCost,
			intOwnershipType	= 1
	FROM tblICInventoryTransaction t
	LEFT JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
	UNION ALL
		SELECT	t.intItemId,
			intItemUOMId		= CASE WHEN t.intLotId IS NULL THEN t.intItemUOMId ELSE Lot.intItemUOMId END,
			intItemLocationId	= CASE WHEN t.intLotId IS NULL THEN t.intItemLocationId ELSE Lot.intItemLocationId END,
			intSubLocationId	= CASE WHEN t.intLotId IS NULL THEN t.intSubLocationId ELSE Lot.intSubLocationId END,
			intStorageLocationId= CASE WHEN t.intLotId IS NULL THEN t.intStorageLocationId ELSE Lot.intStorageLocationId END,
			t.intLotId,
			dtmDate				= CAST(CONVERT(VARCHAR(10),dtmDate,112) AS datetime),
			dblQty				= CAST(0 AS NUMERIC(38, 20)),
			dblUnitStorage		= CASE WHEN t.intLotId IS NULL THEN t.dblQty ELSE Lot.dblQty END,
			dblCost,
			intOwnershipType	= 2
	FROM tblICInventoryTransactionStorage t 
	LEFT JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
	UNION ALL
	SELECT	i.intItemId,
			intItemUOMId		= ItemUOMStock.intItemUOMId,
			intItemLocationId	= DefaultLocation.intItemLocationId,
			intSubLocationId	= NULL,
			intStorageLocationId= NULL,
			intLotId			= NULL,
			dtmDate				= CAST(CONVERT(VARCHAR(10),GETDATE(),112) AS datetime),
			dblQty				= CAST(0 AS NUMERIC(38, 20)) ,
			dblUnitStorage		= CAST(0 AS NUMERIC(38, 20)) ,
			dblCost				= ItemPricing.dblLastCost,
			intOwnershipType	= 1
	FROM tblICItem i
	CROSS APPLY(
		SELECT	intItemUOMId
		FROM	tblICItemUOM iuStock 
		WHERE iuStock.intItemId = i.intItemId AND iuStock.ysnStockUnit = 1
					
	) ItemUOMStock
	CROSS APPLY (
		SELECT	ItemLocation.intItemLocationId
		FROM tblICItemLocation ItemLocation LEFT JOIN tblSMCompanyLocation [Location] 
			ON [Location].intCompanyLocationId = ItemLocation.intLocationId		
		WHERE ItemLocation.intItemId = i.intItemId
	) DefaultLocation
	LEFT JOIN tblICItemPricing ItemPricing 
		ON i.intItemId = ItemPricing.intItemId 
		AND DefaultLocation.intItemLocationId = ItemPricing.intItemLocationId
	WHERE i.strLotTracking = 'No'
)
SELECT intKey						= CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, ItemLocation.intLocationId) AS INT)
	,i.intItemId
	,i.strItemNo 
	,ItemUOM.intItemUOMId
	,strItemUOM = iUOM.strUnitMeasure
	,strItemUOMType = iUOM.strUnitType
	,ItemUOM.ysnStockUnit
	,ItemUOM.dblUnitQty
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
	,dblCost						= MAX(t.dblCost)
FROM InvTransaction t 
LEFT JOIN tblICItem i 
	ON i.intItemId = t.intItemId
INNER JOIN (
		tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
			ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
	) ON ItemUOM.intItemUOMId = t.intItemUOMId
LEFT JOIN tblICItemLocation ItemLocation 
	ON ItemLocation.intItemLocationId = t.intItemLocationId
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
		,Lot.intLotStatusId
		,LotStatus.strSecondaryStatus
		,LotStatus.strPrimaryStatus
		,ItemOwner.intOwnerId
		,LotEntity.strName
		,t.dtmDate