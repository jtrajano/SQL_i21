CREATE PROCEDURE [dbo].[uspICPostStorageMeasurementReading]
	@ysnPost BIT = 0
	,@ysnRecap BIT = 0
	,@strTransactionId NVARCHAR(40) = NULL
	,@intEntityUserSecurityId INT = NULL
	,@strBatchId NVARCHAR(40) = NULL OUTPUT
	
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------    
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'StorageMeasurementReading' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory Adjustment'

DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
		,@intReturnValue AS INT
		,@ysnGLEntriesRequired AS BIT = 0

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  

-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@strDescription AS NVARCHAR(MAX)
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT
			,@StorageMeasurementReading_TransactionType INT = 54
			,@intLocationId AS INT;
  
	SELECT TOP 1   
			@intTransactionId = intStorageMeasurementReadingId
			,@ysnTransactionPostedFlag = ysnPosted
			,@strDescription = strDescription
			,@dtmDate = dtmDate
			,@intCreatedEntityId = intCreatedByUserId
			,@intLocationId = intLocationId
	FROM	dbo.tblICStorageMeasurementReading
	WHERE	strReadingNo = @strTransactionId  
END  


--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Transaction exists   
IF @intTransactionId IS NULL  
BEGIN   
	-- Cannot find the transaction.  
	EXEC uspICRaiseError 80167; 
	GOTO With_Rollback_Exit  
END   
  
-- Validate the date against the FY Periods  
IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
BEGIN   
	-- Unable to find an open fiscal year period to match the transaction date.  
	EXEC uspICRaiseError 80168; 
	GOTO With_Rollback_Exit  
END  
  
-- Check if the transaction is already posted  
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
BEGIN   
	-- The transaction is already posted.  
	EXEC uspICRaiseError 80169; 
	GOTO With_Rollback_Exit  
END   
  
-- Check if the transaction is already unposted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	EXEC uspICRaiseError 80170; 
	GOTO With_Rollback_Exit  
END   
 
IF @ysnRecap = 0
BEGIN 
	UPDATE	dbo.tblICStorageMeasurementReading
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	intStorageMeasurementReadingId = @intTransactionId
END

-- Check Company preference: Allow User Self Post  
IF	dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1 
	AND @intEntityUserSecurityId <> @intCreatedEntityId 
	AND @ysnRecap = 0   
BEGIN   
	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
	IF @ysnPost = 1   
	BEGIN   
		EXEC uspICRaiseError 80172, 'Post';
		GOTO With_Rollback_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		EXEC uspICRaiseError 80172, 'Unpost';
		GOTO With_Rollback_Exit    
	END  
END   


-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO With_Rollback_Exit   


--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	DECLARE @ItemsForAdjust AS ItemCostingTableType  

	
	-- Get the lot details to suffice the selected storage unit
	WITH SourceLot AS (	
			SELECT	Lot.intLotId
					,intRowNo = ROW_NUMBER() OVER(PARTITION BY Lot.intItemId, Lot.intStorageLocationId ORDER BY Lot.dtmDateCreated)
					,Lot.intItemId
					,Lot.intItemLocationId
					,Lot.intItemUOMId
					,Lot.intSubLocationId
					,Lot.intStorageLocationId
					,dblQty = dbo.fnICConvertUOMtoStockUnit(
									Lot.intItemId
									,Lot.intItemUOMId
									,Lot.dblQty)
					,dblLastCost = dbo.fnCalculateCostBetweenUOM( 
									dbo.fnGetItemStockUOM(Detail.intItemId)
									,Lot.intItemUOMId
									,Lot.dblLastCost
								)
					,Lot.dblWeight
					,Lot.dblWeightPerQty
					,Lot.intWeightUOMId
					,Detail.intStorageMeasurementReadingConversionId
					,Detail.intStorageMeasurementReadingId
					,Detail.dblOnHand
					,Detail.dblNewOnHand
					,Detail.dblVariance
			FROM tblICStorageMeasurementReadingConversion Detail
			INNER JOIN tblICLot Lot
				ON Lot.intItemId = Detail.intItemId
				AND Lot.intStorageLocationId = Detail.intStorageLocationId
			WHERE Detail.intStorageMeasurementReadingId = @intTransactionId 
	),
	LotDistribution AS(
		SELECT	*
				,dblRemaining = CAST((dblQty + dblVariance) AS NUMERIC(18,6))
				,ysnAdjustLot = CAST(1 AS BIT)
		FROM SourceLot
		WHERE intRowNo = 1
		UNION ALL
		SELECT	SourceTbl.*
				,dblRemaining = CAST((RecurringTbl.dblRemaining + SourceTbl.dblQty) AS NUMERIC(18,6))
				,ysnAdjustLot = CASE 
									WHEN RecurringTbl.dblRemaining < 0 THEN CAST(1 AS BIT)
									ELSE CAST(0 AS BIT)
								END
		FROM LotDistribution RecurringTbl
		INNER JOIN SourceLot SourceTbl 
			ON RecurringTbl.intRowNo + 1 = SourceTbl.intRowNo
			AND RecurringTbl.intItemId = SourceTbl.intItemId
			AND RecurringTbl.intStorageLocationId = SourceTbl.intStorageLocationId
	)

	SELECT	intLotId
			,intRowNo
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,dblLastCost
			,dblWeight
			,dblWeightPerQty
			,intWeightUOMId
			,intStorageMeasurementReadingConversionId
			,intStorageMeasurementReadingId
			,dblOnHand
			,dblNewOnHand
			,dblVariance
			,dblRemaining
	INTO #tmpLotDistribution
	FROM LotDistribution
	WHERE ysnAdjustLot = 1

	-----------------------------------
	--  Call Quantity Change 
	-----------------------------------
	INSERT INTO @ItemsForAdjust (  
			intItemId  
			,intItemLocationId 
			,intItemUOMId  
			,dtmDate  
			,dblQty  
			,dblUOMQty  
			,dblCost  
			,dblValue 
			,dblSalesPrice  
			,intCurrencyId  
			,dblExchangeRate  
			,intTransactionId  
			,intTransactionDetailId  
			,strTransactionId   
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
			,dblForexRate
	)  	
	SELECT	intItemId					= Detail.intItemId
			,intItemLocationId			= ItemLocation.intItemLocationId
			,intItemUOMId				= StockUOM.intItemUOMId
			,dtmDate					= Header.dtmDate
			,dblQty						= CASE 
											WHEN Item.strLotTracking != 'No' THEN
												CASE
													WHEN LotDistribution.dblRemaining <= 0 THEN -LotDistribution.dblQty
													ELSE LotDistribution.dblRemaining - LotDistribution.dblQty
												END
											ELSE Detail.dblNewOnHand - Detail.dblOnHand
										END
			,dblUOMQty					= StockUOM.dblUnitQty
			,dblCost					= COALESCE(Detail.dblCashPrice, ItemPricing.dblLastCost)--ISNULL(LotDistribution.dblLastCost, ItemPricing.dblLastCost)
			,dblValue					= 0
			,dblSalesPrice				= 0
			,intCurrencyId				= @DefaultCurrencyId
			,dblExchangeRate			= 1
			,intTransactionId			= Header.intStorageMeasurementReadingId
			,intTransactionDetailId		= Detail.intStorageMeasurementReadingConversionId
			,strTransactionId			= Header.strReadingNo
			,intTransactionTypeId		= @StorageMeasurementReading_TransactionType
			,intLotId					= CASE 
											WHEN Item.strLotTracking != 'No' THEN LotDistribution.intLotId
											ELSE NULL
										END
			,intSubLocationId			= StorageUnit.intSubLocationId
			,intStorageLocationId		= StorageUnit.intStorageLocationId
			,dblForexRate				= 1
	FROM tblICStorageMeasurementReading Header
	INNER JOIN tblICStorageMeasurementReadingConversion Detail 
		ON Detail.intStorageMeasurementReadingId = Header.intStorageMeasurementReadingId
	INNER JOIN tblICStorageLocation StorageUnit
		ON StorageUnit.intStorageLocationId = Detail.intStorageLocationId
	INNER JOIN tblICItem Item
		ON Item.intItemId = Detail.intItemId
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemId = Item.intItemId 
		AND ItemLocation.intLocationId = Header.intLocationId
	INNER JOIN dbo.tblICItemUOM StockUOM 
		ON Item.intItemId = StockUOM.intItemId 
		AND StockUOM.ysnStockUnit = 1
	LEFT JOIN #tmpLotDistribution LotDistribution
		ON LotDistribution.intItemId = Detail.intItemId
		AND LotDistribution.intStorageLocationId = Detail.intStorageLocationId
		AND LotDistribution.intStorageMeasurementReadingConversionId = Detail.intStorageMeasurementReadingConversionId
	LEFT JOIN tblICItemPricing ItemPricing
		ON ItemPricing.intItemId = Detail.intItemId
		AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
		
	WHERE Header.intStorageMeasurementReadingId = @intTransactionId

	-----------------------------------
	--  Call the costing routine 
	-----------------------------------
	
	IF EXISTS (SELECT TOP 1 1 FROM @ItemsForAdjust)
	BEGIN 
		-----------------------------------------
		-- Generate the Costing
		-----------------------------------------
		SELECT * FROM @ItemsForAdjust

		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@ItemsForAdjust  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit

		-----------------------------------------
		-- Generate a new set of g/l entries
		-----------------------------------------
		SET @ysnGLEntriesRequired = 1

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
			,@intEntityUserSecurityId
			,@strDescription
	END				

	IF @intReturnValue < 0 GOTO With_Rollback_Exit
END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
	-- Call the post routine 
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
	EXEC	@intReturnValue = dbo.uspICUnpostCosting
			@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@ysnRecap
		
	IF @intReturnValue < 0 GOTO With_Rollback_Exit				
END   

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1. Store all the GL entries in a holding table. It will be used later as data  
--	  for the recap screen.
-- 2. Rollback the save point 
-- 3. Book the G/L entries
-- 4. Commit the save point.
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 1
BEGIN 
	ROLLBACK TRAN @TransactionName

	-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	END 
	ELSE 
	BEGIN 
		-- Post preview is not available. Financials are only booked for company-owned stocks.
		EXEC uspICRaiseError 80185; 
	END 

	COMMIT TRAN @TransactionName
END 

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Update the PO (if it exists)
-- 4. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0 
BEGIN 
	-- If there are items for adjust, expect it to have g/l entries. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost
	END
	COMMIT TRAN @TransactionName
END 


-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strAuditDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId					-- Primary Key Value of the Storage Measurement Reading. 
			,@screenName = 'Inventory.view.StorageMeasurementReading'  -- Screen Namespace
			,@entityId = @intEntityUserSecurityId           -- Entity Id.
			,@actionType = @actionType                      -- Action Type
			,@changeDescription = @strAuditDescription			-- Description
			,@fromValue = ''								-- Previous Value
			,@toValue = ''									-- New Value
END

GOTO Post_Exit

-- This is our immediate exit in case of exceptions controlled by this stored procedure
With_Rollback_Exit:
IF @@TRANCOUNT > 1 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
	RETURN -1;
END

Post_Exit: