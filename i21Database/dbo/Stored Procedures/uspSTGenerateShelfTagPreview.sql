CREATE PROCEDURE [dbo].[uspSTGenerateShelfTagPreview]
	@XML VARCHAR(MAX)
	, @ysnRecap BIT
	, @strEntityIds AS NVARCHAR(MAX) OUTPUT
	, @strResultMsg NVARCHAR(1000) OUTPUT
AS
BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
	        @idoc					INT,
	    	@StoreGroup 			NVARCHAR(MAX),
	    	@Store 					NVARCHAR(MAX),
			@Vendor                 NVARCHAR(MAX),
			@Category               NVARCHAR(MAX),
			@Subcategory            NVARCHAR(MAX),
			@Family                 NVARCHAR(MAX),
			@Class                  NVARCHAR(MAX),
			@PriceChangeFrom   		NVARCHAR(50),     
			@PriceChangeTill		NVARCHAR(50),     
			@ysnPreview             NVARCHAR(1),
			@currentUserId			INT
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	@StoreGroup			=   StoreGroup,
			@Store	   			=	Store,
            @Vendor             =   Vendor,
			@Category           =   Category,
			@Subcategory        =   Subcategory,
			@Family             =   Family,
            @Class              =   Class,
			@PriceChangeFrom    =   PriceChangeFrom, 
			@PriceChangeTill    =   PriceChangeTill,
			@currentUserId		=   currentUserId

	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			StoreGroup		        NVARCHAR(MAX),
			Store			        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Subcategory		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			PriceChangeFrom         NVARCHAR(50),     
			PriceChangeTill			NVARCHAR(50),     
			currentUserId			INT
	)		



	-- Create the filter tables
	BEGIN 
		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Items') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Items (
					intItemId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Location') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Location (
					intLocationId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Vendor') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Vendor (
					intVendorId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Category') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Category (
					intCategoryId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Subcategory') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Subcategory (
					intSubcategoryId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Family') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Family (
					intFamilyId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Class') IS NULL 
			BEGIN
				CREATE TABLE #tmpGenerateShelfTagItems_Class (
					intClassId INT 
				)
			END

	END 

	-- Add the filter records
	BEGIN
		IF(@PriceChangeFrom IS NOT NULL AND @PriceChangeFrom != '' AND @PriceChangeTill IS NOT NULL AND @PriceChangeTill != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Items (
					intItemId
				)
				SELECT DISTINCT intItemId
				FROM (
					SELECT intItemId 
					FROM tblICEffectiveItemCost
					WHERE 
							(
								dtmDateModified BETWEEN @PriceChangeFrom AND @PriceChangeTill
								OR 
								dtmDateCreated BETWEEN @PriceChangeFrom AND @PriceChangeTill
							)
					UNION
					SELECT intItemId 
					FROM tblICEffectiveItemPrice
					WHERE 
							(
								dtmDateModified BETWEEN @PriceChangeFrom AND @PriceChangeTill
								OR 
								dtmDateCreated BETWEEN @PriceChangeFrom AND @PriceChangeTill
							)
					UNION
					SELECT intItemId 
					FROM tblICItemSpecialPricing
					WHERE 
							(
								dtmDateModified BETWEEN @PriceChangeFrom AND @PriceChangeTill
								OR 
								dtmDateCreated BETWEEN @PriceChangeFrom AND @PriceChangeTill
							)
					UNION
					SELECT intItemId 
					FROM tblICItemPricing
					WHERE 
							(
								dtmDateModified BETWEEN @PriceChangeFrom AND @PriceChangeTill
								OR 
								dtmDateCreated BETWEEN @PriceChangeFrom AND @PriceChangeTill
							)
				) temp
			END

		IF(@Store IS NOT NULL AND @Store != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Location (
					intLocationId
				)
				SELECT DISTINCT st.intCompanyLocationId AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Store)
				INNER JOIN tblSTStore st
					ON st.intStoreId = intID
			END
		
		IF(@StoreGroup IS NOT NULL AND @StoreGroup != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Location (
					intLocationId
				)
				SELECT DISTINCT st.intCompanyLocationId AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@StoreGroup)
				INNER JOIN tblSTStoreGroup sg
					ON sg.intStoreGroupId = intID
				INNER JOIN tblSTStoreGroupDetail sgt
					ON sgt.intStoreGroupId = sg.intStoreGroupId
				INNER JOIN tblSTStore st
					ON st.intStoreId = sgt.intStoreId
			END
			 

		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Vendor (
					intVendorId
				)
				SELECT [intID] AS intVendorId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Category (
					intCategoryId
				)
				SELECT [intID] AS intCategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
			END

		IF(@Subcategory IS NOT NULL AND @Subcategory != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Subcategory (
					intSubcategoryId
				)
				SELECT [intID] AS intSubcategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Subcategory)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Family (
					intFamilyId
				)
				SELECT [intID] AS intFamilyId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpGenerateShelfTagItems_Class (
					intClassId
				)
				SELECT [intID] AS intClassId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
			END
	END

	
	SELECT	DISTINCT 
		i.strItemNo, 
		i.strShortName AS strItemShortName, 
		CL.strLocationName AS strLocation, 
		UOM.strLongUPCCode AS strUpc, 
		UM.strUnitMeasure AS strUOM, 
		CAST(CAST(HP.dblSalePrice AS DECIMAL(8,2)) AS VARCHAR(MAX)) AS strPrice
	FROM	tblICItem i CROSS APPLY (
				SELECT	TOP 1
						itemLocation.intItemId  								
				FROM	tblICItemLocation itemLocation 
				WHERE	itemLocation.intItemId = i.intItemId 
						AND	(
							NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Location)
							OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Location WHERE intLocationId = itemLocation.intLocationId) 			
						)
						AND (
							NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Vendor)
							OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Vendor WHERE intVendorId = itemLocation.intVendorId) 			
						)
						AND (
							NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Family)
							OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Family WHERE intFamilyId = itemLocation.intFamilyId)			
						)
						AND (
							NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Class)
							OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Class WHERE intClassId = itemLocation.intClassId )			
						)
			) filterQuery 
	INNER JOIN tblICItemLocation IL
		ON i.intItemId = IL.intItemId
	INNER JOIN tblSMCompanyLocation CL
		ON IL.intLocationId = CL.intCompanyLocationId
	INNER JOIN tblICItemUOM UOM
		ON i.intItemId = UOM.intItemId
	INNER JOIN tblICUnitMeasure UM
		ON UOM.intUnitMeasureId = UM.intUnitMeasureId
	INNER JOIN vyuSTItemHierarchyPricing HP
		ON i.intItemId = HP.intItemId
			AND IL.intItemLocationId = HP.intItemLocationId
			AND UOM.intItemUOMId = HP.intItemUOMId
	WHERE	(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Category)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Category WHERE intCategoryId = i.intCategoryId)			
			)	
			AND	(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Location)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Location WHERE intLocationId = IL.intLocationId) 			
			)
			AND
			(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Subcategory)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Subcategory WHERE intSubcategoryId = i.intSubcategoriesId)			
			)	
			AND
			(
				EXISTS (SELECT TOP 1 1 FROM #tmpGenerateShelfTagItems_Items WHERE intItemId = i.intItemId)			
			)	
			AND UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' AND i.strShortName != '' AND i.strShortName IS NOT NULL
	ORDER BY CL.strLocationName
	
	-- Clean up 
	BEGIN
		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Location') IS NOT NULL  
			DROP TABLE #tmpGenerateShelfTagItems_Location 

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Store') IS NOT NULL  
			DROP TABLE #tmpGenerateShelfTagItems_Store

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Vendor') IS NOT NULL  
			DROP TABLE #tmpGenerateShelfTagItems_Vendor 

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Category') IS NOT NULL   
			DROP TABLE #tmpGenerateShelfTagItems_Category 

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Family') IS NOT NULL  
			DROP TABLE #tmpGenerateShelfTagItems_Family 

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Class') IS NOT NULL  
			DROP TABLE #tmpGenerateShelfTagItems_Class 

		IF OBJECT_ID('tempdb..#tmpGenerateShelfTagItems_Items') IS NOT NULL   
			DROP TABLE #tmpGenerateShelfTagItems_Items 

	END

END TRY

BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()     
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 
END CATCH