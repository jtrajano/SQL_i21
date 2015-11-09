CREATE FUNCTION [dbo].[fnGetTaxGroupIdForCustomer]
(
	 @CustomerId		INT
	,@CompanyLocationId	INT
	,@ItemId			INT
	,@ShipToLocationId	INT
)
RETURNS INT
AS
BEGIN

	DECLARE @VendorId INT
			,@ItemCategoryId INT
			
	SELECT @ItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId 

	SELECT
		 @VendorId			= VI.intVendorId
	FROM
		tblICItem I
	INNER JOIN
		vyuICGetItemStock VI
			ON I.intItemId = VI.intItemId
	WHERE
		I.intItemId = @ItemId
		AND VI.[intLocationId] = @CompanyLocationId	

	
	DECLARE @CustomerSpecialTax TABLE(
		[intARSpecialTaxId] INT
		,[intEntityCustomerId] INT
		,[intEntityCustomerLocationId] INT
		,[intEntityVendorId] INT
		,[intItemId] INT
		,[intCategoryId] INT
		,[intTaxGroupId] INT)

	--Commented until EM-667 is implemented
	--INSERT INTO @CustomerSpecialTax(
	--	 [intARSpecialTaxId]
	--	,[intEntityCustomerId]
	--	,[intEntityCustomerLocationId]
	--	,[intEntityVendorId]
	--	,[intItemId]
	--	,[intCategoryId]
	--	,[intTaxGroupId])
	--SELECT
	--	 ST.[intARSpecialTaxId]
	--	,ST.[intEntityCustomerId]
	--	,ST.[intEntityCustomerLocationId]
	--	,ST.[intEntityVendorId]
	--	,ST.[intItemId]
	--	,ST.[intCategoryId]
	--	,ST.[intTaxGroupMasterId]
	--FROM
	--	tblARSpecialTax ST
	--INNER JOIN
	--	tblARCustomer C
	--		ON ST.[intEntityCustomerId] = C.[intEntityCustomerId]
	--WHERE
	--	C.intEntityCustomerId = @CustomerId
			
	DECLARE @TaxGroupId INT
	SET @TaxGroupId = NULL
	--Customer Special Tax
	IF(EXISTS(SELECT TOP 1 NULL FROM @CustomerSpecialTax))
	BEGIN
		-- 1.Customer > Vendor No. > Vendor Location > Item No.
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId
			AND [intEntityCustomerLocationId] = @ShipToLocationId 
			AND [intItemId] = @ItemId 
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
		
		-- 2.Customer > Vendor No. > Vendor Location > Item Category	
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId
			AND [intEntityCustomerLocationId] = @ShipToLocationId 
			AND [intCategoryId] = @ItemCategoryId
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
			
		-- 3.Customer > Vendor No. > Vendor Location
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId
			AND [intEntityCustomerLocationId] = @ShipToLocationId 			
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
		
		-- 4.Customer > Vendor No. > Item No. 
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId
			AND [intItemId] = @ItemId 
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;			
							
		-- 5.Customer > Vendor No. >  Item Category
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId
			AND [intCategoryId] = @ItemCategoryId
						
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
			
		-- 6.Customer > Vendor No.
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intEntityVendorId] = @VendorId		
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
			
		-- 7.Customer > Item No.
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intItemId] = @ItemId 						
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;

		-- 8.Customer > Item Category
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@CustomerSpecialTax
		WHERE
			[intCategoryId] = @ItemCategoryId			
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;									
																																
	END
	
	SELECT TOP 1
		@TaxGroupId = EL.[intTaxGroupId]
	FROM
		tblARCustomer C
	INNER JOIN
		tblEntityLocation EL
			ON C.[intEntityCustomerId] = EL.[intEntityId] 
			AND EL.[ysnDefaultLocation] = 1
	WHERE
		[intEntityCustomerId] = @CustomerId 
					
	RETURN @TaxGroupId
END
