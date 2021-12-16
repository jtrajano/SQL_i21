CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderDepartment]
	@intCheckoutId							INT,
	@UDT_TransDept							StagingCommanderDepartment		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
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
		IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_TransDept)
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
					SET @strMessage = 'Commander Department XML file did not match the layout mapping'
					SET @ysnSuccess = 0

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
			strErrorType			= 'NO MATCHING TAG'
			, strErrorMessage		= 'No Matching Register Department Setup in Category'
			, strRegisterTag		= 'deptBase sysid'
			, strRegisterTagValue	= ISNULL(Chk.strSysId, '')
			, intCheckoutId			= @intCheckoutId
			, intConcurrencyId		= 1
		FROM @UDT_TransDept Chk
		WHERE ISNULL(Chk.strSysId, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterMerchandiseCode
			FROM
			(
				SELECT DISTINCT
					Chk.strSysId AS strXmlRegisterMerchandiseCode
				FROM @UDT_TransDept Chk
				JOIN dbo.tblICCategoryLocation Cat 
					ON CAST(ISNULL(Chk.strSysId, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(Cat.intRegisterDepartmentId AS NVARCHAR(50))
				LEFT JOIN dbo.tblICItem I 
					ON Cat.intGeneralItemId = I.intItemId
				JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
					AND ISNULL(Chk.strSysId, '') != ''
					AND CAST(ISNULL(Chk.intNetSaleCount, 0) AS INT) != 0
					AND CAST(ISNULL(Chk.dblNetSaleAmount, 0) AS DECIMAL(18, 6)) != 0.000000
			) AS tbl
		)
			AND ISNULL(Chk.strSysId, '') != ''
			AND CAST(ISNULL(Chk.intNetSaleCount, 0) AS INT) != 0
			AND CAST(ISNULL(Chk.dblNetSaleAmount, 0) AS DECIMAL(18, 6)) != 0.000000

		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================


		

		IF NOT EXISTS(SELECT 1 FROM dbo.tblSTCheckoutDepartmetTotals WHERE intCheckoutId = @intCheckoutId)
			BEGIN
				INSERT INTO dbo.tblSTCheckoutDepartmetTotals
				SELECT @intCheckoutId [intCheckoutId]
					, Cat.intCategoryId [intCategoryId]
					, ISNULL(Chk.dblNetSaleAmount, 0) [dblTotalSalesAmountRaw]
					, ISNULL(Chk.dblNetSaleAmount, 0) [dblRegisterSalesAmountRaw]
					--, (
					--	CASE 
					--		WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
					--			THEN ISNULL(CAST(Chk.dblNetSaleAmount AS DECIMAL(18,6)),0)
					--		WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
					--			THEN ISNULL(CAST(Chk.dblNetSaleAmount AS DECIMAL(18,6)),0) + ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)),0) -- dblTotalAmount = Discount Amount
					--																  + ISNULL(CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)),0) 
					--																  + ISNULL(CAST(Chk.dblRefundAmount AS DECIMAL(18,6)),0)
					--    END
					--  ) [dblTotalSalesAmountComputed]
					, [dblTotalSalesAmountComputed] = (
														CASE 
															WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
																THEN CAST(ISNULL(Chk.dblDeptInfoGrossSale, 0) AS DECIMAL(18,6))
															WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
																THEN ISNULL(CAST(Chk.dblNetSaleAmount AS DECIMAL(18,6)),0)
																										  
														END
													  )
					, 0 [dblRegisterSalesAmountComputed]
					, '' [strDepartmentTotalsComment]
					, CAST(Chk.intPromotionCount AS INT) [intPromotionalDiscountsCount]
					, CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)) [dblPromotionalDiscountAmount]
					, CAST(Chk.intTotalCount AS INT) [intManagerDiscountCount]
					--, CAST(Chk.dblTotalAmount AS DECIMAL(18,6)) [dblManagerDiscountAmount]
					, [dblManagerDiscountAmount] = CASE
														WHEN (ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)), 0))  >  0
															THEN (ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)), 0)) * -1
														ELSE 0
												END
					, CAST(Chk.intRefundCount AS INT) [intRefundCount]
					, CAST(Chk.dblRefundAmount AS DECIMAL(18,6)) [dblRefundAmount]
					, CAST(CAST(Chk.dblNetSaleItemCount AS DECIMAL) AS INT) [intItemsSold]
					, CAST(Chk.intNetSaleCount AS INT) [intTotalSalesCount]
					, 0 [dblTaxAmount1]
					, 0 [dblTaxAmount2]
					, 0 [dblTaxAmount3]
					, 0 [dblTaxAmount4]
					, I.intItemId [intItemId]
					, 1 [intConcurrencyId]
					, 0 [dblTotalLotterySalesAmountComputed]
					, NULL [intLotteryItemsSold]
					, 0 [ysnLotteryItemAdded]
				FROM @UDT_TransDept Chk
				JOIN dbo.tblICCategoryLocation Cat 
					ON CAST(ISNULL(Chk.strSysId, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(Cat.intRegisterDepartmentId AS NVARCHAR(50))
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
					AND CAST(ISNULL(Chk.intNetSaleCount, 0) AS INT) != 0
					AND CAST(ISNULL(Chk.dblNetSaleAmount, 0) AS DECIMAL(18, 6)) != 0.000000

			END
		ELSE
			BEGIN
				UPDATE DT  
				SET	[dblTotalSalesAmountRaw]		= ISNULL(Chk.dblNetSaleAmount, 0)
					, [dblRegisterSalesAmountRaw]	= ISNULL(Chk.dblNetSaleAmount, 0)
					, [dblTotalSalesAmountComputed] = (
														CASE 
															WHEN (S.strReportDepartmentAtGrossOrNet) = 'G' -- Gross
																--THEN ISNULL(CAST(Chk.dblNetSaleAmount AS DECIMAL(18,6)),0)
																THEN CAST(ISNULL(Chk.dblDeptInfoGrossSale, 0) AS DECIMAL(18,6))
															WHEN (S.strReportDepartmentAtGrossOrNet) = 'N' -- Net
																THEN ISNULL(CAST(Chk.dblNetSaleAmount AS DECIMAL(18,6)),0)
																--THEN ISNULL(CAST(Chk.dblNetSaleAmount AS DECIMAL(18,6)),0) + ( ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)),0) -- dblTotalAmount = Discount Amount
																--												         + ISNULL(CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)),0) 
																--													     + ISNULL(CAST(Chk.dblRefundAmount AS DECIMAL(18,6)),0) )
																										  
														END
													  )
					, [intPromotionalDiscountsCount] = ISNULL(CAST(Chk.intPromotionCount AS INT),0) 
					, [dblPromotionalDiscountAmount] = ISNULL(CAST(Chk.dblPromotionAmount AS DECIMAL(18,6)),0) 
					, [intManagerDiscountCount]		 = ISNULL(CAST(Chk.intTotalCount AS INT),0) 
					--, [dblManagerDiscountAmount] = ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)), 0) 
					, [dblManagerDiscountAmount]	= CASE
														WHEN (ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)), 0))  >  0
															THEN (ISNULL(CAST(Chk.dblTotalAmount AS DECIMAL(18,6)), 0)) * -1
														ELSE 0
													END
					, [intRefundCount]				= ISNULL(CAST(Chk.intRefundCount AS INT), 0) 
					, [dblRefundAmount]				= ISNULL(CAST(Chk.dblRefundAmount AS DECIMAL(18,6)), 0) 
					, [intItemsSold]				= ISNULL(CAST(CAST(Chk.dblNetSaleItemCount AS DECIMAL) AS INT), 0) 
					, [intTotalSalesCount]			= ISNULL(CAST(Chk.intNetSaleCount AS INT), 0) 
					, [intItemId]					= I.intItemId
				FROM tblSTCheckoutDepartmetTotals DT
				JOIN tblICCategory Cat 
					ON DT.intCategoryId = Cat.intCategoryId
				JOIN tblICCategoryLocation CatLoc 
					ON Cat.intCategoryId = CatLoc.intCategoryId
				JOIN @UDT_TransDept Chk 
					ON CAST(ISNULL(Chk.strSysId, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS = CAST(CatLoc.intRegisterDepartmentId AS NVARCHAR(50))
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
					AND CAST(ISNULL(Chk.intNetSaleCount, 0) AS INT) != 0
					AND CAST(ISNULL(Chk.dblNetSaleAmount, 0) AS DECIMAL(18, 6)) != 0.000000

				
			END


		

		-- Update Register Amount
		UPDATE dbo.tblSTCheckoutDepartmetTotals 
		SET dblRegisterSalesAmountComputed = dblTotalSalesAmountComputed
		WHERE intCheckoutId = @intCheckoutId
		
		  -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- METRIC TAB ---------------------------------------------------------
          -------------------------------------------------------------------------------------------------------------

		MERGE tblSTCheckoutMetrics cm  USING tblSTCheckoutDepartmetTotals cdt
			ON cm.intCheckoutId = @intCheckoutId AND cm.intDepartmentId = cdt.intCategoryId AND cdt.intCheckoutId = @intCheckoutId 
		WHEN MATCHED
			THEN UPDATE SET cm.dblAmount = (CASE WHEN cm.intRegisterImportFieldId = 1
													 THEN CAST(cdt.intItemsSold AS FLOAT)
												 WHEN cm.intRegisterImportFieldId = 7
													 THEN CAST(cdt.dblRegisterSalesAmountComputed AS FLOAT)
												 ELSE 0
												END);
												
		
		  -------------------------------------------------------------------------------------------------------------
          ---------------------------------------- END METRIC TAB -----------------------------------------------------
          -------------------------------------------------------------------------------------------------------------



		SET @intCountRows = 1
		SET @strMessage = 'Success'
		SET @ysnSuccess = 1

		-- COMMIT
		GOTO ExitWithCommit

	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strMessage = ERROR_MESSAGE()
		SET @ysnSuccess = 0
		
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