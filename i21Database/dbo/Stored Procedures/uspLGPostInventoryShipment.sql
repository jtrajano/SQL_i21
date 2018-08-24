CREATE PROCEDURE [dbo].[uspLGPostInventoryShipment] 
	 @ysnPost BIT = 0
	,@strTransactionId NVARCHAR(40) = NULL
	,@intEntityUserSecurityId AS INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------    
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'Outbound Shipment Transaction' + CAST(NEWID() AS NVARCHAR(100));
-- Constants  
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 46
DECLARE @ysnRecap AS INT = 0
DECLARE @STARTING_NUMBER_BATCH AS INT = 3
DECLARE @ENABLE_ACCRUALS_FOR_OUTBOUND BIT = 0
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
	,@OWNERSHIP_TYPE_OWN AS INT = 1
	,@OWNERSHIP_TYPE_STORAGE AS INT = 2
	,@OWNERSHIP_TYPE_CONSIGNED_PURCHASE AS INT = 3
	,@OWNERSHIP_TYPE_CONSIGNED_SALE AS INT = 4
-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
-- Get the Inventory Shipment batch number
DECLARE @strBatchId AS NVARCHAR(40)
	,@strItemNo AS NVARCHAR(50)
	,@ysnAllowBlankGLEntries AS BIT = 1
	,@intItemId AS INT
DECLARE @LotType_Manual AS INT = 1
	,@LotType_Serial AS INT = 2
-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
	,@intReturnValue AS INT
DECLARE @dummyGLEntries AS RecapTableType

SELECT @ENABLE_ACCRUALS_FOR_OUTBOUND = ysnEnableAccrualsForOutbound 
FROM tblLGCompanyPreference

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)

-- Read the transaction info   
BEGIN
	DECLARE @dtmDate AS DATETIME
	DECLARE @intTransactionId AS INT
	DECLARE @intCreatedEntityId AS INT
	DECLARE @ysnAllowUserSelfPost AS BIT
	DECLARE @ysnTransactionPostedFlag AS BIT
	DECLARE @ysnDirectShip BIT;
	DECLARE @strFOBPoint NVARCHAR(50)
	DECLARE @intFOBPointId INT
	DECLARE @ItemsToPost ItemInTransitCostingTableType

	SELECT TOP 1 @intTransactionId = intLoadId
		,@ysnTransactionPostedFlag = ysnPosted
		,@dtmDate = GETDATE()
		,@intCreatedEntityId = intEntityId
		,@strFOBPoint = FT.strFobPoint
		,@intFOBPointId = FP.intFobPointId
	FROM dbo.tblLGLoad L
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FP.strFobPoint
	WHERE strLoadNumber = @strTransactionId
END

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Inventory Shipment exists   
IF @intTransactionId IS NULL
BEGIN
	-- Cannot find the transaction.  
	RAISERROR ('Cannot find the transaction.',11,1)

	GOTO Post_Exit
END

-- Validate the date against the FY Periods  
IF @ysnRecap = 0
	AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0)
BEGIN
	-- Unable to find an open fiscal year period to match the transaction date.  
	RAISERROR ('Unable to find an open fiscal year period to match the transaction date.',11,1)

	GOTO Post_Exit
END

-- Check if the transaction is already posted  
IF @ysnPost = 1
	AND @ysnTransactionPostedFlag = 1
BEGIN
	-- The transaction is already posted.  
	RAISERROR ('The transaction is already posted.',11,1)

	GOTO Post_Exit
END

-- Check if the transaction is already posted  
IF @ysnPost = 0
	AND @ysnTransactionPostedFlag = 0
BEGIN
	-- The transaction is already unposted.  
	RAISERROR ('The transaction is already unposted.',11,1)

	GOTO Post_Exit
END

-- Check Company preference: Allow User Self Post  
IF dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1
	AND @intEntityUserSecurityId <> @intCreatedEntityId
	AND @ysnRecap = 0
BEGIN
	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
	IF @ysnPost = 1
	BEGIN
		RAISERROR ('You cannot %s transactions you did not create. Please contact your local administrator.',11,1,'Post')

		GOTO Post_Exit
	END

	IF @ysnPost = 0
	BEGIN
		RAISERROR ('You cannot %s transactions you did not create. Please contact your local administrator.',11,1,'Unpost')

		GOTO Post_Exit
	END
END

-- Check if the Shipment quantity matches the total Quantity in the Lot
BEGIN
	SET @strItemNo = NULL
	SET @intItemId = NULL

	DECLARE @dblQuantityShipped AS NUMERIC(38, 20)
		--,@LotQty AS NUMERIC(38,20)
		,@LotQtyInItemUOM AS NUMERIC(38, 20)
		,@QuantityShippedInItemUOM AS NUMERIC(38, 20)
	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)

	SELECT TOP 1 @strItemNo = Item.strItemNo
		,@intItemId = Item.intItemId
		,@dblQuantityShipped = Detail.dblQuantity
		,@LotQtyInItemUOM = ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0)
	FROM tblLGLoad LOAD
	INNER JOIN tblLGLoadDetail Detail ON LOAD.intLoadId = Detail.intLoadId
	INNER JOIN dbo.tblICItem Item ON Item.intItemId = Detail.intItemId
	LEFT JOIN (
		SELECT LDL.intLoadDetailId
			,TotalLotQtyInDetailItemUOM = SUM(dbo.fnCalculateQtyBetweenUOM(ISNULL(Lot.intItemUOMId, LD.intItemUOMId), LD.intItemUOMId, LDL.dblLotQuantity))
		FROM dbo.tblLGLoad L
		INNER JOIN dbo.tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		INNER JOIN dbo.tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
		INNER JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
		WHERE L.strLoadNumber = @strTransactionId
		GROUP BY LDL.intLoadDetailId
		) ItemLot ON ItemLot.intLoadDetailId = Detail.intLoadDetailId
	WHERE dbo.fnGetItemLotType(Detail.intItemId) <> 0
		AND LOAD.strLoadNumber = @strTransactionId
		AND ROUND(ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0), 2) <> ROUND(Detail.dblQuantity, 2)

	IF @intItemId IS NOT NULL
	BEGIN
		IF ISNULL(@strItemNo, '') = ''
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50))

		-- 'The Qty to Ship for {Item} is {Ship Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		DECLARE @difference AS NUMERIC(38, 20) = ABS(@dblQuantityShipped - @LotQtyInItemUOM)

		EXEC uspICRaiseError 80047
			,@strItemNo
			,@dblQuantityShipped
			,@LotQtyInItemUOM
			,@difference

		RETURN - 1;
	END
END

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
	,@strBatchId OUTPUT

IF @@ERROR <> 0
	GOTO Post_Exit

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName

SAVE TRAN @TransactionName

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
	IF @ENABLE_ACCRUALS_FOR_OUTBOUND = 1
	BEGIN 
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
		EXEC @intReturnValue = dbo.uspLGPostInventoryShipmentOtherCharges 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_SHIPMENT_TYPE
			,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
			
	END 

	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType
	DECLARE @StorageItemsForPost AS ItemCostingTableType

	IF @strFOBPoint = 'Origin'
		-- Get company owned items to post. 
	BEGIN
		INSERT INTO @ItemsForPost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
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
			)
		SELECT intItemId = LoadDetail.intItemId
			,intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
			,intItemUOMId = ItemUOM.intItemUOMId
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty = - 1 * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ISNULL(LoadDetail.dblQuantity, 0)
				ELSE ISNULL(DetailLot.dblLotQuantity, 0)
				END
			,dblUOMQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblCost = ISNULL(CASE 
					WHEN Lot.dblLastCost IS NULL
						THEN (
								SELECT TOP 1 dblLastCost
								FROM tblICItemPricing
								WHERE intItemId = LoadDetail.intItemId
									AND intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
								)
					ELSE Lot.dblLastCost
					END, 0) * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblSalesPrice = 0.00
			,intCurrencyId = @DefaultCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = LOAD.intLoadId
			,intTransactionDetailId = LoadDetail.intLoadDetailId
			,strTransactionId = LOAD.strLoadNumber
			,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId --, DetailLot.intSubLocationId)
			,intStorageLocationId = Lot.intStorageLocationId --, DetailLot.intStorageLocationId) 
		FROM tblLGLoad LOAD --Header 
		INNER JOIN tblLGLoadDetail LoadDetail ON LOAD.intLoadId = LoadDetail.intLoadId -- DetailItem
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
		LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
		LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE LOAD.intLoadId = @intTransactionId

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

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
				)
			EXEC @intReturnValue = dbo.uspICPostCosting @ItemsForPost
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END
	END

	IF @strFOBPoint = 'Destination'
	BEGIN
		-- Get company owned items to post. 
		INSERT INTO @ItemsForPost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
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
			)
		SELECT intItemId = LoadDetail.intItemId
			,intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
			,intItemUOMId = ItemUOM.intItemUOMId
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty = - 1 * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ISNULL(LoadDetail.dblQuantity, 0)
				ELSE ISNULL(DetailLot.dblLotQuantity, 0)
				END
			,dblUOMQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblCost = ISNULL(CASE 
					WHEN Lot.dblLastCost IS NULL
						THEN (
								SELECT TOP 1 dblLastCost
								FROM tblICItemPricing
								WHERE intItemId = LoadDetail.intItemId
									AND intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
								)
					ELSE Lot.dblLastCost
					END, 0) * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblSalesPrice = 0.00
			,intCurrencyId = @DefaultCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = LOAD.intLoadId
			,intTransactionDetailId = LoadDetail.intLoadDetailId
			,strTransactionId = LOAD.strLoadNumber
			,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId --, DetailLot.intSubLocationId)
			,intStorageLocationId = Lot.intStorageLocationId --, DetailLot.intStorageLocationId) 
		FROM tblLGLoad LOAD --Header 
		INNER JOIN tblLGLoadDetail LoadDetail ON LOAD.intLoadId = LoadDetail.intLoadId -- DetailItem
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
		LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
		LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE LOAD.intLoadId = @intTransactionId

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

			-- Call the post routine 
			INSERT INTO @dummyGLEntries (
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
			EXEC @intReturnValue = dbo.uspICPostCosting @ItemsForPost
				,@strBatchId
				,NULL
				,@intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit

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
			EXEC @intReturnValue = dbo.uspICCreateGLEntries @strBatchId
				,NULL
				,@intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END

		INSERT INTO @ItemsToPost (
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
			,intSourceTransactionId
			,strSourceTransactionId
			,intSourceTransactionDetailId
			,intFobPointId
			,intInTransitSourceLocationId
			,intForexRateTypeId
			,dblForexRate
			)
		SELECT [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,- [dblQty]
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
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionDetailId]
			,[intFobPointId] = @intFOBPointId
			,[intInTransitSourceLocationId] = t.intItemLocationId
			,[intForexRateTypeId] = t.intForexRateTypeId
			,[dblForexRate] = t.dblForexRate
		FROM tblICInventoryTransaction t
		WHERE t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0
			AND t.strBatchId = @strBatchId
			AND @intFOBPointId = 2
			AND t.dblQty < 0 -- Ensure the Qty is negative. Credit Memo are positive Qtys.  Credit Memo does not ship out but receives stock. 

		IF EXISTS (
				SELECT TOP 1 1
				FROM @ItemsToPost
				)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

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
				)
			EXEC @intReturnValue = dbo.uspICPostInTransitCosting @ItemsToPost = @ItemsToPost
				,@strBatchId = @strBatchId
				,@strAccountToCounterInventory = NULL
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@strGLDescription = ''

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END
	END
END

-- Process Storage items
BEGIN
	INSERT INTO @StorageItemsForPost (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
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
		)
	SELECT intItemId = LoadDetail.intItemId
		,intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
		,intItemUOMId = ItemUOM.intItemUOMId
		,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
		,dblQty = - 1 * CASE 
			WHEN Lot.intLotId IS NULL
				THEN ISNULL(LoadDetail.dblQuantity, 0)
			ELSE ISNULL(DetailLot.dblLotQuantity, 0)
			END
		,dblUOMQty = CASE 
			WHEN Lot.intLotId IS NULL
				THEN ItemUOM.dblUnitQty
			ELSE LotItemUOM.dblUnitQty
			END
		,dblCost = ISNULL(CASE 
				WHEN Lot.dblLastCost IS NULL
					THEN (
							SELECT TOP 1 dblLastCost
							FROM tblICItemPricing
							WHERE intItemId = LoadDetail.intItemId
								AND intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
							)
				ELSE Lot.dblLastCost
				END, 0)
		,dblSalesPrice = 0.00
		,intCurrencyId = @DefaultCurrencyId
		,dblExchangeRate = 1
		,intTransactionId = LOAD.intLoadId
		,intTransactionDetailId = LoadDetail.intLoadDetailId
		,strTransactionId = LOAD.strLoadNumber
		,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
		,intLotId = Lot.intLotId
		,intSubLocationId = Lot.intSubLocationId --, DetailLot.intSubLocationId)
		,intStorageLocationId = Lot.intStorageLocationId --, DetailLot.intStorageLocationId) 
	FROM tblLGLoad LOAD --Header 
	INNER JOIN tblLGLoadDetail LoadDetail ON LOAD.intLoadId = LoadDetail.intLoadId -- DetailItem
	INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
	LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
	LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
	WHERE LOAD.intLoadId = @intTransactionId
		AND 1 = 2

	-- Call the post routine 
	IF EXISTS (
			SELECT TOP 1 1
			FROM @StorageItemsForPost
			)
	BEGIN
		EXEC @intReturnValue = dbo.uspICPostStorage @StorageItemsForPost
			,@strBatchId
			,@intEntityUserSecurityId

		IF @intReturnValue < 0
			GOTO With_Rollback_Exit
	END
END

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0
BEGIN
	IF @strFOBPoint = 'Origin'
	BEGIN
		INSERT INTO @ItemsForPost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
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
			)
		SELECT intItemId = LoadDetail.intItemId
			,intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
			,intItemUOMId = ItemUOM.intItemUOMId
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ISNULL(LoadDetail.dblQuantity, 0)
				ELSE ISNULL(DetailLot.dblLotQuantity, 0)
				END
			,dblUOMQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblCost = ISNULL(CASE 
					WHEN Lot.dblLastCost IS NULL
						THEN (
								SELECT TOP 1 dblLastCost
								FROM tblICItemPricing
								WHERE intItemId = LoadDetail.intItemId
									AND intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
								)
					ELSE Lot.dblLastCost
					END, 0) * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblSalesPrice = 0.00
			,intCurrencyId = @DefaultCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = LOAD.intLoadId
			,intTransactionDetailId = LoadDetail.intLoadDetailId
			,strTransactionId = LOAD.strLoadNumber
			,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId --, DetailLot.intSubLocationId)
			,intStorageLocationId = Lot.intStorageLocationId --, DetailLot.intStorageLocationId) 
		FROM tblLGLoad LOAD --Header 
		INNER JOIN tblLGLoadDetail LoadDetail ON LOAD.intLoadId = LoadDetail.intLoadId -- DetailItem
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
		LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
		LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE LOAD.intLoadId = @intTransactionId

		-- Call the post routine 
		IF EXISTS (
				SELECT TOP 1 1
				FROM @ItemsForPost
				)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

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
				)
			EXEC @intReturnValue = dbo.uspICPostCosting @ItemsForPost
				,@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END
	END

		-- Unpost the Other Charges
	IF @ENABLE_ACCRUALS_FOR_OUTBOUND = 1
	BEGIN 
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
		EXEC @intReturnValue = dbo.uspLGPostInventoryShipmentOtherCharges 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_SHIPMENT_TYPE
			,@ysnPost
				
		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END

	IF @strFOBPoint = 'Destination'
	BEGIN
		-- Get company owned items to post. 
		INSERT INTO @ItemsForPost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
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
			)
		SELECT intItemId = LoadDetail.intItemId
			,intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
			,intItemUOMId = ItemUOM.intItemUOMId
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ISNULL(LoadDetail.dblQuantity, 0)
				ELSE ISNULL(DetailLot.dblLotQuantity, 0)
				END
			,dblUOMQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblCost = ISNULL(CASE 
					WHEN Lot.dblLastCost IS NULL
						THEN (
								SELECT TOP 1 dblLastCost
								FROM tblICItemPricing
								WHERE intItemId = LoadDetail.intItemId
									AND intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
								)
					ELSE Lot.dblLastCost
					END, 0) * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblSalesPrice = 0.00
			,intCurrencyId = @DefaultCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = LOAD.intLoadId
			,intTransactionDetailId = LoadDetail.intLoadDetailId
			,strTransactionId = LOAD.strLoadNumber
			,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId --, DetailLot.intSubLocationId)
			,intStorageLocationId = Lot.intStorageLocationId --, DetailLot.intStorageLocationId) 
		FROM tblLGLoad LOAD --Header 
		INNER JOIN tblLGLoadDetail LoadDetail ON LOAD.intLoadId = LoadDetail.intLoadId -- DetailItem
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
		LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
		LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE LOAD.intLoadId = @intTransactionId

		-- Call the post routine 
		IF EXISTS (
				SELECT TOP 1 1
				FROM @ItemsForPost
				)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

			-- Call the post routine 
			INSERT INTO @dummyGLEntries (
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
			EXEC @intReturnValue = dbo.uspICPostCosting @ItemsForPost
				,@strBatchId
				,NULL
				,@intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit

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
			EXEC @intReturnValue = dbo.uspICCreateGLEntries @strBatchId
				,NULL
				,@intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END

		INSERT INTO @ItemsToPost (
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
			,intSourceTransactionId
			,strSourceTransactionId
			,intSourceTransactionDetailId
			,intFobPointId
			,intInTransitSourceLocationId
			,intForexRateTypeId
			,dblForexRate
			)
		SELECT [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,- [dblQty]
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
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionDetailId]
			,[intFobPointId] = @intFOBPointId
			,[intInTransitSourceLocationId] = t.intItemLocationId
			,[intForexRateTypeId] = t.intForexRateTypeId
			,[dblForexRate] = t.dblForexRate
		FROM tblICInventoryTransaction t
		WHERE t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0
			AND t.strBatchId = @strBatchId
			AND @intFOBPointId = 2

		--AND t.dblQty < 0 -- Ensure the Qty is negative. Credit Memo are positive Qtys.  Credit Memo does not ship out but receives stock. 
		IF EXISTS (
				SELECT TOP 1 1
				FROM @ItemsToPost
				)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

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
				)
			EXEC @intReturnValue = dbo.uspICPostInTransitCosting @ItemsToPost = @ItemsToPost
				,@strBatchId = @strBatchId
				,@strAccountToCounterInventory = NULL
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@strGLDescription = ''

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END
	END
END

DECLARE @ItemsToIncreaseInTransitInBound AS InTransitTableType
	,@total AS INT;

INSERT INTO @ItemsToIncreaseInTransitInBound (
	[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intLotId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[dblQty]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionTypeId]
	)
SELECT LD.intItemId
	,intItemLocationId = (
		SELECT TOP (1) intItemLocationId
		FROM tblICItemLocation
		WHERE intItemId = LD.intItemId
			AND intLocationId = CT.intCompanyLocationId
		)
	,CT.intItemUOMId
	,LDL.intLotId
	,LW.intSubLocationId
	,LOT.intStorageLocationId
	,CASE 
		WHEN @ysnPost = 1
			THEN LD.dblQuantity
		ELSE - LD.dblQuantity
		END
	,LD.intLoadId
	,CAST(L.strLoadNumber AS VARCHAR(100))
	,@INVENTORY_SHIPMENT_TYPE
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGLoadDetailLot LDL ON LD.intLoadDetailId = LDL.intLoadDetailId
LEFT JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = LD.intSContractDetailId
WHERE L.intLoadId = @intTransactionId;

SELECT @ysnDirectShip = CASE 
		WHEN intSourceType = 3
			THEN 1
		ELSE 0
		END
FROM tblLGLoad S
WHERE intLoadId = @intTransactionId

IF (@ysnDirectShip <> 1)
BEGIN
	EXEC dbo.uspICIncreaseInTransitOutBoundQty @ItemsToIncreaseInTransitInBound;
END

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1.	Store all the GL entries in a holding table. It will be used later as data  
--		for the recap screen.
--
-- 2.	Rollback the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 1
BEGIN
	ROLLBACK TRAN @TransactionName

	EXEC dbo.uspCMPostRecap @GLEntries

	COMMIT TRAN @TransactionName
END

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Call any stored procedure for the intergrations with the other modules. 
-- 4. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN
	IF @ysnAllowBlankGLEntries = 0
	BEGIN
		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END

	UPDATE dbo.tblLGLoad
	SET ysnPosted = @ysnPost
		,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		,intShipmentStatus = 6
		,dtmPostedDate = GETDATE()
	WHERE strLoadNumber = @strTransactionId

	DECLARE @ItemsFromInventoryShipment AS dbo.ShipmentItemTableType

	INSERT INTO @ItemsFromInventoryShipment (
		-- Header
		[intShipmentId]
		,[strShipmentId]
		,[intOrderType]
		,[intSourceType]
		,[dtmDate]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intEntityCustomerId]
		-- Detail 
		,[intInventoryShipmentItemId]
		,[intItemId]
		,[intLotId]
		,[strLotNumber]
		,[intLocationId]
		,[intItemLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[intItemUOMId]
		,[intWeightUOMId]
		,[dblQty]
		,[dblUOMQty]
		,[dblNetWeight]
		,[dblSalesPrice]
		,[intDockDoorId]
		,[intOwnershipType]
		,[intOrderId]
		,[intSourceId]
		,[intLineNo]
		)
	SELECT L.intLoadId
		,L.strLoadNumber
		,1 AS intOrderType
		,1 AS intSourceType
		,GETDATE()
		,intCurrencyId = NULL
		,[dblExchangeRate] = 1
		,LD.intCustomerEntityId
		,LD.intLoadDetailId
		,LD.intItemId
		,LDL.intLotId
		,Lot.strLotNumber
		,[intLocationId] = LD.intSCompanyLocationId
		,[intItemLocationId] = CASE 
			WHEN IL.intItemLocationId IS NULL
				THEN (
						SELECT TOP 1 ITL.intItemLocationId
						FROM tblICItemLocation ITL
						WHERE ITL.intItemId = LD.intItemId
							AND ITL.intLocationId = CD.intCompanyLocationId
						)
			ELSE IL.intItemLocationId
			END
		,[intSubLocationId] = LD.intSSubLocationId
		,[intStorageLocationId] = NULL
		,[intItemUOMId] = LD.intItemUOMId
		,[intWeightUOMId] = LD.intWeightItemUOMId
		,[dblQty] = CASE 
					WHEN @ysnPost = 1
						THEN - 1 * LD.dblQuantity
					ELSE LD.dblQuantity
					END
		,[dblUOMQty] = IU.dblUnitQty
		,[dblNetWeight] = LDL.dblGross - LDL.dblTare
		,[dblSalesPrice] = ISNULL(CD.dblCashPrice, 0)
		,[intDockDoorId] = NULL
		,[intOwnershipType] = ISNULL(Lot.intOwnershipType, 0)
		,[intOrderId] = NULL
		,[intSourceId] = NULL
		,[intLineNo] = ISNULL(LD.intSContractDetailId, 0)
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
	LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = Lot.intItemLocationId
	WHERE L.intLoadId = @intTransactionId

	EXEC dbo.uspCTShipped @ItemsFromInventoryShipment
		,@intEntityUserSecurityId

	-- Mark stock reservation as posted (or unposted)
	EXEC dbo.uspICPostStockReservation @intTransactionId
		,@INVENTORY_SHIPMENT_TYPE
		,@ysnPost

	COMMIT TRAN @TransactionName
END

-- Create an Audit Log
IF @ysnRecap = 0
BEGIN
	DECLARE @strDescription AS NVARCHAR(100)
		,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE 
			WHEN @ysnPost = 1
				THEN 'Posted'
			ELSE 'Unposted'
			END

	EXEC dbo.uspSMAuditLog @keyValue = @intTransactionId -- Primary Key Value of the Inventory Shipment. 
		,@screenName = 'Logistics.view.ShipmentSchedule' -- Screen Namespace
		,@entityId = @intEntityUserSecurityId -- Entity Id.
		,@actionType = @actionType -- Action Type
		,@changeDescription = @strDescription -- Description
		,@fromValue = '' -- Previous Value
		,@toValue = '' -- New Value
END

GOTO Post_Exit

-- This is our immediate exit in case of exceptions controlled by this stored procedure
With_Rollback_Exit:

IF @@TRANCOUNT > 1
BEGIN
	ROLLBACK TRAN @TransactionName

	COMMIT TRAN @TransactionName
END

Post_Exit: