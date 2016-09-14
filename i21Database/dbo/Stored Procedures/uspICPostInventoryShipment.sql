CREATE PROCEDURE [dbo].[uspICPostInventoryShipment]
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
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
DECLARE @TransactionName AS VARCHAR(500) = 'Inventory Shipment Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE	@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
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

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
	DECLARE @intTransactionId AS INT  
	DECLARE @intCreatedEntityId AS INT  
	DECLARE @ysnAllowUserSelfPost AS BIT   
	DECLARE @ysnTransactionPostedFlag AS BIT  
  
	SELECT TOP 1   
			@intTransactionId = intInventoryShipmentId
			,@ysnTransactionPostedFlag = ysnPosted  
			,@dtmDate = dtmShipDate
			,@intCreatedEntityId = intEntityId  
	FROM	dbo.tblICInventoryShipment
	WHERE	strShipmentNumber = @strTransactionId  
END  

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Inventory Shipment exists   
IF @intTransactionId IS NULL  
BEGIN   
	-- Cannot find the transaction.  
	RAISERROR(50004, 11, 1)  
	GOTO Post_Exit  
END   
  
-- Validate the date against the FY Periods  
IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
BEGIN   
	-- Unable to find an open fiscal year period to match the transaction date.  
	RAISERROR(50005, 11, 1)  
	GOTO Post_Exit  
END  
  
-- Check if the transaction is already posted  
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
BEGIN   
	-- The transaction is already posted.  
	RAISERROR(50007, 11, 1)  
	GOTO Post_Exit  
END   
  
-- Check if the transaction is already posted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	RAISERROR(50008, 11, 1)  
	GOTO Post_Exit  
END   

-- Check Company preference: Allow User Self Post  
IF	dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1 
	AND @intEntityUserSecurityId <> @intCreatedEntityId 
	AND @ysnRecap = 0 
BEGIN   
	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
	IF @ysnPost = 1   
	BEGIN   
		RAISERROR(50013, 11, 1, 'Post')  
		GOTO Post_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		RAISERROR(50013, 11, 1, 'Unpost')  
		GOTO Post_Exit    
	END  
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

	WHERE	dbo.fnGetItemLotType(Detail.intItemId) IN (@LotType_Manual, @LotType_Serial)	
			AND Header.strShipmentNumber = @strTransactionId
			AND ROUND(ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0), 2) <>
				ROUND(Detail.dblQuantity, 2)

	IF @intItemId IS NOT NULL 
	BEGIN 
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		SET @FormattedReceivedQty =  CONVERT(NVARCHAR, CAST(@dblQuantityShipped AS MONEY), 1)
		SET @FormattedLotQty =  CONVERT(NVARCHAR, CAST(@LotQtyInItemUOM AS MONEY), 1)
		SET @FormattedDifference =  CAST(ABS(@dblQuantityShipped - @LotQtyInItemUOM) AS NVARCHAR(50))

		-- 'The Qty to Ship for {Item} is {Ship Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		RAISERROR(80047, 11, 1, @strItemNo, @FormattedReceivedQty, @FormattedLotQty, @FormattedDifference)  

		RETURN -1; 
	END 
END

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT   
IF @@ERROR <> 0 GOTO Post_Exit    

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
	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType  
	DECLARE @StorageItemsForPost AS ItemCostingTableType  

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
		SELECT	intItemId					= DetailItem.intItemId
				,intItemLocationId			= dbo.fnICGetItemLocation(DetailItem.intItemId, Header.intShipFromLocationId)
				,intItemUOMId				=	CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														ELSE
															LotItemUOM.intItemUOMId
			 									END

				,dtmDate					=	dbo.fnRemoveTimeOnDate(Header.dtmShipDate)
				,dblQty						=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															-ISNULL(DetailItem.dblQuantity, 0) 
														ELSE
															-ISNULL(DetailLot.dblQuantityShipped, 0)
												END

				,dblUOMQty					=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															ItemUOM.dblUnitQty
														ELSE
															LotItemUOM.dblUnitQty
												END

				,dblCost					=  ISNULL(
												CASE	WHEN Lot.dblLastCost IS NULL THEN 
															(
																SELECT	TOP 1 dblLastCost 
																FROM	tblICItemPricing 
																WHERE	intItemId = DetailItem.intItemId 
																		AND intItemLocationId = dbo.fnICGetItemLocation(DetailItem.intItemId, Header.intShipFromLocationId)
															)
														ELSE 
															Lot.dblLastCost 
												END, 0)
												* CASE	WHEN  Lot.intLotId IS NULL THEN 
														ItemUOM.dblUnitQty
													ELSE
														LotItemUOM.dblUnitQty
												END

				,dblSalesPrice              = 0.00
				,intCurrencyId              = @DefaultCurrencyId 
				,dblExchangeRate            = 1
				,intTransactionId           = Header.intInventoryShipmentId
				,intTransactionDetailId     = DetailItem.intInventoryShipmentItemId
				,strTransactionId           = Header.strShipmentNumber
				,intTransactionTypeId       = @INVENTORY_SHIPMENT_TYPE
				,intLotId                   = Lot.intLotId
				,intSubLocationId           = ISNULL(Lot.intSubLocationId, DetailItem.intSubLocationId)
				,intStorageLocationId       = ISNULL(Lot.intStorageLocationId, DetailItem.intStorageLocationId) 
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
		WHERE   Header.intInventoryShipmentId = @intTransactionId
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) = @OWNERSHIP_TYPE_OWN

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
			)
			EXEC	@intReturnValue = dbo.uspICPostCosting  
					@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intEntityUserSecurityId

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
		) 
		SELECT	intItemId					= DetailItem.intItemId
				,intItemLocationId			= dbo.fnICGetItemLocation(DetailItem.intItemId, Header.intShipFromLocationId)
				,intItemUOMId				=	CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														ELSE
															LotItemUOM.intItemUOMId
			 									END

				,dtmDate					=	dbo.fnRemoveTimeOnDate(Header.dtmShipDate)
				,dblQty						=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															-ISNULL(DetailItem.dblQuantity, 0) 
														ELSE
															-ISNULL(DetailLot.dblQuantityShipped, 0)
												END

				,dblUOMQty					=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															ItemUOM.dblUnitQty
														ELSE
															LotItemUOM.dblUnitQty
												END

				,dblCost					=  ISNULL(
												CASE	WHEN Lot.dblLastCost IS NULL THEN 
														(SELECT TOP 1 dblLastCost FROM tblICItemPricing WHERE intItemId = DetailItem.intItemId AND intItemLocationId = dbo.fnICGetItemLocation(DetailItem.intItemId, Header.intShipFromLocationId))
													ELSE 
														Lot.dblLastCost 
												END, 0)
				,dblSalesPrice              = 0.00
				,intCurrencyId              = @DefaultCurrencyId 
				,dblExchangeRate            = 1
				,intTransactionId           = Header.intInventoryShipmentId
				,intTransactionDetailId     = DetailItem.intInventoryShipmentItemId
				,strTransactionId           = Header.strShipmentNumber
				,intTransactionTypeId       = @INVENTORY_SHIPMENT_TYPE
				,intLotId                   = Lot.intLotId
				,intSubLocationId           = ISNULL(Lot.intSubLocationId, DetailItem.intSubLocationId)
				,intStorageLocationId       = ISNULL(Lot.intStorageLocationId, DetailItem.intStorageLocationId) 
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
		WHERE   Header.intInventoryShipmentId = @intTransactionId
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) <> @OWNERSHIP_TYPE_OWN

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

	UPDATE @InTransit_Outbound
	SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END

	EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransit_Outbound
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
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END

	UPDATE	dbo.tblICInventoryShipment
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strShipmentNumber = @strTransactionId  

	EXEC dbo.uspICPostInventoryShipmentIntegrations
			@ysnPost
			,@intTransactionId 
			,@intEntityUserSecurityId

	-- Mark stock reservation as posted (or unposted)
	EXEC dbo.uspICPostStockReservation
		@intTransactionId
		,@INVENTORY_SHIPMENT_TYPE
		,@ysnPost

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
END

Post_Exit: