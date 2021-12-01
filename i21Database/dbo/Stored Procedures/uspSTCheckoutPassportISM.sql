CREATE PROCEDURE [dbo].[uspSTCheckoutPassportISM]
	@intCheckoutId INT,
	@UDT_ISM	StagingPassportISM		READONLY,
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
		IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_ISM)
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
			, ISNULL(Chk.strPOSCode, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM @UDT_ISM Chk
		WHERE ISNULL(Chk.strPOSCode, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterPOSCode
			FROM
			(
				SELECT DISTINCT
					Chk.strPOSCode AS strXmlRegisterPOSCode
				FROM @UDT_ISM Chk
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
					ON Chk.strPOSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
					OR CONVERT(NUMERIC(32, 0),CAST(Chk.strPOSCode AS FLOAT)) = UOM.intLongUpcCode
				INNER JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				INNER JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				LEFT JOIN dbo.tblICItemPricing P 
					ON IL.intItemLocationId = P.intItemLocationId 
					AND I.intItemId = P.intItemId
				INNER JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				INNER JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
					AND ISNULL(Chk.strPOSCode, '') != ''
			) AS tbl
		)
		AND ISNULL(Chk.strPOSCode, '') != ''
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================



		-- ==================================================================================================================
		-- Start: Insert to temporary table
		-- ==================================================================================================================
		DECLARE @tblTempForCalculation TABLE
		(
			dblSalesQuantity INT,
			dblDiscountAmount DECIMAL(18, 6),
			dblPromotionAmount DECIMAL(18, 6),
			dblRefundAmount DECIMAL(18, 6),
			dblRefundCount INT,
			dblSalesAmount DECIMAL(18, 6),
			dblActualSalesPrice DECIMAL(18, 6),
			strPOSCode NVARCHAR(15),
			dblAveragePrice DECIMAL(18, 6),
			dblAveragePriceWthDiscounts DECIMAL(18, 6)
		)

		INSERT INTO @tblTempForCalculation
		(
			dblSalesQuantity,
			dblDiscountAmount,
			dblPromotionAmount,
			dblSalesAmount,
			dblRefundAmount,
			dblRefundCount,
			dblActualSalesPrice,
			strPOSCode,
			dblAveragePrice,
			dblAveragePriceWthDiscounts
		)
		SELECT 
			CAST(ISNULL(dblSalesQuantity ,0) AS INT),
			CAST(dblDiscountAmount AS DECIMAL(18,6)),
			CAST(dblPromotionAmount AS DECIMAL(18,6)),
			CAST(dblSalesAmount AS DECIMAL(18,6)),
			CAST(ISNULL(dblRefundAmount, 0) AS DECIMAL(18,6)),
			CAST(ISNULL(dblRefundCount, 0) AS INT),
			CAST(dblActualSalesPrice AS DECIMAL(18,6)),
			strPOSCode,
			CASE 
				WHEN CAST(dblSalesQuantity AS INT) = 0
					THEN 0
				ELSE ISNULL( NULLIF( CAST(dblSalesAmount AS DECIMAL(18, 6)) ,0) , 0)  /  CAST(dblSalesQuantity AS INT)
			END AS dblAveragePrice,
			CASE 
				WHEN CAST(dblSalesQuantity AS INT) = 0
					THEN 0
				ELSE ISNULL( NULLIF( CAST(dblSalesAmount AS DECIMAL(18, 6)) + CAST(dblDiscountAmount AS DECIMAL(18, 6)) + CAST(dblPromotionAmount AS DECIMAL(18, 6)) ,0) , 0)  /  CAST(dblSalesQuantity AS INT)
			END AS dblAveragePriceWthDiscounts
		FROM @UDT_ISM
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
			  , strInvalidUPCCode	= ISNULL(Chk.strPOSCode, '')
			  , strDescription		= NULL -- I.strDescription
			  , intVendorId			= NULL -- IL.intVendorId
			  , intQtySold			= (Chk.dblSalesQuantity)
			  , dblCurrentPrice		= CASE 
										WHEN (Chk.dblSalesQuantity) = 0
											THEN 0
										ELSE (Chk.dblSalesAmount)  /  (Chk.dblSalesQuantity)
									END
			  , dblDiscountAmount	= (Chk.dblDiscountAmount + Chk.dblPromotionAmount)
			  , dblGrossSales		= (Chk.dblSalesAmount)
			  , dblTotalSales		= (Chk.dblSalesAmount) + (Chk.dblDiscountAmount + Chk.dblPromotionAmount)
			  , dblItemStandardCost = NULL --ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			FROM @tblTempForCalculation Chk
			WHERE ISNULL(Chk.strPOSCode, '') NOT IN
			(
				SELECT DISTINCT 
					tbl.strXmlRegisterPOSCode
				FROM
				(
					SELECT DISTINCT
						Chk.strPOSCode AS strXmlRegisterPOSCode
					FROM @UDT_ISM Chk
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
						ON Chk.strPOSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
						OR CONVERT(NUMERIC(32, 0),CAST(Chk.strPOSCode AS FLOAT)) = UOM.intLongUpcCode
					INNER JOIN dbo.tblICItem I 
						ON I.intItemId = UOM.intItemId
					INNER JOIN dbo.tblICItemLocation IL 
						ON IL.intItemId = I.intItemId
					LEFT JOIN dbo.tblICItemPricing P 
						ON IL.intItemLocationId = P.intItemLocationId 
						AND I.intItemId = P.intItemId
					INNER JOIN dbo.tblSMCompanyLocation CL 
						ON CL.intCompanyLocationId = IL.intLocationId
					INNER JOIN dbo.tblSTStore S 
						ON S.intCompanyLocationId = CL.intCompanyLocationId
					WHERE S.intStoreId = @intStoreId
						AND ISNULL(Chk.strPOSCode, '') != ''
				) AS tbl
			)
			AND ISNULL(Chk.strPOSCode, '') != ''
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
				-- , dbldblRefundAmount
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
			  , intQtySold			= (Chk.dblSalesQuantity)
			  , dblCurrentPrice		= CASE 
										WHEN (Chk.dblSalesQuantity) = 0
											THEN 0
										ELSE (Chk.dblSalesAmount)  /  (Chk.dblSalesQuantity)
									END
			  , dblDiscountAmount	= (Chk.dblDiscountAmount + Chk.dblPromotionAmount)
			  -- , dbldblRefundAmount     = Chk.dblRefundAmount
			  , dblGrossSales		= (Chk.dblSalesAmount)
			  , dblTotalSales		= (Chk.dblSalesAmount) + (Chk.dblDiscountAmount + Chk.dblPromotionAmount)
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
				ON Chk.strPOSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
				OR CONVERT(NUMERIC(32, 0),CAST(Chk.strPOSCode AS FLOAT)) = UOM.intLongUpcCode

			INNER JOIN dbo.tblICItem I 
				ON I.intItemId = UOM.intItemId
			INNER JOIN dbo.tblICItemLocation IL 
				ON IL.intItemId = I.intItemId
			LEFT JOIN dbo.tblICItemPricing P 
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
				-- , dbldblRefundAmount
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
			  , intQtySold			= (Chk.dblRefundCount * -1)
			  , dblCurrentPrice		= (ABS(Chk.dblRefundAmount) / Chk.dblRefundCount)
			  , dblDiscountAmount	= 0
			  -- , dbldblRefundAmount     = Chk.dblRefundAmount
			  , dblGrossSales		= (Chk.dblRefundCount * -1) * (ABS(Chk.dblRefundAmount) / Chk.dblRefundCount)
			  , dblTotalSales		= (Chk.dblRefundCount * -1) * (ABS(Chk.dblRefundAmount) / Chk.dblRefundCount)
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
				ON Chk.strPOSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
				OR CONVERT(NUMERIC(32, 0),CAST(Chk.strPOSCode AS FLOAT)) = UOM.intLongUpcCode

			INNER JOIN dbo.tblICItem I 
				ON I.intItemId = UOM.intItemId
			INNER JOIN dbo.tblICItemLocation IL 
				ON IL.intItemId = I.intItemId
			LEFT JOIN dbo.tblICItemPricing P 
				ON IL.intItemLocationId = P.intItemLocationId 
				AND I.intItemId = P.intItemId
			INNER JOIN dbo.tblSMCompanyLocation CL 
				ON CL.intCompanyLocationId = IL.intLocationId
			INNER JOIN dbo.tblSTStore S 
				ON S.intCompanyLocationId = CL.intCompanyLocationId
			WHERE S.intStoreId = @intStoreId
				AND Chk.dblRefundCount > 0 -- Only Items with REFUND
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
					 , ISNULL(CAST(Chk.dblSalesQuantity as int),0)

					 -- Sales Price
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
											THEN (Chk.dblAveragePrice)							-- Chk.dblAveragePrice - P.dblSalePrice
										WHEN Chk.dblAveragePrice < ISNULL(P.dblSalePrice, 0)
											THEN (Chk.dblAveragePrice)							-- P.dblSalePrice - Chk.dblAveragePrice
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
											THEN (Chk.dblAveragePriceWthDiscounts)						-- Chk.dblAveragePriceWthDiscounts - P.dblSalePrice
										WHEN Chk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
											THEN (Chk.dblAveragePriceWthDiscounts)						-- P.dblSalePrice - Chk.dblAveragePriceWthDiscounts
									END
						END) AS dblRetailUnit

					 -- Total Amount
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > ISNULL(P.dblSalePrice, 0)
											THEN (Chk.dblAveragePrice * Chk.dblSalesQuantity)			-- (Chk.dblAveragePrice - P.dblSalePrice) * ISNULL(CAST(Chk.dblSalesQuantity as int),0)
										WHEN Chk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
											THEN (Chk.dblAveragePrice * Chk.dblSalesQuantity)			-- (P.dblSalePrice - Chk.dblAveragePrice) * ISNULL(CAST(Chk.dblSalesQuantity as int),0)
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
											THEN (Chk.dblAveragePriceWthDiscounts * Chk.dblSalesQuantity)	-- (Chk.dblAveragePriceWthDiscounts - P.dblSalePrice) * ISNULL(CAST(Chk.dblSalesQuantity as int),0)
										WHEN Chk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
											THEN (Chk.dblAveragePriceWthDiscounts * Chk.dblSalesQuantity)  -- (P.dblSalePrice - Chk.dblAveragePriceWthDiscounts) * ISNULL(CAST(Chk.dblSalesQuantity as int),0)
									END
						END) AS dblAmount

					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > ISNULL(P.dblSalePrice, 0)
											THEN CAST((Chk.dblAveragePrice - ISNULL(P.dblSalePrice, 0)) AS DECIMAL(18,6))
										WHEN Chk.dblAveragePrice < ISNULL(P.dblSalePrice, 0)
											THEN CAST((ISNULL(P.dblSalePrice, 0) - Chk.dblAveragePrice) AS DECIMAL(18,6))
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
											THEN CAST((Chk.dblAveragePriceWthDiscounts - ISNULL(P.dblSalePrice, 0)) AS DECIMAL(18,6))
										WHEN Chk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0)
											THEN CAST((ISNULL(P.dblSalePrice, 0) - Chk.dblAveragePriceWthDiscounts) AS DECIMAL(18,6))
									END
						END) AS dblShrink
					 , (CASE 
							WHEN @strAllowMarkUpDown = 'I'
								THEN CASE
										WHEN Chk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) THEN 'Mark Up'
										WHEN Chk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) THEN 'Mark Down' 
									END
							WHEN @strAllowMarkUpDown = 'D'
								THEN CASE
										WHEN Chk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) THEN 'Mark Up'
										WHEN Chk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) THEN 'Mark Down' 
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
					ON Chk.strPOSCode COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
					OR CONVERT(NUMERIC(32, 0),CAST(Chk.strPOSCode AS FLOAT)) = UOM.intLongUpcCode
				INNER JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				INNER JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				LEFT JOIN dbo.tblICItemPricing P 
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
					AND Chk.dblSalesQuantity > 0
					AND 0 < CASE
								WHEN @strAllowMarkUpDown = 'I'
									THEN Chk.dblAveragePrice
								WHEN @strAllowMarkUpDown = 'D'
									THEN Chk.dblAveragePriceWthDiscounts
							END
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