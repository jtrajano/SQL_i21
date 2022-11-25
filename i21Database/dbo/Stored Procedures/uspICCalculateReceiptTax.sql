﻿/*

	Centralized sp that calculates the item taxes for the Inventory Receipt and Inventory Return. 

*/

CREATE PROCEDURE [dbo].[uspICCalculateReceiptTax]
	@inventoryReceiptId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Ownership Types
DECLARE	@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

DECLARE @SourceType_NONE AS INT = 0
		,@SourceType_SCALE AS INT = 1
		,@SourceType_INBOUND_SHIPMENT AS INT = 2
		,@SourceType_TRANSPORT AS INT = 3
		,@SourceType_SETTLE_STORAGE AS INT = 4
		,@SourceType_DELIVERY_SHEET AS INT = 5
		,@SourceType_PURCHASE_ORDER AS INT = 6
		,@SourceType_STORE AS INT = 7
		,@SourceType_STORE_LOTTERY_MODULE AS INT = 8
		,@SourceType_TRANSFER_SHIPMENT AS INT = 9

DECLARE	@ItemId				INT
		,@LocationId		INT
		,@TransactionDate	DATETIME
		,@TransactionType	NVARCHAR(40) = 'Purchase'
		,@EntityId			INT	
		,@TaxMasterId		INT	
		,@InventoryReceiptItemId INT
		,@ShipFromId		INT 
		,@TaxGroupId		INT
		,@FreightTermId		INT
		,@TaxUOMId			INT
		,@TaxUnitMeasureId INT

DECLARE @Taxes AS TABLE (
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
	,[ysnInvalidSetup]		BIT
	,[ysnAddToCost]			BIT
	,[strTaxGroup]			NVARCHAR(100)
	,[strNotes]				NVARCHAR(500)
	,[ysnBookToExemptionAccount] BIT
	,[ysnOverrideTaxGroup]	BIT
)

-- Clear the tax details 
DELETE	tblICInventoryReceiptItemTax 
FROM	tblICInventoryReceiptItemTax tax INNER JOIN tblICInventoryReceiptItem ri
			on tax.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
WHERE	ri.intInventoryReceiptId = @inventoryReceiptId

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
		,COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
		,TaxUOM.intUnitMeasureId
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			LEFT OUTER JOIN tblICItemUOM TaxUOM ON TaxUOM.intItemUOMId = COALESCE(ReceiptItem.intWeightUOMId, ReceiptItem.intUnitMeasureId)
WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId
		AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) <> @OWNERSHIP_TYPE_Storage -- Do not compute tax if item ownership is Storage. 
		AND ISNULL(ReceiptItem.intCostingMethod, 0) <> 6 -- Do not compute tax if stock is Category-Managed. 
		AND Receipt.strReceiptType <> 'Transfer Order' -- Do not compute tax for Transfer Orders. 

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
	,@TaxUOMId
	,@TaxUnitMeasureId

WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Clear the contents of the table variable.
	DELETE FROM @Taxes

	-- Get the taxes from uspICGetInventoryItemTaxes
	INSERT INTO @Taxes (
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
		,[ysnInvalidSetup]
		,[ysnAddToCost]
		,[strTaxGroup]
		,[strNotes]
		,[ysnBookToExemptionAccount]
		,[ysnOverrideTaxGroup]
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
		,@UOMId					= @TaxUOMId

	DECLARE	@Amount	NUMERIC(38,20) 
			,@Qty	NUMERIC(38,20)

	SELECT TOP 1
		@Amount = 				
			CASE 
				WHEN ReceiptItem.intWeightUOMId IS NOT NULL AND ReceiptItem.intComputeItemTotalOption = 0 THEN 
					dbo.fnCalculateCostBetweenUOM(
						COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId)
						, ReceiptItem.intWeightUOMId
						, CASE 
								WHEN ReceiptItem.ysnSubCurrency = 1 AND ISNULL(Receipt.intSubCurrencyCents, 0) <> 0 THEN 
									dbo.fnDivide(ReceiptItem.dblUnitCost, Receipt.intSubCurrencyCents) 
								ELSE
									ReceiptItem.dblUnitCost
                          END 
					) 
				ELSE 
					dbo.fnCalculateCostBetweenUOM(
						COALESCE(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId)
						, ReceiptItem.intUnitMeasureId
						, CASE 
								WHEN ReceiptItem.ysnSubCurrency = 1 AND ISNULL(Receipt.intSubCurrencyCents, 0) <> 0 THEN 
									dbo.fnDivide(ReceiptItem.dblUnitCost, Receipt.intSubCurrencyCents) 
								ELSE
									ReceiptItem.dblUnitCost
                          END 
					) 			
			END 	
		,@Qty	 = 
			CASE	
				WHEN ReceiptItem.intWeightUOMId IS NOT NULL AND ReceiptItem.intComputeItemTotalOption = 0 THEN 
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
		,[ysnTaxExempt]
		,[dblQty]
		,[dblCost]
		,[intUnitMeasureId]
		,[intSort]
		,[intConcurrencyId]				
	)
	SELECT 	[intInventoryReceiptItemId]		= @InventoryReceiptItemId
			,[intTaxGroupId]				= vendorTax.[intTaxGroupId]
			,[intTaxCodeId]					= vendorTax.[intTaxCodeId]
			,[intTaxClassId]				= vendorTax.[intTaxClassId]
			,[strTaxableByOtherTaxes]		= vendorTax.[strTaxableByOtherTaxes]
			,[strCalculationMethod]			= vendorTax.[strCalculationMethod]
			,[dblRate]						= vendorTax.[dblRate]
			,[dblTax]						=	CASE 
													WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
														vendorTax.[dblTax] 
													ELSE 
														CASE 
															WHEN ri.dblForexRate <> 0 THEN 
																ROUND(
																	dbo.fnDivide(
																		-- Convert the tax to the transaction currency. 
																		 vendorTax.[dblTax] 
																		, ri.dblForexRate
																	)
																, 2) 
															ELSE 
																vendorTax.[dblTax] 
														END 
												END 
			,[dblAdjustedTax]				= 
												CASE 
													WHEN vendorTax.[ysnTaxAdjusted] = 1THEN 
														vendorTax.[dblAdjustedTax]
													WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
														vendorTax.[dblTax] 
													ELSE 
														CASE 
															WHEN ri.dblForexRate <> 0 THEN 
																ROUND(
																	dbo.fnDivide(
																		-- Convert the tax to the transaction currency. 
																		 vendorTax.[dblTax] 
																		, ri.dblForexRate
																	)
																, 2) 
															ELSE 
																vendorTax.[dblTax] 
														END 
												END 

											--CASE 
											--	WHEN ri.dblForexRate <> 0 THEN 
											--		ROUND(
											--			dbo.fnDivide(
											--				-- Convert the tax to the transaction currency. 
											--					vendorTax.[dblAdjustedTax]
											--				, ri.dblForexRate
											--			)
											--		, 2) 
											--	ELSE 
											--		vendorTax.[dblAdjustedTax]
											--END
			,[intTaxAccountId]				= vendorTax.[intTaxAccountId]
			,[ysnTaxAdjusted]				= vendorTax.[ysnTaxAdjusted]
			,[ysnSeparateOnInvoice]			= vendorTax.[ysnSeparateOnInvoice]
			,[ysnCheckoffTax]				= vendorTax.[ysnCheckoffTax]
			,[strTaxCode]					= vendorTax.[strTaxCode]
			,[ysnTaxExempt]					= vendorTax.[ysnTaxExempt]
			,[dblQty]						= @Qty
			,[dblCost]						= @Amount
			,[intUnitMeasureId]				= @TaxUOMId
			,[intSort]						= 1
			,[intConcurrencyId]				= 1
	FROM	[dbo].[fnGetItemTaxComputationForVendor](@ItemId, @EntityId, @TransactionDate, @Amount, @Qty, @TaxGroupId, @LocationId, @ShipFromId, 1, 0, @FreightTermId,0,@TaxUOMId, NULL, NULL, NULL) vendorTax
			LEFT JOIN tblICInventoryReceiptItem ri 
				ON ri.intInventoryReceiptItemId = @InventoryReceiptItemId
								
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
		,@TaxUOMId
		,@TaxUnitMeasureId
END 

-- Calculate the tax per line item 
UPDATE	ReceiptItem 
SET		dblTax = ROUND(ISNULL(Taxes.dblTaxPerLineItem, 0) , 2) 
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

-- Calculate the Texas Loading Fee (Transport Load Only) 
BEGIN 

	DECLARE @ReceiptItems AS TABLE (
		  intInventoryReceiptId INT
		, intTaxGroupId INT
		, intTaxCodeId INT
		, dblQty NUMERIC(38, 20)
		, ysnGas BIT
		, dtmDate DATETIME
	)
	
	INSERT INTO @ReceiptItems (
		  intInventoryReceiptId
		, intTaxGroupId
		, intTaxCodeId
		, dblQty
		, ysnGas
		, dtmDate
	)
	SELECT 
		intInventoryReceiptId = Receipt.intInventoryReceiptId
		 , intTaxGroupId = TG.intTaxGroupId
		 , intTaxCodeId = TC.intTaxCodeId
		 , dblQty = 
				CASE	
					WHEN ReceiptItem.intWeightUOMId IS NOT NULL AND ReceiptItem.intComputeItemTotalOption = 0 THEN 
						ReceiptItem.dblNet 
					ELSE 
						ReceiptItem.dblOpenReceive 
				END 
		 , ysnGas = 
				CASE 
					WHEN Item.intCategoryId = TCR.intGasolineItemCategoryId THEN CAST(1 AS BIT) 
					ELSE CAST(0 AS BIT) 
				END
		, dtmDate = Receipt.dtmReceiptDate

	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			LEFT JOIN tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId
			LEFT JOIN dbo.tblICItemUOM ReceiveUOM 
				ON ReceiveUOM.intItemUOMId = ReceiptItem.intUnitMeasureId
			LEFT JOIN dbo.tblICItemUOM GrossNetUOM 
				ON GrossNetUOM.intItemUOMId = ReceiptItem.intWeightUOMId
			LEFT JOIN dbo.tblICItemUOM CostUOM
				ON CostUOM.intItemUOMId = ISNULL(ReceiptItem.intCostUOMId, ReceiptItem.intUnitMeasureId) 	
			LEFT JOIN tblSMTaxGroup TG 
				ON ReceiptItem.intTaxGroupId = TG.intTaxGroupId
			INNER JOIN tblSMTaxGroupCode TGC 
				ON TG.intTaxGroupId = TGC.intTaxGroupId
			INNER JOIN tblSMTaxCode TC 
				ON TGC.intTaxCodeId = TC.intTaxCodeId 
			CROSS APPLY (
				SELECT TOP 1 
					TCR.* 
				FROM tblSMTaxCodeRate TCR 
				WHERE 
					TCR.intTaxCodeId = TC.intTaxCodeId 
					AND TCR.dtmEffectiveDate <= Receipt.dtmReceiptDate
				ORDER BY
					TCR.dtmEffectiveDate
			) TCR

	WHERE	Receipt.intInventoryReceiptId = @inventoryReceiptId
			AND TC.ysnTexasLoadingFee = 1
			AND Receipt.intSourceType = @SourceType_TRANSPORT

	IF EXISTS (SELECT TOP 1 1 FROM @ReceiptItems)
	BEGIN
		DELETE ReceiptTax
		FROM tblICInventoryReceiptTax ReceiptTax
		WHERE ReceiptTax.intInventoryReceiptId = @inventoryReceiptId

		INSERT INTO tblICInventoryReceiptTax (
			[intInventoryReceiptId]
			,[intTaxGroupId]
			,[intTaxCodeId]
			,[intTaxClassId]
			,[strTaxableByOtherTaxes]
			,[strCalculationMethod]
			,[dblTax]
			,[dblAdjustedTax]
			,[intTaxAccountId]
			,[strTaxCode]
			,[dblQty]
			,[intConcurrencyId]
		)
		SELECT 
			[intInventoryReceiptId] = RI.intInventoryReceiptId
			,[intTaxGroupId] = RI.intTaxGroupId
			,[intTaxCodeId] = RI.intTaxCodeId
			,[intTaxClassId] = TC.intTaxClassId 
			,[strTaxableByOtherTaxes] = TC.strTaxableByOtherTaxes
			,[strCalculationMethod] = TCR.strCalculationMethod
			,[dblTax] = dbo.[fnCalculateTexasFee](RI.intTaxCodeId, RI.dtmDate, RI.dblQty, RI.dblQtyGas) --CASE WHEN ysnGas = 1 THEN RI.dblQty ELSE 0 END)
			,[dblAdjustedTax] = dbo.[fnCalculateTexasFee](RI.intTaxCodeId, RI.dtmDate, RI.dblQty, RI.dblQtyGas) --CASE WHEN ysnGas = 1 THEN RI.dblQty ELSE 0 END)
			,[intTaxAccountId] = TC.intPurchaseTaxAccountId
			,[strTaxCode] = TC.strTaxCode
			,[dblQty] = RI.dblQty
			,[intConcurrencyId] = 1
		FROM (
				SELECT 
					RI.intInventoryReceiptId
					, RI.intTaxCodeId			
					, RI.intTaxGroupId
					, RI.dtmDate					
					--, RI.ysnGas
					, dblQty = SUM(ISNULL(RI.dblQty, 0)) 
					, dblQtyGas = SUM(CASE WHEN RI.ysnGas = 1 THEN ISNULL(RI.dblQty, 0) ELSE 0 END) 					
				FROM 
					@ReceiptItems RI
				GROUP BY
					RI.intInventoryReceiptId
					, RI.intTaxCodeId			
					, RI.intTaxGroupId
					, RI.dtmDate
					--, RI.ysnGas
			) RI
			INNER JOIN tblICInventoryReceipt R 
				ON R.intInventoryReceiptId = RI.intInventoryReceiptId			
			INNER JOIN tblSMTaxCode TC 
				ON RI.intTaxCodeId = TC.intTaxCodeId 			
			--INNER JOIN tblSMTaxCodeRate TCR 
			--	ON TCR.intTaxCodeId = TC.intTaxCodeId 
			CROSS APPLY (
				SELECT TOP 1 
					TCR.* 
				FROM tblSMTaxCodeRate TCR 
				WHERE 
					TCR.intTaxCodeId = TC.intTaxCodeId 
					AND TCR.dtmEffectiveDate <= R.dtmReceiptDate
				ORDER BY
					TCR.dtmEffectiveDate
			) TCR
	END

END 

_EXIT: 

CLOSE loopReceiptItems;
DEALLOCATE loopReceiptItems;
