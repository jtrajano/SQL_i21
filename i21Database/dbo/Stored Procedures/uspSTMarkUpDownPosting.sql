﻿CREATE PROCEDURE [dbo].[uspSTMarkUpDownPosting]
@intMarkUpDownId INT
,@intCurrentUserId INT
,@ysnRecap BIT
,@ysnPost BIT
,@strStatusMsg NVARCHAR(1000) OUTPUT
,@strBatchId NVARCHAR(1000) OUTPUT
,@ysnIsPosted BIT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF 

BEGIN TRY
	
	--------------------------------------------------------------------------------------------  
	-- Initialize   
	--------------------------------------------------------------------------------------------    
	-- Create a unique transaction name. 
	DECLARE @TransactionName AS VARCHAR(500) = 'InventoryCostPosting' + CAST(NEWID() AS NVARCHAR(100));

	--------------------------------------------------------------------------------------------  
	-- Begin a transaction and immediately create a save point 
	--------------------------------------------------------------------------------------------  
	BEGIN TRAN @TransactionName
	SAVE TRAN @TransactionName -- Save point

	
	----------------------------------
	-- DECLARE VARIABLES
	----------------------------------
	DECLARE @GLEntries AS RecapTableType 

	SET @strStatusMsg = ''
	SET @ysnIsPosted = 0

	DECLARE @strMarkUpDownBatchId AS NVARCHAR(200)
	DECLARE @intStoreId AS INT
	DECLARE @strAdjustmentType AS NVARCHAR(50)
	DECLARE @strType AS NVARCHAR(50)

	DECLARE @MarkUpType_ItemLevel AS NVARCHAR(50) = 'Item Level'
	DECLARE @MarkUpType_DepartmentLevel AS NVARCHAR(50) = 'Department Level'

	DECLARE @AdjustmentType_Regular AS NVARCHAR(50) = 'Regular'
	DECLARE @AdjustmentType_WriteOff AS NVARCHAR(50) = 'Write Off'

	DECLARE @AdjustTypeCategorySales AS INT = 1
	DECLARE @AdjustTypeCategorySalesReturn AS INT = 2
	DECLARE @AdjustTypeCategoryMarkupOrMarkDown AS INT = 3
	DECLARE @AdjustTypeCategoryWriteOff AS INT = 4

	
	DECLARE @InventoryTransactionType_MarkUpOrDown AS INT = 49
	DECLARE @InventoryTransactionType_WriteOff AS INT = 50

	DECLARE @isRequiredGLEntries AS BIT

	-- Batch Id Mark Up Down
	SELECT @strMarkUpDownBatchId = strMarkUpDownNumber
	       ,@intStoreId = intStoreId
		   ,@strAdjustmentType = strAdjustmentType
		   ,@strType = strType
		   ,@ysnIsPosted = ysnIsPosted
		   ,@isRequiredGLEntries = CASE WHEN strAdjustmentType = @AdjustmentType_WriteOff THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM tblSTMarkUpDown
	WHERE intMarkUpDownId = @intMarkUpDownId

	-- Location
	DECLARE @intLocationId INT = (
									SELECT intCompanyLocationId 
									FROM tblSTStore
									WHERE intStoreId = @intStoreId
								 )

	-- Batch No Id
	-- If recap dont create batch, create only guid
	DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId FROM tblSMStartingNumber WHERE strModule = 'Posting' AND strTransactionType = 'Batch Post' AND strPrefix = 'BATCH-')


	DECLARE @ItemsForPost AS ItemCostingTableType  
			,@intReturnValue AS INT 
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50) = 'Inventory Adjustment' --'Cost of Goods'
	
	DECLARE @intCategoryAdjustmentType AS INT



	-- Check if Post or UnPost
	IF(@ysnPost = CAST(1 AS BIT))
		BEGIN
			IF(@strAdjustmentType = @AdjustmentType_Regular)
			BEGIN
					INSERT INTO @ItemsForPost (  
							intItemId  
							,intItemLocationId 
							,intItemUOMId  
							,dtmDate  
							,dblQty
							,dblUOMQty
							,dblCost
							,intTransactionId  
							,intTransactionDetailId   
							,strTransactionId  
							,intTransactionTypeId  
							,intSubLocationId
							,intStorageLocationId
							,intCurrencyId
							,intForexRateTypeId
							,dblForexRate
							,dblUnitRetail
							,intCategoryId
							,dblAdjustCostValue
							,dblAdjustRetailValue
					) 
					-- Decrease quantities from cost bucket first for Item managed. 
					SELECT		
							intItemId				= i.intItemId
							,intItemLocationId		= il.intItemLocationId
							,intItemUOMId			= iu.intItemUOMId
							,dtmDate				= MU.dtmMarkUpDownDate

							-- Item Manage
							,dblQty					= MUD.intQty * -1
							,dblUOMQty				= iu.dblUnitQty 
							,dblCost				= [dbo].[fnCalculateCostBetweenUOM](
															dbo.fnGetItemStockUOM(MUD.intItemId)
															,iu.intItemUOMId
															,ItemPricing.dblLastCost
														)		
							,intTransactionId		= MU.intMarkUpDownId -- Parent Id
							,intTransactionDetailId	= MUD.intMarkUpDownDetailId -- Child Id
							,strTransactionId		= MU.strMarkUpDownNumber --@strMarkUpDownBatchId -- 'POS-10001'
							,intTransactionTypeId	= @InventoryTransactionType_MarkUpOrDown
							,intSubLocationId		= NULL -- Optional
							,intStorageLocationId	= NULL -- Optional 
							,intCurrencyId			= NULL -- Optional. You will use this if you are using multi-currency. 
							,intForexRateTypeId		= NULL -- Optional. You will use this if you are using multi-currency. 
							,dblForexRate			= 1 -- Optional. You will use this if you are using multi-currency. 
							,dblUnitRetail			= NULL
							-- Department Manage
							,intCategoryId			= NULL
							,dblAdjustCostValue		= NULL
							,dblAdjustRetailValue	= NULL -- -200 -- $$$ value to adjust the retail value.
					FROM tblSTMarkUpDownDetail MUD
					INNER JOIN tblSTMarkUpDown MU ON MU.intMarkUpDownId = MUD.intMarkUpDownId
					--If Item Manage, query item fields that are needed
					INNER JOIN (
						tblICItem i INNER JOIN tblICItemLocation il
							ON i.intItemId = il.intItemId AND il.intLocationId = @intLocationId
						INNER JOIN tblICItemUOM iu
							ON iu.intItemId = i.intItemId AND iu.intItemUOMId = il.intIssueUOMId -- Defaulted to issue uom id as per ST-313
						INNER JOIN tblICItemPricing ItemPricing
							ON ItemPricing.intItemId = i.intItemId AND ItemPricing.intItemLocationId = il.intItemLocationId
					) ON i.intItemId = MUD.intItemId
					WHERE MU.intMarkUpDownId = @intMarkUpDownId AND MU.strType = @MarkUpType_ItemLevel
					UNION ALL
					-- Query all the MarkUp/Down for Item & Category managed
					SELECT		
							intItemId				= ISNULL(i.intItemId, CategoryItem.intItemId)
							,intItemLocationId		= ISNULL(il.intItemLocationId, CategoryItem.intItemLocationId)
							,intItemUOMId			= ISNULL(iu.intItemUOMId, CategoryItem.intItemUOMId)
							,dtmDate				= MU.dtmMarkUpDownDate

							-- Item Manage
							,dblQty					= CASE 
														WHEN MU.strType = @MarkUpType_ItemLevel THEN MUD.intQty
														ELSE 0
													END -- 0 -- Required field so specify zero. 
							,dblUOMQty				= CASE
														WHEN MU.strType = @MarkUpType_ItemLevel THEN iu.dblUnitQty 
														ELSE 0
													END -- 0 -- Required field so specify zero. 
							,dblCost				= CASE
														WHEN MU.strType = @MarkUpType_ItemLevel THEN [dbo].[fnCalculateCostBetweenUOM](
															dbo.fnGetItemStockUOM(MUD.intItemId)
															,iu.intItemUOMId
															,ItemPricing.dblLastCost
														)
														ELSE 0
													END			
							,intTransactionId		= MU.intMarkUpDownId -- Parent Id
							,intTransactionDetailId	= MUD.intMarkUpDownDetailId -- Child Id
							,strTransactionId		= MU.strMarkUpDownNumber--@strMarkUpDownBatchId -- 'POS-10001'
							,intTransactionTypeId	= CASE --@intCategoryAdjustmentType -- 49 50 33 -- For demo purposes, use 33, the transaction type for Invoice. 
														WHEN MU.strAdjustmentType = @AdjustmentType_Regular THEN @InventoryTransactionType_MarkUpOrDown
														ELSE @InventoryTransactionType_WriteOff
													END
							,intSubLocationId		= NULL -- Optional
							,intStorageLocationId	= NULL -- Optional 
							,intCurrencyId			= NULL -- Optional. You will use this if you are using multi-currency. 
							,intForexRateTypeId		= NULL -- Optional. You will use this if you are using multi-currency. 
							,dblForexRate			= 1 -- Optional. You will use this if you are using multi-currency. 
							,dblUnitRetail			= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN NULL ELSE ItemPricing.dblSalePrice + MUD.dblRetailPerUnit
													END

							-- Department Manage
							,intCategoryId			= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.intCategoryId ELSE NULL
													END
							,dblAdjustCostValue		= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.dblTotalCostAmount ELSE NULL
													END
							,dblAdjustRetailValue	= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN -MUD.dblTotalRetailAmount * -1 ELSE NULL
													END -- -200 -- $$$ value to adjust the retail value.

					FROM tblSTMarkUpDownDetail MUD
					INNER JOIN tblSTMarkUpDown MU ON MU.intMarkUpDownId = MUD.intMarkUpDownId	
					
					--If Item Manage, query item fields that are needed
					LEFT JOIN (
						tblICItem i INNER JOIN tblICItemLocation il
							ON i.intItemId = il.intItemId AND il.intLocationId = @intLocationId
						INNER JOIN tblICItemUOM iu
							ON iu.intItemId = i.intItemId AND iu.intItemUOMId = il.intIssueUOMId-- Defaulted to issue uom id as per ST-313
						INNER JOIN tblICItemPricing ItemPricing
							ON ItemPricing.intItemId = i.intItemId AND ItemPricing.intItemLocationId = il.intItemLocationId
					) ON i.intItemId = MUD.intItemId
					--Category Managed. Since item Ids are required, we'll fill those fields. This is just a temporary fix
					OUTER APPLY ( 
						SELECT TOP 1	Item.intItemId,
										ItemLocation.intItemLocationId,
										ItemUOM.intItemUOMId
						FROM tblICCategoryPricing CategoryPricing
						INNER JOIN tblICItem Item
							ON CategoryPricing.intCategoryId = MUD.intCategoryId AND CategoryPricing.dblTotalCostValue > 0
						INNER JOIN tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId = @intLocationId AND ItemLocation.intCostingMethod = 6 -- Category Costing Method = 6
						INNER JOIN tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId
						WHERE Item.intCategoryId = MUD.intCategoryId
					) CategoryItem
					WHERE MU.intMarkUpDownId = @intMarkUpDownId
			
			END
			ELSE IF(@strAdjustmentType = @AdjustmentType_WriteOff)
			BEGIN
					-- Write Off
					INSERT INTO @ItemsForPost (  
							intItemId  
							,intItemLocationId 
							,intItemUOMId  
							,dtmDate  
							,dblQty
							,dblUOMQty
							,dblCost
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
							,dblAdjustCostValue
							,dblAdjustRetailValue
					) 
					SELECT		
							intItemId				= ISNULL(i.intItemId, CategoryItem.intItemId)
							,intItemLocationId		= ISNULL(il.intItemLocationId, CategoryItem.intItemLocationId)
							,intItemUOMId			= ISNULL(iu.intItemUOMId, CategoryItem.intItemUOMId)
							,dtmDate				= MU.dtmMarkUpDownDate

							-- Item Manage
							,dblQty					= CASE 
														WHEN MU.strType = @MarkUpType_ItemLevel THEN MUD.intQty * -1
														ELSE 0
													END -- 0 -- Required field so specify zero. 
							,dblUOMQty				= CASE
														WHEN MU.strType = @MarkUpType_ItemLevel THEN iu.dblUnitQty 
														ELSE 0
													END -- 0 -- Required field so specify zero. 
							,dblCost				= CASE
														WHEN MU.strType = @MarkUpType_ItemLevel THEN [dbo].[fnCalculateCostBetweenUOM](
															dbo.fnGetItemStockUOM(MUD.intItemId)
															,iu.intItemUOMId
															,ItemPricing.dblLastCost
														)
														ELSE 0
													END			
							,intTransactionId		= MU.intMarkUpDownId -- Parent Id
							,intTransactionDetailId	= MUD.intMarkUpDownDetailId -- Child Id
							,strTransactionId		= MU.strMarkUpDownNumber--@strMarkUpDownBatchId -- 'POS-10001'
							,intTransactionTypeId	= CASE --@intCategoryAdjustmentType -- 49 50 33 -- For demo purposes, use 33, the transaction type for Invoice. 
														WHEN MU.strAdjustmentType = @AdjustmentType_Regular THEN @InventoryTransactionType_MarkUpOrDown
														ELSE @InventoryTransactionType_WriteOff
													END
							,intSubLocationId		= NULL -- Optional
							,intStorageLocationId	= NULL -- Optional 
							,intCurrencyId			= NULL -- Optional. You will use this if you are using multi-currency. 
							,intForexRateTypeId		= NULL -- Optional. You will use this if you are using multi-currency. 
							,dblForexRate			= 1 -- Optional. You will use this if you are using multi-currency. 

							-- Department Manage
							,intCategoryId			= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.intCategoryId ELSE NULL
													END
							,dblAdjustCostValue		= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.dblTotalCostAmount * -1 ELSE NULL
													END
							,dblAdjustRetailValue	= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.dblTotalRetailAmount * -1 ELSE NULL
													END -- -200 -- $$$ value to adjust the retail value.

					FROM tblSTMarkUpDownDetail MUD
					INNER JOIN tblSTMarkUpDown MU ON MU.intMarkUpDownId = MUD.intMarkUpDownId
					--If Item Manage, query item fields that are needed
					LEFT JOIN (
						tblICItem i INNER JOIN tblICItemLocation il
							ON i.intItemId = il.intItemId AND il.intLocationId = @intLocationId
						INNER JOIN tblICItemUOM iu
							ON iu.intItemId = i.intItemId AND iu.intItemUOMId = il.intIssueUOMId-- Defaulted to issue uom id as per ST-313
						INNER JOIN tblICItemPricing ItemPricing
							ON ItemPricing.intItemId = i.intItemId AND ItemPricing.intItemLocationId = il.intItemLocationId
					) ON i.intItemId = MUD.intItemId
					
					--Category Managed. Since item Ids are required, we'll fill those fields. This is just a temporary fix
					OUTER APPLY ( 
						SELECT TOP 1	Item.intItemId,
										ItemLocation.intItemLocationId,
										ItemUOM.intItemUOMId
						FROM tblICCategoryPricing CategoryPricing
						INNER JOIN tblICItem Item
							ON CategoryPricing.intCategoryId = MUD.intCategoryId AND CategoryPricing.dblTotalCostValue > 0
						INNER JOIN tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId = @intLocationId AND ItemLocation.intCostingMethod = 6 -- Category Costing Method = 6
						INNER JOIN tblICItemUOM ItemUOM
							ON ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId
						WHERE Item.intCategoryId = MUD.intCategoryId
					) CategoryItem
					WHERE MU.intMarkUpDownId = @intMarkUpDownId
			END

			-- Generate New Batch Id
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 


			-- Process Adjustments
			IF EXISTS(SELECT TOP 1 1 FROM @ItemsForPost)
			BEGIN
				EXEC @intReturnValue = dbo.uspICPostCosting  
						@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intCurrentUserId

				IF @intReturnValue < 0 GOTO With_Rollback_Exit
			END

			-- NOTE: 
			-- 1. To see in Retail valuation, item's category should have check retail valuation in Category screen
			-- 2. After Unpost it will create GL Entries for audit


			IF(@isRequiredGLEntries = 1)
				BEGIN
					-----------------------------------------
					-- Generate a new set of g/l entries
					-----------------------------------------
					INSERT INTO @GLEntries (
							[dtmDate] 
							,[strBatchId]
							,[intAccountId]
							,[dblDebit]
							,[dblCredit]
							,[dblDebitUnit]
							,[dblCreditUnit]
							,[strDescription]
							,[strCode]
							,[strReference]
							,[intCurrencyId]
							,[dblExchangeRate]
							,[dtmDateEntered]
							,[dtmTransactionDate]
							,[strJournalLineDescription]
							,[intJournalLineNo]
							,[ysnIsUnposted]
							,[intUserId]
							,[intEntityId]
							,[strTransactionId]
							,[intTransactionId]
							,[strTransactionType]
							,[strTransactionForm]
							,[strModuleName]
							,[intConcurrencyId]
							,[dblDebitForeign]	
							,[dblDebitReport]	
							,[dblCreditForeign]	
							,[dblCreditReport]	
							,[dblReportingRate]	
							,[dblForeignRate]
							,[strRateType]
					)
					EXEC @intReturnValue = dbo.uspICCreateGLEntries 
						@strBatchId
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@intCurrentUserId
						,@strAdjustmentType

					IF @intReturnValue < 0 GOTO With_Rollback_Exit
				END


			--Update Mark Up/Down
			Update tblSTMarkUpDown
			SET ysnIsPosted = @ysnPost
			WHERE intMarkUpDownId = @intMarkUpDownId

			SET @ysnIsPosted = @ysnPost
			SET @strStatusMsg = 'Success'
		END



	ELSE IF(@ysnPost = CAST(0 AS BIT))
		BEGIN
			--UNPOST

			---- Generate New Batch Id
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 

			-- UnPost
			INSERT INTO @GLEntries (
						[dtmDate] 
						,[strBatchId]
						,[intAccountId]
						,[dblDebit]
						,[dblCredit]
						,[dblDebitUnit]
						,[dblCreditUnit]
						,[strDescription]
						,[strCode]
						,[strReference]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[dtmDateEntered]
						,[dtmTransactionDate]
						,[strJournalLineDescription]
						,[intJournalLineNo]
						,[ysnIsUnposted]
						,[intUserId]
						,[intEntityId]
						,[strTransactionId]
						,[intTransactionId]
						,[strTransactionType]
						,[strTransactionForm]
						,[strModuleName]
						,[intConcurrencyId]
						,[dblDebitForeign]	
						,[dblDebitReport]	
						,[dblCreditForeign]	
						,[dblCreditReport]	
						,[dblReportingRate]	
						,[dblForeignRate]
						,[strRateType]
				)
				EXEC @intReturnValue = dbo.uspICUnpostCosting  
						@intMarkUpDownId  
						,@strMarkUpDownBatchId  
						,@strBatchId --New BatchId
						,@intCurrentUserId
						,0

				IF @intReturnValue < 0 GOTO With_Rollback_Exit

				-- Update Mark Up/Down
				Update tblSTMarkUpDown
				SET ysnIsPosted = @ysnPost
				WHERE intMarkUpDownId = @intMarkUpDownId

				SET @ysnIsPosted = @ysnPost
				SET @strStatusMsg = 'Success'

			END

		

	---- Check if recap
	IF(@ysnRecap = CAST(1 AS BIT) AND @isRequiredGLEntries = 1)
		BEGIN
			--IF @@TRANCOUNT > 0 
			ROLLBACK TRAN @TransactionName

			--SET @strBatchId = NEWID();
			IF EXISTS(SELECT * FROM @GLEntries)
			BEGIN
				-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
				EXEC dbo.uspGLPostRecap 
					@GLEntries
					,@intCurrentUserId
			END
		
			
			COMMIT TRAN @TransactionName
			GOTO Post_Exit	
		END
	ELSE
		BEGIN--IF @@TRANCOUNT > 0 
			
			IF @isRequiredGLEntries = 1
			BEGIN 
				IF(EXISTS(SELECT * FROM @GLEntries))
				BEGIN
					EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
				END
			END		
			
			COMMIT TRAN @TransactionName
			GOTO Post_Exit;
		END
END TRY

BEGIN CATCH
	SET @strStatusMsg = ERROR_MESSAGE()
	GOTO With_Rollback_Exit;

END CATCH

With_Rollback_Exit:
IF @@TRANCOUNT > 1 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
END

Post_Exit: