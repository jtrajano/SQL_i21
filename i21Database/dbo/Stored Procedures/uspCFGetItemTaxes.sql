CREATE PROCEDURE [dbo].[uspCFGetItemTaxes]    
	 @intNetworkId					INT
	,@intARItemId					INT
	,@intARItemLocationId			INT
	,@intCustomerId					INT
	,@intCustomerLocationId			INT
	,@dtmTransactionDate			DATETIME
	,@TaxState						NVARCHAR(MAX)
	,@strTaxCodeId					NVARCHAR(MAX)	= ''
	,@FederalExciseTaxRate        	NUMERIC(18,6)	= 0.000000
	,@StateExciseTaxRate1         	NUMERIC(18,6)	= 0.000000
	,@StateExciseTaxRate2         	NUMERIC(18,6)	= 0.000000
	,@CountyExciseTaxRate         	NUMERIC(18,6)	= 0.000000
	,@CityExciseTaxRate           	NUMERIC(18,6)	= 0.000000
	,@StateSalesTaxPercentageRate 	NUMERIC(18,6)	= 0.000000
	,@CountySalesTaxPercentageRate	NUMERIC(18,6)	= 0.000000
	,@CitySalesTaxPercentageRate  	NUMERIC(18,6)	= 0.000000
	,@OtherSalesTaxPercentageRate 	NUMERIC(18,6)	= 0.000000
	--,@LC7							NUMERIC(18,6)	= 0.000000
	--,@LC8							NUMERIC(18,6)	= 0.000000
	--,@LC9							NUMERIC(18,6)	= 0.000000
	--,@LC10						NUMERIC(18,6)	= 0.000000
	--,@LC11						NUMERIC(18,6)	= 0.000000
	--,@LC12						NUMERIC(18,6)	= 0.000000
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
	,@FederalExciseTaxRate        	
	,@StateExciseTaxRate1         	
	,@StateExciseTaxRate2         	
	,@CountyExciseTaxRate         	
	,@CityExciseTaxRate           	
	,@StateSalesTaxPercentageRate 	
	,@CountySalesTaxPercentageRate		
	,@CitySalesTaxPercentageRate  		
	,@OtherSalesTaxPercentageRate 		
	--,@LC7		
	--,@LC8		
	--,@LC9		
	--,@LC10			
	--,@LC11			
	--,@LC12			
	,@intNetworkId
	,@intARItemId				
	,@intARItemLocationId			
	,@intCustomerId				
	,@intCustomerLocationId		
	,@dtmTransactionDate)

	RETURN