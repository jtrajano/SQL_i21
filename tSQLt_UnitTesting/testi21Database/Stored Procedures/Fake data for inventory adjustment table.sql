CREATE PROCEDURE [testi21Database].[Fake data for inventory adjustment table]
AS
BEGIN
	EXEC [testi21Database].[Fake inventory items];
	EXEC testi21Database.[Fake open fiscal year and accounting periods]

	EXEC tSQLt.FakeTable 'dbo.tblICInventoryAdjustment', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryAdjustmentDetail', @Identity = 1;	

	EXEC tSQLt.ApplyConstraint 'dbo.tblICLot', 'UN_tblICLot';		

	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@InvalidItem AS INT = -1

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5
			,@ManualLotGrains_BushelUOMId AS INT = 6
			,@SerializedLotGrains_BushelUOMId AS INT = 7

			,@WetGrains_PoundUOMId AS INT = 8
			,@StickyGrains_PoundUOMId AS INT = 9
			,@PremiumGrains_PoundUOMId AS INT = 10
			,@ColdGrains_PoundUOMId AS INT = 11
			,@HotGrains_PoundUOMId AS INT = 12
			,@ManualLotGrains_PoundUOMId AS INT = 13
			,@SerializedLotGrains_PoundUOMId AS INT = 14

	-- Declare Item-Locations
	DECLARE @WetGrains_DefaultLocation AS INT = 1
			,@StickyGrains_DefaultLocation AS INT = 2
			,@PremiumGrains_DefaultLocation AS INT = 3
			,@ColdGrains_DefaultLocation AS INT = 4
			,@HotGrains_DefaultLocation AS INT = 5

			,@WetGrains_NewHaven AS INT = 6
			,@StickyGrains_NewHaven AS INT = 7
			,@PremiumGrains_NewHaven AS INT = 8
			,@ColdGrains_NewHaven AS INT = 9
			,@HotGrains_NewHaven AS INT = 10

			,@WetGrains_BetterHaven AS INT = 11
			,@StickyGrains_BetterHaven AS INT = 12
			,@PremiumGrains_BetterHaven AS INT = 13
			,@ColdGrains_BetterHaven AS INT = 14
			,@HotGrains_BetterHaven AS INT = 15

			,@ManualLotGrains_DefaultLocation AS INT = 16
			,@SerializedLotGrains_DefaultLocation AS INT = 17

	-- Create mock data for the starting number 
	EXEC tSQLt.FakeTable 'dbo.tblSMStartingNumber';	
	INSERT	[dbo].[tblSMStartingNumber] (
			[intStartingNumberId] 
			,[strTransactionType]
			,[strPrefix]
			,[intNumber]
			,[strModule]
			,[ysnEnable]
			,[intConcurrencyId]
	)
	SELECT	[intStartingNumberId]	= 24
			,[strTransactionType]	= N'Lot Number'
			,[strPrefix]			= N'LOT-'
			,[intNumber]			= 10000
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	UNION ALL
	SELECT	[intStartingNumberId]	= 3
			,[strTransactionType]	= N'Batch Post'
			,[strPrefix]			= N'BATCH-'
			,[intNumber]			= 1
			,[strModule]			= N'Posting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
		
	-- TODO: 
	-- The following are the scenarios you can do within Inventory adjustment:
	-- 1. Add stock from zero. This includes both Lot tracked and non-Lot Items. 
	-- 2. Reduce stock from zero. This includes both Lot tracked and non-Lot Items. 
	-- 3. Add stock from an existing stock . This includes both Lot tracked and non-Lot Items. 
	-- 4. Reduce stock from an existing stock. This includes both Lot tracked and non-Lot Items. 
	-- 5. Change status of an existing Lot
	-- 6. Change the expiry date of an existing lot. 
	-- 7. Change the value/cost of an existing stock. 

	-- Constant for Adjustment Types
	DECLARE @ADJUSTMENT_TYPE_QTY_CHANGE AS INT = 1
			,@ADJUSTMENT_TYPE_UOM_CHANGE AS INT = 2
			,@ADJUSTMENT_TYPE_ITEM_CHANGE AS INT = 3
			,@ADJUSTMENT_TYPE_LOT_STATUS_CHANGE AS INT = 4
			,@ADJUSTMENT_TYPE_LOT_ID_CHANGE AS INT = 5
			,@ADJUSTMENT_TYPE_EXPIRY_DATE_CHANGE AS INT = 6

	INSERT INTO dbo.tblICInventoryAdjustment (
			intLocationId 
			,dtmAdjustmentDate       
			,intAdjustmentType 
			,strAdjustmentNo                                    
			,strDescription                                                                                       
			,intSort     
			,ysnPosted 
			,intEntityId 
			,intConcurrencyId	
	)
	SELECT 	intLocationId		= @NewHaven
			,dtmAdjustmentDate  = GETDATE()     
			,intAdjustmentType	= @ADJUSTMENT_TYPE_QTY_CHANGE 
			,strAdjustmentNo    = 'ADJ-1'                              
			,strDescription     = 'Header only record'                                                                          
			,intSort			= 1
			,ysnPosted			= 0
			,intEntityId		= 1
			,intConcurrencyId	= 1
END 
