/*
 * Title: Lot No Stock
 * Description: Returns list of lot with stock similarly to uspICGetLotAsOfDate
 * Created By: Jonathan Valenzuela
 * Created Date: 01/24/2023
 * JIRA: QC-941 
*/
CREATE PROCEDURE [dbo].[uspQMGetLot]
(
	@intItemId				AS INT = NULL
  , @intLocationId			AS INT
  , @dtmDate				AS DATETIME = NULL
  , @strLotNumber			AS NVARCHAR(50) = NULL
  , @ysnHasStockOnly		AS BIT = 0
  , @intOwnershipType		AS INT = 1
)	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @DefaultLotCondition NVARCHAR(50)

SELECT @DefaultLotCondition = strLotCondition FROM tblICCompanyPreference

DECLARE @tblInventoryTransaction TABLE
(
	intItemId				INT
  , intItemUOMId			INT
  , intItemLocationId		INT
  , intSubLocationId		INT
  , intStorageLocationId	INT
  , intLotId				INT
  , intCostingMethod		INT
  , dtmDate					DATETIME
  , dblQty					NUMERIC(38, 20)
  , dblUnitStorage			NUMERIC(38, 20)
  , dblCost					NUMERIC(38, 20)
  , intOwnershipType		INT
  , strContainerNo          NVARCHAR(50)
  , strMarkings				NVARCHAR(MAX)
  , dblStandardWeight		NUMERIC(38, 20)
);

INSERT INTO @tblInventoryTransaction 
(
	intItemId
  , intItemUOMId
  , intItemLocationId
  , intSubLocationId
  , intStorageLocationId
  , intLotId
  , intCostingMethod
  , dtmDate
  , dblQty
  , dblUnitStorage
  , dblCost
  , intOwnershipType
  , strContainerNo
  , strMarkings
  , dblStandardWeight
)

-- Get the Lot that is Company-Owned 
SELECT t.intItemId
	 , intItemUOMId			= Lot.intItemUOMId 
	 , intItemLocationId	= Lot.intItemLocationId
	 , intSubLocationId		= Lot.intSubLocationId 
	 , intStorageLocationId	= Lot.intStorageLocationId 
	 , t.intLotId
	 , t.intCostingMethod
	 , dtmDate				= dbo.fnRemoveTimeOnDate(dtmDate)
	 , dblQty				= CASE WHEN Lot.intWeightUOMId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intItemUOMId, t.dblQty) 
								   ELSE dbo.fnDivide(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intWeightUOMId, t.dblQty), Lot.dblWeightPerQty)
							  END
	 , dblUnitStorage		= CAST(0 AS NUMERIC(38, 20))
	 , dblLastCost			= dbo.fnCalculateCostBetweenUOM(iu.intItemUOMId, Lot.intItemUOMId, Lot.dblLastCost)
	 , intOwnershipType		= 1
	 , Lot.strContainerNo
	 , Lot.strMarkings
	 , iu.dblStandardWeight
FROM tblICInventoryTransaction t
INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
INNER JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
INNER JOIN tblICItemUOM iu ON iu.intItemId = t.intItemId AND iu.ysnStockUnit = 1		
WHERE t.intItemId = @intItemId
  AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
  AND (NULLIF(@intLocationId, 0) IS NULL OR @intLocationId =  IL.intLocationId)
  AND (@strLotNumber IS NULL OR Lot.strLotNumber LIKE @strLotNumber + '%' COLLATE Latin1_General_CI_AS)
  AND @intOwnershipType = 1
	
/* Get the Lot that is Customer-Owned (aka Storage). */
UNION ALL

SELECT t.intItemId
	 , intItemUOMId			= Lot.intItemUOMId
	 , intItemLocationId	= Lot.intItemLocationId
	 , intSubLocationId		= Lot.intSubLocationId
	 , intStorageLocationId = Lot.intStorageLocationId
	 , t.intLotId
	 , t.intCostingMethod
	 , dtmDate				= dbo.fnRemoveTimeOnDate(dtmDate)
	 , dblQty				= CAST(0 AS NUMERIC(38, 20))
	 , dblUnitStorage		= CASE WHEN Lot.intWeightUOMId IS NULL THEN dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, Lot.intItemUOMId, t.dblQty) 
								   ELSE dbo.fnDivide(t.dblQty, Lot.dblWeightPerQty) 
							  END
	 , dblCost
	 , intOwnershipType		= 2
	 , Lot.strContainerNo
	 , Lot.strMarkings
	 , ItemUOM.dblStandardWeight
FROM tblICInventoryTransactionStorage t 
INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
INNER JOIN tblICLot Lot ON Lot.intLotId = t.intLotId
INNER JOIN tblICItemUOM ItemUOM ON Lot.intItemId = ItemUOM.intItemId
WHERE t.intItemId = @intItemId
  AND FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmDate AS FLOAT))
  AND (@intLocationId IS NULL OR @intLocationId =  IL.intLocationId)
  AND (@strLotNumber IS NULL OR Lot.strLotNumber LIKE @strLotNumber + '%' COLLATE Latin1_General_CI_AS)
  AND @intOwnershipType = 2



/* Final Output / Returned List of data */ 
SELECT intKey							= CAST(ROW_NUMBER() OVER(ORDER BY Lot.intLotId, i.intItemId, ItemLocation.intLocationId) AS INT)
	 , strLotNumber
	 , InventoryTransaction.intStorageLocationId
	 , strStorageLocationName			= strgLoc.strName
	 , intLotStatusId					= Lot.intLotStatusId
	 , strLotStatus						= LotStatus.strSecondaryStatus
	 , iUOM.intUnitMeasureId
	 , strItemUOM						= iUOM.strUnitMeasure
	 , dblRunningAvailableQty			= SUM(InventoryTransaction.dblQty) 
	 , Lot.intLotId
	 , strLocationName					= CompanyLocation.strLocationName
	 , intCompanyLocationId				= CompanyLocation.intCompanyLocationId
	 , SubLocation.strSubLocationName
	 , ItemUOM.intItemUOMId
	 , intWeightUOMId					= Lot.intWeightUOMId
	 , strWeightUOM						= wUOM.strUnitMeasure
	 , ItemLocation.intLocationId
	 , InventoryTransaction.intSubLocationId
FROM @tblInventoryTransaction AS InventoryTransaction 
INNER JOIN tblICItem i ON i.intItemId = InventoryTransaction.intItemId
INNER JOIN (tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure iUOM ON ItemUOM.intUnitMeasureId = iUOM.intUnitMeasureId) ON ItemUOM.intItemUOMId = InventoryTransaction.intItemUOMId
INNER JOIN tblICLot Lot ON Lot.intLotId = InventoryTransaction.intLotId
LEFT JOIN (tblICItemUOM LotWeightUOM INNER JOIN tblICUnitMeasure wUOM ON LotWeightUOM.intUnitMeasureId = wUOM.intUnitMeasureId) ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId 
LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemLocationId = InventoryTransaction.intItemLocationId
LEFT JOIN tblICCostingMethod CostMethod ON CostMethod.intCostingMethodId = InventoryTransaction.intCostingMethod
LEFT JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = InventoryTransaction.intSubLocationId
LEFT JOIN tblICStorageLocation strgLoc ON strgLoc.intStorageLocationId = InventoryTransaction.intStorageLocationId
LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId
GROUP BY i.intItemId
	   , i.strItemNo
	   , ItemUOM.intItemUOMId
	   , iUOM.strUnitMeasure 
	   , iUOM.strUnitType
	   , iUOM.intUnitMeasureId
	   , ItemUOM.ysnStockUnit
	   , ItemUOM.dblUnitQty
	   , ItemLocation.intLocationId
	   , CompanyLocation.strLocationName
	   , CompanyLocation.intCompanyLocationId
	   , InventoryTransaction.intSubLocationId
	   , SubLocation.strSubLocationName
	   , InventoryTransaction.intStorageLocationId
	   , strgLoc.strName
	   , Lot.intLotId
	   , Lot.strLotNumber
	   , InventoryTransaction.intOwnershipType
	   , Lot.dtmExpiryDate
	   , Lot.intItemOwnerId
	   , Lot.dblWeight
	   , Lot.dblWeightPerQty
	   , Lot.intWeightUOMId
	   , Lot.strContainerNo
	   , Lot.strMarkings
	   , Lot.dblQty
	   , wUOM.strUnitMeasure
	   , LotWeightUOM.dblUnitQty
	   , Lot.intLotStatusId
	   , LotStatus.strSecondaryStatus
	   , LotStatus.strPrimaryStatus
	   , ItemLocation.intItemLocationId
	   , InventoryTransaction.intCostingMethod	
	   , CostMethod.strCostingMethod
	   , Lot.strWarehouseRefNo
	   , Lot.strCondition
	   , ItemUOM.dblStandardWeight
HAVING	(@ysnHasStockOnly = 1 AND (SUM(InventoryTransaction.dblQty) <> 0 OR SUM(InventoryTransaction.dblUnitStorage) <> 0)) 
		OR @ysnHasStockOnly = 0
GO


