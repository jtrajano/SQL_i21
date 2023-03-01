﻿CREATE PROCEDURE [dbo].[uspICCalculateInventoryReceiptOtherChargesTaxes]
	@intInventoryReceiptId AS INT 
	,@ysnNewVendorId AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN
	-- Add taxes into the receipt other charges
	BEGIN
		DECLARE	@ItemId				INT
				,@LocationId		INT
				,@TransactionDate	DATETIME
				,@TransactionType	NVARCHAR(40) = 'Purchase' -- "Purchase" is used for Receipt while "Sale" for Shipment
				,@EntityId			INT	
				,@TaxMasterId		INT	
				,@InventoryReceiptChargeId INT
				,@ShipFromId		INT 
				,@TaxGroupId		INT
				,@FreightTermId		INT
				,@TaxUOMId			INT
				,@TaxUnitMeasureId	INT
				,@ReceiptDate		DATETIME 
				,@NewVendorEntityId	INT	

		DECLARE @Taxes AS TABLE (
			--id						INT
			--,intInvoiceDetailId		INT
			intTransactionDetailTaxId	INT
			,intTransactionDetailId	INT
			,intTaxGroupId			INT 
			,intTaxCodeId			INT
			,intTaxClassId			INT
			,strTaxableByOtherTaxes NVARCHAR (MAX) COLLATE Latin1_General_CI_AS
			,strCalculationMethod	NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,dblRate				NUMERIC(18,6)
			,dblBaseRate			NUMERIC(18,6)
			,dblTax					NUMERIC(18,6)
			,dblAdjustedTax			NUMERIC(18,6)
			,intTaxAccountId		INT
			,ysnSeparateOnInvoice	BIT
			,ysnCheckoffTax			BIT
			,strTaxCode				NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,ysnTaxExempt			BIT
			,[ysnTaxOnly]			BIT
			,[ysnInvalidSetup]		BIT
			,[ysnAddToCost]			BIT
			,[strTaxGroup]			NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,[strNotes]				NVARCHAR(500) COLLATE Latin1_General_CI_AS
			,[ysnBookToExemptionAccount] BIT
			,[ysnOverrideTaxGroup]	BIT
		)

		DECLARE @ChargeTaxes AS TABLE (
			[intInventoryReceiptChargeId] INT 
			,[intTaxGroupId] INT 
			,[intTaxCodeId] INT 
			,[intTaxClassId] INT 
			,[strTaxableByOtherTaxes] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS
			,[strCalculationMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,[dblRate] NUMERIC(18,6)
			,[dblTax] NUMERIC(18,6)
			,[dblAdjustedTax] NUMERIC(18,6)
			,[intTaxAccountId] INT
			,[ysnTaxAdjusted] BIT
			,[ysnCheckoffTax] BIT
			,[strTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,[dblQty] NUMERIC(18,6)
			,[dblCost] NUMERIC(18,6)
			,[intUnitMeasureId] INT
			,[intSort] INT
			,[intConcurrencyId]	INT 
		)

		-- If there is a new vendor, update the other charge tax group
		IF @ysnNewVendorId = 1 
		BEGIN 
			UPDATE rc
			SET
				rc.intNewTaxGroupId = taxHierarcy.intTaxGroupId
			FROM 
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
					ON r.intInventoryReceiptId = rc.intInventoryReceiptId
				-- Get the default tax group (if override was not provided)
				OUTER APPLY (
					SELECT	taxGroup.intTaxGroupId, taxGroup.strTaxGroup
					FROM	tblSMTaxGroup taxGroup
					WHERE	taxGroup.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor (
								rc.intNewEntityVendorId	-- @VendorId
								,r.intLocationId	--,@CompanyLocationId
								,NULL							--,@ItemId
								,r.intShipFromId				--,@VendorLocationId
								,NULL							--,@FreightTermId -- NOTE: There is no freight terms for Other Charges. 
								,DEFAULT						--,@FOB
							)
				) taxHierarcy 
			WHERE
				rc.intInventoryReceiptId = @intInventoryReceiptId
				AND rc.intNewEntityVendorId IS NOT NULL 
		END 

		-- Create the cursor
		DECLARE loopReceiptChargeItems CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  Charge.intChargeId
				,Receipt.intLocationId
				,Receipt.dtmReceiptDate
				,COALESCE(Charge.intNewEntityVendorId, Charge.intEntityVendorId, Receipt.intEntityVendorId)
				,Charge.intInventoryReceiptChargeId
				,Receipt.intShipFromId
				,intTaxGroupId = ISNULL(Charge.intNewTaxGroupId, Charge.intTaxGroupId)
				,Receipt.intFreightTermId
				,Charge.intCostUOMId 
				,CostUOM.intUnitMeasureId
				,Receipt.dtmReceiptDate
				,Charge.intNewEntityVendorId 
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
			,@ReceiptDate
			,@NewVendorEntityId

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
			DELETE FROM @ChargeTaxes
			INSERT INTO @ChargeTaxes (
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

			IF (@ysnNewVendorId = 0) 
			BEGIN 
				-- Clear the records in tblICInventoryReceiptChargeTax
				DELETE FROM tblICInventoryReceiptChargeTax 
				WHERE 
					intInventoryReceiptChargeId = @InventoryReceiptChargeId

				-- Insert into the other charge taxes
				INSERT INTO tblICInventoryReceiptChargeTax (
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
				SELECT 
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
				FROM 
					@ChargeTaxes
			END 

			-- Compare the original tax from the original vendor versus the new tax for the new vendor. 
			-- Check the fiscal year period. If open, continue. Otherwise, keep the tax amounts the same. 
			-- If there is a difference, reverse the existing taxes and insert a new one. 
			ELSE IF 
				@NewVendorEntityId IS NOT NULL AND @ysnNewVendorId = 1
				AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@ReceiptDate) = 1)
				AND EXISTS (					
					SELECT TOP 1 1						 
					FROM
						(
							SELECT 						
								intTaxGroupId
								,intTaxCodeId
								,intTaxClassId
								,intTaxAccountId
								,ysnTaxAdjusted
								,ysnCheckoffTax 
								,dblTax = SUM(dblTax)
								,dblAdjustedTax = SUM(dblAdjustedTax)
							FROM 
								@ChargeTaxes 
							GROUP BY
								intTaxGroupId
								,intTaxCodeId
								,intTaxClassId
								,intTaxAccountId
								,ysnTaxAdjusted
								,ysnCheckoffTax 				
						) newTax 
						FULL OUTER JOIN (
							SELECT 						
								intTaxGroupId
								,intTaxCodeId
								,intTaxClassId
								,intTaxAccountId
								,ysnTaxAdjusted
								,ysnCheckoffTax 
								,dblTax = SUM(dblTax)
								,dblAdjustedTax = SUM(dblAdjustedTax)
							FROM 
								tblICInventoryReceiptChargeTax
							WHERE
								intInventoryReceiptChargeId = @InventoryReceiptChargeId
								AND (ysnReversed = 0 OR ysnReversed IS NULL)
							GROUP BY
								intTaxGroupId
								,intTaxCodeId
								,intTaxClassId
								,intTaxAccountId
								,ysnTaxAdjusted
								,ysnCheckoffTax 				
						) oldTax 
							ON newTax.intTaxGroupId = oldTax.intTaxGroupId
							AND newTax.intTaxCodeId = oldTax.intTaxCodeId
							AND newTax.intTaxClassId = oldTax.intTaxClassId
							AND newTax.intTaxAccountId = oldTax.intTaxAccountId
							AND newTax.ysnTaxAdjusted = oldTax.ysnTaxAdjusted
							AND newTax.ysnCheckoffTax = oldTax.ysnCheckoffTax
					WHERE
						(newTax.intTaxCodeId IS NULL OR oldTax.intTaxCodeId IS NULL) 
						OR (
							newTax.intTaxCodeId = oldTax.intTaxCodeId
							AND (
								newTax.intTaxAccountId <> oldTax.intTaxAccountId
								OR newTax.intTaxAccountId IS NULL 
								OR oldTax.intTaxAccountId IS NULL
							)
						)
						OR (
							newTax.intTaxCodeId = oldTax.intTaxCodeId
							AND newTax.intTaxAccountId = oldTax.intTaxAccountId
							AND ISNULL(newTax.dblTax, 0) <> ISNULL(oldTax.dblTax, 0)
						)
						OR (
							newTax.intTaxCodeId = oldTax.intTaxCodeId
							AND newTax.intTaxAccountId = oldTax.intTaxAccountId
							AND ISNULL(newTax.dblAdjustedTax, 0) <> ISNULL(oldTax.dblAdjustedTax, 0)
						)
				)
			BEGIN 
				DECLARE @maxInventoryReceiptChargeTaxId AS INT 

				SELECT @maxInventoryReceiptChargeTaxId = MAX(intInventoryReceiptChargeTaxId)
				FROM  tblICInventoryReceiptChargeTax rcTax
				WHERE rcTax.intInventoryReceiptChargeId = @InventoryReceiptChargeId

				-- Reverse the existing tax amounts. 
				INSERT INTO tblICInventoryReceiptChargeTax (
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
					,[intReverseInventoryReceiptChargeTaxId] 
				)
				SELECT
					[intInventoryReceiptChargeId]
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[dblRate]
					,-[dblTax]
					,-[dblAdjustedTax]
					,[intTaxAccountId]
					,[ysnTaxAdjusted]
					,[ysnCheckoffTax]
					,[strTaxCode]
					,[dblQty]
					,[dblCost]
					,[intUnitMeasureId]
					,[intSort]
					,[intConcurrencyId]	
					,[intInventoryReceiptChargeTaxId] 
				FROM
					tblICInventoryReceiptChargeTax
				WHERE
					intInventoryReceiptChargeId = @InventoryReceiptChargeId
					AND ([ysnReversed] = 0 OR [ysnReversed] IS NULL)

				-- Flag the existing 
				UPDATE tblICInventoryReceiptChargeTax
				SET 
					ysnReversed = 1
					,intConcurrencyId += 1 
				WHERE 
					intInventoryReceiptChargeId = @InventoryReceiptChargeId
					AND ([ysnReversed] = 0 OR [ysnReversed] IS NULL)
					AND intInventoryReceiptChargeTaxId <= @maxInventoryReceiptChargeTaxId

				-- Insert the new taxes.
				INSERT INTO tblICInventoryReceiptChargeTax (
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
				SELECT 
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
				FROM 
					@ChargeTaxes
			END 

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
				,@ReceiptDate
				,@NewVendorEntityId
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
			AND @ysnNewVendorId = 0 

	-- Update the AP Clearing with a new Vendor. 
	IF @ysnNewVendorId = 1
	BEGIN 
		-- Update tblAPVoucherPayable
		UPDATE ap
		SET
			ap.intEntityVendorId = rc.intEntityVendorId			
			,ap.strVendorId = v.strVendorId
			,ap.strName = v.strName
			,ap.dblTax = rc.dblTax
		FROM 
			tblICInventoryReceiptCharge rc INNER JOIN tblAPVoucherPayable ap
				ON rc.intInventoryReceiptChargeId = ap.intInventoryReceiptChargeId
			LEFT JOIN vyuAPVendor v
				ON v.[intEntityId] = rc.intEntityVendorId
		WHERE
			rc.intInventoryReceiptId = @intInventoryReceiptId
			AND rc.intNewEntityVendorId IS NOT NULL 

		-- Delete tblAPVoucherPayableTaxStaging
		DELETE apTax
		FROM 
			tblICInventoryReceiptCharge rc INNER JOIN tblAPVoucherPayable ap
				ON rc.intInventoryReceiptChargeId = ap.intInventoryReceiptChargeId
			INNER JOIN tblAPVoucherPayableTaxStaging apTax
				ON apTax.intVoucherPayableId = ap.intVoucherPayableId
		WHERE
			rc.intInventoryReceiptId = @intInventoryReceiptId
			AND rc.intNewEntityVendorId IS NOT NULL 

		-- Re-insert the new records for tblAPVoucherPayableTaxStaging 
		INSERT INTO tblAPVoucherPayableTaxStaging (
			[intVoucherPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]
			,[ysnTaxOnly]	
			,[ysnTaxExempt]
		)
		SELECT 
			[intVoucherPayableId] = ap.intVoucherPayableId	
			,[intTaxGroupId] = rcTax.intTaxGroupId
			,[intTaxCodeId]	= rcTax.intTaxCodeId
			,[intTaxClassId] = rcTax.intTaxClassId
			,[strTaxableByOtherTaxes] = rcTax.strTaxableByOtherTaxes
			,[strCalculationMethod] = rcTax.strCalculationMethod
			,[dblRate] = rcTax.dblRate
			,[intAccountId] = rcTax.intTaxAccountId
			,[dblTax] = rcTax.dblTax
			,[dblAdjustedTax] = rcTax.dblAdjustedTax
			,[ysnTaxAdjusted] = rcTax.ysnTaxAdjusted
			,[ysnSeparateOnBill] = 0
			,[ysnCheckOffTax] = rcTax.ysnCheckoffTax
			,[ysnTaxOnly] = rcTax.ysnTaxOnly
			,[ysnTaxExempt] = rcTax.ysnTaxExempt
		FROM 
			tblICInventoryReceiptCharge rc INNER JOIN tblAPVoucherPayable ap
				ON rc.intInventoryReceiptChargeId = ap.intInventoryReceiptChargeId
			INNER JOIN tblICInventoryReceiptChargeTax rcTax
				ON rcTax.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
			INNER JOIN tblSMTaxCode taxCode
				ON taxCode.intTaxCodeId = rcTax.intTaxCodeId
		WHERE
			rc.intInventoryReceiptId = @intInventoryReceiptId
			AND rc.intNewEntityVendorId IS NOT NULL 
	END 

	-- Update Other Charge Vendor 
	IF @ysnNewVendorId = 1
	BEGIN 
		UPDATE tblICInventoryReceipt
		SET ysnNewOtherChargeVendor = 0 
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		UPDATE tblICInventoryReceiptCharge 
		SET intEntityVendorId = intNewEntityVendorId
			,intNewEntityVendorId = NULL 
			,intTaxGroupId = ISNULL(intNewTaxGroupId, intTaxGroupId) 
			,intNewTaxGroupId = NULL 
		WHERE 
			intInventoryReceiptId = @intInventoryReceiptId
			AND intNewEntityVendorId IS NOT NULL 
	END 
END
