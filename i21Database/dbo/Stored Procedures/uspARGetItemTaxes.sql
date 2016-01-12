CREATE PROCEDURE [dbo].[uspARGetItemTaxes]
	 @ItemId				INT			= NULL
	,@LocationId			INT
	,@CustomerId			INT			= NULL	
	,@CustomerLocationId	INT			= NULL	
	,@TransactionDate		DATETIME
	,@TaxGroupId			INT			= NULL		
	,@SiteId				INT			= NULL
AS


	IF(ISNULL(@TaxGroupId,0) = 0)
		SELECT @TaxGroupId = [dbo].[fnGetTaxGroupIdForCustomer](@CustomerId, @LocationId, @ItemId, @CustomerLocationId, @SiteId)			
	
	IF @TaxGroupId IS NOT NULL AND @TaxGroupId <> 0
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
				[dbo].[fnGetTaxGroupTaxCodesForCustomer](@TaxGroupId, @CustomerId, @TransactionDate, @ItemId, @CustomerLocationId, 1, NULL)
				
			RETURN 1
		END
							
	RETURN 0
