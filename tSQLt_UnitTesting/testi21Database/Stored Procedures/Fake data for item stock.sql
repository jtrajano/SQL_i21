CREATE PROCEDURE [testi21Database].[Fake data for item stock]
AS
BEGIN
		DROP VIEW vyuAPRptPurchase
		EXEC tSQLt.FakeTable 'dbo.tblICItemStock', @Identity = 1;

		-- Declare the variables for grains (item)
		DECLARE @WetGrains AS INT = 1
				,@StickyGrains AS INT = 2
				,@PremiumGrains AS INT = 3
				,@ColdGrains AS INT = 4
				,@HotGrains AS INT = 5
				,@InvalidItem AS INT = -1

		-- Declare the variables for location
		DECLARE @Default_Location AS INT = 1
				,@NewHaven AS INT = 2
				,@BetterHaven AS INT = 3
				,@InvalidLocation AS INT = -1

		-- Declare the variables for the Unit of Measure
		DECLARE @EACH AS INT = 1;

		-- Add item stock records
		INSERT INTO tblICItemStock (
				[intItemId]
				,[intLocationId]
				,[intSubLocationId]
				,[dblAverageCost]
				,[dblUnitOnHand]
				,[dblOrderCommitted]
				,[dblOnOrder]
				,[dblLastCountRetail]
				,[intSort]
				,[intConcurrencyId]
		)
		-- Add Item Stock for Wet Grains
		SELECT	[intItemId] = @WetGrains
				,[intLocationId] = @Default_Location
				,[intSubLocationId] = NULL
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intLocationId] = @NewHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @WetGrains
				,[intLocationId] = @BetterHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1

		-- Add Item Stock for Sticky Grains
		UNION ALL 
		SELECT	[intItemId] = @StickyGrains
				,[intLocationId] = @Default_Location
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @StickyGrains
				,[intLocationId] = @NewHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @StickyGrains
				,[intLocationId] = @BetterHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1

		-- Add Item Stock for Premium Grains
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intLocationId] = @Default_Location
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intLocationId] = @NewHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @PremiumGrains
				,[intLocationId] = @BetterHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1

		-- Add Item Stock for Cold Grains
		UNION ALL 
		SELECT	[intItemId] = @ColdGrains
				,[intLocationId] = @Default_Location
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @ColdGrains
				,[intLocationId] = @NewHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @ColdGrains
				,[intLocationId] = @BetterHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1

		-- Add Item Stock for Hot Grains
		UNION ALL 
		SELECT	[intItemId] = @HotGrains
				,[intLocationId] = @Default_Location
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @HotGrains
				,[intLocationId] = @NewHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
		UNION ALL 
		SELECT	[intItemId] = @HotGrains
				,[intLocationId] = @BetterHaven
				,[intSubLocationId] = NULL
				,[intUnitMeasureId] = @EACH
				,[dblAverageCost] = 0
				,[dblUnitOnHand] = 0 
				,[dblOrderCommitted] = 0
				,[dblOnOrder] = 0
				,[dblLastCountRetail] = 0
				,[intSort] = 1
				,[intConcurrencyId] = 1
END 
