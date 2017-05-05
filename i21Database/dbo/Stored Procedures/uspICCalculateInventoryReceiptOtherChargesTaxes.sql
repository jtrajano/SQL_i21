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
			DECLARE loopReceiptChargeItems CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  Charge.intChargeId
					,Receipt.intLocationId
					,Receipt.dtmReceiptDate
					,ISNULL(Charge.intEntityVendorId, Receipt.intEntityVendorId)
					,Charge.intInventoryReceiptChargeId
					,Receipt.intShipFromId
					,ISNULL(Charge.intTaxGroupId, Receipt.intTaxGroupId)
					,Receipt.intFreightTermId 
			FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge
						ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
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
						 @Amount = Charge.dblAmount
						,@Qty	 = 1
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge
							ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
						AND Charge.intInventoryReceiptChargeId = @InventoryReceiptChargeId

				-- Compute Taxes
				-- Insert the data from the table variable into Inventory Receipt Item tax table. 
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
					,[intSort]
					,[intConcurrencyId]				
				)
				SELECT 	[intInventoryReceiptChargeId]	= @InventoryReceiptChargeId
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
						,[ysnCheckoffTax]				= [ysnCheckoffTax]
						,[strTaxCode]					= [strTaxCode]
						,[intSort]						= 1
						,[intConcurrencyId]				= 1
				FROM	[dbo].[fnGetItemTaxComputationForVendor](@ItemId, @EntityId, @TransactionDate, @Amount, @Qty, @TaxGroupId, @LocationId, @ShipFromId, 0, @FreightTermId, 0)

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
			END 

			CLOSE loopReceiptChargeItems;
			DEALLOCATE loopReceiptChargeItems;
		END 

		-- Calculate the tax per line item 
		UPDATE	Charge 
		SET		dblTax = CASE 
							-- Negate Tax if Other Charge is marked as Price Down
							WHEN Charge.ysnPrice = 1 
								THEN -(ROUND(dbo.fnDivide(ISNULL(Taxes.dblTaxPerLineItem, 0) ,ISNULL(Receipt.intSubCurrencyCents, 1)), 2))
							ELSE
								ROUND(dbo.fnDivide(ISNULL(Taxes.dblTaxPerLineItem, 0) ,ISNULL(Receipt.intSubCurrencyCents, 1)), 2) 
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