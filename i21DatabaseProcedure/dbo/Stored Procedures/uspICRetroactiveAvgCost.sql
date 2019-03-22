/*

*/
CREATE PROCEDURE [dbo].[uspICRetroactiveAvgCost]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dblQty AS NUMERIC(38,20)
	,@dblNewCost AS NUMERIC(38,20)
	,@dblNewValue AS NUMERIC(38,20)
	,@intSourceTransactionId AS INT
	,@intSourceTransactionDetailId AS INT 
	,@strSourceTransactionId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@intEntityUserSecurityId AS INT
	,@dblResult AS NUMERIC(38, 20) OUTPUT 
	,@strDescription AS NVARCHAR(255) OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables 
BEGIN 
	DECLARE	@RunningQty AS NUMERIC(38, 20)
			,@RunningValue AS NUMERIC(38, 20)
			,@PreviousRunningQty AS NUMERIC(38, 20)
			,@CurrentValue AS NUMERIC(38, 20)

			,@CostAdjustment AS NUMERIC(38, 20)
			,@RetroactiveAverageCost AS NUMERIC(38, 20)

			,@t_intInventoryTransactionId AS INT 
			,@t_intItemId AS INT 
			,@t_intItemLocationId AS INT 
			,@t_intItemUOMId AS INT 
			,@t_dblQty AS NUMERIC(38, 20)			
			,@t_dblCost AS NUMERIC(38, 20)
			,@t_dblValue AS NUMERIC(38, 20)
			,@t_strTransactionId AS NVARCHAR(50)
			,@t_intTransactionId AS INT 
			,@t_intTransactionDetailId AS INT  

			,@InventoryTransactionIdentityId AS INT 

	DECLARE	@StockItemUOMId AS INT
			,@strNewCost AS NVARCHAR(50) 
END 

-- Compute the cost adjustment
BEGIN 
	SET @CostAdjustment = 
		CASE	WHEN @dblNewValue IS NOT NULL THEN @dblNewValue
				WHEN @dblQty IS NOT NULL THEN @dblQty * ISNULL(@dblNewCost, 0) 
				ELSE NULL 
		END 
END

-- Get the starting transaction id and cost bucket id. 
BEGIN 
	DECLARE @InventoryTransactionStartId AS INT
			,@CostBucketId AS INT  

	SELECT	TOP 1 
			@InventoryTransactionStartId = t.intInventoryTransactionId 
	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND t.intTransactionId = @intSourceTransactionId
			AND ISNULL(t.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND t.strTransactionId = @strSourceTransactionId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 

	SELECT	TOP 1 
			@CostBucketId = cb.intInventoryFIFOId
	FROM	tblICInventoryFIFO cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
		
	-- Validate the cost bucket
	BEGIN 
		IF @InventoryTransactionStartId IS NULL
		BEGIN 
			DECLARE @strItemNo AS NVARCHAR(50)				

			SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
			FROM	tblICItem 
			WHERE	intItemId = @intItemId

			-- 'Cost adjustment cannot continue. Unable to find the cost bucket for %s that was posted in %s.
			EXEC uspICRaiseError 80062, @strItemNo, @strSourceTransactionId;  
			RETURN -80062;
		END
	END 
END 

-- Initialize the Running Qty (converted to stock UOM), Running Value, and Average Cost. 
BEGIN 	
	SELECT	@StockItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 			

	SELECT	@RunningQty = SUM (
				dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockItemUOMId, t.dblQty)
			) 
	FROM	tblICInventoryTransaction t INNER JOIN tblICItemUOM iUOM
				ON t.intItemUOMId = iUOM.intItemUOMId
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId < @InventoryTransactionStartId

	SET @RunningQty = ISNULL(@RunningQty, 0) 
	SET @PreviousRunningQty = ISNULL(@RunningQty, 0) 

	SELECT	@RunningValue = SUM (
				ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0) 
			) 
	FROM	tblICInventoryTransaction t 
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId < @InventoryTransactionStartId

	SELECT @RetroactiveAverageCost = 
		CASE	WHEN @RunningQty > 0 THEN ISNULL(@RunningValue, 0) / @RunningQty
				ELSE 
					(
						SELECT	TOP 1 
								dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @StockItemUOMId, t.dblCost) 								
						FROM	tblICInventoryTransaction t 
						WHERE	t.intItemId = @intItemId
								AND t.intItemLocationId = @intItemLocationId
								AND ISNULL(t.ysnIsUnposted, 0) = 0 
								AND t.intInventoryTransactionId < @InventoryTransactionStartId
								AND t.dblQty < 0 
						ORDER BY 
							t.intInventoryTransactionId DESC 
					)
		END 			
END 

-- Loop to perform the retroactive computation
BEGIN 
	DECLARE loopRetroactive CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  t.intInventoryTransactionId
			,t.intItemId
			,t.intItemLocationId
			,t.intItemUOMId
			,t.dblQty
			,t.dblCost
			,t.dblValue
			,t.strTransactionId
			,t.intTransactionId
			,t.intTransactionDetailId
	FROM	tblICInventoryTransaction t 
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId			
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId >= @InventoryTransactionStartId

	OPEN loopRetroactive;

	-- Initial fetch attempt
	FETCH NEXT FROM loopRetroactive INTO 
		@t_intInventoryTransactionId 
		,@t_intItemId 
		,@t_intItemLocationId 
		,@t_intItemUOMId 
		,@t_dblQty 
		,@t_dblCost 
		,@t_dblValue
		,@t_strTransactionId
		,@t_intTransactionId
		,@t_intTransactionDetailId
	;

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @t_dblQty = ISNULL(@t_dblQty, 0)
		SET @t_dblCost = ISNULL(@t_dblCost, 0)
		SET @t_dblValue = ISNULL(@t_dblValue, 0) 
		
		-- Calculate the Running Value. 
		SET @RunningValue += 
			CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
						@t_dblQty * @t_dblCost + @t_dblValue + ISNULL(@CostAdjustment, 0) 
					WHEN @t_dblQty > 0 THEN 
						@t_dblQty * @t_dblCost + @t_dblValue
					WHEN @t_dblQty < 0 THEN 
						@t_dblQty * @RetroactiveAverageCost -- Reduce the stock using the retroactive avg cost. 
					WHEN @t_dblValue <> 0 THEN 
						@t_dblValue
			END 

		-- Calculate the running qty. 
		SET @PreviousRunningQty = @RunningQty
		SET @RunningQty += dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty)

		-- Calculate the Average Cost 
		SET @RetroactiveAverageCost = 
			CASE	WHEN @RunningQty > 0 AND @t_dblQty > 0 THEN 
						@RunningValue / @RunningQty
					WHEN @RunningQty <= 0 AND @t_dblQty > 0 THEN 
						@t_dblQty * @t_dblCost / @t_dblQty
					WHEN @t_dblQty <= 0  THEN 
						@RetroactiveAverageCost
			END 

		-- Initial fetch attempt
		FETCH NEXT FROM loopRetroactive INTO 
			@t_intInventoryTransactionId 
			,@t_intItemId 
			,@t_intItemLocationId 
			,@t_intItemUOMId 
			,@t_dblQty 
			,@t_dblCost 
			,@t_dblValue
			,@t_strTransactionId
			,@t_intTransactionId
			,@t_intTransactionDetailId
		;		
	END 

	CLOSE loopRetroactive;
	DEALLOCATE loopRetroactive;
END 

-- Calculate the result. 
BEGIN 
	-- Get the current valuation 
	SELECT	@CurrentValue = SUM(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0)) 
	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 

	SET @strNewCost = CONVERT(NVARCHAR, CAST(@CostAdjustment AS MONEY), 1)

	-- Set the description output. 
	SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
	FROM	tblICItem i 
	WHERE	i.intItemId = @intItemId

	-- Set the result output. 
	SET @dblResult = @RunningValue - @CurrentValue
END 