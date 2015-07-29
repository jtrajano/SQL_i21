CREATE PROCEDURE [testi21Database].[test uspICAllocateInventoryReceiptOtherCharges for test case 2]
AS
/*
	Test Case 1:
	-----------------------------------------
	1. One other charge. 
		1. Cost method is: 				Unit
		2. Cost is allocated by:		Cost
		3. Inventory cost is:			Yes
		4. Cost billed by:				Vendor 
		5. With contract:				None
		 	
	2. Two line items. 
*/

-- Variables from [testi21Database].[Fake inventory items]
BEGIN 
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@CornCommodity AS INT = 8
			,@OtherCharges AS INT = 9
			,@SurchargeOtherCharges AS INT = 10
			,@SurchargeOnSurcharge AS INT = 11
			,@SurchargeOnSurchargeOnSurcharge AS INT = 12
			,@InvalidItem AS INT = -1

	-- Declare the variables for location
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

	DECLARE @Corn_BushelUOM AS INT = 43,			@Corn_PoundUOM AS INT = 44,				@Corn_KgUOM AS INT = 45, 
			@Corn_25KgBagUOM AS INT = 46,			@Corn_10LbBagUOM AS INT = 47,			@Corn_TonUOM AS INT = 48

	DECLARE @OtherCharges_PoundUOM AS INT = 49
	DECLARE @SurchargeOtherCharges_PoundUOM AS INT = 50
	DECLARE @SurchargeOnSurcharge_PoundUOM AS INT = 51
	DECLARE @SurchargeOnSurchargeOnSurcharge_PoundUOM AS INT = 52

	-- Other charges constant variables. 
	DECLARE @COST_METHOD_PER_Unit AS NVARCHAR(50) = 'Per Unit'
			,@COST_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
			,@COST_METHOD_Amount AS NVARCHAR(50) = 'Amount'

			,@INVENTORY_COST_Yes AS BIT = 1
			,@INVENTORY_COST_No AS BIT = 0

			,@COST_BILLED_BY_Vendor AS NVARCHAR(50) = 'Vendor'
			,@COST_BILLED_BY_ThirdParty AS NVARCHAR(50) = 'Third Party'
			,@COST_BILLED_BY_None AS NVARCHAR(50) = 'None'

			,@ALLOCATE_COST_BY_Unit AS NVARCHAR(50) = 'Unit'
			,@ALLOCATE_COST_BY_Stock_Unit AS NVARCHAR(50) = 'Stock Unit'
			,@ALLOCATE_COST_BY_Weight AS NVARCHAR(50) = 'Weight'
			,@ALLOCATE_COST_BY_Cost AS NVARCHAR(50) = 'Cost'

	DECLARE -- Receipt Types
			@RECEIPT_TYPE_PurchaseContract AS NVARCHAR(50) = 'Purchase Contract'
			,@RECEIPT_TYPE_PurchaseOrder AS NVARCHAR(50) = 'Purchase Order'
			,@RECEIPT_TYPE_TransferOrder AS NVARCHAR(50) = 'Transfer Order'
			,@RECEIPT_TYPE_Direct AS NVARCHAR(50) = 'Direct'

			-- Source Types
			,@SOURCE_TYPE_None AS INT = 1
			,@SOURCE_TYPE_Scale AS INT = 2
			,@SOURCE_TYPE_InboundShipment AS INT = 3

			-- Ownership Types
			,@OWNERSHIP_TYPE_Own AS INT = 1
			,@OWNERSHIP_TYPE_Storage AS INT = 2
			,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
			,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4
END 

BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for inventory receipt table];

		CREATE TABLE expected (
			[intInventoryReceiptId] INT
			,[intInventoryReceiptItemId] INT
			,[intEntityVendorId] INT
			,[dblAmount] NUMERIC(38, 20)
			,[strCostBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,[ysnInventoryCost] BIT
		)

		CREATE TABLE actual (
			[intInventoryReceiptId] INT
			,[intInventoryReceiptItemId] INT
			,[intEntityVendorId] INT
			,[dblAmount] NUMERIC(38, 20)
			,[strCostBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,[ysnInventoryCost] BIT
		)
	END 

	-- Act
	BEGIN 
		DECLARE @intInventoryReceiptId AS INT = 15 -- 'INVRCPT-XXXX15'
		
		-- Modify the other charges in the transaction to use Allocate by Units. 
		UPDATE dbo.tblICInventoryReceiptCharge
		SET strAllocateCostBy = @ALLOCATE_COST_BY_Unit
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		-- Calculate the other charges. 
		EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
			@intInventoryReceiptId

		-- Calculate the surcharges
		EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
			@intInventoryReceiptId

		-- Distribute or allocate the calculate other charges to the items. 
		EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
			@intInventoryReceiptId
	END 

	-- Setup the expected data
	BEGIN 
		INSERT INTO expected (
				[intInventoryReceiptId]
				,[intInventoryReceiptItemId]
				,[intEntityVendorId]
				,[dblAmount]
				,[strCostBilledBy]
				,[ysnInventoryCost]
		)
		SELECT	[intInventoryReceiptId]			= @intInventoryReceiptId
				,[intInventoryReceiptItemId]	= 35
				,[intEntityVendorId]			= NULL 
				,[dblAmount]					= 951.925000
				,[strCostBilledBy]				= @COST_BILLED_BY_None
				,[ysnInventoryCost]				= @INVENTORY_COST_No
		UNION ALL 
		SELECT	[intInventoryReceiptId]			= @intInventoryReceiptId
				,[intInventoryReceiptItemId]	= 36
				,[intEntityVendorId]			= NULL 
				,[dblAmount]					= 1903.850000
				,[strCostBilledBy]				= @COST_BILLED_BY_None
				,[ysnInventoryCost]				= @INVENTORY_COST_No
	END

	-- Assert
	BEGIN 
		INSERT INTO actual (
				[intInventoryReceiptId]
				,[intInventoryReceiptItemId]
				,[intEntityVendorId]
				,[dblAmount]
				,[strCostBilledBy]
				,[ysnInventoryCost]
		)
		SELECT 
				[intInventoryReceiptId]
				,[intInventoryReceiptItemId]
				,[intEntityVendorId]
				,[dblAmount]
				,[strCostBilledBy]
				,[ysnInventoryCost]
		FROM dbo.tblICInventoryReceiptItemAllocatedCharge	

		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';

	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END