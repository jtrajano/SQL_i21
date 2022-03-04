CREATE PROCEDURE [dbo].[uspARGetTaxGroupIdForCustomer]
	@CustomerTaxGroupIdParam	CustomerTaxGroupIdParam READONLY
AS
BEGIN
	IF(OBJECT_ID('tempdb..##CUSTOMERTAXGROUPID') IS NOT NULL) DROP TABLE ##CUSTOMERTAXGROUPID
	CREATE TABLE ##CUSTOMERTAXGROUPID (
		  intCustomerId				INT NULL
		, intCompanyLocationId		INT NULL
		, intItemId					INT NULL
		, intCustomerLocationId		INT NULL
		, intSiteId					INT NULL
		, intFreightTermId 			INT NULL
		, intTaxGroupId				INT NULL
		, intLineItemId				INT NULL
	)
	DECLARE @CustomerTaxGroupId	 CustomerTaxGroupIdParam

	INSERT INTO @CustomerTaxGroupId
	SELECT * FROM @CustomerTaxGroupIdParam
	
	UPDATE P
	SET strFOB = LOWER(RTRIM(LTRIM(strFobPoint)))
	FROM @CustomerTaxGroupId P
	INNER JOIN tblSMFreightTerms F ON P.intFreightTermId = F.intFreightTermId

	UPDATE P
	SET intCustomerLocationId = NULL
	FROM @CustomerTaxGroupId P
	WHERE P.intFreightTermId IS NOT NULL
	  AND P.strFOB = 'origin'

	UPDATE P
	SET intItemCategoryId = I.intCategoryId
	FROM @CustomerTaxGroupId P 
	INNER JOIN tblICItem I ON P.intItemId = I.intItemId

	UPDATE P
	SET intVendorId = VI.intVendorId
	FROM @CustomerTaxGroupId P 
	INNER JOIN tblICItem I ON P.intItemId = I.intItemId
	INNER JOIN vyuICGetItemStock VI ON I.intItemId = VI.intItemId AND VI.intLocationId = P.intCompanyLocationId	
	
	--Consumption Site
	UPDATE P
	SET intTaxGroupId = S.intTaxStateID
	FROM @CustomerTaxGroupId P
	INNER JOIN tblTMSite S ON P.intSiteId = S.intSiteID
	WHERE P.intSiteId IS NOT NULL
			
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

	INSERT INTO @CustomerSpecialTax (
		 [intSequence]
		,[intARSpecialTaxId]
		,[intEntityCustomerId]
		,[intEntityCustomerLocationId]
		,[intEntityVendorId]
		,[intItemId]
		,[intCategoryId]
		,[intTaxGroupId]
	)
	SELECT
		 [intSequence]					= 0
		,[intARSpecialTaxId]			= ST.[intARSpecialTaxId]
		,[intEntityCustomerId]			= ST.[intEntityCustomerId]
		,[intEntityCustomerLocationId]	= ST.[intEntityCustomerLocationId]
		,[intEntityVendorId]			= ST.[intEntityVendorId]
		,[intItemId]					= ST.[intItemId]
		,[intCategoryId]				= ST.[intCategoryId]
		,[intTaxGroupId]				= ST.[intTaxGroupId]
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intEntityVendorId = P.intVendorId
									AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
									AND ST.intItemId = P.intItemId
									AND ST.intCategoryId = P.intItemCategoryId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  --AND P.intTaxGroupId IS NULL
			
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intEntityVendorId = P.intVendorId
									AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
									AND ST.intItemId = P.intItemId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  --AND P.intTaxGroupId IS NULL
		
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intEntityVendorId = P.intVendorId
									AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  --AND P.intTaxGroupId IS NULL 
		
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
									AND ST.intItemId = P.intItemId
									AND ST.intCategoryId = P.intItemCategoryId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  AND ISNULL(ST.[intEntityVendorId],0) = 0
	  --AND P.intTaxGroupId IS NULL 
	  
		
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
									AND ST.intItemId = P.intItemId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  AND ISNULL(ST.[intEntityVendorId],0) = 0
	  --AND P.intTaxGroupId IS NULL 
		
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
									AND ST.intCategoryId = P.intItemCategoryId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  AND ISNULL(ST.[intEntityVendorId],0) = 0
	  	
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId
									AND ST.intItemId = P.intItemId
									AND ST.intCategoryId = P.intItemCategoryId
	WHERE ST.[intTaxGroupId] IS NOT NULL
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId AND ST.intEntityVendorId = P.intVendorId										
	WHERE ST.[intTaxGroupId] IS NOT NULL
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId AND ST.intEntityCustomerLocationId = P.intCustomerLocationId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  AND ISNULL(ST.[intEntityVendorId],0) = 0
				
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId AND ST.intItemId = P.intItemId
	WHERE ST.[intTaxGroupId] IS NOT NULL
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
	FROM tblARSpecialTax ST
	INNER JOIN tblARCustomer C ON ST.[intEntityCustomerId] = C.[intEntityId]
	INNER JOIN @CustomerTaxGroupId P ON C.intEntityId = P.intCustomerId AND ST.intCategoryId = P.intItemCategoryId
	WHERE ST.[intTaxGroupId] IS NOT NULL
	  AND ISNULL(ST.[intEntityVendorId],0) = 0
      AND ISNULL(ST.[intEntityCustomerLocationId],0) = 0

	--SPECIAL TAX GROUP	  
	UPDATE P
	SET intTaxGroupId = TAX.intTaxGroupId
	FROM @CustomerTaxGroupId P
	CROSS APPLY (
		SELECT TOP 1 intTaxGroupId
		FROM @CustomerSpecialTax TAX
		WHERE TAX.intEntityCustomerId = P.intCustomerId
		ORDER BY intSequence
	) TAX
	WHERE P.intTaxGroupId IS NULL
	  AND TAX.intTaxGroupId IS NOT NULL

	--CUSTOMER LOCATION
	UPDATE P
	SET intTaxGroupId = 0
	FROM @CustomerTaxGroupId P
	CROSS APPLY (
		SELECT TOP 1 EL.[intTaxGroupId]
		FROM tblARCustomer C
		INNER JOIN [tblEMEntityLocation] EL ON C.[intEntityId] = EL.[intEntityId] 
		WHERE C.[intEntityId] = P.intCustomerId
		  AND EL.[intEntityLocationId] = P.intCustomerLocationId
	) CUS
	WHERE P.intTaxGroupId IS NULL
	  AND (P.strFOB = 'destination' OR LEN(P.strFOB) < 1)
	  AND CUS.intTaxGroupId IS NOT NULL
	  	
	--COMPANY LOCATION
	UPDATE P
	SET intTaxGroupId = 0
	FROM @CustomerTaxGroupId P
	CROSS APPLY (
		SELECT TOP 1 [intTaxGroupId]
		FROM tblSMCompanyLocation CL
		WHERE CL.intCompanyLocationId = P.intCompanyLocationId
	) CL
	WHERE P.intTaxGroupId IS NULL
	  AND (P.strFOB = 'origin' OR LEN(P.strFOB) < 1)
	  AND CL.intTaxGroupId IS NOT NULL

	INSERT INTO ##CUSTOMERTAXGROUPID WITH (TABLOCK) (
		  intCustomerId
		, intCompanyLocationId
		, intItemId
		, intCustomerLocationId
		, intSiteId
		, intFreightTermId
		, intTaxGroupId
		, intLineItemId
	)
	SELECT intCustomerId
		, intCompanyLocationId
		, intItemId
		, intCustomerLocationId
		, intSiteId
		, intFreightTermId
		, intTaxGroupId
		, intLineItemId
	FROM @CustomerTaxGroupId
END
