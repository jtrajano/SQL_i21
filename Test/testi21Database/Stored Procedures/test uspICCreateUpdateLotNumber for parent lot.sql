﻿CREATE PROCEDURE [testi21Database].[test uspICCreateUpdateLotNumber for parent lot]
AS
BEGIN
	-- Declare the variables for grains (item)
	DECLARE @ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7			

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3

	-- Declare the variables for the Item UOM Ids
	DECLARE @ManualLotGrains_BushelUOMId AS INT = 6
			,@SerializedLotGrains_BushelUOMId AS INT = 7			
			,@ManualLotGrains_PoundUOMId AS INT = 13
			,@SerializedLotGrains_PoundUOMId AS INT = 14

	-- Declare Item-Locations
	DECLARE @ManualLotGrains_DefaultLocation AS INT = 16
			,@SerializedLotGrains_DefaultLocation AS INT = 17

	DECLARE @SubLocationId AS INT = 90
	DECLARE @StorageLocationId AS INT = 299

	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]

		DECLARE @Items AS ItemLotTableType
		DECLARE @intEntityUserSecurityId AS INT 
		DECLARE @intLotStatusId AS INT

		DECLARE	@intLotId					AS INT 
				,@strLotNumber				AS NVARCHAR(50) 
				,@strLotAlias				AS NVARCHAR(50) 
				,@intItemId					AS INT 
				,@intItemLocationId			AS INT 
				,@intSubLocationId			AS INT 
				,@intStorageLocationId		AS INT
				,@dblQty					AS NUMERIC(18,6) 
				,@intItemUOMId				AS INT 
				,@dblWeight					AS NUMERIC(18,6)
				,@intWeightUOMId			AS INT
				,@dblWeightPerQty			AS NUMERIC(38, 20)
				,@dtmExpiryDate				AS DATETIME
				,@dtmManufacturedDate		AS DATETIME
				,@intOriginId				AS INT
				,@intGradeId				AS INT
				,@strBOLNo					AS NVARCHAR(100)
				,@strVessel					AS NVARCHAR(100)
				,@strReceiptNumber			AS NVARCHAR(50)
				,@strMarkings				AS NVARCHAR(MAX)
				,@strNotes					AS NVARCHAR(MAX)
				,@intEntityVendorId			AS INT 
				,@strVendorLotNo			AS NVARCHAR(50)
				,@strGarden					AS NVARCHAR(100)
				,@strContractNo				AS NVARCHAR(50)
				,@ysnReleasedToWarehouse	AS BIT
				,@ysnProduced				AS BIT 
				,@intDetailId				AS INT 
				,@dblGrossWeight			AS NUMERIC(18,6)
				,@intParentLotId			AS INT 
				,@strParentLotNumber		AS NVARCHAR(50) 
				,@strParentLotAlias			AS NVARCHAR(50) 


		CREATE TABLE expected (
			[intLotId]					INT 
			,[intItemId]				INT
			,[intLocationId]			INT
			,[intItemLocationId]		INT
			,[intItemUOMId]				INT
			,[strLotNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intSubLocationId]			INT 
			,[intStorageLocationId]		INT 
			,[dblQty]					NUMERIC(18,6) 
			,[dblLastCost]				NUMERIC(18,6) 
			,[dtmExpiryDate]			DATETIME 
			,[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[intLotStatusId]			INT 
			,[intParentLotId]			INT 
			,[intSplitFromLotId]		INT 
			,[dblWeight]				NUMERIC(18,6) 
			,[intWeightUOMId]			INT 
			,[dblWeightPerQty]			NUMERIC(38,20) 
			,[intOriginId]				INT 
			,[intGradeId]				INT 
			,[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strVessel]				NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[strMarkings]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			,[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
			,[intEntityVendorId]		INT 
			,[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[strGarden]				NVARCHAR(100) COLLATE Latin1_General_CI_AS 
			,[strContractNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,[dtmManufacturedDate]		DATETIME 
			,[ysnReleasedToWarehouse]	BIT 
			,[ysnProduced]				BIT 
			,[dtmDateCreated]			DATETIME 
			,[intCreatedEntityId]		INT 
			,[dblGrossWeight]			NUMERIC(18,6)
		)

		SELECT * 
		INTO actual 
		FROM expected

		SELECT	@intLotId					= NULL 
				,@strLotNumber				= 'LOT-12345'
				,@strLotAlias				= 'ALIAS 1'
				,@intItemId					= @ManualLotGrains
				,@intItemLocationId			= @ManualLotGrains_DefaultLocation
				,@intSubLocationId			= @SubLocationId
				,@intStorageLocationId		= @StorageLocationId
				,@dblQty					= 100
				,@intItemUOMId				= @ManualLotGrains_BushelUOMId
				,@dblWeight					= 250
				,@intWeightUOMId			= @ManualLotGrains_PoundUOMId
				,@dblWeightPerQty			= @dblWeight / @dblQty
				,@dtmExpiryDate				= '02/14/2024'
				,@dtmManufacturedDate		= '02/14/2014'
				,@intOriginId				= 1
				,@intGradeId				= 2
				,@strBOLNo					= 'Bill of Lading'
				,@strVessel					= 'Maesrk'
				,@strReceiptNumber			= 'INVRPT-10001'
				,@strMarkings				= 'Markings'
				,@strNotes					= 'Add notes for a lot number'
				,@intEntityVendorId				= 1
				,@strVendorLotNo			= 'Vendor lot number is 1abc-049843'
				,@strGarden					= 'Garden'
				,@strContractNo				= 'Contract No.'
				,@ysnReleasedToWarehouse	= 0
				,@ysnProduced				= 0
				,@intDetailId				= 12
				,@dblGrossWeight			= 300
				,@strParentLotNumber		= 'PARENT-LOT-1'
				,@strParentLotAlias			= NULL 


		-- Setup the transaction data. 
		INSERT INTO @Items (
			intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,intItemLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dtmExpiryDate
			,dtmManufacturedDate
			,intOriginId
			,intGradeId
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intEntityVendorId
			,strVendorLotNo
			,strGarden
			,intDetailId
			,dblGrossWeight
			,strParentLotNumber
			,strParentLotAlias	
	)
	SELECT	intLotId				= @intLotId
			,strLotNumber			= @strLotNumber
			,strLotAlias			= @strLotAlias
			,intItemId				= @intItemId
			,intItemLocationId		= @intItemLocationId
			,intSubLocationId		= @intSubLocationId
			,intStorageLocationId	= @intStorageLocationId
			,dblQty					= @dblQty
			,intItemUOMId			= @intItemUOMId
			,dblWeight				= @dblWeight
			,intWeightUOMId			= @intWeightUOMId
			,dtmExpiryDate			= @dtmExpiryDate
			,dtmManufacturedDate	= @dtmManufacturedDate
			,intOriginId			= @intOriginId
			,intGradeId				= @intGradeId
			,strBOLNo				= @strBOLNo
			,strVessel				= @strVessel
			,strReceiptNumber		= @strReceiptNumber
			,strMarkings			= @strMarkings
			,strNotes				= @strNotes
			,intEntityVendorId		= @intEntityVendorId
			,strVendorLotNo			= @strVendorLotNo
			,strGarden				= @strGarden
			,intDetailId			= @intDetailId
			,dblGrossWeight			= @dblGrossWeight
			,strParentLotNumber		= @strParentLotNumber
			,strParentLotAlias		= @strParentLotAlias



		-- Setup the expected data
		INSERT INTO expected (
				intLotId
				,strLotNumber
				,strLotAlias
				,intItemId
				,intItemLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblQty
				,intItemUOMId
				,dblWeight
				,intWeightUOMId
				,dblWeightPerQty
				,dtmExpiryDate
				,dtmManufacturedDate
				,intOriginId
				,intGradeId
				,strBOLNo
				,strVessel
				,strReceiptNumber
				,strMarkings
				,strNotes
				,intEntityVendorId
				,strVendorLotNo
				,strGarden
				,dblGrossWeight
				,intCreatedEntityId
				,intParentLotId
		)
		SELECT	intLotId				= 1
				,strLotNumber			= @strLotNumber
				,strLotAlias			= @strLotAlias
				,intItemId				= @intItemId
				,intItemLocationId		= @intItemLocationId
				,intSubLocationId		= @intSubLocationId
				,intStorageLocationId	= @intStorageLocationId
				,dblQty					= 0
				,intItemUOMId			= @intItemUOMId
				,dblWeight				= 0
				,intWeightUOMId			= @intWeightUOMId
				,dblWeightPerQty		= @dblWeightPerQty
				,dtmExpiryDate			= @dtmExpiryDate
				,dtmManufacturedDate	= @dtmManufacturedDate
				,intOriginId			= @intOriginId
				,intGradeId				= @intGradeId
				,strBOLNo				= @strBOLNo
				,strVessel				= @strVessel
				,strReceiptNumber		= @strReceiptNumber
				,strMarkings			= @strMarkings
				,strNotes				= @strNotes
				,intEntityVendorId		= @intEntityVendorId
				,strVendorLotNo			= @strVendorLotNo
				,strGarden				= @strGarden
				,dblGrossWeight			= @dblGrossWeight
				,intCreatedEntityId		= @intEntityUserSecurityId
				,intParentLotId			= NULL 
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICCreateUpdateLotNumber
			@Items
			,@intEntityUserSecurityId
			,@intLotStatusId
	END 

	-- Get the parent lot id. 
	BEGIN 
		SELECT	@intParentLotId = ParentLot.intParentLotId 
		FROM	dbo.tblICParentLot ParentLot
		WHERE	ParentLot.strParentLotNumber = @strParentLotNumber

		UPDATE	expected
		SET		intParentLotId = @intParentLotId
	END 

	-- Assert
	BEGIN 
		INSERT INTO actual (
				intLotId
				,strLotNumber
				,strLotAlias
				,intItemId
				,intItemLocationId
				,intSubLocationId
				,intStorageLocationId
				,dblQty
				,intItemUOMId
				,dblWeight
				,intWeightUOMId
				,dblWeightPerQty
				,dtmExpiryDate
				,dtmManufacturedDate
				,intOriginId
				,intGradeId 
				,strBOLNo
				,strVessel
				,strReceiptNumber
				,strMarkings
				,strNotes
				,intEntityVendorId
				,strVendorLotNo
				,strGarden
				,dblGrossWeight
				,intCreatedEntityId
				,intParentLotId
		)
		SELECT	intLotId				
				,strLotNumber			
				,strLotAlias			
				,intItemId				
				,intItemLocationId		
				,intSubLocationId		
				,intStorageLocationId	
				,dblQty					
				,intItemUOMId			
				,dblWeight				
				,intWeightUOMId
				,dblWeightPerQty			
				,dtmExpiryDate			
				,dtmManufacturedDate	
				,intOriginId
				,intGradeId 			
				,strBOLNo				
				,strVessel				
				,strReceiptNumber		
				,strMarkings			
				,strNotes				
				,intEntityVendorId			
				,strVendorLotNo			
				,strGarden
				,dblGrossWeight
				,intCreatedEntityId
				,intParentLotId
		FROM dbo.tblICLot 

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE expected
END
