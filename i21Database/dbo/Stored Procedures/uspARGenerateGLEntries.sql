﻿CREATE PROCEDURE [dbo].[uspARGenerateGLEntries]
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
	INSERT INTO tblARPostInvoiceGLEntries(
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
	)
	EXEC dbo.uspICPostInTransitCosting  
		 @InTransitItems  
		,@BatchId  
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
		,@UserId	

	UPDATE B
	SET intAccountId = dbo.fnGetItemGLAccount(C.intLinkedItemId, A.intItemLocationId, 'Cost Of Goods')		
	FROM tblICInventoryTransaction  A
	JOIN tblARPostInvoiceGLEntries B ON A.intInventoryTransactionId = B.intJournalLineNo
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
	INSERT INTO tblARPostInvoiceGLEntries
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

UPDATE tblARPostInvoiceGLEntries
SET [strSessionId] = @strSessionId
WHERE strBatchId = @BatchId

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

IF @Post = 1 AND EXISTS(
	SELECT TOP 1 1
	FROM tblARCompanyPreference
	WHERE ysnOverrideLineOfBusinessSegment = 1
)
BEGIN
	UPDATE ARPIGLE
	SET ARPIGLE.intAccountId = LOB.intAccountId
	FROM tblARPostInvoiceGLEntries ARPIGLE
	INNER JOIN tblARPostInvoiceHeader ARPIH ON ARPIGLE.intTransactionId = ARPIH.intInvoiceId
	OUTER APPLY (
		SELECT TOP 1 intAccountId = dbo.[fnGetGLAccountIdFromProfitCenter](ARPIGLE.intAccountId, ISNULL(intSegmentCodeId, 0))
		FROM tblSMLineOfBusiness
		WHERE intLineOfBusinessId = ISNULL(ARPIH.intLineOfBusinessId, 0)
	) LOB
	WHERE ARPIGLE.strSessionId = @strSessionId
	AND ARPIGLE.strCode = 'IC'
	AND ARPIGLE.[dblCredit] > 0 -- COGS Only
	AND ISNULL(ARPIH.intLineOfBusinessId, 0) <> 0
END

RETURN 0
