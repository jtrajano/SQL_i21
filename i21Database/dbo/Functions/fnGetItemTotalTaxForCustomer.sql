﻿CREATE FUNCTION [dbo].[fnGetItemTotalTaxForCustomer]
(
	 @ItemId						INT
	,@CustomerId					INT
	,@TransactionDate				DATETIME
	,@ItemPrice						NUMERIC(18,6)
	,@QtyShipped					NUMERIC(18,6)
	,@TaxGroupId					INT
	,@CompanyLocationId				INT
	,@CustomerLocationId			INT	
	,@IncludeExemptedCodes			BIT
	,@IsCustomerSiteTaxable			BIT
	,@SiteId						INT
	,@FreightTermId					INT
	,@CardId						INT
	,@VehicleId						INT
	,@DisregardExemptionSetup		BIT
	,@ExcludeCheckOff				BIT
	,@CFSiteId						INT
	,@IsDeliver						BIT
	,@IsCFQuote					    BIT             = 0
	,@ItemUOMId						INT				= NULL
	,@CurrencyId					INT				= NULL
	,@CurrencyExchangeRateTypeId	INT				= NULL
	,@CurrencyExchangeRate			NUMERIC(18,6)   = NULL
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @LineItemTotal NUMERIC(18,6)
	
	SELECT
		@LineItemTotal = SUM([dblAdjustedTax])
	FROM
		[dbo].[fnGetItemTaxComputationForCustomer](@ItemId, @CustomerId, @TransactionDate, @ItemPrice, @QtyShipped, @TaxGroupId, @CompanyLocationId, @CustomerLocationId, @IncludeExemptedCodes, 0, @IsCustomerSiteTaxable, @SiteId, @FreightTermId, @CardId, @VehicleId, @DisregardExemptionSetup, @ExcludeCheckOff, @CFSiteId, @IsDeliver, @IsCFQuote, @ItemUOMId, @CurrencyId, @CurrencyExchangeRateTypeId, @CurrencyExchangeRate)
		
	RETURN @LineItemTotal		
END