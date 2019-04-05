CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderDepartment]
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

		BEGIN TRANSACTION 

		-- ==================================================================================================================  
		-- Start Validate if Department xml file matches the Mapping on i21 
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
						, 'Commander Department XML file did not match the layout mapping'
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					SET @intCountRows = 0
					SET @strStatusMsg = 'Commander Department XML file did not match the layout mapping'

					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if Department xml file matches the Mapping on i21   
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
			, 'deptBase sysid' as strRegisterTag
			, ISNULL(Chk.deptBasesysid, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM #tempCheckoutInsert Chk
		WHERE ISNULL(Chk.deptBasesysid, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterMerchandiseCode
			FROM
			(
				SELECT DISTINCT
					Chk.deptBasesysid AS strXmlRegisterMerchandiseCode
				FROM #tempCheckoutInsert Chk
				JOIN dbo.tblICCategoryLocation Cat 
					ON CAST(ISNULL(Chk.deptBasesysid, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(Cat.intRegisterDepartmentId AS NVARCHAR(50))
				LEFT JOIN dbo.tblICItem I 
					ON Cat.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
				AND ISNULL(Chk.deptBasesysid, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.deptBasesysid, '') != ''
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================


		

		IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
			BEGIN
				INSERT INTO dbo.tblSTCheckoutDepartmetTotals
				SELECT @intCheckoutId [intCheckoutId]
					, Cat.intCategoryId [intCategoryId]
					, ISNULL(Chk.netSalesamount, 0) [dblTotalSalesAmountRaw]
					, ISNULL(Chk.netSalesamount, 0) [dblRegisterSalesAmountRaw]
					, (
						CASE 
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
								THEN ISNULL(CAST(Chk.netSalesamount AS DECIMAL(18,6)),0)
							WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
								THEN ISNULL(CAST(Chk.netSalesamount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.totalamount AS DECIMAL(18,6)),0) -- totalamount = Discount Amount
																					  + ISNULL(CAST(Chk.promotionsamount AS DECIMAL(18,6)),0) 
																					  + ISNULL(CAST(Chk.refundsamount AS DECIMAL(18,6)),0)
					    END
					  ) [dblTotalSalesAmountComputed]
					, 0 [dblRegisterSalesAmountComputed]
					, '' [strDepartmentTotalsComment]
					, CAST(Chk.promotionscount AS INT) [intPromotionalDiscountsCount]
					, CAST(Chk.promotionsamount AS DECIMAL(18,6)) [dblPromotionalDiscountAmount]
					, CAST(Chk.totalcount AS INT) [intManagerDiscountCount]
					, CAST(Chk.totalamount AS DECIMAL(18,6)) [dblManagerDiscountAmount]
					, CAST(Chk.refundscount AS INT) [intRefundCount]
					, CAST(Chk.refundsamount AS DECIMAL(18,6)) [dblRefundAmount]
					, CAST(CAST(Chk.netSalesitemCount AS DECIMAL) AS INT) [intItemsSold]
					, CAST(Chk.netSalescount AS INT) [intTotalSalesCount]
					, 0 [dblTaxAmount1]
					, 0 [dblTaxAmount2]
					, 0 [dblTaxAmount3]
					, 0 [dblTaxAmount4]
					, I.intItemId [intItemId]
					, 1 [intConcurrencyId]
				FROM #tempCheckoutInsert Chk
				JOIN dbo.tblICCategoryLocation Cat 
					ON CAST(ISNULL(Chk.deptBasesysid, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(Cat.intRegisterDepartmentId AS NVARCHAR(50))
				--JOIN dbo.tblICItem I ON I.intCategoryId = Cat.intCategoryId
				LEFT JOIN dbo.tblICItem I 
					ON Cat.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId

			END
		ELSE
			BEGIN
				UPDATE DT  
				SET	[dblTotalSalesAmountRaw] = ISNULL(Chk.netSalesamount, 0)
					, [dblRegisterSalesAmountRaw] = ISNULL(Chk.netSalesamount, 0)
					, [dblTotalSalesAmountComputed] = (
											CASE 
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
													THEN ISNULL(CAST(Chk.netSalesamount AS DECIMAL(18,6)),0)
												WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
													THEN ISNULL(CAST(Chk.netSalesamount AS DECIMAL(18,6)),0) + ( ISNULL(CAST(Chk.totalamount AS DECIMAL(18,6)),0) -- totalamount = Discount Amount
																									      + ISNULL(CAST(Chk.promotionsamount AS DECIMAL(18,6)),0) 
																										  + ISNULL(CAST(Chk.refundsamount AS DECIMAL(18,6)),0) )
																										  
											END
										  )
					, [intPromotionalDiscountsCount] = ISNULL(CAST(Chk.promotionscount AS INT),0) 
					, [dblPromotionalDiscountAmount] = ISNULL(CAST(Chk.promotionsamount AS DECIMAL(18,6)),0) 
					, [intManagerDiscountCount] = ISNULL(CAST(Chk.totalcount AS INT),0) 
					, [dblManagerDiscountAmount] = ISNULL(CAST(Chk.totalamount AS DECIMAL(18,6)), 0) 
					, [intRefundCount] = ISNULL(CAST(Chk.refundscount AS INT), 0) 
					, [dblRefundAmount] = ISNULL(CAST(Chk.refundsamount AS DECIMAL(18,6)), 0) 
					, [intItemsSold] = ISNULL(CAST(CAST(Chk.netSalesitemCount AS DECIMAL) AS INT), 0) 
					, [intTotalSalesCount] = ISNULL(CAST(Chk.netSalescount AS INT), 0) 
					, [intItemId] = I.intItemId
				FROM tblSTCheckoutDepartmetTotals DT
				JOIN tblICCategory Cat 
					ON DT.intCategoryId = Cat.intCategoryId
				JOIN tblICCategoryLocation CatLoc 
					ON Cat.intCategoryId = CatLoc.intCategoryId
				JOIN #tempCheckoutInsert Chk 
					ON CAST(ISNULL(Chk.deptBasesysid, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(CatLoc.intRegisterDepartmentId AS NVARCHAR(50))
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