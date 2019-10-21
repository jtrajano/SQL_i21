﻿CREATE PROCEDURE [dbo].[uspICGetStockAsOfDate]
	@intItemId AS INT,
	@intLocationId AS INT,
	@intSubLocationId AS INT = NULL,
	@intStorageLocationId AS INT = NULL,
	@dtmDate AS DATETIME = NULL,
	--@intLotId AS INT = NULL, 
	@strLotNumber AS NVARCHAR(50) = NULL,
	@intOwnershipType AS INT = 1, 
	@ysnHasStockOnly AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @DefaultLotCondition NVARCHAR(50)
SELECT @DefaultLotCondition = strLotCondition FROM tblICCompanyPreference

DECLARE @strSubLocationDefault NVARCHAR(50);
DECLARE @strStorageUnitDefault NVARCHAR(50);

DECLARE @tblInventoryTransaction TABLE(
	intItemId				INT,
	intItemUOMId			INT,
	intItemLocationId		INT,
	intSubLocationId		INT NULL,
	intStorageLocationId	INT NULL,
	intLotId				INT NULL,
	intCostingMethod		INT,
	dtmDate					DATETIME,
	dblQty					NUMERIC(38, 20),
	dblUnitStorage			NUMERIC(38, 20),
	dblCost					NUMERIC(38, 20),
	intOwnershipType		INT
);

INSERT INTO @tblInventoryTransaction (
	intItemId
	,intItemUOMId
	,intItemLocationId
	,intSubLocationId
	,intStorageLocationId
	,intLotId
	,intCostingMethod
	,dtmDate
	,dblQty
	,dblUnitStorage
	,dblCost
	,intOwnershipType
)
-- Get the stocks that are Company-Owned 
SELECT	
	t.intItemId
	,intItemUOMId		= t.intItemUOMId 
	,intItemLocationId	= t.intItemLocationId
	,intSubLocationId	= t.intSubLocationId 
	,intStorageLocationId= t.intStorageLocationId 
	,t.intLotId
	,t.intCostingMethod
	,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
	,dblQty				= 
			CASE 
				WHEN Lot.intLotId IS NOT NULL THEN 
					CASE 
						WHEN Lot.intWeightUOMId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intItemUOMId, t.dblQty) 
						ELSE dbo.fnDivide(t.dblQty, Lot.dblWeightPerQty) 
					END
				ELSE 
					t.dblQty
			END 
	,dblUnitStorage		= CAST(0 AS NUMERIC(38, 20))
	,dblLastCost		= dbo.fnCalculateCostBetweenUOM(iu.intItemUOMId, Lot.intItemUOMId, Lot.dblLastCost)
	,intOwnershipType	= 1
FROM	
	tblICInventoryTransaction t INNER JOIN tblICItemLocation IL 
		ON IL.intItemLocationId = t.intItemLocationId	
	INNER JOIN tblICItemUOM iu 
		ON iu.intItemId = t.intItemId
		AND iu.ysnStockUnit = 1
	LEFT JOIN tblICLot Lot 
		ON Lot.intLotId = t.intLotId
WHERE	
	t.intItemId = @intItemId
	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND IL.intLocationId = @intLocationId
	AND (@intSubLocationId IS NULL OR @intSubLocationId = t.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR @intStorageLocationId = t.intStorageLocationId)
	--AND (@intLotId IS NULL OR @intLotId = t.intLotId)
	AND (@strLotNumber IS NULL OR Lot.strLotNumber LIKE @strLotNumber + '%' COLLATE Latin1_General_CI_AS)
	AND @intOwnershipType = 1
	
-- Get the stock that is Customer-Owned (aka Storage)
UNION ALL
SELECT	t.intItemId
		,intItemUOMId		= t.intItemUOMId
		,intItemLocationId	= t.intItemLocationId
		,intSubLocationId	= t.intSubLocationId
		,intStorageLocationId = t.intStorageLocationId
		,t.intLotId
		,t.intCostingMethod
		,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
		,dblQty				= CAST(0 AS NUMERIC(38, 20))
		,dblUnitStorage		= 
			CASE 
				WHEN Lot.intLotId IS NOT NULL THEN 
					CASE 
						WHEN Lot.intWeightUOMId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intItemUOMId, t.dblQty) 
						ELSE dbo.fnDivide(t.dblQty, Lot.dblWeightPerQty) 
					END
				ELSE 
					t.dblQty
			END 
		,dblCost
		,intOwnershipType	= 2
FROM	
	tblICInventoryTransactionStorage t INNER JOIN tblICItemLocation IL 
		ON IL.intItemLocationId = t.intItemLocationId
	LEFT JOIN tblICLot Lot 
		ON Lot.intLotId = t.intLotId
WHERE 
	t.intItemId = @intItemId
	AND IL.intLocationId = @intLocationId
	AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND (@intSubLocationId IS NULL OR  @intSubLocationId = t.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR  @intStorageLocationId = t.intStorageLocationId)
	--AND (@intLotId IS NULL OR @intLotId = t.intLotId)
	AND (@strLotNumber IS NULL OR Lot.strLotNumber LIKE @strLotNumber + '%' COLLATE Latin1_General_CI_AS)
	AND @intOwnershipType = 2

-- Return the result back. 
SELECT 
	intKey							= CAST(ROW_NUMBER() OVER(ORDER BY Lot.intLotId, i.intItemId, ItemLocation.intLocationId) AS INT)
	,i.intItemId
	,i.strItemNo 
	,ItemUOM.intItemUOMId
	,strItemUOM						= iUOM.strUnitMeasure
	,strItemUOMType					= iUOM.strUnitType
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
	,dblRunningAvailableQty			= SUM(t.dblQty) 
	,dblStorageAvailableQty			= SUM(t.dblUnitStorage) 
	,dblCost						= MAX(t.dblCost)
	,Lot.strWarehouseRefNo
	,strCondition					= COALESCE(NULLIF(Lot.strCondition, ''), @DefaultLotCondition) 
FROM 
	@tblInventoryTransaction t 
	INNER JOIN tblICItem i 
		ON i.intItemId = t.intItemId
	INNER JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
				ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
		) ON ItemUOM.intItemUOMId = t.intItemUOMId

	LEFT JOIN tblICLot Lot
		ON Lot.intLotId = t.intLotId
	LEFT JOIN (
			tblICItemUOM LotWeightUOM INNER JOIN tblICUnitMeasure wUOM
				ON LotWeightUOM.intUnitMeasureId = wUOM.intUnitMeasureId
		) ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId 
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
		,LotWeightUOM.dblUnitQty
		,Lot.intLotStatusId
		,LotStatus.strSecondaryStatus
		,LotStatus.strPrimaryStatus
		,ItemOwner.intOwnerId
		,LotEntity.strName
		,ItemLocation.intItemLocationId
		,t.intCostingMethod	
		,CostMethod.strCostingMethod
		,Lot.strWarehouseRefNo
		,Lot.strCondition
HAVING	(@ysnHasStockOnly = 1 AND (SUM(t.dblQty) <> 0 OR SUM(t.dblUnitStorage) <> 0))
		OR @ysnHasStockOnly = 0 
