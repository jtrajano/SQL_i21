CREATE FUNCTION [dbo].[fnICGetItemRunningStockLotQty] (
	@intItemId AS INT,
	@intLocationId AS INT,
	@intSubLocationId AS INT = NULL,
	@intStorageLocationId AS INT = NULL,
	@dtmDate AS DATETIME = NULL,
	@intLotId AS INT = NULL, 
	@strLotNumber AS NVARCHAR(50) = NULL,
	@intOwnershipType AS INT = 1, 
	@ysnHasStockOnly AS BIT = 0
)
RETURNS @Table TABLE (
	 intKey INT
	,intItemId INT
	,strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,intItemUOMId INT
	,strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strItemUOMType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,ysnStockUnit BIT NULL
	,dblUnitQty NUMERIC(38, 20) NULL
	,intCostingMethod INT NULL
	,strCostingMethod NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intLocationId INT NULL
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,intSubLocationId INT NULL
	,strSubLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,intStorageLocationId INT NULL
	,strStorageLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,intLotId INT NULL
	,strLotNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,intOwnershipType INT
	,strOwnershipType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmExpiryDate DATETIME NULL
	,intItemOwnerId INT NULL
	,intWeightUOMId INT NULL
	,strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dblWeightUOMConvF NUMERIC(38, 20) NULL
	,dblWeight NUMERIC(38, 20) NULL
	,dblWeightPerQty NUMERIC(38, 20) NULL
	,intLotStatusId INT NULL
	,strLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strLotPrimaryStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intOwnerId INT NULL
	,strOwner NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dblRunningAvailableQty NUMERIC(38, 20) NULL
	,dblStorageAvailableQty NUMERIC(38, 20) NULL
	,dblCost NUMERIC(38, 20) NULL
	,strWarehouseRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strCondition NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strContainerNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strMarkings NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,dblStandardWeight NUMERIC(38, 20) NULL
)
AS
BEGIN
DECLARE @DefaultLotCondition NVARCHAR(50)
SELECT @DefaultLotCondition = strLotCondition FROM tblICCompanyPreference

DECLARE @strSubLocationDefault NVARCHAR(50);
DECLARE @strStorageUnitDefault NVARCHAR(50);

DECLARE @tblInventoryTransaction TABLE(
	intItemId				INT,
	intItemUOMId			INT,
	intItemLocationId		INT,
	intSubLocationId		INT,
	intStorageLocationId	INT,
	intLotId				INT,
	intCostingMethod		INT,
	dtmDate					DATETIME,
	dblQty					NUMERIC(38, 20),
	dblUnitStorage			NUMERIC(38, 20),
	dblCost					NUMERIC(38, 20),
	intOwnershipType		INT,
	strContainerNo          NVARCHAR(50), 
	strMarkings				NVARCHAR(MAX),
	dblStandardWeight		NUMERIC(38, 20)
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
	,strContainerNo
	,strMarkings
	,dblStandardWeight
)
-- Get the Lot that is Company-Owned 
SELECT	
	t.intItemId
	,intItemUOMId		= Lot.intItemUOMId 
	,intItemLocationId	= Lot.intItemLocationId
	,intSubLocationId	= Lot.intSubLocationId 
	,intStorageLocationId= Lot.intStorageLocationId 
	,t.intLotId
	,t.intCostingMethod
	,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
	,dblQty				= CASE 
							WHEN Lot.intWeightUOMId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intItemUOMId, t.dblQty) 
							ELSE --dbo.fnDivide(t.dblQty, Lot.dblWeightPerQty) 
								dbo.fnDivide(
									dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intWeightUOMId, t.dblQty) 
									,Lot.dblWeightPerQty
								)
						END
	,dblUnitStorage		= CAST(0 AS NUMERIC(38, 20))
	,dblLastCost = dbo.fnCalculateCostBetweenUOM(iu.intItemUOMId, Lot.intItemUOMId, Lot.dblLastCost)
	,intOwnershipType	= 1
	,Lot.strContainerNo
	,Lot.strMarkings
	,iu.dblStandardWeight
FROM	
	tblICInventoryTransaction t
	INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
	INNER JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
	INNER JOIN tblICItemUOM iu 
		ON iu.intItemId = t.intItemId
		AND iu.ysnStockUnit = 1		
WHERE	
	t.intItemId = @intItemId
	--AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND IL.intLocationId = @intLocationId
	AND (NULLIF(@intSubLocationId, 0) IS NULL OR @intSubLocationId = Lot.intSubLocationId)
	AND (NULLIF(@intStorageLocationId, 0) IS NULL OR @intStorageLocationId = Lot.intStorageLocationId)
	AND (@intLotId IS NULL OR @intLotId = t.intLotId)
	AND (@strLotNumber IS NULL OR Lot.strLotNumber LIKE @strLotNumber + '%' COLLATE Latin1_General_CI_AS)
	AND @intOwnershipType = 1
	
-- Get the Lot that is Customer-Owned (aka Storage)
UNION ALL
SELECT	t.intItemId
		,intItemUOMId		= Lot.intItemUOMId
		,intItemLocationId	= Lot.intItemLocationId
		,intSubLocationId	= Lot.intSubLocationId
		,intStorageLocationId = Lot.intStorageLocationId
		,t.intLotId
		,t.intCostingMethod
		,dtmDate			= dbo.fnRemoveTimeOnDate(dtmDate)
		,dblQty				= CAST(0 AS NUMERIC(38, 20))
		,dblUnitStorage		= CASE 
								WHEN Lot.intWeightUOMId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intItemUOMId, t.dblQty) 
								ELSE dbo.fnDivide(t.dblQty, Lot.dblWeightPerQty) 
							END
		,dblCost
		,intOwnershipType	= 2
		,Lot.strContainerNo
		,Lot.strMarkings
		,ItemUOM.dblStandardWeight
FROM	
	tblICInventoryTransactionStorage t 
	INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
	INNER JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
	INNER JOIN tblICItemUOM ItemUOM ON Lot.intItemId = ItemUOM.intItemId
WHERE 
	t.intItemId = @intItemId
	AND IL.intLocationId = @intLocationId
	--AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
	AND (@intSubLocationId IS NULL OR  @intSubLocationId = Lot.intSubLocationId)
	AND (@intStorageLocationId IS NULL OR  @intStorageLocationId = Lot.intStorageLocationId)
	AND (@intLotId IS NULL OR @intLotId = t.intLotId)
	AND (@strLotNumber IS NULL OR Lot.strLotNumber LIKE @strLotNumber + '%' COLLATE Latin1_General_CI_AS)
	AND @intOwnershipType = 2

INSERT INTO @Table
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
	,Lot.strContainerNo
	,Lot.strMarkings
	,ItemUOM.dblStandardWeight
FROM 
	@tblInventoryTransaction t 
	INNER JOIN tblICItem i 
		ON i.intItemId = t.intItemId
	INNER JOIN (
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM
				ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId
		) ON ItemUOM.intItemUOMId = t.intItemUOMId

	INNER JOIN tblICLot Lot
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
		,Lot.strContainerNo
		,Lot.strMarkings
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
		,ItemUOM.dblStandardWeight
HAVING	(@ysnHasStockOnly = 1 AND (SUM(t.dblQty) <> 0 OR SUM(t.dblUnitStorage) <> 0))
		OR @ysnHasStockOnly = 0

RETURN
END