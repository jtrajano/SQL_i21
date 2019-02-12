CREATE PROCEDURE [dbo].[uspSTCheckoutPassportISM]
	@intCheckoutId INT,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId INT, @strAllowRegisterMarkUpDown NVARCHAR(50), @intShiftNo INT, @intMarkUpDownId INT, @strAllowMarkUpDown NVARCHAR(1)

		SELECT @intStoreId = CH.intStoreId
			   , @intShiftNo = CH.intShiftNo
			   , @strAllowMarkUpDown = ST.strAllowRegisterMarkUpDown 
		FROM dbo.tblSTCheckoutHeader CH
		INNER JOIN dbo.tblSTStore ST
			ON CH.intStoreId = ST.intStoreId
		WHERE CH.intCheckoutId = @intCheckoutId

		--------------------------------------------------------------------------------------------  
		-- Create Save Point.  
		--------------------------------------------------------------------------------------------    
		-- Create a unique transaction name. 
		--DECLARE @TransactionName AS VARCHAR(500) = 'CheckoutPassportISM' + CAST(NEWID() AS NVARCHAR(100)); 
		BEGIN TRANSACTION --@TransactionName
		--SAVE TRAN @TransactionName --> Save point
		--------------------------------------------------------------------------------------------  
		-- END Create Save Point.  
		-------------------------------------------------------------------------------------------- 




		-- ==================================================================================================================  
		-- Start Validate if ISM xml file matches the Mapping on i21 
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
						, 'Passport ISM XML file did not match the layout mapping'
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					SET @intCountRows = 0
					SET @strStatusMsg = 'Passport ISM XML file did not match the layout mapping'

					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if ISM xml file matches the Mapping on i21   
		-- ==================================================================================================================  





		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <POSCode> tag of (RegisterXML) and (Inventory->Item->strUpcCode, strLongUPCCode)
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
			, 'No Matching UPC/Item in Inventory' as strErrorMessage
			, 'POSCode' as strRegisterTag
			, ISNULL(Chk.POSCode, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM #tempCheckoutInsert Chk
		WHERE ISNULL(Chk.POSCode, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterPOSCode
			FROM
			(
				SELECT DISTINCT
					Chk.POSCode AS strXmlRegisterPOSCode
				FROM #tempCheckoutInsert Chk
				INNER JOIN
				(
					SELECT intItemUOMId
						, intItemId
						, strLongUPCCode
						, CASE 
							WHEN strLongUPCCode NOT LIKE '%[^0-9]%' 
								THEN CONVERT(NUMERIC(32, 0),CAST(strLongUPCCode AS FLOAT))
							ELSE NULL
						END AS intLongUpcCode 
					FROM dbo.tblICItemUOM
				) AS UOM
					ON Chk.POSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
					OR CONVERT(NUMERIC(32, 0),CAST(Chk.POSCode AS FLOAT)) = UOM.intLongUpcCode
				INNER JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				INNER JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				INNER JOIN dbo.tblICItemPricing P 
					ON IL.intItemLocationId = P.intItemLocationId 
					AND I.intItemId = P.intItemId
				INNER JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				INNER JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
					AND ISNULL(Chk.POSCode, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.POSCode, '') != ''
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================



		-- ==================================================================================================================
		-- Start: Insert to temporary table
		-- ==================================================================================================================
		DECLARE @tblTempForCalculation TABLE
		(
			SalesQuantity INT,
			DiscountAmount DECIMAL(18, 6),
			PromotionAmount DECIMAL(18, 6),
			RefundAmount DECIMAL(18, 6),
			RefundCount INT,
			SalesAmount DECIMAL(18, 6),
			ActualSalesPrice DECIMAL(18, 6),
			POSCode NVARCHAR(15),
			dblAveragePrice DECIMAL(18, 6),
			dblAveragePriceWthDiscounts DECIMAL(18, 6)
		)

		INSERT INTO @tblTempForCalculation
		(
			SalesQuantity,
			DiscountAmount,
			PromotionAmount,
			SalesAmount,
			RefundAmount,
			RefundCount,
			ActualSalesPrice,
			POSCode,
			dblAveragePrice,
			dblAveragePriceWthDiscounts
		)
		SELECT 
			CAST(ISNULL(SalesQuantity ,0) AS INT),
			CAST(DiscountAmount AS DECIMAL(18,6)),
			CAST(PromotionAmount AS DECIMAL(18,6)),
			CAST(SalesAmount AS DECIMAL(18,6)),
			CAST(ISNULL(RefundAmount, 0) AS DECIMAL(18,6)),
			CAST(ISNULL(RefundCount, 0) AS INT),
			CAST(ActualSalesPrice AS DECIMAL(18,6)),
			POSCode,
			CASE 
				WHEN ( CAST(SalesQuantity AS INT) - CAST(RefundCount AS INT) ) = 0
					THEN 0
				ELSE ISNULL( NULLIF( CAST(SalesAmount AS DECIMAL(18, 6)) + CAST(RefundAmount AS DECIMAL(18, 6)) ,0) , 0) / ( CAST(SalesQuantity AS INT) - CAST(RefundCount AS INT) )
			END AS dblAveragePrice,
			CASE 
				WHEN ( CAST(SalesQuantity AS INT) - CAST(RefundCount AS INT) ) = 0
					THEN 0
				ELSE ISNULL( NULLIF( CAST(SalesAmount AS DECIMAL(18, 6)) + CAST(RefundAmount AS DECIMAL(18, 6)) + CAST(DiscountAmount AS DECIMAL(18, 6)) + CAST(PromotionAmount AS DECIMAL(18, 6)) ,0) , 0) / ( CAST(SalesQuantity AS INT) - CAST(RefundCount AS INT) )
			END AS dblAveragePriceWthDiscounts
		FROM #tempCheckoutInsert
		-- ==================================================================================================================
		-- End: Insert to temporary table
		-- ==================================================================================================================



		

		DECLARE @intLocationId AS INT = (SELECT intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId)

		BEGIN
			INSERT INTO dbo.tblSTCheckoutItemMovements
			(
				intCheckoutId
				, intItemUPCId
				, strDescription
				, intVendorId
				, intQtySold
				, dblCurrentPrice
				, dblDiscountAmount
				-- , dblRefundAmount
				, dblGrossSales
				, dblTotalSales
				, dblItemStandardCost
				, intConcurrencyId
			)
			SELECT 
				intCheckoutId		= @intCheckoutId
			  , intItemUPCId		= UOM.intItemUOMId
			  , strDescription		= I.strDescription
			  , intVendorId			= IL.intVendorId
			  , intQtySold			= (Chk.SalesQuantity - Chk.RefundCount)
			  , dblCurrentPrice		= CASE 
										WHEN (Chk.SalesQuantity - Chk.RefundCount) = 0
											THEN 0
										ELSE (Chk.SalesAmount + Chk.RefundAmount)  /  (Chk.SalesQuantity - Chk.RefundCount)
									END
			  , dblDiscountAmount	= (Chk.DiscountAmount + Chk.PromotionAmount)
			  -- , dblRefundAmount     = Chk.RefundAmount
			  , dblGrossSales		= (Chk.SalesAmount + Chk.RefundAmount)
			  , dblTotalSales		= (Chk.SalesAmount + Chk.RefundAmount) + (Chk.DiscountAmount + Chk.PromotionAmount)
			  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			FROM @tblTempForCalculation Chk
			INNER JOIN
			(
				SELECT intItemUOMId
					, intItemId
					, strLongUPCCode
					, CASE 
						WHEN strLongUPCCode NOT LIKE '%[^0-9]%' 
							THEN CONVERT(NUMERIC(32, 0),CAST(strLongUPCCode AS FLOAT))
						ELSE NULL
					END AS intLongUpcCode 
				FROM dbo.tblICItemUOM
			) AS UOM
				ON Chk.POSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
				OR CONVERT(NUMERIC(32, 0),CAST(Chk.POSCode AS FLOAT)) = UOM.intLongUpcCode

			INNER JOIN dbo.tblICItem I 
				ON I.intItemId = UOM.intItemId
			INNER JOIN dbo.tblICItemLocation IL 
				ON IL.intItemId = I.intItemId
			INNER JOIN dbo.tblICItemPricing P 
				ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
			INNER JOIN dbo.tblSMCompanyLocation CL 
				ON CL.intCompanyLocationId = IL.intLocationId
			INNER JOIN dbo.tblSTStore S 
				ON S.intCompanyLocationId = CL.intCompanyLocationId
			WHERE S.intStoreId = @intStoreId

		END



		-- Add Mark Up or Down only if ISM Price is not equal to Inventory Retail Price
		-- =============================================================================================================================================================================
		-- Start: Item Price Differences / Department Discounts
		-- =============================================================================================================================================================================
		IF (@strAllowMarkUpDown = 'I' OR @strAllowMarkUpDown = 'D')
			BEGIN
				INSERT INTO dbo.tblSTCheckoutMarkUpDowns
				SELECT @intCheckoutId
					 , IC.intCategoryId
					 , UOM.intItemUOMId
					 , ISNULL(CAST(Chk.SalesQuantity as int),0)

					 -- Sales Price
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > P.dblSalePrice 
											THEN Chk.dblAveragePrice - P.dblSalePrice
										WHEN Chk.dblAveragePrice < P.dblSalePrice 
											THEN P.dblSalePrice - Chk.dblAveragePrice
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > P.dblSalePrice 
											THEN Chk.dblAveragePriceWthDiscounts - P.dblSalePrice
										WHEN Chk.dblAveragePriceWthDiscounts < P.dblSalePrice 
											THEN P.dblSalePrice - Chk.dblAveragePriceWthDiscounts
									END
						END) AS dblRetailUnit

					 -- Total Amount
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > P.dblSalePrice 
											THEN (Chk.dblAveragePrice - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
										WHEN Chk.dblAveragePrice < P.dblSalePrice 
											THEN (P.dblSalePrice - Chk.dblAveragePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > P.dblSalePrice 
											THEN (Chk.dblAveragePriceWthDiscounts - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
										WHEN Chk.dblAveragePriceWthDiscounts < P.dblSalePrice 
											THEN (P.dblSalePrice - Chk.dblAveragePriceWthDiscounts) * ISNULL(CAST(Chk.SalesQuantity as int),0)
									END
						END) AS dblAmount

					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > P.dblSalePrice 
											THEN CAST((Chk.dblAveragePrice - P.dblSalePrice) AS DECIMAL(18,6))
										WHEN Chk.dblAveragePrice < P.dblSalePrice 
											THEN CAST((P.dblSalePrice - Chk.dblAveragePrice) AS DECIMAL(18,6))
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > P.dblSalePrice 
											THEN CAST((Chk.dblAveragePriceWthDiscounts - P.dblSalePrice) AS DECIMAL(18,6))
										WHEN Chk.dblAveragePriceWthDiscounts < P.dblSalePrice 
											THEN CAST((P.dblSalePrice - Chk.dblAveragePriceWthDiscounts) AS DECIMAL(18,6))
									END
						END) AS dblShrink
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > P.dblSalePrice THEN 'Mark Up'
										WHEN Chk.dblAveragePrice < P.dblSalePrice THEN 'Mark Down' 
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > P.dblSalePrice THEN 'Mark Up'
										WHEN Chk.dblAveragePriceWthDiscounts < P.dblSalePrice THEN 'Mark Down' 
									END
						END) AS strUpDownNotes
					 , 1
				FROM @tblTempForCalculation Chk
				INNER JOIN
				(
					SELECT intItemUOMId
						, intItemId
						, strLongUPCCode
						, CASE 
							WHEN strLongUPCCode NOT LIKE '%[^0-9]%' 
								THEN CONVERT(NUMERIC(32, 0),CAST(strLongUPCCode AS FLOAT))
							ELSE NULL
						END AS intLongUpcCode 
					FROM dbo.tblICItemUOM
				) AS UOM
					ON Chk.POSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
					OR CONVERT(NUMERIC(32, 0),CAST(Chk.POSCode AS FLOAT)) = UOM.intLongUpcCode
				INNER JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				INNER JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				INNER JOIN dbo.tblICItemPricing P 
					ON IL.intItemLocationId = P.intItemLocationId 
					AND I.intItemId = P.intItemId
				INNER JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				INNER JOIN dbo.tblICCategory IC 
					ON IC.intCategoryId = I.intCategoryId
				INNER JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
					AND I.strLotTracking = 'No'
					AND P.dblSalePrice != CASE
												WHEN @strAllowMarkUpDown = 'I'
													THEN Chk.dblAveragePrice
												WHEN @strAllowMarkUpDown = 'D'
													THEN Chk.dblAveragePriceWthDiscounts
											END

				-- Get MUD- next Batch number

				DECLARE @strMUDbatchId AS NVARCHAR(1000)
				EXEC uspSTGetMarkUpDownBatchId @strMUDbatchId OUT, @intLocationId

				-- Update batch no.
				UPDATE tblSTCheckoutHeader
				SET strMarkUpDownBatchNo = @strMUDbatchId
				WHERE intCheckoutId = @intCheckoutId
			END
		-- =============================================================================================================================================================================
		-- End: Item Price Differences / Department Discounts
		-- =============================================================================================================================================================================


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