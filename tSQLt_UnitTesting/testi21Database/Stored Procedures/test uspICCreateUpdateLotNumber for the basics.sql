CREATE PROCEDURE [testi21Database].[test uspICCreateUpdateLotNumber for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake inventory items]

		DECLARE @Items AS ItemLotTableType
		DECLARE @intUserId AS INT 
		DECLARE @intLotStatusId AS INT

		CREATE TABLE expected (
			[intLotId]					INT NOT NULL IDENTITY, 		
			[intItemId]					INT NOT NULL,
			[intLocationId]				INT NOT NULL,
			[intItemLocationId]			INT NOT NULL,
			[intItemUOMId]				INT NOT NULL,			
			[strLotNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intSubLocationId]			INT NULL,
			[intStorageLocationId]		INT NULL,
			[dblQty]					NUMERIC(18,6) DEFAULT ((0)) NOT NULL,		
			[dblLastCost]				NUMERIC(18,6) DEFAULT ((0)) NULL,		
			[dtmExpiryDate]				DATETIME NULL,
			[strLotAlias]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[intLotStatusId]			INT NOT NULL DEFAULT ((1)),
			[intParentLotId]			INT NULL,
			[intSplitFromLotId]			INT NULL,
			[dblWeight]					NUMERIC(18,6) NULL DEFAULT ((0)) ,
			[intWeightUOMId]			INT NULL,
			[dblWeightPerQty]			NUMERIC(18,6) NULL DEFAULT ((0)),
			[intOriginId]				INT NULL,
			[strBOLNo]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
			[strVessel]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 		
			[strReceiptNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[strMarkings]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
			[strNotes]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
			[intVendorId]				INT NULL,		
			[strVendorLotNo]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[intVendorLocationId]		INT NULL, 
			[strVendorLocation]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
			[strContractNo]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[dtmManufacturedDate]		DATETIME NULL,
			[ysnReleasedToWarehouse]	BIT DEFAULT((0)),
			[ysnProduced]				BIT DEFAULT((0)),
			[dtmDateCreated]			DATETIME NULL,
			[intCreatedUserId]			INT NULL,
			[intConcurrencyId]			INT NULL DEFAULT ((1)),		
		)

		SELECT * 
		INTO actual 
		FROM expected
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspICCreateUpdateLotNumber
			@Items
			,@intUserId
			,@intLotStatusId
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END