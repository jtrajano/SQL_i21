CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantISM]
@intCheckoutId Int,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows int OUTPUT
AS
BEGIN
	Begin Try

	DECLARE @intStoreId Int, @strAllowRegisterMarkUpDown nvarchar(50), @intShiftNo int, @intMarkUpDownId int
	Select @intStoreId = intStoreId, @intShiftNo = intShiftNo from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	DECLARE @intLocationId AS INT = (SELECT intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId)

	--INSERT INTO dbo.tblSTCheckoutItemMovements
	--SELECT DISTINCT @intCheckoutId 
	--, UOM.intItemUOMId
	--, I.strDescription
	--, IL.intVendorId
	--, ISNULL(CAST(Chk.SalesQuantity as int),0)
	--, ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
	--, ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
	--, P.dblStandardCost
	--, 1
	--from #tempCheckoutInsert Chk
	--JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
	--JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
	--JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	--JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
	--JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	--JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	--WHERE S.intStoreId = @intStoreId

	-- , ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0) + ISNULL(CAST(Chk.DiscountAmount as decimal(18,6)),0) --Need to add another column for discount

	--Removed DISTINCT
	BEGIN
		INSERT INTO dbo.tblSTCheckoutItemMovements
		(
			intCheckoutId
			, intItemUPCId
			, strDescription
			, intVendorId
			, intQtySold
			, dblCurrentPrice
			, dblDiscountAmount
			, dblTotalSales
			, dblItemStandardCost
			, intConcurrencyId
		)
		SELECT 
			intCheckoutId		= @intCheckoutId
		  , intItemUPCId		= UOM.intItemUOMId
		  , strDescription		= I.strDescription
		  , intVendorId			= IL.intVendorId
		  , intQtySold			= ISNULL(CAST(Chk.SalesQuantity as int),0)
		  , dblCurrentPrice		= ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
		  , dblDiscountAmount	= ISNULL(CAST(Chk.DiscountAmount as decimal(18,6)),0)
		  , dblTotalSales		= ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
		  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost as decimal(18,6)),0)
		  , intConcurrencyId	= 1
		from #tempCheckoutInsert Chk
		JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
		JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE S.intStoreId = @intStoreId
	END

	-- Add Mark Up or Down
    INSERT INTO dbo.tblSTCheckoutMarkUpDowns
    SELECT @intCheckoutId
         , IC.intCategoryId
		 , UOM.intItemUOMId
         , ISNULL(CAST(Chk.SalesQuantity as int),0)
         , ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
         , ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
	     , (CASE 
                WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > P.dblSalePrice THEN CAST((ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0) AS DECIMAL(18,6))
                WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < P.dblSalePrice THEN CAST((P.dblSalePrice - ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)) * ISNULL(CAST(Chk.SalesQuantity as int),0) AS DECIMAL(18,6))
            END) AS dblShrink
         , (CASE 
				WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > 0 THEN 'Mark Up'
                WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < 0 THEN 'Mark Down' 
                --WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > P.dblSalePrice THEN 'U Promotion'
                --WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < P.dblSalePrice THEN 'D Promotion' 
            END) AS strUpDownNotes
         , 1
    FROM #tempCheckoutInsert Chk
    JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
    JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
    JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
    JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
    JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
    JOIN dbo.tblICCategory IC ON IC.intCategoryId = I.intCategoryId
    JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
    WHERE S.intStoreId = @intStoreId
    AND ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) <> P.dblSalePrice


	-- Get MUD- next Batch number
	DECLARE @strMUDbatchId AS NVARCHAR(1000)
	EXEC uspSTGetMarkUpDownBatchId @strMUDbatchId OUT, @intLocationId

	-- Update batch no.
	UPDATE tblSTCheckoutHeader
	SET strMarkUpDownBatchNo = @strMUDbatchId
	WHERE intCheckoutId = @intCheckoutId


	------ NO SEPARATE ENTRIES ON MARK UP/DOWN UPON CHECKOUT
	--SELECT @strAllowRegisterMarkUpDown = strAllowRegisterMarkUpDown FROM dbo.tblSTStore Where intStoreId = @intStoreId
	--IF(@strAllowRegisterMarkUpDown <> 'None')
	--BEGIN

	--	-- Get MUD- next Batch number
	--	DECLARE @strMUDbatchId AS NVARCHAR(100)
	--	EXEC uspSTGetMarkUpDownBatchId @strMUDbatchId OUT, @intLocationId


	--	INSERT INTO dbo.tblSTMarkUpDown
	--	(
	--		intStoreId
	--		,dtmMarkUpDownDate
	--		,intShiftNo
	--		,strType
	--		,strAdjustmentType
	--		,intCheckoutId
	--		,strMarkUpDownNumber
	--		,ysnIsPosted
	--		,intConcurrencyId
	--	)
	--	SELECT @intStoreId
	--	      , GETDATE()
	--		  , @intShiftNo
	--		  , CASE 
	--				WHEN S.strAllowRegisterMarkUpDown = 'I' THEN 'Item Level' 
	--				WHEN S.strAllowRegisterMarkUpDown = 'D' THEN 'Department Level'
	--		    END 
	--		 , 'Regular'
	--		 , @intCheckoutId
	--		 , @strMUDbatchId
	--		 , CAST(0 AS BIT)
	--		 , 0
	--	FROM tblSTStore S 
	--	WHERE intStoreId = @intStoreId

	--	SET @intMarkUpDownId = @@IDENTITY

	--	INSERT INTO dbo.tblSTMarkUpDownDetail
	--	(
	--		intMarkUpDownId
	--		, intItemId
	--		, intCategoryId
	--		, strMarkUpOrDown
	--		, strRetailShrinkRS
	--		, intQty
	--		, dblRetailPerUnit
	--		, dblTotalRetailAmount
	--		, dblTotalCostAmount
	--		, strNote
	--		, dblActulaGrossProfit
	--		, ysnSentToHost
	--		, strReason
	--		, intConcurrencyId
	--	)
	--	SELECT 
	--		intMarkUpDownId			= @intMarkUpDownId
	--		, intItemId				= I.intItemId
	--		, intCategoryId			= I.intCategoryId
	--		, strMarkUpOrDown		= (CASE 
	--									WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > Pr.dblSalePrice THEN 'Mark Up'
	--									WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < Pr.dblSalePrice THEN 'Mark Down' 
	--								  END)
	--		, strRetailShrinkRS		= CAST(ISNULL(Chk.DiscountAmount, '') AS NVARCHAR(100))
	--		, intQty				= CAST(Chk.SalesQuantity as int)
	--		, dblRetailPerUnit		= (CASE 
	--									WHEN (SP.dtmBeginDate < GETDATE() AND SP.dtmEndDate > GETDATE()) THEN (ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)), 0) - (ISNULL(SP.dblUnit ,0) / ISNULL(UOM.dblUnitQty, 1)) )
	--									ELSE (ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)), 0) - (ISNULL(Pr.dblSalePrice ,0) / ISNULL(UOM.dblUnitQty, 1)) )
	--								  END)
	--		, dblTotalRetailAmount	= 0
	--		, dblTotalCostAmount	= 0
	--		, strNote				= 'On Sale'
	--		, dblActulaGrossProfit	= 0
	--		, ysnSentToHost			= 0
	--		, strReason				= ''
	--		, intConcurrencyId		= 0
	--	FROM #tempCheckoutInsert Chk
	--	JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
	--	JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
	--	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	--	Join dbo.tblICItemSpecialPricing SP ON I.intItemId = SP.intItemId AND IL.intItemLocationId = SP.intItemLocationId
	--	Join dbo.tblICItemPricing Pr ON Pr.intItemId = I.intItemId AND Pr.intItemLocationId = IL.intItemLocationId
	--	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	--	JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	--	WHERE S.intStoreId = @intStoreId


	--	UPDATE dbo.tblSTMarkUpDownDetail
	--	Set strMarkUpOrDown = (CASE WHEN dblRetailPerUnit > 0 THEN 'Mark Up' WHEN dblRetailPerUnit < 0 THEN 'Mark Down' END)
	--	, dblTotalRetailAmount = intQty * dblRetailPerUnit
	--	Where intMarkUpDownId = @intMarkUpDownId

	--	UPDATE dbo.tblSTMarkUpDownDetail
	--	SET strMarkUpOrDown = 'Mark Down' 
	--	Where strRetailShrinkRS <> ''

	--END

	SET @intCountRows = 1
	SET @strStatusMsg = 'Success'

	End Try

	Begin Catch
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END