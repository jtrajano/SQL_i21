CREATE PROCEDURE [dbo].[uspICPostInventoryShipment]
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId AS INT = NULL 
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
DECLARE @TransactionName AS VARCHAR(500) = 'InventoryShipment' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  

DECLARE	@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = NULL --'Cost of Goods'
		,@OWNERSHIP_TYPE_OWN AS INT = 1
		,@OWNERSHIP_TYPE_STORAGE AS INT = 2
		,@OWNERSHIP_TYPE_CONSIGNED_PURCHASE AS INT = 3
		,@OWNERSHIP_TYPE_CONSIGNED_SALE AS INT = 4

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

-- Get the default currency ID
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Get the Inventory Shipment batch number
DECLARE @strItemNo AS NVARCHAR(50)
		,@ysnAllowBlankGLEntries AS BIT = 1
		,@intItemId AS INT
		,@strCurrencyId AS NVARCHAR(50)
		,@strFunctionalCurrencyId AS NVARCHAR(50)

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 
		,@dummyGLEntries AS RecapTableType 
		,@intReturnValue AS INT
		,@intEntityCustomerId AS INT 

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT  
			,@intFobPointId AS INT 
			,@intLocationId AS INT
  
	SELECT TOP 1   
			@intTransactionId = s.intInventoryShipmentId
			,@ysnTransactionPostedFlag = s.ysnPosted  
			,@dtmDate = s.dtmShipDate
			,@intCreatedEntityId = s.intEntityId  
			,@intFobPointId = fp.intFobPointId
			,@intLocationId = s.intShipFromLocationId
			,@intEntityCustomerId = s.intEntityCustomerId
	FROM	dbo.tblICInventoryShipment s LEFT JOIN tblSMFreightTerms ft
				ON s.intFreightTermId = ft.intFreightTermId
			LEFT JOIN tblICFobPoint fp
				ON fp.strFobPoint = ft.strFobPoint
	WHERE	strShipmentNumber = @strTransactionId  

	---- Initialize the account to counter inventory 
	--SELECT	@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY = NULL 
	--WHERE	ISNULL(@intFobPointId, @FOB_ORIGIN) = @FOB_DESTINATION 
END  

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
BEGIN 
	DECLARE @strInvoiceNumber AS NVARCHAR(50)
			,@strChargeItem AS NVARCHAR(50)
			,@strBillNumber AS NVARCHAR(50)

	-- Validate if the Inventory Shipment exists   
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
  
	-- Check if the transaction is already posted  
	IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
	BEGIN   
		-- The transaction is already unposted.  
		EXEC uspICRaiseError 80170; 
		GOTO With_Rollback_Exit  
	END   

	IF @ysnRecap = 0
	BEGIN 
		UPDATE	dbo.tblICInventoryShipment
		SET		ysnPosted = @ysnPost
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		WHERE	strShipmentNumber = @strTransactionId  
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

	-- Do not allow unpost if Shipment is already processed to Sales Invoice. 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		SET @strInvoiceNumber = NULL 
		SELECT	TOP 1 
				@strInvoiceNumber = Invoice.strInvoiceNumber
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
				LEFT JOIN dbo.tblARInvoiceDetail InvoiceItems
					ON InvoiceItems.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
					AND InvoiceItems.intItemId = ShipmentItem.intItemId 
				INNER JOIN dbo.tblARInvoice Invoice
					ON Invoice.intInvoiceId = InvoiceItems.intInvoiceId
		WHERE	Shipment.intInventoryShipmentId = @intTransactionId
				AND InvoiceItems.intInvoiceId IS NOT NULL

		IF @strInvoiceNumber IS NOT NULL 
		BEGIN 
			EXEC uspICRaiseError 80089, @strInvoiceNumber;
			GOTO With_Rollback_Exit    
		END 
	END 

	-- Do not allow unpost if other charge is already included in invoice. 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		SET @strInvoiceNumber = NULL 
		SELECT	TOP 1 
				@strInvoiceNumber = Invoice.strInvoiceNumber
				,@strChargeItem = Item.strItemNo
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge Charge
					ON Shipment.intInventoryShipmentId = Charge.intInventoryShipmentId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Charge.intChargeId				
				LEFT JOIN dbo.tblARInvoiceDetail InvoiceItems
					ON InvoiceItems.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId
				INNER JOIN dbo.tblARInvoice Invoice
					ON Invoice.intInvoiceId = InvoiceItems.intInvoiceId
		WHERE	Shipment.intInventoryShipmentId = @intTransactionId
				AND InvoiceItems.intInvoiceId IS NOT NULL

		IF @strInvoiceNumber IS NOT NULL 
		BEGIN 
			EXEC uspICRaiseError 80089, @strInvoiceNumber;
			GOTO With_Rollback_Exit    
		END 
	END
		
	-- Do not allow unpost if other charge is already billed. 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		SET @strBillNumber = NULL 
		SELECT	TOP 1 
				@strBillNumber = Bill.strBillId
				,@strChargeItem = Item.strItemNo
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge Charge
					ON Shipment.intInventoryShipmentId = Charge.intInventoryShipmentId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Charge.intChargeId				
				LEFT JOIN dbo.tblAPBillDetail BillItems
					ON BillItems.intInventoryShipmentChargeId = Charge.intInventoryShipmentChargeId
				INNER JOIN dbo.tblAPBill Bill
					ON Bill.intBillId = BillItems.intBillId
		WHERE	Shipment.intInventoryShipmentId = @intTransactionId
				AND BillItems.intBillDetailId IS NOT NULL

		IF @strBillNumber IS NOT NULL 
		BEGIN 
			-- 'Unable to unpost the Inventory Shipment. The {Other Charge} was billed.'
			EXEC uspICRaiseError 80091, @strChargeItem;
			GOTO With_Rollback_Exit    
		END 
	END 

	-- Check if non-active lots slipped through the shipment screen
	DECLARE @strLotNo NVARCHAR(100)
	SELECT TOP 1 @strLotNo = l.strLotNumber
	FROM tblICInventoryShipmentItemLot sl
		INNER JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentItemId = sl.intInventoryShipmentItemId
		INNER JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = si.intInventoryShipmentId
		INNER JOIN tblICLot l ON l.intLotId = sl.intLotId
	WHERE s.intInventoryShipmentId = @intTransactionId
		AND l.intLotStatusId <> 1

	IF @strLotNo IS NOT NULL
	BEGIN
		-- Unable to post lot %s. Only active lots are allowed to be shipped.
		EXEC uspICRaiseError 80208, @strLotNo;
		GOTO With_Rollback_Exit
	END
	
	-- Check if the Shipment quantity matches the total Quantity in the Lot
	BEGIN 
		SET @strItemNo = NULL 
		SET @intItemId = NULL 

		DECLARE @dblQuantityShipped AS NUMERIC(38,20)
				--,@LotQty AS NUMERIC(38,20)
				,@LotQtyInItemUOM AS NUMERIC(38,20)
				,@QuantityShippedInItemUOM AS NUMERIC(38,20)

		DECLARE @FormattedReceivedQty AS NVARCHAR(50)
		DECLARE @FormattedLotQty AS NVARCHAR(50)
		DECLARE @FormattedDifference AS NVARCHAR(50)

		SELECT	TOP 1 
				@strItemNo					= Item.strItemNo
				,@intItemId					= Item.intItemId
				,@dblQuantityShipped		= Detail.dblQuantity
				,@LotQtyInItemUOM			= ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0)
		FROM	tblICInventoryShipment Header INNER JOIN  tblICInventoryShipmentItem Detail 
					ON Header.intInventoryShipmentId = Detail.intInventoryShipmentId	
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Detail.intItemId
				LEFT JOIN (
					SELECT  AggregrateLot.intInventoryShipmentItemId
							,TotalLotQtyInDetailItemUOM = SUM(
								dbo.fnCalculateQtyBetweenUOM(
									ISNULL(Lot.intItemUOMId, tblICInventoryShipmentItem.intItemUOMId)
									,tblICInventoryShipmentItem.intItemUOMId
									,AggregrateLot.dblQuantityShipped
								)
							)
					FROM	dbo.tblICInventoryShipment INNER JOIN dbo.tblICInventoryShipmentItem 
								ON tblICInventoryShipment.intInventoryShipmentId = tblICInventoryShipmentItem.intInventoryShipmentId
							INNER JOIN dbo.tblICInventoryShipmentItemLot AggregrateLot
								ON AggregrateLot.intInventoryShipmentItemId = tblICInventoryShipmentItem.intInventoryShipmentItemId
							INNER JOIN tblICLot Lot
								ON Lot.intLotId = AggregrateLot.intLotId
					WHERE	tblICInventoryShipment.strShipmentNumber = @strTransactionId				
					GROUP BY AggregrateLot.intInventoryShipmentItemId
				) ItemLot
					ON ItemLot.intInventoryShipmentItemId = Detail.intInventoryShipmentItemId	

		WHERE	dbo.fnGetItemLotType(Detail.intItemId) <> 0 
				AND Header.strShipmentNumber = @strTransactionId
				AND ROUND(ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0), 2) <>
					ROUND(Detail.dblQuantity, 2)

		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'The Qty to Ship for {Item} is {Ship Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
			DECLARE @difference AS NUMERIC(38, 20) = ABS(@dblQuantityShipped - @LotQtyInItemUOM)
			EXEC uspICRaiseError 80047, @strItemNo, @dblQuantityShipped, @LotQtyInItemUOM, @difference
			GOTO With_Rollback_Exit; 
		END 
	END

	-- Check if the transaction is using a foreign currency and it has a missing forex rate. 
	BEGIN 		
		SELECT @strItemNo = NULL
				,@intItemId = NULL 
				,@strCurrencyId = NULL 
				,@strFunctionalCurrencyId = NULL 

		SELECT TOP 1 
				@strTransactionId = Shipment.strShipmentNumber 
				,@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
				,@strCurrencyId = c.strCurrency
				,@strFunctionalCurrencyId = fc.strCurrency
		FROM	tblICInventoryShipment Shipment INNER JOIN tblICInventoryShipmentItem ShipmentItem
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId	
				INNER JOIN tblICItem Item
					ON Item.intItemId = ShipmentItem.intItemId
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID =  Shipment.intCurrencyId
				LEFT JOIN tblSMCurrency fc
					ON fc.intCurrencyID =  @intFunctionalCurrencyId
		WHERE	ISNULL(ShipmentItem.dblForexRate, 0) = 0 
				AND Shipment.intCurrencyId IS NOT NULL 
				AND Shipment.intCurrencyId <> @intFunctionalCurrencyId
				AND Shipment.strShipmentNumber = @strTransactionId

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- '{Transaction Id} is using a foreign currency. Please check if {Item No} has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from {Foreign Currency} to {Functional Currency}.'
			EXEC uspICRaiseError 80162, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId;
			GOTO With_Rollback_Exit; 
		END 
	END 

	-- Do not allow unpost shipment has destination qty. 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		IF EXISTS (
			SELECT	TOP 1 1 
			FROM	tblICInventoryShipment s
			WHERE	s.strShipmentNumber = @strTransactionId
					AND dtmDestinationDate IS NOT NULL 
					AND ysnDestinationPosted = 1
		)
		BEGIN 
			-- 'Unable to unpost {Shipment Number} because you need to unpost the Destination Qty first.'
			EXEC uspICRaiseError 80195, @strTransactionId;
			GOTO Post_Exit    
		END 
	END

	-- Do not allow post if Lot bond is not yet released. 
	IF @ysnPost = 1 AND @ysnRecap = 0 
	BEGIN 
		EXEC uspMFValidateInventoryShipment @intTransactionId
		IF @@ERROR <> 0 GOTO With_Rollback_Exit    
	END 
END

-- Get the next batch number
BEGIN 
	SET @strBatchId = NULL 
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId   
	IF @@ERROR <> 0 GOTO With_Rollback_Exit    
END 

-- Call any integration sp before doing the post/unpost. 
BEGIN 
	EXEC dbo.uspICBeforePostInventoryShipmentIntegration
			@ysnPost
			,@intTransactionId 
			,@intEntityUserSecurityId
END 

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType  
	DECLARE @ItemsForInTransitCosting AS ItemInTransitCostingTableType
	DECLARE @StorageItemsForPost AS ItemCostingTableType  

	-- Process the Other Charges
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
		EXEC @intReturnValue = dbo.uspICPostInventoryShipmentOtherCharges 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_SHIPMENT_TYPE
			,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
			
	END 	

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
				,intForexRateTypeId
				,dblForexRate
				,intCategoryId
		) 
		SELECT	intItemId					= DetailItem.intItemId
				,intItemLocationId			= dbo.fnICGetItemLocation(DetailItem.intItemId, Header.intShipFromLocationId)
				,intItemUOMId				=	CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														WHEN Lot.intWeightUOMId IS NULL THEN 
															Lot.intItemUOMId
														ELSE
															Lot.intWeightUOMId
			 									END

				,dtmDate					=	dbo.fnRemoveTimeOnDate(Header.dtmShipDate)
				,dblQty						=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															-ISNULL(DetailItem.dblQuantity, 0) 
														WHEN Lot.intWeightUOMId IS NULL THEN 
															-ISNULL(DetailLot.dblQuantityShipped, 0)
														ELSE
															-dbo.fnMultiply(
																DetailLot.dblQuantityShipped
																, DetailLot.dblWeightPerQty
															)
												END

				,dblUOMQty					=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															ItemUOM.dblUnitQty
														WHEN  Lot.intWeightUOMId IS NULL THEN 
															LotItemUOM.dblUnitQty
														ELSE
															LotWeightUOM.dblUnitQty
												END

				,dblCost					= 0.00 
				,dblSalesPrice              = 
											dbo.fnCalculateCostBetweenUOM (
												ISNULL(DetailItem.intPriceUOMId, ItemUOM.intItemUOMId) 
												,CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														WHEN Lot.intWeightUOMId IS NULL THEN 
															Lot.intItemUOMId
														ELSE
															Lot.intWeightUOMId
			 									END
												,DetailItem.dblUnitPrice
											)


				,intCurrencyId              = @intFunctionalCurrencyId 
				,dblExchangeRate            = 1
				,intTransactionId           = Header.intInventoryShipmentId
				,intTransactionDetailId     = DetailItem.intInventoryShipmentItemId
				,strTransactionId           = Header.strShipmentNumber
				,intTransactionTypeId       = @INVENTORY_SHIPMENT_TYPE
				,intLotId                   = Lot.intLotId
				,intSubLocationId           = ISNULL(Lot.intSubLocationId, DetailItem.intSubLocationId)
				,intStorageLocationId       = ISNULL(Lot.intStorageLocationId, DetailItem.intStorageLocationId) 
				,intForexRateTypeId			= DetailItem.intForexRateTypeId
				,dblForexRate				= 1 
				,intCategoryId				= i.intCategoryId 
		FROM    tblICInventoryShipment Header INNER JOIN  tblICInventoryShipmentItem DetailItem 
					ON Header.intInventoryShipmentId = DetailItem.intInventoryShipmentId    
				INNER JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intItemUOMId
				LEFT JOIN tblICInventoryShipmentItemLot DetailLot 
					ON DetailLot.intInventoryShipmentItemId = DetailItem.intInventoryShipmentItemId
				LEFT JOIN tblICLot Lot 
					ON Lot.intLotId = DetailLot.intLotId            
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId   
				LEFT JOIN tblICItemUOM LotWeightUOM
					ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId					         
				LEFT JOIN tblICItem i
					ON DetailItem.intItemId = i.intItemId
		WHERE   Header.intInventoryShipmentId = @intTransactionId
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) = @OWNERSHIP_TYPE_OWN
				AND i.strType <> 'Bundle' -- Do not include Bundle items in the item costing. Bundle components are the ones included in the item costing. 

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN 
			SET @ysnAllowBlankGLEntries = 0

			-- Call the Costing routine. 
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
			EXEC	@intReturnValue = dbo.uspICPostCosting  
					@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit

			-- Generate the GL entries
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
			EXEC @intReturnValue = dbo.uspICCreateGLEntries 
				@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit

			-- Get values for the In-Transit Costing 
			INSERT INTO @ItemsForInTransitCosting (
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
			)
			SELECT
					[intItemId] 
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
					,[intFobPointId] = @intFobPointId
					,[intInTransitSourceLocationId] = t.intItemLocationId
					,[intForexRateTypeId] = t.intForexRateTypeId
					,[dblForexRate] = t.dblForexRate
			FROM	tblICInventoryTransaction t 
			WHERE	t.strTransactionId = @strTransactionId
					AND t.ysnIsUnposted = 0 
					AND t.strBatchId = @strBatchId
					--AND @intFobPointId = @FOB_DESTINATION
					AND t.dblQty < 0 -- Ensure the Qty is negative. Credit Memo are positive Qtys.  Credit Memo does not ship out but receives stock. 

			IF EXISTS (SELECT TOP 1 1 FROM @ItemsForInTransitCosting)
			BEGIN 
				-- Call the post routine for the In-Transit costing. 
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
				EXEC	@intReturnValue = dbo.uspICPostInTransitCosting  
						@ItemsForInTransitCosting  
						,@strBatchId  
						,NULL 
						,@intEntityUserSecurityId
			END 

			IF @intReturnValue < 0 GOTO With_Rollback_Exit						
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
				,intForexRateTypeId
				,dblForexRate
		) 
		SELECT	intItemId					= DetailItem.intItemId
				,intItemLocationId			= dbo.fnICGetItemLocation(DetailItem.intItemId, Header.intShipFromLocationId)
				,intItemUOMId				=	CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														WHEN Lot.intWeightUOMId IS NULL THEN 
															Lot.intItemUOMId
														ELSE
															Lot.intWeightUOMId
			 									END

				,dtmDate					=	dbo.fnRemoveTimeOnDate(Header.dtmShipDate)
				,dblQty						=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															-ISNULL(DetailItem.dblQuantity, 0) 
														WHEN Lot.intWeightUOMId IS NULL THEN 
															-ISNULL(DetailLot.dblQuantityShipped, 0)
														ELSE
															-dbo.fnMultiply(
																DetailLot.dblQuantityShipped
																, DetailLot.dblWeightPerQty
															)
												END

				,dblUOMQty					=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															ItemUOM.dblUnitQty
														WHEN  Lot.intWeightUOMId IS NULL THEN 
															LotItemUOM.dblUnitQty
														ELSE
															LotWeightUOM.dblUnitQty
												END

				,dblCost					= 0.00 
				,dblSalesPrice              = 
											dbo.fnCalculateCostBetweenUOM (
												ISNULL(DetailItem.intPriceUOMId, ItemUOM.intItemUOMId) 
												,CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														WHEN Lot.intWeightUOMId IS NULL THEN 
															Lot.intItemUOMId
														ELSE
															Lot.intWeightUOMId
			 									END
												,DetailItem.dblUnitPrice
											)
				,intCurrencyId              = @intFunctionalCurrencyId 
				,dblExchangeRate            = 1
				,intTransactionId           = Header.intInventoryShipmentId
				,intTransactionDetailId     = DetailItem.intInventoryShipmentItemId
				,strTransactionId           = Header.strShipmentNumber
				,intTransactionTypeId       = @INVENTORY_SHIPMENT_TYPE
				,intLotId                   = Lot.intLotId
				,intSubLocationId           = ISNULL(Lot.intSubLocationId, DetailItem.intSubLocationId)
				,intStorageLocationId       = ISNULL(Lot.intStorageLocationId, DetailItem.intStorageLocationId) 
				,intForexRateTypeId			= DetailItem.intForexRateTypeId
				,dblForexRate				= 1 
		FROM    tblICInventoryShipment Header INNER JOIN  tblICInventoryShipmentItem DetailItem 
					ON Header.intInventoryShipmentId = DetailItem.intInventoryShipmentId    
				INNER JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intItemUOMId
				LEFT JOIN tblICInventoryShipmentItemLot DetailLot 
					ON DetailLot.intInventoryShipmentItemId = DetailItem.intInventoryShipmentItemId
				LEFT JOIN tblICLot Lot 
					ON Lot.intLotId = DetailLot.intLotId            
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId   
				LEFT JOIN tblICItemUOM LotWeightUOM
					ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId					         
				LEFT JOIN tblICItem i
					ON DetailItem.intItemId = i.intItemId
		WHERE   Header.intInventoryShipmentId = @intTransactionId
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) <> @OWNERSHIP_TYPE_OWN
				AND i.strType <> 'Bundle' -- Do not include Bundle items in the storage costing. Bundle components are the ones included in the storage costing. 
				
		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
		BEGIN 
			EXEC	@intReturnValue = dbo.uspICPostStorage
					@StorageItemsForPost  
					,@strBatchId  
					,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END
	END 

	-- Post the Taxes from the Other Charges
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
		EXEC dbo.uspICPostInventoryShipmentTaxes 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_SHIPMENT_TYPE
			,1	
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
			EXEC @intReturnValue = dbo.uspICPostInventoryShipmentOtherCharges 
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

IF @ysnRecap = 0 
BEGIN 
	-- Update the in-transit outbound
	DECLARE @InTransit_Outbound InTransitTableType

	INSERT INTO @InTransit_Outbound (
			intItemId
			, intItemLocationId
			, intItemUOMId
			, intLotId
			, intSubLocationId
			, intStorageLocationId
			, dblQty
			, intTransactionId
			, strTransactionId
			, intTransactionTypeId
			, intFOBPointId
	)
	SELECT	
			intItemId				= si.intItemId
			,intItemLocationId		= il.intItemLocationId
			,intItemUOMId = 
				CASE	WHEN l.intLotId IS NULL THEN 
							iu.intItemUOMId
						ELSE
							lotPackUOM.intItemUOMId
				END
			,intLotId				= sil.intLotId
			,intSubLocationId		= si.intSubLocationId
			,intStorageLocationId	= si.intStorageLocationId
			,dblQty	=	
				CASE	WHEN  l.intLotId IS NULL THEN 
							-ISNULL(si.dblQuantity, 0) 
						ELSE
							-ISNULL(sil.dblQuantityShipped, 0)
				END	
			,intTransactionId		= s.intInventoryShipmentId
			,strTransactionId		= s.strShipmentNumber
			,intTransactionTypeId	= @INVENTORY_SHIPMENT_TYPE
			,intFobPointId			= @intFobPointId
	FROM    tblICInventoryShipment s INNER JOIN  tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId    
			INNER JOIN tblICItemLocation il
				ON il.intItemId = si.intItemId
				AND il.intLocationId = s.intShipFromLocationId
			INNER JOIN tblICItemUOM iu 
				ON iu.intItemUOMId = si.intItemUOMId
			LEFT JOIN tblICInventoryShipmentItemLot sil
				ON sil.intInventoryShipmentItemId = si.intInventoryShipmentItemId
			LEFT JOIN tblICLot l
				ON l.intLotId = sil.intLotId
			LEFT JOIN tblICItemUOM lotPackUOM
				ON lotPackUOM.intItemUOMId = l.intItemUOMId
	WHERE   s.intInventoryShipmentId = @intTransactionId
			AND ISNULL(si.intOwnershipType, @OWNERSHIP_TYPE_OWN) = @OWNERSHIP_TYPE_OWN

	UPDATE @InTransit_Outbound
	SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END

	EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransit_Outbound
END 

-- Clean up the recap data. 
BEGIN 
	UPDATE @GLEntries
	SET dblDebitForeign = ISNULL(dblDebitForeign, 0)
		,dblCreditForeign = ISNULL(dblCreditForeign, 0) 

	-- If shipment is in foreign currency, then make sure the Foreign Debits and Credits are filled-in. 
	UPDATE	glEntries
	SET
			dblDebitForeign = CASE WHEN dblDebit <> 0 AND dblDebitForeign = 0 AND si.dblForexRate <> 0 THEN ISNULL(dblDebit / si.dblForexRate, 0) ELSE ISNULL(dblDebitForeign, 0) END
			,dblCreditForeign = CASE WHEN dblCredit <> 0 AND dblCreditForeign = 0 AND si.dblForexRate <> 0 THEN ISNULL(dblCredit / si.dblForexRate, 0) ELSE ISNULL(dblCreditForeign, 0) END 
			,intCurrencyId = s.intCurrencyId
			,dblExchangeRate = si.dblForexRate
			,dblForeignRate = si.dblForexRate
			,strRateType = currencyRateType.strCurrencyExchangeRateType
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId
			INNER JOIN tblICInventoryTransaction t
				ON t.strTransactionId = s.strShipmentNumber
				AND t.intTransactionDetailId = si.intInventoryShipmentItemId
			INNER JOIN @GLEntries glEntries
				ON glEntries.intJournalLineNo = t.intInventoryTransactionId 			
				AND glEntries.strTransactionId = s.strShipmentNumber 
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = si.intForexRateTypeId
	WHERE	s.strShipmentNumber = @strTransactionId
			AND s.intCurrencyId <> @intFunctionalCurrencyId
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

	-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	END 
	ELSE IF NOT EXISTS (SELECT TOP 1 1 FROM @ItemsForPost) 
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
-- 3. Call any stored procedure for the intergrations with the other modules. 
-- 4. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN
	-- Check if blank GL entries are allowed
	-- If there is a company owned stock, do not allow blank gl entries. 
	SELECT	TOP 1 
			@ysnAllowBlankGLEntries = 0
	FROM	dbo.tblICInventoryShipment Header INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Header.intShipFromLocationId = ItemLocation.intLocationId
			INNER JOIN dbo.tblICInventoryShipmentItem DetailItem 
				ON Header.intInventoryShipmentId = DetailItem.intInventoryShipmentId 
				AND ItemLocation.intItemId = DetailItem.intItemId
			LEFT JOIN dbo.tblICInventoryShipmentItemLot DetailItemLot
				ON DetailItem.intInventoryShipmentItemId = DetailItemLot.intInventoryShipmentItemId
	WHERE	Header.intInventoryShipmentId = @intTransactionId   
			AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) = @OWNERSHIP_TYPE_OWN
			 
	IF @ysnAllowBlankGLEntries = 0 
	BEGIN 
		UPDATE @GLEntries
		SET intEntityId = @intEntityCustomerId
		WHERE intEntityId IS NULL 

		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END

	EXEC dbo.uspICAfterPostInventoryShipmentIntegration
			@ysnPost
			,@intTransactionId 
			,@intEntityUserSecurityId

	COMMIT TRAN @TransactionName
END 

-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId							-- Primary Key Value of the Inventory Shipment. 
			,@screenName = 'Inventory.view.InventoryShipment'       -- Screen Namespace
			,@entityId = @intEntityUserSecurityId				    -- Entity Id.
			,@actionType = @actionType                              -- Action Type
			,@changeDescription = @strDescription					-- Description
			,@fromValue = ''										-- Previous Value
			,@toValue = ''											-- New Value
END

GOTO Post_Exit
    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
With_Rollback_Exit:
IF @@TRANCOUNT > 1 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
	RETURN -1
END

Post_Exit: