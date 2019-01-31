﻿CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMCM]
	@intCheckoutId INT,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId INT

		SELECT @intStoreId = intStoreId 
		FROM dbo.tblSTCheckoutHeader 
		WHERE intCheckoutId = @intCheckoutId

		--------------------------------------------------------------------------------------------  
		-- Create Save Point.  
		--------------------------------------------------------------------------------------------    
		-- Create a unique transaction name. 
		--DECLARE @TransactionName AS VARCHAR(500) = 'CheckoutPassportMCM' + CAST(NEWID() AS NVARCHAR(100)); 
		BEGIN TRANSACTION --@TransactionName
		--SAVE TRAN @TransactionName --> Save point
		--------------------------------------------------------------------------------------------  
		-- END Create Save Point.  
		-------------------------------------------------------------------------------------------- 




		-- ==================================================================================================================  
		-- Start Validate if MCM xml file matches the Mapping on i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM #tempCheckoutInsert)
			BEGIN
					-- Add to error logging
					INSERT INTO tblSTCheckoutErrorLogs 
					(
						strErrorType
						, strErrorMessage 
						, strRegisterTag
						, strRegisterTagValue
						, intCheckoutId
						, intConcurrencyId
					)
					VALUES
					(
						'XML LAYOUT MAPPING'
						, 'Passport MCM XML file did not match the layout mapping'
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					SET @intCountRows = 0
					SET @strStatusMsg = 'Passport MCM XML file did not match the layout mapping'

					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if MCM xml file matches the Mapping on i21   
		-- ==================================================================================================================




		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <MerchandiseCode> tag of (RegisterXML) and (Inventory --> Category --> Point of Sale --> Select Location same with Store --> 'Cash Register Department')
		-- ------------------------------------------------------------------------------------------------------------------ 
		INSERT INTO tblSTCheckoutErrorLogs 
		(
			strErrorType
			, strErrorMessage 
			, strRegisterTag
			, strRegisterTagValue
			, intCheckoutId
			, intConcurrencyId
		)
		SELECT DISTINCT
			'NO MATCHING TAG' as strErrorType
			, 'No Matching Register Department Setup in Category' as strErrorMessage
			, 'MerchandiseCode' as strRegisterTag
			, ISNULL(Chk.MerchandiseCode, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM #tempCheckoutInsert Chk
		WHERE ISNULL(Chk.MerchandiseCode, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterMerchandiseCode
			FROM
			(
				SELECT DISTINCT
					Chk.MerchandiseCode AS strXmlRegisterMerchandiseCode
				FROM #tempCheckoutInsert Chk
				JOIN dbo.tblICCategoryLocation Cat 
					ON CAST(ISNULL(Chk.MerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(Cat.intRegisterDepartmentId AS NVARCHAR(50))
				LEFT JOIN dbo.tblICItem I 
					ON Cat.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
				AND ISNULL(Chk.MerchandiseCode, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.MerchandiseCode, '') != ''
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================


		

		IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
			BEGIN
				INSERT INTO dbo.tblSTCheckoutDepartmetTotals
				SELECT @intCheckoutId [intCheckoutId]
					, Cat.intCategoryId [intCategoryId]
					, ISNULL(Chk.SalesAmount, 0) [dblTotalSalesAmountRaw]
					, ISNULL(Chk.SalesAmount, 0) [dblRegisterSalesAmountRaw]
					, (
						CASE 
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
								THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0)
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
								THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.DiscountAmount AS DECIMAL(18,6)),0) 
																					  + ISNULL(CAST(Chk.PromotionAmount AS DECIMAL(18,6)),0) 
																					  + ISNULL(CAST(Chk.RefundAmount AS DECIMAL(18,6)),0) --// - (ABS(CAST(ISNULL(Chk.DiscountAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.RefundAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.PromotionAmount, 0) AS DECIMAL(18,6))))
					    END
					  ) [dblTotalSalesAmountComputed]
					, 0 [dblRegisterSalesAmountComputed]
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
				SET	[dblTotalSalesAmountRaw] = ISNULL(Chk.SalesAmount, 0)
					, [dblRegisterSalesAmountRaw] = ISNULL(Chk.SalesAmount, 0)
					, [dblTotalSalesAmountComputed] = (
											CASE 
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
													THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0)
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
													THEN ISNULL(CAST(Chk.SalesAmount AS DECIMAL(18,6)),0) + ( ISNULL(CAST(Chk.DiscountAmount AS DECIMAL(18,6)),0) 
																									      + ISNULL(CAST(Chk.PromotionAmount AS DECIMAL(18,6)),0) 
																										  + ISNULL(CAST(Chk.RefundAmount AS DECIMAL(18,6)),0) )
																										  --// - (ABS(CAST(ISNULL(Chk.DiscountAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.RefundAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.PromotionAmount, 0) AS DECIMAL(18,6))))
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
				JOIN tblICCategory Cat 
					ON DT.intCategoryId = Cat.intCategoryId
				JOIN tblICCategoryLocation CatLoc 
					ON Cat.intCategoryId = CatLoc.intCategoryId
				JOIN #tempCheckoutInsert Chk 
					ON CAST(ISNULL(Chk.MerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(CatLoc.intRegisterDepartmentId AS NVARCHAR(50))
				LEFT JOIN dbo.tblICItem I 
					ON CatLoc.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE DT.intCheckoutId = @intCheckoutId 
				AND S.intStoreId = @intStoreId

			END

		-- Update Register Amount
		UPDATE dbo.tblSTCheckoutDepartmetTotals 
		SET dblRegisterSalesAmountComputed = dblTotalSalesAmountComputed
		Where intCheckoutId = @intCheckoutId

		SET @intCountRows = 1
		SET @strStatusMsg = 'Success'

		-- COMMIT
		GOTO ExitWithCommit

	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
		
		-- ROLLBACK
		GOTO ExitWithRollback
	END CATCH
END


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END
	
ExitPost: