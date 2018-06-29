CREATE PROCEDURE [dbo].[uspSTReportUpdateItemPricingPreview]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY

	BEGIN TRANSACTION

		DECLARE @ErrMsg NVARCHAR(MAX)

		DECLARE @UpdateCount INT
		SET @UpdateCount = 0

		--START Handle xml Param
		DECLARE @strCompanyLocationId NVARCHAR(MAX)
				, @strVendorId NVARCHAR(MAX)
				, @strCategoryId NVARCHAR(MAX)
				, @strFamilyId NVARCHAR(MAX)
				, @strClassId NVARCHAR(MAX)
				, @strDescription NVARCHAR(MAX)
				, @strRegion NVARCHAR(MAX)
				, @strDistrict NVARCHAR(MAX)
				, @strState NVARCHAR(MAX)
				, @intUpcCode INT
				, @dblStandardCost DECIMAL (18,6)
				, @dblRetailPrice DECIMAL (18,6)
				, @dblSalesPrice DECIMAL (18,6)
				, @dtmSalesStartingDate DATE
				, @dtmSalesEndingDate DATE
				, @ysnPreview NVARCHAR(1)
				, @intCurrentUserId INT


		IF LTRIM(RTRIM(@xmlParam)) = ''
			SET @xmlParam = NULL

		--Declare xmlParam holder
		DECLARE @temp_xml_table TABLE 
		(  
				[fieldname]		NVARCHAR(MAX),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(MAX), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50) 
		)  

		DECLARE @xmlDocumentId INT

		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT ,@xmlParam

		INSERT INTO @temp_xml_table  
		SELECT	*  
		FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
		WITH (  
					[fieldname]		NVARCHAR(MAX),  
					condition		NVARCHAR(20),        
					[from]			NVARCHAR(MAX), 
					[to]			NVARCHAR(50),  
					[join]			NVARCHAR(10),  
					[begingroup]	NVARCHAR(50),  
					[endgroup]		NVARCHAR(50),  
					[datatype]		NVARCHAR(50)  
		)  

		--START FILTERS
		--strCompanyLocationId
		SELECT @strCompanyLocationId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strCompanyLocationId'

		--strVendorId
		SELECT @strVendorId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strVendorId'

		--strCategoryId
		SELECT @strCategoryId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strCategoryId'

		--strFamilyId
		SELECT @strFamilyId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strFamilyId'

		--strClassId
		SELECT @strClassId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strClassId'

		--intUpcCode
		SELECT @intUpcCode = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'intUpcCode'

		--strDescription
		SELECT @strDescription = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strDescription'

		--strRegion
		SELECT @strRegion = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strRegion'

		--strDistrict
		SELECT @strDistrict = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strDistrict'

		--strState
		SELECT @strState = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strState'
		--END OF FILTERS



		-- UPDATE FIELDS
		--dblCost
		SELECT @dblStandardCost = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblCost'

		--dblRetail
		SELECT @dblRetailPrice = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblRetail'

		--dblSalesPrice
		SELECT @dblSalesPrice = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblSalesPrice'

		--dtmSalesStartingDate
		SELECT @dtmSalesStartingDate = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dtmSalesStartingDate'

		--dtmSalesEndingDate
		SELECT @dtmSalesEndingDate = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dtmSalesEndingDate'
		-- END OF UPDATE FIELDS



		--ysnPreview
		SELECT @ysnPreview = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'ysnPreview'

		--currentUserId
		SELECT @intCurrentUserId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'intCurrentUserId'



		-- Create the filter tables
		BEGIN
			CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
				intLocationId INT 
			)

			CREATE TABLE #tmpUpdateItemPricingForCStore_Vendor (
				intVendorId INT 
			)

			CREATE TABLE #tmpUpdateItemPricingForCStore_Category (
				intCategoryId INT 
			)

			CREATE TABLE #tmpUpdateItemPricingForCStore_Family (
				intFamilyId INT 
			)

			CREATE TABLE #tmpUpdateItemPricingForCStore_Class (
				intClassId INT 
			)

			-- Create the temp table for the audit log. 
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

			-- Create the temp table for the audit log. 
			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
					intItemId INT 
					,intItemSpecialPricingId INT 
					,dblOldUnitAfterDiscount NUMERIC(38, 20) NULL 
					,dtmOldBeginDate DATETIME NULL 
					,dtmOldEndDate DATETIME NULL 
					,dblNewUnitAfterDiscount NUMERIC(38, 20) NULL 
					,dtmNewBeginDate DATETIME NULL
					,dtmNewEndDate DATETIME NULL 		
				)
			;
		END



		-- Add the filter records
		BEGIN
			IF(@strCompanyLocationId IS NOT NULL AND @strCompanyLocationId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemPricingForCStore_Location (
						intLocationId
					)
					--SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
					SELECT [intID] AS intLocationId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCompanyLocationId)
				END
		
			IF(@strVendorId IS NOT NULL AND @strVendorId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
						intVendorId
					)
					--SELECT intVendorId = CAST(@strVendorId AS INT)
					SELECT [intID] AS intVendorId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strVendorId)
				END

			IF(@strCategoryId IS NOT NULL AND @strCategoryId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemPricingForCStore_Category (
						intCategoryId
					)
					--SELECT intCategoryId = CAST(@strCategoryId AS INT)
					SELECT [intID] AS intCategoryId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryId)
				END

			IF(@strFamilyId IS NOT NULL AND @strFamilyId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemPricingForCStore_Family (
						intFamilyId
					)
					--SELECT intFamilyId = CAST(@strFamilyId AS INT)
					SELECT [intID] AS intFamilyId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strFamilyId)
				END

			IF(@strClassId IS NOT NULL AND @strClassId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemPricingForCStore_Class (
						intClassId
					)
					--SELECT intClassId = CAST(@strClassId AS INT)
					SELECT [intID] AS intClassId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strClassId)
				END
		END


		-- Get strUpcCode
		DECLARE @strUpcCode AS NVARCHAR(20) = (
												SELECT CASE
														WHEN strLongUPCCode IS NOT NULL AND strLongUPCCode != '' THEN strLongUPCCode ELSE strUpcCode
												END AS strUpcCode
												FROM tblICItemUOM 
												WHERE intItemUOMId = @intUpcCode
											  )


		DECLARE @dblStandardCostConv AS NUMERIC(38, 20) = CAST(@dblStandardCost AS NUMERIC(38, 20))
		DECLARE @dblRetailPriceConv AS NUMERIC(38, 20) = CAST(@dblRetailPrice AS NUMERIC(38, 20))

		-- ITEM PRICING
		EXEC [uspICUpdateItemPricingForCStore]
			@strUpcCode = @strUpcCode
			, @strDescription = @strDescription
			, @intItemId = NULL
			, @dblStandardCost = @dblStandardCostConv
			, @dblRetailPrice = @dblRetailPriceConv
			,@intEntityUserSecurityId = @intCurrentUserId



		DECLARE @dblSalesPriceConv AS DECIMAL(18, 6) = CAST(@dblSalesPrice AS DECIMAL(18, 6))
		DECLARE @dtmSalesStartingDateConv AS DATE = CAST(@dtmSalesStartingDate AS DATE)
		DECLARE @dtmSalesEndingDateConv AS DATE = CAST(@dtmSalesEndingDate AS DATE)

		-- ITEM SPECIAL PRICING
		EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
			@dblPromotionalSalesPrice = @dblSalesPriceConv 
			,@dtmBeginDate = @dtmSalesStartingDateConv
			,@dtmEndDate = @dtmSalesEndingDateConv 
			,@intEntityUserSecurityId = @intCurrentUserId


		-- Handle preview using Table variable
		DECLARE @tblPreview TABLE (
			intCompanyLocationId INT
			, strLocation NVARCHAR(250)
			, strUpc NVARCHAR(50)
			, strItemDescription NVARCHAR(250)
			, strChangeDescription NVARCHAR(100)
			, strOldData NVARCHAR(MAX)
			, strNewData NVARCHAR(MAX)
			, intParentId INT
			, intChildId INT
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
				,UOM.strLongUPCCode
				,I.strDescription
				,CASE
					WHEN [Changes].oldColumnName = 'strStandardCost_Original' THEN 'Standard Cost'
					WHEN [Changes].oldColumnName = 'strSalePrice_Original' THEN 'Sale Price'
					WHEN [Changes].oldColumnName = 'strLastCost_Original' THEN 'Last Cost'
				END
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemPricingId
		FROM 
		(
			SELECT DISTINCT intItemId, intItemPricingId, oldColumnName, strOldData, strNewData
			FROM 
			(
				SELECT intItemId
				   , intItemPricingId
				   , CAST(CAST(dblOldStandardCost AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strStandardCost_Original
				   , CAST(CAST(dblOldSalePrice AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strSalePrice_Original
				   , CAST(CAST(dblOldLastCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strLastCost_Original
				   , CAST(CAST(dblNewStandardCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strStandardCost_New
				   , CAST(CAST(dblNewSalePrice AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strSalePrice_New
				   , CAST(CAST(dblNewLastCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strLastCost_New
				FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strStandardCost_Original, strSalePrice_Original, strLastCost_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strStandardCost_New, strSalePrice_New, strLastCost_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		) [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemPricing IP ON [Changes].intItemPricingId = IP.intItemPricingId
		JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
		JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode AND intItemUOMId = UOM.intItemUOMId) 		
		)


		-- ITEM SPECIAL PRICING
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
				,UOM.strLongUPCCode
				,I.strDescription
				,CASE
					WHEN [Changes].oldColumnName = 'strUnitAfterDiscount_Original' THEN 'Unit After Discount'
					WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'Begin Date'
					WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'End Date'
				END
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemSpecialPricingId
		FROM 
		(
			SELECT DISTINCT intItemId, intItemSpecialPricingId, oldColumnName, strOldData, strNewData
			FROM 
			(
				SELECT intItemId 
					,intItemSpecialPricingId 
					,CAST(CAST(dblOldUnitAfterDiscount AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strUnitAfterDiscount_Original
					,CAST(CAST(dtmOldBeginDate AS DATE) AS NVARCHAR(50)) AS strBeginDate_Original
					,CAST(CAST(dtmOldEndDate AS DATE) AS NVARCHAR(50)) AS strEndDate_Original
					,CAST(CAST(dblNewUnitAfterDiscount AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strUnitAfterDiscount_New
					,CAST(CAST(dtmNewBeginDate AS DATE) AS NVARCHAR(50)) AS strBeginDate_New
					,CAST(CAST(dtmNewEndDate AS DATE) AS NVARCHAR(50)) AS strEndDate_New
				FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strUnitAfterDiscount_Original, strBeginDate_Original, strEndDate_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strUnitAfterDiscount_New, strBeginDate_New, strEndDate_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
		) [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemSpecialPricing IP ON [Changes].intItemSpecialPricingId = IP.intItemSpecialPricingId
		JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
		JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intUpcCode AND intItemUOMId = UOM.intItemUOMId) 		
		)



	   DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')

	   -- Query Preview display
	   SELECT strLocation
			  , strUpc
			  , strItemDescription
			  , strChangeDescription
			  , strOldData
			  , strNewData
	   FROM @tblPreview
	   ORDER BY strItemDescription, strChangeDescription ASC
    
	   DELETE FROM @tblPreview

	   -- Clean up 
		BEGIN
			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_Location 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_Vendor 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_Category 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_Family 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_Class 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 
		END


	-- Rollback if Preview
	IF(@ysnPreview = 'Y')
		BEGIN
			IF @@TRANCOUNT > 0 
				ROLLBACK TRANSACTION
		END
	ELSE
		BEGIN
			IF @@TRANCOUNT > 0 
				COMMIT TRANSACTION
		END
	
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION
	RETURN -1
END CATCH