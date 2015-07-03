CREATE PROCEDURE [dbo].[uspICPostInventoryShipment]
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL    
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

-- Get the Inventory Shipment batch number
DECLARE @strBatchId AS NVARCHAR(40) 
		,@strItemNo AS NVARCHAR(50)
		,@ysnAllowBlankGLEntries AS BIT = 1
		,@intItemId AS INT

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 

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

-- Read the user preference  
BEGIN  
	SELECT	@ysnAllowUserSelfPost = 1  
	FROM	dbo.tblSMPreferences   
	WHERE	strPreference = 'AllowUserSelfPost'   
			AND LOWER(RTRIM(LTRIM(strValue))) = 'true'    
			AND intUserID = @intUserId  
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
IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId AND @ysnRecap = 0   
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

	DECLARE @dblQuantityShipped AS NUMERIC(18,6)
			--,@LotQty AS NUMERIC(18,6)
			,@LotQtyInItemUOM AS NUMERIC(18,6)
			,@QuantityShippedInItemUOM AS NUMERIC(18,6)

	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@dblQuantityShipped		= Detail.dblQuantity
			--,@LotQty					= ISNULL(ItemLot.TotalLotQty, 0)
			,@LotQtyInItemUOM			= ISNULL(ItemLot.TotalLotQtyInDetailItemUOM, 0)
	FROM	tblICInventoryShipment Header INNER JOIN  tblICInventoryShipmentItem Detail 
				ON Header.intInventoryShipmentId = Detail.intInventoryShipmentId	
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = Detail.intItemId
			LEFT JOIN (
				SELECT  AggregrateLot.intInventoryShipmentItemId
						,TotalLotQtyInDetailItemUOM = SUM(
							dbo.fnCalculateQtyBetweenUOM(
								ISNULL(AggregrateLot.intItemUOMId, tblICInventoryShipmentItem.intItemUOMId)
								,tblICInventoryShipmentItem.intItemUOMId
								,AggregrateLot.dblQuantityShipped
							)
						)
						--,TotalLotQty = SUM(ISNULL(AggregrateLot.dblQuantityShipped, 0))
				FROM	dbo.tblICInventoryShipment INNER JOIN dbo.tblICInventoryShipmentItem 
							ON tblICInventoryShipment.intInventoryShipmentId = tblICInventoryShipmentItem.intInventoryShipmentId
						INNER JOIN dbo.tblICInventoryShipmentItemLot AggregrateLot
							ON AggregrateLot.intInventoryShipmentItemId = tblICInventoryShipmentItem.intInventoryShipmentItemId
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
		RAISERROR(51153, 11, 1, @strItemNo, @FormattedReceivedQty, @FormattedLotQty, @FormattedDifference)  
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
	DECLARE @CustodyItemsForPost AS ItemCostingTableType  

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
		SELECT	intItemId					= Detail.intItemId
				,intItemLocationId			= dbo.fnICGetItemLocation(Detail.intItemId, Header.intShipFromLocationId)
				,intItemUOMId				=	CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														ELSE
															LotItemUOM.intItemUOMId
												END

				,dtmDate					=	dbo.fnRemoveTimeOnDate(Header.dtmShipDate)
				,dblQty						=	-1 *
												CASE	WHEN  Lot.intLotId IS NULL THEN 
															ISNULL(Detail.dblQuantity, 0) 
														ELSE
															ISNULL(DetailLot.dblQuantityShipped, 0)
												END

				,dblUOMQty					=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															ItemUOM.dblUnitQty
														ELSE
															LotItemUOM.dblUnitQty
												END
				,dblCost                    = Lot.dblLastCost
				,dblSalesPrice              = 0.00
				,intCurrencyId              = NULL 
				,dblExchangeRate            = 1
				,intTransactionId           = Header.intInventoryShipmentId
				,intTransactionDetailId     = DetailItem.intInventoryShipmentItemId
				,strTransactionId           = Header.strShipmentNumber
				,intTransactionTypeId       = @INVENTORY_SHIPMENT_TYPE
				,intLotId                   = Lot.intLotId
				,intSubLocationId           = Lot.intSubLocationId
				,intStorageLocationId       = Lot.intStorageLocationId
		FROM    tblICInventoryShipment Header INNER JOIN  tblICInventoryShipmentItem DetailItem 
					ON Header.intInventoryShipmentId = DetailItem.intInventoryShipmentId    
				INNER JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intItemUOMId
				LEFT JOIN tblICInventoryShipmentItemLot DetailLot 
					ON DetailLot.intInventoryShipmentItemId = DetailItem.intInventoryShipmentItemId
				LEFT JOIN tblICLot Lot 
					ON Lot.intLotId = DetailLot.intLotId            
				INNER JOIN vyuICGetShipmentItemSource ItemSource 
					ON ItemSource.intInventoryShipmentItemId = DetailItem.intInventoryShipmentItemId
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
			)
			EXEC	dbo.uspICPostCosting  
					@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intUserId
		END
	END 

	-- Process custody items
	BEGIN 
		INSERT INTO @CustodyItemsForPost (  
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
		SELECT	intItemId					= Detail.intItemId
				,intItemLocationId			= dbo.fnICGetItemLocation(Detail.intItemId, Header.intShipFromLocationId)
				,intItemUOMId				=	CASE	WHEN Lot.intLotId IS NULL THEN 
															ItemUOM.intItemUOMId
														ELSE
															LotItemUOM.intItemUOMId
												END

				,dtmDate					=	dbo.fnRemoveTimeOnDate(Header.dtmShipDate)
				,dblQty						=	-1 *
												CASE	WHEN  Lot.intLotId IS NULL THEN 
															ISNULL(Detail.dblQuantity, 0) 
														ELSE
															ISNULL(DetailLot.dblQuantityShipped, 0)
												END

				,dblUOMQty					=	CASE	WHEN  Lot.intLotId IS NULL THEN 
															ItemUOM.dblUnitQty
														ELSE
															LotItemUOM.dblUnitQty
												END
				,dblCost                    = Lot.dblLastCost
				,dblSalesPrice              = 0.00
				,intCurrencyId              = NULL 
				,dblExchangeRate            = 1
				,intTransactionId           = Header.intInventoryShipmentId
				,intTransactionDetailId     = DetailItem.intInventoryShipmentItemId
				,strTransactionId           = Header.strShipmentNumber
				,intTransactionTypeId       = @INVENTORY_SHIPMENT_TYPE
				,intLotId                   = Lot.intLotId
				,intSubLocationId           = Lot.intSubLocationId
				,intStorageLocationId       = Lot.intStorageLocationId
		FROM    tblICInventoryShipment Header INNER JOIN  tblICInventoryShipmentItem DetailItem 
					ON Header.intInventoryShipmentId = DetailItem.intInventoryShipmentId    
				INNER JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intItemUOMId
				LEFT JOIN tblICInventoryShipmentItemLot DetailLot 
					ON DetailLot.intInventoryShipmentItemId = DetailItem.intInventoryShipmentItemId
				LEFT JOIN tblICLot Lot 
					ON Lot.intLotId = DetailLot.intLotId            
				INNER JOIN vyuICGetShipmentItemSource ItemSource 
					ON ItemSource.intInventoryShipmentItemId = DetailItem.intInventoryShipmentItemId
		WHERE   Header.intInventoryShipmentId = @intTransactionId
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) <> @OWNERSHIP_TYPE_OWN

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @CustodyItemsForPost) 
		BEGIN 
			EXEC	dbo.uspICPostCustody
					@CustodyItemsForPost  
					,@strBatchId  
					,@intUserId
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
		)
		EXEC	dbo.uspICUnpostCosting
				@intTransactionId
				,@strTransactionId
				,@strBatchId
				,@intUserId						
	END 
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
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END

	UPDATE	dbo.tblICInventoryShipment
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strShipmentNumber = @strTransactionId  

	EXEC dbo.uspICPostInventoryShipmentIntegrations
			@ysnPost
			,@intTransactionId 
			,@intUserId 
			,@intEntityId

	COMMIT TRAN @TransactionName
END 
    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit: