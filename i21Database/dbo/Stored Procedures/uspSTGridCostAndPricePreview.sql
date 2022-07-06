CREATE PROCEDURE [dbo].[uspSTGridCostAndPricePreview]
    @XML VARCHAR(MAX),
    @XMLGrid VARCHAR(MAX),
    @ysnRecap BIT,
    @strGuid UNIQUEIDENTIFIER,
    @strEntityIds AS NVARCHAR(MAX) OUTPUT,
    @strResultMsg NVARCHAR(1000) OUTPUT
AS
BEGIN TRY

    BEGIN TRANSACTION

    SET @strEntityIds = ''

    DECLARE @dtmDateTimeModifiedFrom AS DATETIME
    DECLARE @dtmDateTimeModifiedTo AS DATETIME

    DECLARE @ErrMsg NVARCHAR(MAX),
            @idoc INT,
            @idocGrid INT,
            @StoreGroup NVARCHAR(MAX),
            @Location NVARCHAR(MAX),
            @Vendor NVARCHAR(MAX),
            @Family NVARCHAR(MAX),
            @Class NVARCHAR(MAX),
            @StartDate NVARCHAR(50),
            @EndDate NVARCHAR(50),
            @FixedRetail BIT,
            @CategoryMargin BIT,
            @GivenMarginBool BIT,
            @GivenMargin DECIMAL(18, 6),
            @RetailRounding BIT,
            @strItemId NVARCHAR(MAX),
            @strNewCost NVARCHAR(MAX)


    EXEC sp_xml_preparedocument @idoc OUTPUT, @XML
	
    EXEC sp_xml_preparedocument @idocGrid OUTPUT, @XMLGrid


    SELECT @StoreGroup = StoreGroup,
           @Location = Location,
           @Vendor = Vendor,
           @Family = Family,
           @Class = Class,
           @StartDate = StartDate,
           @EndDate = EndDate,
           @FixedRetail = FixedRetail,
           @CategoryMargin = CategoryMargin,
           @GivenMarginBool = GivenMarginBool,
           @GivenMargin = GivenMargin,
           @RetailRounding = RetailRounding
    FROM
        OPENXML(@idoc, 'root', 2)
        WITH
        (
            StoreGroup NVARCHAR(MAX),
            Location NVARCHAR(MAX),
            Vendor NVARCHAR(MAX),
            Family NVARCHAR(MAX),
            Class NVARCHAR(MAX),
            StartDate NVARCHAR(250),
            EndDate NVARCHAR(250),
            FixedRetail BIT,
            CategoryMargin BIT,
            GivenMarginBool BIT,
            GivenMargin DECIMAL(18, 6),
            RetailRounding BIT
        )

		
    SELECT @strItemId 	 = ItemId,
           @strNewCost	 = NewCost
    FROM
        OPENXML(@idocGrid, 'root', 2)
        WITH
        (
            ItemId NVARCHAR(MAX),
            NewCost NVARCHAR(MAX)
        )
    -- Insert statements for procedure here

	


    -- Create the filter tables
    BEGIN
        IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Grid') IS NULL
        BEGIN
            CREATE TABLE #tmpUpdateGridCostAndPrice_Grid (intItemId INT, dblNewCost NUMERIC(18,2))
        END

        IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Location') IS NULL
        BEGIN
            CREATE TABLE #tmpUpdateGridCostAndPrice_Location (intLocationId INT)
        END

        IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Vendor') IS NULL
        BEGIN
            CREATE TABLE #tmpUpdateGridCostAndPrice_Vendor (intVendorId INT)
        END

        IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NULL
        BEGIN
            CREATE TABLE #tmpUpdateItemPricingForCStore_Category (intCategoryId INT)
        END

        IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Family') IS NULL
        BEGIN
            CREATE TABLE #tmpUpdateGridCostAndPrice_Family (intFamilyId INT)
        END

        IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Class') IS NULL
        BEGIN
            CREATE TABLE #tmpUpdateGridCostAndPrice_Class (intClassId INT)
        END

        -- Create the temp table for the result table
        IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice') IS NULL
            CREATE TABLE #tmpUpdateGridCostAndPrice
            (
                strVendorItemNumber VARCHAR(MAX),
                strDescription VARCHAR(MAX),
                dblNewCost DECIMAL(18, 6) NULL,
                strLocation VARCHAR(MAX),
                strLongUPCCode VARCHAR(MAX),
                strUnit VARCHAR(MAX),
                intQuantity INT,
                dblPrice DECIMAL(18, 6) NULL,
                strCategory VARCHAR(MAX),
                dblCategoryMargin DECIMAL(18, 6) NULL,
                strFamily VARCHAR(MAX),
                strClass VARCHAR(MAX)
            );
    END


    -- Add the filter records
    BEGIN
        IF (@strItemId IS NOT NULL AND @strItemId != '')
        BEGIN
            INSERT INTO #tmpUpdateGridCostAndPrice_Grid
            (
                intItemId,
				dblNewCost
            )
            SELECT DISTINCT
                intItemId AS intItemId,
                dblNewCost AS dblNewCost
            FROM (SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY strDataType ASC) AS intRow, CAST(strDataType AS INT) AS intItemId FROM dbo.fnARSplitValues(@strItemId, ',')) AS item
				, (SELECT ROW_NUMBER() OVER(ORDER BY strDataType ASC) AS intRowCost, CAST(strDataType AS NUMERIC(16,2)) AS dblNewCost FROM dbo.fnARSplitValues(@strNewCost, ',')) AS cost
				WHERE item.intRow = cost.intRowCost) AS tblItems
        END

        IF (@Location IS NOT NULL AND @Location != '')
        BEGIN
            INSERT INTO #tmpUpdateGridCostAndPrice_Location
            (
                intLocationId
            )
            SELECT DISTINCT
                [intID] AS intLocationId
            FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
        END

        IF (@StoreGroup IS NOT NULL AND @StoreGroup != '')
        BEGIN
            INSERT INTO #tmpUpdateGridCostAndPrice_Location
            (
                intLocationId
            )
            SELECT DISTINCT
                st.intCompanyLocationId AS intLocationId
            FROM [dbo].[fnGetRowsFromDelimitedValues](@StoreGroup)
                INNER JOIN tblSTStoreGroup sg
                    ON sg.intStoreGroupId = intID
                INNER JOIN tblSTStoreGroupDetail sgt
                    ON sgt.intStoreGroupId = sg.intStoreGroupId
                INNER JOIN tblSTStore st
                    ON st.intStoreId = sgt.intStoreId
        END

        IF (@Vendor IS NOT NULL AND @Vendor != '')
        BEGIN
            INSERT INTO #tmpUpdateGridCostAndPrice_Vendor
            (
                intVendorId
            )
            SELECT [intID] AS intVendorId
            FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
        END

        IF (@Family IS NOT NULL AND @Family != '')
        BEGIN
            INSERT INTO #tmpUpdateGridCostAndPrice_Family
            (
                intFamilyId
            )
            SELECT [intID] AS intFamilyId
            FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
        END

        IF (@Class IS NOT NULL AND @Class != '')
        BEGIN
            INSERT INTO #tmpUpdateGridCostAndPrice_Class
            (
                intClassId
            )
            SELECT [intID] AS intClassId
            FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
        END
    END
	
    SELECT DISTINCT 
		   ISNULL((SELECT TOP 1 strVendorProduct FROM tblICItemVendorXref WHERE intItemId = it.intItemId), '') AS strVendorItemNumber,
           it.intItemId AS intItemId,
           it.strDescription AS strDescription,
           CAST(tmp_item.dblNewCost AS NUMERIC(18, 6)) AS dblNewCost,
           ill.strLocationName AS strLocation,
           st.intStoreNo AS intStoreNo,
           uom.strLongUPCCode AS strLongUPCCode,
           um.strUnitMeasure AS strUnit,
           CAST(uom.dblUnitQty AS INT) AS intQuantity,
				CAST(ROUND(CAST(
					CASE
						WHEN (SELECT TOP 1 dblUnitAfterDiscount 
								FROM tblICItemSpecialPricing spr 
								WHERE @StartDate BETWEEN spr.dtmBeginDate AND spr.dtmEndDate
									AND spr.intItemLocationId = il.intItemLocationId) != 0
							THEN (SELECT TOP 1 dblUnitAfterDiscount 
								FROM tblICItemSpecialPricing spr 
								WHERE @StartDate BETWEEN spr.dtmBeginDate AND spr.dtmEndDate
									AND spr.intItemLocationId = il.intItemLocationId)
						WHEN (@StartDate >= (SELECT TOP 1 dtmEffectiveRetailPriceDate FROM tblICEffectiveItemPrice EIP 
													WHERE EIP.intItemLocationId = il.intItemLocationId
													AND @StartDate >= dtmEffectiveRetailPriceDate
													ORDER BY dtmEffectiveRetailPriceDate ASC))
							THEN (SELECT TOP 1 dblRetailPrice FROM tblICEffectiveItemPrice EIP 
													WHERE EIP.intItemLocationId = il.intItemLocationId
													AND @StartDate >= dtmEffectiveRetailPriceDate
													ORDER BY dtmEffectiveRetailPriceDate ASC) --Effective Retail Price
						WHEN ISNULL(ipr.intItemPricingId, 0) != 0
							THEN ipr.dblSalePrice
						ELSE 0
					END 
			AS FLOAT),2) AS NUMERIC(18,6))
			AS dblCurrentRetailPrice,
           CASE WHEN @CategoryMargin = 'true'
			THEN ISNULL(catloc.dblTargetGrossProfit, 0)
		   ELSE 0
		   END AS dblCategoryMargin, 
           ISNULL(@GivenMargin, 0) AS dblGivenMargin, 
		   cat.strCategoryCode AS strCategory,
           fam.strSubcategoryDesc AS strFamily,
           class.strSubcategoryDesc AS strClass
    FROM tblICItem it
        JOIN tblICItemLocation il
            ON it.intItemId = il.intItemId
        JOIN tblICItemUOM uom
            ON it.intItemId = uom.intItemId
               AND uom.ysnStockUnit = 1
        JOIN tblICUnitMeasure um
            ON uom.intUnitMeasureId = um.intUnitMeasureId
        JOIN tblICCategory cat
            ON it.intCategoryId = cat.intCategoryId
        LEFT JOIN tblICCategoryLocation catloc
            ON cat.intCategoryId = catloc.intCategoryId AND catloc.intLocationId = il.intLocationId
        LEFT JOIN tblSTSubcategory fam
            ON il.intFamilyId = fam.intSubcategoryId
        LEFT JOIN tblSTSubcategory class
            ON il.intClassId = class.intSubcategoryId
        LEFT JOIN tblICItemPricing ipr
            ON ipr.intItemLocationId = il.intItemLocationId
        JOIN tblSMCompanyLocation ill
            ON il.intLocationId = ill.intCompanyLocationId
        JOIN tblSTStore st
            ON ill.intCompanyLocationId = st.intCompanyLocationId
		JOIN #tmpUpdateGridCostAndPrice_Grid tmp_item
			ON it.intItemId = tmp_item.intItemId
    WHERE (
              NOT EXISTS
    (
        SELECT TOP 1 1 FROM #tmpUpdateGridCostAndPrice_Location
    )
              OR EXISTS
    (
        SELECT TOP 1
            1
        FROM #tmpUpdateGridCostAndPrice_Location
        WHERE intLocationId = il.intLocationId
    )
          )
          AND (
                  NOT EXISTS
    (
        SELECT TOP 1 1 FROM #tmpUpdateGridCostAndPrice_Vendor
    )
                  OR EXISTS
    (
        SELECT TOP 1
            1
        FROM #tmpUpdateGridCostAndPrice_Vendor
        WHERE intVendorId = il.intVendorId
    )
              )
          AND (
                  NOT EXISTS
    (
        SELECT TOP 1 1 FROM #tmpUpdateGridCostAndPrice_Family
    )
                  OR EXISTS
    (
        SELECT TOP 1
            1
        FROM #tmpUpdateGridCostAndPrice_Family
        WHERE intFamilyId = il.intFamilyId
    )
              )
          AND (
                  NOT EXISTS
    (
        SELECT TOP 1 1 FROM #tmpUpdateGridCostAndPrice_Class
    )
                  OR EXISTS
    (
        SELECT TOP 1
            1
        FROM #tmpUpdateGridCostAndPrice_Class
        WHERE intClassId = il.intClassId
    )
              )
	AND it.strStatus != 'Discontinued'
	
    IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Grid') IS NOT NULL
        DROP TABLE #tmpUpdateGridCostAndPrice_Grid

    IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Location') IS NOT NULL
        DROP TABLE #tmpUpdateGridCostAndPrice_Location

    IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Vendor') IS NOT NULL
        DROP TABLE #tmpUpdateGridCostAndPrice_Vendor

    IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Family') IS NOT NULL
        DROP TABLE #tmpUpdateGridCostAndPrice_Family

    IF OBJECT_ID('tempdb..#tmpUpdateGridCostAndPrice_Class') IS NOT NULL
        DROP TABLE #tmpUpdateGridCostAndPrice_Class


    -- Handle Returned Table
    IF (@ysnRecap = 1)
    BEGIN
        -- Exit
        GOTO ExitPost
    END
    ELSE IF (@ysnRecap = 0)
    BEGIN
        -- Commit transaction
        GOTO ExitWithCommit

    ----TEST
    --GOTO ExitWithRollback
    END


END TRY
BEGIN CATCH

    SET @ErrMsg = ERROR_MESSAGE()
    --SET @strResultMsg = ERROR_MESSAGE()
    SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE() --+ '<\BR>' + 
    IF @idoc <> 0
        EXEC sp_xml_removedocument @idoc
    --RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  

    GOTO ExitWithRollback
END CATCH



ExitWithCommit:
COMMIT TRANSACTION
GOTO ExitPost


ExitWithRollback:
IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRANSACTION
END


ExitPost:
