CREATE PROCEDURE [testIC].[Fake Item Stock]
AS
BEGIN	
	----------------------------------
	-- DECLARE THE CONSTANTS
	----------------------------------
	DECLARE @PurchaseType AS INT = 1
	DECLARE @SalesType AS INT = 2

	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5

	-- Declare the variables for company locations
	DECLARE @Paris AS INT = 1
			,@Florence AS INT = 2
			,@Tokyo AS INT = 3
			,@Manila AS INT = 3

	-- Declare the item-locations 
	DECLARE @WetGrains_Paris AS INT = 1
			,@WetGrains_Florence AS INT = 2
			,@WetGrains_Tokyo AS INT = 3
			,@WetGrains_Manila AS INT = 4

			,@StickyGrains_Paris AS INT = 5
			,@StickyGrains_Florence AS INT = 6
			,@StickyGrains_Tokyo AS INT = 7
			,@StickyGrains_Manila AS INT = 8

			,@PremiumGrains_Paris AS INT = 9
			,@PremiumGrains_Florence AS INT = 10
			,@PremiumGrains_Tokyo AS INT = 11
			,@PremiumGrains_Manila AS INT = 12

			,@ColdGrains_Paris AS INT = 13
			,@ColdGrains_Florence AS INT = 14
			,@ColdGrains_Tokyo AS INT = 15
			,@ColdGrains_Manila AS INT = 16

			,@HotGrains_Paris AS INT = 17
			,@HotGrains_Florence AS INT = 18
			,@HotGrains_Tokyo AS INT = 19
			,@HotGrains_Manila AS INT = 20

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5

	DECLARE @USD AS INT = 1;		
	DECLARE @Each AS INT = 1;
	
	EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;

	-- Add stock information for items under location 1 ('Paris')
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @WetGrains_Paris, 100)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @StickyGrains_Paris, 150)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @PremiumGrains_Paris, 200)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @ColdGrains_Paris, 250)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @HotGrains_Paris, 300)

	-- Add stock information for items under location 2 ('Florence')
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @WetGrains_Florence, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @StickyGrains_Florence, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @PremiumGrains_Florence, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @ColdGrains_Florence, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @HotGrains_Florence, 0)

	-- Add stock information for items under location 3 ('Tokyo')
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@WetGrains, @WetGrains_Tokyo, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@StickyGrains, @StickyGrains_Tokyo, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@PremiumGrains, @PremiumGrains_Tokyo, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@ColdGrains, @ColdGrains_Tokyo, 0)
	INSERT INTO dbo.tblICItemStock (intItemId, intItemLocationId, dblUnitOnHand) VALUES (@HotGrains, @HotGrains_Tokyo, 0)
END