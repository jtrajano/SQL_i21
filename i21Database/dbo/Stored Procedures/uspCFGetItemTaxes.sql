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
	,@FederalExciseTax1				NUMERIC(18,6)	= 0.000000
	,@FederalExciseTax2				NUMERIC(18,6)	= 0.000000
	,@StateExciseTax1				NUMERIC(18,6)	= 0.000000
	,@StateExciseTax2				NUMERIC(18,6)	= 0.000000
	,@StateExciseTax3				NUMERIC(18,6)	= 0.000000
	,@CountyTax1					NUMERIC(18,6)	= 0.000000
	,@CityTax1						NUMERIC(18,6)	= 0.000000
	,@StateSalesTax					NUMERIC(18,6)	= 0.000000
	,@CountySalesTax				NUMERIC(18,6)	= 0.000000
	,@CitySalesTax					NUMERIC(18,6)	= 0.000000
	,@DisregardExemptionSetup		BIT				= 0 
	,@Tax1							NVARCHAR(MAX)	= ''
	,@Tax2							NVARCHAR(MAX)	= ''
	,@Tax3							NVARCHAR(MAX)	= ''
	,@Tax4							NVARCHAR(MAX)	= ''
	,@Tax5							NVARCHAR(MAX)	= ''
	,@Tax6							NVARCHAR(MAX)	= ''
	,@Tax7							NVARCHAR(MAX)	= ''
	,@Tax8							NVARCHAR(MAX)	= ''
	,@Tax9							NVARCHAR(MAX)	= ''
	,@Tax10							NVARCHAR(MAX)	= ''
	,@TaxValue1						NUMERIC(18,6)	= 0.000000
	,@TaxValue2						NUMERIC(18,6)	= 0.000000
	,@TaxValue3						NUMERIC(18,6)	= 0.000000
	,@TaxValue4						NUMERIC(18,6)	= 0.000000
	,@TaxValue5						NUMERIC(18,6)	= 0.000000
	,@TaxValue6						NUMERIC(18,6)	= 0.000000
	,@TaxValue7						NUMERIC(18,6)	= 0.000000
	,@TaxValue8						NUMERIC(18,6)	= 0.000000
	,@TaxValue9						NUMERIC(18,6)	= 0.000000
	,@TaxValue10					NUMERIC(18,6)	= 0.000000
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
	,[ysnTaxOnly]
	,[strTaxGroup]
	,[ysnInvalidSetup]
	,[strReason]
	,[strNotes]
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
	,@FederalExciseTax1	
	,@FederalExciseTax2	
	,@StateExciseTax1	
	,@StateExciseTax2	
	,@StateExciseTax3	
	,@CountyTax1		
	,@CityTax1			
	,@StateSalesTax		
	,@CountySalesTax	
	,@CitySalesTax			
	,@intNetworkId
	,@intARItemId				
	,@intARItemLocationId			
	,@intCustomerId				
	,@intCustomerLocationId		
	,@dtmTransactionDate
	,@DisregardExemptionSetup	
	,@Tax1						
	,@Tax2						
	,@Tax3						
	,@Tax4						
	,@Tax5						
	,@Tax6						
	,@Tax7						
	,@Tax8						
	,@Tax9						
	,@Tax10						
	,@TaxValue1					
	,@TaxValue2					
	,@TaxValue3					
	,@TaxValue4					
	,@TaxValue5					
	,@TaxValue6					
	,@TaxValue7					
	,@TaxValue8					
	,@TaxValue9					
	,@TaxValue10)

	RETURN