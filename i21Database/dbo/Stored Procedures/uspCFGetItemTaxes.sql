CREATE PROCEDURE [dbo].[uspCFGetItemTaxes]    
	 @intNetworkId					INT
	,@intARItemId					INT
	,@intARItemLocationId			INT
	,@intCustomerId					INT
	,@intCustomerLocationId			INT
	,@dtmTransactionDate			DATETIME
	,@TaxState						NVARCHAR(MAX)
	,@strTaxCodeId					NVARCHAR(MAX)	= ''
	,@FET							NUMERIC(18,6)	= 0.000000
	,@SET							NUMERIC(18,6)	= 0.000000
	,@SST							NUMERIC(18,6)	= 0.000000
	,@LC1							NUMERIC(18,6)	= 0.000000
	,@LC2							NUMERIC(18,6)	= 0.000000
	,@LC3							NUMERIC(18,6)	= 0.000000
	,@LC4							NUMERIC(18,6)	= 0.000000
	,@LC5							NUMERIC(18,6)	= 0.000000
	,@LC6							NUMERIC(18,6)	= 0.000000
	,@LC7							NUMERIC(18,6)	= 0.000000
	,@LC8							NUMERIC(18,6)	= 0.000000
	,@LC9							NUMERIC(18,6)	= 0.000000
	,@LC10							NUMERIC(18,6)	= 0.000000
	,@LC11							NUMERIC(18,6)	= 0.000000
	,@LC12							NUMERIC(18,6)	= 0.000000
AS    
		
SELECT
	 [intTransactionDetailTaxId]
	,[intTransactionDetailId]  AS [intInvoiceDetailId]
	,NULL
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblTax]
	,[dblAdjustedTax]
	,[intTaxAccountId]    AS [intSalesTaxAccountId]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[strTaxCode]
	,[ysnTaxExempt]
	,[strTaxGroup]
	,[ysnInvalid]
	,[strReason]
	,[strTaxExemptReason]
FROM
	[dbo].[fnCFRemoteTaxes](
	@TaxState		
	,@strTaxCodeId
	,@FET	
	,@SET	
	,@SST	
	,@LC1	
	,@LC2	
	,@LC3	
	,@LC4		
	,@LC5		
	,@LC6		
	,@LC7		
	,@LC8		
	,@LC9		
	,@LC10			
	,@LC11			
	,@LC12			
	,@intNetworkId
	,@intARItemId				
	,@intARItemLocationId			
	,@intCustomerId				
	,@intCustomerLocationId		
	,@dtmTransactionDate)


	RETURN