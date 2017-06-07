/*

	Centralized sp that calculates the item taxes for the Inventory Receipt and Inventory Return. 

*/

CREATE PROCEDURE [dbo].[uspICCalculateReceiptTax]
	@inventoryReceiptId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ownership Types
DECLARE	@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

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
		AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) <> @OWNERSHIP_TYPE_Storage -- Do not compute tax if item ownership is Storage. 

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

	SELECT TOP 1
			@Amount = 				
					dbo.fnDivide(
						CASE 
							WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
								dbo.fnCalculateCostBetweenUOM(COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intWeightUOMId, ReceiptItem.dblUnitCost) 
							ELSE 
								dbo.fnCalculateCostBetweenUOM(COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId), ReceiptItem.intUnitMeasureId, ReceiptItem.dblUnitCost) 			
						END 
						,CASE WHEN ISNULL(Receipt.intSubCurrencyCents, 0) = 0 THEN 1 ELSE Receipt.intSubCurrencyCents END 
					)
					
		,@Qty	 = CASE	WHEN ReceiptItem.intWeightUOMId IS NOT NULL THEN 
							ReceiptItem.dblNet 
						ELSE 
							ReceiptItem.dblOpenReceive 
					END 

	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			LEFT JOIN dbo.tblICItemUOM ReceiveUOM 
				ON ReceiveUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
				ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON CostUOM.intItemUOMId = ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId) 	
	WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId
			AND ReceiptItem.intInventoryReceiptItemId = @InventoryReceiptItemId

	-- Compute Item Taxes
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

_EXIT: 

CLOSE loopReceiptItems;
DEALLOCATE loopReceiptItems;
