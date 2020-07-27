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
SET ANSI_WARNINGS OFF

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

IF @Post = 1
BEGIN
    INSERT INTO #ARInvoiceGLEntries
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
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId])
    SELECT 
         [dtmDate]						= CAST(ISNULL(P.[dtmPostDate], P.[dtmDate]) AS DATE)
        ,[strBatchId]					= P.[strBatchId]
        ,[intAccountId]					= GL.[intAccountId]
        ,[dblDebit]						= GL.[dblCredit]
        ,[dblCredit]					= GL.[dblDebit]
        ,[dblDebitUnit]					= GL.[dblCreditUnit]
        ,[dblCreditUnit]				= GL.[dblDebitUnit]
        ,[strDescription]				= 'Reverse Provisional Invoice' + ISNULL((' - ' + GL.strDescription), '')
        ,[strCode]						= @CODE
        ,[strReference]					= GL.[strReference]
        ,[intCurrencyId]				= GL.[intCurrencyId]
        ,[dblExchangeRate]				= GL.[dblExchangeRate]
        ,[dtmDateEntered]				= P.[dtmDatePosted]
        ,[dtmTransactionDate]			= P.[dtmDate]
        ,[strJournalLineDescription]	= GL.[strJournalLineDescription]
        ,[intJournalLineNo]				= P.[intOriginalInvoiceId]
        ,[ysnIsUnposted]				= 0
        ,[intUserId]					= P.[intUserId]
        ,[intEntityId]					= P.[intUserId]
        ,[strTransactionId]				= P.[strInvoiceNumber]
        ,[intTransactionId]				= P.[intInvoiceId]
        ,[strTransactionType]			= P.[strTransactionType]
        ,[strTransactionForm]			= @SCREEN_NAME
        ,[strModuleName]				= @MODULE_NAME
        ,[intConcurrencyId]				= 1
        ,[dblDebitForeign]				= GL.[dblCreditForeign]
        ,[dblDebitReport]				= GL.[dblCreditReport]
        ,[dblCreditForeign]				= GL.[dblDebitForeign]
        ,[dblCreditReport]				= GL.[dblDebitReport]
        ,[dblReportingRate]				= GL.[dblReportingRate]
        ,[dblForeignRate]				= GL.[dblForeignRate]
        ,[strDocument]					= GL.[strDocument]
        ,[strComments]					= GL.[strComments]
        ,[strSourceDocumentId]			= GL.[strSourceDocumentId]
        ,[intSourceLocationId]			= GL.[intSourceLocationId]
        ,[intSourceUOMId]				= GL.[intSourceUOMId]
        ,[dblSourceUnitDebit]			= GL.[dblSourceUnitCredit]
        ,[dblSourceUnitCredit]			= GL.[dblSourceUnitDebit]
        ,[intCommodityId]				= GL.[intCommodityId]
        ,[intSourceEntityId]			= GL.[intSourceEntityId]
    FROM (
        SELECT 
			 [intOriginalInvoiceId]
			,[strBatchId]
			,[intInvoiceId]
			,[dtmPostDate]
			,[dtmDate]
			,[dtmDatePosted]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[strInvoiceOriginId]
			,[intUserId]
        FROM
			#ARPostInvoiceHeader
        WHERE
			[intOriginalInvoiceId] IS NOT NULL
			AND [ysnFromProvisional] = 1
			AND [ysnProvisionalWithGL] = 1 
            AND [ysnPost] = 1
			AND (
                ([strTransactionType] <> 'Credit Memo'	AND [dblBaseInvoiceTotal] = 0.000000 AND [dblInvoiceTotal] = 0.000000)
                OR
                ([strTransactionType] = 'Credit Memo' AND [dblBaseInvoiceTotal] <> 0.000000 AND [dblProvisionalAmount] <> 0.000000)
				OR
				([strTransactionType] = 'Invoice' AND [dblBaseInvoiceTotal] <> 0.000000 AND [dblProvisionalAmount] <> 0.000000 AND [dblAmountDue] <> 0.000000)
				)
    ) P
    INNER JOIN (
        SELECT 
			 [intAccountId]
			,[intGLDetailId]
			,[intTransactionId]
			,[strTransactionId]
			,[dblCredit]
			,[dblDebit]
			,[dblCreditUnit]
			,[dblDebitUnit]
			,[strReference]
			,[strDescription]
			,[strJournalLineDescription]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strDocument]
			,[strComments]
			,[strSourceDocumentId]
			,[intSourceLocationId]
			,[intSourceUOMId]
			,[dblSourceUnitDebit]
			,[dblSourceUnitCredit]
			,[intCommodityId]
			,[intSourceEntityId]
        FROM
			tblGLDetail WITH (NOLOCK)
        WHERE 
            [ysnIsUnposted] = 0
            AND [strModuleName] = @MODULE_NAME
    ) GL ON P.[intOriginalInvoiceId] = GL.[intTransactionId]
        AND P.[strInvoiceOriginId] = GL.[strTransactionId]
    ORDER BY GL.intGLDetailId				
END

IF @Post = 1
EXEC [dbo].[uspARGenerateGLEntriesForInvoices]

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
	#ARItemsForCosting
WHERE
	[ysnForValidation] IS NULL
	OR [ysnForValidation] = 0

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
BEGIN
    -- Call the post routine 
    INSERT INTO #ARInvoiceGLEntries (
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
				
IF @Post = 1
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
FROM 
	#ARItemsForInTransitCosting

IF EXISTS (SELECT TOP 1 1 FROM @InTransitItems)
BEGIN 
    -- Call the post routine 
    INSERT INTO #ARInvoiceGLEntries
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
	JOIN #ARInvoiceGLEntries B ON A.intInventoryTransactionId = B.intJournalLineNo
							  AND A.intTransactionId = B.intTransactionId
							  AND A.strTransactionId = B.strTransactionId
	JOIN #ARItemsForInTransitCosting C ON A.intTransactionId = C.intTransactionId
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
	#ARItemsForStorageCosting

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
BEGIN 
    -- Call the post routine 
    INSERT INTO #ARInvoiceGLEntries
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

IF @Post = 0
BEGIN
    INSERT INTO #ARInvoiceGLEntries
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
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId])
    SELECT 
         [dtmDate]						= GLD.[dtmDate]
        ,[strBatchId]					= @BatchId
        ,[intAccountId]					= GLD.[intAccountId]
        ,[dblDebit]						= GLD.[dblCredit]
        ,[dblCredit]					= GLD.[dblDebit]
        ,[dblDebitUnit]					= GLD.[dblCreditUnit]
        ,[dblCreditUnit]				= GLD.[dblDebitUnit]
        ,[strDescription]				= GLD.[strDescription]
        ,[strCode]						= GLD.[strCode]
        ,[strReference]					= GLD.[strReference]
        ,[intCurrencyId]				= GLD.[intCurrencyId]
        ,[dblExchangeRate]				= GLD.[dblExchangeRate]
        ,[dtmDateEntered]				= PID.[dtmDatePosted]
        ,[dtmTransactionDate]			= GLD.[dtmTransactionDate]
        ,[strJournalLineDescription]	= REPLACE(GLD.[strJournalLineDescription], 'Posted ', 'Unposted ')
        ,[intJournalLineNo]				= GLD.[intJournalLineNo]
        ,[ysnIsUnposted]				= 1
        ,[intUserId]					= GLD.[intUserId]
        ,[intEntityId]					= GLD.[intUserId]
        ,[strTransactionId]				= GLD.[strTransactionId]
        ,[intTransactionId]				= GLD.[intTransactionId]
        ,[strTransactionType]			= GLD.[strTransactionType]
        ,[strTransactionForm]			= GLD.[strTransactionForm]
        ,[strModuleName]				= GLD.[strModuleName]
        ,[intConcurrencyId]				= 1
        ,[dblDebitForeign]				= GLD.[dblCreditForeign]
        ,[dblDebitReport]				= GLD.[dblCreditReport]
        ,[dblCreditForeign]				= GLD.[dblDebitForeign]
        ,[dblCreditReport]				= GLD.[dblDebitReport]
        ,[dblReportingRate]				= GLD.[dblReportingRate]
        ,[dblForeignRate]				= GLD.[dblForeignRate]
        ,[strDocument]					= GLD.[strDocument]
        ,[strComments]					= GLD.[strComments]
        ,[strSourceDocumentId]			= GLD.[strSourceDocumentId]
        ,[intSourceLocationId]			= GLD.[intSourceLocationId]
        ,[intSourceUOMId]				= GLD.[intSourceUOMId]
        ,[dblSourceUnitDebit]			= GLD.[dblSourceUnitCredit]
        ,[dblSourceUnitCredit]			= GLD.[dblSourceUnitDebit]
        ,[intCommodityId]				= GLD.[intCommodityId]
        ,[intSourceEntityId]			= GLD.[intSourceEntityId]
    FROM
		#ARPostInvoiceHeader PID
    INNER JOIN
        tblGLDetail GLD
            ON PID.[intInvoiceId] = GLD.[intTransactionId]
            AND PID.[strInvoiceNumber] = GLD.[strTransactionId]							 
    WHERE
         GLD.[ysnIsUnposted] = 0
    ORDER BY
        GLD.[intGLDetailId]
END

UPDATE #ARInvoiceGLEntries
SET [dtmDateEntered] = @PostDate
   ,[strBatchId]     = @BatchId

UPDATE GL
SET GL.intSourceEntityId = I.intEntityCustomerId
  , GL.intEntityId		 = I.intEntityId
FROM #ARInvoiceGLEntries GL
INNER JOIN tblARInvoice I ON GL.strTransactionId = I.strInvoiceNumber
						 AND GL.intTransactionId = I.intInvoiceId
WHERE GL.intSourceEntityId IS NULL
 
RETURN 0
