CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransfer for one item and shipment NOT required]
AS
BEGIN

	-- Item Ids
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@InvalidItem AS INT = -1
			 
	-- Company Location Ids
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1

	-- Declare the variables for sub-locations
	DECLARE @Raw_Materials_SubLocation_DefaultLocation AS INT = 1
			,@FinishedGoods_SubLocation_DefaultLocation AS INT = 2
			,@Raw_Materials_SubLocation_NewHaven AS INT = 3
			,@FinishedGoods_SubLocation_NewHaven AS INT = 4
			,@Raw_Materials_SubLocation_BetterHaven AS INT = 5
			,@FinishedGoods_SubLocation_BetterHaven AS INT = 6

	-- Declare the variables for storage locations
	DECLARE @StorageSilo_RM_DL AS INT = 1
			,@StorageSilo_FG_DL AS INT = 2
			,@StorageSilo_RM_NH AS INT = 3
			,@StorageSilo_FG_NH AS INT = 4
			,@StorageSilo_RM_BH AS INT = 5
			,@StorageSilo_FG_BH AS INT = 6

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

	DECLARE	@UOM_Bushel AS INT = 1
			,@UOM_Pound AS INT = 2
			,@UOM_Kg AS INT = 3
			,@UOM_25KgBag AS INT = 4
			,@UOM_10LbBag AS INT = 5
			,@UOM_Ton AS INT = 6

	DECLARE @BushelUnitQty AS NUMERIC(18,6) = 1
			,@PoundUnitQty AS NUMERIC(18,6) = 1
			,@KgUnitQty AS NUMERIC(18,6) = 2.20462
			,@25KgBagUnitQty AS NUMERIC(18,6) = 55.1155
			,@10LbBagUnitQty AS NUMERIC(18,6) = 10
			,@TonUnitQty AS NUMERIC(18,6) = 2204.62
	
	DECLARE @WetGrains_BushelUOM AS INT = 1,		@StickyGrains_BushelUOM AS INT = 2,		@PremiumGrains_BushelUOM AS INT = 3,
			@ColdGrains_BushelUOM AS INT = 4,		@HotGrains_BushelUOM AS INT = 5,		@ManualGrains_BushelUOM AS INT = 6,
			@SerializedGrains_BushelUOM AS INT = 7	

	DECLARE @WetGrains_PoundUOM AS INT = 8,			@StickyGrains_PoundUOM AS INT = 9,		@PremiumGrains_PoundUOM AS INT = 10,
			@ColdGrains_PoundUOM AS INT = 11,		@HotGrains_PoundUOM AS INT = 12,		@ManualGrains_PoundUOM AS INT = 13,
			@SerializedGrains_PoundUOM AS INT = 14	

	DECLARE @WetGrains_KgUOM AS INT = 15,			@StickyGrains_KgUOM AS INT = 16,		@PremiumGrains_KgUOM AS INT = 17,
			@ColdGrains_KgUOM AS INT = 18,			@HotGrains_KgUOM AS INT = 19,			@ManualGrains_KgUOM AS INT = 20,
			@SerializedGrains_KgUOM AS INT = 21

	DECLARE @WetGrains_25KgBagUOM AS INT = 22,		@StickyGrains_25KgBagUOM AS INT = 23,	@PremiumGrains_25KgBagUOM AS INT = 24,
			@ColdGrains_25KgBagUOM AS INT = 25,		@HotGrains_25KgBagUOM AS INT = 26,		@ManualGrains_25KgBagUOM AS INT = 27,
			@SerializedGrains_25KgBagUOM AS INT = 28

	DECLARE @WetGrains_10LbBagUOM AS INT = 29,		@StickyGrains_10LbBagUOM AS INT = 30,	@PremiumGrains_10LbBagUOM AS INT = 31,
			@ColdGrains_10LbBagUOM AS INT = 32,		@HotGrains_10LbBagUOM AS INT = 33,		@ManualGrains_10LbBagUOM AS INT = 34,
			@SerializedGrains_10LbBagUOM AS INT = 35

	DECLARE @WetGrains_TonUOM AS INT = 36,			@StickyGrains_TonUOM AS INT = 37,		@PremiumGrains_TonUOM AS INT = 38,
			@ColdGrains_TonUOM AS INT = 39,			@HotGrains_TonUOM AS INT = 40,			@ManualGrains_TonUOM AS INT = 41,
			@SerializedGrains_TonUOM AS INT = 42

	-- Declare the account ids
	DECLARE @Inventory_Default AS INT = 1000
	DECLARE @CostOfGoods_Default AS INT = 2000
	DECLARE @APClearing_Default AS INT = 3000
	DECLARE @WriteOffSold_Default AS INT = 4000
	DECLARE @RevalueSold_Default AS INT = 5000 
	DECLARE @AutoNegative_Default AS INT = 6000
	DECLARE @InventoryInTransit_Default AS INT = 7000
	DECLARE @AccountReceivable_Default AS INT = 8000
	DECLARE @InventoryAdjustment_Default AS INT = 9000

	DECLARE @Inventory_NewHaven AS INT = 1001
	DECLARE @CostOfGoods_NewHaven AS INT = 2001
	DECLARE @APClearing_NewHaven AS INT = 3001
	DECLARE @WriteOffSold_NewHaven AS INT = 4001
	DECLARE @RevalueSold_NewHaven AS INT = 5001
	DECLARE @AutoNegative_NewHaven AS INT = 6001
	DECLARE @InventoryInTransit_NewHaven AS INT = 7001
	DECLARE @AccountReceivable_NewHaven AS INT = 8001
	DECLARE @InventoryAdjustment_NewHaven AS INT = 9001

	DECLARE @Inventory_BetterHaven AS INT = 1002
	DECLARE @CostOfGoods_BetterHaven AS INT = 2002
	DECLARE @APClearing_BetterHaven AS INT = 3002
	DECLARE @WriteOffSold_BetterHaven AS INT = 4002
	DECLARE @RevalueSold_BetterHaven AS INT = 5002
	DECLARE @AutoNegative_BetterHaven AS INT = 6002
	DECLARE @InventoryInTransit_BetterHaven AS INT = 7002
	DECLARE @AccountReceivable_BetterHaven AS INT = 8002
	DECLARE @InventoryAdjustment_BetterHaven AS INT = 9002

	-- Lot Numbers
	DECLARE @ManualLotGrains_Lot_100001 AS INT = 1
			,@ManualLotGrains_Lot_100002 AS INT = 2
			,@ManualLotGrains_Lot_100003 AS INT = 3

	-- Lot Status
	DECLARE @LOT_STATUS_Active AS INT = 1
			,@LOT_STATUS_On_Hold AS INT = 2
			,@LOT_STATUS_Quarantine AS INT = 3

	DECLARE @Ship_Via_Truck AS NVARCHAR(50) = 'Truck'
			,@Ship_Via_Truck_Id AS INT = 1

	DECLARE	-- Inventory transfer transaction types. 
			@INVENTORY_TRANSFER_TYPE AS INT = 12
			,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 13

			-- Transfer types. 
			,@TRANSFER_TYPE_LOCATION_TO_LOCATION AS NVARCHAR(50) = 'Location to Location'
			,@TRANSFER_TYPE_STORAGE_TO_STORAGE AS NVARCHAR(50) = 'Storage to Storage'

			,@STATUS_OPEN AS INT = 1
			,@STATUS_PARTIAL AS INT = 2
			,@STATUS_CLOSED AS INT = 3
			,@STATUS_SHORT_CLOSED AS INT = 4

	-- Arrange
	BEGIN 
		EXEC testi21Database.[Fake data for inventory transfer table];	
	END

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryTransfer
			@ysnPost = 1
			,@ysnRecap = 0
			,@strTransactionId = 'INVTRN-2'
			,@intUserId = 1
			,@intEntityId = 1
	END 

	-- Assert
	BEGIN 
		-- No exception 
		EXEC tSQLt.ExpectNoException;

		-- Inventory transfer is marked as posted. 
		DECLARE @ysnPosted AS BIT 
		SELECT @ysnPosted = ysnPosted FROM dbo.tblICInventoryTransfer WHERE strTransferNo = 'INVTRN-2'

		EXEC tSQLt.AssertEquals @ysnPosted, 1

		-- The G/L entries are correct 
		CREATE TABLE expected_tblGLDetail (
			intAccountId INT
			,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)

		CREATE TABLE actual_tblGLDetail (
			intAccountId INT
			,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
			,dblDebit NUMERIC(18,6)
			,dblCredit NUMERIC(18,6)
		)

		INSERT INTO expected_tblGLDetail (
			intAccountId
			,strBatchId
			,strTransactionId
			,dblDebit
			,dblCredit
		)
		SELECT 
			intAccountId		= @Inventory_Default
			,strBatchId			= 'BATCH-1'
			,strTransactionId	= 'INVTRN-2'
			,dblDebit			= 0
			,dblCredit			= (100 * @25KgBagUnitQty * ROUND(2.50 / @25KgBagUnitQty, 6) ) 
		UNION ALL 
		SELECT 
			intAccountId		= @Inventory_NewHaven
			,strBatchId			= 'BATCH-1'
			,strTransactionId	= 'INVTRN-2'
			,dblDebit			= (100 * @25KgBagUnitQty * ROUND(2.50 / @25KgBagUnitQty, 6)) 
			,dblCredit			= 0

		INSERT INTO actual_tblGLDetail (
			intAccountId
			,strBatchId
			,strTransactionId
			,dblDebit
			,dblCredit
		)
		SELECT 
			intAccountId		
			,strBatchId			
			,strTransactionId	
			,dblDebit			
			,dblCredit			
		FROM dbo.tblGLDetail 
		WHERE	strTransactionId = 'INVTRN-2'

		EXEC tSQLt.AssertEqualsTable 'expected_tblGLDetail', 'actual_tblGLDetail';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('expected_tblGLDetail') IS NOT NULL 
		DROP TABLE expected_tblGLDetail

	IF OBJECT_ID('actual_tblGLDetail') IS NOT NULL 
		DROP TABLE dbo.actual_tblGLDetail
END 
