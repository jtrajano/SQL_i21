CREATE PROCEDURE [dbo].[uspSTMarkUpDownPosting]
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
	-- If recap dont create batch, create onlu guid
	DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId FROM tblSMStartingNumber WHERE strModule = 'Posting' AND strTransactionType = 'Batch Post' AND strPrefix = 'BATCH-')


	DECLARE @ItemsForPost AS ItemCostingTableType  
			,@intReturnValue AS INT 
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(50) = 'Inventory Adjustment' --'Cost of Goods'
	
	DECLARE @intCategoryAdjustmentType AS INT



	-- Check if Post or UnPost
	IF(@ysnPost = CAST(1 AS BIT))
		BEGIN
			----POST
			--IF(@strAdjustmentType = 'Regular')
			--	BEGIN
			--		-- Mark Up/Down
			--		IF EXISTS(SELECT * FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')
			--			BEGIN
			--				SET @intCategoryAdjustmentType = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Mark Ups/Downs')
			--			END

			--		-- Note: Mark Up/Down should not have entry on Inventory Adjustments
			
			--	END
			--ELSE IF(@strAdjustmentType = 'Write Off')
			--	BEGIN
			--		-- Write Off
			--		IF EXISTS(SELECT * FROM tblICInventoryTransactionType WHERE strName = 'Retail Write Offs')
			--			BEGIN
			--				SET @intCategoryAdjustmentType = (SELECT intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = 'Retail Write Offs')
			--			END

			--		-- Note: Write off should have entry on Inventory Adjustments
			--	END


				-- Insert
				INSERT INTO @ItemsForPost (  
							intItemId  
							,intItemLocationId 
							,intItemUOMId  
							,dtmDate  
							,dblQty
							,dblUOMQty
							,dblCost
							--,dblValue
							--,dblSalesPrice
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
					) 
					SELECT		
							intItemId				= i.intItemId
							,intItemLocationId		= il.intItemLocationId
							,intItemUOMId			= iu.intItemUOMId
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
															,MUD.dblRetailPerUnit
														)
														ELSE 0
													END
							--,dblSalesPrice			= CASE
							--							WHEN MU.strType = @MarkUpType_ItemLevel THEN MUD.dblRetailPerUnit 
							--							ELSE 0
							--						END -- Required field so specify zero or the sales price used when selling the item. 
			
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
							,dblAdjustRetailValue	= CASE
														WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.dblRetailPerUnit ELSE NULL
													END -- -200 -- $$$ value to adjust the retail value.

					FROM tblSTMarkUpDownDetail MUD
					INNER JOIN tblSTMarkUpDown MU ON MU.intMarkUpDownId = MUD.intMarkUpDownId
					INNER JOIN tblICItem i ON MUD.intItemId = i.intItemId
					INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId AND il.intLocationId = @intLocationId
					LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = il.intLocationId 
					INNER JOIN tblICItemUOM iu ON iu.intItemId = i.intItemId AND iu.intItemUOMId = il.intIssueUOMId -- Defaulted to issue uom id as per ST-313
					WHERE MU.intMarkUpDownId = @intMarkUpDownId

				-- Generate New Batch Id
				EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 


				-- Process Adjustments
				EXEC @intReturnValue = dbo.uspICPostCosting  
					 @ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intCurrentUserId

				IF @intReturnValue < 0 GOTO With_Rollback_Exit

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
	IF(@ysnRecap = CAST(1 AS BIT))
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