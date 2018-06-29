



CREATE PROCEDURE [dbo].[uspSTCheckoutNucleusISM]
@intCheckoutId Int
AS
BEGIN

	DECLARE @intStoreId Int, @strAllowRegisterMarkUpDown nvarchar(50), @intShiftNo int, @intMarkUpDownId int
	Select @intStoreId = intStoreId, @intShiftNo = intShiftNo from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

	INSERT INTO dbo.tblSTCheckoutItemMovements
	SELECT DISTINCT @intCheckoutId 
	, UOM.intItemUOMId
	, I.strDescription
	, IL.intVendorId
	, (ISNULL(CAST(Chk.SalesQuantity as int),0) - ISNULL(CAST(Chk.RefundCount as int),0))
	, CASE WHEN (SP.dtmBeginDate < GETDATE() AND SP.dtmEndDate > GETDATE()) THEN (ISNULL(SP.dblUnit ,0) / ISNULL(UOM.dblUnitQty, 1))
				ELSE (ISNULL(Pr.dblSalePrice ,0) / ISNULL(UOM.dblUnitQty, 1)) 
			END 
	, (ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0) - ISNULL(CAST(Chk.RefundAmount as decimal(18,6)),0))
	, P.dblStandardCost
	, 1
	from #tempCheckoutInsert Chk
	JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
	JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
	JOIN dbo.tblICItemSpecialPricing SP ON I.intItemId = SP.intItemId AND IL.intItemLocationId = SP.intItemLocationId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	WHERE S.intStoreId = @intStoreId

	
END
