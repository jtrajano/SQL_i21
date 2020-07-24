CREATE PROCEDURE [dbo].[uspICAddPurchaseOrderToInventoryReceipt]
	@PurchaseOrderId AS INT
	,@intEntityUserSecurityId AS INT
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(20)

DECLARE @ReceiptType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @ReceiptType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @ReceiptType_Direct AS NVARCHAR(100) = 'Direct'

IF @PurchaseOrderId IS NULL 
BEGIN 
    -- Raise the error:
    -- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
	EXEC uspICRaiseError 80004; 
    GOTO _Exit
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

-- Get the transaction id 
EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 

-- Insert the Inventory Receipt header 
INSERT INTO dbo.tblICInventoryReceipt (
		strReceiptNumber
		,dtmReceiptDate
		,intEntityVendorId
		,strReceiptType
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
		,ysnPosted
)
SELECT 	strReceiptNumber		= @ReceiptNumber
		,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
		,intEntityVendorId		= PO.[intEntityVendorId]
		,strReceiptType			= @ReceiptType_PurchaseOrder
		,intBlanketRelease		= NULL
		,intLocationId			= PO.intShipToId
		,strVendorRefNo			= PO.strReference
		,strBillOfLading		= NULL
		,intShipViaId			= PO.intShipViaId
		,intShipFromId			= PO.intShipFromId 
		,intReceiverId			= @intEntityUserSecurityId 
		,intCurrencyId			= PO.intCurrencyId
		,strVessel				= NULL
		,intFreightTermId		= PO.intFreightTermId
		,intShiftNumber			= NULL 
		,dblInvoiceAmount		= PO.dblTotal
		,ysnInvoicePaid			= 0 
		,intCheckNo				= NULL 
		,dteCheckDate			= NULL 
		,intTrailerTypeId		= NULL 
		,dteTrailerArrivalDate	= NULL 
		,dteTrailerArrivalTime	= NULL 
		,strSealNo				= NULL 
		,strSealStatus			= NULL 
		,dteReceiveTime			= NULL 
		,dblActualTempReading	= NULL 
		,intConcurrencyId		= 1
		,intEntityId			= @intEntityUserSecurityId
		,ysnPosted				= 0
FROM	dbo.tblPOPurchase PO
WHERE	PO.intPurchaseId = @PurchaseOrderId

-- Get the identity value from tblICInventoryReceipt
SELECT @InventoryReceiptId = SCOPE_IDENTITY()

INSERT INTO dbo.tblICInventoryReceiptItem (
	intInventoryReceiptId
    ,intLineNo
	,intOrderId
    ,intItemId
	,intSubLocationId
	,dblOrderQty
	,dblOpenReceive
	,dblReceived
    ,intUnitMeasureId
	,intWeightUOMId
    ,dblUnitCost
	,dblLineTotal
    ,intSort
    ,intConcurrencyId
)
SELECT	intInventoryReceiptId	= @InventoryReceiptId
		,intLineNo				= PODetail.intPurchaseDetailId
		,intOrderId				= @PurchaseOrderId
		,intItemId				= PODetail.intItemId
		,intSubLocationId		= PODetail.intSubLocationId
		,dblOrderQty			= ISNULL(PODetail.dblQtyOrdered, 0)
		,dblOpenReceive			= ISNULL(PODetail.dblQtyOrdered, 0) - ISNULL(PODetail.dblQtyReceived, 0)
		,dblReceived			= ISNULL(PODetail.dblQtyReceived, 0)
		,intUnitMeasureId		= ItemUOM.intItemUOMId
		,intWeightUOMId			=	(
										SELECT	TOP 1 
												tblICItemUOM.intItemUOMId 
										FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
													ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
										WHERE	tblICItemUOM.intItemId = PODetail.intItemId 
												AND tblICItemUOM.ysnStockUnit = 1 
												AND tblICUnitMeasure.strUnitType IN ('Weight', 'Volume')
												AND dbo.fnGetItemLotType(PODetail.intItemId) <> 0 
									)
		,dblUnitCost			= PODetail.dblCost
		,dblLineTotal			= (ISNULL(PODetail.dblQtyOrdered, 0) - ISNULL(PODetail.dblQtyReceived, 0)) * PODetail.dblCost
		,intSort				= PODetail.intLineNo
		,intConcurrencyId		= 1
FROM	dbo.tblPOPurchaseDetail PODetail INNER JOIN dbo.tblICItemUOM ItemUOM			
			ON ItemUOM.intItemId = PODetail.intItemId
			AND ItemUOM.intItemUOMId = PODetail.intUnitOfMeasureId
		INNER JOIN dbo.tblICUnitMeasure UOM
			ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
WHERE	PODetail.intPurchaseId = @PurchaseOrderId
		AND dbo.fnIsStockTrackingItem(PODetail.intItemId) = 1
		AND PODetail.dblQtyOrdered != PODetail.dblQtyReceived

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
			,@CostUOMId			INT

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
		,dblBaseRate			NUMERIC(18,6)
		,dblTax					NUMERIC(18,6)
		,dblAdjustedTax			NUMERIC(18,6)
		,intTaxAccountId		INT
		,ysnSeparateOnInvoice	BIT
		,ysnCheckoffTax			BIT
		,strTaxCode				NVARCHAR(50)
		,ysnTaxExempt			BIT
		,[ysnTaxOnly]			BIT
		,ysnInvalidSetup		BIT
		,[strTaxGroup]			NVARCHAR(100)
		,[strNotes]				NVARCHAR(500)
		,[ysnBookToExemptionAccount] BIT
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
			,ISNULL(ReceiptItem.intTaxGroupId, Receipt.intTaxGroupId)
			,Receipt.intFreightTermId 
			,ReceiptItem.intCostUOMId
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
		,@ShipFromId
		,@TaxGroupId
		,@FreightTermId
		,@CostUOMId

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
			,dblBaseRate
			,dblTax
			,dblAdjustedTax
			,intTaxAccountId
			,ysnSeparateOnInvoice
			,ysnCheckoffTax
			,strTaxCode
			,ysnTaxExempt
			,[ysnTaxOnly]
			,ysnInvalidSetup
			,[strTaxGroup]
			,[strNotes]
			,[ysnBookToExemptionAccount]
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
			,@UOMId					= @CostUOMId



		DECLARE	@Amount	NUMERIC(38,20) 
				,@Qty	NUMERIC(38,20)
		-- Fields used in the calculation of the taxes

		SELECT TOP 1
				@Amount = ReceiptItem.dblUnitCost
				,@Qty	 = ReceiptItem.dblOpenReceive 

		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				--INNER JOIN dbo.tblICInventoryReceiptItemTax ItemTax
				--	ON ItemTax.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
		WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId
				AND ReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId

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
		FROM	[dbo].[fnGetItemTaxComputationForVendor](@ItemId, @EntityId, @TransactionDate, @Amount, @Qty, @TaxGroupId, @LocationId, @ShipFromId, 0, 0, @FreightTermId, 0, @CostUOMId, NULL, NULL, NULL)

		--Compute the tax
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
				,intTaxGroupId				= ISNULL(ReceiptItem.intTaxGroupId, Receipt.intTaxGroupId)
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
			,@ShipFromId
			,@TaxGroupId
			,@FreightTermId
			,@CostUOMId
	END 

	CLOSE loopReceiptItems;
	DEALLOCATE loopReceiptItems;
END 

-- Calculate the tax per line item 
UPDATE	ReceiptItem 
SET		dblTax = ISNULL(Taxes.dblTaxPerLineItem, 0)
FROM	dbo.tblICInventoryReceiptItem ReceiptItem LEFT JOIN (
			SELECT	dblTaxPerLineItem = SUM (
						CASE WHEN ISNULL(ysnTaxAdjusted, 0) = 1 THEN ISNULL(ReceiptItemTax.dblAdjustedTax, 0)	
								ELSE ISNULL(ReceiptItemTax.dblTax, 0)
						END						
					) 
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
SET		dblLineTotal = ISNULL(dblOpenReceive, 0) * ISNULL(dblUnitCost, 0) --+ ISNULL(dblTax, 0)
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

_Exit: 
