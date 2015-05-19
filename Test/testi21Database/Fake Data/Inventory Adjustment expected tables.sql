CREATE PROCEDURE [testi21Database].[Inventory Adjustment expected tables]
AS
BEGIN	

	-- Create the expected and actual tables. 
	CREATE TABLE expected_tblICInventoryAdjustment (
		intInventoryAdjustmentId INT NULL 
		,intLocationId INT NULL 
		,dtmAdjustmentDate DATETIME NULL 
		,intAdjustmentType INT NULL 
		,strAdjustmentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,intSort INT NULL 
		,ysnPosted BIT NULL
		,intEntityId INT NULL
		,intConcurrencyId INT NULL
		,dtmPostedDate DATETIME NULL
		,dtmUnpostedDate DATETIME NULL 			
	)

	CREATE TABLE actual_tblICInventoryAdjustment (
		intInventoryAdjustmentId INT NULL 
		,intLocationId INT NULL 
		,dtmAdjustmentDate DATETIME NULL 
		,intAdjustmentType INT NULL 
		,strAdjustmentNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,intSort INT NULL 
		,ysnPosted BIT NULL
		,intEntityId INT NULL
		,intConcurrencyId INT NULL
		,dtmPostedDate DATETIME NULL
		,dtmUnpostedDate DATETIME NULL 			
	)

	CREATE TABLE expected_expected_tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentDetailId INT NULL 
		,intInventoryAdjustmentId INT NULL 
		,intSubLocationId INT NULL 
		,intStorageLocationId INT NULL 
		,intItemId INT NULL
		,intNewItemId INT NULL
		,intLotId INT NULL
		,intNewLotId INT NULL
		,strNewLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblNewQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblNewSplitLotQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblAdjustByQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,intItemUOMId INT NULL
		,intNewItemUOMId INT NULL
		,intWeightUOMId INT NULL
		,intNewWeightUOMId INT NULL
		,dblWeight NUMERIC(18,6) NULL DEFAULT ((0))
		,dblNewWeight NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblWeightPerQty NUMERIC(38,20) NULL DEFAULT ((0))
		,dblNewWeightPerQty NUMERIC(38,20) NULL DEFAULT ((0))
		,dtmExpiryDate DATETIME NULL
		,dtmNewExpiryDate DATETIME NULL
		,intLotStatusId INT NULL
		,intNewLotStatusId INT NULL
		,dblCost NUMERIC(38,20) NULL DEFAULT ((0))
		,dblNewCost NUMERIC(38,20) NULL DEFAULT ((0))
		,intNewLocationId INT NULL
		,intNewSubLocationId INT NULL
		,intNewStorageLocationId INT NULL
		,dblLineTotal NUMERIC(38,20) NULL DEFAULT ((0))
		,intSort INT NULL
		,intConcurrencyId INT NULL DEFAULT ((0))
	)

	CREATE TABLE actual_expected_tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentDetailId INT NULL 
		,intInventoryAdjustmentId INT NULL 
		,intSubLocationId INT NULL 
		,intStorageLocationId INT NULL 
		,intItemId INT NULL
		,intNewItemId INT NULL
		,intLotId INT NULL
		,intNewLotId INT NULL
		,strNewLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblNewQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblNewSplitLotQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblAdjustByQuantity NUMERIC(18, 6) NULL DEFAULT ((0))
		,intItemUOMId INT NULL
		,intNewItemUOMId INT NULL
		,intWeightUOMId INT NULL
		,intNewWeightUOMId INT NULL
		,dblWeight NUMERIC(18,6) NULL DEFAULT ((0))
		,dblNewWeight NUMERIC(18, 6) NULL DEFAULT ((0))
		,dblWeightPerQty NUMERIC(38,20) NULL DEFAULT ((0))
		,dblNewWeightPerQty NUMERIC(38,20) NULL DEFAULT ((0))
		,dtmExpiryDate DATETIME NULL
		,dtmNewExpiryDate DATETIME NULL
		,intLotStatusId INT NULL
		,intNewLotStatusId INT NULL
		,dblCost NUMERIC(38,20) NULL DEFAULT ((0))
		,dblNewCost NUMERIC(38,20) NULL DEFAULT ((0))
		,intNewLocationId INT NULL
		,intNewSubLocationId INT NULL
		,intNewStorageLocationId INT NULL
		,dblLineTotal NUMERIC(38,20) NULL DEFAULT ((0))
		,intSort INT NULL
		,intConcurrencyId INT NULL DEFAULT ((0))
	)
END