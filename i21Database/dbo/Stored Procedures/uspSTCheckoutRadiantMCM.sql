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
		, ISNULL(CAST(Chk.SalesQuantity as int),0) [intTotalSalesCount]
		, (CASE WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' 
			THEN ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0) + ISNULL(CAST(Chk.DiscountAmount as decimal(18,6)),0) + ISNULL(CAST(Chk.PromotionAmount as decimal(18,6)),0)
			WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' 
			THEN ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
		   END) [dblTotalSalesAmount]
		, 0 [dblRegisterSalesAmount]
		, '' [strDepartmentTotalsComment]
		, CAST(Chk.PromotionCount as int) [intPromotionalDiscountsCount]
		, CAST(Chk.PromotionAmount as decimal(18,6)) [dblPromotionalDiscountAmount]
		, CAST(Chk.DiscountCount as int) [intManagerDiscountCount]
		, CAST(Chk.DiscountAmount as decimal(18,6)) [dblManagerDiscountAmount]
		, CAST(Chk.RefundCount as int) [intRefundCount]
		, CAST(Chk.RefundAmount as decimal(18,6)) [dblRefundAmount]
		, CAST(Chk.TransactionCount as int) [intItemsSold]
		, 0 [dblTaxAmount1]
		, 0 [dblTaxAmount2]
		, 0 [dblTaxAmount3]
		, 0 [dblTaxAmount4]
		, 1 [intConcurrencyId]
		from #tempCheckoutInsert Chk
		JOIN dbo.tblICCategoryLocation Cat ON Cat.intRegisterDepartmentId = CASE WHEN LEN(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS)<=4 THEN Chk.MerchandiseCode COLLATE Latin1_General_CI_AS ELSE SUBSTRING(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS, 0, 4) END
		JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE S.intStoreId = @intStoreId
	END
	ELSE
	BEGIN
		UPDATE dbo.tblSTCheckoutDepartmetTotals  
		SET intTotalSalesCount = ISNULL(CAST(Chk.SalesQuantity AS INT),0),
		dblTotalSalesAmount = (CASE WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' 
			THEN ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0) + ISNULL(CAST(Chk.DiscountAmount as decimal(18,6)),0) + ISNULL(CAST(Chk.PromotionAmount as decimal(18,6)),0) 
			WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' 
			THEN ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
		   END)
		, [intPromotionalDiscountsCount] = ISNULL(CAST(Chk.PromotionCount as INT),0) 
		, [dblPromotionalDiscountAmount] = ISNULL(CAST(Chk.PromotionAmount as decimal(18,6)),0) 
		, [intManagerDiscountCount] = ISNULL(CAST(Chk.DiscountCount as int),0) 
		, [dblManagerDiscountAmount] = ISNULL(CAST(Chk.DiscountAmount as decimal(18,6)), 0) 
		, [intRefundCount] = ISNULL(CAST(Chk.RefundCount as int), 0) 
		, [dblRefundAmount] = ISNULL(CAST(Chk.RefundAmount as decimal(18,6)), 0) 
		, [intItemsSold] = ISNULL(CAST(Chk.TransactionCount as int), 0) 
		FROM #tempCheckoutInsert Chk
		JOIN dbo.tblICCategoryLocation Cat ON Cat.intRegisterDepartmentId = CASE WHEN LEN(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS)<=4 THEN Chk.MerchandiseCode COLLATE Latin1_General_CI_AS ELSE SUBSTRING(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS, 0, 4) END
		JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE intCheckoutId = @intCheckoutId AND tblSTCheckoutDepartmetTotals.intCategoryId = Cat.intCategoryId
	END

	UPDATE dbo.tblSTCheckoutDepartmetTotals SET dblRegisterSalesAmount = dblTotalSalesAmount Where intCheckoutId = @intCheckoutId

END
