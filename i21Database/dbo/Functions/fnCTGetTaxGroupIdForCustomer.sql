﻿
Create FUNCTION [dbo].[fnCTGetTaxGroupIdForCustomer]
(
	 @CustomerId			INT
	,@CompanyLocationId		INT
	,@ItemId				INT
	,@CustomerLocationId	INT
	,@SiteId				INT
	,@FreightTermId			INT
	,@FOB					NVARCHAR(100) = NULL
)
RETURNS INT
AS
BEGIN

	
	DECLARE @TaxGroupId INT
	SET @TaxGroupId = NULL

	--Customer Location
	SELECT TOP 1
		@TaxGroupId = EL.[intTaxGroupId]
	FROM
		tblARCustomer C
	INNER JOIN
		[tblEMEntityLocation] EL
			ON C.[intEntityId] = EL.[intEntityId] 
	WHERE
		C.[intEntityId] = @CustomerId
		AND EL.[intEntityLocationId] = @CustomerLocationId

	IF ISNULL(@TaxGroupId,0) <> 0 
		RETURN @TaxGroupId;	

	--Company Location
	SELECT TOP 1
		@TaxGroupId = [intTaxGroupId]
	FROM
		tblSMCompanyLocation
	WHERE
		intCompanyLocationId = @CompanyLocationId
	
	IF ISNULL(@TaxGroupId,0) <> 0 
		RETURN @TaxGroupId;
					
	RETURN NULL
END