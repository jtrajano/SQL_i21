CREATE PROCEDURE [dbo].[uspSTUpdateRebateOrDiscount]
	@XML varchar(max)
	
AS
BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
	        @idoc					INT,
	    	@Location 			    NVARCHAR(MAX),
			@Vendor                 NVARCHAR(MAX),
			@Category               NVARCHAR(MAX),
			@Family                 NVARCHAR(MAX),
			@Class                  NVARCHAR(MAX),
			@PromotionType          NVARCHAR(50),
			@BeginDate   			NVARCHAR(50),     
			@EndDate		 	    NVARCHAR(50),     
		    @RebateAmount           DECIMAL (18,6),
			@AccumlatedQty          DECIMAL (18,6),
			@AccumAmount            DECIMAL (18,6),
			@DiscThroughAmount      DECIMAL (18,6),
			@DiscThroughQty         DECIMAL (18,6),
			@DiscAmountUnit         DECIMAL (18,6),
			@ysnPreview             NVARCHAR(1),
			@currentUserId			INT
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location	   	    =	Location,
            @Vendor             =   Vendor,
			@Category           =   Category,
			@Family             =   Family,
            @Class              =   Class,
			@PromotionType      =   PromotionTypeValue, 
			@BeginDate          =   BeginingDate,
			@EndDate            =   EndingDate,
			@RebateAmount 	    =	RebateAmount,
			@AccumlatedQty	    =	AccumlatedQuantity,
			@AccumAmount	    =	AccumlatedAmount,
		    @DiscThroughAmount  =   DiscThroughAmount,
			@DiscThroughQty     =   DiscThroughQty,
			@DiscAmountUnit     =   DiscAmountUnit,
			@ysnPreview			=	ysnPreview,
			@currentUserId		=   currentUserId

	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			PromotionTypeValue      NVARCHAR(50),
			BeginingDate            NVARCHAR(50),     
			EndingDate              NVARCHAR(50),     
			RebateAmount		    DECIMAL (18,6),
			AccumlatedQuantity		DECIMAL (18,6),
			AccumlatedAmount        DECIMAL (18,6),
			DiscThroughAmount       DECIMAL (18,6),
			DiscThroughQty          DECIMAL (18,6),
			DiscAmountUnit          DECIMAL (18,6),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)		



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
		IF(@Location IS NOT NULL AND @Location != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Location (
					intLocationId
				)
				--SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
				SELECT [intID] AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
			END
		
		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Vendor (
					intVendorId
				)
				--SELECT intVendorId = CAST(@strVendorId AS INT)
				SELECT [intID] AS intVendorId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Category (
					intCategoryId
				)
				--SELECT intCategoryId = CAST(@strCategoryId AS INT)
				SELECT [intID] AS intCategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Family (
					intFamilyId
				)
				--SELECT intFamilyId = CAST(@strFamilyId AS INT)
				SELECT [intID] AS intFamilyId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Class (
					intClassId
				)
				--SELECT intClassId = CAST(@strClassId AS INT)
				SELECT [intID] AS intClassId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
			END
	END


	BEGIN
		
		DECLARE @dtmBeginDateConv AS DATE = CAST(@BeginDate AS DATE)
		DECLARE @dtmEndDateConv AS DATE = CAST(@EndDate AS DATE)
		DECLARE @dblDiscount AS DECIMAL(18,6) = 0

		IF(@PromotionType = 'Vendor Rebate')
			BEGIN
				SET @dblDiscount = @RebateAmount
				SET @PromotionType = 'Rebate'

				-- SP
				EXEC [uspICUpdateItemSpecialPricingForCStore]
					-- filter params
					@strUpcCode = NULL 
					,@strDescription = NULL 
					,@intItemId = NULL 
					,@strPromotionType = @PromotionType
					-- update params
					,@dtmBeginDate = @dtmBeginDateConv
					,@dtmEndDate = @dtmEndDateConv
					,@dblDiscount = @dblDiscount

					,@dblAccumulatedAmount = @AccumAmount
					,@dblAccumulatedQty = @AccumlatedQty

					,@dblDiscountThruAmount = NULL
					,@dblDiscountThruQty = NULL

					,@intEntityUserSecurityId = @currentUserId
			END
		ELSE IF(@PromotionType = 'Vendor Discount')
			BEGIN
				SET @dblDiscount = @DiscAmountUnit

				-- SP
					EXEC [uspICUpdateItemSpecialPricingForCStore]
						-- filter params
						@strUpcCode = NULL 
						,@strDescription = NULL 
						,@intItemId = NULL 
						,@strPromotionType = @PromotionType
						-- update params
						,@dtmBeginDate = @dtmBeginDateConv
						,@dtmEndDate = @dtmEndDateConv
						,@dblDiscount = @dblDiscount

						,@dblAccumulatedAmount = NULL
						,@dblAccumulatedQty = NULL

						,@dblDiscountThruAmount = @DiscThroughAmount
						,@dblDiscountThruQty = @DiscThroughQty

						,@intEntityUserSecurityId = @currentUserId
			END
	END




	-------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
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
	-------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------


	DECLARE @RecCount AS INT = (SELECT COUNT(*) FROM @tblPreview)
	DECLARE @UpdateCount AS INT = (SELECT COUNT(DISTINCT intChildId) FROM @tblPreview)

	SELECT  @RecCount as RecCount,  @UpdateCount as UpdateItemPrcicingCount	

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH