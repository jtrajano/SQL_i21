CREATE PROCEDURE [dbo].[uspSMGetItemTaxes]
	 @ItemId					INT
	,@LocationId			INT
	,@TransactionDate		DATETIME
	,@TransactionType		NVARCHAR(20) -- Purchase/Sale
	,@EntityId				INT			= NULL
	,@TaxMasterId			INT			= NULL
	,@BillShipToLocationId	INT			= NULL
AS

BEGIN

	IF ISNULL(@TaxMasterId,0) = 0
		BEGIN				
			IF (@TransactionType = 'Sale')
				SELECT @TaxMasterId = [dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @LocationId, @ItemId, @BillShipToLocationId)
			ELSE
				SELECT @TaxMasterId = [dbo].[fnGetTaxGroupIdForVendor](@EntityId, @LocationId, @ItemId, @BillShipToLocationId)
		END
			
				
	IF (@TransactionType = 'Sale')
		BEGIN
			SELECT
				 [intTransactionDetailTaxId]
				,[intTransactionDetailId]		AS [intInvoiceDetailId]
				,NULL							AS [intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[numRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]				AS [intSalesTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[strTaxGroup]
				,[strNotes]
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxMasterId, @EntityId, @TransactionDate, @ItemId, @BillShipToLocationId)
					
			RETURN 1
		END
	ELSE
		BEGIN
			SELECT
				 [intTransactionDetailTaxId]
				,[intTransactionDetailId]		AS [intInvoiceDetailId]
				,NULL							AS [intTaxGroupMasterId]
				,[intTaxGroupId]
				,[intTaxCodeId]
				,[intTaxClassId]
				,[strTaxableByOtherTaxes]
				,[strCalculationMethod]
				,[numRate]
				,[dblTax]
				,[dblAdjustedTax]
				,[intTaxAccountId]
				,[ysnSeparateOnInvoice]
				,[ysnCheckoffTax]
				,[strTaxCode]
				,[ysnTaxExempt]
				,[strTaxGroup]
				,[strNotes]
			FROM
				[dbo].[fnGetTaxGroupTaxCodesForVendor](@TaxMasterId, @EntityId, @TransactionDate, @ItemId, @BillShipToLocationId)
					
			RETURN 1
		END
				
	RETURN 0
END