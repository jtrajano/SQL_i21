﻿CREATE PROCEDURE [dbo].[uspSMGetItemTaxes]
	 @ItemId				INT
	,@LocationId			INT
	,@TransactionDate		DATETIME
	,@TransactionType		NVARCHAR(20) -- Purchase/Sale
	,@EntityId				INT				= NULL
	,@TaxGroupId			INT				= NULL
	,@BillShipToLocationId	INT				= NULL
	,@IncludeExemptedCodes	BIT				= NULL
	,@SiteId				INT				= NULL
	,@FOBPoint				NVARCHAR(150)	= NULL
AS

BEGIN

	IF LOWER(RTRIM(LTRIM(ISNULL(@FOBPoint,'')))) <> 'origin'
		SET @BillShipToLocationId = NULL

	IF ISNULL(@TaxGroupId,0) = 0
		BEGIN				
			IF (@TransactionType = 'Sale')
				SELECT @TaxGroupId = [dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @LocationId, @ItemId, @BillShipToLocationId, @SiteId)
			ELSE
				SELECT @TaxGroupId = [dbo].[fnGetTaxGroupIdForVendor](@EntityId, @LocationId, @ItemId, @BillShipToLocationId)
		END
			
				
	IF (@TransactionType = 'Sale')
		BEGIN
			SELECT
				 [intTransactionDetailTaxId]
				,[intTransactionDetailId]		AS [intTransactionDetailId]
				--,NULL							AS [intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]				AS [intSalesTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @EntityId, @TransactionDate, @ItemId, @BillShipToLocationId, @IncludeExemptedCodes, NULL)
					
			RETURN 1
		END
	ELSE
		BEGIN
			SELECT
				 [intTransactionDetailTaxId]
				,[intTransactionDetailId]		AS [intTransactionDetailId]
				--,NULL							AS [intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[dblRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[ysnInvalidSetup]
				,[strTaxGroup]
				,[strNotes]
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForVendor](@TaxGroupId, @EntityId, @TransactionDate, @ItemId, @BillShipToLocationId, @IncludeExemptedCodes)
					
			RETURN 1
		END
				
	RETURN 0
END