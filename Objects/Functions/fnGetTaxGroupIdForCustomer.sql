CREATE FUNCTION [dbo].[fnGetTaxGroupIdForCustomer]
(
	 @CustomerId			INT
	,@CompanyLocationId		INT
	,@ItemId				INT
	,@CustomerLocationId	INT
	,@SiteId				INT
	,@FreightTermId			INT
)
RETURNS INT
AS
BEGIN

	DECLARE @FOB NVARCHAR(150)
	SET @FOB = LOWER(RTRIM(LTRIM(ISNULL((SELECT strFobPoint FROM tblSMFreightTerms WHERE [intFreightTermId] = @FreightTermId),''))))

	IF ISNULL(@FreightTermId,0) <> 0 AND @FOB = 'origin'
		SET @CustomerLocationId = NULL

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

	DECLARE @TaxGroupId INT
	SET @TaxGroupId = NULL


	--Consumption Site
	IF ISNULL(@SiteId, 0) <> 0
	BEGIN
		SELECT TOP 1
			@TaxGroupId = [intTaxStateID]
		FROM
			tblTMSite
		WHERE
			[intSiteID] = @SiteId 

		IF ISNULL(@TaxGroupId,0) <> 0
			RETURN @TaxGroupId;	
	END
		
	--Customer Special Tax
	DECLARE @CustomerSpecialTax TABLE(
		 [intSequence] INT
		,[intARSpecialTaxId] INT
		,[intEntityCustomerId] INT
		,[intEntityCustomerLocationId] INT
		,[intEntityVendorId] INT
		,[intItemId] INT
		,[intCategoryId] INT
		,[intTaxGroupId] INT)

	INSERT INTO @CustomerSpecialTax(
		 [intSequence]
		,[intARSpecialTaxId]
		,[intEntityCustomerId]
		,[intEntityCustomerLocationId]
		,[intEntityVendorId]
		,[intItemId]
		,[intCategoryId]
		,[intTaxGroupId])	
		
	SELECT
		 [intSequence]					= 0
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intEntityVendorId] = @VendorId
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
		AND ST.[intItemId] = @ItemId
		AND ST.[intCategoryId] = @ItemCategoryId
			
	UNION

	SELECT
		 [intSequence]					= 1
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intEntityVendorId] = @VendorId
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
		AND ST.[intItemId] = @ItemId
		
	UNION	
		
	SELECT
		 [intSequence]					= 2
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intEntityVendorId] = @VendorId
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
		
	UNION	
		
	SELECT
		 [intSequence]					= 3
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
		AND ST.[intItemId] = @ItemId
		AND ST.[intCategoryId] = @ItemCategoryId	
		
	UNION	
		
	SELECT
		 [intSequence]					= 4
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
		AND ST.[intItemId] = @ItemId
		
	UNION			
		
	SELECT
		 [intSequence]					= 5
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
		AND ST.[intCategoryId] = @ItemCategoryId	
		
	UNION

	SELECT
		 [intSequence]					= 6
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intItemId] = @ItemId
		AND ST.[intCategoryId] = @ItemCategoryId
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ISNULL(ST.[intEntityCustomerLocationId],0) = 0
		
	UNION

	SELECT
		 [intSequence]					= 7
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intEntityVendorId] = @VendorId
		AND ISNULL(ST.[intEntityCustomerLocationId],0) = 0
				
	UNION

	SELECT
		 [intSequence]					= 8
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ST.[intEntityCustomerLocationId] = @CustomerLocationId
				
	UNION

	SELECT
		 [intSequence]					= 9
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intItemId] = @ItemId
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ISNULL(ST.[intEntityCustomerLocationId],0) = 0

	UNION

	SELECT
		 [intSequence]					= 10
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblARSpecialTax ST
	INNER JOIN
		tblARCustomer C
			ON ST.[intEntityCustomerId] = C.[intEntityId]
	WHERE
			C.[intEntityId] = @CustomerId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intCategoryId] = @ItemCategoryId
		AND ISNULL(ST.[intEntityVendorId],0) = 0
		AND ISNULL(ST.[intEntityCustomerLocationId],0) = 0
		

	SELECT TOP 1
		@TaxGroupId = [intTaxGroupId]
	FROM
		@CustomerSpecialTax
	ORDER BY intSequence

	IF ISNULL(@TaxGroupId,0) <> 0
		RETURN @TaxGroupId;	
	
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

	IF ISNULL(@TaxGroupId,0) <> 0 AND (@FOB = 'destination' OR LEN(@FOB) < 1)
		RETURN @TaxGroupId;	

	--Company Location
	SELECT TOP 1
		@TaxGroupId = [intTaxGroupId]
	FROM
		tblSMCompanyLocation
	WHERE
		intCompanyLocationId = @CompanyLocationId
	
	IF ISNULL(@TaxGroupId,0) <> 0 AND (@FOB = 'origin' OR LEN(@FOB) < 1)
		RETURN @TaxGroupId;
					
	RETURN NULL
END
