﻿CREATE FUNCTION [dbo].[fnGetTaxGroupIdForVendor]
(
	 @VendorId				INT
	,@CompanyLocationId		INT
	,@ItemId				INT
	,@VendorLocationId		INT
	,@FreightTermId			INT
	,@FOB					NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
	IF ISNULL(@FOB, '') = ''
		SET @FOB = LOWER(RTRIM(LTRIM(ISNULL((SELECT strFobPoint FROM tblSMFreightTerms WHERE [intFreightTermId] = @FreightTermId),''))))
	ELSE
		SET @FOB = LOWER(@FOB)

	IF ISNULL(@FreightTermId,0) <> 0 AND @FOB <> 'origin'
		SET @VendorLocationId = NULL

	DECLARE  @TaxVendorId		INT
			,@ItemCategoryId	INT
			
	SELECT @ItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @ItemId 

	SELECT
		 @TaxVendorId = VI.intVendorId
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

	--Vendor Special Tax
	DECLARE @VendorSpecialTax TABLE(
		 [intSequence] INT
		,[intAPVendorSpecialTaxId] INT
		,[intEntityVendorId] INT
		,[intEntityVendorLocationId] INT
		,[intTaxEntityVendorId] INT
		,[intItemId] INT
		,[intCategoryId] INT
		,[intTaxGroupId] INT)

	INSERT INTO @VendorSpecialTax(
		 [intSequence]
		,[intAPVendorSpecialTaxId]
		,[intEntityVendorId]
		,[intEntityVendorLocationId]
		,[intTaxEntityVendorId]
		,[intItemId]
		,[intCategoryId]
		,[intTaxGroupId])	
		
	SELECT
		 [intSequence]					= 0
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intTaxEntityVendorId] = @VendorId
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		--AND ST.[intItemId] = @ItemId
		AND COALESCE(ST.[intItemId], 0) = COALESCE(@ItemId, ST.[intItemId], 0) 
		AND ST.[intCategoryId] = @ItemCategoryId
			
	UNION

	SELECT
		 [intSequence]					= 1
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intTaxEntityVendorId] = @VendorId
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		--AND ST.[intItemId] = @ItemId
		AND COALESCE(ST.[intItemId], 0) = COALESCE(@ItemId, ST.[intItemId], 0) 
		
	UNION	
		
	SELECT
		 [intSequence]					= 2
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intTaxEntityVendorId] = @VendorId
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		
	UNION	
		
	SELECT
		 [intSequence]					= 3
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		--AND ST.[intItemId] = @ItemId
		AND COALESCE(ST.[intItemId], 0) = COALESCE(@ItemId, ST.[intItemId], 0) 
		AND ST.[intCategoryId] = @ItemCategoryId	
		
	UNION	
		
	SELECT
		 [intSequence]					= 4
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		--AND ST.[intItemId] = @ItemId
		AND COALESCE(ST.[intItemId], 0) = COALESCE(@ItemId, ST.[intItemId], 0) 
		
	UNION			
		
	SELECT
		 [intSequence]					= 5
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		AND ST.[intCategoryId] = @ItemCategoryId	
		
	UNION

	SELECT
		 [intSequence]					= 6
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ISNULL(ST.[intEntityVendorLocationId],0) = 0
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0
		--AND ST.[intItemId] = @ItemId
		AND COALESCE(ST.[intItemId], 0) = COALESCE(@ItemId, ST.[intItemId], 0) 
		AND ST.[intCategoryId] = @ItemCategoryId
		
	UNION

	SELECT
		 [intSequence]					= 7
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intTaxEntityVendorId] = @VendorId
		AND ISNULL(ST.[intEntityVendorLocationId],0) = 0
				
	UNION

	SELECT
		 [intSequence]					= 8
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0
				
	UNION

	SELECT
		 [intSequence]					= 9
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		--AND ST.[intItemId] = @ItemId
		AND COALESCE(ST.[intItemId], 0) = COALESCE(@ItemId, ST.[intItemId], 0) 
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0

	UNION

	SELECT
		 [intSequence]					= 10
		,[intAPVendorSpecialTaxId]		= ST.[intAPVendorSpecialTaxId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intEntityVendorLocationId]	= ST.[intEntityVendorLocationId]
		,[intTaxEntityVendorId]			= ST.[intTaxEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM
		tblAPVendorSpecialTax ST
	INNER JOIN
		tblAPVendor V
			ON ST.[intEntityVendorId] = V.[intEntityId]
	WHERE
			V.[intEntityId] = @VendorId
		AND	ST.[intTaxGroupId] IS NOT NULL
		AND ST.[intCategoryId] = @ItemCategoryId
		AND ST.[intEntityVendorLocationId] = @VendorLocationId
		AND ISNULL(ST.[intTaxEntityVendorId],0) = 0
		

	SELECT TOP 1
		@TaxGroupId = [intTaxGroupId]
	FROM
		@VendorSpecialTax
	ORDER BY intSequence

	IF ISNULL(@TaxGroupId,0) <> 0
		RETURN @TaxGroupId;	

	--Vendor Ship From Location
	SELECT TOP 1 @TaxGroupId = EMEL.intTaxGroupId
	FROM tblAPVendor APV
	INNER JOIN tblEMEntityLocation EMEL
	ON APV.intShipFromId = EMEL.intEntityLocationId
	WHERE APV.intEntityId = @VendorId

	IF ISNULL(@TaxGroupId,0) <> 0 AND ISNULL(@VendorLocationId, 0) = 0
		RETURN @TaxGroupId;

	--Company Location
	SELECT TOP 1
		@TaxGroupId = [intTaxGroupId]
	FROM
		tblSMCompanyLocation
	WHERE
		intCompanyLocationId = @CompanyLocationId
	
	IF ISNULL(@TaxGroupId,0) <> 0 AND (@FOB = 'destination' OR LEN(@FOB) < 1)
		RETURN @TaxGroupId;


	--Vendor Location
	SELECT TOP 1
		@TaxGroupId = EL.[intTaxGroupId]
	FROM
		tblAPVendor P
	INNER JOIN
		[tblEMEntityLocation] EL
			ON P.[intEntityId] = EL.[intEntityId] 
	WHERE
		P.[intEntityId] = @VendorId
		AND EL.[intEntityLocationId] = @VendorLocationId

	IF ISNULL(@TaxGroupId,0) <> 0 AND (@FOB = 'origin' OR LEN(@FOB) < 1)
		RETURN @TaxGroupId;


					
	RETURN NULL
END
