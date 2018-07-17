CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMCM]
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
		DECLARE @TransactionName AS VARCHAR(500) = 'CheckoutPassportMCM' + CAST(NEWID() AS NVARCHAR(100)); 
		BEGIN TRAN @TransactionName
		SAVE TRAN @TransactionName --> Save point
		--------------------------------------------------------------------------------------------  
		-- END Create Save Point.  
		-------------------------------------------------------------------------------------------- 


		DECLARE @intStoreId INT

		SELECT @intStoreId = intStoreId 
		FROM dbo.tblSTCheckoutHeader 
		WHERE intCheckoutId = @intCheckoutId

		IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
			BEGIN
				INSERT INTO dbo.tblSTCheckoutDepartmetTotals
				SELECT @intCheckoutId [intCheckoutId]
					, Cat.intCategoryId [intCategoryId]
					, (
						CASE 
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
								THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.DiscountAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.PromotionAmount AS DECIMAL(18,6)),0)
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
								THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0)
					    END
					  ) [dblTotalSalesAmount]
					, 0 [dblRegisterSalesAmount]
					, '' [strDepartmentTotalsComment]
					, CAST(Chk.PromotionCount AS INT) [intPromotionalDiscountsCount]
					, CAST(Chk.PromotionAmount AS DECIMAL(18,6)) [dblPromotionalDiscountAmount]
					, CAST(Chk.DiscountCount AS INT) [intManagerDiscountCount]
					, CAST(Chk.DiscountAmount AS DECIMAL(18,6)) [dblManagerDiscountAmount]
					, CAST(Chk.RefundCount AS INT) [intRefundCount]
					, CAST(Chk.RefundAmount AS DECIMAL(18,6)) [dblRefundAmount]
					, CAST(Chk.SalesQuantity AS INT) [intItemsSold]
					, CAST(Chk.TransactionCount AS INT) [intTotalSalesCount]
					, 0 [dblTaxAmount1]
					, 0 [dblTaxAmount2]
					, 0 [dblTaxAmount3]
					, 0 [dblTaxAmount4]
					, I.intItemId [intItemId]
					, 1 [intConcurrencyId]
				FROM #tempCheckoutInsert Chk
				JOIN dbo.tblICCategoryLocation Cat ON CAST(ISNULL(Chk.MerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(Cat.intRegisterDepartmentId AS NVARCHAR(50))
				--JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
				LEFT JOIN dbo.tblICItem I ON Cat.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId

			END
		ELSE
			BEGIN
				UPDATE DT  
				SET	dblTotalSalesAmount = (
											CASE 
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
													THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.DiscountAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.PromotionAmount AS DECIMAL(18,6)),0) 
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
													THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0)
											END
										  )
					, [intPromotionalDiscountsCount] = ISNULL(CAST(Chk.PromotionCount AS INT),0) 
					, [dblPromotionalDiscountAmount] = ISNULL(CAST(Chk.PromotionAmount AS DECIMAL(18,6)),0) 
					, [intManagerDiscountCount] = ISNULL(CAST(Chk.DiscountCount AS INT),0) 
					, [dblManagerDiscountAmount] = ISNULL(CAST(Chk.DiscountAmount AS DECIMAL(18,6)), 0) 
					, [intRefundCount] = ISNULL(CAST(Chk.RefundCount AS INT), 0) 
					, [dblRefundAmount] = ISNULL(CAST(Chk.RefundAmount AS DECIMAL(18,6)), 0) 
					, [intItemsSold] = ISNULL(CAST(Chk.SalesQuantity AS INT), 0) 
					, [intTotalSalesCount] = ISNULL(CAST(Chk.TransactionCount AS INT), 0) 
					, [intItemId] = I.intItemId
				FROM tblSTCheckoutDepartmetTotals DT
				JOIN tblICCategory Cat ON DT.intCategoryId = Cat.intCategoryId
				JOIN tblICCategoryLocation CatLoc ON Cat.intCategoryId = CatLoc.intCategoryId
				JOIN #tempCheckoutInsert Chk ON CAST(ISNULL(Chk.MerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(CatLoc.intRegisterDepartmentId AS NVARCHAR(50))
				LEFT JOIN dbo.tblICItem I ON CatLoc.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE DT.intCheckoutId = @intCheckoutId 
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