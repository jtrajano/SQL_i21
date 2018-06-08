CREATE PROCEDURE [dbo].[uspSTReportUpdateRebateOrDiscountPreview]
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY

	BEGIN TRANSACTION

		DECLARE @ErrMsg NVARCHAR(MAX)

		--START Handle xml Param
		DECLARE @strCompanyLocationId	NVARCHAR(MAX)
				, @strVendorId			NVARCHAR(MAX)
				, @strCategoryId		NVARCHAR(MAX)
				, @strFamilyId			NVARCHAR(MAX)
				, @strClassId			NVARCHAR(MAX)
				, @strPromotionType     NVARCHAR(50)
				, @dtmBeginDate   	    NVARCHAR(50)   
				, @dtmEndDate		 	NVARCHAR(50)    
				, @dblRebateAmount      DECIMAL (18,6)
				, @dblAccumlatedQty     DECIMAL (18,6)
				, @dblAccumAmount       DECIMAL (18,6)
				, @dblDiscThroughAmount DECIMAL (18,6)
				, @dblDiscThroughQty    DECIMAL (18,6)
				, @dblDiscAmountUnit    DECIMAL (18,6)
				, @ysnPreview           NVARCHAR(1)
				, @intCurrentUserId		INT

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

		--strPromotionType
		SELECT @strPromotionType = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'strPromotionType'

		--dtmBeginDate
		SELECT @dtmBeginDate = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dtmBeginDate'

		--dtmEndDate
		SELECT @dtmEndDate = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dtmEndDate'

		--dblRebateAmount
		SELECT @dblRebateAmount = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblRebateAmount'

		--dblAccumlatedQty
		SELECT @dblAccumlatedQty = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblAccumlatedQty'

		--dblAccumAmount
		SELECT @dblAccumAmount = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblAccumAmount'

		--dblDiscThroughAmount
		SELECT @dblDiscThroughAmount = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblDiscThroughAmount'

		--dblDiscThroughQty
		SELECT @dblDiscThroughQty = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblDiscThroughQty'

		--dblDiscAmountUnit
		SELECT @dblDiscAmountUnit = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'dblDiscAmountUnit'

		--ysnPreview
		SELECT @ysnPreview = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'ysnPreview'

		--intCurrentUserId
		SELECT @intCurrentUserId = [from]
		FROM @temp_xml_table
		WHERE [fieldname] = 'intCurrentUserId'
		--END Handle xml Param

	
		--DECLARE @UpdateCount INT
		--DECLARE @RecCount INT

		--SET @UpdateCount = 0
		--SET @RecCount = 0



		-- Create the filter tables
		BEGIN
			CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Location (
				intLocationId INT 
			)

			CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Vendor (
				intVendorId INT 
			)

			CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Category (
				intCategoryId INT 
			)

			CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Family (
				intFamilyId INT 
			)

			CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Class (
				intClassId INT 
			)
		END 

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_AuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_AuditLog (
				intItemId INT
				,intItemSpecialPricingId INT 
				,dtmBeginDate_Original DATETIME 
				,dtmEndDate_Original DATETIME 
				,dblDiscount_Original NUMERIC(18, 6) 
				,dblAccumulatedAmount_Original NUMERIC(18, 6) 
				,dblAccumulatedQty_Original NUMERIC(18, 6) 
				,dblDiscountThruAmount_Original NUMERIC(18, 6) 
				,dblDiscountThruQty_Original NUMERIC(18, 6) 

				,dtmBeginDate_New DATETIME 
				,dtmEndDate_New DATETIME 
				,dblDiscount_New NUMERIC(18, 6) 
				,dblAccumulatedAmount_New NUMERIC(18, 6) 
				,dblAccumulatedQty_New NUMERIC(18, 6) 
				,dblDiscountThruAmount_New NUMERIC(18, 6) 
				,dblDiscountThruQty_New NUMERIC(18, 6) 
			)


		-- Add the filter records
		BEGIN
			IF(@strCompanyLocationId IS NOT NULL AND @strCompanyLocationId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Location (
						intLocationId
					)
					--SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
					SELECT [intID] AS intLocationId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCompanyLocationId)
				END
		
			IF(@strVendorId IS NOT NULL AND @strVendorId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Vendor (
						intVendorId
					)
					--SELECT intVendorId = CAST(@strVendorId AS INT)
					SELECT [intID] AS intVendorId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strVendorId)
				END

			IF(@strCategoryId IS NOT NULL AND @strCategoryId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Category (
						intCategoryId
					)
					--SELECT intCategoryId = CAST(@strCategoryId AS INT)
					SELECT [intID] AS intCategoryId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryId)
				END

			IF(@strFamilyId IS NOT NULL AND @strFamilyId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Family (
						intFamilyId
					)
					--SELECT intFamilyId = CAST(@strFamilyId AS INT)
					SELECT [intID] AS intFamilyId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strFamilyId)
				END

			IF(@strClassId IS NOT NULL AND @strClassId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Class (
						intClassId
					)
					--SELECT intClassId = CAST(@strClassId AS INT)
					SELECT [intID] AS intClassId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strClassId)
				END
		END


		BEGIN
		
			DECLARE @dtmBeginDateConv AS DATE = CAST(@dtmBeginDate AS DATE)
			DECLARE @dtmEndDateConv AS DATE = CAST(@dtmEndDate AS DATE)
			DECLARE @dblDiscount AS DECIMAL(18,6) = 0

			IF(@strPromotionType = 'Vendor Rebate')
				BEGIN
					SET @dblDiscount = @dblRebateAmount
				END
			ELSE IF(@strPromotionType = 'Vendor Discount')
				BEGIN
					SET @dblDiscount = @dblDiscAmountUnit
				END
		
			-- SP
			EXEC [uspICUpdateItemSpecialPricingForCStore]
			-- filter params
			@strUpcCode = NULL 
			,@strDescription = NULL 
			,@intItemId = NULL 
			-- update params
			,@dtmBeginDate = @dtmBeginDateConv
			,@dtmEndDate = @dtmEndDateConv
			,@dblDiscount = @dblDiscount
			,@dblAccumulatedAmount = @dblAccumAmount
			,@dblAccumulatedQty = @dblAccumlatedQty
			,@dblDiscountThruAmount = @dblDiscThroughAmount
			,@dblDiscountThruQty = @dblDiscThroughQty

			,@intEntityUserSecurityId = @intCurrentUserId
		END



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
					WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'Begin Date'
					WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'End Date'
					WHEN [Changes].oldColumnName = 'strDiscount_Original' THEN 'Discount'
					WHEN [Changes].oldColumnName = 'strAccumulatedAmount_Original' THEN 'Accumulated Amount'
					WHEN [Changes].oldColumnName = 'strAccumulatedQty_Original' THEN 'Accumulated Quantity'
					WHEN [Changes].oldColumnName = 'strDiscountThruAmount_Original' THEN 'Discount Through Amount'
					WHEN [Changes].oldColumnName = 'strDiscountThruQty_Original' THEN 'Discount Through Quantity'
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
						,CAST(CAST(dtmBeginDate_Original AS DATE) AS NVARCHAR(50)) AS strBeginDate_Original
						,CAST(CAST(dtmEndDate_Original AS DATE) AS NVARCHAR(50)) AS strEndDate_Original
						,CAST(CAST(dblDiscount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscount_Original
						,CAST(CAST(dblAccumulatedAmount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedAmount_Original
						,CAST(CAST(dblAccumulatedQty_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedQty_Original
						,CAST(CAST(dblDiscountThruAmount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruAmount_Original
						,CAST(CAST(dblDiscountThruQty_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruQty_Original

						,CAST(CAST(dtmBeginDate_New AS DATE) AS NVARCHAR(50)) AS strBeginDate_New
						,CAST(CAST(dtmEndDate_New AS DATE) AS NVARCHAR(50)) AS strEndDate_New
						,CAST(CAST(dblDiscount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscount_New
						,CAST(CAST(dblAccumulatedAmount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedAmount_New
						,CAST(CAST(dblAccumulatedQty_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedQty_New
						,CAST(CAST(dblDiscountThruAmount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruAmount_New
						,CAST(CAST(dblDiscountThruQty_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruQty_New
				FROM #tmpUpdateItemSpecialPricingForCStore_AuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strBeginDate_Original, strEndDate_Original, strDiscount_Original, strAccumulatedAmount_Original, strAccumulatedQty_Original, strDiscountThruAmount_Original, strDiscountThruQty_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strBeginDate_New, strEndDate_New, strDiscount_New, strAccumulatedAmount_New, strAccumulatedQty_New, strDiscountThruAmount_New, strDiscountThruQty_New)
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
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
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
			IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Location') IS NOT NULL  
				DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Location 

			IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Vendor') IS NOT NULL  
				DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Vendor 

			IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Category') IS NOT NULL  
				DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Category 

			IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Family') IS NOT NULL  
				DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Family 

			IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Class') IS NOT NULL  
				DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Class 

			-- Create the temp table for the audit log. 
			IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_AuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemSpecialPricingForCStore_AuditLog 
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