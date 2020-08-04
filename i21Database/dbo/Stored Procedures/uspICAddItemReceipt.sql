/*

Important Notes:

Accepted values for ReceiptStagingTable.intGrossNetUOMId:
	1. -1 (or any negative value) means NULL gross/net uom
	2. NULL means it will use the stock uom of the item as the gross/net uom
	3. or provide a [valid gross/net uom id]
	4. If you provided an invalid gross/net uom id, it will use the stock unit of the item. 

Accepted values for ReceiptStagingTable.intTaxGroupId and ReceiptOtherChargesTableType.intTaxGroupId
	1. -1 (or any negative value) means a NULL tax group. 
	2. NULL means it will get the tax group from the tax group hierarchy (fnGetTaxGroupIdForVendor) 
	3. or provide a valid tax group. 

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

DECLARE @intEntityId AS INT
DECLARE @startingNumberId_InventoryReceipt AS INT = 23;
DECLARE @receiptNumber AS NVARCHAR(50);

DECLARE @inventoryReceiptId AS INT
		,@strSourceId AS NVARCHAR(50)
		,@strSourceScreenName AS NVARCHAR(50)
		,@strReceiptNumber AS NVARCHAR(50)
		,@intLocationId AS INT 


DECLARE @SourceType_NONE AS INT = 0
		,@SourceType_SCALE AS INT = 1
		,@SourceType_INBOUND_SHIPMENT AS INT = 2
		,@SourceType_TRANSPORT AS INT = 3
		,@SourceType_SETTLE_STORAGE AS INT = 4
		,@SourceType_DELIVERY_SHEET AS INT = 5
		,@SourceType_PURCHASE_ORDER AS INT = 6
		,@SourceType_STORE AS INT = 7

DECLARE @STATUS_OPEN AS TINYINT = 1
		,@STATUS_IN_TRANSIT AS TINYINT = 2
		,@STATUS_CLOSED AS TINYINT = 3
		,@STATUS_SHORT_CLOSED AS TINYINT = 4 

DECLARE @PricingType_Basis AS INT = 2
		,@PricingType_DP_PricedLater AS INT = 5

-- Get the entity id
SELECT	@intEntityId = [intEntityId]
FROM	dbo.tblSMUserSecurity 
WHERE	[intEntityId] = @intUserId


-- Validate the user id. 
IF @intEntityId IS NULL 
BEGIN 
	-- 'Receiver id is invalid. It must be a User type Entity.'
	EXEC uspICRaiseError 80180;
	GOTO _Exit;
END 

-- Check if Bundle
DECLARE @intItemId INT;
SET @intItemId = NULL;

SELECT TOP 1 @intItemId = i.intItemId
FROM @ReceiptEntries r
	INNER JOIN tblICItem i ON i.intItemId = r.intItemId
WHERE i.strBundleType IS NOT NULL

IF @intItemId IS NOT NULL
BEGIN
	EXEC uspICRaiseError 80203, 'Inventory Receipt';
	GOTO _Exit;
END

BEGIN 
	DECLARE @TransactionName AS VARCHAR(500) = 'uspICAddItemReceipt_' + CAST(NEWID() AS NVARCHAR(100));
	BEGIN TRAN @TransactionName
	SAVE TRAN @TransactionName
END

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
	,[Location] INT
	,ShipVia INT
	,ShipFromEntity INT NULL 
	,ShipFrom INT
	,Currency INT
	,intSourceType INT
	,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strVendorRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	--,intTaxGroupId INT
)

-- Sort the data from @ReceiptEntries and determine which ones are the header records. 
INSERT INTO @DataForReceiptHeader(
		Vendor
		,BillOfLadding
		,ReceiptType
		,[Location]
		,ShipVia
		,ShipFromEntity
		,ShipFrom
		,Currency
		,intSourceType
		,strVendorRefNo
		--,intTaxGroupId
)
SELECT	RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromEntityId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
		,RawData.strVendorRefNo
FROM	@ReceiptEntries RawData
GROUP BY RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromEntityId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
		,RawData.strVendorRefNo
;

-- Validate if there is data to process. If there is no data, then raise an error. 
IF NOT EXISTS (SELECT TOP 1 1 FROM @DataForReceiptHeader)
BEGIN 
	-- 'Data not found. Unable to create the Inventory Receipt.'
	EXEC uspICRaiseError 80055;
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
				EXEC uspICRaiseError 80134;
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
				EXEC uspICRaiseError 80135;
				GOTO _Exit_With_Rollback;
			END

		-- Validate Ship From Id --
		DECLARE @valueShipFromId INT

		IF EXISTS ( 
			--SELECT *
			--FROM @DataForReceiptHeader RawHeaderData
			--WHERE 
			--	RawHeaderData.intId = @intId 
			--	AND RTRIM(LTRIM(LOWER(RawHeaderData.ReceiptType))) <> 'transfer order'
			--	AND RawHeaderData.ShipFrom NOT IN (
			--		SELECT intEntityLocationId 
			--		FROM tblEMEntityLocation 
			--		WHERE intEntityId = RawHeaderData.Vendor
			--	)

			SELECT TOP 1 *
			FROM 
				@DataForReceiptHeader RawHeaderData
				OUTER APPLY (
					SELECT TOP 1 intEntityLocationId
					FROM 
						tblEMEntityLocation entityLocation
					WHERE	
						entityLocation.intEntityLocationId = RawHeaderData.ShipFrom
						AND entityLocation.intEntityId = ISNULL(RawHeaderData.ShipFromEntity, RawHeaderData.Vendor)						
				) shipFrom
			WHERE
				RawHeaderData.intId = @intId 
				AND RTRIM(LTRIM(LOWER(RawHeaderData.ReceiptType))) <> 'transfer order'
				AND shipFrom.intEntityLocationId IS NULL 
		)
		BEGIN
			-- Ship From Id is invalid or missing.
			EXEC uspICRaiseError 80136;
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
				EXEC uspICRaiseError 80137;
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
				EXEC uspICRaiseError 80138, @valueShipViaIdStr;
				GOTO _Exit_With_Rollback;
			END

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
				EXEC uspICRaiseError 80114, @valueFreightTermIdStr
				GOTO _Exit_With_Rollback;
			END

		-- Validate Source Type Id
		DECLARE @valueSourceTypeId INT

		SELECT @valueSourceTypeId = RawHeaderData.intSourceType
		FROM @DataForReceiptHeader RawHeaderData
		WHERE RawHeaderData.intId = @intId

		IF @valueSourceTypeId IS NULL OR @valueSourceTypeId	NOT IN (
			@SourceType_NONE 
			,@SourceType_SCALE 
			,@SourceType_INBOUND_SHIPMENT 
			,@SourceType_TRANSPORT 
			,@SourceType_SETTLE_STORAGE 
			,@SourceType_DELIVERY_SHEET 
			,@SourceType_PURCHASE_ORDER 
			,@SourceType_STORE 
		)
			BEGIN
				-- Source Type Id is invalid or missing.
				EXEC uspICRaiseError 80115; 
				GOTO _Exit_With_Rollback;
			END

		-- Check if there is an existing Inventory receipt 
		SELECT	TOP 1
				@inventoryReceiptId = RawData.intInventoryReceiptId
				,@strSourceScreenName = RawData.strSourceScreenName
				,@strSourceId = RawData.strSourceId
				,@intLocationId = RawData.intLocationId
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0)
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)
					AND ISNULL(RawHeaderData.strVendorRefNo,0) = ISNULL(RawData.strVendorRefNo,0)
		WHERE	RawHeaderData.intId = @intId
		ORDER BY RawData.intInventoryReceiptId DESC

		-- Block overwrite of a posted inventory receipt record.
		IF EXISTS (SELECT 1 FROM dbo.tblICInventoryReceipt WHERE intInventoryReceiptId = @inventoryReceiptId AND ISNULL(ysnPosted, 0) = 1) 
		BEGIN 
			SELECT	@receiptNumber = strReceiptNumber
			FROM	dbo.tblICInventoryReceipt 
			WHERE	intInventoryReceiptId = @inventoryReceiptId

			-- 'Unable to update %s. It is posted. Please unpost it first.'
			EXEC uspICRaiseError 80077, @receiptNumber;
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

		-- Validate the Book Id
		BEGIN 
			DECLARE @valueBookId INT

			SELECT	TOP 1 
					@valueBookId = RawData.intBookId
			FROM	@ReceiptEntries RawData LEFT JOIN tblCTBook book
						ON RawData.intBookId = book.intBookId 
			WHERE	RawData.intBookId IS NOT NULL 
					AND book.intBookId IS NULL 

			IF @valueBookId IS NOT NULL 
			BEGIN
				-- 'Book id is invalid or missing. Please create or fix it at Contract Management -> Books.'
				EXEC uspICRaiseError 80212
				GOTO _Exit_With_Rollback;
			END
		END 
		
		-- Validate the Sub Book Id
		BEGIN 
			DECLARE @valueSubBookId INT

			SELECT	TOP 1 
					@valueSubBookId = RawData.intSubBookId
			FROM	@ReceiptEntries RawData LEFT JOIN tblCTSubBook subBook
						ON RawData.intSubBookId = subBook.intSubBookId 
			WHERE	RawData.intSubBookId IS NOT NULL 
					AND subBook.intSubBookId IS NULL 

			IF @valueSubBookId IS NOT NULL 
			BEGIN
				-- 'Sub Book id is invalid or missing. Please create or fix it at Contract Management -> Books.'
				EXEC uspICRaiseError 80213
				GOTO _Exit_With_Rollback;
			END
		END 

		-- Validate the Sub Book Id against its parent book. 
		BEGIN 
			DECLARE @valueSubBookId2 INT
					,@strBook NVARCHAR(50)
					,@strSubBook NVARCHAR(50)

			SELECT	TOP 1 
					@valueSubBookId2 = RawData.intSubBookId
					,@strBook = book.strBook
					,@strSubBook = subBook.strSubBook
			FROM	@ReceiptEntries RawData LEFT JOIN tblCTSubBook subBook
						ON RawData.intSubBookId = subBook.intSubBookId 
					LEFT JOIN tblCTBook book 
						ON book.intBookId = subBook.intBookId 
			WHERE	RawData.intSubBookId IS NOT NULL 
					AND ISNULL(RawData.intBookId, 0) <> ISNULL(book.intBookId, 0) 

			IF @valueSubBookId2 IS NOT NULL 
			BEGIN
				-- '{Sub Book} is not a sub book of {Book}. You can correct it at Contract Management -> Books.'
				EXEC uspICRaiseError 80214, @strSubBook, @strBook 
				GOTO _Exit_With_Rollback;
			END
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
						AND ISNULL(RawHeaderData.[Location],0) = ISNULL(RawData.intLocationId,0)
						AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
						AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
						AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)
						AND ISNULL(RawHeaderData.strVendorRefNo,0) = ISNULL(RawData.strVendorRefNo,0)	
						AND ISNULL(RawHeaderData.ShipFromEntity,0) = ISNULL(RawData.intShipFromEntityId,0)	

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
				,intBookId				= IntegrationData.intBookId
				,intSubBookId			= IntegrationData.intSubBookId
				,dtmDateModified		= GETDATE()
				,intModifiedByUserId 	= @intUserId
				,strDataSource			= IntegrationData.strReceiptType
				,intShipFromEntityId	= ISNULL(IntegrationData.intShipFromEntityId, IntegrationData.intEntityVendorId)
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
				,intBookId
				,intSubBookId
				,dtmDateCreated
				,intCreatedByUserId
				,strDataSource
				,intShipFromEntityId
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
				/*intBookId*/					,IntegrationData.intBookId
				/*intSubBookId*/				,IntegrationData.intSubBookId 
				,GETDATE()
				,@intUserId
				/*strDataSource*/				,IntegrationData.strReceiptType
				/*intShipFromEntityId*/			,ISNULL(IntegrationData.intShipFromEntityId, IntegrationData.intEntityVendorId)
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
			EXEC uspICRaiseError 80004; 
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
			EXEC uspICRaiseError 80117, @valueItemIdStr;
			GOTO _Exit_With_Rollback;
		END

		-- Validate Tax Group Id
		DECLARE @valueTaxGroupId INT = NULL

		SELECT TOP 1 
				@valueTaxGroupId = RawData.intTaxGroupId
		FROM	@ReceiptEntries RawData LEFT JOIN tblSMTaxGroup tg
					ON tg.intTaxGroupId = RawData.intTaxGroupId
		WHERE	tg.intTaxGroupId IS NULL 
				AND RawData.intTaxGroupId IS NOT NULL 
				AND RawData.intTaxGroupId > 0 

		IF @valueTaxGroupId IS NOT NULL 
		BEGIN
			DECLARE @valueTaxGroupIdStr NVARCHAR(50)
			SET @valueTaxGroupIdStr = CAST(@valueTaxGroupId AS NVARCHAR(50))
			-- Tax Group Id {Tax Group Id} is invalid.
			EXEC uspICRaiseError 80116, @valueTaxGroupIdStr;
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
			EXEC uspICRaiseError 80118, @valueContractHeaderIdStr;
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
			EXEC uspICRaiseError 80119, @valueContractHeaderIdStr;
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
			EXEC uspICRaiseError 80120, @getItem;
			GOTO _Exit_With_Rollback;
		END

		-- Validate Sub Location Id
		DECLARE @valueSubLocationId INT
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@valueSubLocationId = RawData.intSubLocationId
				,@getItem = i.strItemNo
		FROM	@ReceiptEntries	RawData LEFT JOIN tblICItem i 
					ON RawData.intItemId = i.intItemId		
				LEFT JOIN tblSMCompanyLocationSubLocation sub 
					ON sub.intCompanyLocationSubLocationId = RawData.intSubLocationId
					AND sub.intCompanyLocationId = RawData.intLocationId 
		WHERE	RTRIM(LTRIM(LOWER(RawData.strReceiptType))) <> 'transfer order'
				AND sub.intCompanyLocationSubLocationId IS NULL 		
				AND RawData.intSubLocationId IS NOT NULL 		

		IF @valueSubLocationId IS NOT NULL 
		BEGIN
			EXEC uspICRaiseError 80098, @getItem
			GOTO _Exit_With_Rollback;
		END

		-- Validate Storage Location Id
		DECLARE @valueStorageLocationId INT
		SET @getItemId = NULL
		SET @getItem = NULL

		SELECT TOP 1 
				@valueStorageLocationId = RawData.intStorageLocationId
				, @getItem = i.strItemNo 
		FROM	@ReceiptEntries RawData LEFT JOIN tblICItem i 
					ON RawData.intItemId = i.intItemId
				LEFT JOIN tblICStorageLocation storage 
					ON storage.intStorageLocationId = RawData.intStorageLocationId
					AND storage.intSubLocationId = RawData.intSubLocationId -- Sub-location for the storage location must match too. 
		WHERE	storage.intStorageLocationId IS NULL 
				AND RawData.intStorageLocationId IS NOT NULL 

		IF @valueStorageLocationId IS NOT NULL 
		BEGIN
			-- Storage Unit is invalid or missing for item {Item}.
			EXEC uspICRaiseError 80098, @getItem
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
				AND RawData.intGrossNetUOMId > 0 

		IF @getItemId IS NOT NULL 
		BEGIN
			SELECT	@getItem = strItemNo
			FROM	tblICItem
			WHERE	intItemId = @getItemId

			-- Gross/Net UOM is invalid for item {Item}.
			EXEC uspICRaiseError 80121, @getItem;
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
			EXEC uspICRaiseError 80122, @getItem;
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
			EXEC uspICRaiseError 80123, @valueLotIdStr, @getItem;
			GOTO _Exit_With_Rollback;
		END

		--  Flush out existing item and charges detail data for re-insertion
		BEGIN 
			DELETE FROM dbo.tblICInventoryReceiptCharge
			WHERE intInventoryReceiptId = @inventoryReceiptId

			DELETE FROM dbo.tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @inventoryReceiptId
		END

		IF EXISTS(SELECT TOP 1 1 FROM @ReceiptEntries re INNER JOIN tblICItem i ON i.intItemId = re.intItemId AND i.strType NOT IN ('Inventory', 'Raw Material', 'Finished Good', 'Non-Inventory'))
		BEGIN
			EXEC uspICRaiseError 80230;
			GOTO _Exit_With_Rollback;
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
				,strChargesLink
				,intLoadReceive
				,intCostingMethod
				,intTicketId
				,intInventoryTransferId
				,intInventoryTransferDetailId
				,intPurchaseId
				,intPurchaseDetailId
				,intContractHeaderId
				,intContractDetailId
				,dblUnitRetail
				,ysnAllowVoucher
				,dtmDateCreated
				,intCreatedByUserId
				,strActualCostId
				,intLoadShipmentId
				,intLoadShipmentDetailId
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
														CASE	WHEN RawData.intSourceType = 0 OR RawData.intSourceType = 1 OR RawData.intSourceType = 6 THEN -- None
																	CASE	WHEN (ContractView.ysnLoad = 1) THEN 
																				ISNULL(ContractView.intNoOfLoad, 0)
																			ELSE 
																				ISNULL(ContractView.dblDetailQuantity, 0) 
																	END
																--WHEN RawData.intSourceType = 1 THEN -- Scale
																--	0 
																WHEN RawData.intSourceType = 2 THEN -- Inbound Shipment
																	ISNULL(LogisticsView.dblQuantity, 0)
																WHEN RawData.intSourceType = 3 THEN -- Transport
																	ISNULL(TransportView.dblOrderedQuantity, 0) 
																WHEN RawData.intSourceType = 5 THEN -- Delivery Sheet
																	0
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
										CASE	
											WHEN RawData.intGrossNetUOMId < 1 OR RawData.intGrossNetUOMId IS NULL THEN NULL 
											ELSE dbo.fnGetMatchingItemUOMIdByTypes(RawData.intItemId, 
												COALESCE(GrossNetUOM.intItemUOMId, RawData.intGrossNetUOMId, defaultGrossNetUOM.intItemUOMId)
												, 'Weight,Volume')
										END 
										
				,dblUnitCost			= RawData.dblCost
				--,dblLineTotal			= RawData.dblQty * RawData.dblCost
				,intSort				= ISNULL(RawData.intSort, 1)
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
				,intTaxGroupId			= 
										CASE 
											WHEN ContractView.intPricingTypeId IN (@PricingType_Basis, @PricingType_DP_PricedLater) THEN NULL 
											WHEN RawData.intTaxGroupId < 0 THEN NULL 
											WHEN RawData.strReceiptType = 'Transfer Order' THEN NULL 
											ELSE ISNULL(RawData.intTaxGroupId, taxHierarcy.intTaxGroupId) 
										END
				,intForexRateTypeId		= CASE WHEN RawData.intCurrencyId <> @intFunctionalCurrencyId THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
				,dblForexRate			= CASE WHEN RawData.intCurrencyId <> @intFunctionalCurrencyId THEN ISNULL(RawData.dblForexRate, forexRate.dblRate)  ELSE NULL END 
				,intContainerId			= RawData.intContainerId 
				,strChargesLink			= RawData.strChargesLink
				,intLoadReceive			= RawData.intLoadReceive
				,intCostingMethod		= 
										CASE 
											WHEN ISNULL(Item.strLotTracking, 'No') <> 'No' THEN 
												4 -- 4 is for Lot Costing
											ELSE
												ItemLocation.intCostingMethod
										END
				,intTicketId					= RawData.intTicketId
				,intInventoryTransferId			= RawData.intInventoryTransferId
				,intInventoryTransferDetailId	= RawData.intInventoryTransferDetailId
				,intPurchaseId					= RawData.intPurchaseId
				,intPurchaseDetailId			= RawData.intPurchaseDetailId
				,intContractHeaderId			= RawData.intContractHeaderId
				,intContractDetailId			= RawData.intContractDetailId
				,dblUnitRetail					= RawData.dblUnitRetail 
				,ysnAllowVoucher				= RawData.ysnAllowVoucher
				,dtmDateCreated = GETDATE()
				,intCreatedByUserId = @intUserId
				,strActualCostId				= RawData.strActualCostId
				,RawData.intLoadShipmentId
				,RawData.intLoadShipmentDetailId
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0) 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
					AND ISNULL(RawHeaderData.strVendorRefNo,0) = ISNULL(RawData.strVendorRefNo,0)
					--AND ISNULL(RawHeaderData.ShipFromEntity,0) = ISNULL(RawData.intShipFromEntityId,0)	
				INNER JOIN tblICItem Item
					ON Item.intItemId = RawData.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intItemId  
					AND ItemUOM.intItemUOMId = RawData.intItemUOMId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
					ON GrossNetUOM.intItemUOMId = RawData.intGrossNetUOMId
					AND GrossNetUOM.intItemId = RawData.intItemId
                LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure    
                    ON GrossNetUOM.intUnitMeasureId = GrossNetUnitMeasure.intUnitMeasureId
                    AND GrossNetUnitMeasure.strUnitType IN ('Weight', 'Volume')
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = RawData.intItemId 
					AND ItemLocation.intLocationId = RawData.intLocationId
				OUTER APPLY (
					SELECT	TOP 1 
							tblICItemUOM.intItemUOMId 
					FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
								ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
					WHERE	tblICItemUOM.intItemId = RawData.intItemId 
							AND tblICItemUOM.ysnStockUnit = 1 
							AND tblICUnitMeasure.strUnitType IN ('Weight', 'Volume')
				) defaultGrossNetUOM
				LEFT JOIN tblICCostingMethod CostingMethod
					ON CostingMethod.intCostingMethodId = ItemLocation.intCostingMethod
				-- Get the SM forex rate. 
				OUTER APPLY dbo.fnSMGetForexRate(
					ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId)
					,CASE WHEN RawData.intCurrencyId <> @intFunctionalCurrencyId THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
					,RawData.dtmDate
				) forexRate

				-- Get the default tax group (if override was not provided)
				OUTER APPLY (
					SELECT	taxGroup.intTaxGroupId, taxGroup.strTaxGroup
					FROM	tblSMTaxGroup taxGroup
					WHERE	taxGroup.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor (
								RawData.intEntityVendorId	-- @VendorId
								,RawData.intLocationId		--,@CompanyLocationId
								,NULL						--,@ItemId
								,RawData.intShipFromId		--,@VendorLocationId
								,RawData.intFreightTermId	--,@FreightTermId
							)
							AND RawData.intTaxGroupId IS NULL
				) taxHierarcy 

				-- Integrations with the other modules: 
				-- 1. Purchase Order
				LEFT JOIN vyuPODetails POView
					ON POView.intPurchaseId = RawData.intContractHeaderId -- intOrderId
					AND POView.intPurchaseDetailId = ISNULL(RawData.intContractDetailId, 0) -- intLineNo
					AND RawData.strReceiptType = 'Purchase Order'

				-- 2. Contracts
				LEFT JOIN vyuCTCompactContractDetailView ContractView
					ON ContractView.intContractDetailId = ISNULL(RawData.intContractDetailId, 0) -- intLineNo
					AND RawData.strReceiptType = 'Purchase Contract'

				-- 3. Inventory Transfer
				LEFT JOIN vyuICGetInventoryTransferDetail TransferView
					ON TransferView.intInventoryTransferDetailId = ISNULL(RawData.intContractDetailId, 0) -- intLineNo
					AND RawData.strReceiptType = 'Transfer Order'

				-- 4. Logistics
				LEFT JOIN vyuLGLoadContainerLookup LogisticsView --vyuICLoadContainerReceiptContracts LogisticsView
					ON LogisticsView.intLoadDetailId = RawData.intSourceId
					AND RawData.strReceiptType = 'Purchase Contract'
					AND RawData.intSourceType = 2
					AND RawData.intContainerId = LogisticsView.intLoadContainerId

				-- 5. Transport Loads (New tables)
				LEFT JOIN vyuTRGetLoadReceipt TransportView 
					ON TransportView.intLoadReceiptId = RawData.intSourceId
					AND RawData.intSourceType = 3

		WHERE RawHeaderData.intId = @intId
		ORDER BY RawData.intSort, RawData.intId

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
			EXEC uspICRaiseError 80140, @valueCharge;
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
			EXEC uspICRaiseError 80141, @valueCharge;
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
			EXEC uspICRaiseError 80142, @valueCharge;
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
			EXEC uspICRaiseError 80143, @valueCharge
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
			EXEC uspICRaiseError 80144, @valueCharge
			GOTO _Exit_With_Rollback;
		END

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
			EXEC uspICRaiseError 80124; 
			GOTO _Exit_With_Rollback;
		END

		-- Validate Cost Method
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT TOP 1 
				@valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData   
		WHERE	RawData.strCostMethod IS NULL OR RTRIM(LTRIM(LOWER(RawData.strCostMethod))) NOT IN ('per unit', 'percentage', 'amount', 'gross unit')
		ORDER BY RawData.strCostMethod ASC

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Cost Method for Other Charge item {Other Charge Item No.} is invalid or missing.
			EXEC uspICRaiseError 80125, @valueCharge;
			GOTO _Exit_With_Rollback;
		END

		-- Validate Cost UOM Id
		-- Cost UOM Id is required if Cost Method is 'Per Unit'.
		-- Cost UOM Id is required if Cost Method is 'Gross Unit'.
		SET @valueChargeId = NULL
		SET @valueCharge = NULL

		SELECT	@valueChargeId = RawData.intChargeId
		FROM	@OtherCharges RawData LEFT JOIN tblICItemUOM iu
					ON RawData.intCostUOMId = iu.intItemUOMId
		WHERE	iu.intItemUOMId IS NULL
				AND RTRIM(LTRIM(LOWER(RawData.strCostMethod))) IN ('per unit', 'gross unit')

		IF @valueChargeId IS NOT NULL
		BEGIN
			SELECT @valueCharge = strItemNo
			FROM tblICItem
			WHERE intItemId = @valueChargeId

			-- Cost UOM is invalid or missing for item {Charge Item No.}.
			EXEC uspICRaiseError 80122, @valueCharge;
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
			EXEC uspICRaiseError 80127, @valueCharge;
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
			EXEC uspICRaiseError 80128, @valueCharge;
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
			EXEC uspICRaiseError 80118, @valueOtherChargeContractHeaderIdStr;
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
			EXEC uspICRaiseError 80119, @valueOtherChargeContractHeaderIdStr;
			GOTO _Exit_With_Rollback;
		END

		-- Validate Tax Group Id
		DECLARE @valueOtherChargeTaxGroupId INT = NULL

		SELECT	TOP 1 
				@valueOtherChargeTaxGroupId = RawData.intTaxGroupId	
		FROM	@OtherCharges RawData LEFT JOIN tblSMTaxGroup tg
					ON RawData.intTaxGroupId = tg.intTaxGroupId
		WHERE	tg.intTaxGroupId IS NULL 
				AND RawData.intTaxGroupId IS NOT NULL 
				AND RawData.intTaxGroupId > 0 
		
		IF @valueOtherChargeTaxGroupId IS NOT NULL
		BEGIN
			DECLARE @valueOtherChargeTaxGroupIdStr NVARCHAR(50)
			SET @valueOtherChargeTaxGroupIdStr = CAST(@valueOtherChargeTaxGroupId AS NVARCHAR(50))
			-- Tax Group Id {Tax Group Id} is invalid.
			EXEC uspICRaiseError 80116, @valueOtherChargeTaxGroupIdStr;
			GOTO _Exit_With_Rollback;
		END

		-- Validate if the sub currency matches with its Main and Receipt Currency. 
		-- Ex. If it is USC, then RawHeaderData.intCurrencyId and tblSMCurrency.intMainCurrencyId should be USD. 
		-- If RawHeaderData.intCurrencyId and tblSMCurrency.intMainCurrencyId aren't USD, then throw the error. 
		BEGIN 
			DECLARE @strCharge AS NVARCHAR(50)
					,@strSubCurrency AS NVARCHAR(50)
					,@strReceiptCurrency AS NVARCHAR(50)
					,@intBadSubCurrency AS INT 
					
			SELECT	TOP 1 
					@strCharge = charge.strItemNo
					,@intBadSubCurrency = subCurrency.intCurrencyID
					,@strSubCurrency = subCurrency.strCurrency
					,@strReceiptCurrency = receiptCurrency.strCurrency
			FROM	@OtherCharges RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
						ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0)
						AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
						AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
						AND ISNULL(RawHeaderData.[Location],0) = ISNULL(RawData.intLocationId,0)
						AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)						
						AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
						AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)
						AND ISNULL(RawHeaderData.strVendorRefNo,0) = ISNULL(RawData.strVendorRefNo,0)
						--AND ISNULL(RawHeaderData.ShipFromEntity,0) = ISNULL(RawData.intShipFromEntityId,0)	
						
					LEFT JOIN tblSMCurrency subCurrency
						ON subCurrency.intCurrencyID = RawData.intCostCurrencyId
					LEFT JOIN tblSMCurrency receiptCurrency
						ON receiptCurrency.intCurrencyID = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
					LEFT JOIN tblICItem charge
						ON charge.intItemId = RawData.intChargeId
			WHERE	RawData.ysnSubCurrency = 1	
					AND ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId) <> ISNULL(subCurrency.intMainCurrencyId, @intFunctionalCurrencyId) 

			IF (@intBadSubCurrency IS NOT NULL)
			BEGIN 
				--'Please check {Other Charge}. It is using {Sub Currency} but it is not a sub currency of {Receipt Currency}.'
				EXEC uspICRaiseError 80204, @strCharge, @strSubCurrency, @strReceiptCurrency;
				GOTO _Exit_With_Rollback;
			END 
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
				,[strChargesLink]
				,[ysnAllowVoucher]
				,dtmDateCreated
				,intCreatedByUserId
				,intLoadShipmentId
				,intLoadShipmentCostId
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
				,[intEntityVendorId]		= 
							CASE WHEN RawData.ysnAccrue = 1 THEN 
									ISNULL(RawData.intOtherChargeEntityVendorId, RawData.intEntityVendorId) 
								 ELSE 
									NULL
							END 
				,[dblAmount]				= RawData.dblAmount
				,[strAllocateCostBy]		= RawData.strAllocateCostBy
				,[ysnAccrue]				= RawData.ysnAccrue
				,[ysnPrice]					= RawData.ysnPrice
				,[ysnSubCurrency]			= ISNULL(RawData.ysnSubCurrency, 0) 
				,[intCurrencyId]			= COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) 
				,[intCent]					= CostCurrency.intCent
				,[intTaxGroupId]			= CASE WHEN RawData.intTaxGroupId < 0 THEN NULL ELSE ISNULL(RawData.intTaxGroupId, taxHierarcy.intTaxGroupId) END 
				,[intForexRateTypeId]		= CASE WHEN COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 						
				,[dblForexRate]				= CASE WHEN COALESCE(RawData.intCostCurrencyId, RawData.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(RawData.ysnSubCurrency, 0) = 0 THEN ISNULL(RawData.dblForexRate, forexRate.dblRate) ELSE NULL END 			
				,[strChargesLink]			= RawData.strChargesLink
				,[ysnAllowVoucher]			= RawData.ysnAllowVoucher
				,GETDATE()
				,@intUserId
				,intLoadShipmentId			= RawData.intLoadShipmentId
				,intLoadShipmentCostId		= RawData.intLoadShipmentCostId
		FROM	@OtherCharges RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(RawData.intEntityVendorId, 0)
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(RawData.intCurrencyId, @intFunctionalCurrencyId)
					AND ISNULL(RawHeaderData.[Location],0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)					
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
					--AND ISNULL(RawHeaderData.strVendorRefNo,0) = ISNULL(RawData.strVendorRefNo,0)
					--AND ISNULL(RawHeaderData.ShipFromEntity,0) = ISNULL(RawData.intShipFromEntityId,0)					

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

				-- Get the default tax group (if override was not provided)
				OUTER APPLY (
					SELECT	taxGroup.intTaxGroupId, taxGroup.strTaxGroup
					FROM	tblSMTaxGroup taxGroup
					WHERE	taxGroup.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor (
								ISNULL(RawData.intOtherChargeEntityVendorId, RawData.intEntityVendorId)	-- @VendorId
								,RawData.intLocationId			--,@CompanyLocationId
								,NULL							--,@ItemId
								,RawData.intShipFromId			--,@VendorLocationId
								,NULL							--,@FreightTermId -- NOTE: There is no freight terms for Other Charges. 
							)
							AND RawData.intTaxGroupId IS NULL 			
				) taxHierarcy 

		WHERE RawHeaderData.intId = @intId

		-- Add the taxes into the receipt. 
		BEGIN 
			EXEC [uspICCalculateReceiptTax] @inventoryReceiptId
		END 
		
		-- Add lot/s to receipt item if @LotEntries contains a value
		IF EXISTS (SELECT TOP 1 1 FROM @LotEntries)
		BEGIN 
			------------------------------------------------
			------- Validate Receipt Item Lot fields -------
			------------------------------------------------
			DECLARE @valueLotRecordId INT = NULL
					,@valueLotRecordNo NVARCHAR(50) = NULL

			-- Validate Lot Entity Id
			SELECT TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblEMEntity Entity
						ON ItemLot.intEntityVendorId = Entity.intEntityId									
			WHERE	RTRIM(LTRIM(LOWER(ItemLot.strReceiptType))) <> 'transfer order'
					AND Entity.intEntityId IS NULL 
					AND ItemLot.intEntityVendorId IS NOT NULL 

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Entity Id is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80146, @valueLotRecordNo;
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
				EXEC uspICRaiseError 80147, @valueLotRecordNo;
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
				EXEC uspICRaiseError 80148, @valueLotRecordNo;
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
				EXEC uspICRaiseError 80149, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Ship From Id --
			SET @valueLotRecordNo = NULL
						
			SELECT TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblEMEntityLocation el
						ON ItemLot.intShipFromId = el.intEntityLocationId						
			WHERE	RTRIM(LTRIM(LOWER(ItemLot.strReceiptType))) <> 'transfer order'
					AND ItemLot.intShipFromId IS NOT NULL 
					AND el.intEntityLocationId IS NULL 							

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Ship From Id is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80150, @valueLotRecordNo
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Source Type Id
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot
			WHERE	ItemLot.intSourceType IS NULL 
					OR ItemLot.intSourceType > 5 
					OR ItemLot.intSourceType < 0

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Source Type Id is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80152, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Item Id
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot	LEFT JOIN tblICItem i 
						ON ItemLot.intItemId = i.intItemId
			WHERE	ItemLot.intItemId IS NULL 
					OR i.intItemId IS NULL 

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Item Id is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80153, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Sub Location Id
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot	LEFT JOIN tblSMCompanyLocationSubLocation subLocation
						ON ItemLot.intLocationId = subLocation.intCompanyLocationId
						AND ItemLot.intSubLocationId = subLocation.intCompanyLocationSubLocationId
			WHERE	ItemLot.intSubLocationId IS NULL 
					OR subLocation.intCompanyLocationSubLocationId IS NULL 

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Sub Location is invalid or missing for {Lot Number}.
				EXEC uspICRaiseError 80155, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Storage Location Id
			SET @valueLotRecordNo = NULL

			SELECT	TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblICStorageLocation storageLocation
						ON ItemLot.intLocationId = storageLocation.intLocationId
						AND ItemLot.intSubLocationId= storageLocation.intSubLocationId
						AND ItemLot.intStorageLocationId = storageLocation.intStorageLocationId									
			WHERE	ItemLot.intStorageLocationId IS NULL 
					OR storageLocation.intStorageLocationId IS NULL
								 
			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- 'Storage Unit is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80155, @valueLotRecordNo
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Id
			DECLARE @valueLotRecordLotId INT = NULL
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordLotId = ItemLot.intLotId
					, @valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblICLot l
						ON ItemLot.intLotId = l.intLotId
			WHERE	l.intLotId IS NULL 
					AND ItemLot.intLotId IS NOT NULL 

			IF @valueLotRecordLotId > 0
			BEGIN
				DECLARE @valueLotRecordLotIdStr NVARCHAR(50)
				SET @valueLotRecordLotIdStr = CAST(@valueLotRecordLotId AS NVARCHAR(50))
				-- Lot ID {Lot Id} is invalid for lot {Lot Number}.
				EXEC uspICRaiseError 80157, @valueLotRecordLotIdStr, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Number
			DECLARE @valueLotRecordLotNo NVARCHAR(50) = NULL
					,@valueLotRecordItemId INT = NULL
					,@valueLotRecordItemNo NVARCHAR(50) = NULL

			SELECT TOP 1 @valueLotRecordItemId = ItemLot.intItemId
			FROM	@LotEntries ItemLot LEFT JOIN tblICLot l
						ON ItemLot.strLotNumber = l.strLotNumber
						AND ItemLot.intLotId = l.intLotId
			WHERE	ItemLot.strLotNumber IS NOT NULL 
					AND ItemLot.intLotId IS NOT NULL 
					AND l.strLotNumber IS NULL 

			IF @valueLotRecordItemId > 0
			BEGIN
				SELECT @valueLotRecordItemNo = strItemNo
				FROM tblICItem
				WHERE intItemId = @valueLotRecordItemId

				-- Lot Number is invalid or missing for item {ItemNo.}.
				EXEC uspICRaiseError 80130, @valueLotRecordItemNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Item UOM Id
			SET @valueLotRecordNo = NULL
								 
			SELECT	TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblICItemUOM iu
						ON ItemLot.intItemId = iu.intItemId
						AND ItemLot.intItemUnitMeasureId = iu.intItemUOMId 
			WHERE	ItemLot.intItemUnitMeasureId IS NULL 
					AND iu.intItemUOMId IS NULL 

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Item UOM Id is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80156, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Lot Condition
			DECLARE @valueLotRecordLotCondition NVARCHAR(50) = NULL
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordLotCondition = ItemLot.strCondition, @valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot
			WHERE	ItemLot.strCondition IS NOT NULL 
					AND RTRIM(LTRIM(LOWER(ItemLot.strCondition))) NOT IN ('sound/full', 'slack', 'damaged', 'clean wgt')

			IF @valueLotRecordLotCondition IS NOT NULL
			BEGIN
				-- Lot Condition {Lot Condition} is invalid for lot {Lot Number}.
				EXEC uspICRaiseError 80131, @valueLotRecordLotCondition, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Parent Lot Id
			DECLARE @valueLotRecordParentLotId INT = NULL
					,@valueLotRecordParentLotIdStr NVARCHAR(50)
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordParentLotId = ItemLot.intParentLotId
					, @valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblICLot l
						ON ItemLot.intLotId = l.intLotId
						AND ItemLot.intParentLotId = l.intParentLotId
			WHERE	ItemLot.intParentLotId IS NOT NULL 
					AND l.intParentLotId IS NULL 

			IF @valueLotRecordParentLotId > 0
			BEGIN
				SET @valueLotRecordParentLotIdStr = CAST(@valueLotRecordParentLotId AS NVARCHAR(50))
				-- Parent Lot Id {Parent Lot Id} is invalid for lot {Lot Number}.
				EXEC uspICRaiseError 80132, @valueLotRecordParentLotIdStr, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate Parent Lot Number
			DECLARE @valueLotRecordParentLotNo NVARCHAR(50) = NULL
			SET @valueLotRecordNo = NULL

			SELECT TOP 1 
					@valueLotRecordNo = ItemLot.strLotNumber
			FROM	@LotEntries ItemLot LEFT JOIN tblICParentLot parentLot
						ON ItemLot.intItemId = parentLot.intItemId
						AND ItemLot.intParentLotId = parentLot.intParentLotId
						AND ItemLot.strParentLotNumber = parentLot.strParentLotNumber
			WHERE	ItemLot.intParentLotId IS NOT NULL 
					AND parentLot.intParentLotId IS NULL 

			IF @valueLotRecordNo IS NOT NULL
			BEGIN
				-- Parent Lot Number is invalid or missing for lot {Lot Number}.
				EXEC uspICRaiseError 80133, @valueLotRecordNo;
				GOTO _Exit_With_Rollback;
			END

			-- Validate the Producer Id. 
			BEGIN
				DECLARE @intEntityProducerId AS INT
				DECLARE @intProducerId AS INT 
				DECLARE @strEntityName AS NVARCHAR(50) 

				SET @intEntityProducerId = NULL  
				SET	@strEntityName = NULL 

				SELECT	TOP 1 
						@intProducerId = ItemLot.intProducerId 
						,@intEntityProducerId = et.intEntityId
						,@strEntityName  = e.strName
				FROM	@LotEntries ItemLot LEFT JOIN tblICItem i
							ON ItemLot.intItemId = i.intItemId 
						LEFT JOIN tblEMEntity e 
							ON ItemLot.intProducerId = e.intEntityId 
						LEFT JOIN tblEMEntityType et
							ON e.intEntityId = et.intEntityId
							AND et.strType = 'Producer'
				WHERE	ItemLot.intProducerId IS NOT NULL 
						AND et.intEntityId IS NULL 

				IF (@intProducerId IS NOT NULL) AND (@intEntityProducerId IS NULL)
				BEGIN 
					--'Invalid Producer. {Entity Name} is not configured as a Producer type. Please check the Entity setup.'
					EXEC uspICRaiseError 80210, @strEntityName;
					GOTO _Exit_With_Rollback;
				END 
			END 

			-- Validate the Certificate. 
			BEGIN
				DECLARE @strCertificateName AS NVARCHAR(50) 

				SELECT	TOP 1 
						@strCertificateName = ItemLot.strCertificate 									
				FROM	@LotEntries ItemLot LEFT JOIN tblICCertification c
							ON ItemLot.strCertificate = c.strCertificationName 
				WHERE	ItemLot.strCertificate IS NOT NULL 
						AND c.strCertificationName IS NULL 
				IF (@strCertificateName IS NOT NULL)
				BEGIN 
					--'Certificate {Certificate Name} is invalid or missing. Create or fix it at Contract Management -> Certification Programs.'
					EXEC uspICRaiseError 80211, @strCertificateName;
					GOTO _Exit_With_Rollback;
				END 
			END 

			DECLARE @DefaultLotCondition NVARCHAR(50)
			SELECT @DefaultLotCondition = strLotCondition FROM tblICCompanyPreference
			
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
				,[strCertificate]
				,[intProducerId]
				,[strCertificateId]
				,[strTrackingNumber]
				,[intSort]
				,[intConcurrencyId]
				,dtmDateCreated
				,intCreatedByUserId
			)
			SELECT
				[intInventoryReceiptItemId]	= ReceiptItem.intInventoryReceiptItemId
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
				,[strCondition] = ISNULL(NULLIF(ItemLot.strCondition, ''), @DefaultLotCondition)
				,[dtmCertified] = ItemLot.dtmCertified
				,[dtmExpiryDate] = 
					ISNULL(
						ItemLot.dtmExpiryDate
						,dbo.fnICCalculateExpiryDate (
							ReceiptItem.intItemId
							, ItemLot.dtmManufacturedDate
							, Receipt.dtmReceiptDate
						)
					)
				,[intParentLotId] = ItemLot.intParentLotId
				,[strParentLotNumber] = ItemLot.strParentLotNumber
				,[strParentLotAlias] = ItemLot.strParentLotAlias
				,[strCertificate] = ItemLot.strCertificate
				,[intProducerId] = ItemLot.intProducerId
				,[strCertificateId] = ItemLot.strCertificateId
				,[strTrackingNumber] = ItemLot.strTrackingNumber 
				,[intSort] = 1
				,[intConcurrencyId] = 1
				,[dtmDateCreated] = GETDATE()
				,[intCreatedByUserId] = @intUserId
			FROM	
				@LotEntries ItemLot INNER JOIN @DataForReceiptHeader RawHeaderData
					ON ISNULL(RawHeaderData.Vendor, 0) = ISNULL(ItemLot.intEntityVendorId, 0)
					AND ISNULL(RawHeaderData.BillOfLadding, '') = ISNULL(ItemLot.strBillOfLadding , '')
					AND ISNULL(RawHeaderData.Currency, @intFunctionalCurrencyId) = ISNULL(ItemLot.intCurrencyId, @intFunctionalCurrencyId)
					AND ISNULL(RawHeaderData.[Location],0) = ISNULL(ItemLot.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(ItemLot.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(ItemLot.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(ItemLot.intShipViaId,0)		   
					AND ISNULL(RawHeaderData.intSourceType,0) = ISNULL(ItemLot.intSourceType, 0)					
					--AND ISNULL(RawHeaderData.strVendorRefNo,0) = ISNULL(ItemLot.strVendorRefNo,0)
					--AND ISNULL(RawHeaderData.ShipFromEntity,0) = ISNULL(ItemLot.intShipFromEntityId,0)											
				INNER JOIN tblICInventoryReceiptItem ReceiptItem 
					ON ReceiptItem.intItemId = ItemLot.intItemId
					AND ISNULL(ReceiptItem.intSubLocationId, 0) = ISNULL(ItemLot.intSubLocationId, 0)
					AND ISNULL(ReceiptItem.intStorageLocationId, 0) = ISNULL(ItemLot.intStorageLocationId, 0)
					AND ISNULL(ReceiptItem.intOrderId, 0) = ISNULL(ItemLot.intContractHeaderId, 0)
					AND ISNULL(ReceiptItem.intLineNo, 0) = ISNULL(ItemLot.intContractDetailId, 0)
					AND ISNULL(ReceiptItem.intSort, 1) = ISNULL(ItemLot.intSort, 1)
				INNER JOIN tblICInventoryReceipt Receipt
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN tblICItem i ON i.intItemId = ItemLot.intItemId
			WHERE
				Receipt.intInventoryReceiptId = @inventoryReceiptId
				AND i.strLotTracking != 'No'
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

		-- Validate the receipt total. Do not allow negative receipt total. 
		-- However, allow it if source type is a 'STORE'
		IF EXISTS (
			SELECT 1
			FROM	tblICInventoryReceipt r
			WHERE	r.intInventoryReceiptId = @inventoryReceiptId
					AND dbo.fnICGetReceiptTotals(@inventoryReceiptId, 6) < 0
					AND r.intSourceType <> @SourceType_STORE 
		) 
		BEGIN
			-- Unable to create the Inventory Receipt. The receipt total is going to be negative.
			EXEC uspICRaiseError 80182;
			GOTO _Exit_With_Rollback;
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

		-- Update the transfer order status
		IF RTRIM(LTRIM(LOWER(@valueReceiptType))) IN ('transfer order')
		BEGIN 
			EXEC uspICUpdateTransferOrderStatus @inventoryReceiptId, @STATUS_CLOSED
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