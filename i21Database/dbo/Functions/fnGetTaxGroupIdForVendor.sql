CREATE FUNCTION [dbo].[fnGetTaxGroupIdForVendor]
(
	 @VendorId				INT
	,@CompanyLocationId		INT
	,@ItemId				INT
	,@VendorLocationId		INT
)
RETURNS INT
AS
BEGIN

	DECLARE @TaxVendorId INT
			,@ItemCategoryId INT
			
	SELECT @ItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId 

	SELECT
		 @TaxVendorId			= VI.intVendorId
	FROM
		tblICItem I
	INNER JOIN
		vyuICGetItemStock VI
			ON I.intItemId = VI.intItemId
	WHERE
		I.intItemId = @ItemId
		AND VI.[intLocationId] = @CompanyLocationId	

	DECLARE @VendorSpecialTax TABLE(
		[intAPVendorSpecialTaxId] INT
		,[intEntityVendorId] INT
		,[intEntityVendorLocationId] INT
		,[intTaxEntityVendorId] INT
		,[intItemId] INT
		,[intCategoryId] INT
		,[intTaxGroupId] INT)

	INSERT INTO @VendorSpecialTax(
		 [intAPVendorSpecialTaxId]
		,[intEntityVendorId]
		,[intEntityVendorLocationId]
		,[intTaxEntityVendorId]
		,[intItemId]
		,[intCategoryId]
		,[intTaxGroupId])
	SELECT
		 ST.[intAPVendorSpecialTaxId]
		,ST.[intEntityVendorId]
		,ST.[intEntityVendorLocationId]
		,ST.[intTaxEntityVendorId]
		,ST.[intItemId]
		,ST.[intCategoryId]
		,ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityVendorId]
	WHERE
		V.[intEntityVendorId] = @VendorId
			
	DECLARE @TaxGroupId INT
	SET @TaxGroupId = NULL
	--Vendor Special Tax
	IF(EXISTS(SELECT TOP 1 NULL FROM @VendorSpecialTax))
	BEGIN
		-- 1.Vendor > Vendor No. > Vendor Location > Item No.
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intTaxEntityVendorId] = @TaxVendorId
			AND [intEntityVendorLocationId] = @VendorLocationId 
			AND [intItemId] = @ItemId 
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
		
		-- 2.Vendor > Vendor No. > Vendor Location > Item Category	
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intTaxEntityVendorId] = @TaxVendorId
			AND [intEntityVendorLocationId] = @VendorLocationId 
			AND [intCategoryId] = @ItemCategoryId
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
			
		-- 3.Vendor > Vendor No. > Vendor Location
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intTaxEntityVendorId] = @TaxVendorId
			AND [intEntityVendorLocationId] = @VendorLocationId 			
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
		
		-- 4.Vendor > Vendor No. > Item No. 
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intTaxEntityVendorId] = @TaxVendorId
			AND [intItemId] = @ItemId 
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;			
							
		-- 5.Vendor > Vendor No. >  Item Category
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intTaxEntityVendorId] = @TaxVendorId
			AND [intCategoryId] = @ItemCategoryId
						
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
			
		-- 6.Vendor > Vendor No.
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intTaxEntityVendorId] = @TaxVendorId		
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;
			
		-- 7.Vendor > Item No.
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intItemId] = @ItemId 						
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;

		-- 8.Vendor > Item Category
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intCategoryId] = @ItemCategoryId			
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;		
			
		-- 9.Vendor > Vendor Location
		SELECT TOP 1
			@TaxGroupId = [intTaxGroupId]
		FROM
			@VendorSpecialTax
		WHERE
			[intEntityVendorLocationId] = @VendorLocationId 			
			
		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;							
																																
	END

	--Company Location
	SELECT TOP 1
		@TaxGroupId = [intTaxGroupId]
	FROM
		tblSMCompanyLocation
	WHERE
		intCompanyLocationId = @CompanyLocationId
	
	IF ISNULL(@TaxGroupId,0) <> 0
		RETURN @TaxGroupId;


	--Vendor Location
	SELECT TOP 1
		@TaxGroupId = EL.[intTaxGroupId]
	FROM
		tblAPVendor P
	INNER JOIN
		tblEntityLocation EL
			ON P.[intEntityVendorId] = EL.[intEntityId] 
	WHERE
		P.[intEntityVendorId] = @VendorId
		AND EL.[intEntityLocationId] = @VendorLocationId

	IF ISNULL(@TaxGroupId,0) <> 0
		RETURN @TaxGroupId;


					
	RETURN NULL
END
