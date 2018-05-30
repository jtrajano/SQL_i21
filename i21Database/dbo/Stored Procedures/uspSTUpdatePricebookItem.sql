CREATE PROCEDURE [dbo].[uspSTUpdatePricebookItem]
@strUniqueId NVARCHAR(1000)
, @intEntityId Int
, @intCategoryId int
, @intItemVendorXrefId INT
, @strVendorProduct NVARCHAR(250)
, @strDescription nvarchar(250)
, @PosDescription nvarchar(250)
, @dblSalePrice decimal(18,6)
, @dblLastCost decimal(18,6)
, @intEntityVendorId int
, @strVendorId nvarchar(100)
, @Family nvarchar(100)
, @FamilyId int
, @Class nvarchar(100)
, @ClassId int
, @strStatusMsg NVARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY

		DECLARE @intItemUOMId int
		DECLARE @intItemId int
		DECLARE @intItemLocationId int
		DECLARE @intItemPricingId int
		DECLARE @strCompanyLocation AS NVARCHAR(150)

		SELECT 
		@intItemUOMId = intItemUOMId
		, @intItemId = intItemId
		, @intItemLocationId = intItemLocationId
		, @intItemPricingId = intItemPricingId
		FROM vyuSTPricebookMaster WHERE strUniqueId = @strUniqueId




		DECLARE @ErrMsg NVARCHAR(MAX)

		-- Retail Price - @dblSalePrice
		-- Last Cost - @dblLastCost

		-- Create Filters
			DECLARE @intCurrentLocationId AS INT
			DECLARE @intCurrentVendorId AS INT
			DECLARE @intCurrentCategoryId AS INT
			DECLARE @intCurrentFamilyId AS INT
			DECLARE @intCurrentClassId AS INT
			DECLARE @strUpcCode AS NVARCHAR(50)
			DECLARE @strCurrentItemDescription AS NVARCHAR(50)

			-- GET Values
			SELECT DISTINCT
					@intCurrentLocationId = CL.intCompanyLocationId
					, @intCurrentVendorId = IL.intVendorId
					, @intCurrentCategoryId = I.intCategoryId
					, @intCurrentFamilyId = IL.intFamilyId
					, @intCurrentClassId = IL.intClassId
					, @strUpcCode = CASE 
										WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
									END
					, @strCurrentItemDescription = I.strDescription
			FROM dbo.tblICItemPricing AS IP 
			LEFT OUTER JOIN dbo.tblICItemLocation AS IL ON IP.intItemId = IL.intItemId
															AND IL.intItemLocationId IS NOT NULL
			LEFT OUTER JOIN dbo.tblSTSubcategory AS SubCatF ON IL.intFamilyId = SubCatF.intSubcategoryId
			LEFT OUTER JOIN dbo.tblSTSubcategory AS SubCatC ON IL.intClassId = SubCatC.intSubcategoryId
			LEFT OUTER JOIN dbo.tblSMCompanyLocation AS CL ON IL.intLocationId = CL.intCompanyLocationId
			LEFT OUTER JOIN dbo.tblICItemUOM AS UOM ON IP.intItemId = UOM.intItemId 
			LEFT OUTER JOIN dbo.tblICItem AS I ON IP.intItemId = I.intItemId
			LEFT OUTER JOIN dbo.tblICCategory AS Cat ON I.intCategoryId = Cat.intCategoryId
			LEFT OUTER JOIN dbo.tblAPVendor AS Vendor ON IL.intVendorId = Vendor.[intEntityId]
			LEFT OUTER JOIN dbo.tblICItemVendorXref AS VendorXref ON IL.intItemLocationId = VendorXref.intItemLocationId
			LEFT OUTER JOIN dbo.tblEMEntity AS EM ON EM.intEntityId = IL.intVendorId
			WHERE UOM.intItemUOMId = @intItemUOMId
			AND I.intItemId = @intItemId
			AND IL.intItemLocationId = @intItemLocationId
			AND IP.intItemPricingId = @intItemPricingId



			-- Create the filter tables (ITEM, ITEM LOCATION, VendorXref)
			BEGIN
				-- Create the temp table used for filtering. 
				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_Location (
						intLocationId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_Vendor (
						intVendorId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_Category (
						intCategoryId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_Family (
						intFamilyId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL  
					CREATE TABLE #tmpUpdateItemForCStore_Class (
						intClassId INT 
					)
			END 

			-- Create the filter tables (ITEM PRICING)
			BEGIN
			-- Create the temp table 
				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
						intLocationId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_Vendor (
						intVendorId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_Category (
						intCategoryId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_Family (
						intFamilyId INT 
					)

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NULL  
					CREATE TABLE #tmpUpdateItemPricingForCStore_Class (
						intClassId INT 
					)
			END



			-- ITEM
			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemForCStore_itemAuditLog (
					intItemId INT
					-- Original Fields
					,intCategoryId_Original INT NULL
					,strCountCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,strDescription_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
					-- Modified Fields
					,intCategoryId_New INT NULL
					,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				)
			;


			-- ITEM PRICING 
			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog (
					intItemId INT
					,intItemPricingId INT 
					,dblOldStandardCost NUMERIC(38, 20) NULL
					,dblOldSalePrice NUMERIC(38, 20) NULL
					,dblOldLastCost NUMERIC(38, 20) NULL
					,dblNewStandardCost NUMERIC(38, 20) NULL
					,dblNewSalePrice NUMERIC(38, 20) NULL
					,dblNewLastCost NUMERIC(38, 20) NULL
				)
			;


			-- ITEM VendorXref 
			IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog (
				intItemId INT
				, intItemLocationId INT		
				, intItemVendorXrefId INT		
				, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				-- Original Fields		
				, strVendorProduct_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				, strVendorProductDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				, strVendorProduct_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				, strVendorProductDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
			)


			-- ITEM LOCATION
			IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog (
					intItemId INT
					,intItemLocationId INT 
					-- Original Fields
					,ysnTaxFlag1_Original BIT NULL
					,ysnTaxFlag2_Original BIT NULL
					,ysnTaxFlag3_Original BIT NULL
					,ysnTaxFlag4_Original BIT NULL
					,ysnDepositRequired_Original BIT NULL
					,intDepositPLUId_Original INT NULL 
					,ysnQuantityRequired_Original BIT NULL 
					,ysnScaleItem_Original BIT NULL 
					,ysnFoodStampable_Original BIT NULL 
					,ysnReturnable_Original BIT NULL 
					,ysnSaleable_Original BIT NULL 
					,ysnIdRequiredLiquor_Original BIT NULL 
					,ysnIdRequiredCigarette_Original BIT NULL 
					,ysnPromotionalItem_Original BIT NULL 
					,ysnPrePriced_Original BIT NULL 
					,ysnApplyBlueLaw1_Original BIT NULL 
					,ysnApplyBlueLaw2_Original BIT NULL 
					,ysnCountedDaily_Original BIT NULL 
					,strCounted_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,ysnCountBySINo_Original BIT NULL 
					,intFamilyId_Original INT NULL 
					,intClassId_Original INT NULL 
					,intProductCodeId_Original INT NULL 
					,intVendorId_Original INT NULL 
					,intMinimumAge_Original INT NULL 
					,dblMinOrder_Original NUMERIC(18, 6) NULL 
					,dblSuggestedQty_Original NUMERIC(18, 6) NULL
					,intCountGroupId_Original INT NULL 
					,intStorageLocationId_Original INT NULL 
					,dblReorderPoint_Original NUMERIC(18, 6) NULL
					,strDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
					-- Modified Fields
					,ysnTaxFlag1_New BIT NULL
					,ysnTaxFlag2_New BIT NULL
					,ysnTaxFlag3_New BIT NULL
					,ysnTaxFlag4_New BIT NULL
					,ysnDepositRequired_New BIT NULL
					,intDepositPLUId_New INT NULL 
					,ysnQuantityRequired_New BIT NULL 
					,ysnScaleItem_New BIT NULL 
					,ysnFoodStampable_New BIT NULL 
					,ysnReturnable_New BIT NULL 
					,ysnSaleable_New BIT NULL 
					,ysnIdRequiredLiquor_New BIT NULL 
					,ysnIdRequiredCigarette_New BIT NULL 
					,ysnPromotionalItem_New BIT NULL 
					,ysnPrePriced_New BIT NULL 
					,ysnApplyBlueLaw1_New BIT NULL 
					,ysnApplyBlueLaw2_New BIT NULL 
					,ysnCountedDaily_New BIT NULL 
					,strCounted_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,ysnCountBySINo_New BIT NULL 
					,intFamilyId_New INT NULL 
					,intClassId_New INT NULL 
					,intProductCodeId_New INT NULL 
					,intVendorId_New INT NULL 
					,intMinimumAge_New INT NULL 
					,dblMinOrder_New NUMERIC(18, 6) NULL 
					,dblSuggestedQty_New NUMERIC(18, 6) NULL
					,intCountGroupId_New INT NULL 
					,intStorageLocationId_New INT NULL 
					,dblReorderPoint_New NUMERIC(18, 6) NULL
					,strDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				)




			-- Add the filter records (ITEM, ITEM LOCATION, VendorXref)
			BEGIN
				IF(@intCurrentLocationId IS NOT NULL AND @intCurrentLocationId != 0)
					BEGIN
						INSERT INTO #tmpUpdateItemForCStore_Location (
							intLocationId
						)
						SELECT intLocationId = @intCurrentLocationId
					END
		
				IF(@intCurrentVendorId IS NOT NULL AND @intCurrentVendorId != 0)
					BEGIN
						INSERT INTO #tmpUpdateItemForCStore_Vendor (
							intVendorId
						)
						SELECT intVendorId = @intCurrentVendorId
					END

				IF(@intCurrentCategoryId IS NOT NULL AND @intCurrentCategoryId != 0)
					BEGIN
						INSERT INTO #tmpUpdateItemForCStore_Category (
							intCategoryId
						)
						SELECT intCategoryId = @intCurrentCategoryId
					END

				IF(@intCurrentFamilyId IS NOT NULL AND @intCurrentFamilyId != 0)
					BEGIN
						INSERT INTO #tmpUpdateItemForCStore_Family (
							intFamilyId
						)
						SELECT intFamilyId = @intCurrentFamilyId
					END

				IF(@intCurrentClassId IS NOT NULL AND @intCurrentClassId != 0)
					BEGIN
						INSERT INTO #tmpUpdateItemForCStore_Class (
							intClassId
						)
						SELECT intClassId = @intCurrentClassId
					END
			END

			-- Add the filter records (ITEM PRICING)
			BEGIN
				IF(@intCurrentLocationId IS NOT NULL)
					BEGIN
						INSERT INTO #tmpUpdateItemPricingForCStore_Location (
							intLocationId
						)
						SELECT intLocationId = @intCurrentLocationId
					END
		
				IF(@intCurrentVendorId IS NOT NULL)
					BEGIN
						INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
							intVendorId
						)
						SELECT intVendorId = @intCurrentVendorId
					END

				--NO Category

				IF(@intCurrentFamilyId IS NOT NULL)
					BEGIN
						INSERT INTO #tmpUpdateItemPricingForCStore_Family (
							intFamilyId
						)
						SELECT intFamilyId = @intCurrentFamilyId
					END

				IF(@intCurrentClassId IS NOT NULL)
					BEGIN
						INSERT INTO #tmpUpdateItemPricingForCStore_Class (
							intClassId
						)
						SELECT intClassId = @intCurrentClassId
					END
			END




			BEGIN 
				-- ITEM
				EXEC [dbo].[uspICUpdateItemForCStore]
					@strUpcCode = NULL --@strUpcCode  
					,@strDescription = NULL --@strCurrentItemDescription  
					,@dblRetailPriceFrom = NULL  
					,@dblRetailPriceTo = NULL 
					,@intItemId = @intItemId

					,@intCategoryId = @intCategoryId
					,@strCountCode = NULL
					,@strItemDescription = @strDescription 

					,@intEntityUserSecurityId = 1

				-- ITEM PRICING
				EXEC [uspICUpdateItemPricingForCStore]
					@strUpcCode = NULL --@strUpcCode
					,@strDescription = NULL --@strCurrentItemDescription
					,@intItemId = @intItemId
					,@dblStandardCost = null
					,@dblRetailPrice = @dblSalePrice
					,@dblLastCost = @dblLastCost
					,@intEntityUserSecurityId = 1

				-- ITEM VendorXref
				EXEC uspICUpdateItemVendorXrefForCStore
					-- filter params
					@intItemId = @intItemId
					-- update params
					,@strVendorProduct = @strVendorProduct
					,@strVendorProductDescription = NULL
					,@intEntityUserSecurityId = 1

				-- ITEM LOCATION
				EXEC [dbo].[uspICUpdateItemLocationForCStore]
					@strUpcCode = NULL 
					,@strDescription = NULL 
					,@dblRetailPriceFrom = NULL  
					,@dblRetailPriceTo = NULL 
					,@intItemLocationId = @intItemLocationId

					,@ysnTaxFlag1 = NULL 
					,@ysnTaxFlag2 = NULL
					,@ysnTaxFlag3 = NULL
					,@ysnTaxFlag4 = NULL
					,@ysnDepositRequired = NULL
					,@intDepositPLUId = NULL
					,@ysnQuantityRequired = NULL
					,@ysnScaleItem = NULL
					,@ysnFoodStampable = NULL
					,@ysnReturnable = NULL
					,@ysnSaleable = NULL
					,@ysnIdRequiredLiquor = NULL
					,@ysnIdRequiredCigarette = NULL
					,@ysnPromotionalItem = NULL
					,@ysnPrePriced = NULL
					,@ysnApplyBlueLaw1 = NULL
					,@ysnApplyBlueLaw2 = NULL		
					,@ysnCountedDaily = NULL
					,@strCounted = NULL
					,@ysnCountBySINo = NULL
					,@intFamilyId = @FamilyId
					,@intClassId = @ClassId
					,@intProductCodeId = NULL
					,@intVendorId = 10
					,@intMinimumAge = NULL
					,@dblMinOrder = NULL
					,@dblSuggestedQty = NULL
					,@intCountGroupId = NULL
					,@intStorageLocationId = NULL
					,@dblReorderPoint = NULL 
					,@strItemLocationDescription = @PosDescription 

					,@intEntityUserSecurityId = 1
			END




			-------------------------------------------------------------------------------
			------- Create Preview Table --------------------------------------------------
			-------------------------------------------------------------------------------
			-- Handle preview using Table variable
			DECLARE @tblPreview TABLE (
				intCompanyLocationId INT
				, strLocation NVARCHAR(250)
				, strUpc NVARCHAR(50)
				, strItemDescription NVARCHAR(250)
				, strChangeDescription NVARCHAR(250)
				, strOldData NVARCHAR(MAX)
				, strNewData NVARCHAR(MAX)
				, intParentId INT
				, intChildId INT
			)


			-- ITEM
			INSERT INTO @tblPreview (
				intCompanyLocationId
				, strLocation
				, strUpc
				, strItemDescription
				, strChangeDescription
				, strOldData
				, strNewData
				, intParentId
				, intChildId
			)
			SELECT	CL.intCompanyLocationId
					,CL.strLocationName
					, CASE
						WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
					END
					,I.strDescription
					,CASE
						WHEN [Changes].oldColumnName = 'strCategoryId_Original' THEN 'Category' /* + '	' + 'intLocationId: ' + CAST(@intCurrentLocationId AS NVARCHAR(10)) 
																									  + '	intCurrentVendorId: ' + CAST(@intCurrentVendorId AS NVARCHAR(10))
																									  + '	intCurrentCategoryId: ' + CAST(@intCurrentCategoryId AS NVARCHAR(10)) 
																									  + '	intCurrentFamilyId: ' + CAST(@intCurrentFamilyId AS NVARCHAR(10))
																									  + '	intCurrentClassId: ' + CAST(@intCurrentClassId AS NVARCHAR(10)) */
						WHEN [Changes].oldColumnName = 'strDescription_Original' THEN 'Item Description'
					END
					,[Changes].strOldData
					,[Changes].strNewData
					,[Changes].intItemId 
					,[Changes].intItemId
			FROM 
			(
				SELECT DISTINCT intItemId, oldColumnName, strOldData, strNewData
				FROM 
				(
					SELECT intItemId
							-- Original Fields
							,CAST((SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = intCategoryId_Original) AS NVARCHAR(100)) AS strCategoryId_Original
							,CAST(strDescription_Original AS NVARCHAR(100)) AS strDescription_Original
							-- Modified Fields
							,CAST((SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = intCategoryId_New) AS NVARCHAR(100)) AS strCategoryId_New
							,CAST(strDescription_New AS NVARCHAR(100)) AS strDescription_New
					FROM #tmpUpdateItemForCStore_itemAuditLog
				) t
				unpivot
				(
					strOldData for oldColumnName in (strCategoryId_Original, strDescription_Original)--, strCountCode_Original, strDescription_Original)
				) o
				unpivot
				(
					strNewData for newColumnName in (strCategoryId_New, strDescription_New)--, strCountCode_New, strDescription_New)
				) n
				WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
			) [Changes]
			JOIN tblICItem I ON [Changes].intItemId = I.intItemId
			JOIN tblICItemSpecialPricing IP ON I.intItemId = IP.intItemId
			JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
			JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
			JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
			WHERE 
			(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
			)


			-- ITEM PRICING
			INSERT INTO @tblPreview (
				intCompanyLocationId
				, strLocation
				, strUpc
				, strItemDescription
				, strChangeDescription
				, strOldData
				, strNewData
				, intParentId
				, intChildId
			)
			SELECT	CL.intCompanyLocationId
					,CL.strLocationName
					, CASE
						WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
					END
					,I.strDescription
					,CASE
						WHEN [Changes].oldColumnName = 'strSalePrice_Original' THEN 'Sale Price'
						WHEN [Changes].oldColumnName = 'strLastCost_Original' THEN 'Last Cost'
					END
					,[Changes].strOldData
					,[Changes].strNewData
					,[Changes].intItemId 
					,[Changes].intItemId
			FROM 
			(
				SELECT DISTINCT intItemId, intItemPricingId, oldColumnName, strOldData, strNewData
				FROM 
				(
					SELECT intItemId
							,intItemPricingId
							-- Original Fields 
							,CAST(CAST(dblOldSalePrice AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strSalePrice_Original
							,CAST(CAST(dblOldLastCost AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strLastCost_Original
							-- Modified Fields
							,CAST(CAST(dblNewSalePrice AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strSalePrice_New
							,CAST(CAST(dblNewLastCost AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strLastCost_New
					FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
				) t
				unpivot
				(
					strOldData for oldColumnName in (strSalePrice_Original, strLastCost_Original)
				) o
				unpivot
				(
					strNewData for newColumnName in (strSalePrice_New, strLastCost_New)
				) n
				WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
			) [Changes]
			JOIN tblICItem I ON [Changes].intItemId = I.intItemId
			JOIN tblICItemSpecialPricing IP ON I.intItemId = IP.intItemId
			JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
			JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
			JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
			WHERE 
			(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
			)


			-- ITEM VendorXref
			INSERT INTO @tblPreview (
				intCompanyLocationId
				, strLocation
				, strUpc
				, strItemDescription
				, strChangeDescription
				, strOldData
				, strNewData
				, intParentId
				, intChildId
			)
			SELECT	CL.intCompanyLocationId
					,CL.strLocationName
					, CASE
						WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
					END
					,I.strDescription
					,CASE
						WHEN [Changes].oldColumnName = 'strVendorProduct_Original' THEN 'Vendor Product' -- + '	' + CAST((SELECT COUNT(*) FROM  #tmpUpdateItemPricingForCStore_ItemPricingAuditLog) AS nvarchar(50))
						--WHEN [Changes].oldColumnName = 'strVendorProductDescription_Original' THEN 'Vendor Product Description'
					END
					,[Changes].strOldData
					,[Changes].strNewData
					,[Changes].intItemId 
					,[Changes].intItemId
			FROM 
			(
				SELECT DISTINCT intItemId, intItemLocationId, strAction, intItemVendorXrefId, oldColumnName, strOldData, strNewData
				FROM 
				(
					SELECT intItemId
							,intItemLocationId
							,intItemVendorXrefId
							,strAction
							-- Original Fields 
							,strVendorProduct_Original
							--,strVendorProductDescription_Original
							-- Modified Fields
							,strVendorProduct_New
							--,strVendorProductDescription_New
					FROM #tmpUpdateItemVendorXrefForCStore_itemAuditLog
				) t
				unpivot
				(
					strOldData for oldColumnName in (strVendorProduct_Original)--, strVendorProductDescription_Original)
				) o
				unpivot
				(
					strNewData for newColumnName in (strVendorProduct_New)--, strVendorProductDescription_New)
				) n
				WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
			) [Changes]
			JOIN tblICItem I ON [Changes].intItemId = I.intItemId
			JOIN tblICItemSpecialPricing IP ON I.intItemId = IP.intItemId
			JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
			JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
			JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
			WHERE 
			(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
			)


			-- ITEM LOCATION
			INSERT INTO @tblPreview (
				intCompanyLocationId
				, strLocation
				, strUpc
				, strItemDescription
				, strChangeDescription
				, strOldData
				, strNewData
				, intParentId
				, intChildId
			)
			SELECT	CL.intCompanyLocationId
					,CL.strLocationName
					, CASE
						WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
					END
					,I.strDescription
					,CASE
						WHEN [Changes].oldColumnName = 'strFamilyId_Original' THEN 'Family'
						WHEN [Changes].oldColumnName = 'strClassId_Original' THEN 'Class'
						WHEN [Changes].oldColumnName = 'strDescription_Original' THEN 'Description'
					END
					,[Changes].strOldData
					,[Changes].strNewData
					,[Changes].intItemId 
					,[Changes].intItemId
			FROM 
			(
				SELECT DISTINCT intItemId, intItemLocationId, oldColumnName, strOldData, strNewData
				FROM 
				(
					SELECT intItemId
							,intItemLocationId
							-- Original Fields 
							,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intFamilyId_Original) AS NVARCHAR(1000)) AS strFamilyId_Original
							,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intClassId_Original) AS NVARCHAR(1000)) AS strClassId_Original
							,strDescription_Original
							-- Modified Fields
							,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intFamilyId_New) AS NVARCHAR(1000)) AS strFamilyId_New
							,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intClassId_New) AS NVARCHAR(1000)) AS strClassId_New
							,strDescription_New
					FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog
				) t
				unpivot
				(
					strOldData for oldColumnName in (strFamilyId_Original, strClassId_Original, strDescription_Original)
				) o
				unpivot
				(
					strNewData for newColumnName in (strFamilyId_New, strClassId_New, strDescription_New)
				) n
				WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
			) [Changes]
			JOIN tblICItem I ON [Changes].intItemId = I.intItemId
			JOIN tblICItemSpecialPricing IP ON I.intItemId = IP.intItemId
			JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
			JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
			JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
			WHERE 
			(
				NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
				OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
			)
			-------------------------------------------------------------------------------
			------- Create Preview Table --------------------------------------------------
			-------------------------------------------------------------------------------



			DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')

		   -- Query Preview display
		   SELECT DISTINCT strLocation
				  , strUpc
				  , strItemDescription
				  , strChangeDescription
				  , strOldData
				  , strNewData
		   FROM @tblPreview
		   ORDER BY strItemDescription, strChangeDescription ASC
    
		   DELETE FROM @tblPreview




			-- Clean up (ITEM, ITEM LOCATION, VendorXref)
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL  
					DROP TABLE #tmpUpdateItemForCStore_Location 

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL  
					DROP TABLE #tmpUpdateItemForCStore_Vendor 

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
					DROP TABLE #tmpUpdateItemForCStore_Category 

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL  
					DROP TABLE #tmpUpdateItemForCStore_Family 

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL  
					DROP TABLE #tmpUpdateItemForCStore_Class 

				IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NOT NULL  
					DROP TABLE #tmpUpdateItemForCStore_itemAuditLog 
			END

			-- Clean up (ITEM PRICING)
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_Location

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_Vendor

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_Category

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_Family

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_Class

				IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
					DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
			END
		
			SET @strStatusMsg = 'Success'
	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()  
	END CATCH
END