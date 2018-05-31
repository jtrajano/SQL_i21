CREATE PROCEDURE [dbo].[uspSTMarkUpDownPosting]
@intMarkUpDownId INT
,@intCurrentUserId INT
,@strStatusMsg NVARCHAR(1000) OUTPUT
,@strBatchId NVARCHAR(1000) OUTPUT
AS
BEGIN TRY
	DECLARE @strMarkUpDownBatchId AS NVARCHAR(200)
	DECLARE @intStoreId AS INT
	DECLARE @strAdjustmentType AS NVARCHAR(50)
	DECLARE @strType AS NVARCHAR(50)

	-- Batch Id Mark Up Down
	SELECT @strMarkUpDownBatchId = strMarkUpDownNumber
	       ,@intStoreId = intStoreId
		   ,@strAdjustmentType = strAdjustmentType
		   ,@strType = strType
	FROM tblSTMarkUpDown
	WHERE intMarkUpDownId = @intMarkUpDownId

	-- Location
	DECLARE @intLocationId INT = (
									SELECT intCompanyLocationId 
									FROM tblSTStore
									WHERE intStoreId = @intStoreId
								 )

	-- Batch No Id
	DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId FROM tblSMStartingNumber WHERE strModule = 'Posting' AND strTransactionType = 'Batch Post' AND strPrefix = 'BATCH-')
    EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 

	DECLARE @ItemsForPost AS ItemCostingTableType  
			,@intReturnValue AS INT 
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50) = 'Cost of Goods'
	
	--DECLARE @AdjustTypeCategorySales AS INT = 1
	--		,@AdjustTypeCategorySalesReturn AS INT = 2
	--		,@AdjustTypeCategoryMarkupOrMarkDown AS INT = 3
	--		,@AdjustTypeCategoryWriteOff AS INT = 4
	
	DECLARE @intCategoryAdjustmentType AS INT


	IF(@strAdjustmentType = 'Regular')
		BEGIN
			-- Mark Up/Down
			IF EXISTS(SELECT * FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')
				BEGIN
					SET @intCategoryAdjustmentType = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')
				END
			
		END
	ELSE IF(@strAdjustmentType = 'Write Off')
		BEGIN
			-- Write Off
			IF EXISTS(SELECT * FROM tblICInventoryTransactionType WHERE strName = 'Retail Write Offs')
				BEGIN
					SET @intCategoryAdjustmentType = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Write Offs')
				END
		END


	-- Insert
	INSERT INTO @ItemsForPost (  
			intItemId  
			,intItemLocationId 
			,intItemUOMId  
			,dtmDate  
			,dblQty
			,dblUOMQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intTransactionId  
			,intTransactionDetailId   
			,strTransactionId  
			,intTransactionTypeId  
			,intSubLocationId
			,intStorageLocationId
			,intCurrencyId
			,intForexRateTypeId
			,dblForexRate
			,intCategoryId
			,dblAdjustRetailValue
			,intCategoryAdjustmentType
	) 
	SELECT		
			intItemId				= i.intItemId
			,intItemLocationId		= il.intItemLocationId
			,intItemUOMId			= iu.intItemUOMId
			,dtmDate				= GETDATE()

			-- Item Manage
			,dblQty					= CASE 
										WHEN @strType = 'Item Level' THEN MUD.intQty ELSE 0
									END -- 0 -- Required field so specify zero. 
			,dblUOMQty				= CASE
										WHEN @strType = 'Item Level' THEN MUD.intQty ELSE 0
									END -- 0 -- Required field so specify zero. 
			,dblCost				= CASE
										WHEN @strType = 'Item Level' THEN MUD.dblTotalCostAmount ELSE 0
									END
			,dblValue				= CASE
										WHEN @strType = 'Item Level' THEN MUD.dblRetailPerUnit ELSE 0
									END
			,dblSalesPrice			= CASE
										WHEN @strType = 'Item Level' THEN MUD.dblRetailPerUnit ELSE 0
									END -- Required field so specify zero or the sales price used when selling the item. 
			
			,intTransactionId		= 1
			,intTransactionDetailId	= 2
			,strTransactionId		= @strMarkUpDownBatchId -- 'POS-10001'
			,intTransactionTypeId	= @intCategoryAdjustmentType -- 49 50 33 -- For demo purposes, use 33, the transaction type for Invoice. 
			,intSubLocationId		= NULL -- Optional
			,intStorageLocationId	= NULL -- Optional 
			,intCurrencyId			= NULL -- Optional. You will use this if you are using multi-currency. 
			,intForexRateTypeId		= NULL -- Optional. You will use this if you are using multi-currency. 
			,dblForexRate			= 1 -- Optional. You will use this if you are using multi-currency. 
			,intCategoryId			= i.intCategoryId

			-- Department Manage
			,dblAdjustRetailValue	= CASE
										WHEN @strType = 'Department Level' THEN MUD.dblRetailPerUnit ELSE 0
									END -- -200 -- $$$ value to adjust the retail value.

			,intCategoryAdjustmentType = NULL -- @intCategoryAdjustmentType -- Specify the adjustment type. 

	FROM	tblICItem i 
	INNER JOIN tblSTMarkUpDownDetail MUD ON i.intItemId = MUD.intItemId
	INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId 
	LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId 
	LEFT JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1


	-- Post
	EXEC @intReturnValue = dbo.uspICPostCosting  
		@ItemsForPost  
		,@strBatchId  
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
		,@intCurrentUserId


	-- Update Mark Up/Down
	Update tblSTMarkUpDown
	SET strBatchId = @strBatchId
	WHERE intMarkUpDownId = @intMarkUpDownId

	SET @strStatusMsg = 'Success'
END TRY

BEGIN CATCH
	SET @strStatusMsg = ERROR_MESSAGE()
END CATCH