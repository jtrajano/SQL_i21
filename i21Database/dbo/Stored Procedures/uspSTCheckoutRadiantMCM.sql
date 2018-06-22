﻿CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantMCM]
@intCheckoutId INT,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows INT OUTPUT
AS
BEGIN
	BEGIN TRY
		
		--------------------------------------------------------------------------------------------  
		-- Create Save Point.  
		--------------------------------------------------------------------------------------------    
		-- Create a unique transaction name. 
		DECLARE @TransactionName AS VARCHAR(500) = 'CheckoutRadiantMCM' + CAST(NEWID() AS NVARCHAR(100)); 
		BEGIN TRAN @TransactionName
		SAVE TRAN @TransactionName --> Save point
		--------------------------------------------------------------------------------------------  
		-- END Create Save Point.  
		-------------------------------------------------------------------------------------------- 


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
			, I.intItemId [intItemId]
			, 1 [intConcurrencyId]
			from #tempCheckoutInsert Chk
			JOIN dbo.tblICCategoryLocation Cat ON Cat.intRegisterDepartmentId = CASE WHEN LEN(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS)<=4 THEN Chk.MerchandiseCode COLLATE Latin1_General_CI_AS ELSE SUBSTRING(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS, 0, 4) END
			--JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
			LEFT JOIN dbo.tblICItem I ON Cat.intGeneralItemId = I.intItemId
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
			, [intItemId] = I.intItemId
			FROM #tempCheckoutInsert Chk
			JOIN dbo.tblICCategoryLocation Cat ON Cat.intRegisterDepartmentId = CASE WHEN LEN(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS)<=4 THEN Chk.MerchandiseCode COLLATE Latin1_General_CI_AS ELSE SUBSTRING(Chk.MerchandiseCode COLLATE Latin1_General_CI_AS, 0, 4) END
			--JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
			LEFT JOIN dbo.tblICItem I ON Cat.intGeneralItemId = I.intItemId
			JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
			JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
			JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
			WHERE intCheckoutId = @intCheckoutId 
			AND tblSTCheckoutDepartmetTotals.intCategoryId = Cat.intCategoryId
			AND S.intStoreId = @intStoreId
		END

		UPDATE dbo.tblSTCheckoutDepartmetTotals SET dblRegisterSalesAmount = dblTotalSalesAmount Where intCheckoutId = @intCheckoutId

		SET @intCountRows = 1
		SET @strStatusMsg = 'Success'

		-- IF SUCCESS Commit Transaction
		COMMIT TRAN @TransactionName

	END TRY

	BEGIN CATCH
		-- IF HAS Error Rollback Transaction
		ROLLBACK TRAN @TransactionName	

		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()

		COMMIT TRAN @TransactionName
	END CATCH
END