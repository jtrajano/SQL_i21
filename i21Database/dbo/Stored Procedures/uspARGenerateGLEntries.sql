CREATE PROCEDURE [dbo].[uspARGenerateGLEntries]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@UserId            INT             = NULL
    ,@raiseError        BIT             = 1
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE @ErrorMerssage		NVARCHAR(MAX) = NULL	  
	  , @InitTranCount		INT
	  , @CurrentTranCount	INT
	  , @Savepoint			NVARCHAR(32)
	  , @CurrentSavepoint	NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = 'uspARGenerateGLEntries'

IF ISNULL(@raiseError,0) = 0	
	BEGIN
		IF @InitTranCount = 0
			BEGIN TRANSACTION
		ELSE
			BEGIN
				COMMIT TRANSACTION
				BEGIN TRANSACTION @Savepoint
			END
	END

DECLARE  @AVERAGECOST   INT = 1
		,@FIFO          INT = 2
        ,@LIFO          INT = 3
        ,@LOTCOST       INT = 4
        ,@ACTUALCOST    INT = 5

--Update onhand
-- Get the items to post
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'
DECLARE @ItemsForPost AS ItemCostingTableType

IF @Post = 1

INSERT INTO @ItemsForPost
    ([intItemId]
    ,[intItemLocationId]
    ,[intItemUOMId]
    ,[dtmDate]
    ,[dblQty]
    ,[dblUOMQty]
    ,[dblCost]
    ,[dblValue]
    ,[dblSalesPrice]
    ,[intCurrencyId]
    ,[dblExchangeRate]
    ,[intTransactionId]
    ,[intTransactionDetailId]
    ,[strTransactionId]
    ,[intTransactionTypeId]
    ,[intLotId]
    ,[intSubLocationId]
    ,[intStorageLocationId]
    ,[ysnIsStorage]
    ,[strActualCostId]
    ,[intSourceTransactionId]
    ,[strSourceTransactionId]
    ,[intInTransitSourceLocationId]
    ,[intForexRateTypeId]
    ,[dblForexRate]
    ,[intStorageScheduleTypeId]
    ,[dblUnitRetail]
    ,[intCategoryId]
    ,[dblAdjustRetailValue]) 
SELECT 
     [intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[dtmDate]
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[intTransactionDetailId]
	,[strTransactionId]
	,[intTransactionTypeId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[ysnIsStorage]
	,[strActualCostId]
	,[intSourceTransactionId]
	,[strSourceTransactionId]
	,[intInTransitSourceLocationId]
	,[intForexRateTypeId]
	,[dblForexRate]
	,[intStorageScheduleTypeId]
	,[dblUnitRetail]
	,[intCategoryId]
	,[dblAdjustRetailValue]
FROM 
	##ARItemsForCosting

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
BEGIN
	BEGIN TRY
		-- Call the post routine 
		INSERT INTO ##ARInvoiceGLEntries (
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
		EXEC dbo.uspICPostCosting  
			 @ItemsForPost  
			,@BatchId  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@UserId
	END TRY
	BEGIN CATCH
		SELECT @ErrorMerssage = ERROR_MESSAGE()
		IF @raiseError = 0
			BEGIN
				ROLLBACK TRANSACTION @Savepoint
				
				SET @CurrentTranCount = @@TRANCOUNT
				SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
				IF @CurrentTranCount = 0
					BEGIN TRANSACTION
				ELSE
					SAVE TRANSACTION @CurrentSavepoint
						
				INSERT INTO ##ARInvalidInventories (
					 [strMessage]
					,[strTransactionType]
					,[strTransactionId]
					,[strBatchNumber]
					,[intTransactionId]
				)
				SELECT DISTINCT
					 [strError]             = @ErrorMerssage
					,[strTransactionType]   = IH.[strTransactionType] 
					,[strTransactionId]     = IH.[strInvoiceNumber]
					,[strBatchNumber]       = @BatchId
					,[intTransactionId]     = IH.[intInvoiceId] 
				FROM ##ARPostInvoiceHeader IH
				INNER JOIN ##ARItemsForCosting COSTING ON IH.strInvoiceNumber = COSTING.strTransactionId AND IH.intInvoiceId = COSTING.intTransactionId
				LEFT JOIN (
					SELECT DISTINCT intTransactionId
								  , strTransactionId
					FROM tblICInventoryTransaction
					WHERE strTransactionForm = 'Invoice'
					  AND ysnIsUnposted = 0
				) ICT ON IH.strInvoiceNumber = ICT.strTransactionId AND IH.intInvoiceId = ICT.intTransactionId
				WHERE ICT.intTransactionId IS NULL

				SET @CurrentTranCount = @@TRANCOUNT

				IF @CurrentTranCount = 0
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION
						IF (XACT_STATE()) = 1
							COMMIT TRANSACTION @CurrentSavepoint
					END		
				ELSE
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION  @CurrentSavepoint
					END	
			END						
		IF @raiseError = 1
			RAISERROR(@ErrorMerssage, 11, 1)
	END CATCH
END

DECLARE  @InTransitItems                ItemInTransitCostingTableType 
		,@FOB_ORIGIN                    INT = 1
		,@FOB_DESTINATION               INT = 2	
				
IF @Post = 1 OR (@Post = 0 AND EXISTS(SELECT TOP 1 1 FROM ##ARPostInvoiceDetail WHERE intSourceId = 2))
INSERT INTO @InTransitItems
    ([intItemId] 
    ,[intItemLocationId] 
    ,[intItemUOMId] 
    ,[dtmDate] 
    ,[dblQty] 
    ,[dblUOMQty] 
    ,[dblCost] 
    ,[dblValue] 
    ,[dblSalesPrice] 
    ,[intCurrencyId] 
    ,[dblExchangeRate] 
    ,[intTransactionId] 
    ,[intTransactionDetailId] 
    ,[strTransactionId] 
    ,[intTransactionTypeId] 
    ,[intLotId] 
    ,[intSourceTransactionId] 
    ,[strSourceTransactionId] 
    ,[intSourceTransactionDetailId] 
    ,[intFobPointId] 
    ,[intInTransitSourceLocationId]
    ,[intForexRateTypeId]
    ,[dblForexRate])
SELECT
     [intItemId] 
    ,[intItemLocationId] 
    ,[intItemUOMId] 
    ,[dtmDate] 
    ,[dblQty] 
    ,[dblUOMQty] 
    ,[dblCost] 
    ,[dblValue] 
    ,[dblSalesPrice] 
    ,[intCurrencyId] 
    ,[dblExchangeRate] 
    ,[intTransactionId] 
    ,[intTransactionDetailId] 
    ,[strTransactionId] 
    ,[intTransactionTypeId] 
    ,[intLotId] 
    ,[intSourceTransactionId] 
    ,[strSourceTransactionId] 
    ,[intSourceTransactionDetailId] 
    ,[intFobPointId] 
    ,[intInTransitSourceLocationId]
    ,[intForexRateTypeId]
    ,[dblForexRate]
FROM ##ARItemsForInTransitCosting

IF EXISTS (SELECT TOP 1 1 FROM @InTransitItems)
BEGIN
	BEGIN TRY 
		 --Call the post routine 
		INSERT INTO ##ARInvoiceGLEntries
			([dtmDate] 
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
			,[intSourceEntityId]
			,[intCommodityId]
		)
		EXEC dbo.uspICPostInTransitCosting  
			 @InTransitItems  
			,@BatchId  
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@UserId
	END TRY
	BEGIN CATCH
		SELECT @ErrorMerssage = ERROR_MESSAGE()
		IF @raiseError = 0
			BEGIN
				ROLLBACK TRANSACTION @Savepoint
				
				SET @CurrentTranCount = @@TRANCOUNT
				SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
				IF @CurrentTranCount = 0
					BEGIN TRANSACTION
				ELSE
					SAVE TRANSACTION @CurrentSavepoint
						
				INSERT INTO ##ARInvalidInventories (
					 [strMessage]
					,[strTransactionType]
					,[strTransactionId]
					,[strBatchNumber]
					,[intTransactionId]
				)
				SELECT DISTINCT
					 [strError]             = @ErrorMerssage
					,[strTransactionType]   = IH.[strTransactionType] 
					,[strTransactionId]     = IH.[strInvoiceNumber]
					,[strBatchNumber]       = @BatchId
					,[intTransactionId]     = IH.[intInvoiceId] 
				FROM ##ARPostInvoiceHeader IH
				INNER JOIN ##ARItemsForInTransitCosting INTRANSIT ON IH.strInvoiceNumber = INTRANSIT.strTransactionId AND IH.intInvoiceId = INTRANSIT.intTransactionId
				LEFT JOIN (
					SELECT DISTINCT intTransactionId
								  , strTransactionId
					FROM tblICInventoryTransaction
					WHERE strTransactionForm = 'Invoice'
					  AND ysnIsUnposted = 0
				) ICT ON IH.strInvoiceNumber = ICT.strTransactionId AND IH.intInvoiceId = ICT.intTransactionId
				WHERE ICT.intTransactionId IS NULL

				SET @CurrentTranCount = @@TRANCOUNT

				IF @CurrentTranCount = 0
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION
						IF (XACT_STATE()) = 1
							COMMIT TRANSACTION @CurrentSavepoint
					END		
				ELSE
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION  @CurrentSavepoint
					END	
			END						
		IF @raiseError = 1
			RAISERROR(@ErrorMerssage, 11, 1)
	END CATCH

	UPDATE B
	SET intAccountId = dbo.fnGetItemGLAccount(C.intLinkedItemId, A.intItemLocationId, 'Cost Of Goods')		
	FROM tblICInventoryTransaction  A
	JOIN ##ARInvoiceGLEntries B ON A.intInventoryTransactionId = B.intJournalLineNo
							  AND A.intTransactionId = B.intTransactionId
							  AND A.strTransactionId = B.strTransactionId
	JOIN ##ARItemsForInTransitCosting C ON A.intTransactionId = C.intTransactionId
					             AND A.strTransactionId = C.strTransactionId
					             AND A.intTransactionDetailId =  C.intTransactionDetailId 
					             AND A.intItemId = C.intItemId
					             AND A.intItemLocationId = C.intItemLocationId
	WHERE A.strBatchId = @BatchId
	  AND C.intLinkedItemId IS NOT NULL
	  AND dbo.fnGetItemGLAccount(A.intItemId, A.intItemLocationId, 'Cost of Goods') = B.intAccountId

END

DECLARE @StorageItemsForPost AS ItemCostingTableType  			

IF @Post = 1
INSERT INTO @StorageItemsForPost (  
     [intItemId] 
    ,[intItemLocationId] 
    ,[intItemUOMId]
    ,[dtmDate]
    ,[dblQty]
    ,[dblUOMQty]
    ,[dblCost]
    ,[dblSalesPrice]
    ,[intCurrencyId] 
    ,[dblExchangeRate]
    ,[intTransactionId] 
    ,[intTransactionDetailId]
    ,[strTransactionId]  
    ,[intTransactionTypeId]  
    ,[intLotId] 
    ,[intSubLocationId]
    ,[intStorageLocationId]
    ,[strActualCostId]
) 
SELECT 
     [intItemId] 
    ,[intItemLocationId] 
    ,[intItemUOMId]
    ,[dtmDate]
    ,[dblQty]
    ,[dblUOMQty]
    ,[dblCost]
    ,[dblSalesPrice]
    ,[intCurrencyId] 
    ,[dblExchangeRate]
    ,[intTransactionId] 
    ,[intTransactionDetailId]
    ,[strTransactionId]  
    ,[intTransactionTypeId]  
    ,[intLotId] 
    ,[intSubLocationId]
    ,[intStorageLocationId]
    ,[strActualCostId]
FROM 
	##ARItemsForStorageCosting

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
BEGIN 
	BEGIN TRY
		-- Call the post routine 
		INSERT INTO ##ARInvoiceGLEntries
			([dtmDate] 
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
			,[intSourceEntityId]
			,[intCommodityId]
		)
		EXEC dbo.uspICPostStorage  
				 @StorageItemsForPost  
				,@BatchId  		
				,@UserId
	END TRY
	BEGIN CATCH
		SELECT @ErrorMerssage = ERROR_MESSAGE()
		IF @raiseError = 0
			BEGIN
				ROLLBACK TRANSACTION @Savepoint
				
				SET @CurrentTranCount = @@TRANCOUNT
				SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
				IF @CurrentTranCount = 0
					BEGIN TRANSACTION
				ELSE
					SAVE TRANSACTION @CurrentSavepoint
						
				INSERT INTO ##ARInvalidInventories (
					 [strMessage]
					,[strTransactionType]
					,[strTransactionId]
					,[strBatchNumber]
					,[intTransactionId]
				)
				SELECT DISTINCT
					 [strError]             = @ErrorMerssage
					,[strTransactionType]   = IH.[strTransactionType] 
					,[strTransactionId]     = IH.[strInvoiceNumber]
					,[strBatchNumber]       = @BatchId
					,[intTransactionId]     = IH.[intInvoiceId] 
				FROM ##ARPostInvoiceHeader IH
				INNER JOIN ##ARItemsForStorageCosting STORAGE ON IH.strInvoiceNumber = STORAGE.strTransactionId AND IH.intInvoiceId = STORAGE.intTransactionId
				LEFT JOIN (
					SELECT DISTINCT intTransactionId
								  , strTransactionId
					FROM tblICInventoryTransaction
					WHERE strTransactionForm = 'Invoice'
					  AND ysnIsUnposted = 0
				) ICT ON IH.strInvoiceNumber = ICT.strTransactionId AND IH.intInvoiceId = ICT.intTransactionId				
				WHERE ICT.intTransactionId IS NULL

				SET @CurrentTranCount = @@TRANCOUNT

				IF @CurrentTranCount = 0
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION
						IF (XACT_STATE()) = 1
							COMMIT TRANSACTION @CurrentSavepoint
					END		
				ELSE
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION  @CurrentSavepoint
					END	
			END						
		IF @raiseError = 1
			RAISERROR(@ErrorMerssage, 11, 1)
	END CATCH
END

UPDATE ##ARInvoiceGLEntries
SET [dtmDateEntered] = @PostDate
   ,[strBatchId]     = @BatchId

UPDATE GL
SET GL.intSourceEntityId = I.intEntityCustomerId
  , GL.intEntityId		 = I.intEntityId
FROM ##ARInvoiceGLEntries GL
INNER JOIN tblARInvoice I ON GL.strTransactionId = I.strInvoiceNumber
						 AND GL.intTransactionId = I.intInvoiceId
WHERE GL.intSourceEntityId IS NULL
 
RETURN 0
