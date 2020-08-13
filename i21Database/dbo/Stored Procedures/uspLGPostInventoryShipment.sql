CREATE PROCEDURE [dbo].[uspLGPostInventoryShipment] 
	 @ysnPost BIT = 0
	,@strTransactionId NVARCHAR(40) = NULL
	,@intEntityUserSecurityId AS INT = NULL
	,@ysnRecap BIT = 0
	,@strBatchId NVARCHAR(40) = NULL OUTPUT
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
DECLARE @STARTING_NUMBER_BATCH AS INT = 3
DECLARE @ENABLE_ACCRUALS_FOR_OUTBOUND BIT = 0

DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
-- Get the Inventory Shipment batch number
DECLARE @strItemNo AS NVARCHAR(50)
	,@ysnAllowBlankGLEntries AS BIT = 1
	,@intItemId AS INT
-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
	,@intReturnValue AS INT
DECLARE @dummyGLEntries AS RecapTableType

SELECT TOP 1 @ENABLE_ACCRUALS_FOR_OUTBOUND = ysnEnableAccrualsForOutbound 
FROM tblLGCompanyPreference

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)

-- Read the transaction info   
BEGIN
	DECLARE @dtmDate AS DATETIME
	DECLARE @intTransactionId AS INT
	DECLARE @intCreatedEntityId AS INT
	DECLARE @ysnTransactionPostedFlag AS BIT
	DECLARE @ysnDirectShip BIT;
	DECLARE @ysnIsReturn BIT = 0
	DECLARE @strCreditMemo NVARCHAR(50)
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
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1
BEGIN
	-- The transaction is already posted.  
	RAISERROR ('The transaction is already posted.',11,1)

	GOTO Post_Exit
END

-- Check if the transaction is already posted  
IF @ysnPost = 0 AND @ysnRecap = 0
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
		,@LotQtyInItemUOM AS NUMERIC(38, 20)
		,@QuantityShippedInItemUOM AS NUMERIC(38, 20)
	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)
	DECLARE @intSourceType INT = NULL
	DECLARE @errMsg NVARCHAR(MAX)

	SELECT TOP 1 @strItemNo = Item.strItemNo
		,@intItemId = Item.intItemId
		,@dblQuantityShipped = Detail.dblQuantity
		,@LotQtyInItemUOM = ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0)
		,@intSourceType = L.intSourceType
	FROM tblLGLoad L
	INNER JOIN tblLGLoadDetail Detail ON L.intLoadId = Detail.intLoadId
	INNER JOIN dbo.tblICItem Item ON Item.intItemId = Detail.intItemId
	LEFT JOIN (
		SELECT LDL.intLoadDetailId
			,TotalLotQtyInDetailItemUOM = SUM(dbo.fnCalculateQtyBetweenUOM(ISNULL(Lot.intItemUOMId, LD.intItemUOMId), LD.intItemUOMId, LDL.dblLotQuantity))
		FROM dbo.tblLGLoadDetail LD
		INNER JOIN dbo.tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
		INNER JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
		WHERE LD.intLoadId = @intTransactionId
		GROUP BY LDL.intLoadDetailId
		) ItemLot ON ItemLot.intLoadDetailId = Detail.intLoadDetailId
	WHERE dbo.fnGetItemLotType(Detail.intItemId) <> 0
		AND L.strLoadNumber = @strTransactionId
		AND ROUND(ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0), 2) <> ROUND(Detail.dblQuantity, 2)

	IF @intItemId IS NOT NULL
	BEGIN
		IF ISNULL(@strItemNo, '') = ''
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50))

		-- 'No Lots selected for {Item}. Please choose a Source Type that supports Lot selection.'
		IF (@intSourceType NOT IN (5, 6, 7))
		BEGIN
			SELECT @errMsg = 'No Lots selected for ' + @strItemNo + '. Please choose a Source Type that supports Lot selection.'
			RAISERROR(@errMsg, 16, 1);
		END

		-- 'No Lots selected for {Item}.'
		IF (@LotQtyInItemUOM = 0)
		BEGIN
			SELECT @errMsg = 'No Lots selected for ' + @strItemNo + '. '
			RAISERROR(@errMsg, 16, 1);
		END

		-- 'The Qty to Ship for {Item} is {Ship Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		DECLARE @difference AS NUMERIC(38, 20) = ABS(@dblQuantityShipped - @LotQtyInItemUOM)

		EXEC uspICRaiseError 80047
			,@strItemNo
			,@dblQuantityShipped
			,@LotQtyInItemUOM
			,@difference

		RETURN - 1;
	END

	SELECT TOP 1 @ysnIsReturn = 1, @strCreditMemo = I.strInvoiceNumber
	 FROM tblLGLoad L JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
	 WHERE L.intLoadId = @intTransactionId
	 AND I.strTransactionType = 'Credit Memo'
	 AND I.ysnPosted = 1

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
	-- Mark stock reservation as posted (or unposted)
	EXEC dbo.uspICPostStockReservation @intTransactionId, @INVENTORY_SHIPMENT_TYPE, @ysnPost

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
			,intItemUOMId = CASE WHEN Lot.intLotId IS NULL THEN 
									ISNULL(LoadDetail.intItemUOMId, 0)
								ELSE 
									ISNULL(DetailLot.intItemUOMId, 0)
								END
			,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
			,dblQty = -1 * COALESCE(DetailLot.dblLotQuantity, LoadDetail.dblQuantity, 0)
			,dblUOMQty = ISNULL(LotItemUOM.dblUnitQty, ItemUOM.dblUnitQty)
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
			,intTransactionId = L.intLoadId
			,intTransactionDetailId = LoadDetail.intLoadDetailId
			,strTransactionId = L.strLoadNumber
			,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId
			,intStorageLocationId = Lot.intStorageLocationId
		FROM tblLGLoad L
		INNER JOIN tblLGLoadDetail LoadDetail ON L.intLoadId = LoadDetail.intLoadId
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
		LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
		LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE L.intLoadId = @intTransactionId

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
				,[intSourceEntityId]
				,[intCommodityId]
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
				,[intSourceEntityId]
				,[intCommodityId]
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
			,intSourceEntityId
			)
		SELECT [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,-[dblQty]
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
			,t.intSourceEntityId
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
				,[intSourceEntityId]
				,[intCommodityId]
			)
			EXEC @intReturnValue = dbo.uspICPostInTransitCosting @ItemsToPost = @ItemsToPost
				,@strBatchId = @strBatchId
				,@strAccountToCounterInventory = NULL
				,@intEntityUserSecurityId = @intEntityUserSecurityId

			IF @intReturnValue < 0
				GOTO With_Rollback_Exit
		END 
	END
END

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
	-- Call the unpost routine 
	BEGIN 
		-- Unpost the company owned stocks. 
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

		-- Unpost storage stocks. 
		EXEC	@intReturnValue = dbo.uspICUnpostStorage
				@intTransactionId
				,@strTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@ysnRecap
		
		IF @intReturnValue < 0 GOTO With_Rollback_Exit

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

		-- Unpost the Taxes from the Other Charges
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
				,[intSourceEntityId]
				,[intCommodityId]
			)	
			EXEC dbo.uspICPostInventoryShipmentTaxes 
				@intTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_SHIPMENT_TYPE
				,0

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END

	END 
END   

DECLARE @ItemsToIncreaseInTransitOutBound AS InTransitTableType
	,@total AS INT;

INSERT INTO @ItemsToIncreaseInTransitOutBound (
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
	,[intFOBPointId]
	)
SELECT 
	[intItemId] = LD.intItemId
	,[intItemLocationId] = LOC.intItemLocationId
	,[intItemUOMId] = CASE WHEN LDL.intLotId IS NULL THEN ISNULL(CT.intItemUOMId, LD.intItemUOMId) ELSE LDL.intWeightUOMId END
	,[intLotId] = LDL.intLotId
	,[intSubLocationId] = CASE WHEN LDL.intLotId IS NULL THEN ISNULL(LWH.intSubLocationId, LD.intSSubLocationId) ELSE LOT.intSubLocationId END
	,[intStorageLocationId] = LOT.intStorageLocationId
	,[dblQty] = CASE WHEN (@ysnPost = 1)
					THEN
						CASE WHEN LDL.intLotId IS NULL THEN LD.dblQuantity ELSE LDL.dblGross END 
					ELSE
						CASE WHEN LDL.intLotId IS NULL THEN -LD.dblQuantity ELSE -LDL.dblGross END
					END
	,[intTransactionId] = LD.intLoadId
	,[strTransactionId] = CAST(L.strLoadNumber AS VARCHAR(100))
	,[intTransactionTypeId] = @INVENTORY_SHIPMENT_TYPE
	,[intFOBPointId] = 2
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGLoadDetailLot LDL ON LD.intLoadDetailId = LDL.intLoadDetailId
LEFT JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
LEFT JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intSContractDetailId
OUTER APPLY (SELECT TOP 1 intSubLocationId = LW.intSubLocationId 
				FROM tblLGLoadDetailContainerLink LDCL 
				LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
				LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
				LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
				WHERE LDCL.intLoadDetailId = LD.intLoadDetailId
			) LWH
OUTER APPLY (SELECT TOP (1) intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = LD.intItemId
					AND intLocationId = ISNULL(CT.intCompanyLocationId,LD.intSCompanyLocationId)
				) LOC
WHERE L.intLoadId = @intTransactionId;

SELECT @ysnDirectShip = CASE 
		WHEN intSourceType = 3
			THEN 1
		ELSE 0
		END
FROM tblLGLoad S
WHERE intLoadId = @intTransactionId
 
IF (@ysnDirectShip <> 1 AND @ysnIsReturn <> 1)
BEGIN
	EXEC dbo.uspICIncreaseInTransitOutBoundQty @ItemsToIncreaseInTransitOutBound;
END

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag and Del Qty in the transaction. Increase the concurrency. 
-- 3. Update the Delivered Qty, Gross, Tare, and Net in the details
-- 4. Call any stored procedure for the intergrations with the other modules. 
-- 5. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN

	SELECT TOP 1 @ysnAllowBlankGLEntries = 0
	FROM tblLGLoad L --Header 
	INNER JOIN tblLGLoadDetail LoadDetail ON L.intLoadId = LoadDetail.intLoadId
	INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
	INNER JOIN dbo.tblICItemLocation ItemLocation ON LoadDetail.intSCompanyLocationId = ItemLocation.intLocationId
		AND ItemLocation.intItemId = LoadDetail.intItemId
	LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
	LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
	WHERE L.intLoadId = @intTransactionId

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
		,dblDeliveredQuantity = CASE WHEN (@ysnPost = 1) THEN 
									(SELECT SUM(dblDeliveredQuantity) FROM tblLGLoadDetail WHERE intLoadId = tblLGLoad.intLoadId)
								ELSE 0 END
	WHERE intLoadId = @intTransactionId

	UPDATE Detail
	SET dblDeliveredQuantity = CASE WHEN (@ysnPost = 1) THEN Detail.dblQuantity ELSE 0 END
		,dblDeliveredGross = CASE WHEN (@ysnPost = 1) THEN Detail.dblGross ELSE 0 END
		,dblDeliveredTare = CASE WHEN (@ysnPost = 1) THEN Detail.dblTare ELSE 0 END
		,dblDeliveredNet = CASE WHEN (@ysnPost = 1) THEN Detail.dblNet ELSE 0 END
	FROM dbo.tblLGLoadDetail Detail
		INNER JOIN dbo.tblLGLoad Header ON Detail.intLoadId = Header.intLoadId 
	WHERE Header.intLoadId = @intTransactionId

	DECLARE @ItemsFromInventoryShipment AS dbo.ShipmentItemTableType

	INSERT INTO @ItemsFromInventoryShipment (
		[intShipmentId]
		,[strShipmentId]
		,[intOrderType]
		,[intSourceType]
		,[dtmDate]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intEntityCustomerId]
		,[intInventoryShipmentItemId]
		,[intItemId]
		,[intLocationId]
		,[intItemLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[intItemUOMId]
		,[intWeightUOMId]
		,[dblQty]
		,[dblUOMQty]
		,[dblSalesPrice]
		,[intDockDoorId]
		,[intOrderId]
		,[intSourceId]
		,[intLineNo]
		,[intLoadShipped]
		,[ysnLoad]
		)
	SELECT 
		[intShipmentId] = L.intLoadId
		,[strShipmentId] = L.strLoadNumber
		,[intOrderType] = 1
		,[intSourceType] = -1
		,[dtmDate] = GETDATE()
		,[intCurrencyId] = NULL
		,[dblExchangeRate] = 1
		,[intEntityCustomerId] = LD.intCustomerEntityId
		,[intInventoryShipmentItemId] = LD.intLoadDetailId
		,[intItemId] = LD.intItemId
		,[intLocationId] = LD.intSCompanyLocationId
		,[intItemLocationId] = 
						(SELECT TOP 1 ITL.intItemLocationId
						FROM tblICItemLocation ITL
						WHERE ITL.intItemId = LD.intItemId
							AND ITL.intLocationId = CD.intCompanyLocationId)
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
		,[dblSalesPrice] = ISNULL(CD.dblCashPrice, 0)
		,[intDockDoorId] = NULL
		,[intOrderId] = NULL
		,[intSourceId] = NULL
		,[intLineNo] = ISNULL(LD.intSContractDetailId, 0)
		,[intLoadShipped] = CASE WHEN CH.ysnLoad = 1 THEN 
								CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END
							ELSE NULL END
		,[ysnLoad] = CH.ysnLoad
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
	WHERE L.intLoadId = @intTransactionId

	EXEC dbo.uspCTShipped @ItemsFromInventoryShipment
		,@intEntityUserSecurityId
		,@ysnPost

	-- Mark stock reservation as posted (or unposted)
	EXEC dbo.uspICPostStockReservation @intTransactionId
		,@INVENTORY_SHIPMENT_TYPE
		,@ysnPost

	COMMIT TRAN @TransactionName
END
ELSE
BEGIN 
	ROLLBACK TRAN @TransactionName

	-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	END

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