CREATE PROCEDURE [dbo].[uspSTMarkUpDownCheckoutPosting]
@intCheckoutId INT
,@intCurrentUserId INT
,@ysnPost BIT
,@strStatusMsg NVARCHAR(1000) OUTPUT
,@strBatchId NVARCHAR(1000) OUTPUT
,@ysnIsPosted BIT OUTPUT
AS
BEGIN TRY
	
	SET @strStatusMsg = ''
	DECLARE @ItemsForPost AS ItemCostingTableType 
	DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50) = 'Cost of Goods'
	DECLARE @intReturnValue AS INT 
	DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId FROM tblSMStartingNumber WHERE strModule = 'Posting' AND strTransactionType = 'Batch Post' AND strPrefix = 'BATCH-')
	DECLARE @strMarkUpDownBatchNo AS NVARCHAR(1000) = (SELECT strMarkUpDownBatchNo FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
	DECLARE @intLocationId INT = (
									SELECT intCompanyLocationId
									FROM tblSTStore
									WHERE intStoreId = (
															SELECT intStoreId 
															FROM tblSTCheckoutHeader
															WHERE intCheckoutId = @intCheckoutId
													   )	
								 )
	

	-- Check if Post or UnPost
	IF(@ysnPost = CAST(1 AS BIT)) -- POST
		BEGIN
			-- POST

			DECLARE @intCategoryAdjustmentType AS INT = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')

			IF(@intCategoryAdjustmentType IS NOT NULL AND @intCategoryAdjustmentType != 0)
				BEGIN

					-- INSERT
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
								,dblQty					= MUD.dblQty		-- 0 -- Required field so specify zero. 
								,dblUOMQty				= MUD.dblQty		-- 0 -- Required field so specify zero.
								,dblCost				= MUD.dblAmount		-- 0 -- Required field so specify zero.
								,dblValue				= MUD.dblRetailUnit	-- 0 -- Required field so specify zero.
								,dblSalesPrice			= MUD.dblRetailUnit	-- Required field so specify zero or the sales price used when selling the item. 
			
								,intTransactionId		= @intCheckoutId -- Parent Id
								,intTransactionDetailId	= MUD.intCheckoutMarkUpDownId -- Child Id
								,strTransactionId		= @strMarkUpDownBatchNo -- 'POS-10001'
								,intTransactionTypeId	= @intCategoryAdjustmentType -- 49 50 33 -- For demo purposes, use 33, the transaction type for Invoice. 
								,intSubLocationId		= NULL -- Optional
								,intStorageLocationId	= NULL -- Optional 
								,intCurrencyId			= NULL -- Optional. You will use this if you are using multi-currency. 
								,intForexRateTypeId		= NULL -- Optional. You will use this if you are using multi-currency. 
								,dblForexRate			= 1 -- Optional. You will use this if you are using multi-currency. 
								,intCategoryId			= i.intCategoryId

								-- Department Manage
								,dblAdjustRetailValue	= 0

								,intCategoryAdjustmentType = NULL -- @intCategoryAdjustmentType -- Specify the adjustment type. 
						FROM tblSTCheckoutMarkUpDowns MUD
						INNER JOIN tblICItemUOM UOM ON MUD.intItemUOMId = UOM.intItemUOMId
						INNER JOIN tblICItem i ON UOM.intItemId = i.intItemId
						INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId 
						LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId 
						INNER JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1
						WHERE MUD.intCheckoutId = @intCheckoutId
						
						-- Generate New Batch Id
						EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 

						EXEC @intReturnValue = dbo.uspICPostCosting  
							 @ItemsForPost  
							,@strBatchId  
							,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
							,@intCurrentUserId

						SET @ysnIsPosted = 1
						SET @strStatusMsg = 'Success'
				END
		END
	ELSE IF(@ysnPost = CAST(0 AS BIT)) -- UNPOST
		BEGIN
			-- UNPOST

			---- Generate New Batch Id
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 

			-- UnPost
			EXEC @intReturnValue = dbo.uspICUnpostCosting  
					@intCheckoutId  
					,@strMarkUpDownBatchNo  
					,@strBatchId --New BatchId
					,@intCurrentUserId
					,0

			SET @ysnIsPosted = 0
			SET @strStatusMsg = 'Success'
		END

END TRY

BEGIN CATCH
	SET @strStatusMsg = ERROR_MESSAGE()
END CATCH
