/*
	Parameters:

*/
CREATE PROCEDURE [uspICPostDestinationInventoryShipment]
	@ysnPost AS BIT  = 0  
	,@ysnRecap AS BIT  = 0  
	,@dtmDate AS DATETIME 
	,@DestinationItems AS DestinationShipmentItem READONLY
	,@ShipmentCharges AS DestinationShipmentCharge READONLY
	,@intEntityUserSecurityId AS INT = NULL 
	,@strBatchId AS NVARCHAR(40) = NULL OUTPUT
	,@DestinationItemLots as DestinationShipmentItemLot READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strShipmentNumber AS NVARCHAR(50) 
DECLARE @strInvoiceNumber AS NVARCHAR(50) 
DECLARE @GLEntries AS RecapTableType 
DECLARE @intShipmentId INT
DECLARE @intReturnValue AS INT 
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @intLocationId AS INT 

DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5

DECLARE @strDescription AS NVARCHAR(100) 
		,@actionType AS NVARCHAR(50)
		,@strTransactionType AS NVARCHAR(50) = 'Inventory Shipment at Destination'

/************************************************************************************************************
	VALIDATIONS 
*************************************************************************************************************/

-- Validate the items.
BEGIN 
	DECLARE @InvalidItemId AS INT
			,@strItemNo AS NVARCHAR(50)
			,@strItemType AS NVARCHAR(50) 

	SELECT	TOP 1 
			@InvalidItemId = i.intItemId
			,@strItemNo = i.strItemNo
			,@strItemType = i.strType 
	FROM	@DestinationItems d INNER JOIN tblICItem i 
				ON i.intItemId = d.intItemId
	WHERE	i.strType NOT IN ('Inventory', 'Bundle', 'Kit')

	IF @InvalidItemId IS NOT NULL 
	BEGIN
		-- '{Item} is set as {Item Type} type and that type is not allowed for Shipment.'
		EXEC uspICRaiseError 80163, @strItemNo, @strItemType; 
		GOTO _ExitWithError
	END
END

-- Validate if the shipment is posted. 
BEGIN 
	SET @strShipmentNumber = NULL 
	SELECT	TOP 1 
			@strShipmentNumber = s.strShipmentNumber
	FROM	@DestinationItems d INNER JOIN tblICInventoryShipment s 
				ON d.intInventoryShipmentId = s.intInventoryShipmentId
	WHERE	ISNULL(s.ysnPosted, 0) = 0 
	

	IF @strShipmentNumber IS NOT NULL 
	BEGIN
		-- 'The {Shipment Id} is not posted. Destination Qty can only be updated on a posted shipment.'
		EXEC uspICRaiseError 80192, @strShipmentNumber; 
		GOTO _ExitWithError
	END
END

-- Validate that shipment is not yet processed to invoice. 
BEGIN 
	SET @strInvoiceNumber = NULL 
	SET @strShipmentNumber = NULL 
	SELECT	TOP 1 
			@strInvoiceNumber = inv.strInvoiceNumber 
			,@strShipmentNumber = s.strShipmentNumber
	FROM	@DestinationItems d INNER JOIN tblICInventoryShipment s 
				ON d.intInventoryShipmentId = s.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentItem si
				ON si.intInventoryShipmentId = s.intInventoryShipmentId
			LEFT JOIN (
				tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
					ON inv.intInvoiceId = invD.intInvoiceId
			)
				ON invD.intInventoryShipmentItemId = si.intInventoryShipmentItemId
	WHERE	inv.strInvoiceNumber IS NOT NULL 
	

	IF @strShipmentNumber IS NOT NULL 
	BEGIN
		-- 'Please unpost and delete {Invoice Number} first. Destination Qty in {Shipment Number} will not be updated if it has an invoice already.'
		EXEC uspICRaiseError 80193, @strInvoiceNumber, @strShipmentNumber; 
		GOTO _ExitWithError
	END
END

-- Validate if the shipment is already posted. 
IF @ysnPost = 1 AND @ysnRecap = 0 
BEGIN 
	SET @strInvoiceNumber = NULL 
	SET @strShipmentNumber = NULL 
	SELECT	TOP 1 
			@strShipmentNumber = s.strShipmentNumber
	FROM	@DestinationItems d INNER JOIN tblICInventoryShipment s 
				ON d.intInventoryShipmentId = s.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentItem si
				ON si.intInventoryShipmentId = s.intInventoryShipmentId
	WHERE	s.ysnDestinationPosted = 1
	
	IF @strShipmentNumber IS NOT NULL 
	BEGIN
		-- 'Unable to Post the Destination Qty because {Shipment Number} is already posted.'
		EXEC uspICRaiseError 80194, 'Post', @strShipmentNumber, 'posted'; 
		GOTO _ExitWithError
	END
END

-- Validate if the shipment is already posted. 
IF @ysnPost = 0 AND @ysnRecap = 0 
BEGIN 
	SET @strInvoiceNumber = NULL 
	SET @strShipmentNumber = NULL 
	SELECT	TOP 1 
			@strShipmentNumber = s.strShipmentNumber
	FROM	@DestinationItems d INNER JOIN tblICInventoryShipment s 
				ON d.intInventoryShipmentId = s.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentItem si
				ON si.intInventoryShipmentId = s.intInventoryShipmentId
	WHERE	s.ysnDestinationPosted = 0
	
	IF @strShipmentNumber IS NOT NULL 
	BEGIN
		-- 'Unable to Unpost the Destination Qty because {Shipment Number} is already unposted.'
		EXEC uspICRaiseError 80194, 'Unpost', @strShipmentNumber, 'unposted'; 
		GOTO _ExitWithError
	END
END
 
-- Get the functional currency and default Forex Rate Type Id 
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	DECLARE @intDefaultForexRateTypeId AS INT 
	 
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 

	SELECT	TOP 1 
			@intDefaultForexRateTypeId = intInventoryRateTypeId 
	FROM	tblSMMultiCurrency
END 

-- Get the next batch number
IF @strBatchId IS NULL 
BEGIN 
	SELECT	TOP 1 
			@intLocationId = s.intShipFromLocationId
	FROM	@DestinationItems d INNER JOIN tblICInventoryShipment s 
				ON d.intInventoryShipmentId = s.intInventoryShipmentId

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId   
	IF @@ERROR <> 0 GOTO _ExitWithError    
END 


--------------------------------------------------------------------------------------------  
-- If POST, call the Post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1 
BEGIN 
	-- Update the destination qty. 
	UPDATE	si
	SET		si.dblDestinationQuantity = d.dblDestinationQty
			,si.dblDestinationGross = d.dblDestinationGross
			,si.dblDestinationNet = d.dblDestinationNet
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId
			INNER JOIN tblICItemLocation l
				ON l.intItemId = si.intItemId
				AND l.intLocationId = s.intShipFromLocationId			
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId
				AND si.intItemId = d.intItemId
				AND l.intItemLocationId = d.intItemLocationId
				AND si.intInventoryShipmentItemId = COALESCE(d.intInventoryShipmentItemId, si.intInventoryShipmentItemId) 

	update c
		set c.dblDestinationGrossWeight = b.dblDestinationGrossWeight,
			c.dblDestinationQuantityShipped = b.dblDestinationQuantityShipped,
			c.dblDestinationTareWeight = b.dblDestinationTareWeight	
	from 
		tblICInventoryShipmentItem as a
			join @DestinationItemLots as b
				on a.intInventoryShipmentItemId = b.intInventoryShipmentItemId
					and a.intInventoryShipmentId = b.intInventoryShipmentId
			join tblICInventoryShipmentItemLot c
				on b.intLotId = c.intLotId
					and b.intInventoryShipmentItemId = c.intInventoryShipmentItemId
					
	-- Clear the existing other charges
	DELETE	sCharge
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentCharge sCharge
				ON sCharge.intInventoryShipmentId = s.intInventoryShipmentId			
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId

	-- Insert shipment charges
	INSERT INTO tblICInventoryShipmentCharge (
			intInventoryShipmentId
			, intEntityVendorId
			, intChargeId
			, strCostMethod
			, dblAmount
			, dblRate
			, intContractId
			, intContractDetailId
			, ysnPrice
			, ysnAccrue
			, intCostUOMId
			, intCurrencyId
			, intForexRateTypeId 
			, dblForexRate 
			, strAllocatePriceBy
			, strChargesLink
			, intConcurrencyId
	)
	SELECT 
			sc.intInventoryShipmentId
			, sc.intEntityVendorId
			, sc.intChargeId
			, sc.strCostMethod
			, sc.dblAmount
			, sc.dblRate
			, sc.intContractId
			, sc.intContractDetailId
			, sc.ysnPrice
			, sc.ysnAccrue
			, sc.intCostUOMId
			, ISNULL(sc.intCurrency, @intFunctionalCurrencyId)
			, intForexRateTypeId = CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END  
			, dblForexRate = CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.dblForexRate, forexRate.dblRate) ELSE NULL END   
			, ISNULL(sc.strAllocatePriceBy, 'Unit') 
			, sc.strChargesLink 
			, intConcurrencyId = 1
	FROM	@ShipmentCharges sc INNER JOIN tblICInventoryShipment s
				ON sc.intInventoryShipmentId = s.intInventoryShipmentId 
			-- Get the SM forex rate. 
			OUTER APPLY dbo.fnSMGetForexRate(
				ISNULL(sc.intCurrency, @intFunctionalCurrencyId)
				,CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END  
				,s.dtmShipDate
			) forexRate

	-- Post the GL entries related to the other charges. 
	DECLARE shipments CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	DISTINCT 
			s.strShipmentNumber  
			,s.intInventoryShipmentId
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId
			INNER JOIN tblICItemLocation l
				ON l.intItemId = si.intItemId
				AND l.intLocationId = s.intShipFromLocationId			
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId
				AND si.intItemId = d.intItemId
				AND l.intItemLocationId = d.intItemLocationId
				AND si.intInventoryShipmentItemId = COALESCE(d.intInventoryShipmentItemId, si.intInventoryShipmentItemId) 
	OPEN shipments

	FETCH NEXT FROM shipments 
	INTO	@strShipmentNumber
			,@intShipmentId

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Post the other charges for the shipment
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
			EXEC @intReturnValue = dbo.uspICPostInventoryShipmentOtherCharges 
				@intShipmentId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_SHIPMENT_TYPE
				,@ysnPost

			IF @intReturnValue < 0 GOTO _ExitWithError
		END 

		-- Create and post the inventory adjustment
		IF @ysnRecap = 0 
		BEGIN 
			EXEC @intReturnValue = uspICInventoryAdjustment_CreatePostQtyChangeFromInvShipmentDestination
				@intShipmentId
				,@dtmDate
				,@intEntityUserSecurityId
				,@ysnPost

			IF @intReturnValue < 0 GOTO _ExitWithError
		END 

		-- Create the audit log. 
		SELECT @actionType = 'Destination Posted'
			
		EXEC	dbo.uspSMAuditLog 
				@keyValue = @intShipmentId								-- Primary Key Value of the Inventory Shipment. 
				,@screenName = 'Inventory.view.InventoryShipment'       -- Screen Namespace
				,@entityId = @intEntityUserSecurityId				    -- Entity Id.
				,@actionType = @actionType                              -- Action Type
				,@changeDescription = @strDescription					-- Description
				,@fromValue = ''										-- Previous Value
				,@toValue = ''											-- New Value

		FETCH NEXT FROM shipments 
		INTO	@strShipmentNumber
				,@intShipmentId
	END

	CLOSE shipments
	DEALLOCATE shipments 


	-- Call the Integration sp
	EXEC uspICPostDestinationInventoryShipmentIntegration
		@DestinationItems
		,@ysnPost
		,@intEntityUserSecurityId
END 

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0 
BEGIN   
	DECLARE unpostShipment CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	DISTINCT 
			s.strShipmentNumber  
			,s.intInventoryShipmentId
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId
			INNER JOIN tblICItemLocation l
				ON l.intItemId = si.intItemId
				AND l.intLocationId = s.intShipFromLocationId			
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId
				AND si.intItemId = d.intItemId
				AND l.intItemLocationId = d.intItemLocationId
				AND si.intInventoryShipmentItemId = COALESCE(d.intInventoryShipmentItemId, si.intInventoryShipmentItemId) 
	OPEN unpostShipment

	FETCH NEXT FROM unpostShipment 
	INTO	@strShipmentNumber
			, @intShipmentId

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Unpost the other charges for the shipment
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
			EXEC @intReturnValue = dbo.uspICPostInventoryShipmentOtherCharges 
				@intShipmentId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_SHIPMENT_TYPE	
				,@ysnPost 

			IF @intReturnValue < 0 GOTO _ExitWithError
		END 

		-- Even on unpost, create and post a new inventory adjustment
		IF @ysnRecap = 0 
		BEGIN 
			EXEC @intReturnValue = uspICInventoryAdjustment_CreatePostQtyChangeFromInvShipmentDestination
				@intShipmentId
				,@dtmDate
				,@intEntityUserSecurityId
				,@ysnPost

			IF @intReturnValue < 0 GOTO _ExitWithError
		END 
		
		-- Update the ysnPostedFlag gl entries posted for the destination. 
		BEGIN 			
			UPDATE	GLEntries
			SET		ysnIsUnposted = 1
			FROM	dbo.tblGLDetail GLEntries
			WHERE	GLEntries.intTransactionId = @intShipmentId
					AND GLEntries.strTransactionId = @strShipmentNumber
					AND GLEntries.strTransactionType = @strTransactionType
					AND ISNULL(GLEntries.ysnIsUnposted, 0) = 0
		END 
		
		-- Create the audit log. 
		BEGIN 
			SELECT @actionType = 'Destination Unposted'
			
			EXEC	dbo.uspSMAuditLog 
					@keyValue = @intShipmentId								-- Primary Key Value of the Inventory Shipment. 
					,@screenName = 'Inventory.view.InventoryShipment'       -- Screen Namespace
					,@entityId = @intEntityUserSecurityId				    -- Entity Id.
					,@actionType = @actionType                              -- Action Type
					,@changeDescription = @strDescription					-- Description
					,@fromValue = ''										-- Previous Value
					,@toValue = ''											-- New Value
		END

		-- Get the next shipment in the loop. 
		FETCH NEXT FROM unpostShipment 
		INTO	@strShipmentNumber
				, @intShipmentId
	END

	CLOSE unpostShipment
	DEALLOCATE unpostShipment 

	-- Call the Integration sp
	EXEC uspICPostDestinationInventoryShipmentIntegration
		@DestinationItems
		,@ysnPost
		,@intEntityUserSecurityId

	-- Clear the existing other charges
	DELETE	sCharge
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentCharge sCharge
				ON sCharge.intInventoryShipmentId = s.intInventoryShipmentId			
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId

	-- Clear the destination qty. 
	UPDATE	si
	SET		si.dblDestinationQuantity = NULL 
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentId
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId
END   

IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
BEGIN 
	-- Update the date and transaction type. 
	UPDATE @GLEntries
	SET dtmDate = @dtmDate
		,strTransactionType = @strTransactionType
		
	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
END 

--------------------------------------------------------------------------------------------  
-- Update the shipment destination posted flag. 
-- Add an audit log. 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN
	UPDATE	s
	SET		s.ysnDestinationPosted = @ysnPost 
			,s.dtmDestinationDate = CASE WHEN @ysnPost = 1 THEN @dtmDate ELSE NULL END 
			,s.intConcurrencyId += 1 
	FROM	tblICInventoryShipment s INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId
END 

-- Check the 'Adjust Inventory' settings. 
-- If it is set as 'Destination'
--  a. Create an Inventory adjustment if there is a variance between the shipped qty and destination qty. 
-- If it is set as 'Origin'
--  a. No need to create an Inventory Adjustment. 

-- TODO:
-- Do not allow Shipment Posting to unpost if it has destination qty. 

GOTO _Exit 

_ExitWithError: 
RETURN -1; 

_Exit:  