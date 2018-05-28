CREATE PROCEDURE [dbo].[uspSTReportUpdateItemDataPreview]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRANSACTION

	DECLARE @ErrMsg NVARCHAR(MAX)

	--START Handle xml Param
	DECLARE @strCompanyLocationId 	   NVARCHAR(MAX),
			@strVendorId               NVARCHAR(MAX),
			@strCategoryId             NVARCHAR(MAX),
			@strFamilyId	           NVARCHAR(MAX),
			@strClassId                NVARCHAR(MAX),
			@intUpcCode                INT,
			@strDescription            NVARCHAR(250),
			@dblPriceBetween1             DECIMAL (18,6),
			@dblPriceBetween2             DECIMAL (18,6),
			@strTaxFlag1ysn               NVARCHAR(1),
			@strTaxFlag2ysn               NVARCHAR(1),
			@strTaxFlag3ysn               NVARCHAR(1),
			@strTaxFlag4ysn               NVARCHAR(1),
			@strDepositRequiredysn        NVARCHAR(1),
			@intDepositPLU                INT,
			@strQuantityRequiredysn       NVARCHAR(1),
			@strScaleItemysn              NVARCHAR(1),
			@strFoodStampableysn          NVARCHAR(1),
			@strReturnableysn             NVARCHAR(1),
			@strSaleableysn               NVARCHAR(1),
			@strID1Requiredysn            NVARCHAR(1),
			@strID2Requiredysn            NVARCHAR(1),
			@strPromotionalItemysn        NVARCHAR(1),
			@strPrePricedysn              NVARCHAR(1),
			@strActiveysn                 NVARCHAR(1),
			@strBlueLaw1ysn               NVARCHAR(1),
			@strBlueLaw2ysn               NVARCHAR(1),
			@strCountedDailyysn           NVARCHAR(1),
			@strCounted                   NVARCHAR(50),
			@strCountSerialysn            NVARCHAR(1),
			@strStickReadingysn           NVARCHAR(1),
			@intNewFamily                 INT,
			@intNewClass                  INT,
			@intNewProductCode            INT,
			@intNewCategory               INT,
			@intNewVendor                 INT,
			@intNewInventoryGroup         INT,
			@strNewCountCode              NVARCHAR(50),     
			@intNewMinAge                 INT,
			@dblNewMinVendorOrderQty      DECIMAL(18,6),
			@dblNewVendorSuggestedQty     DECIMAL(18,6),
			@dblNewMinQtyOnHand           DECIMAL(18,6),
			@intNewBinLocation            INT,
			@intNewGLPurchaseAccount      INT,
			@intNewGLSalesAccount         INT,
			--@intNewGLVarianceAccount      INT,
			@strYsnPreview                NVARCHAR(1),
			@intCurrentUserId			  INT

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

	--intUpcCode
	SELECT @intUpcCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intUpcCode'

	--strDescription
	SELECT @strDescription = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDescription'

	--dblPriceBetween1
	SELECT @dblPriceBetween1 = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblPriceBetween1'

	--dblPriceBetween2
	SELECT @dblPriceBetween2 = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblPriceBetween2'

	--strTaxFlag1ysn
	SELECT @strTaxFlag1ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag1ysn'

	--strTaxFlag2ysn
	SELECT @strTaxFlag2ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag2ysn'

	--strTaxFlag3ysn
	SELECT @strTaxFlag3ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag3ysn'

	--strTaxFlag4ysn
	SELECT @strTaxFlag4ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag4ysn'

	--strDepositRequiredysn
	SELECT @strDepositRequiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDepositRequiredysn'

	--intDepositPLU
	SELECT @intDepositPLU = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intDepositPLU'

	--strQuantityRequiredysn
	SELECT @strQuantityRequiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strQuantityRequiredysn'

	--strScaleItemysn
	SELECT @strScaleItemysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strScaleItemysn'

	--strFoodStampableysn
	SELECT @strFoodStampableysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strFoodStampableysn'

	--strReturnableysn
	SELECT @strReturnableysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strReturnableysn'

	--strSaleableysn
	SELECT @strSaleableysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strSaleableysn'

	--strID1Requiredysn
	SELECT @strID1Requiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strID1Requiredysn'

	--strID2Requiredysn
	SELECT @strID2Requiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strID2Requiredysn'

	--strPromotionalItemysn
	SELECT @strPromotionalItemysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strPromotionalItemysn'

	--strPrePricedysn
	SELECT @strPrePricedysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strPrePricedysn'

	--strActiveysn
	SELECT @strActiveysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strActiveysn'

	--strBlueLaw1ysn
	SELECT @strBlueLaw1ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strBlueLaw1ysn'

	--strBlueLaw2ysn 
	SELECT @strBlueLaw2ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strBlueLaw2ysn'

	--strCountedDailyysn 
	SELECT @strCountedDailyysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCountedDailyysn'

	--strCounted 
	SELECT @strCounted = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCounted'

	--strCountSerialysn 
	SELECT @strCountSerialysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCountSerialysn'

	--strStickReadingysn 
	SELECT @strStickReadingysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strStickReadingysn'

	--intNewFamily 
	SELECT @intNewFamily = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewFamily'

	--intNewClass 
	SELECT @intNewClass = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewClass'

	--intNewProductCode 
	SELECT @intNewProductCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewProductCode'

	--intNewCategory 
	SELECT @intNewCategory = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewCategory'

	--intNewVendor 
	SELECT @intNewVendor = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewVendor'

	--intNewInventoryGroup 
	SELECT @intNewInventoryGroup = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewInventoryGroup'

	--strNewCountCode 
	SELECT @strNewCountCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strNewCountCode'

	--intNewMinAge 
	SELECT @intNewMinAge = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewMinAge'

	--dblNewMinVendorOrderQty 
	SELECT @dblNewMinVendorOrderQty = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblNewMinVendorOrderQty'

	--dblNewVendorSuggestedQty 
	SELECT @dblNewVendorSuggestedQty = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblNewVendorSuggestedQty'

	--dblNewMinQtyOnHand 
	SELECT @dblNewMinQtyOnHand = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblNewMinQtyOnHand'

	--intNewBinLocation 
	SELECT @intNewBinLocation = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewBinLocation'

	--intNewGLPurchaseAccount 
	SELECT @intNewGLPurchaseAccount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewGLPurchaseAccount'

	--intNewGLSalesAccount 
	SELECT @intNewGLSalesAccount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewGLSalesAccount'

	----intNewGLVarianceAccount 
	--SELECT @intNewGLVarianceAccount = [from]
	--FROM @temp_xml_table
	--WHERE [fieldname] = 'intNewGLVarianceAccount'

	--strYsnPreview 
	SELECT @strYsnPreview = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strYsnPreview'

	--@intCurrentUserId
	SELECT @intCurrentUserId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intCurrentUserId'



	-- Create the temp table used for filtering. 
		BEGIN
			
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


		-- Item Audit Log
		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemForCStore_itemAuditLog (
				intItemId INT
				-- Original Fields
				,intCategoryId_Original INT NULL
				,strCountCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				,intCategoryId_New INT NULL
				,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			)
		;

		-- Item Account Audit Log
		IF OBJECT_ID('tempdb..#tmpUpdateItemAccountForCStore_itemAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemAccountForCStore_itemAuditLog (
				intItemId INT
				, intItemAccountId INT		
				, intAccountCategoryId INT 
				, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
				-- Original Fields	
				, intAccountId_Original INT NULL	
				-- Modified Fields	
				, intAccountId_New INT NULL		
			)
		;

		-- Item Location Audit Log
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
			)
		;


		-- Add the filter records
		BEGIN
			IF(@strCompanyLocationId IS NOT NULL AND @strCompanyLocationId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Location (
						intLocationId
					)
					--SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
					SELECT [intID] AS intLocationId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCompanyLocationId)
				END
		
			IF(@strVendorId IS NOT NULL AND @strVendorId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Vendor (
						intVendorId
					)
					--SELECT intVendorId = CAST(@strVendorId AS INT)
					SELECT [intID] AS intVendorId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strVendorId)
				END

			IF(@strCategoryId IS NOT NULL AND @strCategoryId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Category (
						intCategoryId
					)
					--SELECT intCategoryId = CAST(@strCategoryId AS INT)
					SELECT [intID] AS intCategoryId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strCategoryId)
				END

			IF(@strFamilyId IS NOT NULL AND @strFamilyId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Family (
						intFamilyId
					)
					--SELECT intFamilyId = CAST(@strFamilyId AS INT)
					SELECT [intID] AS intFamilyId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strFamilyId)
				END

			IF(@strClassId IS NOT NULL AND @strClassId != '')
				BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Class (
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

		BEGIN 
			-- Item Update
			EXEC [dbo].[uspICUpdateItemForCStore]
					@strUpcCode = @strUpcCode 
					,@strDescription = @strDescription 
					,@dblRetailPriceFrom = NULL  
					,@dblRetailPriceTo = NULL 

					,@intCategoryId = @intNewCategory
					,@strCountCode = @strNewCountCode

					,@intEntityUserSecurityId = @intCurrentUserId
		END


		BEGIN 
			-- Item Account
			EXEC [dbo].[uspICUpdateItemAccountForCStore]
				-- filter params
				@strUpcCode = @strUpcCode 
				,@strDescription = @strDescription 
				,@dblRetailPriceFrom = NULL  
				,@dblRetailPriceTo = NULL 
				-- update params
				,@intGLAccountCOGS = @intNewGLPurchaseAccount		-- If 'Cost of Goods'
				,@intGLAccountSalesRevenue = @intNewGLSalesAccount	-- If 'Sales Account'

				,@intEntityUserSecurityId = @intCurrentUserId
		END


		BEGIN 
			-- Item Location

			DECLARE @ysnTaxFlag1 AS BIT = CAST(@strTaxFlag1ysn AS BIT)
			DECLARE @ysnTaxFlag2 AS BIT = CAST(@strTaxFlag2ysn AS BIT)
			DECLARE @ysnTaxFlag3 AS BIT = CAST(@strTaxFlag3ysn AS BIT)
			DECLARE @ysnTaxFlag4 AS BIT = CAST(@strTaxFlag4ysn AS BIT)

			EXEC [dbo].[uspICUpdateItemLocationForCStore]
				@strUpcCode = @strUpcCode 
				,@strDescription = @strDescription 
				,@dblRetailPriceFrom = NULL  
				,@dblRetailPriceTo = NULL 

				,@ysnTaxFlag1 = @ysnTaxFlag1
				,@ysnTaxFlag2 = @ysnTaxFlag2
				,@ysnTaxFlag3 = @ysnTaxFlag3
				,@ysnTaxFlag4 = @ysnTaxFlag4
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
				,@intFamilyId = NULL
				,@intClassId = NULL
				,@intProductCodeId = NULL
				,@intVendorId = NULL
				,@intMinimumAge = NULL
				,@dblMinOrder = NULL
				,@dblSuggestedQty = NULL
				,@intCountGroupId = NULL
				,@intStorageLocationId = NULL
				,@dblReorderPoint = 1

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

		-- ITEM Preview
		DECLARE @strCategoryCode_New AS NVARCHAR(50) = (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = @intNewCategory)
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
				,CASE
					  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
				END
				,I.strDescription
				,CASE
					WHEN [Changes].intCategoryId_Original IS NOT NULL AND [Changes].intCategoryId_Original != [Changes].intCategoryId_New THEN 'Category'
					WHEN [Changes].strCountCode_Original IS NOT NULL AND [Changes].strCountCode_Original != ISNULL([Changes].strCountCode_New, 0) THEN 'Count Code'
				 END
				,CASE
					WHEN [Changes].intCategoryId_Original IS NOT NULL AND [Changes].intCategoryId_Original != [Changes].intCategoryId_New THEN CAST(ISNULL(Cat.strCategoryCode, '') AS NVARCHAR(50)) --CAST(ISNULL(intCategoryId_Original, '') AS NVARCHAR(50))
					WHEN [Changes].strCountCode_Original IS NOT NULL AND [Changes].strCountCode_Original != [Changes].strCountCode_New THEN CAST(ISNULL([Changes].strCountCode_Original, '') AS NVARCHAR(50))
				 END
				,CASE
					WHEN [Changes].intCategoryId_New IS NOT NULL AND [Changes].intCategoryId_Original != [Changes].intCategoryId_New THEN CAST(ISNULL(@strCategoryCode_New, '') AS NVARCHAR(50)) --CAST(ISNULL(intCategoryId_New, '') AS NVARCHAR(50))
					WHEN [Changes].strCountCode_New IS NOT NULL AND [Changes].strCountCode_Original != [Changes].strCountCode_New THEN CAST(ISNULL([Changes].strCountCode_New, '') AS NVARCHAR(50))
				 END
				,[Changes].intItemId 
				,[Changes].intItemId
		FROM #tmpUpdateItemForCStore_itemAuditLog [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		JOIN tblICCategory Cat ON [Changes].intCategoryId_Original = Cat.intCategoryId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
				strUpcCode IS NULL 
				OR EXISTS (
							SELECT TOP 1 1 
							FROM	tblICItemUOM uom 
							WHERE	uom.intItemId = @intUpcCode
							AND (uom.strUpcCode = @strUpcCode OR uom.strLongUPCCode = @strUpcCode)
						)
		)





		-- ITEM ACCOUNT Preview
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
				,CASE
					  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
				END
				,I.strDescription
				,AC.strAccountCategory
				,CAST(ISNULL([Changes].intAccountId_Original, '') AS NVARCHAR(50))
				,CAST(ISNULL([Changes].intAccountId_New, '') AS NVARCHAR(50))
				,[Changes].intItemId 
				,[Changes].intItemAccountId
		FROM #tmpUpdateItemAccountForCStore_itemAuditLog [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemAccount IA ON [Changes].intItemAccountId = IA.intItemAccountId
		JOIN tblGLAccountCategory AC ON IA.intAccountCategoryId = AC.intAccountCategoryId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
				strUpcCode IS NULL 
				OR EXISTS (
							SELECT TOP 1 1 
							FROM	tblICItemUOM uom 
							WHERE	uom.intItemId = @intUpcCode
							AND (uom.strUpcCode = @strUpcCode OR uom.strLongUPCCode = @strUpcCode)
						)
		)




		-- ITEM LOCATION Preview
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
				,CASE
					  WHEN UOM.strLongUPCCode IS NOT NULL AND UOM.strLongUPCCode != '' THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
				END
				,I.strDescription
				,CASE
					WHEN [Changes].ysnTaxFlag1_Original IS NOT NULL AND [Changes].ysnTaxFlag1_Original != [Changes].ysnTaxFlag1_New THEN 'Tax Flag 1'
					WHEN [Changes].ysnTaxFlag2_Original IS NOT NULL AND [Changes].ysnTaxFlag2_Original != [Changes].ysnTaxFlag2_New THEN 'Tax Flag 2'
					WHEN [Changes].ysnTaxFlag3_Original IS NOT NULL AND [Changes].ysnTaxFlag3_Original != [Changes].ysnTaxFlag3_New THEN 'Tax Flag 3'
					WHEN [Changes].ysnTaxFlag4_Original IS NOT NULL AND [Changes].ysnTaxFlag4_Original != [Changes].ysnTaxFlag4_New THEN 'Tax Flag 4'
				 END
				,CASE
					WHEN [Changes].ysnTaxFlag1_Original IS NOT NULL AND [Changes].ysnTaxFlag1_Original != [Changes].ysnTaxFlag1_New THEN CAST(CAST([Changes].ysnTaxFlag1_Original AS BIT) AS NVARCHAR(10))
					WHEN [Changes].ysnTaxFlag2_Original IS NOT NULL AND [Changes].ysnTaxFlag2_Original != [Changes].ysnTaxFlag2_New THEN CAST([Changes].ysnTaxFlag2_Original AS NVARCHAR(10))
					WHEN [Changes].ysnTaxFlag3_Original IS NOT NULL AND [Changes].ysnTaxFlag3_Original != [Changes].ysnTaxFlag3_New THEN CAST([Changes].ysnTaxFlag3_Original AS NVARCHAR(10))
					WHEN [Changes].ysnTaxFlag4_Original IS NOT NULL AND [Changes].ysnTaxFlag4_Original != [Changes].ysnTaxFlag4_New THEN CAST([Changes].ysnTaxFlag4_Original AS NVARCHAR(10))
				 END
				,CASE
					WHEN [Changes].ysnTaxFlag1_Original IS NOT NULL AND [Changes].ysnTaxFlag1_Original != [Changes].ysnTaxFlag1_New THEN CAST([Changes].ysnTaxFlag1_New AS NVARCHAR(10))
					WHEN [Changes].ysnTaxFlag2_Original IS NOT NULL AND [Changes].ysnTaxFlag2_Original != [Changes].ysnTaxFlag2_New THEN CAST([Changes].ysnTaxFlag2_New AS NVARCHAR(10))
					WHEN [Changes].ysnTaxFlag3_Original IS NOT NULL AND [Changes].ysnTaxFlag3_Original != [Changes].ysnTaxFlag3_New THEN CAST([Changes].ysnTaxFlag3_New AS NVARCHAR(10))
					WHEN [Changes].ysnTaxFlag4_Original IS NOT NULL AND [Changes].ysnTaxFlag4_Original != [Changes].ysnTaxFlag4_New THEN CAST([Changes].ysnTaxFlag4_New AS NVARCHAR(10))
				 END
				,[Changes].intItemId 
				,[Changes].intItemLocationId
		FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemLocation IL ON I.intItemId = IL.intItemId 
		JOIN tblICItemUOM UOM ON IL.intItemId = UOM.intItemId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
				strUpcCode IS NULL 
				OR EXISTS (
							SELECT TOP 1 1 
							FROM	tblICItemUOM uom 
							WHERE	uom.intItemId = @intUpcCode
							AND (uom.strUpcCode = @strUpcCode OR uom.strLongUPCCode = @strUpcCode)
						)
		)






	   DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')

	   -- Query Preview display
	   SELECT DISTINCT 
	          strLocation
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

			IF OBJECT_ID('tempdb..#tmpUpdateItemAccountForCStore_itemAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemAccountForCStore_itemAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		END

ROLLBACK TRANSACTION