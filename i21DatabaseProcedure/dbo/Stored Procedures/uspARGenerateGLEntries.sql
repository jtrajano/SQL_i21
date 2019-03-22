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

--IF(OBJECT_ID('tempdb..#ARInvoiceGLEntries') IS NULL)
--BEGIN
--CREATE TABLE #ARInvoiceGLEntries
--	([dtmDate]                   DATETIME         NOT NULL,
--	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
--	[intAccountId]              INT              NULL,
--	[dblDebit]                  NUMERIC (18, 6)  NULL,
--	[dblCredit]                 NUMERIC (18, 6)  NULL,
--	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
--	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
--	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
--	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
--	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
--	[intCurrencyId]             INT              NULL,
--	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
--	[dtmDateEntered]            DATETIME         NOT NULL,
--	[dtmTransactionDate]        DATETIME         NULL,
--	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
--	[intJournalLineNo]			INT              NULL,
--	[ysnIsUnposted]             BIT              NOT NULL,    
--	[intUserId]                 INT              NULL,
--	[intEntityId]				INT              NULL,
--	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
--	[intTransactionId]          INT              NULL,
--	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
--	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
--	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
--	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
--	[dblDebitForeign]			NUMERIC (18, 9) NULL,
--	[dblDebitReport]			NUMERIC (18, 9) NULL,
--	[dblCreditForeign]			NUMERIC (18, 9) NULL,
--	[dblCreditReport]			NUMERIC (18, 9) NULL,
--	[dblReportingRate]			NUMERIC (18, 9) NULL,
--	[dblForeignRate]			NUMERIC (18, 9) NULL,
--	[intCurrencyExchangeRateTypeId] INT NULL,
--	[strRateType]			    NVARCHAR(50)	COLLATE Latin1_General_CI_AS,
--	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
--	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
--	[strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
--	[intSourceLocationId]		INT NULL,
--	[intSourceUOMId]			INT NULL,
--	[dblSourceUnitDebit]		NUMERIC (18, 6)  NULL,
--	[dblSourceUnitCredit]		NUMERIC (18, 6)  NULL,
--	[intCommodityId]			INT NULL,
--	intSourceEntityId INT NULL,
--	ysnRebuild BIT NULL)
--END

--DECLARE @PostingGLEntries AS RecapTableType

IF @Post = 1 --AND EXISTS(SELECT NULL FROM #ARPostInvoiceHeader WHERE intOriginalInvoiceId IS NOT NULL AND [intSourceId] IS NOT NULL AND intOriginalInvoiceId <> 0 AND [intSourceId] = 2)
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
						
--INSERT INTO @PostingGLEntries
--    ([dtmDate]
--    ,[strBatchId]
--    ,[intAccountId]
--    ,[dblDebit]
--    ,[dblCredit]
--    ,[dblDebitUnit]
--    ,[dblCreditUnit]
--    ,[strDescription]
--    ,[strCode]
--    ,[strReference]
--    ,[intCurrencyId]
--    ,[dblExchangeRate]
--    ,[dtmDateEntered]
--    ,[dtmTransactionDate]
--    ,[strJournalLineDescription]
--    ,[intJournalLineNo]
--    ,[ysnIsUnposted]
--    ,[intUserId]
--    ,[intEntityId]
--    ,[strTransactionId]
--    ,[intTransactionId]
--    ,[strTransactionType]
--    ,[strTransactionForm]
--    ,[strModuleName]
--    ,[intConcurrencyId]
--    ,[dblDebitForeign]
--    ,[dblDebitReport]
--    ,[dblCreditForeign]
--    ,[dblCreditReport]
--    ,[dblReportingRate]
--    ,[dblForeignRate]
--    ,[strRateType]
--    ,[strDocument]
--    ,[strComments]
--    ,[strSourceDocumentId]
--    ,[intSourceLocationId]
--    ,[intSourceUOMId]
--    ,[dblSourceUnitDebit]
--    ,[dblSourceUnitCredit]
--    ,[intCommodityId]
--    ,[intSourceEntityId]
--    ,[ysnRebuild])
--SELECT
--     [dtmDate]
--    ,[strBatchId]
--    ,[intAccountId]
--    ,[dblDebit]
--    ,[dblCredit]
--    ,[dblDebitUnit]
--    ,[dblCreditUnit]
--    ,[strDescription]
--    ,[strCode]
--    ,[strReference]
--    ,[intCurrencyId]
--    ,[dblExchangeRate]
--    ,[dtmDateEntered]
--    ,[dtmTransactionDate]
--    ,[strJournalLineDescription]
--    ,[intJournalLineNo]
--    ,[ysnIsUnposted]
--    ,[intUserId]
--    ,[intEntityId]
--    ,[strTransactionId]
--    ,[intTransactionId]
--    ,[strTransactionType]
--    ,[strTransactionForm]
--    ,[strModuleName]
--    ,[intConcurrencyId]
--    ,[dblDebitForeign]
--    ,[dblDebitReport]
--    ,[dblCreditForeign]
--    ,[dblCreditReport]
--    ,[dblReportingRate]
--    ,[dblForeignRate]
--    ,[strRateType]
--    ,[strDocument]
--    ,[strComments]
--    ,[strSourceDocumentId]
--    ,[intSourceLocationId]
--    ,[intSourceUOMId]
--    ,[dblSourceUnitDebit]
--    ,[dblSourceUnitCredit]
--    ,[intCommodityId]
--    ,[intSourceEntityId]
--    ,[ysnRebuild]
--FROM
--    #ARInvoiceGLEntries

--DELETE FROM #ARInvoiceGLEntries

DECLARE  @AVERAGECOST   INT = 1
		,@FIFO          INT = 2
        ,@LIFO          INT = 3
        ,@LOTCOST       INT = 4
        ,@ACTUALCOST    INT = 5

--Update onhand
-- Get the items to post
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'
DECLARE @ItemsForPost AS ItemCostingTableType
--DECLARE @PostBatchId NVARCHAR(40)
--		,@UserId INT
--		,@PostDate DATETIME

--SELECT TOP 1 @PostBatchId = [strBatchId], @UserId = [intUserId], @PostDate = [dtmDatePosted] FROM #ARPostInvoiceHeader WHERE [ysnPost] = 1

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
        ,[strRateType])
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
        ,[dblForeignRate])
	EXEC dbo.uspICPostInTransitCosting  
         @InTransitItems  
        ,@BatchId  
        ,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
        ,@UserId


	update 
		B
			set intAccountId =  dbo.fnGetItemGLAccount(C.intLinkedItemId, A.intItemLocationId, 'Cost Of Goods')		
	from tblICInventoryTransaction  A
			join #ARInvoiceGLEntries B
				on A.intInventoryTransactionId = B.intJournalLineNo
					and A.intTransactionId = B.intTransactionId
					and A.strTransactionId = B.strTransactionId
			join #ARItemsForInTransitCosting C
				ON A.intTransactionId = C.intTransactionId
					and A.strTransactionId = C.strTransactionId
					and A.intTransactionDetailId =  C.intTransactionDetailId 
					and A.intItemId = C.intItemId
					and A.intItemLocationId = C.intItemLocationId

		where A.strBatchId = @BatchId  and C.intLinkedItemId is not null 
			and dbo.fnGetItemGLAccount(A.intItemId, A.intItemLocationId, 'Cost of Goods') = B.intAccountId

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
        ,[dblForeignRate])
    EXEC dbo.uspICPostStorage  
             @StorageItemsForPost  
            ,@BatchId  		
            ,@UserId			
END

--INSERT INTO #ARInvoiceGLEntries
--	([dtmDate]
--	,[strBatchId]
--	,[intAccountId]
--	,[dblDebit]
--	,[dblCredit]
--	,[dblDebitUnit]
--	,[dblCreditUnit]
--	,[strDescription]
--	,[strCode]
--	,[strReference]
--	,[intCurrencyId]
--	,[dblExchangeRate]
--	,[dtmDateEntered]
--	,[dtmTransactionDate]
--	,[strJournalLineDescription]
--	,[intJournalLineNo]
--	,[ysnIsUnposted]
--	,[intUserId]
--	,[intEntityId]
--	,[strTransactionId]
--	,[intTransactionId]
--	,[strTransactionType]
--	,[strTransactionForm]
--	,[strModuleName]
--	,[intConcurrencyId]
--	,[dblDebitForeign]
--	,[dblDebitReport]
--	,[dblCreditForeign]
--	,[dblCreditReport]
--	,[dblReportingRate]
--	,[dblForeignRate]
--	,[strRateType]
--	,[strDocument]
--	,[strComments]
--	,[strSourceDocumentId]
--	,[intSourceLocationId]
--	,[intSourceUOMId]
--	,[dblSourceUnitDebit]
--	,[dblSourceUnitCredit]
--	,[intCommodityId]
--	,[intSourceEntityId]
--	,[ysnRebuild])
--SELECT
--     [dtmDate]                      = GLEntries.[dtmDate]
--    ,[strBatchId]                   = GLEntries.[strBatchId]
--    ,[intAccountId]                 = GLEntries.[intAccountId]
--    ,[dblDebit]                     = GLEntries.[dblDebit]
--    ,[dblCredit]                    = GLEntries.[dblCredit]
--    ,[dblDebitUnit]                 = DebitUnit.Value
--    ,[dblCreditUnit]                = CreditUnit.Value
--    ,[strDescription]               = GLEntries.[strDescription]
--    ,[strCode]                      = GLEntries.[strCode]
--    ,[strReference]                 = GLEntries.[strReference]
--    ,[intCurrencyId]                = GLEntries.[intCurrencyId]
--    ,[dblExchangeRate]              = GLEntries.[dblExchangeRate]
--    ,[dtmDateEntered]               = @PostDate
--    ,[dtmTransactionDate]           = GLEntries.[dtmTransactionDate]
--    ,[strJournalLineDescription]    = GLEntries.[strJournalLineDescription]
--    ,[intJournalLineNo]             = GLEntries.[intJournalLineNo]
--    ,[ysnIsUnposted]                = GLEntries.[ysnIsUnposted]
--    ,[intUserId]                    = GLEntries.[intUserId]
--    ,[intEntityId]                  = GLEntries.[intEntityId]
--    ,[strTransactionId]             = GLEntries.[strTransactionId]
--    ,[intTransactionId]             = GLEntries.[intTransactionId]
--    ,[strTransactionType]           = GLEntries.[strTransactionType]
--    ,[strTransactionForm]           = GLEntries.[strTransactionForm]
--    ,[strModuleName]                = GLEntries.[strModuleName]
--    ,[intConcurrencyId]             = GLEntries.[intConcurrencyId]
--    ,[dblDebitForeign]              = GLEntries.[dblDebitForeign]
--    ,[dblDebitReport]               = GLEntries.[dblDebitReport]
--    ,[dblCreditForeign]             = GLEntries.[dblCreditForeign]
--    ,[dblCreditReport]              = GLEntries.[dblCreditReport]
--    ,[dblReportingRate]             = GLEntries.[dblReportingRate]
--    ,[dblForeignRate]               = GLEntries.[dblForeignRate]
--    ,[strRateType]                  = GLEntries.[strRateType]
--    ,[strDocument]                  = GLEntries.[strDocument]
--    ,[strComments]                  = GLEntries.[strComments]
--    ,[strSourceDocumentId]          = GLEntries.[strSourceDocumentId]
--    ,[intSourceLocationId]          = GLEntries.[intSourceLocationId]
--    ,[intSourceUOMId]               = GLEntries.[intSourceUOMId]
--    ,[dblSourceUnitDebit]           = GLEntries.[dblSourceUnitDebit]
--    ,[dblSourceUnitCredit]          = GLEntries.[dblSourceUnitCredit]
--    ,[intCommodityId]               = GLEntries.[intCommodityId]
--    ,[intSourceEntityId]            = GLEntries.[intSourceEntityId]
--    ,[ysnRebuild]                   = GLEntries.[ysnRebuild]
--FROM
--    @PostingGLEntries GLEntries
--CROSS APPLY dbo.fnGetDebitUnit(ISNULL(GLEntries.dblDebitUnit, 0.000000) - ISNULL(GLEntries.dblCreditUnit, 0.000000)) DebitUnit
--CROSS APPLY dbo.fnGetCreditUnit(ISNULL(GLEntries.dblDebitUnit, 0.000000) - ISNULL(GLEntries.dblCreditUnit, 0.000000)) CreditUnit


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
SET
     [dtmDateEntered] = @PostDate
	,[strBatchId]     = @BatchId

RETURN 0
