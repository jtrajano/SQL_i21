CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantMCM]
@intCheckoutId Int
AS
BEGIN

DECLARE @intStoreId Int
Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
BEGIN
	INSERT INTO dbo.tblSTCheckoutDepartmetTotals
	SELECT @intCheckoutId 
	, Cat.intCategoryId
	, ISNULL(Chk.SalesQuantity,0) [intTotalSalesCount]
	, (CASE WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' 
		THEN ISNULL(Chk.SalesAmount,0) + ISNULL(Chk.DiscountAmount,0) + ISNULL(Chk.PromotionAmount,0) + ISNULL(Chk.RefundAmount,0)   
		WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' 
		THEN ISNULL(Chk.SalesAmount,0)
	   END) [dblTotalSalesAmount]
	, 0 [dblRegisterSalesAmount]
	, '' [strDepartmentTotalsComment]
	, Chk.PromotionCount [intPromotionalDiscountsCount]
	, Chk.PromotionAmount [dblPromotionalDiscountAmount]
	, Chk.DiscountCount [intManagerDiscountCount]
	, Chk.DiscountAmount [dblManagerDiscountAmount]
	, Chk.RefundCount [intRefundCount]
	, Chk.RefundAmount [dblRefundAmount]
	, Chk.TransactionCount [intItemsSold]
	, 0 [dblTaxAmount1]
	, 0 [dblTaxAmount2]
	, 0 [dblTaxAmount3]
	, 0 [dblTaxAmount4]
	, 1 [intConcurrencyId]
	from #tempCheckoutInsert Chk
	JOIN dbo.tblICCategory Cat ON Cat.strCategoryCode = CASE WHEN LEN(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS)<=4 THEN Chk.MerchandiseCode COLLATE Latin1_General_CI_AS ELSE SUBSTRING(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS, 0, 4) END
	JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	WHERE S.intStoreId = @intStoreId
END
ELSE
BEGIN
	UPDATE dbo.tblSTCheckoutDepartmetTotals
	SET intTotalSalesCount = ISNULL(Chk.SalesQuantity,0),
	dblTotalSalesAmount = (CASE WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' 
		THEN ISNULL(Chk.SalesAmount,0) + ISNULL(Chk.DiscountAmount,0) + ISNULL(Chk.PromotionAmount,0) + ISNULL(Chk.RefundAmount,0)   
		WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' 
		THEN ISNULL(Chk.SalesAmount,0)
	   END)
	FROM #tempCheckoutInsert Chk
	JOIN dbo.tblICCategory Cat ON Cat.strCategoryCode = CASE WHEN LEN(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS)<=4 THEN Chk.MerchandiseCode COLLATE Latin1_General_CI_AS ELSE SUBSTRING(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS, 0, 4) END
	JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
	WHERE intCheckoutId = @intCheckoutId
END

UPDATE dbo.tblSTCheckoutDepartmetTotals SET dblRegisterSalesAmount = dblTotalSalesAmount Where intCheckoutId = @intCheckoutId

END
