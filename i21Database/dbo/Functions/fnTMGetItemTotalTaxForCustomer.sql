CREATE FUNCTION [dbo].[fnTMGetItemTotalTaxForCustomer]
(
	 @ItemId					INT
	,@CustomerId				INT
	,@TransactionDate			DATETIME
	,@ItemPrice					NUMERIC(18,6)
	,@QtyShipped				NUMERIC(18,6)
	,@TaxGroupId				INT
	,@CompanyLocationId			INT
	,@CustomerLocationId		INT	
	,@IncludeExemptedCodes		BIT
	,@IsCustomerSiteTaxable		BIT
	,@SiteId					INT
	,@FreightTermId				INT
	,@CardId					INT
	,@VehicleId					INT
	,@DisregardExemptionSetup	BIT
)
RETURNS NUMERIC(18,6)
AS
BEGIN

	DECLARE @intItemUOMId INT

	SELECT @intItemUOMId = intIssueUOMId 
    FROM tblICItemLocation
    WHERE intItemId = @ItemId
    AND intLocationId = @CompanyLocationId


	RETURN dbo.fnGetItemTotalTaxForCustomer( @ItemId
											,@CustomerId			
											,@TransactionDate		
											,@ItemPrice				
											,@QtyShipped			
											,@TaxGroupId			
											,@CompanyLocationId		
											,@CustomerLocationId	
											,@IncludeExemptedCodes	
											,@IsCustomerSiteTaxable	
											,@SiteId				
											,@FreightTermId			
											,@CardId				
											,@VehicleId				
											,@DisregardExemptionSetup
											,0
											,NULL
											,1
											,0
											,@intItemUOMId	-- intItemUOMId
											,NULL
											,NULL
											,NULL
											)
END