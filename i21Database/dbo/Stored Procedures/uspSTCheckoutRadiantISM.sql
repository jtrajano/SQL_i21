﻿CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantISM]
@intCheckoutId Int
AS
BEGIN

	DECLARE @intStoreId Int, @strAllowRegisterMarkUpDown nvarchar(50), @intShiftNo int, @intMarkUpDownId int
	Select @intStoreId = intStoreId, @intShiftNo = intShiftNo from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	INSERT INTO dbo.tblSTCheckoutItemMovements
	SELECT @intCheckoutId 
	, UOM.intItemUOMId
	, I.strDescription
	, IL.intVendorId
	, Chk.SalesQuantity
	, Chk.ActualSalesPrice
	, Chk.SalesAmount
	, 0
	from #tempCheckoutInsert Chk
	JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
	JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	WHERE S.intStoreId = @intStoreId

	--SELECT @strAllowRegisterMarkUpDown = strAllowRegisterMarkUpDown FROM dbo.tblSTStore Where intStoreId = @intStoreId
	--IF(@strAllowRegisterMarkUpDown <> 'None')
	--BEGIN

	--	--IF(@strAllowRegisterMarkUpDown = 'I')
	
	--	INSERT INTO dbo.tblSTMarkUpDown
	--	SELECT @intStoreId, GETDATE(), @intShiftNo
	--	, CASE WHEN S.strAllowRegisterMarkUpDown = 'I' THEN 'Item Level' 
	--			WHEN S.strAllowRegisterMarkUpDown = 'D' THEN 'Department Level'
	--	  END 
	--	, 'Regular'
	--	, 0
	--	FROM tblSTStore S

	--	SET @intMarkUpDownId = @@IDENTITY

	--	INSERT INTO dbo.tblSTMarkUpDownDetail
	--	SELECT @intMarkUpDownId
	--	, UOM.intItemUOMId
	--	, I.intCategoryId
	--	, '' [strMarkUpOrDown]
	--	, ISNULL(Chk.DiscountAmount, '') [strRetailShrinkRS]
	--	, Chk.SalesQuantity [intQty]
	--	, CASE WHEN (SP.dtmBeginDate < GETDATE() AND SP.dtmEndDate > GETDATE()) THEN (ISNULL(Chk.ActualSalesPrice, 0) - (ISNULL(SP.dblUnit ,0) / ISNULL(UOM.dblUnitQty, 1)) )
	--			ELSE (ISNULL(Chk.ActualSalesPrice, 0) - (ISNULL(Pr.dblSalePrice ,0) / ISNULL(UOM.dblUnitQty, 1)) )
	--		END [dblRetailPerUnit]
	--	, 0 [dblTotalRetailAmount]
	--	, 0 [dblTotalCostAmount]
	--	, 'On Sale' [strNote]
	--	, 0 [dblActulaGrossProfit]
	--	, 'N' [ysnSentToHost]
	--	, '' [strReason]
	--	, 0
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

END
