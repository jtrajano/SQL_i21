CREATE PROCEDURE [dbo].[uspARGenerateGLEntries]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@UserId            INT             = NULL    
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS ON

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '
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
    ,[dblAdjustRetailValue]
	,[strBOLNumber]
	,[strSourceNumber]
	,[strSourceType]
	,[intSourceEntityId]
) 
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
	,[strBOLNumber]
	,[strSourceNumber]
	,[strSourceType]
	,[intSourceEntityId]
FROM 
	##ARItemsForCosting

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
BEGIN
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
    ,[dblForexRate]
	,[strBOLNumber]	
)
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
	,[strBOLNumber]
FROM ##ARItemsForInTransitCosting

IF EXISTS (SELECT TOP 1 1 FROM @InTransitItems)
BEGIN		 --Call the post routine 
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
	,[strBOLNumber]
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
	,[strBOLNumber]
FROM 
	##ARItemsForStorageCosting

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
BEGIN 
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
