CREATE PROCEDURE [dbo].[uspICAddItemReceipt]
	@ReceiptEntries ReceiptStagingTable READONLY
	,@OtherCharges ReceiptOtherChargesTableType READONLY 
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(50);
DECLARE @InventoryReceiptId AS INT;

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
	,intTaxCodeId			INT
	,intTaxClassId			INT
	,strTaxableByOtherTaxes NVARCHAR(MAX) 
	,strCalculationMethod	NVARCHAR(50)
	,numRate				NUMERIC(18,6)
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
)
SELECT	RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
FROM	@ReceiptEntries RawData
GROUP BY RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
;

-- Validate if there is data to process. If there is no data, then raise an error. 
IF NOT EXISTS (SELECT TOP 1 1 FROM @DataForReceiptHeader)
BEGIN 
	-- 'Data not found. Unable to create the Inventory Receipt.'
	RAISERROR(51169, 11, 1);	
	GOTO _Exit;
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
		
		SET @ReceiptNumber = NULL 
		SET @InventoryReceiptId = NULL 

		-- Check if there is an existing Inventory receipt 
		SELECT	@InventoryReceiptId = RawData.intInventoryReceiptId
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData
					ON RawHeaderData.Vendor = RawData.intEntityVendorId 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)	
		WHERE	RawHeaderData.intId = @intId
				
		IF @InventoryReceiptId IS NULL 
		BEGIN 
			-- Generate the receipt starting number
			-- If @ReceiptNumber IS NULL, uspSMGetStartingNumber will throw an error. 
			-- Error is 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
			EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 
			IF @@ERROR <> 0 OR @ReceiptNumber IS NULL GOTO _BreakLoop;
		END 

		MERGE	
		INTO	dbo.tblICInventoryReceipt 
		WITH	(HOLDLOCK) 
		AS		Receipt 
		USING (
			SELECT	RawData.*
			FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData
						ON RawHeaderData.Vendor = RawData.intEntityVendorId 
						AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
						AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
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
				,strVendorRefNo			= NULL
				,strBillOfLading		= IntegrationData.strBillOfLadding
				,intShipViaId			= IntegrationData.intShipViaId
				,intShipFromId			= IntegrationData.intShipFromId
				,intReceiverId			= @intUserId 
				,intCurrencyId			= IntegrationData.intCurrencyId
				,strVessel				= NULL
				,intFreightTermId		= NULL
				,strAllocateFreight		= 'No' -- Default is No
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
				,intEntityId			= (SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WHERE intUserSecurityID = @intUserId)
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0

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
				,strVessel
				,intFreightTermId
				,strAllocateFreight
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
			)
			VALUES (
				/*strReceiptNumber*/			@ReceiptNumber
				/*dtmReceiptDate*/				,dbo.fnRemoveTimeOnDate(ISNULL(IntegrationData.dtmDate, GETDATE()))
				/*intEntityVendorId*/			,IntegrationData.intEntityVendorId
				/*strReceiptType*/				,IntegrationData.strReceiptType
				/*intSourceType*/				,IntegrationData.intSourceType
				/*intBlanketRelease*/			,NULL
				/*intLocationId*/				,IntegrationData.intLocationId
				/*strVendorRefNo*/				,NULL
				/*strBillOfLading*/				,IntegrationData.strBillOfLadding
				/*intShipViaId*/				,IntegrationData.intShipViaId
				/*intShipFromId*/				,IntegrationData.intShipFromId
				/*intReceiverId*/				,@intUserId 
				/*intCurrencyId*/				,IntegrationData.intCurrencyId
				/*strVessel*/					,NULL
				/*intFreightTermId*/			,NULL
				/*strAllocateFreight*/			,'No' -- Default is No
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
				/*intEntityId*/					,(SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WHERE intUserSecurityID = @intUserId)
				/*intCreatedUserId*/			,@intUserId
				/*ysnPosted*/					,0
			)
		;
				
		-- Get the identity value from tblICInventoryReceipt to check if the insert was successful
		IF @InventoryReceiptId IS NULL 
		BEGIN 
			SELECT @InventoryReceiptId = SCOPE_IDENTITY()
		END 
						
		-- Validate the inventory receipt id
		IF @InventoryReceiptId IS NULL 
		BEGIN 
			-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
			RAISERROR(50031, 11, 1);
			RETURN;
		END

		--  Flush out existing detail detail data for re-insertion
		BEGIN 
			DELETE FROM dbo.tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @InventoryReceiptId

			DELETE FROM dbo.tblICInventoryReceiptCharge
			WHERE intInventoryReceiptId = @InventoryReceiptId
		END 

		-- Insert the Inventory Receipt Detail. 
		INSERT INTO dbo.tblICInventoryReceiptItem (
				intInventoryReceiptId
				,intLineNo
				,intOrderId
				,intSourceId
				,intItemId
				,intSubLocationId
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
		)
		SELECT	intInventoryReceiptId	= @InventoryReceiptId
				,intLineNo				= ISNULL(RawData.intContractDetailId, 0)
				,intOrderId				= RawData.intContractHeaderId
				,intSourceId			= RawData.intSourceId
				,intItemId				= RawData.intItemId
				,intSubLocationId		= NULL
				,dblOrderQty			= ISNULL(RawData.dblQty, 0)
				,dblOpenReceive			= ISNULL(RawData.dblQty, 0)
				,dblReceived			= ISNULL(RawData.dblQty, 0)
				,intUnitMeasureId		= ItemUOM.intItemUOMId
				,intWeightUOMId			= (
												SELECT	TOP 1 
														tblICItemUOM.intItemUOMId 
												FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
															ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
												WHERE	tblICItemUOM.intItemId = RawData.intItemId 
														AND tblICItemUOM.ysnStockUnit = 1 
														AND tblICUnitMeasure.strUnitType = 'Weight'
														AND dbo.fnGetItemLotType(RawData.intItemId) IN (1,2)
										)
				,dblUnitCost			= RawData.dblCost
				--,dblLineTotal			= RawData.dblQty * RawData.dblCost
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType       = CASE	WHEN RawData.ysnIsCustody = 0 THEN @OWNERSHIP_TYPE_Own
												WHEN RawData.ysnIsCustody = 1 THEN @OWNERSHIP_TYPE_Storage
												ELSE @OWNERSHIP_TYPE_Own
										  END
				,dblGross				= RawData.dblGross
				,dblNet					= RawData.dblNet
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON RawHeaderData.Vendor = RawData.intEntityVendorId 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
				INNER JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intItemId  
					AND ItemUOM.intItemUOMId = RawData.intItemUOMId			
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
		WHERE RawHeaderData.intId = @intId

		-- Insert the Other Charges
		INSERT INTO dbo.tblICInventoryReceiptCharge (
				[intInventoryReceiptId]
				,[intContractId]
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
		)
		SELECT 
				[intInventoryReceiptId]		= @InventoryReceiptId
				,[intContractId]			= RawData.intContractDetailId
				,[intChargeId]				= RawData.intChargeId
				,[ysnInventoryCost]			= RawData.ysnInventoryCost
				,[strCostMethod]			= RawData.strCostMethod
				,[dblRate]					= RawData.dblRate
				,[intCostUOMId]				= RawData.intCostUOMId
				,[intEntityVendorId]		= RawData.intEntityVendorId
				,[dblAmount]				= RawData.dblAmount
				,[strAllocateCostBy]		= RawData.strAllocateCostBy
				,[ysnAccrue]				= RawData.ysnAccrue
				,[ysnPrice]					= RawData.ysnPrice
		FROM	@OtherCharges RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON RawHeaderData.Vendor = RawData.intEntityVendorId 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
				LEFT JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intChargeId  
					AND ItemUOM.intItemUOMId = RawData.intCostUOMId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
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

			DECLARE @Taxes AS TABLE (
				id						INT
				,intInvoiceDetailId		INT
				,intTaxGroupMasterId	INT
				,intTaxGroupId			INT 
				,intTaxCodeId			INT
				,intTaxClassId			INT
				,strTaxableByOtherTaxes NVARCHAR (MAX) 
				,strCalculationMethod	NVARCHAR(50)
				,numRate				NUMERIC(18,6)
				,dblTax					NUMERIC(18,6)
				,dblAdjustedTax			NUMERIC(18,6)
				,intTaxAccountId		INT
				,ysnSeparateOnInvoice	BIT
				,ysnCheckoffTax			BIT
				,strTaxCode				NVARCHAR(50)
				,ysnTaxExempt			BIT
			)

			-- Create the cursor
			DECLARE loopReceiptItems CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  ReceiptItem.intItemId
					,Receipt.intLocationId
					,Receipt.dtmReceiptDate
					,Receipt.intEntityId
					,ReceiptItem.intInventoryReceiptItemId
			FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
						ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

			OPEN loopReceiptItems;

			-- Initial fetch attempt
			FETCH NEXT FROM loopReceiptItems INTO 
				@ItemId
				,@LocationId
				,@TransactionDate
				,@EntityId
				,@InventoryReceiptItemId

			WHILE @@FETCH_STATUS = 0
			BEGIN 
				-- Clear the contents of the table variable.
				DELETE FROM @Taxes

				-- Get the taxes from uspSMGetItemTaxes
				INSERT INTO @Taxes (
					id
					,intInvoiceDetailId
					,intTaxGroupMasterId
					,intTaxGroupId
					,intTaxCodeId
					,intTaxClassId
					,strTaxableByOtherTaxes
					,strCalculationMethod
					,numRate
					,dblTax
					,dblAdjustedTax
					,intTaxAccountId
					,ysnSeparateOnInvoice
					,ysnCheckoffTax
					,strTaxCode
					,ysnTaxExempt				
				)
				EXEC dbo.uspSMGetItemTaxes 
					@ItemId
					,@LocationId
					,@TransactionDate
					,@TransactionType
					,@EntityId
					,@TaxMasterId

				-- Insert the data from the table variable into Inventory Receipt Item tax table. 
				INSERT INTO dbo.tblICInventoryReceiptItemTax (
					[intInventoryReceiptItemId]
					,[intTaxGroupMasterId]
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
						,[intTaxGroupMasterId]			= intTaxGroupMasterId
						,[intTaxGroupId]				= intTaxGroupId
						,[intTaxCodeId]					= intTaxCodeId
						,[intTaxClassId]				= intTaxClassId
						,[strTaxableByOtherTaxes]		= strTaxableByOtherTaxes
						,[strCalculationMethod]			= strCalculationMethod
						,[dblRate]						= numRate
						,[dblTax]						= dblTax
						,[dblAdjustedTax]				= dblAdjustedTax
						,[intTaxAccountId]				= intTaxAccountId
						,[ysnTaxAdjusted]				= CASE WHEN ISNULL(dblAdjustedTax, 0) <> 0 THEN 1 ELSE 0 END 
						,[ysnSeparateOnInvoice]			= ysnSeparateOnInvoice
						,[ysnCheckoffTax]				= ysnCheckoffTax
						,[strTaxCode]					= strTaxCode
						,[intSort]						= 1
						,[intConcurrencyId]				= 1
				FROM	@Taxes

				-- Compute the tax
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
						,intTaxCodeId
						,intTaxClassId
						,strTaxableByOtherTaxes
						,strCalculationMethod
						,numRate
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
						,intTaxCodeId				= ItemTax.intTaxCodeId
						,intTaxClassId				= ItemTax.intTaxClassId
						,strTaxableByOtherTaxes		= ItemTax.strTaxableByOtherTaxes
						,strCalculationMethod		= ItemTax.strCalculationMethod
						,numRate					= ItemTax.dblRate
						,dblTax						= ItemTax.dblTax
						,dblAdjustedTax				= ItemTax.dblAdjustedTax
						,ysnCheckoffTax				= ItemTax.ysnCheckoffTax

						-- Fields used in the calculation of the taxes
						,dblAmount					= ReceiptItem.dblUnitCost
						,dblQty						= ReceiptItem.dblOpenReceive 

					FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
							INNER JOIN dbo.tblICInventoryReceiptItemTax ItemTax
								ON ItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
					WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId
							AND ReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId
					
					-- Call the SM stored procedure to compute the tax. 
					EXEC dbo.[uspSMComputeItemTaxes]

					-- Get the computed tax. 
					UPDATE	ItemTax
					SET		dblTax = ComputedTax.dblCalculatedTaxAmount
					FROM	dbo.tblICInventoryReceiptItemTax ItemTax INNER JOIN #tmpComputeItemTaxes ComputedTax
								ON ItemTax.intInventoryReceiptItemId = ComputedTax.intDetailId
								AND ItemTax.intInventoryReceiptItemTaxId = ComputedTax.intTaxDetailId
				END
									
				-- Get the next item. 
				FETCH NEXT FROM loopReceiptItems INTO 
					@ItemId
					,@LocationId
					,@TransactionDate
					,@EntityId
					,@InventoryReceiptItemId
			END 

			CLOSE loopReceiptItems;
			DEALLOCATE loopReceiptItems;
		END 

		-- Calculate the tax per line item 
		UPDATE	ReceiptItem 
		SET		dblTax = ISNULL(Taxes.dblTaxPerLineItem, 0)
		FROM	dbo.tblICInventoryReceiptItem ReceiptItem LEFT JOIN (
					SELECT	dblTaxPerLineItem = SUM(ReceiptItemTax.dblTax) 
							,ReceiptItemTax.intInventoryReceiptItemId
					FROM	dbo.tblICInventoryReceiptItemTax ReceiptItemTax INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
								ON ReceiptItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
					WHERE	ReceiptItem.intInventoryReceiptId = @InventoryReceiptId
					GROUP BY ReceiptItemTax.intInventoryReceiptItemId
				) Taxes
					ON ReceiptItem.intInventoryReceiptItemId = Taxes.intInventoryReceiptItemId
		WHERE	ReceiptItem.intInventoryReceiptId = @InventoryReceiptId

		-- Re-update the line total 
		UPDATE	ReceiptItem 
		SET		dblLineTotal = ISNULL(dblOpenReceive, 0) * ISNULL(dblUnitCost, 0) + ISNULL(dblTax, 0)
		FROM	dbo.tblICInventoryReceiptItem ReceiptItem
		WHERE	intInventoryReceiptId = @InventoryReceiptId

		-- Re-update the total cost 
		UPDATE	Receipt
		SET		dblInvoiceAmount = Detail.dblTotal
		FROM	dbo.tblICInventoryReceipt Receipt LEFT JOIN (
					SELECT	dblTotal = SUM(dblLineTotal) 
							,intInventoryReceiptId
					FROM	dbo.tblICInventoryReceiptItem 
					WHERE	intInventoryReceiptId = @InventoryReceiptId
					GROUP BY intInventoryReceiptId
				) Detail
					ON Receipt.intInventoryReceiptId = Detail.intInventoryReceiptId
		WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

		-- Log successful inserts. 
		INSERT INTO #tmpAddItemReceiptResult (
			intSourceId
			,intInventoryReceiptId
		)
		SELECT	ReceiptItem.intSourceId
				,Receipt.intInventoryReceiptId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

		-- Fetch the next row from cursor. 
		FETCH NEXT FROM loopDataForReceiptHeader INTO @intId;
	END
	-- End of the loop

	_BreakLoop:

	CLOSE loopDataForReceiptHeader;
	DEALLOCATE loopDataForReceiptHeader;
END 

_Exit: