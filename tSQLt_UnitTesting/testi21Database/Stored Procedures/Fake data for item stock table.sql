CREATE PROCEDURE [testi21Database].[Fake data for item stock table]
AS
BEGIN
		-- Use the fake items. 
		EXEC [testi21Database].[Fake inventory items]

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

		-- Sub Locations
		DECLARE	@SubLocation_NorthWarehouse AS INT = 10001
				,@SubLocation_EastWarehouse AS INT = 10002
				,@SubLocation_SouthhWarehouse AS INT = 10003
				,@SubLocation_WestWarehouse AS INT = 10004

		DECLARE @DefaultLocation_ColdStorage AS INT = 30001
				,@NewHaven_ColdStorage AS INT = 30002
				,@BetterHaven_ColdStorage AS INT = 30003

		-- Add item stock records
		/*
			-----------------------------------------------------------------------------------------------------------------------------------------------
			ItemId				ItemLocationId					SubLocationId					UnitOnHand	OrderCommitted		OnOrder		LastCountRetail	
			-----------------	------------------------------	-----------------------------	-----------	----------------	-----------	---------------
			@WetGrains			@WetGrains_DefaultLocation		@SubLocation_NorthWarehouse			      0				   0		      0			      0
			@WetGrains			@WetGrains_NewHaven				@SubLocation_EastWarehouse				  0				   0		      0			      0
			@WetGrains			@WetGrains_BetterHaven			@SubLocation_WestWarehouse				  0				   0		      0			      0		
		*/

		DECLARE @intItemCounter AS INT = 1
		DECLARE @intItemLocationCounter AS INT 
		DECLARE @intItemUOMCounter AS INT 

		WHILE (@intItemCounter <= 7)
		BEGIN 
			SET @intItemLocationCounter = 1

			WHILE (@intItemLocationCounter <= 3) 
			BEGIN 
				INSERT INTO tblICItemStock (
						[intItemId]
						,[intItemLocationId]
						,[intSubLocationId]
						,[dblUnitOnHand]
						,[dblOrderCommitted]
						,[dblOnOrder]
						,[dblLastCountRetail]
						,[intSort]
						,[intConcurrencyId]
				)
				SELECT	[intItemId] = 
									CASE	WHEN @intItemCounter = 1 THEN @WetGrains
											WHEN @intItemCounter = 2 THEN @StickyGrains
											WHEN @intItemCounter = 3 THEN @PremiumGrains
											WHEN @intItemCounter = 4 THEN @ColdGrains
											WHEN @intItemCounter = 5 THEN @HotGrains
											WHEN @intItemCounter = 6 THEN @ManualLotGrains
											WHEN @intItemCounter = 7 THEN @SerializedLotGrains
									END 
						,[intItemLocationId] = 									
									CASE	WHEN @intItemCounter = 1 AND @intItemLocationCounter = 1 THEN @WetGrains_DefaultLocation
											WHEN @intItemCounter = 1 AND @intItemLocationCounter = 2 THEN @WetGrains_NewHaven
											WHEN @intItemCounter = 1 AND @intItemLocationCounter = 3 THEN @WetGrains_BetterHaven

											WHEN @intItemCounter = 2 AND @intItemLocationCounter = 1 THEN @StickyGrains_DefaultLocation
											WHEN @intItemCounter = 2 AND @intItemLocationCounter = 2 THEN @StickyGrains_NewHaven
											WHEN @intItemCounter = 2 AND @intItemLocationCounter = 3 THEN @StickyGrains_BetterHaven

											WHEN @intItemCounter = 3 AND @intItemLocationCounter = 1 THEN @PremiumGrains_DefaultLocation
											WHEN @intItemCounter = 3 AND @intItemLocationCounter = 2 THEN @PremiumGrains_NewHaven
											WHEN @intItemCounter = 3 AND @intItemLocationCounter = 3 THEN @PremiumGrains_BetterHaven

											WHEN @intItemCounter = 4 AND @intItemLocationCounter = 1 THEN @ColdGrains_DefaultLocation
											WHEN @intItemCounter = 4 AND @intItemLocationCounter = 2 THEN @ColdGrains_NewHaven
											WHEN @intItemCounter = 4 AND @intItemLocationCounter = 3 THEN @ColdGrains_BetterHaven

											WHEN @intItemCounter = 5 AND @intItemLocationCounter = 1 THEN @HotGrains_DefaultLocation
											WHEN @intItemCounter = 5 AND @intItemLocationCounter = 2 THEN @HotGrains_NewHaven
											WHEN @intItemCounter = 5 AND @intItemLocationCounter = 3 THEN @HotGrains_BetterHaven

											WHEN @intItemCounter = 6 AND @intItemLocationCounter = 1 THEN @ManualLotGrains_DefaultLocation
											WHEN @intItemCounter = 6 AND @intItemLocationCounter = 2 THEN @ManualLotGrains_DefaultLocation
											WHEN @intItemCounter = 6 AND @intItemLocationCounter = 3 THEN @ManualLotGrains_DefaultLocation

											WHEN @intItemCounter = 7 AND @intItemLocationCounter = 1 THEN @SerializedLotGrains_DefaultLocation
											WHEN @intItemCounter = 7 AND @intItemLocationCounter = 2 THEN @SerializedLotGrains_DefaultLocation
											WHEN @intItemCounter = 7 AND @intItemLocationCounter = 3 THEN @SerializedLotGrains_DefaultLocation
									END 
						,[intSubLocationId] = NULL 										
						,[dblUnitOnHand] = 0 
						,[dblOrderCommitted] = 0
						,[dblOnOrder] = 0
						,[dblLastCountRetail] = 0
						,[intSort] = 1
						,[intConcurrencyId] = 1	

				SET @intItemLocationCounter += 1;
			END 
			SET @intItemCounter += 1;
		END 

		-- Add data to the Item Stock UOM table 
		SET @intItemCounter  = 1
		WHILE (@intItemCounter <= 7)
		BEGIN 
			SET @intItemLocationCounter = 1

			WHILE (@intItemLocationCounter <= 3) 
			BEGIN 				
				SET @intItemUOMCounter = 1
				
				WHILE (@intItemUOMCounter <=2 )
				BEGIN 
					INSERT INTO dbo.tblICItemStockUOM (
						intItemId
						,intItemLocationId
						,intItemUOMId
						,intSubLocationId
						,intStorageLocationId
						,dblOnHand		
					)
					SELECT 
						intItemId = CASE	WHEN @intItemCounter = 1 THEN @WetGrains
											WHEN @intItemCounter = 2 THEN @StickyGrains
											WHEN @intItemCounter = 3 THEN @PremiumGrains
											WHEN @intItemCounter = 4 THEN @ColdGrains
											WHEN @intItemCounter = 5 THEN @HotGrains
											WHEN @intItemCounter = 6 THEN @ManualLotGrains
											WHEN @intItemCounter = 7 THEN @SerializedLotGrains
									END 
						,intItemLocationId = 
									CASE	WHEN @intItemCounter = 1 AND @intItemLocationCounter = 1 THEN @WetGrains_DefaultLocation
											WHEN @intItemCounter = 1 AND @intItemLocationCounter = 2 THEN @WetGrains_NewHaven
											WHEN @intItemCounter = 1 AND @intItemLocationCounter = 3 THEN @WetGrains_BetterHaven

											WHEN @intItemCounter = 2 AND @intItemLocationCounter = 1 THEN @StickyGrains_DefaultLocation
											WHEN @intItemCounter = 2 AND @intItemLocationCounter = 2 THEN @StickyGrains_NewHaven
											WHEN @intItemCounter = 2 AND @intItemLocationCounter = 3 THEN @StickyGrains_BetterHaven

											WHEN @intItemCounter = 3 AND @intItemLocationCounter = 1 THEN @PremiumGrains_DefaultLocation
											WHEN @intItemCounter = 3 AND @intItemLocationCounter = 2 THEN @PremiumGrains_NewHaven
											WHEN @intItemCounter = 3 AND @intItemLocationCounter = 3 THEN @PremiumGrains_BetterHaven

											WHEN @intItemCounter = 4 AND @intItemLocationCounter = 1 THEN @ColdGrains_DefaultLocation
											WHEN @intItemCounter = 4 AND @intItemLocationCounter = 2 THEN @ColdGrains_NewHaven
											WHEN @intItemCounter = 4 AND @intItemLocationCounter = 3 THEN @ColdGrains_BetterHaven

											WHEN @intItemCounter = 5 AND @intItemLocationCounter = 1 THEN @HotGrains_DefaultLocation
											WHEN @intItemCounter = 5 AND @intItemLocationCounter = 2 THEN @HotGrains_NewHaven
											WHEN @intItemCounter = 5 AND @intItemLocationCounter = 3 THEN @HotGrains_BetterHaven

											WHEN @intItemCounter = 6 AND @intItemLocationCounter = 1 THEN @ManualLotGrains_DefaultLocation
											WHEN @intItemCounter = 6 AND @intItemLocationCounter = 2 THEN @ManualLotGrains_DefaultLocation
											WHEN @intItemCounter = 6 AND @intItemLocationCounter = 3 THEN @ManualLotGrains_DefaultLocation

											WHEN @intItemCounter = 7 AND @intItemLocationCounter = 1 THEN @SerializedLotGrains_DefaultLocation
											WHEN @intItemCounter = 7 AND @intItemLocationCounter = 2 THEN @SerializedLotGrains_DefaultLocation
											WHEN @intItemCounter = 7 AND @intItemLocationCounter = 3 THEN @SerializedLotGrains_DefaultLocation
										END 
						,intItemUOMId = 
									CASE	WHEN @intItemCounter = 1 AND @intItemUOMCounter = 1 THEN @WetGrains_BushelUOMId
											WHEN @intItemCounter = 1 AND @intItemUOMCounter = 2 THEN @WetGrains_PoundUOMId

											WHEN @intItemCounter = 2 AND @intItemUOMCounter = 1 THEN @StickyGrains_BushelUOMId
											WHEN @intItemCounter = 2 AND @intItemUOMCounter = 2 THEN @StickyGrains_PoundUOMId

											WHEN @intItemCounter = 3 AND @intItemUOMCounter = 1 THEN @PremiumGrains_BushelUOMId
											WHEN @intItemCounter = 3 AND @intItemUOMCounter = 2 THEN @PremiumGrains_PoundUOMId

											WHEN @intItemCounter = 4 AND @intItemUOMCounter = 1 THEN @ColdGrains_BushelUOMId
											WHEN @intItemCounter = 4 AND @intItemUOMCounter = 2 THEN @ColdGrains_PoundUOMId

											WHEN @intItemCounter = 5 AND @intItemUOMCounter = 1 THEN @HotGrains_BushelUOMId
											WHEN @intItemCounter = 5 AND @intItemUOMCounter = 2 THEN @HotGrains_PoundUOMId

											WHEN @intItemCounter = 6 AND @intItemUOMCounter = 1 THEN @ManualLotGrains_BushelUOMId
											WHEN @intItemCounter = 6 AND @intItemUOMCounter = 2 THEN @ManualLotGrains_PoundUOMId

											WHEN @intItemCounter = 5 AND @intItemUOMCounter = 1 THEN @SerializedLotGrains_BushelUOMId
											WHEN @intItemCounter = 5 AND @intItemUOMCounter = 2 THEN @SerializedLotGrains_PoundUOMId
									END 
						,intSubLocationId = NULL 
						,intStorageLocationId = NULL 
						,dblOnHand = 0												

					SET @intItemUOMCounter  += 1;
				END 			

				SET @intItemLocationCounter += 1;
			END 
			SET @intItemCounter += 1;
		END 

	

		-- Add data to the pricing table
		/*
			ItemId					ItemLocationId					AverageCost
			--------------------	-----------------------------	---------------
			@WetGrains				@WetGrains_DefaultLocation				  0
			@WetGrains				@WetGrains_NewHaven				          0
			@WetGrains				@WetGrains_BetterHaven					  0		
		*/
		SET @intItemCounter = 1

		WHILE (@intItemCounter <= 7) 
		BEGIN 
			SET @intItemLocationCounter = 1

			WHILE (@intItemLocationCounter <= 3) 
			BEGIN 
				INSERT INTO dbo.tblICItemPricing (
						intItemId
						,intItemLocationId
						,dblAverageCost
				)
				SELECT	[intItemId] = 
								CASE	WHEN @intItemCounter = 1 THEN @WetGrains
										WHEN @intItemCounter = 2 THEN @StickyGrains
										WHEN @intItemCounter = 3 THEN @PremiumGrains
										WHEN @intItemCounter = 4 THEN @ColdGrains
										WHEN @intItemCounter = 5 THEN @HotGrains
										WHEN @intItemCounter = 6 THEN @ManualLotGrains
										WHEN @intItemCounter = 7 THEN @SerializedLotGrains
								END 
						,[intItemLocationId] = 
								CASE	WHEN @intItemCounter = 1 AND @intItemLocationCounter = 1 THEN @WetGrains_DefaultLocation
										WHEN @intItemCounter = 1 AND @intItemLocationCounter = 2 THEN @WetGrains_NewHaven
										WHEN @intItemCounter = 1 AND @intItemLocationCounter = 3 THEN @WetGrains_BetterHaven

										WHEN @intItemCounter = 2 AND @intItemLocationCounter = 1 THEN @StickyGrains_DefaultLocation
										WHEN @intItemCounter = 2 AND @intItemLocationCounter = 2 THEN @StickyGrains_NewHaven
										WHEN @intItemCounter = 2 AND @intItemLocationCounter = 3 THEN @StickyGrains_BetterHaven

										WHEN @intItemCounter = 3 AND @intItemLocationCounter = 1 THEN @PremiumGrains_DefaultLocation
										WHEN @intItemCounter = 3 AND @intItemLocationCounter = 2 THEN @PremiumGrains_NewHaven
										WHEN @intItemCounter = 3 AND @intItemLocationCounter = 3 THEN @PremiumGrains_BetterHaven

										WHEN @intItemCounter = 4 AND @intItemLocationCounter = 1 THEN @ColdGrains_DefaultLocation
										WHEN @intItemCounter = 4 AND @intItemLocationCounter = 2 THEN @ColdGrains_NewHaven
										WHEN @intItemCounter = 4 AND @intItemLocationCounter = 3 THEN @ColdGrains_BetterHaven

										WHEN @intItemCounter = 5 AND @intItemLocationCounter = 1 THEN @HotGrains_DefaultLocation
										WHEN @intItemCounter = 5 AND @intItemLocationCounter = 2 THEN @HotGrains_NewHaven
										WHEN @intItemCounter = 5 AND @intItemLocationCounter = 3 THEN @HotGrains_BetterHaven

										WHEN @intItemCounter = 6 AND @intItemLocationCounter = 1 THEN @ManualLotGrains_DefaultLocation
										WHEN @intItemCounter = 6 AND @intItemLocationCounter = 2 THEN @ManualLotGrains_DefaultLocation
										WHEN @intItemCounter = 6 AND @intItemLocationCounter = 3 THEN @ManualLotGrains_DefaultLocation

										WHEN @intItemCounter = 7 AND @intItemLocationCounter = 1 THEN @SerializedLotGrains_DefaultLocation
										WHEN @intItemCounter = 7 AND @intItemLocationCounter = 2 THEN @SerializedLotGrains_DefaultLocation
										WHEN @intItemCounter = 7 AND @intItemLocationCounter = 3 THEN @SerializedLotGrains_DefaultLocation
								END  
						,[dblAverageCost] = 0
				SET @intItemLocationCounter += 1;
			END
			SET @intItemCounter += 1;
		END 
END 
