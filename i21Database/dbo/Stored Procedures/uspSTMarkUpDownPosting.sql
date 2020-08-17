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
	-- Create Save Point.  
	--------------------------------------------------------------------------------------------    
	-- Create a unique transaction name. 
	DECLARE @SavedPointTransaction AS VARCHAR(500) = 'MarkUpMarkDownPosting' + CAST(NEWID() AS NVARCHAR(100)); 
	DECLARE @intTransactionCount INT = @@TRANCOUNT;

	IF(@intTransactionCount = 0)
		BEGIN
			BEGIN TRAN @SavedPointTransaction
		END
	ELSE
		BEGIN
			SAVE TRAN @SavedPointTransaction --> Save point
		END
	--------------------------------------------------------------------------------------------  
	-- END Create Save Point.  
	-------------------------------------------------------------------------------------------- 


	DECLARE @GLEntries AS RecapTableType 

	SET @strStatusMsg = ''
	SET @ysnIsPosted = 0
	SET @strBatchId = ''

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
	DECLARE @strCategoryCode AS NVARCHAR(1000) = ''



	-- VALIDATE @isRequiredGLEntries = true
	DECLARE @tblTempItemCheck TABLE 
	(
		[intCategoryId] int NULL,
		[strCategoryCode] nvarchar(150) COLLATE Latin1_General_CI_AS NULL,
		[ysnHasItem] BIT
	)

	DECLARE @tblTempItemValuationCheck TABLE 
	(
		[intCategoryId] int NULL,
		[strCategoryCode] nvarchar(150) COLLATE Latin1_General_CI_AS NULL,
		[ysnHasItemValuation] BIT,
		[ysnHasItemCosting] BIT,
		[intLocationId] INT
	)

	--IF(@isRequiredGLEntries = CAST(1 AS BIT))
	--	BEGIN
	--		IF(@strType = 'Department Level')
	--			BEGIN
	--				INSERT INTO @tblTempItemCheck
	--				(
	--					intCategoryId,
	--					strCategoryCode,
	--					ysnHasItem
	--				)
	--				SELECT DISTINCT
	--					MD.intCategoryId,
	--					C.strCategoryCode,
	--					CASE
	--						WHEN I.intItemId IS NOT NULL THEN CAST(1 AS BIT) 
	--						ELSE CAST(0 AS BIT) 
	--					END as strResult
	--				FROM tblSTMarkUpDownDetail MD
	--				JOIN tblICCategory C ON MD.intCategoryId = C.intCategoryId
	--				JOIN tblICItem I ON MD.intCategoryId = I.intCategoryId
	--				JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId
	--				WHERE intMarkUpDownId = @intMarkUpDownId
	--				AND IL.intCostingMethod = 6
	--				AND IL.intIssueUOMId IS NOT NULL
	--				AND IL.intLocationId = @intLocationId

	--				IF NOT EXISTS(SELECT * FROM @tblTempItemCheck)
	--					BEGIN
	--						PRINT 'NO Item with same Category or No Item that has Category Costing Method and has Sale UOM.'

	--						SELECT @strCategoryCode = @strCategoryCode + C.strCategoryCode + ', '
	--						FROM tblSTMarkUpDownDetail MD
	--						JOIN tblICCategory C ON MD.intCategoryId = C.intCategoryId
	--						WHERE MD.intMarkUpDownId = @intMarkUpDownId

	--						ROLLBACK TRAN @TransactionName
	--						COMMIT TRAN @TransactionName
	--						SET @strStatusMsg = 'Category ' + @strCategoryCode + ' has no Item or no Category Costing Method and Sale UOM.'
	--						RETURN
	--					END
	--				ELSE IF EXISTS(SELECT * FROM @tblTempItemCheck)
	--					BEGIN
	--						PRINT 'Has Item with same Category and Has Item that has Category Costing Method and has Sale UOM.'

	--						INSERT INTO @tblTempItemValuationCheck
	--						(
	--							intCategoryId,
	--							strCategoryCode,
	--							ysnHasItemValuation,
	--							ysnHasItemCosting,
	--							intLocationId
	--						)
	--						SELECT DISTINCT
	--							MD.intCategoryId,
	--							C.strCategoryCode,
	--							CASE
	--								WHEN IV.intCategoryId IS NOT NULL THEN CAST(1 AS BIT) 
	--								ELSE CAST(0 AS BIT) 
	--							END as ysnHasItemValuation,
	--							CASE
	--								WHEN IV.dblEndingCost > 0 THEN CAST(1 AS BIT) 
	--								ELSE CAST(0 AS BIT) 
	--							END as ysnHasItemCosting,
	--						IV.intLocationId
	--						FROM tblSTMarkUpDownDetail MD
	--						JOIN tblICCategory C ON MD.intCategoryId = C.intCategoryId
	--						JOIN tblICRetailValuation IV ON MD.intCategoryId = IV.intCategoryId
	--						WHERE intMarkUpDownId = @intMarkUpDownId
	--						AND IV.intLocationId = @intLocationId

	--						IF NOT EXISTS(SELECT * FROM @tblTempItemValuationCheck)
	--							BEGIN
	--								PRINT 'NO Item Valuation or No Item Costing.'

	--								SELECT @strCategoryCode = @strCategoryCode + C.strCategoryCode + ', '
	--								FROM tblSTMarkUpDownDetail MD
	--								JOIN tblICCategory C ON MD.intCategoryId = C.intCategoryId
	--								WHERE MD.intMarkUpDownId = @intMarkUpDownId

	--								ROLLBACK TRAN @TransactionName
	--								COMMIT TRAN @TransactionName
	--								SET @strStatusMsg = 'Category ' + @strCategoryCode + ' has no Item Valuation or No Item Costing.'
	--								RETURN
	--							END
	--					END
	--				END
	--			END		
	---- END VALIDATE @isRequiredGLEntries = true


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
						-- Query all the MarkUp/Down for Item & Category managed
						SELECT		
								intItemId				= Item.intItemId--ISNULL(i.intItemId, CategoryItem.intItemId)
								,intItemLocationId		= ItemLocation.intItemLocationId --ISNULL(il.intItemLocationId, CategoryItem.intItemLocationId)
								,intItemUOMId			= ItemUOM.intItemUOMId --ISNULL(iu.intItemUOMId, CategoryItem.intItemUOMId)
								,dtmDate				= MU.dtmMarkUpDownDate
								,dblQty					= CASE
															WHEN MU.strType = @MarkUpType_DepartmentLevel THEN 0 ELSE MUD.intQty
														END
								,dblUOMQty				= 0
								,dblCost				= 0			
								,intTransactionId		= MU.intMarkUpDownId -- Parent Id
								,intTransactionDetailId	= MUD.intMarkUpDownDetailId -- Child Id
								,strTransactionId		= MU.strMarkUpDownNumber--@strMarkUpDownBatchId -- 'POS-10001'
								,intTransactionTypeId	= @InventoryTransactionType_MarkUpOrDown
								,intSubLocationId		= NULL -- Optional
								,intStorageLocationId	= NULL -- Optional 
								,intCurrencyId			= NULL -- Optional. You will use this if you are using multi-currency. 
								,intForexRateTypeId		= NULL -- Optional. You will use this if you are using multi-currency. 
								,dblForexRate			= 1 -- Optional. You will use this if you are using multi-currency. 
								,dblUnitRetail			= MUD.dblTotalRetailAmount
								,intCategoryId			= CASE
															WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.intCategoryId ELSE NULL
														END
								,dblAdjustCostValue		= MUD.dblTotalCostAmount
								,dblAdjustRetailValue	= MUD.dblTotalRetailAmount
						FROM tblSTMarkUpDownDetail MUD
						INNER JOIN tblSTMarkUpDown MU 
							ON MU.intMarkUpDownId = MUD.intMarkUpDownId	
						
						--TEST
						JOIN tblICCategory Category
							ON MUD.intCategoryId = Category.intCategoryId
						INNER JOIN tblICItem Item
							ON MUD.intItemId = Item.intItemId
						INNER JOIN tblICItemUOM ItemUOM
							ON Item.intItemId = ItemUOM.intItemId
						INNER JOIN tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = Item.intItemId 
							AND ItemLocation.intLocationId = @intLocationId 
							AND ItemLocation.intCostingMethod = 6 -- Category Costing Method = 6

						----If Item Manage, query item fields that are needed
						--LEFT JOIN (
						--	tblICItem i INNER JOIN tblICItemLocation il
						--		ON i.intItemId = il.intItemId AND il.intLocationId = @intLocationId
						--	INNER JOIN tblICItemUOM iu
						--		ON iu.intItemId = i.intItemId AND iu.intItemUOMId = il.intIssueUOMId-- Defaulted to issue uom id as per ST-313
						--	INNER JOIN tblICItemPricing ItemPricing
						--		ON ItemPricing.intItemId = i.intItemId AND ItemPricing.intItemLocationId = il.intItemLocationId
						--) ON i.intItemId = MUD.intItemId

						----Category Managed. Since item Ids are required, we'll fill those fields. This is just a temporary fix
						--OUTER APPLY ( 
						--	SELECT TOP 1	Item.intItemId,
						--					ItemLocation.intItemLocationId,
						--					ItemUOM.intItemUOMId
						--	FROM tblICCategoryPricing CategoryPricing
						--	INNER JOIN tblICItem Item
						--		ON CategoryPricing.intCategoryId = MUD.intCategoryId AND CategoryPricing.dblTotalCostValue > 0
						--	INNER JOIN tblICItemLocation ItemLocation
						--		ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId = @intLocationId AND ItemLocation.intCostingMethod = 6 -- Category Costing Method = 6
						--	INNER JOIN tblICItemUOM ItemUOM
						--		ON ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId
						--	WHERE Item.intCategoryId = MUD.intCategoryId
						--) CategoryItem
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
								,dblUnitRetail
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
								,dblCost				= 0--CASE
														--	WHEN MU.strType = @MarkUpType_ItemLevel THEN [dbo].[fnCalculateCostBetweenUOM](
														--		dbo.fnGetItemStockUOM(MUD.intItemId)
														--		,iu.intItemUOMId
														--		,ItemPricing.dblLastCost
														--	)
														--	ELSE 0
														--END
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
															WHEN MU.strType = @MarkUpType_ItemLevel THEN MUD.dblRetailPerUnit
															ELSE NULL
														END

								-- Department Manage
								,intCategoryId			= CASE
															WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.intCategoryId ELSE NULL
														END
								,dblAdjustCostValue		= CASE
															WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.dblTotalCostAmount * -1 ELSE NULL
														END
								,dblAdjustRetailValue	= CASE
															WHEN MU.strType = @MarkUpType_DepartmentLevel THEN MUD.dblTotalRetailAmount * -1  ELSE NULL -- -200 -- $$$ value to adjust the retail value.
														END 

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
						--OUTER APPLY ( 
						--	SELECT TOP 1	Item.intItemId,
						--					ItemLocation.intItemLocationId,
						--					ItemUOM.intItemUOMId
						--	FROM tblICCategoryPricing CategoryPricing
						--	INNER JOIN tblICItem Item
						--		ON CategoryPricing.intCategoryId = MUD.intCategoryId AND CategoryPricing.dblTotalCostValue > 0
						--	INNER JOIN tblICItemLocation ItemLocation
						--		ON ItemLocation.intItemId = Item.intItemId AND ItemLocation.intLocationId = @intLocationId AND ItemLocation.intCostingMethod = 6 -- Category Costing Method = 6
						--	INNER JOIN tblICItemUOM ItemUOM
						--		ON ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId
						--	WHERE Item.intCategoryId = MUD.intCategoryId
						--) CategoryItem
						OUTER APPLY ( 
							SELECT TOP 1
								item.intItemId,
								ItemLocation.intItemLocationId,
								ItemUOM.intItemUOMId
							FROM tblICCategoryLocation catLoc
							INNER JOIN tblICCategory cat
								ON catLoc.intCategoryId = cat.intCategoryId
							INNER JOIN tblICItem item
								ON catLoc.intGeneralItemId = item.intItemId
							INNER JOIN tblICItemLocation ItemLocation
								ON ItemLocation.intItemId = item.intItemId 
								AND ItemLocation.intLocationId = @intLocationId  
								AND ItemLocation.intCostingMethod = 6 -- Category Costing Method = 6
							INNER JOIN tblICItemUOM ItemUOM
								ON ItemUOM.intItemUOMId = ItemLocation.intIssueUOMId
							WHERE item.intCategoryId = MUD.intCategoryId
						) CategoryItem
						WHERE MU.intMarkUpDownId = @intMarkUpDownId
				END

			-- COMMIT HERE Note sure
			--COMMIT TRANSACTION @SavedPointTransaction

			-- Generate New Batch Id
			IF(@ysnRecap = CAST(1 AS BIT))
				BEGIN
					SET @strBatchId = CAST(NEWID() AS NVARCHAR(100))
				END
			ELSE
				BEGIN
					EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 
				END
			


			-- Process Adjustments
			IF EXISTS(SELECT TOP 1 1 FROM @ItemsForPost)
			BEGIN
				EXEC @intReturnValue = dbo.uspICPostCosting  
						@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intCurrentUserId

				--IF @intReturnValue < 0 GOTO With_Rollback_Exit
				IF (@intReturnValue < 0)
					BEGIN
						IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0))  
							BEGIN 
								ROLLBACK TRANSACTION @SavedPointTransaction;
							END
					END
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
							,[intSourceEntityId]
							,[intCommodityId]
					)
					EXEC @intReturnValue = dbo.uspICCreateGLEntries 
						@strBatchId
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@intCurrentUserId
						,@strAdjustmentType




					--IF @intReturnValue < 0 GOTO With_Rollback_Exit
					IF (@intReturnValue < 0)
						BEGIN
							IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0))  
								BEGIN 
									ROLLBACK TRANSACTION @SavedPointTransaction;
								END
						END
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


			-- Generate New Batch Id
			IF(@ysnRecap = CAST(1 AS BIT))
				BEGIN
					SET @strBatchId = CAST(NEWID() AS NVARCHAR(100))
				END
			ELSE
				BEGIN
					EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 
				END


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
						,[intSourceEntityId]
						,[intCommodityId]
				)
				EXEC @intReturnValue = dbo.uspICUnpostCosting  
						@intMarkUpDownId  
						,@strMarkUpDownBatchId  
						,@strBatchId --New BatchId
						,@intCurrentUserId
						,0

				--IF @intReturnValue < 0 GOTO With_Rollback_Exit
				IF (@intReturnValue < 0) 
					BEGIN
						IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0))  
						BEGIN 
							ROLLBACK TRANSACTION @SavedPointTransaction;
						END
					END

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

			---------------------------------------------------------------------------------------
			----------- MANIPULATE TRANSACTION ----------------------------------------------------
			---------------------------------------------------------------------------------------
			-- ROLLBACK TRANSACTION
			IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0))  
				BEGIN 
					ROLLBACK TRANSACTION @SavedPointTransaction;
				END

			-- BEGIN TRANSACTION to COMMIT
			BEGIN TRAN @SavedPointTransaction
			---------------------------------------------------------------------------------------
			--------- END MANIPULATE TRANSACTION --------------------------------------------------
			---------------------------------------------------------------------------------------


			--SET @strBatchId = NEWID();
			IF EXISTS(SELECT * FROM @GLEntries)
			BEGIN
				-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
				EXEC dbo.uspGLPostRecap 
					@GLEntries
					,@intCurrentUserId
			END
			
			-- Commit Transaction
			IF(@intTransactionCount = 0)
				BEGIN
					COMMIT TRANSACTION @SavedPointTransaction
					GOTO Post_Exit;
				END	
		END
	ELSE
		BEGIN
			IF @isRequiredGLEntries = 1
			BEGIN 
				IF(EXISTS(SELECT * FROM @GLEntries))
				BEGIN
					EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
				END
			END		

			-- IF SUCCESS Commit Transaction
			IF(@intTransactionCount = 0)
				BEGIN
					COMMIT TRANSACTION @SavedPointTransaction
					GOTO Post_Exit;
				END
		END
END TRY

BEGIN CATCH
	SET @strStatusMsg = ERROR_MESSAGE()
	GOTO With_Rollback_Exit;
END CATCH


With_Rollback_Exit:
IF (XACT_STATE() = 1 OR (@intTransactionCount = 0 AND XACT_STATE() <> 0))  
	BEGIN 
		ROLLBACK TRANSACTION @SavedPointTransaction;
	END

--EXIT here
Post_Exit:
