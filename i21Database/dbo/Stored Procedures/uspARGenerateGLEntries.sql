CREATE PROCEDURE [dbo].[uspARGenerateGLEntries]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@UserId            INT             = NULL
	,@strSessionId		NVARCHAR(50) 	= NULL    
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
DECLARE @TempGLEntries AS TABLE (
	  [dtmDate]							DATETIME         NOT NULL
	, [strBatchId]						NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL
	, [intAccountId]					INT              NULL
	, [dblDebit]						NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblCredit]						NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblDebitUnit]					NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblCreditUnit]					NUMERIC (18, 6)  NULL DEFAULT 0
	, [strDescription]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [strCode]							NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL 
	, [strReference]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [intCurrencyId]					INT              NULL
	, [dblExchangeRate]					NUMERIC (38, 20) NULL DEFAULT 1
	, [dtmDateEntered]					DATETIME         NOT NULL
	, [dtmTransactionDate]				DATETIME         NULL
	, [strJournalLineDescription]		NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL
	, [intJournalLineNo]				INT              NULL
	, [ysnIsUnposted]					BIT              NOT NULL DEFAULT 0
	, [intUserId]						INT              NULL
	, [intEntityId]						INT              NULL
	, [strTransactionId]				NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
	, [intTransactionId]				INT              NULL
	, [strTransactionType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strTransactionForm]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strModuleName]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [intConcurrencyId]				INT              DEFAULT 1 NOT NULL
	, [dblDebitForeign]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblDebitReport]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblCreditForeign]				NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblCreditReport]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblReportingRate]				NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblForeignRate]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [intCurrencyExchangeRateTypeId]	INT NULL
	, [strRateType]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [strDocument]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strComments]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strSourceDocumentId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [intSourceLocationId]				INT NULL
	, [intSourceUOMId]					INT NULL
	, [dblSourceUnitDebit]				NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblSourceUnitCredit]				NUMERIC (18, 6)  NULL DEFAULT 0
	, [intCommodityId]					INT NULL
	, [intSourceEntityId]				INT NULL
	, [ysnRebuild]						BIT				 NULL DEFAULT 0
    , [strSessionId]                    NVARCHAR(50)  	COLLATE Latin1_General_CI_AS NULL
) 

IF @Post = 1
	INSERT INTO @ItemsForPost(
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
		,[intTicketId]
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
		,[intTicketId]
		,[strSourceNumber]
		,[strSourceType]
		,[intSourceEntityId]
	FROM tblARPostItemsForCosting
	WHERE ISNULL([ysnGLOnly], 0) = CAST(0 AS BIT)
	  AND strSessionId = @strSessionId

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
BEGIN
	INSERT INTO @TempGLEntries (
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

IF @Post = 1 OR (@Post = 0 AND EXISTS(SELECT TOP 1 1 FROM tblARPostInvoiceDetail WHERE intSourceId = 2 AND strSessionId = @strSessionId))
	INSERT INTO @InTransitItems(
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
		,[intTicketId]
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
		,[intSourceTransactionId] 
		,[strSourceTransactionId] 
		,[intSourceTransactionDetailId] 
		,[intFobPointId] 
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate]
		,[strBOLNumber]
		,[intTicketId]
		,[intSourceEntityId]
	FROM tblARPostItemsForInTransitCosting
	WHERE strSessionId = @strSessionId

IF EXISTS (SELECT TOP 1 1 FROM @InTransitItems)
BEGIN		 --Call the post routine 
	INSERT INTO @TempGLEntries(
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
	EXEC dbo.uspICPostInTransitCosting  
		 @InTransitItems  
		,@BatchId  
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
		,@UserId	

	UPDATE B
	SET intAccountId = dbo.fnGetItemGLAccount(C.intLinkedItemId, A.intItemLocationId, 'Cost Of Goods')		
	FROM tblICInventoryTransaction  A
	JOIN @TempGLEntries B ON A.intInventoryTransactionId = B.intJournalLineNo
	AND A.intTransactionId = B.intTransactionId
	AND A.strTransactionId = B.strTransactionId
	JOIN tblARPostItemsForInTransitCosting C ON A.intTransactionId = C.intTransactionId
					             AND A.strTransactionId = C.strTransactionId
					             AND A.intTransactionDetailId =  C.intTransactionDetailId 
					             AND A.intItemId = C.intItemId
					             AND A.intItemLocationId = C.intItemLocationId
	WHERE A.strBatchId = @BatchId
	  AND C.intLinkedItemId IS NOT NULL
	  AND dbo.fnGetItemGLAccount(A.intItemId, A.intItemLocationId, 'Cost of Goods') = B.intAccountId
	  AND C.strSessionId = @strSessionId

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
	FROM tblARPostItemsForStorageCosting
	WHERE strSessionId = @strSessionId

-- Call the post routine 
IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
BEGIN 
	-- Call the post routine 
	INSERT INTO @TempGLEntries
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

INSERT INTO tblARPostInvoiceGLEntries (
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
	,[intSourceEntityId]
	,[intCommodityId]
	,[strSessionId]
)
SELECT [dtmDate] 
	,[strBatchId]					= @BatchId
	,[intAccountId]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
	,[strDescription]
	,[strCode]
	,[strReference]
	,[intCurrencyId]
	,[dblExchangeRate]				= ISNULL(dblExchangeRate, 1)
	,[dtmDateEntered]				= @PostDate
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
	,[dblDebitForeign]				= CASE WHEN ISNULL(dblExchangeRate, 1) = 1 THEN dblDebit ELSE dblDebitForeign END
	,[dblDebitReport]
	,[dblCreditForeign]				= CASE WHEN ISNULL(dblExchangeRate, 1) = 1 THEN dblCredit ELSE dblCreditForeign END
	,[dblCreditReport]
	,[dblReportingRate]
	,[dblForeignRate]
	,[intSourceEntityId]
	,[intCommodityId]
	,[strSessionId]					= @strSessionId
FROM @TempGLEntries

UPDATE tblARPostInvoiceGLEntries
SET [strSessionId] = @strSessionId
WHERE strSessionId IS NULL 

UPDATE tblARPostInvoiceGLEntries
SET [dtmDateEntered] = @PostDate
   ,[strBatchId]     = @BatchId
WHERE strSessionId = @strSessionId

UPDATE GL
SET GL.intSourceEntityId = I.intEntityCustomerId
  , GL.intEntityId		 = I.intEntityId
FROM tblARPostInvoiceGLEntries GL
INNER JOIN tblARInvoice I ON GL.strTransactionId = I.strInvoiceNumber
						 AND GL.intTransactionId = I.intInvoiceId
WHERE GL.intSourceEntityId IS NULL
  AND GL.strSessionId = @strSessionId

RETURN 0
