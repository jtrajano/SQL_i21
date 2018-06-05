CREATE PROCEDURE [dbo].[uspSTMarkUpDownPosting]
@intMarkUpDownId INT
,@intCurrentUserId INT
,@ysnRecap BIT
,@ysnPost BIT
,@strStatusMsg NVARCHAR(1000) OUTPUT
,@strBatchId NVARCHAR(1000) OUTPUT
,@ysnIsPosted BIT OUTPUT
AS
BEGIN TRY
	
	----------------------------------------------------------------------------------------------  
	---- Initialize   
	----------------------------------------------------------------------------------------------    
	---- Create a unique transaction name. 
	--DECLARE @TransactionName AS VARCHAR(500) = 'InventoryReceipt' + CAST(NEWID() AS NVARCHAR(100));

	----------------------------------------------------------------------------------------------  
	---- Begin a transaction and immediately create a save point 
	----------------------------------------------------------------------------------------------  
	--BEGIN TRAN @TransactionName
	--SAVE TRAN @TransactionName -- Save point


	SET @strStatusMsg = ''
	SET @ysnIsPosted = 0

	DECLARE @strMarkUpDownBatchId AS NVARCHAR(200)
	DECLARE @intStoreId AS INT
	DECLARE @strAdjustmentType AS NVARCHAR(50)
	DECLARE @strType AS NVARCHAR(50)

	-- Batch Id Mark Up Down
	SELECT @strMarkUpDownBatchId = strMarkUpDownNumber
	       ,@intStoreId = intStoreId
		   ,@strAdjustmentType = strAdjustmentType
		   ,@strType = strType
		   ,@ysnIsPosted = ysnIsPosted
	FROM tblSTMarkUpDown
	WHERE intMarkUpDownId = @intMarkUpDownId

	-- Location
	DECLARE @intLocationId INT = (
									SELECT intCompanyLocationId 
									FROM tblSTStore
									WHERE intStoreId = @intStoreId
								 )

	-- Batch No Id
	-- If recap dont create batch, create onlu guid
	DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId FROM tblSMStartingNumber WHERE strModule = 'Posting' AND strTransactionType = 'Batch Post' AND strPrefix = 'BATCH-')


	DECLARE @ItemsForPost AS ItemCostingTableType  
			,@intReturnValue AS INT 
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50) = 'Cost of Goods'
	
	DECLARE @intCategoryAdjustmentType AS INT



	IF(@ysnPost = CAST(1 AS BIT))
		 BEGIN
			--POST
			IF(@strAdjustmentType = 'Regular')
				BEGIN
					-- Mark Up/Down
					IF EXISTS(SELECT * FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')
						BEGIN
							SET @intCategoryAdjustmentType = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')
						END

					-- Note: Mark Up/Down should not have entry on Inventory Adjustments
			
				END
			ELSE IF(@strAdjustmentType = 'Write Off')
				BEGIN
					-- Write Off
					IF EXISTS(SELECT * FROM tblICInventoryTransactionType WHERE strName = 'Retail Write Offs')
						BEGIN
							SET @intCategoryAdjustmentType = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Write Offs')
						END

				    -- Note: Write off should have entry on Inventory Adjustments
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
			
					,intTransactionId		= @intMarkUpDownId
					,intTransactionDetailId	= NULL
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

			FROM tblSTMarkUpDownDetail MUD
			INNER JOIN tblICItem i ON MUD.intItemId = i.intItemId
			INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId 
			LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId 
			INNER JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1
			WHERE intMarkUpDownId = @intMarkUpDownId

			-- Generate New Batch Id
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 


			-- Post
			EXEC @intReturnValue = dbo.uspICPostCosting  
				@ItemsForPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intCurrentUserId

			-- Update Mark Up/Down
			Update tblSTMarkUpDown
			SET ysnIsPosted = 1
			WHERE intMarkUpDownId = @intMarkUpDownId

			SET @ysnIsPosted = 1
			SET @strStatusMsg = 'Success'

			-- NOTE: 
			-- 1. To see in Retail valuation, item's category should have check retail valuation in Category screen
			-- 2. After Unpost it will create GL Entries for audit
		 END

	ELSE IF(@ysnPost = CAST(0 AS BIT))
		 BEGIN
			--UNPOST

			-- Generate New Batch Id
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 

			-- UnPost
			EXEC @intReturnValue = dbo.uspICUnpostCosting  
				@intMarkUpDownId  
				,@strMarkUpDownBatchId  
				,@strBatchId --New BatchId
				,@intCurrentUserId
				,0

			-- Update Mark Up/Down
			Update tblSTMarkUpDown
			SET ysnIsPosted = 0
			WHERE intMarkUpDownId = @intMarkUpDownId

			SET @ysnIsPosted = 0
			SET @strStatusMsg = 'Success'

		 END
END TRY

BEGIN CATCH
	SET @strStatusMsg = ERROR_MESSAGE()
END CATCH