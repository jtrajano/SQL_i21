CREATE PROCEDURE [dbo].[uspICCalculateInventoryReceiptOtherChargesTaxes]
	@intInventoryReceiptId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
		-- Add taxes into the receipt. 
		BEGIN
			DECLARE	@ItemId				INT
					,@LocationId		INT
					,@TransactionDate	DATETIME
					,@TransactionType	NVARCHAR(20) = 'Purchase' -- "Purchase" is used for Receipt while "Sale" for Shipment
					,@EntityId			INT	
					,@TaxMasterId		INT	
					,@InventoryReceiptChargeId INT
					,@ShipFromId		INT 
					,@TaxGroupId		INT
					,@FreightTermId		INT
					,@TaxUOMId			INT
					,@TaxUnitMeasureId INT

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
				,[ysnInvalidSetup]		BIT
				,[ysnAddToCost]			BIT
				,[strTaxGroup]			NVARCHAR(100)
				,[strNotes]				NVARCHAR(500)
				,[ysnBookToExemptionAccount] BIT
			)

			-- Create the cursor
			DECLARE loopReceiptChargeItems CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  Charge.intChargeId
					,Receipt.intLocationId
					,Receipt.dtmReceiptDate
					,ISNULL(Charge.intEntityVendorId, Receipt.intEntityVendorId)
					,Charge.intInventoryReceiptChargeId
					,Receipt.intShipFromId
					,Charge.intTaxGroupId --,ISNULL(Charge.intTaxGroupId, Receipt.intTaxGroupId)
					,Receipt.intFreightTermId
					,Charge.intCostUOMId 
					,CostUOM.intUnitMeasureId
			FROM dbo.tblICInventoryReceipt Receipt 
				INNER JOIN dbo.tblICInventoryReceiptCharge Charge ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
				LEFT OUTER JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = Charge.intCostUOMId
			WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId

			OPEN loopReceiptChargeItems;

			-- Initial fetch attempt
			FETCH NEXT FROM loopReceiptChargeItems INTO 
				@ItemId
				,@LocationId
				,@TransactionDate
				,@EntityId
				,@InventoryReceiptChargeId
				,@ShipFromId
				,@TaxGroupId
				,@FreightTermId
				,@TaxUOMId
				,@TaxUnitMeasureId

			WHILE @@FETCH_STATUS = 0
			BEGIN 
				-- Clear the records in tblICInventoryReceiptChargeTax
				DELETE FROM tblICInventoryReceiptChargeTax WHERE intInventoryReceiptChargeId = @InventoryReceiptChargeId

				-- Clear the contents of the table variable.
				DELETE FROM @Taxes

				-- Get the taxes from uspICGetInventoryItemTaxes
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
					,[ysnInvalidSetup]
					,[ysnAddToCost]
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
					,@UOMId					= @TaxUOMId

				-- Fields used in the calculation of the taxes
				DECLARE	@Amount	NUMERIC(38,20) 
						,@Qty	NUMERIC(38,20)
						,@Cost	NUMERIC(18,6) 
				
				-- Get the taxable amount and qty from the charges. 
				SELECT TOP 1
						-- Note: Do not compute tax if it can't be converted to voucher. Zero out the amount and Qty so that tax will be zero too. 
						-- Charges with Accrue = false and Price = false does not create vouchers. 
						 @Amount = 
							CASE 
								WHEN ISNULL(Charge.ysnAccrue, 0) = 1 THEN Charge.dblAmount 
								WHEN ISNULL(Charge.ysnPrice, 0) = 1 THEN -Charge.dblAmount 
								ELSE 0 
							END 
						,@Qty	 = CASE WHEN ISNULL(Charge.ysnAccrue, 0) = 1 OR ISNULL(Charge.ysnPrice, 0) = 1 THEN ISNULL(Charge.dblQuantity, 1) ELSE 0 END 
						,@Cost   = CASE WHEN ISNULL(Charge.ysnAccrue, 0) = 1 OR ISNULL(Charge.ysnPrice, 0) = 1 THEN dbo.fnDivide(Charge.dblAmount, Charge.dblQuantity) ELSE 0 END 
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge
							ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
						AND Charge.intInventoryReceiptChargeId = @InventoryReceiptChargeId

				-- Compute Taxes
				-- Insert the data from the table variable into Inventory Receipt Charge tax table. 
				INSERT INTO dbo.tblICInventoryReceiptChargeTax(
					[intInventoryReceiptChargeId]
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
					,[ysnCheckoffTax]
					,[strTaxCode]
					,[dblQty]
					,[dblCost]
					,[intUnitMeasureId]
					,[intSort]
					,[intConcurrencyId]				
				)
				SELECT 	[intInventoryReceiptChargeId]	= @InventoryReceiptChargeId
						,[intTaxGroupId]				= vendorTax.[intTaxGroupId]
						,[intTaxCodeId]					= vendorTax.[intTaxCodeId]
						,[intTaxClassId]				= vendorTax.[intTaxClassId]
						,[strTaxableByOtherTaxes]		= vendorTax.[strTaxableByOtherTaxes]
						,[strCalculationMethod]			= vendorTax.[strCalculationMethod]
						,[dblRate]						= vendorTax.[dblRate]
						,[dblTax]						=	CASE 
																WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN vendorTax.[dblTax] 
																ELSE 
																	CASE 
																		WHEN rc.dblForexRate <> 0 THEN 
																			ROUND(
																				dbo.fnDivide(
																					-- Convert the tax to the transaction currency. 
																					 vendorTax.[dblTax] 
																					, rc.dblForexRate
																				)
																			, 2) 
																		ELSE 
																			vendorTax.[dblTax] 
																	END 
															END 

						,[dblAdjustedTax]				=
															CASE 
																WHEN vendorTax.[ysnTaxAdjusted] = 1 THEN 
																	vendorTax.[dblAdjustedTax]
																WHEN vendorTax.[strCalculationMethod] = 'Percentage' THEN 
																	vendorTax.[dblTax] 
																ELSE 
																	CASE 
																		WHEN rc.dblForexRate <> 0 THEN 
																			ROUND(
																				dbo.fnDivide(
																					-- Convert the tax to the transaction currency. 
																					 vendorTax.[dblTax] 
																					, rc.dblForexRate
																				)
																			, 2) 
																		ELSE 
																			vendorTax.[dblTax] 
																	END 
															END 						
						 
														--CASE 
														--	WHEN rc.dblForexRate <> 0 THEN 
														--		ROUND(
														--			dbo.fnDivide(
														--				-- Convert the tax to the transaction currency. 
														--					vendorTax.[dblAdjustedTax]
														--				, rc.dblForexRate
														--			)
														--		, 2) 
														--	ELSE 
														--		vendorTax.[dblAdjustedTax]
														--END 

						,[intTaxAccountId]				= vendorTax.[intTaxAccountId]
						,[ysnTaxAdjusted]				= vendorTax.[ysnTaxAdjusted]
						,[ysnCheckoffTax]				= vendorTax.[ysnCheckoffTax]
						,[strTaxCode]					= vendorTax.[strTaxCode]
						,[dblQty]						= @Qty
						,[dblCost]						= @Cost
						,[intUnitMeasureId]				= @TaxUOMId
						,[intSort]						= 1
						,[intConcurrencyId]				= 1
				FROM	[dbo].[fnGetItemTaxComputationForVendor](@ItemId, @EntityId, @TransactionDate, @Cost, @Qty, @TaxGroupId, @LocationId, @ShipFromId, 0, 0, @FreightTermId, 0, @TaxUOMId, NULL, NULL, NULL) vendorTax
						LEFT JOIN tblICInventoryReceiptCharge rc 
							ON rc.intInventoryReceiptChargeId = @InventoryReceiptChargeId

				--Get the next item. 
				FETCH NEXT FROM loopReceiptChargeItems INTO 
					@ItemId
					,@LocationId
					,@TransactionDate
					,@EntityId
					,@InventoryReceiptChargeId
					,@ShipFromId
					,@TaxGroupId
					,@FreightTermId
					,@TaxUOMId
					,@TaxUnitMeasureId
			END 

			CLOSE loopReceiptChargeItems;
			DEALLOCATE loopReceiptChargeItems;
		END 

		-- Calculate the tax per line item 
		UPDATE	Charge 
		SET		dblTax = 
					CASE WHEN Charge.ysnSubCurrency = 1 THEN 
						ROUND(dbo.fnDivide(ISNULL(Taxes.dblTaxPerLineItem, 0) ,ISNULL(Receipt.intSubCurrencyCents, 1)), 2)  					
					ELSE 
						ROUND(ISNULL(Taxes.dblTaxPerLineItem, 0), 2)  					
					END 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge
						ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
				LEFT JOIN (
					SELECT	dblTaxPerLineItem = SUM(ChargeTax.dblTax) 
							,ChargeTax.intInventoryReceiptChargeId
					FROM	dbo.tblICInventoryReceiptChargeTax ChargeTax INNER JOIN dbo.tblICInventoryReceiptCharge Charge
								ON ChargeTax.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId
					WHERE	Charge.intInventoryReceiptId = @intInventoryReceiptId
					GROUP BY ChargeTax.intInventoryReceiptChargeId
				) Taxes
					ON Charge.intInventoryReceiptChargeId = Taxes.intInventoryReceiptChargeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
END