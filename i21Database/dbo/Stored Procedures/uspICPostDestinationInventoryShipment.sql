/*
	Parameters:

*/
CREATE PROCEDURE [uspICPostDestinationInventoryShipment]
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@dtmDate AS DATETIME 
	,@DestinationItems DestinationShipmentItem READONLY
	,@ShipmentCharges ShipmentChargeStagingTable READONLY
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId AS INT = NULL 
	,@strBatchId NVARCHAR(40) = NULL OUTPUT
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

/************************************************************************************************************
	VALIDATIONS 
*************************************************************************************************************/

-- Validate the items.
BEGIN 
	IF EXISTS(
		SELECT	TOP 1 1
		FROM	@DestinationItems d INNER JOIN tblICItem i 
					ON i.intItemId = d.intItemId
		WHERE	i.strType NOT IN ('Inventory', 'Finished Good', 'Raw Material', 'Bundle', 'Kit')
	)
	BEGIN
		-- 'Shipment for non-inventory items are not allowed.'
		EXEC uspICRaiseError 80163; 
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
		EXEC uspICRaiseError 80194, @strShipmentNumber; 
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
	FROM	tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
				ON s.intInventoryShipmentId = si.intInventoryShipmentItemId
			INNER JOIN tblICItemLocation l
				ON l.intItemId = si.intItemId
				AND l.intLocationId = s.intShipFromLocationId			
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId
				AND si.intItemId = d.intItemId
				AND l.intItemLocationId = d.intItemLocationId
				AND si.intInventoryShipmentItemId = COALESCE(d.intInventoryShipmentItemId, si.intInventoryShipmentItemId) 

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
			, ysnPrice
			, ysnAccrue
			, intCostUOMId
			, intCurrencyId
			, intForexRateTypeId 
			, dblForexRate 
			, intConcurrencyId
	)
	SELECT 
			sc.intShipmentId
			, sc.intEntityVendorId
			, sc.intChargeId
			, sc.strCostMethod
			, sc.dblAmount
			, sc.dblRate
			, sc.intContractId
			, sc.ysnPrice
			, sc.ysnAccrue
			, sc.intCostUOMId
			, ISNULL(sc.intCurrency, @intFunctionalCurrencyId)
			, intForexRateTypeId = CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END  
			, dblForexRate = CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.dblForexRate, forexRate.dblRate) ELSE NULL END   
			, intConcurrencyId = 1
	FROM	@ShipmentCharges sc INNER JOIN tblICInventoryShipment s
				ON sc.intShipmentId = s.intInventoryShipmentId 
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
				ON s.intInventoryShipmentId = si.intInventoryShipmentItemId
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
			@intShipmentId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_SHIPMENT_TYPE

		IF @intReturnValue < 0 GOTO _ExitWithError

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
				ON s.intInventoryShipmentId = si.intInventoryShipmentItemId
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
		EXEC @intReturnValue = dbo.uspICUnpostInventoryShipmentOtherCharges 
			@intShipmentId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_SHIPMENT_TYPE	

		IF @intReturnValue < 0 GOTO _ExitWithError

		-- Create the audit log. 
		SELECT @actionType = 'Destination Unposted'
			
		EXEC	dbo.uspSMAuditLog 
				@keyValue = @intShipmentId								-- Primary Key Value of the Inventory Shipment. 
				,@screenName = 'Inventory.view.InventoryShipment'       -- Screen Namespace
				,@entityId = @intEntityUserSecurityId				    -- Entity Id.
				,@actionType = @actionType                              -- Action Type
				,@changeDescription = @strDescription					-- Description
				,@fromValue = ''										-- Previous Value
				,@toValue = ''											-- New Value


		FETCH NEXT FROM unpostShipment 
		INTO	@strShipmentNumber
				, @intShipmentId
	END

	CLOSE unpostShipment
	DEALLOCATE unpostShipment 

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
				ON s.intInventoryShipmentId = si.intInventoryShipmentItemId
			INNER JOIN @DestinationItems d
				ON s.intInventoryShipmentId = d.intInventoryShipmentId

END   

IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
BEGIN 
	UPDATE @GLEntries
	SET dtmDate = @dtmDate

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

GOTO _Exit 

_ExitWithError: 
RETURN -1; 

_Exit:  