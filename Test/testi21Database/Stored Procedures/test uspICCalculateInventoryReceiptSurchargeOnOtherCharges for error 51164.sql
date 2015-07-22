﻿CREATE PROCEDURE [testi21Database].[test uspICCalculateInventoryReceiptSurchargeOnOtherCharges for error 51164]
AS
BEGIN
	-- Arrange 
	BEGIN 
		EXEC [testi21Database].[Fake data for inventory receipt table];

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
		END 
		
		CREATE TABLE expected
		(
			[intInventoryReceiptId] INT NOT NULL,
			[intInventoryReceiptChargeId] INT NOT NULL, 
			[intInventoryReceiptItemId] INT NOT NULL, 
			[intChargeId] INT NOT NULL, 
			[intEntityVendorId] INT NULL, 
			[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)) 
		)

		CREATE TABLE actual
		(
			[intInventoryReceiptId] INT NOT NULL,
			[intInventoryReceiptChargeId] INT NOT NULL, 
			[intInventoryReceiptItemId] INT NOT NULL, 
			[intChargeId] INT NOT NULL, 
			[intEntityVendorId] INT NULL, 
			[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)) 
		)

		DECLARE @intInventoryReceiptId AS INT = 11
	END 

	-- Create a cyclic surcharge. 
	BEGIN 
		UPDATE dbo.tblICItem
		SET intOnCostTypeId = @SurchargeOtherCharges
		WHERE intItemId = @OtherCharges

		UPDATE dbo.tblICItem
		SET intOnCostTypeId = @OtherCharges
		WHERE intItemId = @SurchargeOtherCharges
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException
			@ExpectedMessage = 'Cyclic situation found. Unable to compute surcharge because Surcharge Other Charges depends on Other Charges and vice-versa.'
			,@ExpectedErrorNumber = 51164
	END
	
	-- Act
	BEGIN 		
		EXEC [dbo].[uspICCalculateInventoryReceiptSurchargeOnOtherCharges]
			@intInventoryReceiptId
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END