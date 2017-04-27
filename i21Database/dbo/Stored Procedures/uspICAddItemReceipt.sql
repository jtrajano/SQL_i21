/*

Important Notes:

Accepted values for ReceiptStagingTable.intGrossNetUOMId:
	1. -1 (or any negative value) means NULL gross/net uom
	2. NULL means it will use the stock uom of the item as the gross/net uom
	3. or provide a [valid gross/net uom id]
	4. If you provided an invalid gross/net uom id, it will use the stock unit of the item. 
*/

CREATE PROCEDURE [dbo].[uspICAddItemReceipt]
	@ReceiptEntries ReceiptStagingTable READONLY
	,@OtherCharges ReceiptOtherChargesTableType READONLY 
	,@intUserId AS INT	
	,@LotEntries ReceiptItemLotStagingTable READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN 
	DECLARE @TransactionName AS VARCHAR(500) = 'uspICAddItemReceipt_' + CAST(NEWID() AS NVARCHAR(100));
	BEGIN TRAN @TransactionName
	SAVE TRAN @TransactionName
END 

DECLARE @intEntityId AS INT
DECLARE @startingNumberId_InventoryReceipt AS INT = 23;
DECLARE @receiptNumber AS NVARCHAR(50);

DECLARE @inventoryReceiptId AS INT
		,@strSourceId AS NVARCHAR(50)
		,@strSourceScreenName AS NVARCHAR(50)
		,@strReceiptNumber AS NVARCHAR(50)
		,@intLocationId AS INT 
		
-- Get the entity id
SELECT	@intEntityId = [intEntityId]
FROM	dbo.tblSMUserSecurity 
WHERE	[intEntityId] = @intUserId

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemReceiptResult (
		intSourceId INT
		,intInventoryReceiptId INT
	)
END 

CREATE TABLE #tmpComputeItemTaxes (
	intId					INT IDENTITY(1, 1) PRIMARY KEY 

	-- Integration fields. Foreign keys. 
	,intHeaderId			INT
	,intDetailId			INT 
	,intTaxDetailId			INT 
	,dtmDate				DATETIME 
	,intItemId				INT

	-- Taxes fields
	,intTaxGroupId			INT
	,intTaxCodeId			INT
	,intTaxClassId			INT
	,strTaxableByOtherTaxes NVARCHAR(MAX) 
	,strCalculationMethod	NVARCHAR(50)
	,dblRate				NUMERIC(18,6)
	,dblTax					NUMERIC(18,6)
	,dblAdjustedTax			NUMERIC(18,6)
	,ysnCheckoffTax			BIT

	-- Fields used in the calculation of the taxes
	,dblAmount				NUMERIC(18,6) 
	,dblQty					NUMERIC(18,6) 		
		
	-- Internal fields
	,ysnCalculated			BIT 
	,dblCalculatedTaxAmount	NUMERIC(18,6) 
)

-- Ownership Types
DECLARE	@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

DECLARE @DataForReceiptHeader TABLE(
	intId INT IDENTITY PRIMARY KEY CLUSTERED
    ,Vendor INT
    ,BillOfLadding NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,ReceiptType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,Location INT
	,ShipVia INT
	,ShipFrom INT
	,Currency INT
	,intSourceType INT
	,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--,intTaxGroupId INT
)

-- Sort the data from @ReceiptEntries and determine which ones are the header records. 
INSERT INTO @DataForReceiptHeader(
		Vendor
		,BillOfLadding
		,ReceiptType
		,Location
		,ShipVia
		,ShipFrom
		,Currency
		,intSourceType
		--,intTaxGroupId
)
SELECT	RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
		--,RawData.intTaxGroupId
FROM	@ReceiptEntries RawData
GROUP BY RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
		--,RawData.intTaxGroupId
;

-- Validate if there is data to process. If there is no data, then raise an error. 
IF NOT EXISTS (SELECT TOP 1 1 FROM @DataForReceiptHeader)
BEGIN 
	-- 'Data not found. Unable to create the Inventory Receipt.'
	RAISERROR('Data not found. Unable to create the Inventory Receipt.', 11, 1);	
	GOTO _Exit;
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

-- Do a loop using a cursor. 
BEGIN 
	DECLARE @intId INT
	DECLARE loopDataForReceiptHeader CURSOR LOCAL FAST_FORWARD 
	FOR 
	SELECT intId FROM @DataForReceiptHeader

	-- Open the cursor 
	OPEN loopDataForReceiptHeader;

	-- First data row fetch from the cursor 
	FETCH NEXT FROM loopDataForReceiptHeader INTO @intId;

	-- Begin Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		
		SET @receiptNumber = NULL 
		SET @inventoryReceiptId = NULL 
		SET @intLocationId = NULL 

		------------------------------------------
		----- Validate Receipt Header Fields -----
		------------------------------------------

		-- Validate Receipt Type --
		DECLARE @valueReceiptType NVARCHAR(50)

		SELECT @valueReceiptType = RawHeaderData.ReceiptType
		FROM @DataForReceiptHeader RawHeaderData
		WHERE RawHeaderData.intId = @intId

		IF RTRIM(LTRIM(LOWER(@valueReceiptType))) NOT IN ('direct', 'purchase contract', 'purchase order', 'transfer order')
			BEGIN
				--Receipt Type is invalid or missing.
				RAISERROR('Receipt Type is invalid or missing.', 11, 1);
				GOTO _Exit_With_Rollback;
			END
			
		-- Validate Vendor Id --
		DECLARE @valueEntityId INT

		IF EXISTS ( SELECT *
				    FROM @DataForReceiptHeader RawHeaderData
					WHERE RawHeaderData.intId = @intId AND RTRIM(LTRIM(LOWER(RawHeaderData.ReceiptType))) <> 'transfer order'
						  AND RawHeaderData.Vendor NOT IN (SELECT intEntityId FROM tblEMEntity)
				  )
			BEGIN
				-- Vendor Id is invalid or missing.
				RAISERROR('Vendor Id is invalid or missing.', 11, 1);
				GOTO _Exit_With_Rollback;
			END

		-- Validate Ship From Id --
		DECLARE @valueShipFromId INT

		IF EXISTS ( SELECT *
					FROM @DataForReceiptHeader RawHeaderData
					WHERE RawHeaderData.intId = @intId AND RTRIM(LTRIM(LOWER(RawHeaderData.ReceiptType))) <> 'transfer order'
					      AND RawHeaderData.ShipFrom NOT IN (SELECT intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = RawHeaderData.Vendor)
				  )
			BEGIN
				-- Ship From Id is invalid or missing.
				RAISERROR('Ship From Id is invalid or missing.', 11, 1);
				GOTO _Exit_With_Rollback;
			END

		-- Validate Location Id
		DECLARE @valueLocationId INT

		SELECT @valueLocationId = RawHeaderData.Location
		FROM @DataForReceiptHeader RawHeaderData
		WHERE RawHeaderData.intId = @intId
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE intCompanyLocationId = @valueLocationId)
			BEGIN
				-- Location Id is invalid or missing.
				RAISERROR('Location Id is invalid or missing.', 11, 1);
				GOTO _Exit_With_Rollback;
			END

		-- Validate Ship Via Id
		DECLARE @valueShipViaId INT

		SELECT @valueShipViaId = RawHeaderData.ShipVia
		FROM @DataForReceiptHeader RawHeaderData
		WHERE RawHeaderData.intId = @intId


		IF @valueShipViaId > 0 AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMShipVia WHERE [intEntityId] = @valueShipViaId)
			BEGIN
				DECLARE @valueShipViaIdStr NVARCHAR(50)
				SET @valueShipViaIdStr = CAST(@valueShipViaId AS NVARCHAR(50))
				-- Ship Via Id {Ship Via Id} is invalid.
				RAISERROR('Ship Via Id %s is invalid.', 11, 1, @valueShipViaIdStr);
				GOTO _Exit_With_Rollback;
			END

		-- Validate Currency Id
		--DECLARE @valueCurrencyId INT

		--SELECT @valueCurrencyId = RawHeaderData.Currency
		--FROM @DataForReceiptHeader RawHeaderData
		--WHERE RawHeaderData.intId = @intId

		--IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMCurrency WHERE intCurrencyID = @valueCurrencyId)
		--	BEGIN
		--		-- Currency Id is invalid or missing.
		--		RAISERROR(80113, 11, 1);
		--		GOTO _Exit_With_Rollback;
		--	END

		-- Validate Freight Term Id
		DECLARE @valueFreightTermId INT

		SELECT @valueFreightTermId = RawData.intFreightTermId
		FROM	@ReceiptEntries RawData
		WHERE RawData.intFreightTermId NOT IN (SELECT intFreightTermId FROM tblSMFreightTerms)

		IF @valueFreightTermId > 0
			BEGIN
				DECLARE @valueFreightTermIdStr NVARCHAR(50)
				SET @valueFreightTermIdStr = CAST(@valueFreightTermId AS NVARCHAR(50))
				-- Freight Term Id {Freight Term Id} is invalid.
				RAISERROR('Freight Term Id %s is invalid.', 11, 1, @valueFreightTermIdStr);
				GOTO _Exit_With_Rollback;
			END

		-- Validate Source Type Id
		DECLARE @valueSourceTypeId INT

		SELECT @valueSourceTypeId = RawHeaderData.intSourceType
		FROM @DataForReceiptHeader RawHeaderData
		WHERE RawHeaderData.intId = @intId

		IF @valueSourceTypeId IS NULL OR @valueSourceTypeId > 4 OR @valueSourceTypeId < 0
			BEGIN
				-- Source Type Id is invalid or missing.
				RAISERROR('Source Type Id is invalid or missing.', 11, 1);
				GOTO _Exit_With_Rollback;
			END

		-- Check if there is an existing Inventory receipt 
		SELECT	@inventoryReceiptId = RawData.intInventoryReceiptId
				,@strSourceScreenName = RawData.strSourceScreenName
				,@strSourceId = RawData.strSourceId
				,@intLocationId = RawData.intLocationId
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0)
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)	
		WHERE	RawHeaderData.intId = @intId

		-- Block overwrite of a posted inventory receipt record.
		IF EXISTS (SELECT 1 FROM dbo.tblICInventoryReceipt WHERE intInventoryReceiptId = @inventoryReceiptId AND ISNULL(ysnPosted, 0) = 1) 
		BEGIN 
			SELECT	@receiptNumber = strReceiptNumber
			FROM	dbo.tblICInventoryReceipt 
			WHERE	intInventoryReceiptId = @inventoryReceiptId

			-- 'Unable to update %s. It is posted. Please unpost it first.'
			RAISERROR('Unable to update %s. It is posted. Please unpost it first.', 11, 1, @receiptNumber);	
			GOTO _Exit_With_Rollback;
		END
				
		IF @inventoryReceiptId IS NULL 
		BEGIN 
			-- Generate the receipt starting number
			-- If @receiptNumber IS NULL, uspSMGetStartingNumber will throw an error. 
			-- Error is 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
			EXEC dbo.uspSMGetStartingNumber @startingNumberId_InventoryReceipt, @receiptNumber OUTPUT, @intLocationId
			IF @@ERROR <> 0 OR @receiptNumber IS NULL GOTO _BreakLoop;
		END 
		
		MERGE	
		INTO	dbo.tblICInventoryReceipt 
		WITH	(HOLDLOCK) 
		AS		Receipt 
		USING (
			SELECT	TOP 1 
					RawData.*
			FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData
						ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0)
						AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
						AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
						AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
						AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
						AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
						AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)	
			WHERE	RawHeaderData.intId = @intId
		) AS IntegrationData
			ON Receipt.intInventoryReceiptId = IntegrationData.intInventoryReceiptId

		WHEN MATCHED THEN 
			UPDATE
			SET 
				dtmReceiptDate			= dbo.fnRemoveTimeOnDate(ISNULL(IntegrationData.dtmDate, GETDATE()))
				,intEntityVendorId		= IntegrationData.intEntityVendorId
				,strReceiptType			= IntegrationData.strReceiptType
				,intSourceType          = IntegrationData.intSourceType
				,intBlanketRelease		= NULL
				,intLocationId			= IntegrationData.intLocationId
				,strVendorRefNo			= IntegrationData.strVendorRefNo
				,strBillOfLading		= IntegrationData.strBillOfLadding
				,intShipViaId			= IntegrationData.intShipViaId
				,intShipFromId			= IntegrationData.intShipFromId
				,intReceiverId			= @intUserId 
				,intCurrencyId			= ISNULL(IntegrationData.intCurrencyId, @intFunctionalCurrencyId)
				,intSubCurrencyCents	= IntegrationData.intSubCurrencyCents
				,strVessel				= NULL
				,intFreightTermId		= IntegrationData.intFreightTermId 
				,intShiftNumber			= NULL 
				,dblInvoiceAmount		= 0
				,ysnInvoicePaid			= 0 
				,intCheckNo				= NULL 
				,dtmCheckDate			= NULL 
				,intTrailerTypeId		= NULL 
				,dtmTrailerArrivalDate	= NULL 
				,dtmTrailerArrivalTime	= NULL 
				,strSealNo				= NULL 
				,strSealStatus			= NULL 
				,dtmReceiveTime			= NULL 
				,dblActualTempReading	= NULL 
				,intConcurrencyId		= 1
				,intEntityId			= (SELECT TOP 1 [intEntityId] FROM dbo.tblSMUserSecurity WHERE [intEntityId] = @intUserId)
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
				,strActualCostId		= IntegrationData.strActualCostId
				--,intTaxGroupId			= IntegrationData.intTaxGroupId
				,intTransferorId		= IntegrationData.intTransferorId 
		WHEN NOT MATCHED THEN 
			INSERT (
				strReceiptNumber
				,dtmReceiptDate
				,intEntityVendorId
				,strReceiptType
				,intSourceType
				,intBlanketRelease
				,intLocationId
				,strVendorRefNo
				,strBillOfLading
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,intSubCurrencyCents
				,strVessel
				,intFreightTermId
				,intShiftNumber
				,dblInvoiceAmount
				,ysnInvoicePaid
				,intCheckNo
				,dtmCheckDate
				,intTrailerTypeId
				,dtmTrailerArrivalDate
				,dtmTrailerArrivalTime
				,strSealNo
				,strSealStatus
				,dtmReceiveTime
				,dblActualTempReading
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
				,strActualCostId
				--,intTaxGroupId
				,intTransferorId
			)
			VALUES (
				/*strReceiptNumber*/			@receiptNumber
				/*dtmReceiptDate*/				,dbo.fnRemoveTimeOnDate(ISNULL(IntegrationData.dtmDate, GETDATE()))
				/*intEntityVendorId*/			,IntegrationData.intEntityVendorId
				/*strReceiptType*/				,IntegrationData.strReceiptType
				/*intSourceType*/				,IntegrationData.intSourceType
				/*intBlanketRelease*/			,NULL
				/*intLocationId*/				,IntegrationData.intLocationId
				/*strVendorRefNo*/				,IntegrationData.strVendorRefNo
				/*strBillOfLading*/				,IntegrationData.strBillOfLadding
				/*intShipViaId*/				,IntegrationData.intShipViaId
				/*intShipFromId*/				,IntegrationData.intShipFromId
				/*intReceiverId*/				,@intUserId 
				/*intCurrencyId*/				,ISNULL(IntegrationData.intCurrencyId, @intFunctionalCurrencyId) 
				/*intSubCurrencyCents*/			,IntegrationData.intSubCurrencyCents
				/*strVessel*/					,NULL
				/*intFreightTermId*/			,IntegrationData.intFreightTermId 
				/*intShiftNumber*/				,NULL 
				/*dblInvoiceAmount*/			,0
				/*ysnInvoicePaid*/				,0 
				/*intCheckNo*/					,NULL 
				/*dteCheckDate*/				,NULL 
				/*intTrailerTypeId*/			,NULL 
				/*dtmTrailerArrivalDate*/		,NULL 
				/*dtmTrailerArrivalTime*/		,NULL 
				/*strSealNo*/					,NULL 
				/*strSealStatus*/				,NULL 
				/*dtmReceiveTime*/				,NULL 
				/*dblActualTempReading*/		,NULL 
				/*intConcurrencyId*/			,1
				/*intEntityId*/					,(SELECT TOP 1 [intEntityId] FROM dbo.tblSMUserSecurity WHERE [intEntityId] = @intUserId)
				/*intCreatedUserId*/			,@intUserId
				/*ysnPosted*/					,0
				/*strActualCostId*/				,IntegrationData.strActualCostId
				/*intTaxGroupId*/				--,IntegrationData.intTaxGroupId
				/*intTransferorId*/				,IntegrationData.intTransferorId 
			)
		;
				
		-- Get the identity value from tblICInventoryReceipt to check if the insert was successful
		IF @inventoryReceiptId IS NULL 
		BEGIN 
			SELECT @inventoryReceiptId = SCOPE_IDENTITY()
		END 
						
		-- Validate the inventory receipt id
		IF @inventoryReceiptId IS NULL 
		BEGIN 
			-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
			RAISERROR('Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.', 11, 1);
			RETURN;
		END

		-----------------------------------------------
		----- Validate Receipt Item Detail Fields -----
		-----------------------------------------------

		-- Validate Item Id
		DECLARE @valueItemId INT = NULL

		SELECT TOP 1 
				@valueItemId = RawData.intItemId
		FROM	@ReceiptEntries RawData	LEFT JOIN tblICItem i
					ON i.intItemId = RawData.intItemId
		WHERE	i.intItemId IS NULL 

		IF @valueItemId IS NOT NULL 
		BEGIN
			DECLARE @valueItemIdStr NVARCHAR(50)
			SET @valueItemIdStr = CAST(@valueItemId AS NVARCHAR(50))

			-- Item Id {Item Id} invalid.
			RAISERROR('Item Id %s is invalid.', 11, 1, @valueItemIdStr);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Tax Group Id
		DECLARE @valueTaxGroupId INT = NULL

		SELECT TOP 1 
				@valueTaxGroupId = RawData.intTaxGroupId
		FROM	@ReceiptEntries RawData LEFT JOIN tblSMTaxGroup tg
					ON tg.intTaxGroupId = RawData.intTaxGroupId
		WHERE	tg.intTaxGroupId IS NULL 

		IF @valueTaxGroupId IS NOT NULL 
		BEGIN
			DECLARE @valueTaxGroupIdStr NVARCHAR(50)
			SET @valueTaxGroupIdStr = CAST(@valueTaxGroupId AS NVARCHAR(50))
			-- Tax Group Id {Tax Group Id} is invalid.
			RAISERROR('Tax Group Id %s is invalid.', 11, 1, @valueTaxGroupIdStr);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Contract Header Id
		DECLARE @valueContractHeaderId INT = NULL
		
		SELECT TOP 1 
				@valueContractHeaderId = RawData.intContractHeaderId
		FROM	@ReceiptEntries RawData LEFT JOIN tblCTContractHeader ch 
					ON ch.intContractHeaderId = RawData.intContractHeaderId
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) = 'purchase contract'
				AND ch.intContractHeaderId IS NULL 

		IF @valueContractHeaderId > 0
		BEGIN
			DECLARE @valueContractHeaderIdStr NVARCHAR(50)
			SET @valueContractHeaderIdStr = CAST(@valueContractHeaderId AS NVARCHAR(50))
			-- Contract Header Id {Contract Header Id} is invalid.
			RAISERROR('Contract Header Id %s is invalid.', 11, 1, @valueContractHeaderIdStr);
			GOTO _Exit_With_Rollback;
		END
			
		-- Validate Contract Detail Id
		SET @valueContractHeaderId = NULL

		SELECT	TOP 1 
				@valueContractHeaderId = RawData.intContractHeaderId
		FROM	@ReceiptEntries RawData	LEFT JOIN tblCTContractDetail cd 
					ON cd.intContractHeaderId = RawData.intContractHeaderId
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) = 'purchase contract'
				AND cd.intContractDetailId IS NULL 

		IF @valueContractHeaderId IS NOT NULL 
		BEGIN
			SET @valueContractHeaderIdStr =  CAST(@valueContractHeaderId AS NVARCHAR(50));
			-- Contract Detail Id is invalid or missing for Contract Header Id {Contract Header Id}.
			RAISERROR('Contract Detail Id is invalid or missing for Contract Header Id %s.', 11, 1, @valueContractHeaderIdStr);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Item UOM Id
		DECLARE @getItemId INT = NULL
				,@getItem NVARCHAR(50) = NULL

		SELECT TOP 1 
				@getItemId = RawData.intItemId
		FROM	@ReceiptEntries RawData LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intItemUOMId
		WHERE	iu.intItemUOMId IS NULL 

		IF @getItemId IS NOT NULL 
		BEGIN
			SELECT @getItem = strItemNo
			FROM tblICItem
			WHERE intItemId = @getItemId

			-- Item UOM Id is invalid or missing for lot {Item}.
			RAISERROR('Item UOM Id is invalid or missing for item %s.', 11, 1, @getItem);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Sub Location Id
		DECLARE @valueSubLocationId INT
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@valueSubLocationId = RawData.intSubLocationId
				,@getItemId = RawData.intItemId
		FROM	@ReceiptEntries	RawData LEFT JOIN tblSMCompanyLocationSubLocation sub 
					ON sub.intCompanyLocationSubLocationId = RawData.intSubLocationId
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) <> 'transfer order'
				AND sub.intCompanyLocationSubLocationId IS NULL 		
				AND RawData.intSubLocationId IS NOT NULL 		

		IF @valueSubLocationId IS NOT NULL 
		BEGIN
			SELECT	@getItem = strItemNo
			FROM	tblICItem
			WHERE	intItemId = @getItemId

			-- Sub Location is invalid or missing for item {Item}.
			RAISERROR('Storage Location is invalid or missing for item %s.', 11, 1,@getItem);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Storage Location Id
		DECLARE @valueStorageLocationId INT
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@valueStorageLocationId = RawData.intStorageLocationId
				, @getItemId = RawData.intItemId
		FROM	@ReceiptEntries RawData LEFT JOIN tblICStorageLocation storage 
					ON storage.intStorageLocationId = RawData.intStorageLocationId
		WHERE	storage.intStorageLocationId IS NULL 
				AND RawData.intStorageLocationId IS NOT NULL 

		IF @valueStorageLocationId IS NOT NULL 
		BEGIN
			SELECT @getItem = strItemNo
			FROM tblICItem
			WHERE intItemId = @getItemId

			-- Storage Location is invalid for item {Item}.
			RAISERROR('Storage Unit is invalid for item %s.', 11, 1, @getItem);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Gross/Net UOM Id
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@getItemId = RawData.intItemId
		FROM	@ReceiptEntries RawData LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intGrossNetUOMId
		WHERE	iu.intItemUOMId IS NULL 
				AND RawData.intGrossNetUOMId IS NOT NULL 

		IF @getItemId IS NOT NULL 
		BEGIN
			SELECT	@getItem = strItemNo
			FROM	tblICItem
			WHERE	intItemId = @getItemId

			-- Gross/Net UOM is invalid for item {Item}.
			RAISERROR('Gross/Net UOM is invalid for item %s.', 11, 1, @getItem);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Cost UOM Id
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@getItemId = RawData.intItemId
		FROM	@ReceiptEntries RawData LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intCostUOMId
		WHERE	iu.intItemUOMId IS NULL 
				AND RawData.intCostUOMId IS NOT NULL 

		IF @getItemId IS NOT NULL 
		BEGIN
			SELECT @getItem = strItemNo
			FROM tblICItem
			WHERE intItemId = @getItemId

			-- Cost UOM is invalid or missing for item {Item}.
			RAISERROR('Cost UOM is invalid or missing for item %s.', 11, 1, @getItem);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Lot Id
		DECLARE @valueLotId INT = NULL
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@valueLotId = RawData.intLotId
				, @getItemId = RawData.intItemId
		FROM	@ReceiptEntries RawData	LEFT JOIN tblICLot lot 
					ON lot.intLotId = RawData.intLotId
		WHERE	lot.intLotId IS NULL
				AND RawData.intLotId IS NOT NULL 

		IF @valueLotId IS NOT NULL 
		BEGIN
			SELECT @getItem = strItemNo
			FROM tblICItem
			WHERE intItemId = @getItemId

			DECLARE @valueLotIdStr NVARCHAR(50)
			SET @valueLotIdStr = CAST(@valueLotId AS NVARCHAR(50))
			-- Lot ID {Lot Id} is invalid for item {Item}.
			RAISERROR('Lot ID %s is invalid for item %s.', 11, 1, @valueLotIdStr, @getItem);
			GOTO _Exit_With_Rollback;
		END

		--  Flush out existing item and charges detail data for re-insertion
		BEGIN 
			DELETE FROM dbo.tblICInventoryReceiptCharge
			WHERE intInventoryReceiptId = @inventoryReceiptId

			DELETE FROM dbo.tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @inventoryReceiptId
		END

		-- Insert the Inventory Receipt Detail. 
		INSERT INTO dbo.tblICInventoryReceiptItem (
				intInventoryReceiptId
				,intLineNo
				,intOrderId
				,intSourceId
				,intItemId
				,intSubLocationId
				,intStorageLocationId
				,dblOrderQty
				,dblOpenReceive
				,dblReceived
				,intUnitMeasureId
				,intWeightUOMId
				,dblUnitCost
				--,dblLineTotal
				,intSort
				,intConcurrencyId
				,intOwnershipType
				,dblGross
				,dblNet
				,intCostUOMId
				,intDiscountSchedule
				,ysnSubCurrency
				,intTaxGroupId
				,intForexRateTypeId
				,dblForexRate 
				,intContainerId 
		)
		SELECT	intInventoryReceiptId	= @inventoryReceiptId
				,intLineNo				= ISNULL(RawData.intContractDetailId, 0)
				,intOrderId				= RawData.intContractHeaderId
				,intSourceId			= RawData.intSourceId
				,intItemId				= RawData.intItemId
				,intSubLocationId		= RawData.intSubLocationId
				,intStorageLocationId	= RawData.intStorageLocationId
				,dblOrderQty			= --ISNULL(RawData.dblQty, 0)
										(
											CASE	WHEN RawData.strReceiptType = 'Purchase Contract' THEN 
														CASE	WHEN RawData.intSourceType = 0 THEN -- None
																	CASE	WHEN (ContractView.ysnLoad = 1) THEN 
																				ISNULL(ContractView.intNoOfLoad, 0)
																			ELSE 
																				ISNULL(ContractView.dblDetailQuantity, 0) 
																	END
																WHEN RawData.intSourceType = 1 THEN -- Scale
																	0 
																WHEN RawData.intSourceType = 2 THEN -- Inbound Shipment
																	ISNULL(LogisticsView.dblQuantity, 0)
																WHEN RawData.intSourceType = 3 THEN -- Transport
																	ISNULL(TransportView.dblOrderedQuantity, 0) 
																ELSE 
																	NULL
														END
						
													WHEN RawData.strReceiptType = 'Purchase Order' THEN 
														ISNULL(POView.dblQtyOrdered, 0.00)
													WHEN RawData.strReceiptType = 'Transfer Order' THEN 
														ISNULL(TransferView.dblQuantity, 0.00)
													WHEN RawData.strReceiptType = 'Direct' THEN 
														0.00
													ELSE 0.00
											END
									)
				,dblOpenReceive			= ISNULL(RawData.dblQty, 0)
				,dblReceived			= ISNULL(RawData.dblQty, 0)
				,intUnitMeasureId		= ItemUOM.intItemUOMId
				,intWeightUOMId			= 
										CASE	WHEN RawData.intGrossNetUOMId < 1 OR RawData.intGrossNetUOMId IS NULL THEN NULL 
												WHEN GrossNetUnitMeasure.intUnitMeasureId IS NOT NULL THEN GrossNetUOM.intItemUOMId
												ELSE (
														SELECT	TOP 1 
																tblICItemUOM.intItemUOMId 
														FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
																	ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
														WHERE	tblICItemUOM.intItemId = RawData.intItemId 
																AND tblICItemUOM.ysnStockUnit = 1 
																AND tblICUnitMeasure.strUnitType IN ('Weight', 'Volume')
													)											
										END 
				
										
				,dblUnitCost			= RawData.dblCost
				--,dblLineTotal			= RawData.dblQty * RawData.dblCost
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType       = CASE	WHEN RawData.ysnIsStorage = 0 THEN @OWNERSHIP_TYPE_Own
												WHEN RawData.ysnIsStorage = 1 THEN @OWNERSHIP_TYPE_Storage
												ELSE @OWNERSHIP_TYPE_Own
										  END
				,dblGross				= --CASE WHEN RawData.intGrossNetUOMId < 1 OR RawData.intGrossNetUOMId IS NULL THEN NULL ELSE RawData.dblGross END
										  RawData.dblGross
				,dblNet					= --CASE WHEN RawData.intGrossNetUOMId < 1 OR RawData.intGrossNetUOMId IS NULL THEN NULL ELSE RawData.dblNet END
										  RawData.dblNet
				,intCostUOMId			= RawData.intCostUOMId
				,intDiscountSchedule	= RawData.intDiscountSchedule
				,ysnSubCurrency			= ISNULL(RawData.ysnSubCurrency, 0)
				,intTaxGroupId			= RawData.intTaxGroupId
				,intForexRateTypeId		= CASE WHEN RawData.intCurrencyId <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
				,dblForexRate			= CASE WHEN RawData.intCurrencyId <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.dblForexRate, forexRate.dblRate)  ELSE NULL END 
				,intContainerId			= RawData.intContainerId 

		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0) 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
				INNER JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intItemId  
					AND ItemUOM.intItemUOMId = RawData.intItemUOMId			
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
					ON GrossNetUOM.intItemUOMId = RawData.intGrossNetUOMId
                LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure    
                    ON GrossNetUOM.intUnitMeasureId = GrossNetUnitMeasure.intUnitMeasureId
                    AND GrossNetUnitMeasure.strUnitType IN ('Weight', 'Volume')
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = RawData.intItemId AND ItemLocation.intLocationId = RawData.intLocationId

				-- Get the SM forex rate. 
				OUTER APPLY dbo.fnSMGetForexRate(
					ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId)
					,CASE WHEN RawData.intCurrencyId <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
					,RawData.dtmDate
				) forexRate

				-- Integrations with the other modules: 
				-- 1. Purchase Order
				LEFT JOIN vyuPODetails POView
					ON POView.intPurchaseId = RawData.intContractHeaderId -- intOrderId
					AND intPurchaseDetailId = ISNULL(RawData.intContractDetailId, 0) -- intLineNo
					AND RawData.strReceiptType = 'Purchase Order'

				-- 2. Contracts
				LEFT JOIN vyuCTContractDetailView ContractView
					ON ContractView.intContractDetailId = ISNULL(RawData.intContractDetailId, 0) -- intLineNo
					AND RawData.strReceiptType = 'Purchase Contract'

				-- 3. Inventory Transfer
				LEFT JOIN vyuICGetInventoryTransferDetail TransferView
					ON TransferView.intInventoryTransferDetailId = ISNULL(RawData.intContractDetailId, 0) -- intLineNo
					AND RawData.strReceiptType = 'Transfer Order'

				-- 4. Logistics
				LEFT JOIN vyuICLoadContainerReceiptContracts LogisticsView
					ON LogisticsView.intLoadDetailId = RawData.intSourceId
					AND RawData.strReceiptType = 'Purchase Contract'
					AND RawData.intSourceType = 2

				-- 5. Transport Loads (New tables)
				LEFT JOIN vyuTRGetLoadReceipt TransportView 
					ON TransportView.intLoadReceiptId = RawData.intSourceId
					AND RawData.intSourceType = 3

		WHERE RawHeaderData.intId = @intId

		--------------------------------------------
		------ Validate Other Charges Fields -------
		--------------------------------------------
		DECLARE @valueChargeId INT = NULL
				,@valueCharge NVARCHAR (50) = NULL

		-- Validate Other Charge Entity Id
		SELECT TOP 1 @valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblEMEntity e 
					ON e.intEntityId = RawData.intEntityVendorId
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) <> 'transfer order'
				AND e.intEntityId IS NULL 
				AND RawData.intEntityVendorId IS NOT NULL 

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT	@valueCharge = strItemNo
			FROM	tblICItem
			WHERE	intItemId = @valueChargeId

			-- Entity Id is invalid or missing for other charge item {Other Charge Item No.}.
			RAISERROR('Entity Id is invalid or missing for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Other Charge Receipt Type --
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT TOP 1 @valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData
		WHERE	RawData.strReceiptType IS NULL OR (RTRIM(LTRIM(LOWER(RawData.strReceiptType))) NOT IN ('direct', 'purchase contract', 'purchase order', 'transfer order'))

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Receipt type is invalid or missing for other charge item {Other Charge Item No.}.
			RAISERROR('Receipt type is invalid or missing for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Other Charge Location Id
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT TOP 1 
				@valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblSMCompanyLocation loc 
					ON loc.intCompanyLocationId = RawData.intLocationId
		WHERE	loc.intCompanyLocationId IS NULL 
		
		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Location Id is invalid or missing for other charge item {Other Charge Item No.}.
			RAISERROR('Location Id is invalid or missing for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Other Charge Ship Via Id
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT TOP 1 @valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblSMShipVia shipVia 
					ON shipVia.[intEntityId] = RawData.intShipViaId
		WHERE	RawData.intShipViaId IS NOT NULL 
				AND shipVia.[intEntityId] IS NULL 

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Ship Via Id is invalid for other charge item {Other Charge Item No.}.
			RAISERROR('Ship Via Id is invalid for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Other Charge Ship From Id --
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT TOP 1 @valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblEMEntityLocation e 
					ON e.intEntityLocationId = RawData.intShipFromId				
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) <> 'transfer order'
				AND e.intEntityLocationId IS NULL 
				AND RawData.intShipFromId IS NOT NULL 				

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId
			-- Ship From Id is invalid or missing for other charge item {Other Charge Item No.}.
			RAISERROR('Ship From Id is invalid or missing for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Other Charge Currency Id
		--SET @valueChargeId = NULL
		--SET @valueCharge = NULL

		--SELECT TOP 1 @valueChargeId = RawData.intChargeId
		--FROM	@OtherCharges RawData LEFT JOIN tblSMCurrency currency 
		--			ON currency.intCurrencyID = RawData.intCurrencyId
		--WHERE	RawData.intCurrencyId IS NOT NULL 
		--		AND currency.intCurrencyID IS NULL 

		--IF @valueChargeId IS NOT NULL
		--BEGIN
		--	SELECT @valueCharge = strItemNo
		--	FROM tblICItem
		--	WHERE intItemId = @valueChargeId
		--	-- Currency Id is invalid for other charge item {Other Charge Item No.}.
		--	RAISERROR(80145, 11, 1, @valueCharge);
		--	GOTO _Exit_With_Rollback;
		--END

		-- Validate Other Charge Item Id
		IF EXISTS(
			SELECT	TOP 1 1
			FROM	@OtherCharges RawData  LEFT JOIN tblICItem charge 
						ON charge.strType = 'Other Charge' 
						AND charge.intItemId = RawData.intChargeId
			WHERE	RawData.intChargeId IS NULL 
					OR charge.intItemId IS NULL 
		)
		BEGIN
			-- Other Charge Item Id is invalid or missing.
			RAISERROR('Other Charge Item Id is invalid or missing.', 11, 1);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Cost Method
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT TOP 1 
				@valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData   
		WHERE	RawData.strCostMethod IS NULL OR RTRIM(LTRIM(LOWER(RawData.strCostMethod))) NOT IN ('per unit', 'percentage', 'amount')
		ORDER BY RawData.strCostMethod ASC

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Cost Method for Other Charge item {Other Charge Item No.} is invalid or missing.
			RAISERROR('Cost Method for Other Charge item %s is invalid or missing.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		---- Validate Cost Currency Id
		--DECLARE @valueCostCurrencyId INT
		--SET @valueChargeId = NULL
		--SET @valueCharge = NULL

		--SELECT	TOP 1 
		--		@valueCostCurrencyId = RawData.intCostCurrencyId
		--		,@valueChargeId = RawData.intChargeId
		--FROM	@OtherCharges RawData LEFT JOIN tblSMCurrency c 
		--			ON RawData.intCostCurrencyId = c.intCurrencyID
		--WHERE	c.intCurrencyID IS NULL 

		--IF @valueCostCurrencyId IS NOT NULL 
		--BEGIN
		--	SELECT @valueCharge = strItemNo
		--	FROM tblICItem
		--	WHERE intItemId = @valueChargeId

		--	DECLARE @valueCostCurrencyIdStr NVARCHAR(50)
		--	SET @valueCostCurrencyIdStr = CAST(@valueCostCurrencyId AS NVARCHAR(50))
		--	-- Cost Currency Id %s is invalid for other charge item %s.
		--	RAISERROR(80126, 11, 1, @valueCostCurrencyIdStr, @valueCharge);
		--	GOTO _Exit_With_Rollback;
		--END

		-- Validate Cost UOM Id
		-- Cost UOM Id is required if Cost Method is 'Per Unit'
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT	@valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblICItemUOM iu
					ON RawData.intCostUOMId = iu.intItemUOMId
		WHERE	iu.intItemUOMId IS NULL
				AND RTRIM(LTRIM(LOWER(RawData.strCostMethod))) = 'per unit'

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Cost UOM is invalid or missing for item {Charge Item No.}.
			RAISERROR('Cost UOM is invalid or missing for item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Other Charges Vendor Id
		DECLARE @valueOtherChargeVendorId INT
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT	TOP 1
				@valueOtherChargeVendorId = RawData.intOtherChargeEntityVendorId
				, @valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblEMEntity e
					ON RawData.intOtherChargeEntityVendorId = e.intEntityId
		WHERE	e.intEntityId IS NULL 
				AND RawData.intOtherChargeEntityVendorId IS NOT NULL 

		IF @valueOtherChargeVendorId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Vendor Id is invalid for other charge item {Other Charge Item No.}.
			RAISERROR('Vendor Id is invalid for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Allocate Cost By
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT	@valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData
		WHERE	RawData.strAllocateCostBy IS NOT NULL 
				AND RTRIM(LTRIM(LOWER(RawData.strAllocateCostBy))) NOT IN ('unit', 'stock unit', 'cost')

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Allocate Cost By is invalid or missing for other charge item {Other Charge Item No.}.
			RAISERROR('Allocate Cost By is invalid or missing for other charge item %s.', 11, 1, @valueCharge);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Contract Header Id
		DECLARE @valueOtherChargeContractHeaderId INT = NULL

		SELECT	TOP 1 
				@valueOtherChargeContractHeaderId = RawData.intContractHeaderId
		FROM	@OtherCharges RawData LEFT JOIN tblCTContractHeader ch
					ON RawData.intContractHeaderId = ch.intContractHeaderId
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) = 'purchase contract'
				AND ch.intContractHeaderId IS NULL 

		IF @valueOtherChargeContractHeaderId IS NOT NULL
		BEGIN
			DECLARE @valueOtherChargeContractHeaderIdStr AS NVARCHAR(50)
			SET @valueOtherChargeContractHeaderIdStr = CAST(@valueOtherChargeContractHeaderId AS NVARCHAR(50))
			-- Contract Header Id {Contract Header Id} is invalid.
			RAISERROR('Contract Header Id %s is invalid.', 11, 1, @valueOtherChargeContractHeaderIdStr);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Contract Detail Id
		SET @valueOtherChargeContractHeaderId = NULL

		SELECT TOP 1 
				@valueOtherChargeContractHeaderId = RawData.intContractHeaderId
		FROM	@OtherCharges RawData LEFT JOIN tblCTContractDetail cd
					ON RawData.intContractDetailId = cd.intContractDetailId
					AND RawData.intContractHeaderId = cd.intContractHeaderId
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) = 'purchase contract'
				AND cd.intContractDetailId IS NULL 				

		IF @valueOtherChargeContractHeaderId IS NOT NULL 
		BEGIN
			SET @valueOtherChargeContractHeaderIdStr = CAST(@valueOtherChargeContractHeaderId AS NVARCHAR(50))
			-- Contract Detail Id is invalid or missing for Contract Header Id {Contract Header Id}.
			RAISERROR('Contract Detail Id is invalid or missing for Contract Header Id %s.', 11, 1, @valueOtherChargeContractHeaderIdStr);
			GOTO _Exit_With_Rollback;
		END

		-- Validate Tax Group Id
		DECLARE @valueOtherChargeTaxGroupId INT = NULL

		SELECT	TOP 1 
				@valueOtherChargeTaxGroupId = RawData.intTaxGroupId	
		FROM	@OtherCharges RawData LEFT JOIN tblSMTaxGroup tg
					ON RawData.intTaxGroupId = tg.intTaxGroupId
		WHERE	RawData.intTaxGroupId IS NOT NULL 
				AND tg.intTaxGroupId IS NULL 
		
		IF @valueOtherChargeTaxGroupId IS NOT NULL
		BEGIN
			DECLARE @valueOtherChargeTaxGroupIdStr NVARCHAR(50)
			SET @valueOtherChargeTaxGroupIdStr = CAST(@valueOtherChargeTaxGroupId AS NVARCHAR(50))
			-- Tax Group Id {Tax Group Id} is invalid.
			RAISERROR('Tax Group Id %s is invalid.', 11, 1, @valueOtherChargeTaxGroupIdStr);
			GOTO _Exit_With_Rollback;
		END

		-- Insert the Other Charges
		INSERT INTO dbo.tblICInventoryReceiptCharge (
				[intInventoryReceiptId]
				,[intContractId]
				,[intContractDetailId]
				,[intChargeId]
				,[ysnInventoryCost]
				,[strCostMethod]
				,[dblRate]
				,[intCostUOMId]
				,[intEntityVendorId]
				,[dblAmount]
				,[strAllocateCostBy]
				,[ysnAccrue]
				,[ysnPrice]
				,[ysnSubCurrency]
				,[intCurrencyId]
				,[intCent]
				,[intTaxGroupId]
				,[intForexRateTypeId]
				,[dblForexRate]
		)
		SELECT 
				[intInventoryReceiptId]		= @inventoryReceiptId
				,[intContractId]			= RawData.intContractHeaderId
				,[intContractDetailId]		= RawData.intContractDetailId
				,[intChargeId]				= RawData.intChargeId
				,[ysnInventoryCost]			= RawData.ysnInventoryCost
				,[strCostMethod]			= RawData.strCostMethod
				,[dblRate]					= RawData.dblRate
				,[intCostUOMId]				= RawData.intCostUOMId
				,[intEntityVendorId]		= RawData.intOtherChargeEntityVendorId
				,[dblAmount]				= RawData.dblAmount
				,[strAllocateCostBy]		= RawData.strAllocateCostBy
				,[ysnAccrue]				= RawData.ysnAccrue
				,[ysnPrice]					= RawData.ysnPrice
				,[ysnSubCurrency]			= ISNULL(RawData.ysnSubCurrency, 0) 
				,[intCurrencyId]			= COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) 
				,[intCent]					= CostCurrency.intCent
				,[intTaxGroupId]			= RawData.intTaxGroupId
				,[intForexRateTypeId]		= CASE WHEN COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
				,[dblForexRate]				= CASE WHEN COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.dblForexRate, forexRate.dblRate) ELSE NULL END 

		FROM	@OtherCharges RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0)
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)

				INNER JOIN tblICInventoryReceipt r
					ON r.intInventoryReceiptId = @inventoryReceiptId

				LEFT JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intChargeId  
					AND ItemUOM.intItemUOMId = RawData.intCostUOMId
				LEFT JOIN dbo.tblSMCurrency CostCurrency
					ON CostCurrency.intCurrencyID = RawData.intCostCurrencyId

				-- Get the SM forex rate. 
				OUTER APPLY dbo.fnSMGetForexRate(
					COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) 
					,CASE WHEN COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
					,r.dtmReceiptDate
				) forexRate

		WHERE RawHeaderData.intId = @intId

		-- Add taxes into the receipt. 
		BEGIN
			DECLARE	@ItemId				INT
					,@LocationId		INT
					,@TransactionDate	DATETIME
					,@TransactionType	NVARCHAR(20) = 'Purchase'
					,@EntityId			INT	
					,@TaxMasterId		INT	
					,@InventoryReceiptItemId INT
					,@ShipFromId		INT 
					,@TaxGroupId		INT
					,@FreightTermId		INT

			DECLARE @Taxes AS TABLE (
				--id						INT
				--,intInvoiceDetailId		INT
				intTransactionDetailTaxId	INT
				,intTransactionDetailId	INT
				,intTaxGroupId			INT 
				,intTaxCodeId			INT
				,intTaxClassId			INT
				,strTaxableByOtherTaxes NVARCHAR (MAX) 
				,strCalculationMethod	NVARCHAR(50)
				,dblRate				NUMERIC(18,6)
				,dblTax					NUMERIC(18,6)
				,dblAdjustedTax			NUMERIC(18,6)
				,intTaxAccountId		INT
				,ysnSeparateOnInvoice	BIT
				,ysnCheckoffTax			BIT
				,strTaxCode				NVARCHAR(50)
				,ysnTaxExempt			BIT
				,[ysnInvalidSetup]		BIT
				,[strTaxGroup]			NVARCHAR(100)
				,[strNotes]				NVARCHAR(500)
			)

			-- Create the cursor
			DECLARE loopReceiptItems CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  ReceiptItem.intItemId
					,Receipt.intLocationId
					,Receipt.dtmReceiptDate
					,Receipt.intEntityVendorId
					,ReceiptItem.intInventoryReceiptItemId
					,Receipt.intShipFromId
					,ReceiptItem.intTaxGroupId
					,Receipt.intFreightTermId 
			FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
						ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId

			OPEN loopReceiptItems;

			-- Initial fetch attempt
			FETCH NEXT FROM loopReceiptItems INTO 
				@ItemId
				,@LocationId
				,@TransactionDate
				,@EntityId
				,@InventoryReceiptItemId
				,@ShipFromId
				,@TaxGroupId
				,@FreightTermId

			WHILE @@FETCH_STATUS = 0
			BEGIN 
				-- Clear the contents of the table variable.
				DELETE FROM @Taxes

				-- Get the taxes from uspSMGetItemTaxes
				INSERT INTO @Taxes (
					--id
					--,intInvoiceDetailId
					intTransactionDetailTaxId
					,intTransactionDetailId
					,intTaxGroupId
					,intTaxCodeId
					,intTaxClassId
					,strTaxableByOtherTaxes
					,strCalculationMethod
					,dblRate
					,dblTax
					,dblAdjustedTax
					,intTaxAccountId
					,ysnSeparateOnInvoice
					,ysnCheckoffTax
					,strTaxCode
					,ysnTaxExempt
					,[ysnInvalidSetup]
					,[strTaxGroup]
					,[strNotes]
				)
				EXEC dbo.uspSMGetItemTaxes
					 @ItemId				= @ItemId
					,@LocationId			= @LocationId
					,@TransactionDate		= @TransactionDate
					,@TransactionType		= @TransactionType
					,@EntityId				= @EntityId
					,@TaxGroupId			= @TaxGroupId
					,@BillShipToLocationId	= @ShipFromId
					,@IncludeExemptedCodes	= NULL
					,@SiteId				= NULL
					,@FreightTermId			= @FreightTermId


				DECLARE	@Amount	NUMERIC(38,20) 
						,@Qty	NUMERIC(38,20)
				-- Fields used in the calculation of the taxes

				SELECT TOP 1
				 -- Use 1 to compute Line Total and Taxes based on Quantity, 2 to compute based on Net, and null to compute based on default setup (If Gross/Net UOM is available, compute based on Net, else based on Quantity)
					 @Amount = CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
										 dbo.fnMultiply(
											 dbo.fnDivide(
												 ISNULL(dblUnitCost, 0) 
												 ,ISNULL(Receipt.intSubCurrencyCents, 1) 
											 )
											 ,dbo.fnDivide(
												  GrossNetUOM.dblUnitQty
												  ,CostUOM.dblUnitQty 
											 )
										 )
									ELSE 
										 dbo.fnMultiply(
											 dbo.fnDivide(
												 ISNULL(dblUnitCost, 0) 
												 ,ISNULL(Receipt.intSubCurrencyCents, 1) 
											 )
											 ,dbo.fnDivide(
												  ReceiveUOM.dblUnitQty
												  ,CostUOM.dblUnitQty 
											 )
										)																	
								END 
					,@Qty	 = CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
										ReceiptItem.dblNet 
									ELSE 
										ReceiptItem.dblOpenReceive 
								END 

				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
						--INNER JOIN dbo.tblICInventoryReceiptItemTax ItemTax
						--	ON ItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
						LEFT JOIN dbo.tblICItemUOM ReceiveUOM 
							ON ReceiveUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
						LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
							ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM CostUOM
							ON CostUOM.intItemUOMId = ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId) 	
				WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId
						AND ReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId

				-- Compute Taxes
				-- Insert the data from the table variable into Inventory Receipt Item tax table. 
				INSERT INTO dbo.tblICInventoryReceiptItemTax (
					[intInventoryReceiptItemId]
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[dblRate]
					,[dblTax]
					,[dblAdjustedTax]
					,[intTaxAccountId]
					,[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[strTaxCode]
					,[intSort]
					,[intConcurrencyId]				
				)
				SELECT 	[intInventoryReceiptItemId]		= @InventoryReceiptItemId
						,[intTaxGroupId]				= [intTaxGroupId]
						,[intTaxCodeId]					= [intTaxCodeId]
						,[intTaxClassId]				= [intTaxClassId]
						,[strTaxableByOtherTaxes]		= [strTaxableByOtherTaxes]
						,[strCalculationMethod]			= [strCalculationMethod]
						,[dblRate]						= [dblRate]
						,[dblTax]						= [dblTax]
						,[dblAdjustedTax]				= [dblAdjustedTax]
						,[intTaxAccountId]				= [intTaxAccountId]
						,[ysnTaxAdjusted]				= [ysnTaxAdjusted]
						,[ysnSeparateOnInvoice]			= [ysnSeparateOnInvoice]
						,[ysnCheckoffTax]				= [ysnCheckoffTax]
						,[strTaxCode]					= [strTaxCode]
						,[intSort]						= 1
						,[intConcurrencyId]				= 1
				FROM	[dbo].[fnGetItemTaxComputationForVendor](@ItemId, @EntityId, @TransactionDate, @Amount, @Qty, @TaxGroupId, @LocationId, @ShipFromId, 0, @FreightTermId,0)

			-- Removed this part as taxes are already computed in fnGetItemTaxComputationForVendor
			  /*	--Compute the tax
				BEGIN 
					-- Clear the temp table 
					DELETE FROM #tmpComputeItemTaxes

					-- Insert data to the temp table in order to process the taxes. 
					INSERT INTO #tmpComputeItemTaxes (
						-- Integration fields. Foreign keys. 
						intHeaderId
						,intDetailId
						,intTaxDetailId
						,dtmDate
						,intItemId

						-- Taxes fields
						,intTaxGroupId
						,intTaxCodeId
						,intTaxClassId
						,strTaxableByOtherTaxes
						,strCalculationMethod
						,dblRate
						,dblTax
						,dblAdjustedTax
						,ysnCheckoffTax

						-- Fields used in the calculation of the taxes
						,dblAmount
						,dblQty
					)
					SELECT 
						-- Integration fields. Foreign keys. 
						intHeaderId					= Receipt.intInventoryReceiptId
						,intDetailId				= ReceiptItem.intInventoryReceiptItemId
						,intTaxDetailId				= ItemTax.intInventoryReceiptItemTaxId
						,dtmDate					= Receipt.dtmReceiptDate
						,intItemId					= ReceiptItem.intItemId

						-- Taxes fields
						,intTaxGroupId				= Receipt.intTaxGroupId
						,intTaxCodeId				= ItemTax.intTaxCodeId
						,intTaxClassId				= ItemTax.intTaxClassId
						,strTaxableByOtherTaxes		= ItemTax.strTaxableByOtherTaxes
						,strCalculationMethod		= ItemTax.strCalculationMethod
						,dblRate					= ItemTax.dblRate
						,dblTax						= ItemTax.dblTax
						,dblAdjustedTax				= ItemTax.dblAdjustedTax
						,ysnCheckoffTax				= ItemTax.ysnCheckoffTax

						-- Fields used in the calculation of the taxes
						,dblAmount					=	-- ReceiptItem.dblUnitCost
														CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
																	dbo.fnMultiply(
																		dbo.fnDivide(
																			ISNULL(dblUnitCost, 0) 
																			,ISNULL(Receipt.intSubCurrencyCents, 1) 
																		)
																		,dbo.fnDivide(
																			GrossNetUOM.dblUnitQty
																			,CostUOM.dblUnitQty 
																		)
																	)
																ELSE 
																	dbo.fnMultiply(
																		dbo.fnDivide(
																			ISNULL(dblUnitCost, 0) 
																			,ISNULL(Receipt.intSubCurrencyCents, 1) 
																		)
																		,dbo.fnDivide(
																			ReceiveUOM.dblUnitQty
																			,CostUOM.dblUnitQty 
																		)
																	)																	
														END 

						,dblQty						=	CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
																	ReceiptItem.dblNet 
																ELSE 
																	ReceiptItem.dblOpenReceive 
														END 

					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
							INNER JOIN dbo.tblICInventoryReceiptItemTax ItemTax
								ON ItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							LEFT JOIN dbo.tblICItemUOM ReceiveUOM 
								ON ReceiveUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
							LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
								ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
							LEFT JOIN dbo.tblICItemUOM CostUOM
								ON CostUOM.intItemUOMId = ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId) 					

					WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId
							AND ReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId
					
					-- Call the SM stored procedure to compute the tax. 
					EXEC dbo.[uspSMComputeItemTaxes]

					-- Get the computed tax. 
					UPDATE	ItemTax
					SET		dblTax = ComputedTax.dblTax
					FROM	dbo.tblICInventoryReceiptItemTax ItemTax INNER JOIN #tmpComputeItemTaxes ComputedTax
								ON ItemTax.intInventoryReceiptItemId = ComputedTax.intDetailId
								AND ItemTax.intInventoryReceiptItemTaxId = ComputedTax.intTaxDetailId
				END */
									
				-- Get the next item. 
				FETCH NEXT FROM loopReceiptItems INTO 
					@ItemId
					,@LocationId
					,@TransactionDate
					,@EntityId
					,@InventoryReceiptItemId
					,@ShipFromId
					,@TaxGroupId
					,@FreightTermId
			END 

			CLOSE loopReceiptItems;
			DEALLOCATE loopReceiptItems;
		END 
		
		-- Add lot/s to receipt item if @LotEntries contains a value
		IF EXISTS (SELECT TOP 1 1 FROM @LotEntries)

		BEGIN
			DECLARE @intCountItems INT
					,@counterItem INT = 0
					,@currentReceiptItemId INT
					,@prevReceiptItemId INT = NULL

			SELECT @intCountItems=COUNT(ReceiptItem.intInventoryReceiptItemId)
			FROM tblICInventoryReceipt Receipt
			INNER JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
			WHERE Receipt.intInventoryReceiptId = @inventoryReceiptId

			WHILE @counterItem < @intCountItems
				BEGIN
					-- Get intInventoryReceiptItemId
					IF @prevReceiptItemId IS NOT NULL
						BEGIN
							SELECT TOP 1 @currentReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							FROM tblICInventoryReceipt Receipt
							INNER JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							WHERE Receipt.intInventoryReceiptId = @inventoryReceiptId AND ReceiptItem.intInventoryReceiptItemId > @prevReceiptItemId
							ORDER BY ReceiptItem.intInventoryReceiptItemId ASC
						END
					ELSE
						BEGIN
							SELECT TOP 1 @currentReceiptItemId = ReceiptItem.intInventoryReceiptItemId
							FROM tblICInventoryReceipt Receipt
							INNER JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
							WHERE Receipt.intInventoryReceiptId = @inventoryReceiptId AND ReceiptItem.intInventoryReceiptItemId IS NOT NULL
						END

					
					-- Check if item is lot-tracked
					IF EXISTS (SELECT * 
							   FROM tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
							   WHERE ReceiptItem.intInventoryReceiptItemId = @currentReceiptItemId AND Item.strLotTracking <> 'No')
					BEGIN

						------------------------------------------------
						------- Validate Receipt Item Lot fields -------
						------------------------------------------------
						DECLARE @valueLotRecordId INT = NULL
								,@valueLotRecordNo NVARCHAR(50) = NULL

						-- Validate Lot Entity Id
						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intEntityVendorId IS NULL OR ItemLot.intEntityVendorId NOT IN (SELECT intEntityId FROM tblEMEntity)

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Entity Id is invalid or missing for lot {Lot Number}.
								RAISERROR('Entity Id is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Receipt Type --
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.strReceiptType IS NULL OR (RTRIM(LTRIM(LOWER(ItemLot.strReceiptType))) NOT IN ('direct', 'purchase contract', 'purchase order', 'transfer order'))

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Receipt type is invalid or missing for lot {Lot Number}.
								RAISERROR('Receipt type is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Location Id
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intLocationId IS NULL OR ItemLot.intLocationId NOT IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation)
		
						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Location Id is invalid or missing for lot {Lot Number}.
								RAISERROR('Location Id is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Ship Via Id
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intShipViaId > 0 AND ItemLot.intShipViaId NOT IN (SELECT [intEntityId] FROM tblSMShipVia)

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Ship Via Id is invalid for lot {Lot Number}.
								RAISERROR('Ship Via Id is invalid for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Ship From Id --
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intShipFromId IS NULL OR ItemLot.intShipFromId NOT IN (SELECT intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = ItemLot.intEntityVendorId)

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Ship From Id is invalid or missing for lot {Lot Number}.
								RAISERROR('Ship From Id is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						---- Validate Lot Currency Id
						--SET @valueLotRecordNo = NULL

						--SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						--FROM @LotEntries ItemLot
						--WHERE ItemLot.intCurrencyId IS NULL OR ItemLot.intCurrencyId NOT IN (SELECT intCurrencyID FROM tblSMCurrency)

						--IF @valueLotRecordNo IS NOT NULL
						--	BEGIN
						--		-- Currency Id is invalid or missing for lot {Lot Number}.
						--		RAISERROR(80151, 11, 1, @valueLotRecordNo);
						--		GOTO _Exit_With_Rollback;
						--	END

						-- Validate Lot Source Type Id
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intSourceType IS NULL OR ItemLot.intSourceType > 4 OR ItemLot.intSourceType < 0

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Source Type Id is invalid or missing for lot {Lot Number}.
								RAISERROR('Source Type Id is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Item Id
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot	   
						WHERE ItemLot.intItemId IS NULL OR ItemLot.intItemId NOT IN (SELECT intItemId FROM tblICItem)

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Item Id is invalid or missing for lot {Lot Number}.
								RAISERROR('Item Id is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Sub Location Id
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot	   	   
						WHERE ItemLot.intSubLocationId IS NULL OR ItemLot.intSubLocationId NOT IN (SELECT intCompanyLocationSubLocationId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationId = ItemLot.intLocationId)

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Sub Location is invalid or missing for {Lot Number}.
								RAISERROR('Storage Location is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Storage Location Id
						SET @valueLotRecordNo = NULL

						SELECT @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot   
						WHERE ItemLot.intStorageLocationId IS NULL OR ItemLot.intStorageLocationId NOT IN (SELECT intStorageLocationId FROM tblICStorageLocation WHERE intLocationId = ItemLot.intLocationId AND intSubLocationId = ItemLot.intSubLocationId)
								 
						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- 'Storage Location is invalid or missing for lot {Lot Number}.
								RAISERROR('Storage Unit is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Id
						DECLARE @valueLotRecordLotId INT = NULL
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordLotId = ItemLot.intLotId, @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intLotId NOT IN (SELECT intLotId FROM tblICLot WHERE intItemId = ItemLot.intItemId)
						ORDER BY ItemLot.intLotId ASC

						IF @valueLotRecordLotId > 0
							BEGIN
								DECLARE @valueLotRecordLotIdStr NVARCHAR(50)
								SET @valueLotRecordLotIdStr = CAST(@valueLotRecordLotId AS NVARCHAR(50))
								-- Lot ID {Lot Id} is invalid for lot {Lot Number}.
								RAISERROR('Lot ID %s is invalid for lot %s.', 11, 1, @valueLotRecordLotIdStr, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Lot Number
						DECLARE @valueLotRecordLotNo NVARCHAR(50) = NULL
								,@valueLotRecordItemId INT = NULL
								,@valueLotRecordItemNo NVARCHAR(50) = NULL

						SELECT TOP 1 @valueLotRecordItemId = ItemLot.intItemId
						FROM @LotEntries ItemLot
						WHERE ItemLot.strLotNumber IS NULL 
								OR (ItemLot.intLotId > 0 AND ItemLot.strLotNumber NOT IN (SELECT strLotNumber FROM tblICLot WHERE intLotId = ItemLot.intLotId))
						ORDER BY ItemLot.strLotNumber ASC

						IF @valueLotRecordItemId > 0
							BEGIN
								SELECT @valueLotRecordItemNo = strItemNo
								FROM tblICItem
								WHERE intItemId = @valueLotRecordItemId

								-- Lot Number is invalid or missing for item {ItemNo.}.
								RAISERROR('Lot Number is invalid or missing for item %s.', 11, 1, @valueLotRecordItemNo);
								GOTO _Exit_With_Rollback;
							END

							-- Validate Lot Item UOM Id
							SET @valueLotRecordNo = NULL
								 
							SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
							FROM @LotEntries ItemLot
							WHERE ItemLot.intItemUnitMeasureId IS NULL OR
									ItemLot.intItemUnitMeasureId NOT IN (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = ItemLot.intItemId)
							ORDER BY ItemLot.intItemUnitMeasureId ASC

							IF @valueLotRecordNo IS NOT NULL
								BEGIN
									-- Item UOM Id is invalid or missing for lot {Lot Number}.
									RAISERROR('Item UOM Id is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
									GOTO _Exit_With_Rollback;
								END

						-- Validate Lot Condition
						DECLARE @valueLotRecordLotCondition NVARCHAR(50) = NULL
							SET @valueLotRecordNo = NULL

							SELECT TOP 1 @valueLotRecordLotCondition = ItemLot.strCondition, @valueLotRecordNo = ItemLot.strLotNumber
							FROM @LotEntries ItemLot
							WHERE ItemLot.strCondition IS NOT NULL 
									AND RTRIM(LTRIM(LOWER(ItemLot.strCondition))) NOT IN ('sound/full', 'slack', 'damaged', 'clean wgt')
							ORDER BY ItemLot.strCondition ASC

							IF @valueLotRecordLotCondition IS NOT NULL
								BEGIN
									-- Lot Condition {Lot Condition} is invalid for lot {Lot Number}.
									RAISERROR('Lot Condition %s is invalid for lot %s.', 11, 1, @valueLotRecordLotCondition, @valueLotRecordNo);
									GOTO _Exit_With_Rollback;
								END

						-- Validate Parent Lot Id
						DECLARE @valueLotRecordParentLotId INT = NULL
								,@valueLotRecordParentLotIdStr NVARCHAR(50)
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordParentLotId = ItemLot.intParentLotId, @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intParentLotId NOT IN (SELECT intParentLotId FROM tblICLot WHERE intItemId = ItemLot.intItemId AND intLotId = ItemLot.intLotId)
						ORDER BY ItemLot.intParentLotId ASC

						IF @valueLotRecordParentLotId > 0
							BEGIN
								SET @valueLotRecordParentLotIdStr = CAST(@valueLotRecordParentLotId AS NVARCHAR(50))
								-- Parent Lot Id {Parent Lot Id} is invalid for lot {Lot Number}.
								RAISERROR('Parent Lot Id %s is invalid for lot %s.', 11, 1, @valueLotRecordParentLotIdStr, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Validate Parent Lot Number
						DECLARE @valueLotRecordParentLotNo NVARCHAR(50) = NULL
						SET @valueLotRecordNo = NULL

						SELECT TOP 1 @valueLotRecordNo = ItemLot.strLotNumber
						FROM @LotEntries ItemLot
						WHERE ItemLot.intParentLotId > 0
								AND (ItemLot.strParentLotNumber IS NULL OR
								(ItemLot.strParentLotNumber NOT IN (SELECT strParentLotNumber FROM tblICParentLot WHERE intItemId = ItemLot.intItemId AND intParentLotId = ItemLot.intParentLotId)))
						ORDER BY ItemLot.strParentLotNumber ASC

						IF @valueLotRecordNo IS NOT NULL
							BEGIN
								-- Parent Lot Number is invalid or missing for lot {Lot Number}.
								RAISERROR('Parent Lot Number is invalid or missing for lot %s.', 11, 1, @valueLotRecordNo);
								GOTO _Exit_With_Rollback;
							END

						-- Insert Lot for Receipt Item
						INSERT INTO dbo.tblICInventoryReceiptItemLot (
							[intInventoryReceiptItemId]		
							,[intLotId]
							,[strLotNumber]
							,[strLotAlias]
							,[intSubLocationId]
							,[intStorageLocationId]
							,[intItemUnitMeasureId]
							,[dblQuantity]
							,[dblGrossWeight]
							,[dblTareWeight]
							,[dblCost]
							,[intNoPallet]
							,[intUnitPallet]
							,[dblStatedGrossPerUnit]
							,[dblStatedTarePerUnit]
							,[strContainerNo]
							,[intEntityVendorId]
							,[strGarden]
							,[strMarkings]
							,[intOriginId]
							,[intGradeId]
							,[intSeasonCropYear]
							,[strVendorLotId]
							,[dtmManufacturedDate]
							,[strRemarks]
							,[strCondition]
							,[dtmCertified]
							,[dtmExpiryDate]
							,[intParentLotId]
							,[strParentLotNumber]
							,[strParentLotAlias]
							,[intSort]
							,[intConcurrencyId]
						)
						SELECT
							[intInventoryReceiptItemId]	= @currentReceiptItemId
							,[intLotId] = ItemLot.intLotId
							,[strLotNumber] = ItemLot.strLotNumber
							,[strLotAlias] = ItemLot.strLotAlias
							,[intSubLocationId] = ItemLot.intSubLocationId
							,[intStorageLocationId] = ItemLot.intStorageLocationId
							,[intItemUnitMeasureId] = ItemLot.intItemUnitMeasureId
							,[dblQuantity] = ItemLot.dblQuantity
							,[dblGrossWeight] = ItemLot.dblGrossWeight
							,[dblTareWeight] = ItemLot.dblTareWeight
							,[dblCost] = ItemLot.dblCost
							,[intNoPallet] = ItemLot.intNoPallet
							,[intUnitPallet] = ItemLot.intUnitPallet
							,[dblStatedGrossPerUnit] = ItemLot.dblStatedGrossPerUnit
							,[dblStatedTarePerUnit] = ItemLot.dblStatedTarePerUnit
							,[strContainerNo] = ItemLot.strContainerNo
							,[intEntityVendorId] = ItemLot.intEntityVendorId
							,[strGarden] = ItemLot.strGarden
							,[strMarkings] = ItemLot.strMarkings
							,[intOriginId] = ItemLot.intOriginId
							,[intGradeId] = ItemLot.intGradeId
							,[intSeasonCropYear] = ItemLot.intSeasonCropYear
							,[strVendorLotId] = ItemLot.strVendorLotId
							,[dtmManufacturedDate] = ItemLot.dtmManufacturedDate
							,[strRemarks] = ItemLot.strRemarks
							,[strCondition] = ItemLot.strCondition
							,[dtmCertified] = ItemLot.dtmCertified
							,[dtmExpiryDate] = ItemLot.dtmExpiryDate
							,[intParentLotId] = ItemLot.intParentLotId
							,[strParentLotNumber] = ItemLot.strParentLotNumber
							,[strParentLotAlias] = ItemLot.strParentLotAlias
							,[intSort] = 1
							,[intConcurrencyId] = 1
						FROM @LotEntries ItemLot INNER JOIN @DataForReceiptHeader RawHeaderData
							ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(ItemLot.intEntityVendorId, 0)
							AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(ItemLot.strReceiptType,0)
							AND ISNULL(RawHeaderData.Location,0) = ISNULL(ItemLot.intLocationId,0)
							AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(ItemLot.intShipViaId,0)		   
							AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(ItemLot.intShipFromId,0)
							AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(ItemLot.intCurrencyId, @intFunctionalCurrencyId)
							AND ISNULL(RawHeaderData.intSourceType,0) = ISNULL(ItemLot.intSourceType, 0)
							AND RawHeaderData.BillOfLadding = ItemLot.strBillOfLadding 
						LEFT JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
							ON ReceiptItem.intItemId = ItemLot.intItemId
							AND ReceiptItem.intSubLocationId = ItemLot.intSubLocationId
							AND ReceiptItem.intStorageLocationId = ItemLot.intStorageLocationId
						WHERE ReceiptItem.intInventoryReceiptItemId = @currentReceiptItemId
					END

					SET @prevReceiptItemId = @currentReceiptItemId
					SET @counterItem = @counterItem + 1
				END
		END

		-- Calculate the tax per line item 
		UPDATE	ReceiptItem 
		SET		dblTax = ROUND(
					dbo.fnDivide(
						ISNULL(Taxes.dblTaxPerLineItem, 0)
						,ISNULL(Receipt.intSubCurrencyCents, 1) 
					)
				, 2) 

		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
						ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN (
					SELECT	dblTaxPerLineItem = SUM(ReceiptItemTax.dblTax) 
							,ReceiptItemTax.intInventoryReceiptItemId
					FROM	dbo.tblICInventoryReceiptItemTax ReceiptItemTax INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON ReceiptItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
					WHERE	ReceiptItem.intInventoryReceiptId = @inventoryReceiptId
					GROUP BY ReceiptItemTax.intInventoryReceiptItemId
				) Taxes
					ON ReceiptItem.intInventoryReceiptItemId = Taxes.intInventoryReceiptItemId
		WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId

		-- Re-update the line total 
		UPDATE	ReceiptItem 
		SET		dblLineTotal = 
					ROUND(
						--ISNULL(dblTax, 0) + 
						CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
									dbo.fnMultiply(
										ISNULL(ReceiptItem.dblNet, 0)
										,dbo.fnMultiply(
											dbo.fnDivide(
												ISNULL(dblUnitCost, 0) 
												,ISNULL(Receipt.intSubCurrencyCents, 1) 
											)
											,dbo.fnDivide(
												GrossNetUOM.dblUnitQty
												,CostUOM.dblUnitQty 
											)
										)
									)								 
								ELSE 
									dbo.fnMultiply(
										ISNULL(ReceiptItem.dblOpenReceive, 0)
										,dbo.fnMultiply(
											dbo.fnDivide(
												ISNULL(dblUnitCost, 0) 
												,ISNULL(Receipt.intSubCurrencyCents, 1) 
											)
											,dbo.fnDivide(
												ReceiveUOM.dblUnitQty
												,CostUOM.dblUnitQty 
											)
										)
									)
						END 
						, 2
					) 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN dbo.tblICItemUOM ReceiveUOM 
					ON ReceiveUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
					ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
				LEFT JOIN dbo.tblICItemUOM CostUOM
					ON CostUOM.intItemUOMId = ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId) 								
		WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId

		-- Re-update the total cost 
		UPDATE	Receipt
		SET		dblInvoiceAmount = Detail.dblTotal
		FROM	dbo.tblICInventoryReceipt Receipt LEFT JOIN (
					SELECT	dblTotal = SUM(dblLineTotal) 
							,intInventoryReceiptId
					FROM	dbo.tblICInventoryReceiptItem 
					WHERE	intInventoryReceiptId = @inventoryReceiptId
					GROUP BY intInventoryReceiptId
				) Detail
					ON Receipt.intInventoryReceiptId = Detail.intInventoryReceiptId
		WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId

		-- Update Cost UOM Id if null
		UPDATE tblICInventoryReceiptItem
		SET intCostUOMId = intUnitMeasureId
		WHERE dblUnitCost > 0 AND intCostUOMId IS NULL

		-- Calculate the other charges
		BEGIN 			
			-- Calculate the other charges. 
			EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
				@inventoryReceiptId			

			-- Calculate the surcharges
			EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
				@inventoryReceiptId
			
			-- Allocate the other charges and surcharges. 
			EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
				@inventoryReceiptId		
				
			-- Calculate Other Charges Taxes
			EXEC dbo.uspICCalculateInventoryReceiptOtherChargesTaxes
				@inventoryReceiptId
		END 

		-- Log successful inserts. 
		INSERT INTO #tmpAddItemReceiptResult (
			intSourceId
			,intInventoryReceiptId
		)
		SELECT	ReceiptItem.intSourceId
				,Receipt.intInventoryReceiptId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId
		
		-- Create an Audit Log
		BEGIN 
			DECLARE @strDescription AS NVARCHAR(100) = @strSourceScreenName + ' to Inventory Receipt'
			
			SELECT	@strReceiptNumber = strReceiptNumber
			FROM	dbo.tblICInventoryReceipt 
			WHERE	intInventoryReceiptId = @inventoryReceiptId
			
			EXEC	dbo.uspSMAuditLog 
					@keyValue = @inventoryReceiptId							-- Primary Key Value of the Inventory Receipt. 
					,@screenName = 'Inventory.view.InventoryReceipt'        -- Screen Namespace
					,@entityId = @intEntityId                               -- Entity Id.
					,@actionType = 'Processed'                              -- Action Type
					,@changeDescription = @strDescription					-- Description
					,@fromValue = @strSourceId                              -- Previous Value
					,@toValue = @strReceiptNumber                           -- New Value
		END

		-- Fetch the next row from cursor. 
		FETCH NEXT FROM loopDataForReceiptHeader INTO @intId;
	END
	-- End of the loop

	_BreakLoop:

	CLOSE loopDataForReceiptHeader;
	DEALLOCATE loopDataForReceiptHeader;	
END

IF @@TRANCOUNT > 0
BEGIN 
	COMMIT TRAN @TransactionName
	GOTO _Exit
END 

_Exit_With_Rollback:
IF @@TRANCOUNT > 0 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
END

_Exit: