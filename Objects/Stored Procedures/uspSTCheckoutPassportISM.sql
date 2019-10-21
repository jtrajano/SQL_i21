CREATE PROCEDURE [dbo].[uspSTCheckoutPassportISM]
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


		DECLARE @tblTemp TABLE
		(
			intRowCount											INT,
			intTransmissionHeaderStoreLocationID				INT,
			strTransmissionHeaderVendorName						NVARCHAR(150),
			strTransmissionHeaderVendorModelVersion				NVARCHAR(150),
			intMovementHeaderReportSequenceNumber				INT,
			intMovementHeaderPrimaryReportPeriod				INT,
			intMovementHeaderSecondaryReportPeriod				INT,
			dtmMovementHeaderBusinessDate						DATE,
			dtmMovementHeaderBeginDate							DATE,
			dtmMovementHeaderBeginTime							TIME,
			dtmMovementHeaderEndDate							DATE,
			dtmMovementHeaderEndTime							TIME,
			strISMDetailItemID									NVARCHAR(50),
			strISMDetailDescription								NVARCHAR(150),
			strISMDetailMerchandiseCode							NVARCHAR(50),
			intISMDetailSellingUnits							INT,
			strPOSCodeFormatformat								NVARCHAR(20),
			strItemCodePOSCodeFormat							NVARCHAR(50),
			strItemCodePOSCode									NVARCHAR(20),
			intItemCodePOSCodeModifier							INT,
			dblISMSellPriceSummaryActualSalesPrice				DECIMAL(18, 6),
			intISMSalesTotalsSalesQuantity						INT,
			dblISMSalesTotalsSalesAmount						DECIMAL(18, 6),
			dblISMSalesTotalsDiscountAmount						DECIMAL(18, 6),
			intISMSalesTotalsDiscountCount						INT,
			dblISMSalesTotalsPromotionAmount					DECIMAL(18, 6),
			intISMSalesTotalsPromotionCount						INT,
			dblISMSalesTotalsRefundAmount						DECIMAL(18, 6),
			intISMSalesTotalsRefundCount						INT,
			intISMSalesTotalsTransactionCount					INT,
			intRegisterUpcCode									BIGINT
		)

		BEGIN TRY
			INSERT INTO @tblTemp
			(
				intRowCount,
				intTransmissionHeaderStoreLocationID,
				strTransmissionHeaderVendorName,
				strTransmissionHeaderVendorModelVersion,
				intMovementHeaderReportSequenceNumber,
				intMovementHeaderPrimaryReportPeriod,
				intMovementHeaderSecondaryReportPeriod,
				dtmMovementHeaderBusinessDate,
				dtmMovementHeaderBeginDate,
				dtmMovementHeaderBeginTime,
				dtmMovementHeaderEndDate,
				dtmMovementHeaderEndTime,
				strISMDetailItemID,
				strISMDetailDescription,
				strISMDetailMerchandiseCode,
				intISMDetailSellingUnits,
				strPOSCodeFormatformat,
				strItemCodePOSCodeFormat,
				strItemCodePOSCode,
				intItemCodePOSCodeModifier,
				dblISMSellPriceSummaryActualSalesPrice,
				intISMSalesTotalsSalesQuantity,
				dblISMSalesTotalsSalesAmount,
				dblISMSalesTotalsDiscountAmount,
				intISMSalesTotalsDiscountCount,
				dblISMSalesTotalsPromotionAmount,
				intISMSalesTotalsPromotionCount,
				dblISMSalesTotalsRefundAmount,
				intISMSalesTotalsRefundCount,
				intISMSalesTotalsTransactionCount,
				intRegisterUpcCode
			)
			SELECT 
				intRowCount									= CAST(temp.intRowCount AS INT),
				intTransmissionHeaderStoreLocationID		= CAST(temp.TransmissionHeaderStoreLocationID AS INT),
				strTransmissionHeaderVendorName				= ISNULL(temp.TransmissionHeaderVendorName, ''),
				strTransmissionHeaderVendorModelVersion		= ISNULL(temp.TransmissionHeaderVendorModelVersion, ''),
				intMovementHeaderReportSequenceNumber		= CAST(temp.MovementHeaderReportSequenceNumber AS INT),
				intMovementHeaderPrimaryReportPeriod		= CAST(temp.MovementHeaderPrimaryReportPeriod AS INT),
				intMovementHeaderSecondaryReportPeriod		= CAST(temp.MovementHeaderSecondaryReportPeriod AS INT),
				dtmMovementHeaderBusinessDate				= CAST(temp.MovementHeaderBusinessDate AS DATE),
				dtmMovementHeaderBeginDate					= CAST(temp.MovementHeaderBeginDate AS DATE),
				dtmMovementHeaderBeginTime					= CAST(temp.MovementHeaderBeginTime AS TIME),
				dtmMovementHeaderEndDate					= CAST(temp.MovementHeaderEndDate AS DATE),
				dtmMovementHeaderEndTime					= CAST(temp.MovementHeaderEndTime AS TIME),
				strISMDetailItemID							= ISNULL(temp.ISMDetailItemID, ''),
				strISMDetailDescription						= ISNULL(temp.ISMDetailDescription, ''),
				strISMDetailMerchandiseCode					= ISNULL(temp.ISMDetailMerchandiseCode, ''),
				intISMDetailSellingUnits					= CAST(temp.ISMDetailSellingUnits AS INT),
				strPOSCodeFormatformat						= ISNULL(temp.POSCodeFormatformat, ''),
				strItemCodePOSCodeFormat					= ISNULL(temp.ItemCodePOSCodeFormat, ''),
				strItemCodePOSCode							= ISNULL(temp.ItemCodePOSCode, ''),
				intItemCodePOSCodeModifier					= CAST(temp.ItemCodePOSCodeModifier AS INT),
				dblISMSellPriceSummaryActualSalesPrice		= CAST(temp.ISMSellPriceSummaryActualSalesPrice AS DECIMAL(18, 6)),
				intISMSalesTotalsSalesQuantity				= CAST(temp.ISMSalesTotalsSalesQuantity AS INT),
				dblISMSalesTotalsSalesAmount				= CAST(temp.ISMSalesTotalsSalesAmount AS DECIMAL(18, 6)),
				dblISMSalesTotalsDiscountAmount				= CAST(temp.ISMSalesTotalsDiscountAmount AS DECIMAL(18, 6)),
				intISMSalesTotalsDiscountCount				= CAST(temp.ISMSalesTotalsDiscountCount AS INT),
				dblISMSalesTotalsPromotionAmount			= CAST(temp.ISMSalesTotalsPromotionAmount AS DECIMAL(18, 6)),
				intISMSalesTotalsPromotionCount				= CAST(temp.ISMSalesTotalsPromotionCount AS INT),
				dblISMSalesTotalsRefundAmount				= CAST(temp.ISMSalesTotalsRefundAmount AS DECIMAL(18, 6)),
				intISMSalesTotalsRefundCount				= CAST(temp.ISMSalesTotalsRefundCount AS INT),
				intISMSalesTotalsTransactionCount			= CAST(temp.ISMSalesTotalsTransactionCount AS INT),
				intRegisterUpcCode							= CONVERT(NUMERIC(32, 0),CAST(temp.ItemCodePOSCode AS FLOAT)) -- Remove Leading Zeros if PASSPORT,									
			FROM #tempCheckoutInsert temp
		END TRY
		BEGIN CATCH
			SET @intCountRows = 0
			SET @strStatusMsg = 'Passport ISM - Insert to temporary table: ' + ERROR_MESSAGE()

			GOTO ExitWithRollback
		END CATCH



		-- ==================================================================================================================  
		-- Start Validate if ISM xml file matches the Mapping on i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM @tblTemp)
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
		-- Compare <ItemCodePOSCode> tag of (RegisterXML) and (Inventory->Item->strUpcCode, strLongUPCCode)
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
			, ISNULL(Chk.strItemCodePOSCode, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM @tblTemp Chk
		WHERE CAST(Chk.intRegisterUpcCode AS BIGINT) NOT IN
		(
			SELECT DISTINCT
				CAST(UOM.intUpcCode AS BIGINT) AS intUpcCode
			FROM @tblTemp Chk
			INNER JOIN vyuSTItemUOMPosCodeFormat UOM
				ON CAST(Chk.intRegisterUpcCode AS BIGINT) = CAST(UOM.intUpcCode AS BIGINT)
			INNER JOIN dbo.tblICItem I 
				ON I.intItemId = UOM.intItemId
			INNER JOIN dbo.tblICItemLocation IL 
				ON IL.intItemId = I.intItemId
				AND UOM.intLocationId = IL.intLocationId
			LEFT JOIN dbo.tblICItemPricing P 
				ON IL.intItemLocationId = P.intItemLocationId 
				AND I.intItemId = P.intItemId
			INNER JOIN dbo.tblSMCompanyLocation CL 
				ON CL.intCompanyLocationId = IL.intLocationId
			INNER JOIN dbo.tblSTStore S 
				ON S.intCompanyLocationId = CL.intCompanyLocationId
			WHERE S.intStoreId = @intStoreId
				AND ISNULL(Chk.strItemCodePOSCode, '') != ''
		)
			AND ISNULL(Chk.strItemCodePOSCode, '') != ''
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================





		-- ==================================================================================================================
		-- Start: Insert to temporary table
		-- ==================================================================================================================
		DECLARE @tblTempForCalculation TABLE
		(
			intCalculationId			INT	NOT NULL IDENTITY,
			intCheckoutId				INT,
			SalesQuantity				INT,
			DiscountAmount				DECIMAL(18, 6),
			PromotionAmount				DECIMAL(18, 6),
			RefundAmount				DECIMAL(18, 6),
			RefundCount					INT,
			SalesAmount					DECIMAL(18, 6),
			ActualSalesPrice			DECIMAL(18, 6),
			POSCode						NVARCHAR(15),
			intPOSCode					BIGINT,
			dblAveragePrice				DECIMAL(18, 6),
			dblAveragePriceWthDiscounts DECIMAL(18, 6)
		)



		INSERT INTO @tblTempForCalculation
		(
			intCheckoutId,
			SalesQuantity,
			DiscountAmount,
			PromotionAmount,
			SalesAmount,
			RefundAmount,
			RefundCount,
			ActualSalesPrice,
			POSCode,
			intPOSCode,
			dblAveragePrice,
			dblAveragePriceWthDiscounts
		)
		SELECT 
			intCheckoutId				= @intCheckoutId,
			SalesQuantity				= CAST(ISNULL(Chk.intISMSalesTotalsSalesQuantity ,0) AS INT),
			DiscountAmount				= CAST(Chk.dblISMSalesTotalsDiscountAmount AS DECIMAL(18,6)),
			PromotionAmount				= CAST(Chk.dblISMSalesTotalsPromotionAmount AS DECIMAL(18,6)),
			SalesAmount					= CAST(Chk.dblISMSalesTotalsSalesAmount AS DECIMAL(18,6)),
			RefundAmount				= CAST(ISNULL(Chk.dblISMSalesTotalsRefundAmount, 0) AS DECIMAL(18,6)),
			RefundCount					= CAST(ISNULL(Chk.intISMSalesTotalsRefundCount, 0) AS INT),
			ActualSalesPrice			= CAST(Chk.dblISMSellPriceSummaryActualSalesPrice AS DECIMAL(18,6)),
			POSCode						= Chk.strItemCodePOSCode,
			intPOSCode					= CAST(Chk.intRegisterUpcCode AS BIGINT),
			dblAveragePrice				= CASE 
											WHEN ( CAST(Chk.intISMSalesTotalsSalesQuantity AS INT) - CAST(Chk.intISMSalesTotalsRefundCount AS INT) ) = 0
												THEN 0
											ELSE ISNULL( NULLIF( CAST(Chk.dblISMSalesTotalsSalesAmount AS DECIMAL(18, 6)) + CAST(Chk.dblISMSalesTotalsRefundAmount AS DECIMAL(18, 6)) ,0) , 0) / ( CAST(Chk.intISMSalesTotalsSalesQuantity AS INT) - CAST(Chk.intISMSalesTotalsRefundCount AS INT) )
										END,
			dblAveragePriceWthDiscounts = CASE 
											WHEN ( CAST(Chk.intISMSalesTotalsSalesQuantity AS INT) - CAST(Chk.intISMSalesTotalsRefundCount AS INT) ) = 0
												THEN 0
											ELSE ISNULL( NULLIF( CAST(Chk.dblISMSalesTotalsSalesAmount AS DECIMAL(18, 6)) + CAST(Chk.dblISMSalesTotalsRefundAmount AS DECIMAL(18, 6)) + CAST(Chk.dblISMSalesTotalsDiscountAmount AS DECIMAL(18, 6)) + CAST(Chk.dblISMSalesTotalsPromotionAmount AS DECIMAL(18, 6)) ,0) , 0) / ( CAST(Chk.intISMSalesTotalsSalesQuantity AS INT) - CAST(Chk.intISMSalesTotalsRefundCount AS INT) )
										END
		FROM @tblTemp Chk
		-- ==================================================================================================================
		-- End: Insert to temporary table
		-- ==================================================================================================================


		--SELECT * FROM @tblTempForCalculation
		

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
				, intCalculationId
			)
			SELECT 
				intCheckoutId		= @intCheckoutId
			  , intItemUPCId		= NULL -- UOM.intItemUOMId
			  , strInvalidUPCCode	= ISNULL(TempChk.POSCode, '')
			  , strDescription		= NULL -- I.strDescription
			  , intVendorId			= NULL -- IL.intVendorId
			  , intQtySold			= (TempChk.SalesQuantity)
			  , dblCurrentPrice		= CASE 
										WHEN (TempChk.SalesQuantity) = 0
											THEN 0
										ELSE (TempChk.SalesAmount)  /  (TempChk.SalesQuantity)
									END
			  , dblDiscountAmount	= (TempChk.DiscountAmount + TempChk.PromotionAmount)
			  , dblGrossSales		= (TempChk.SalesAmount)
			  , dblTotalSales		= (TempChk.SalesAmount) + (TempChk.DiscountAmount + TempChk.PromotionAmount)
			  , dblItemStandardCost = NULL --ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			  , intCalculationId	= TempChk.intCalculationId
			FROM @tblTempForCalculation TempChk
			WHERE TempChk.intPOSCode NOT IN
			(
				SELECT DISTINCT
					UOM.intUpcCode AS intPOSCode
				FROM tblICItemUOM UOM
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
					AND UOM.strLongUPCCode IS NOT NULL
					AND UOM.intUpcCode IS NOT NULL
			)
			AND ISNULL(TempChk.POSCode, '') != ''
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
				, intCalculationId
			)
			SELECT 
				intCheckoutId		= @intCheckoutId
			  , intItemUPCId		= UOM.intItemUOMId
			  , strInvalidUPCCode   = NULL
			  , strDescription		= I.strDescription
			  , intVendorId			= IL.intVendorId
			  , intQtySold			= (TempChk.SalesQuantity)
			  , dblCurrentPrice		= CASE 
										WHEN (TempChk.SalesQuantity) = 0
											THEN 0
										ELSE (TempChk.SalesAmount)  /  (TempChk.SalesQuantity)
									END
			  , dblDiscountAmount	= (TempChk.DiscountAmount + TempChk.PromotionAmount)
			  -- , dblRefundAmount     = Chk.RefundAmount
			  , dblGrossSales		= (TempChk.SalesAmount)
			  , dblTotalSales		= (TempChk.SalesAmount) + (TempChk.DiscountAmount + TempChk.PromotionAmount)
			  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			  , intCalculationId	= TempChk.intCalculationId
			FROM @tblTempForCalculation TempChk
			INNER JOIN tblICItemUOM UOM
				ON TempChk.intPOSCode = UOM.intUpcCode
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
				AND ISNULL(TempChk.POSCode, '') != ''
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
				, intCalculationId
			)
			SELECT 
				intCheckoutId		= @intCheckoutId
			  , intItemUPCId		= UOM.intItemUOMId
			  , strInvalidUPCCode	= NULL
			  , strDescription		= I.strDescription
			  , intVendorId			= IL.intVendorId
			  , intQtySold			= (TempChk.RefundCount * -1)
			  , dblCurrentPrice		= (ABS(TempChk.RefundAmount) / TempChk.RefundCount)
			  , dblDiscountAmount	= 0
			  -- , dblRefundAmount     = Chk.RefundAmount
			  , dblGrossSales		= (TempChk.RefundCount * -1) * (ABS(TempChk.RefundAmount) / TempChk.RefundCount)
			  , dblTotalSales		= (TempChk.RefundCount * -1) * (ABS(TempChk.RefundAmount) / TempChk.RefundCount)
			  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost AS DECIMAL(18,6)),0)
			  , intConcurrencyId	= 1
			  , intCalculationId	= TempChk.intCalculationId
			FROM @tblTempForCalculation TempChk
			INNER JOIN tblICItemUOM UOM
				ON TempChk.intPOSCode = UOM.intUpcCode
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
				AND TempChk.RefundCount > 0 -- Only Items with REFUND
				AND ISNULL(TempChk.POSCode, '') != ''
		-- ==================================================================================================================
		-- End: Item Movement Add extra line for refund
		-- ==================================================================================================================





		-- Add Mark Up or Down only if ISM Price is not equal to Inventory Retail Price
		-- =============================================================================================================================================================================
		-- Start: Item Price Differences / Department Discounts
		-- =============================================================================================================================================================================
		IF (@strAllowMarkUpDown = 'I' OR @strAllowMarkUpDown = 'D')
			BEGIN
				--INSERT INTO dbo.tblSTCheckoutMarkUpDowns
				--SELECT @intCheckoutId
				--	 , IC.intCategoryId
				--	 , UOM.intItemUOMId
				--	 , ISNULL(CAST(TempChk.SalesQuantity as int),0)

				--	 -- Sales Price
				--	 , (CASE 
				--			WHEN @strAllowMarkUpDown = 'I'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice)
				--						WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice)
				--					END
				--			WHEN @strAllowMarkUpDown = 'D'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts)
				--						WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts)
				--					END
				--		END) AS dblRetailUnit

				--	 -- Total Amount
				--	 , (CASE 
				--			WHEN @strAllowMarkUpDown = 'I'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice * TempChk.SalesQuantity)
				--						WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice * TempChk.SalesQuantity)
				--					END
				--			WHEN @strAllowMarkUpDown = 'D'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts * TempChk.SalesQuantity)
				--						WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts * TempChk.SalesQuantity)
				--					END
				--		END) AS dblAmount

				--	 , (CASE 
				--			WHEN @strAllowMarkUpDown = 'I'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
				--							THEN CAST((TempChk.dblAveragePrice - ISNULL(P.dblSalePrice, 0)) AS DECIMAL(18,6))
				--						WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
				--							THEN CAST((ISNULL(P.dblSalePrice, 0) - TempChk.dblAveragePrice) AS DECIMAL(18,6))
				--					END
				--			WHEN @strAllowMarkUpDown = 'D'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
				--							THEN CAST((TempChk.dblAveragePriceWthDiscounts - ISNULL(P.dblSalePrice, 0)) AS DECIMAL(18,6))
				--						WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0)
				--							THEN CAST((ISNULL(P.dblSalePrice, 0) - TempChk.dblAveragePriceWthDiscounts) AS DECIMAL(18,6))
				--					END
				--		END) AS dblShrink
				--	 , (CASE 
				--			WHEN @strAllowMarkUpDown = 'I'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) THEN 'Mark Up'
				--						WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) THEN 'Mark Down' 
				--					END
				--			WHEN @strAllowMarkUpDown = 'D'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) THEN 'Mark Up'
				--						WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) THEN 'Mark Down' 
				--					END
				--		END) AS strUpDownNotes
				--	 , 1
				INSERT INTO dbo.tblSTCheckoutMarkUpDowns
				(
					[intCheckoutId],
				    [intItemMovementId],								--> This will be used to modify MarkU/D when ItemMovement value is changed
					[intCategoryId],
					[intItemUOMId],
					[dblQty],
					[dblRetailUnit],
					[dblAmount],
					[dblShrink],
					[strUpDownNotes],
					[intConcurrencyId]
				)
				SELECT 
					[intCheckoutId]			= @intCheckoutId,
				    [intItemMovementId]		= im.intItemMovementId,		--> This will be used to modify MarkU/D when ItemMovement value is changed
					[intCategoryId]			= IC.intCategoryId,
					[intItemUOMId]			= UOM.intItemUOMId,
					[dblQty]				= ISNULL(CAST(TempChk.SalesQuantity AS INT),0),
					[dblRetailUnit]			= (CASE 
												WHEN @strAllowMarkUpDown = 'I'
													THEN CASE
															WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePrice)
															WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePrice)
														END
												WHEN @strAllowMarkUpDown = 'D'
													THEN CASE
															WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePriceWthDiscounts)
															WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePriceWthDiscounts)
														END
											END),
					[dblAmount]				= (CASE 
												WHEN @strAllowMarkUpDown = 'I'
													THEN CASE
															WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePrice * TempChk.SalesQuantity)
															WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePrice * TempChk.SalesQuantity)
														END
												WHEN @strAllowMarkUpDown = 'D'
													THEN CASE
															WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePriceWthDiscounts * TempChk.SalesQuantity)
															WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
																THEN (TempChk.dblAveragePriceWthDiscounts * TempChk.SalesQuantity)
														END
											END),
					[dblShrink]				= (CASE 
												WHEN @strAllowMarkUpDown = 'I'
													THEN CASE
															WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
																THEN CAST((TempChk.dblAveragePrice - ISNULL(P.dblSalePrice, 0)) AS DECIMAL(18,6))
															WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
																THEN CAST((ISNULL(P.dblSalePrice, 0) - TempChk.dblAveragePrice) AS DECIMAL(18,6))
														END
												WHEN @strAllowMarkUpDown = 'D'
													THEN CASE
															WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
																THEN CAST((TempChk.dblAveragePriceWthDiscounts - ISNULL(P.dblSalePrice, 0)) AS DECIMAL(18,6))
															WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0)
																THEN CAST((ISNULL(P.dblSalePrice, 0) - TempChk.dblAveragePriceWthDiscounts) AS DECIMAL(18,6))
														END
											END),
					[strUpDownNotes]		= (CASE 
												WHEN @strAllowMarkUpDown = 'I'
													THEN CASE
															WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) THEN 'Mark Up'
															WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) THEN 'Mark Down' 
														END
												WHEN @strAllowMarkUpDown = 'D'
													THEN CASE
															WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) THEN 'Mark Up'
															WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) THEN 'Mark Down' 
														END
											END),
					[intConcurrencyId]		= 1
				FROM @tblTempForCalculation TempChk
				INNER JOIN tblSTCheckoutItemMovements im
					ON TempChk.intCalculationId = im.intCalculationId
					AND TempChk.intCheckoutId = im.intCheckoutId
				INNER JOIN tblICItemUOM UOM
					ON TempChk.intPOSCode = UOM.intUpcCode
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
					AND im.intCheckoutId = @intCheckoutId
					AND ISNULL(TempChk.POSCode, '') != ''
					AND I.strLotTracking = 'No'
					AND TempChk.SalesQuantity > 0
					AND 0 < CASE
								WHEN @strAllowMarkUpDown = 'I'
									THEN TempChk.dblAveragePrice
								WHEN @strAllowMarkUpDown = 'D'
									THEN TempChk.dblAveragePriceWthDiscounts
							END
					AND P.dblSalePrice != CASE
												WHEN @strAllowMarkUpDown = 'I'
													THEN TempChk.dblAveragePrice
												WHEN @strAllowMarkUpDown = 'D'
													THEN TempChk.dblAveragePriceWthDiscounts
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
	COMMIT TRANSACTION
	GOTO ExitPost
	

ExitWithRollback:
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END
	
ExitPost: