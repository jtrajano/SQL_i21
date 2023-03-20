CREATE PROCEDURE [dbo].[uspSTCheckoutPassportMCM]
	@intCheckoutId INT,
	@UDT_MCM	StagingPassportMCM		READONLY,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN

	BEGIN TRY	
		BEGIN TRANSACTION


		DECLARE @intStoreId INT

		SELECT @intStoreId = intStoreId 
		FROM dbo.tblSTCheckoutHeader 
		WHERE intCheckoutId = @intCheckoutId


		-- ==================================================================================================================  
		-- Start Validate if MCM xml file matches the Mapping on i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_MCM)
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
		-- Compare <intMerchandiseCode> tag of (RegisterXML) and (Inventory --> Category --> Point of Sale --> Select Location same with Store --> 'Cash Register Department')
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
			, ISNULL(Chk.intMerchandiseCode, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM @UDT_MCM Chk
		WHERE ISNULL(Chk.intMerchandiseCode, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterMerchandiseCode
			FROM
			(
				SELECT DISTINCT
					Chk.intMerchandiseCode AS strXmlRegisterMerchandiseCode
				FROM @UDT_MCM Chk
				JOIN dbo.vyuSTStoreDepartments StoreDepartments 
					ON CAST(ISNULL(Chk.intMerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(StoreDepartments.strRegisterCode AS NVARCHAR(50))
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = StoreDepartments.intCompanyLocationId
				WHERE StoreDepartments.intStoreId = @intStoreId
				AND ISNULL(Chk.intMerchandiseCode, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.intMerchandiseCode, '') != ''
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================


		

		IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
			BEGIN
				INSERT INTO dbo.tblSTCheckoutDepartmetTotals
				SELECT @intCheckoutId [intCheckoutId]
					, StoreDepartments.intCategoryId
					, ISNULL(Chk.dblSalesAmount, 0) [dblTotalSalesAmountRaw]
					, ISNULL(Chk.dblSalesAmount, 0) [dblRegisterSalesAmountRaw]
					, (
						CASE 
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
								THEN ISNULL(CAST(Chk.dblSalesAmount AS DECIMAL(18,6)),0)
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
								THEN ISNULL(CAST(Chk.dblSalesAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.dblDiscountAmount AS DECIMAL(18,6)),0) 
																					                + ISNULL(CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)),0) 
																					                + ISNULL(CAST(Chk.dblRefundAmount AS DECIMAL(18,6)),0) --// - (ABS(CAST(ISNULL(Chk.DiscountAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.RefundAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.PromotionAmount, 0) AS DECIMAL(18,6))))
					    END
					  ) [dblTotalSalesAmountComputed]
					, 0 [dblRegisterSalesAmountComputed]
					, '' [strDepartmentTotalsComment]
					, CAST(Chk.dblPromotionCount AS INT) [intPromotionalDiscountsCount]
					, CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)) [dblPromotionalDiscountAmount]
					, CAST(Chk.dblDiscountCount AS INT) [intManagerDiscountCount]
					, CAST(Chk.dblDiscountAmount AS DECIMAL(18,6)) [dblManagerDiscountAmount]
					, CAST(Chk.dblRefundCount AS INT) [intRefundCount]
					, CAST(Chk.dblRefundAmount AS DECIMAL(18,6)) [dblRefundAmount]
					, CAST(Chk.dblSalesQuantity AS INT) [intItemsSold]
					, CAST(Chk.dblTransactionCount AS INT) [intTotalSalesCount]
					, 0 [dblTaxAmount1]
					, 0 [dblTaxAmount2]
					, 0 [dblTaxAmount3]
					, 0 [dblTaxAmount4]
					, CASE 
						WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
						THEN StoreDepartments.intGeneralItemId
						WHEN StoreDepartments.strCategoriesOrSubcategories = 'S'
						THEN StoreDepartments.intSubcategoryItemId
						ELSE NULL
						END AS [intItemId]
					, 1 [intConcurrencyId]
					, 0 [dblTotalLotterySalesAmountComputed]
					, NULL [intLotteryItemsSold]
					, 0 [ysnLotteryItemAdded] 
					, StoreDepartments.intCategoryId
					, strRegisterCode
				FROM @UDT_MCM Chk
				JOIN dbo.vyuSTStoreDepartments StoreDepartments 
					ON CAST(ISNULL(Chk.intMerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(StoreDepartments.strRegisterCode AS NVARCHAR(50))
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = StoreDepartments.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId

			END
		ELSE
			BEGIN
				UPDATE DT  
				SET	[dblTotalSalesAmountRaw] = ISNULL(Chk.dblSalesAmount, 0)
					, [dblRegisterSalesAmountRaw] = ISNULL(Chk.dblSalesAmount, 0)
					, [dblTotalSalesAmountComputed] = (
											CASE 
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
													THEN ISNULL(CAST(Chk.dblSalesAmount AS DECIMAL(18,6)),0)
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
													THEN ISNULL(CAST(Chk.dblSalesAmount AS DECIMAL(18,6)),0) + ( ISNULL(CAST(Chk.dblDiscountAmount AS DECIMAL(18,6)),0) 
																														+ ISNULL(CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)),0) 
																														+ ISNULL(CAST(Chk.dblRefundAmount AS DECIMAL(18,6)),0) )
																														--// - (ABS(CAST(ISNULL(Chk.DiscountAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.RefundAmount, 0) AS DECIMAL(18,6))) + ABS(CAST(ISNULL(Chk.PromotionAmount, 0) AS DECIMAL(18,6))))
											END
										  )
					, [intPromotionalDiscountsCount] = ISNULL(CAST(Chk.dblPromotionCount AS INT),0) 
					, [dblPromotionalDiscountAmount] = ISNULL(CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)),0) 
					, [intManagerDiscountCount] = ISNULL(CAST(Chk.dblDiscountCount AS INT),0) 
					, [dblManagerDiscountAmount] = ISNULL(CAST(Chk.dblDiscountAmount AS DECIMAL(18,6)), 0) 
					, [intRefundCount] = ISNULL(CAST(Chk.dblRefundCount AS INT), 0) 
					, [dblRefundAmount] = ISNULL(CAST(Chk.dblRefundAmount AS DECIMAL(18,6)), 0) 
					, [intItemsSold] = ISNULL(CAST(Chk.dblSalesQuantity AS INT), 0) 
					, [intTotalSalesCount] = ISNULL(CAST(Chk.dblTransactionCount AS INT), 0) 
					, [intItemId] = CASE 
										WHEN StoreDepartments.strCategoriesOrSubcategories = 'C'
										THEN StoreDepartments.intGeneralItemId
										WHEN StoreDepartments.strCategoriesOrSubcategories = 'S'
										THEN StoreDepartments.intSubcategoryItemId
										ELSE NULL
										END
				FROM tblSTCheckoutDepartmetTotals DT
				JOIN vyuSTStoreDepartments StoreDepartments
					ON DT.intCategoryId = StoreDepartments.intCategoryId AND (DT.intSubcategoriesId = StoreDepartments.intSubcategoriesId OR DT.intSubcategoriesId IS NULL)
				JOIN @UDT_MCM Chk 
					ON CAST(ISNULL(Chk.intMerchandiseCode, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(StoreDepartments.strRegisterCode AS NVARCHAR(50))
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = StoreDepartments.intCompanyLocationId
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
		SET @strStatusMsg = 'Error on uspSTCheckoutPassportMCM: ' + ERROR_MESSAGE()
PRINT 	@strStatusMsg
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