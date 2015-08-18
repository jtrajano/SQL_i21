﻿CREATE PROCEDURE [testi21Database].[test uspICAddItemReceipt to add a purchase contract type with no contract detail id]
AS
BEGIN
	-- Fake data
	BEGIN 
		EXEC testi21Database.[Fake data for inventory receipt table]

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

				,@CornCommodity_DefaultLocation AS INT = 18
				,@CornCommodity_NewHaven AS INT = 19
				,@CornCommodity_BetterHaven AS INT = 20

				,@ManualLotGrains_NewHaven AS INT = 21
				,@SerializedLotGrains_NewHaven AS INT = 22

				,@OtherCharges_DefaultLocation AS INT = 23
				,@SurchargeOtherCharges_DefaultLocation AS INT = 24
				,@SurchargeOnSurcharge_DefaultLocation AS INT = 25
				,@SurchargeOnSurchargeOnSurcharge_DefaultLocation AS INT = 26

				,@OtherCharges_NewHaven AS INT = 27
				,@SurchargeOtherCharges_NewHaven AS INT = 28
				,@SurchargeOnSurcharge_NewHaven AS INT = 29
				,@SurchargeOnSurchargeOnSurcharge_NewHaven AS INT = 30

				,@OtherCharges_BetterHaven AS INT = 31
				,@SurchargeOtherCharges_BetterHaven AS INT = 32
				,@SurchargeOnSurcharge_BetterHaven AS INT = 33
				,@SurchargeOnSurchargeOnSurcharge_BetterHaven AS INT = 34

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

	-- Setup the expected and actual table
	BEGIN 
		CREATE TABLE expected (
			intSourceId INT
			,intInventoryReceiptId INT 	
		)

		CREATE TABLE actual	 (
			intSourceId INT
			,intInventoryReceiptId INT 	
		)

		CREATE TABLE expected_tblICInventoryReceiptItem (
			intLineNo INT 
		)

		CREATE TABLE actual_tblICInventoryReceiptItem (
			intLineNo INT 
		)
	END 

	-- Arrange 
	BEGIN 
		DECLARE @ReceiptDataToCreate AS ReceiptStagingTable
				,@ReceiptOtherCharges AS ReceiptOtherChargesTableType
				,@intUserId AS INT 
	END 
	
	-- Act 	
	BEGIN 
		INSERT INTO @ReceiptDataToCreate(
				strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,strBillOfLadding
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,dblCost
				,intCurrencyId
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsCustody
				,dblFreightRate
				,intSourceId
				,dblGross
				,dblNet
		)	
		SELECT	strReceiptType		= 'Purchase Contract'
				,intEntityVendorId	= 1
				,intShipFromId		= 2
				,intLocationId		= @Default_Location
				,intItemId			= @ManualLotGrains
				,intItemLocationId	= @ManualLotGrains_DefaultLocation
				,intItemUOMId		= @ManualGrains_KgUOM
				,strBillOfLadding	= '7'
				,intContractHeaderId = NULL 
				,intContractDetailId = NULL 
				,dtmDate			= '09/09/2009'
				,intShipViaId		= 10
				,dblQty				= 11
				,dblCost			= 12
				,intCurrencyId		= 13
				,dblExchangeRate	= 14
				,intLotId			= 15
				,intSubLocationId		= 16
				,intStorageLocationId	= 17
				,ysnIsCustody			= 18
				,dblFreightRate			= 19
				,intSourceId			= 20
				,dblGross				= 21
				,dblNet					= 22


		-- Create the temp table if it does not exists. 
		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
		BEGIN 
			CREATE TABLE #tmpAddItemReceiptResult (
				intSourceId INT
				,intInventoryReceiptId INT
			)
		END 

		EXEC dbo.uspICAddItemReceipt
			@ReceiptDataToCreate
			,@ReceiptOtherCharges
			,@intUserId

	END 

	-- Setup Expected data
	BEGIN 
		INSERT INTO dbo.expected_tblICInventoryReceiptItem(
			intLineNo
		)
		SELECT intLineNo = 0
	END 

	-- Assert
	BEGIN

		DECLARE @strReceiptNumber AS NVARCHAR(50)


		SELECT	@strReceiptNumber = tblICInventoryReceipt.strReceiptNumber
		FROM	dbo.tblICInventoryReceipt INNER JOIN #tmpAddItemReceiptResult 
					ON tblICInventoryReceipt.intInventoryReceiptId = #tmpAddItemReceiptResult.intInventoryReceiptId

		EXEC tSQLt.AssertEquals 'INVRCT-1', @strReceiptNumber

		INSERT INTO actual_tblICInventoryReceiptItem (
			intLineNo
		)
		SELECT	intLineNo = ReceiptItem.intLineNo
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId 
		WHERE	Receipt.strReceiptNumber = @strReceiptNumber

		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryReceiptItem', 'actual_tblICInventoryReceiptItem';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE dbo.actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected

	IF OBJECT_ID('actual_tblICInventoryReceiptItem') IS NOT NULL 
		DROP TABLE dbo.actual_tblICInventoryReceiptItem

	IF OBJECT_ID('expected_tblICInventoryReceiptItem') IS NOT NULL 
		DROP TABLE dbo.expected_tblICInventoryReceiptItem
END 
