﻿CREATE PROCEDURE [testi21Database].[Inventory Adjustment expected tables]
AS
BEGIN	

	-- Create the expected and actual tables. 
	CREATE TABLE expected_tblICInventoryAdjustment (
		intInventoryAdjustmentId		INT NULL 
		,intLocationId					INT NULL 
		,dtmAdjustmentDate				DATETIME NULL 
		,intAdjustmentType				INT NULL 
		,strAdjustmentNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,strDescription					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,intSort						INT NULL 
		,ysnPosted						BIT NULL
		,intEntityId					INT NULL
		,intConcurrencyId				INT NULL
		,dtmPostedDate					DATETIME NULL
		,dtmUnpostedDate				DATETIME NULL 			
		,intSourceId					INT NULL 
		,intSourceTransactionTypeId		INT NULL 
	)

	CREATE TABLE actual_tblICInventoryAdjustment (
		intInventoryAdjustmentId		INT NULL 
		,intLocationId					INT NULL 
		,dtmAdjustmentDate				DATETIME NULL 
		,intAdjustmentType				INT NULL 
		,strAdjustmentNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,strDescription					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,intSort						INT NULL 
		,ysnPosted						BIT NULL
		,intEntityId					INT NULL
		,intConcurrencyId				INT NULL
		,dtmPostedDate					DATETIME NULL
		,dtmUnpostedDate				DATETIME NULL 		
		,intSourceId					INT NULL 
		,intSourceTransactionTypeId		INT NULL 
	)

	CREATE TABLE expected_tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentDetailId	INT NULL 
		,intInventoryAdjustmentId		INT NULL 
		,intSubLocationId				INT NULL 
		,intStorageLocationId			INT NULL 
		,intItemId						INT NULL
		,intNewItemId					INT NULL
		,intLotId						INT NULL
		,intNewLotId					INT NULL
		,strNewLotNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblQuantity					NUMERIC(18, 6) NULL 
		,dblNewQuantity					NUMERIC(18, 6) NULL 
		,dblNewSplitLotQuantity			NUMERIC(18, 6) NULL 
		,dblAdjustByQuantity			NUMERIC(18, 6) NULL 
		,intItemUOMId					INT NULL
		,intNewItemUOMId				INT NULL
		,intWeightUOMId					INT NULL
		,intNewWeightUOMId				INT NULL
		,dblWeight						NUMERIC(18,6) NULL 
		,dblNewWeight					NUMERIC(18, 6) NULL 
		,dblWeightPerQty				NUMERIC(38,20) NULL 
		,dblNewWeightPerQty				NUMERIC(38,20) NULL 
		,dtmExpiryDate					DATETIME NULL
		,dtmNewExpiryDate				DATETIME NULL
		,intLotStatusId					INT NULL
		,intNewLotStatusId				INT NULL
		,dblCost						NUMERIC(38,20) NULL 
		,dblNewCost						NUMERIC(38,20) NULL 
		,intNewLocationId				INT NULL
		,intNewSubLocationId			INT NULL
		,intNewStorageLocationId		INT NULL
		,dblLineTotal					NUMERIC(38,20) NULL 
		,intSort						INT NULL
		,intConcurrencyId				INT NULL 
	)

	CREATE TABLE actual_tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentDetailId	INT NULL 
		,intInventoryAdjustmentId		INT NULL 
		,intSubLocationId				INT NULL 
		,intStorageLocationId			INT NULL 
		,intItemId						INT NULL
		,intNewItemId					INT NULL
		,intLotId						INT NULL
		,intNewLotId					INT NULL
		,strNewLotNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblQuantity					NUMERIC(18, 6) NULL 
		,dblNewQuantity					NUMERIC(18, 6) NULL 
		,dblNewSplitLotQuantity			NUMERIC(18, 6) NULL 
		,dblAdjustByQuantity			NUMERIC(18, 6) NULL 
		,intItemUOMId					INT NULL
		,intNewItemUOMId				INT NULL
		,intWeightUOMId					INT NULL
		,intNewWeightUOMId				INT NULL
		,dblWeight						NUMERIC(18,6) NULL 
		,dblNewWeight					NUMERIC(18, 6) NULL 
		,dblWeightPerQty				NUMERIC(38,20) NULL 
		,dblNewWeightPerQty				NUMERIC(38,20) NULL 
		,dtmExpiryDate					DATETIME NULL
		,dtmNewExpiryDate				DATETIME NULL
		,intLotStatusId					INT NULL
		,intNewLotStatusId				INT NULL
		,dblCost						NUMERIC(38,20) NULL 
		,dblNewCost						NUMERIC(38,20) NULL 
		,intNewLocationId				INT NULL
		,intNewSubLocationId			INT NULL
		,intNewStorageLocationId		INT NULL
		,dblLineTotal					NUMERIC(38,20) NULL 
		,intSort						INT NULL
		,intConcurrencyId				INT NULL 
	)

	CREATE TABLE expected_tblICLot (
		intLotId					INT NULL 
		,intItemId					INT NULL
		,intLocationId				INT NULL
		,intItemLocationId			INT NULL
		,intItemUOMId				INT NULL			
		,strLotNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL
		,intSubLocationId			INT NULL
		,intStorageLocationId		INT NULL
		,dblQty						NUMERIC(18,6) NULL		
		,dblLastCost				NUMERIC(18,6) NULL		
		,dtmExpiryDate				DATETIME NULL
		,strLotAlias				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,intLotStatusId				INT NULL 
		,intParentLotId				INT NULL
		,intSplitFromLotId			INT NULL
		,dblWeight					NUMERIC(18,6) NULL
		,intWeightUOMId				INT NULL
		,dblWeightPerQty			NUMERIC(38,20) NULL
		,intOriginId				INT NULL
		,strBOLNo					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,strVessel					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 		
		,strReceiptNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strMarkings				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
		,stres						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
		,intEntityVendorId			INT NULL		
		,strVendorLotNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,intVendorLocationId		INT NULL
		,strVendorLocation			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,strContractNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,dtmManufacturedDate		DATETIME NULL
		,ysnReleasedToWarehouse		BIT 
		,ysnProduced				BIT 
		,dtmDateCreated				DATETIME NULL
		,intCreatedEntityId			INT NULL
		,intConcurrencyId			INT NULL 
	)

	CREATE TABLE actual_tblICLot (
		intLotId					INT NULL 
		,intItemId					INT NULL
		,intLocationId				INT NULL
		,intItemLocationId			INT NULL
		,intItemUOMId				INT NULL			
		,strLotNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL
		,intSubLocationId			INT NULL
		,intStorageLocationId		INT NULL
		,dblQty						NUMERIC(18,6) NULL		
		,dblLastCost				NUMERIC(18,6) NULL		
		,dtmExpiryDate				DATETIME NULL
		,strLotAlias				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,intLotStatusId				INT NULL 
		,intParentLotId				INT NULL
		,intSplitFromLotId			INT NULL
		,dblWeight					NUMERIC(18,6) NULL
		,intWeightUOMId				INT NULL
		,dblWeightPerQty			NUMERIC(38,20) NULL
		,intOriginId				INT NULL
		,strBOLNo					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,strVessel					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 		
		,strReceiptNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strMarkings				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
		,stres						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
		,intEntityVendorId			INT NULL		
		,strVendorLotNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,intVendorLocationId		INT NULL
		,strVendorLocation			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
		,strContractNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
		,dtmManufacturedDate		DATETIME NULL
		,ysnReleasedToWarehouse		BIT 
		,ysnProduced				BIT 
		,dtmDateCreated				DATETIME NULL
		,intCreatedEntityId			INT NULL
		,intConcurrencyId			INT NULL 
	)
END