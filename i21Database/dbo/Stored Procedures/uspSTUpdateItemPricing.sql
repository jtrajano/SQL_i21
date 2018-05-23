CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
	@XML varchar(max)
	, @strEntityIds AS NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY

	SET @strEntityIds = ''

	DECLARE @ErrMsg				NVARCHAR(MAX),
	        @idoc				INT,
			@Location 			NVARCHAR(MAX),
			@Vendor             NVARCHAR(MAX),
			@Category           NVARCHAR(MAX),
			@Family             NVARCHAR(MAX),
			@Class              NVARCHAR(MAX),
			@Description        NVARCHAR(250),
			@Region             NVARCHAR(6),
			@District           NVARCHAR(6),
			@State              NVARCHAR(2),
			@UpcCode            NVARCHAR(MAX),
			@StandardCost       DECIMAL (18,6),
			@RetailPrice        DECIMAL (18,6),
			@SalesPrice         DECIMAL (18,6),
		    @SalesStartDate		NVARCHAR(50),
			@SalesEndDate   	NVARCHAR(50),
			@ysnPreview			NVARCHAR(1),
			@currentUserId		INT
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location		 =	 Location,
            @Vendor          =   Vendor,
			@Category        =   Category,
			@Family          =   Family,
            @Class           =   Class,
            @Description     =   ItmDescription,
			@Region          =   Region,
			@District        =   District,
			@State           =   States,
			@UpcCode         =   UPCCode,
			@StandardCost 	 = 	 Cost,
			@RetailPrice   	 =	 Retail,
			@SalesPrice		 =	 SalesPrice,
			@SalesStartDate	 =	 SalesStartingDate,
			@SalesEndDate	 =	 SalesEndingDate,
			@ysnPreview		 =   ysnPreview,
			@currentUserId   =   currentUserId
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			ItmDescription		    NVARCHAR(250),
			Region                  NVARCHAR(6),
			District                NVARCHAR(6),
			States                  NVARCHAR(2),
			UPCCode		            NVARCHAR(MAX),
			Cost		            DECIMAL (18,6),
			Retail		            DECIMAL (18,6),
			SalesPrice       		DECIMAL (18,6),
			SalesStartingDate		NVARCHAR(50),
			SalesEndingDate			NVARCHAR(50),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)  
    -- Insert statements for procedure here


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
				,dblNewStandardCost NUMERIC(38, 20) NULL
				,dblNewSalePrice NUMERIC(38, 20) NULL
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
		IF(@Location IS NOT NULL AND @Location != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Location (
					intLocationId
				)
				SELECT intLocationId = CAST(@Location AS INT)
			END
		
		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
					intVendorId
				)
				SELECT intVendorId = CAST(@Vendor AS INT)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Category (
					intCategoryId
				)
				SELECT intCategoryId = CAST(@Category AS INT)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Family (
					intFamilyId
				)
				SELECT intFamilyId = CAST(@Family AS INT)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Class (
					intClassId
				)
				SELECT intClassId = CAST(@Class AS INT)
			END
	END

	DECLARE @dblStandardCostConv AS DECIMAL(18, 6) = CAST(@StandardCost AS DECIMAL(18, 6))
	DECLARE @dblRetailPriceConv AS DECIMAL(18, 6) = CAST(@RetailPrice AS DECIMAL(18, 6))
	DECLARE @intCurrentUserIdConv AS INT = CAST(@currentUserId AS INT)

	-- ITEM PRICING
	EXEC [uspICUpdateItemPricingForCStore]
		@dblStandardCost = @dblStandardCostConv
		,@dblRetailPrice = @dblRetailPriceConv
		,@intEntityUserSecurityId = @intCurrentUserIdConv



	DECLARE @dblSalesPriceConv AS DECIMAL(18, 6) = CAST(@SalesPrice AS DECIMAL(18, 6))
	DECLARE @dtmSalesStartingDateConv AS DATE = CAST(@SalesStartDate AS DATE)
	DECLARE @dtmSalesEndingDateConv AS DATE = CAST(@SalesEndDate AS DATE)

	-- ITEM SPECIAL PRICING
	EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
		@dblPromotionalSalesPrice = @dblSalesPriceConv 
		,@dtmBeginDate = @dtmSalesStartingDateConv
		,@dtmEndDate = @dtmSalesEndingDateConv 
		,@intEntityUserSecurityId = @intCurrentUserIdConv




	DECLARE @RecCount AS INT = 0
	DECLARE @UpdateCount AS INT = 0

	SET @RecCount = @RecCount + (SELECT COUNT(*) FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog WHERE dblOldSalePrice != dblNewSalePrice AND dblOldStandardCost != dblNewStandardCost)
	SET @RecCount = @RecCount + (SELECT COUNT(*) FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog WHERE dblOldUnitAfterDiscount != dblNewUnitAfterDiscount AND dtmOldBeginDate != dtmNewBeginDate AND dtmOldEndDate != dtmNewEndDate)

	SET @UpdateCount = @UpdateCount + (SELECT COUNT(DISTINCT intItemPricingId) FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
	SET @UpdateCount = @UpdateCount + (SELECT COUNT(DISTINCT intItemSpecialPricingId) FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog)

	SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount


END TRY

BEGIN CATCH  
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')         
END CATCH