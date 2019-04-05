CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderPLU]
	@intCheckoutId INT,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows INT OUTPUT
AS
BEGIN
	BEGIN TRY
		
		BEGIN TRANSACTION

		DECLARE @intStoreId INT, @strAllowRegisterMarkUpDown NVARCHAR(50), @intShiftNo INT, @intMarkUpDownId INT, @strAllowMarkUpDown NVARCHAR(1)

		SELECT @intStoreId = CH.intStoreId
			   , @intShiftNo = CH.intShiftNo
			   , @strAllowMarkUpDown = ST.strAllowRegisterMarkUpDown 
		FROM dbo.tblSTCheckoutHeader CH
		INNER JOIN dbo.tblSTStore ST
			ON CH.intStoreId = ST.intStoreId
		WHERE CH.intCheckoutId = @intCheckoutId

		

		-- ==================================================================================================================  
		-- Start Validate if PLU xml file matches the Mapping on i21 
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
						, 'Commander PLU XML file did not match the layout mapping'
						, ''
						, ''
						, @intCheckoutId
						, 1
					)

					SET @intCountRows = 0
					SET @strStatusMsg = 'Commander PLU XML file did not match the layout mapping'

					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if PLU xml file matches the Mapping on i21   
		-- ==================================================================================================================  





		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <upc> tag of (RegisterXML) and (Inventory->Item->strUpcCode, strLongUPCCode)
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
			, 'upc' as strRegisterTag
			, ISNULL(Chk.pluBaseupc, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM #tempCheckoutInsert Chk
		WHERE ISNULL(Chk.pluBaseupc, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterPOSCode
			FROM
			(
				SELECT DISTINCT
					Chk.pluBaseupc AS strXmlRegisterPOSCode
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
					ON Chk.pluBaseupc COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
					OR CONVERT(NUMERIC(32, 0),CAST(Chk.pluBaseupc AS FLOAT)) = UOM.intLongUpcCode
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
					AND ISNULL(Chk.pluBaseupc, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.pluBaseupc, '') != ''
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
			UPC NVARCHAR(15),
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
			UPC,
			dblAveragePrice,
			dblAveragePriceWthDiscounts
		)
		SELECT 
			CAST(ISNULL(CAST(netSalesitemCount AS DECIMAL(18, 6)) ,0) AS INT),
			0, -- Commander has No Discount in PLU xml //CAST(DiscountAmount AS DECIMAL(18,6)),
			0, -- Commander has No Promotion in PLU xml //CAST(PromotionAmount AS DECIMAL(18,6)),
			CAST(netSalesamount AS DECIMAL(18,6)),
			0, -- Commander has No Refund in PLU xml //CAST(ISNULL(RefundAmount, 0) AS DECIMAL(18,6)),
			0, -- Commander has No Refund in PLU xml //CAST(ISNULL(RefundCount, 0) AS INT),
			CAST(pluInfosalePrice AS DECIMAL(18,6)),
			pluBaseupc,
			CASE 
				WHEN CAST(CAST(netSalesitemCount AS DECIMAL(18, 6)) AS INT) = 0
					THEN 0
				ELSE ISNULL( NULLIF( CAST(netSalesamount AS DECIMAL(18, 6)) ,0) , 0) /   CAST(CAST(netSalesitemCount AS DECIMAL(18, 6)) AS INT)
			END AS dblAveragePrice,
			CASE 
				WHEN CAST(CAST(netSalesitemCount AS DECIMAL(18, 6)) AS INT) = 0
					THEN 0
				ELSE ISNULL( NULLIF( CAST(netSalesamount AS DECIMAL(18, 6)) ,0) , 0) /   CAST(CAST(netSalesitemCount AS DECIMAL(18, 6)) AS INT)
			END AS dblAveragePriceWthDiscounts
			--CASE 
			--	WHEN ( CAST(netSalesitemCount AS INT) - CAST(RefundCount AS INT) ) = 0
			--		THEN 0
			--	ELSE ISNULL( NULLIF( CAST(netSalesamount AS DECIMAL(18, 6)) + CAST(RefundAmount AS DECIMAL(18, 6)) + CAST(DiscountAmount AS DECIMAL(18, 6)) + CAST(PromotionAmount AS DECIMAL(18, 6)) ,0) , 0) / ( CAST(netSalesitemCount AS INT) - CAST(RefundCount AS INT) )
			--END AS dblAveragePriceWthDiscounts
		FROM #tempCheckoutInsert
		-- ==================================================================================================================
		-- End: Insert to temporary table
		-- ==================================================================================================================



		

		DECLARE @intLocationId AS INT = (SELECT intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId)

		-- ==================================================================================================================
		-- Start: Insert first those UPC's that are not existing in i21
		-- ==================================================================================================================
			INSERT INTO dbo.tblSTCheckoutItemMovements
			(
				intCheckoutId
				, intItemUPCId
				, strInvalidUPCCode
				, strDescription
				, intVendorId
				, intQtySold
				, dblCurrentPrice
				, dblDiscountAmount
				, dblGrossSales
				, dblTotalSales
				, dblItemStandardCost
				, intConcurrencyId
			)
			SELECT 
				intCheckoutId		= @intCheckoutId
			  , intItemUPCId		= NULL -- UOM.intItemUOMId
			  , strInvalidUPCCode	= ISNULL(TmpChk.UPC, '')
			  , strDescription		= NULL -- I.strDescription
			  , intVendorId			= NULL -- IL.intVendorId
			  , intQtySold			= (TmpChk.SalesQuantity)
			  , dblCurrentPrice		= CASE 
										WHEN (TmpChk.SalesQuantity) = 0
											THEN 0
										ELSE (TmpChk.SalesAmount)  /  (TmpChk.SalesQuantity)
									END
			  , dblDiscountAmount	= (TmpChk.DiscountAmount + TmpChk.PromotionAmount)
			  , dblGrossSales		= (TmpChk.SalesAmount)
			  , dblTotalSales		= (TmpChk.SalesAmount) + (TmpChk.DiscountAmount + TmpChk.PromotionAmount)
			  , dblItemStandardCost = NULL --ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			FROM @tblTempForCalculation TmpChk
			WHERE ISNULL(TmpChk.UPC, '') NOT IN
			(
				SELECT DISTINCT 
					tbl.strXmlRegisterPOSCode
				FROM
				(
					SELECT DISTINCT
						Chk.pluBaseupc AS strXmlRegisterPOSCode
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
						ON Chk.pluBaseupc COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
						OR CONVERT(NUMERIC(32, 0),CAST(Chk.pluBaseupc AS FLOAT)) = UOM.intLongUpcCode
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
						AND ISNULL(Chk.pluBaseupc, '') != ''
				) AS tbl
			)
			AND ISNULL(TmpChk.UPC, '') != ''
		-- ==================================================================================================================
		-- End: Insert first those UPC's that are not existing in i21
		-- ==================================================================================================================




		-- ==================================================================================================================
		-- Start: All Item Movement
		-- ==================================================================================================================
			INSERT INTO dbo.tblSTCheckoutItemMovements
			(
				intCheckoutId
				, intItemUPCId
				, strInvalidUPCCode
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
			  , strInvalidUPCCode   = NULL
			  , strDescription		= I.strDescription
			  , intVendorId			= IL.intVendorId
			  , intQtySold			= (TmpChk.SalesQuantity)
			  , dblCurrentPrice		= CASE 
										WHEN (TmpChk.SalesQuantity) = 0
											THEN 0
										ELSE (TmpChk.SalesAmount)  /  (TmpChk.SalesQuantity)
									END
			  , dblDiscountAmount	= (TmpChk.DiscountAmount + TmpChk.PromotionAmount)
			  -- , dblRefundAmount     = Chk.RefundAmount
			  , dblGrossSales		= (TmpChk.SalesAmount)
			  , dblTotalSales		= (TmpChk.SalesAmount) + (TmpChk.DiscountAmount + TmpChk.PromotionAmount)
			  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			FROM @tblTempForCalculation TmpChk
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
				ON TmpChk.UPC COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
				OR CONVERT(NUMERIC(32, 0),CAST(TmpChk.UPC AS FLOAT)) = UOM.intLongUpcCode

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
		-- ==================================================================================================================
		-- End: All Item Movement
		-- ==================================================================================================================




		-- ==================================================================================================================
		-- Start: Item Movement Add extra line for refund
		-- ==================================================================================================================
			INSERT INTO dbo.tblSTCheckoutItemMovements
			(
				intCheckoutId
				, intItemUPCId
				, strInvalidUPCCode
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
			  , strInvalidUPCCode	= NULL
			  , strDescription		= I.strDescription
			  , intVendorId			= IL.intVendorId
			  , intQtySold			= (TmpChk.RefundCount * -1)
			  , dblCurrentPrice		= ABS(TmpChk.RefundAmount)
			  , dblDiscountAmount	= 0
			  -- , dblRefundAmount     = Chk.RefundAmount
			  , dblGrossSales		= (TmpChk.RefundCount * -1) * ABS(TmpChk.RefundAmount)
			  , dblTotalSales		= (TmpChk.RefundCount * -1) * ABS(TmpChk.RefundAmount)
			  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			FROM @tblTempForCalculation TmpChk
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
				ON TmpChk.UPC COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
				OR CONVERT(NUMERIC(32, 0),CAST(TmpChk.UPC AS FLOAT)) = UOM.intLongUpcCode

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
				AND TmpChk.RefundCount > 0 -- Only Items with REFUND
		-- ==================================================================================================================
		-- End: Item Movement Add extra line for refund
		-- ==================================================================================================================





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
					 , ISNULL(CAST(TmpChk.SalesQuantity as int),0)

					 -- Sales Price
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN TmpChk.dblAveragePrice > P.dblSalePrice 
											THEN (TmpChk.dblAveragePrice)							-- Chk.dblAveragePrice - P.dblSalePrice
										WHEN TmpChk.dblAveragePrice < P.dblSalePrice 
											THEN (TmpChk.dblAveragePrice)							-- P.dblSalePrice - Chk.dblAveragePrice
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN TmpChk.dblAveragePriceWthDiscounts > P.dblSalePrice 
											THEN (TmpChk.dblAveragePriceWthDiscounts)				-- Chk.dblAveragePriceWthDiscounts - P.dblSalePrice
										WHEN TmpChk.dblAveragePriceWthDiscounts < P.dblSalePrice 
											THEN (TmpChk.dblAveragePriceWthDiscounts)				-- P.dblSalePrice - Chk.dblAveragePriceWthDiscounts
									END
						END) AS dblRetailUnit

					 -- Total Amount
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN TmpChk.dblAveragePrice > P.dblSalePrice 
											THEN (TmpChk.dblAveragePrice * TmpChk.SalesQuantity)			-- (Chk.dblAveragePrice - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
										WHEN TmpChk.dblAveragePrice < P.dblSalePrice 
											THEN (TmpChk.dblAveragePrice * TmpChk.SalesQuantity)			-- (P.dblSalePrice - Chk.dblAveragePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN TmpChk.dblAveragePriceWthDiscounts > P.dblSalePrice 
											THEN (TmpChk.dblAveragePriceWthDiscounts * TmpChk.SalesQuantity)	-- (Chk.dblAveragePriceWthDiscounts - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
										WHEN TmpChk.dblAveragePriceWthDiscounts < P.dblSalePrice 
											THEN (TmpChk.dblAveragePriceWthDiscounts * TmpChk.SalesQuantity)  -- (P.dblSalePrice - Chk.dblAveragePriceWthDiscounts) * ISNULL(CAST(Chk.SalesQuantity as int),0)
									END
						END) AS dblAmount

					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN TmpChk.dblAveragePrice > P.dblSalePrice 
											THEN CAST((TmpChk.dblAveragePrice - P.dblSalePrice) AS DECIMAL(18,6))
										WHEN TmpChk.dblAveragePrice < P.dblSalePrice 
											THEN CAST((P.dblSalePrice - TmpChk.dblAveragePrice) AS DECIMAL(18,6))
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN TmpChk.dblAveragePriceWthDiscounts > P.dblSalePrice 
											THEN CAST((TmpChk.dblAveragePriceWthDiscounts - P.dblSalePrice) AS DECIMAL(18,6))
										WHEN TmpChk.dblAveragePriceWthDiscounts < P.dblSalePrice 
											THEN CAST((P.dblSalePrice - TmpChk.dblAveragePriceWthDiscounts) AS DECIMAL(18,6))
									END
						END) AS dblShrink
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN TmpChk.dblAveragePrice > P.dblSalePrice THEN 'Mark Up'
										WHEN TmpChk.dblAveragePrice < P.dblSalePrice THEN 'Mark Down' 
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN TmpChk.dblAveragePriceWthDiscounts > P.dblSalePrice THEN 'Mark Up'
										WHEN TmpChk.dblAveragePriceWthDiscounts < P.dblSalePrice THEN 'Mark Down' 
									END
						END) AS strUpDownNotes
					 , 1
				FROM @tblTempForCalculation TmpChk
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
					ON TmpChk.UPC COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
					OR CONVERT(NUMERIC(32, 0),CAST(TmpChk.UPC AS FLOAT)) = UOM.intLongUpcCode
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
					AND TmpChk.SalesQuantity > 0
					AND 0 < CASE
								WHEN @strAllowMarkUpDown = 'I'
									THEN TmpChk.dblAveragePrice
								WHEN @strAllowMarkUpDown = 'D'
									THEN TmpChk.dblAveragePriceWthDiscounts
							END
					AND P.dblSalePrice != CASE
												WHEN @strAllowMarkUpDown = 'I'
													THEN TmpChk.dblAveragePrice
												WHEN @strAllowMarkUpDown = 'D'
													THEN TmpChk.dblAveragePriceWthDiscounts
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