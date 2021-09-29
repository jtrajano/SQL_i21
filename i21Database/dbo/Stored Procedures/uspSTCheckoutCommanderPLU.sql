CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderPLU]
	@intCheckoutId							INT,
	@UDT_TranPLU							StagingCommanderPlu		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
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



		--DECLARE #tblTemp TABLE
		--(
		--	intRowCount											INT,
		--	intperiodsysid										INT,
		--	strperiodperiodType									NVARCHAR(50),
		--	strperiodname										NVARCHAR(50),
		--	intperiodperiodSeqNum								INT,
		--	dtmperiodperiodBeginDate							DATETIME,
		--	dtmperiodperiodEndDate								DATETIME,
		--	strpluPdperiod										NVARCHAR(50),
		--	intpluPdsite										INT,
		--	dblpluInfosalePrice									DECIMAL(18, 6),
		--	dblpluInfooriginalPrice								DECIMAL(18, 6),
		--	strpluInforeasonCode								NVARCHAR(150),
		--	dblpluInfopercentOfSales							DECIMAL(18, 6),
		--	strpluBaseupc										NVARCHAR(20),
		--	intpluBasemodifier									INT,
		--	strpluBasename										NVARCHAR(150),
		--	intnetSalescount									INT,
		--	dblnetSalesamount									NVARCHAR(150),
		--	dblnetSalesitemCount								DECIMAL(18, 6),
		--	dblDiscount											DECIMAL(18, 6),
		--	intRegisterUpcCode									BIGINT
		--)

		
		BEGIN TRY
			--INSERT INTO #tblTemp
			--(
			--	intRowCount,
			--	intperiodsysid,
			--	strperiodperiodType,
			--	strperiodname,
			--	intperiodperiodSeqNum,
			--	dtmperiodperiodBeginDate,
			--	dtmperiodperiodEndDate,
			--	strpluPdperiod,
			--	intpluPdsite,
			--	dblpluInfosalePrice,
			--	dblpluInfooriginalPrice,
			--	strpluInforeasonCode,
			--	dblpluInfopercentOfSales,
			--	strpluBaseupc,
			--	intpluBasemodifier,
			--	strpluBasename,
			--	intnetSalescount,
			--	dblnetSalesamount,
			--	dblnetSalesitemCount,
			--	dblDiscount,
			--	intRegisterUpcCode
			--)
			--USE TEMP TABLE FOR PERFORMANCE--
			print 1
			SELECT 
				intRowCount					= CAST(temp.intRowCount AS INT),
				intperiodsysid				= CAST(temp.strPeriodSysId AS INT),
				strperiodperiodType			= CAST(ISNULL(temp.strPeriodPeriodType, '') AS NVARCHAR(MAX)),
				strperiodname				= CAST(ISNULL(temp.strPeriodName, '')AS NVARCHAR(MAX)),
				intperiodperiodSeqNum		= CAST(temp.intPeriodPeriodSeqNum AS INT),
				dtmperiodperiodBeginDate	= CAST(REPLACE(LEFT (temp.strPeriodPeriodBeginDate, LEN (temp.strPeriodPeriodBeginDate)-6), 'T', ' ') AS DATETIME),
				dtmperiodperiodEndDate		= CAST(REPLACE(LEFT (temp.strPeriodPeriodEndDate, LEN (temp.strPeriodPeriodEndDate)-6), 'T', ' ') AS DATETIME),
				strpluPdperiod				= CAST(ISNULL(temp.strPluPdPeriod	, '')AS NVARCHAR(MAX)),
				intpluPdsite				= CAST(temp.intPluPdSite AS INT),
				dblpluInfosalePrice			= CAST(temp.dblPluInfoSalePrice AS DECIMAL(18, 6)),
				dblpluInfooriginalPrice		= CAST(temp.dblPluInfoOriginalPrice AS DECIMAL(18, 6)),
				strpluInforeasonCode		= CAST(ISNULL(temp.strPluInfoReasonCode, '')AS NVARCHAR(MAX)),
				dblpluInfopercentOfSales	= CAST(temp.dblPluInfoPercentOfSales AS DECIMAL(18, 6)),
				strpluBaseupc				= CAST(ISNULL(temp.intPluBaseUPC, '')AS NVARCHAR(MAX)),
				intpluBasemodifier			= CAST(temp.intPluBaseModifier AS INT),
				strpluBasename				= CAST(ISNULL(temp.strPluBaseName, '')AS NVARCHAR(MAX)),
				intnetSalescount			= CAST(temp.intNetSalesCount AS INT),
				--dblnetSalesamount			= CAST(temp.dblNetSalesAmount AS DECIMAL(18, 6)),
				dblnetSalesamount			= CASE
												WHEN (ISNULL(temp.strPluInfoReasonCode, '')  =  'DISCOUNT_SALE')
													THEN (CAST(temp.dblPluInfoOriginalPrice AS DECIMAL(18, 6))  *  CAST(temp.dblNetSalesItemCount AS DECIMAL(18, 6)))
												ELSE CAST(temp.dblNetSalesAmount AS DECIMAL(18, 6))
											END,
				dblnetSalesitemCount		= CAST(temp.dblNetSalesItemCount AS DECIMAL(18, 6)),
				dblDiscount					= CASE
												WHEN ISNULL(temp.strPluInfoReasonCode, '')  =  'DISCOUNT_SALE'
													THEN -(CAST(temp.dblPluInfoOriginalPrice AS DECIMAL(18, 6))   -   CAST(temp.dblPluInfoSalePrice AS DECIMAL(18, 6))) -- Convert to Negative since COMMANDER has a discount of positive
												ELSE 0
											END,
				intRegisterUpcCode			= CONVERT(NUMERIC(32, 0),CAST(temp.intPluBaseUPC AS FLOAT)) -- Remove Leading Zeros on COMMANDER xml,
			INTO #tblTemp
			FROM @UDT_TranPLU temp


			-- Remove last digit(check digit)
			-- Assumption is COMMANDER xml has check digit
			UPDATE #tblTemp
			SET intRegisterUpcCode = CASE
										WHEN (strpluBaseupc IS NOT NULL AND strpluBaseupc != '' AND LEN(strpluBaseupc) = 14 AND SUBSTRING(strpluBaseupc, 1, 1) = '0')
											THEN LEFT (intRegisterUpcCode, LEN (intRegisterUpcCode)-1) -- Remove Check digit on last character
										ELSE intRegisterUpcCode
									END
		END TRY
		BEGIN CATCH
			SET @intCountRows = 0
			SET @strMessage = 'COMMANDER PLU - Insert to temporary table: ' + ERROR_MESSAGE()

			GOTO ExitWithRollback
		END CATCH



		-- ==================================================================================================================  
		-- Start Validate if PLU xml file matches the Mapping on i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM #tblTemp)
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
					SET @strMessage = 'Commander PLU XML file did not match the layout mapping'
					SET @ysnSuccess = 0

					GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if PLU xml file matches the Mapping on i21   
		-- ==================================================================================================================  





		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <upc> tag of (RegisterXML) and (Inventory->Item->strUpcCode, strLongUPCCode)
		-- ------------------------------------------------------------------------------------------------------------------ 
		print 1
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
			, strErrorMessage		= 'No Matching UPC/Item in Inventory'
			, strRegisterTag		= 'upc'
			, strRegisterTagValue	= LEFT(Chk.strpluBaseupc, LEN (Chk.strpluBaseupc)-1) -- Remove Check digit on last character
			, intCheckoutId			= @intCheckoutId
			, intConcurrencyId		= 1
		FROM #tblTemp Chk
		WHERE Chk.intRegisterUpcCode NOT IN
		(
			SELECT DISTINCT
				UOM.intUpcCode AS intRegisterUpcCode
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
			AND ISNULL(Chk.strpluBaseupc, '') != ''

		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================



		-- ==================================================================================================================
		-- Start: Insert to temporary table
		-- ==================================================================================================================
		--DECLARE #tblTempForCalculation TABLE
		--(
		--	intCalculationId			INT	NOT NULL IDENTITY,
		--	intCheckoutId				INT,
		--	SalesQuantity				INT,
		--	DiscountAmount				DECIMAL(18, 6),
		--	PromotionAmount				DECIMAL(18, 6),
		--	RefundAmount				DECIMAL(18, 6),
		--	RefundCount					INT,
		--	SalesAmount					DECIMAL(18, 6),
		--	ActualSalesPrice			DECIMAL(18, 6),
		--	POSCode						NVARCHAR(15),
		--	intPOSCode					BIGINT,
		--	dblAveragePrice				DECIMAL(18, 6),
		--	dblAveragePriceWthDiscounts	DECIMAL(18, 6)
		--)

		print 3
		--INSERT INTO #tblTempForCalculation
		--(
		--	intCheckoutId,
		--	SalesQuantity,
		--	DiscountAmount,
		--	PromotionAmount,
		--	SalesAmount,
		--	RefundAmount,
		--	RefundCount,
		--	ActualSalesPrice,
		--	POSCode,
		--	intPOSCode,
		--	dblAveragePrice,
		--	dblAveragePriceWthDiscounts
		--)
		SELECT 
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as intCalculationId,
			intCheckoutId					= @intCheckoutId,
			SalesQuantity					= CAST(ISNULL(CAST(dblnetSalesitemCount AS DECIMAL(18, 6)) ,0) AS INT),
			--DiscountAmount					= 0, -- Commander has No Discount in PLU xml //CAST(DiscountAmount AS DECIMAL(18,6)),
			DiscountAmount					= dblDiscount,
			PromotionAmount					= 0, -- Commander has Promotion in PLU xml with example of <reasonCode>MATCH_SALE</reasonCode>
			SalesAmount						= CAST(dblnetSalesamount AS DECIMAL(18,6)),
			RefundAmount					= 0, -- Commander has No Refund in PLU xml //CAST(ISNULL(RefundAmount, 0) AS DECIMAL(18,6)),
			RefundCount						= 0, -- Commander has No Refund in PLU xml //CAST(ISNULL(RefundCount, 0) AS INT),
			ActualSalesPrice				= CAST(dblpluInfosalePrice AS DECIMAL(18,6)),
			POSCode							= strpluBaseupc,
			intPOSCode						= intRegisterUpcCode,
			dblAveragePrice					= CASE 
												WHEN CAST(CAST(dblnetSalesitemCount AS DECIMAL(18, 6)) AS INT) = 0
													THEN 0
												ELSE ISNULL( NULLIF( CAST(dblnetSalesamount AS DECIMAL(18, 6)) ,0) , 0) /   CAST(CAST(dblnetSalesitemCount AS DECIMAL(18, 6)) AS INT)
											END,
			dblAveragePriceWthDiscounts    = CASE 
												WHEN CAST(CAST(dblnetSalesitemCount AS DECIMAL(18, 6)) AS INT) = 0
													THEN 0
												ELSE ISNULL( NULLIF( CAST(dblnetSalesamount AS DECIMAL(18, 6)) ,0) , 0) /   CAST(CAST(dblnetSalesitemCount AS DECIMAL(18, 6)) AS INT)
											END
		INTO #tblTempForCalculation
		FROM #tblTemp
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
			FROM #tblTempForCalculation TempChk
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
			FROM #tblTempForCalculation TempChk
			INNER JOIN tblICItemUOM UOM
				ON TempChk.intPOSCode = UOM.intUpcCode
			INNER JOIN dbo.tblICItem I 
				ON I.intItemId = UOM.intItemId
			INNER JOIN dbo.tblICItemLocation IL 
				ON IL.intItemId = I.intItemId
			INNER JOIN dbo.tblSMCompanyLocation CL 
				ON CL.intCompanyLocationId = IL.intLocationId
			INNER JOIN dbo.tblSTStore S 
				ON S.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN dbo.tblICItemPricing P 
				ON IL.intItemLocationId = P.intItemLocationId 
				AND I.intItemId = P.intItemId
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
			  , intCalculationId	=TempChk.intCalculationId
			FROM #tblTempForCalculation TempChk
			INNER JOIN tblICItemUOM UOM
				ON TempChk.intPOSCode = UOM.intUpcCode
			INNER JOIN dbo.tblICItem I 
				ON I.intItemId = UOM.intItemId
			INNER JOIN dbo.tblICItemLocation IL 
				ON IL.intItemId = I.intItemId	
			INNER JOIN dbo.tblSMCompanyLocation CL 
				ON CL.intCompanyLocationId = IL.intLocationId
			INNER JOIN dbo.tblSTStore S 
				ON S.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN dbo.tblICItemPricing P 
				ON IL.intItemLocationId = P.intItemLocationId 
				AND I.intItemId = P.intItemId
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
				--							THEN (TempChk.dblAveragePrice)							-- Chk.dblAveragePrice - P.dblSalePrice
				--						WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice)							-- P.dblSalePrice - Chk.dblAveragePrice
				--					END
				--			WHEN @strAllowMarkUpDown = 'D'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts)				-- Chk.dblAveragePriceWthDiscounts - P.dblSalePrice
				--						WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts)				-- P.dblSalePrice - Chk.dblAveragePriceWthDiscounts
				--					END
				--		END) AS dblRetailUnit

				--	 -- Total Amount
				--	 , (CASE 
				--			WHEN @strAllowMarkUpDown = 'I'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePrice > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice * TempChk.SalesQuantity)			-- (Chk.dblAveragePrice - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
				--						WHEN TempChk.dblAveragePrice < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePrice * TempChk.SalesQuantity)			-- (P.dblSalePrice - Chk.dblAveragePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
				--					END
				--			WHEN @strAllowMarkUpDown = 'D'
				--				THEN CASE
				--						WHEN TempChk.dblAveragePriceWthDiscounts > ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts * TempChk.SalesQuantity)	-- (Chk.dblAveragePriceWthDiscounts - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
				--						WHEN TempChk.dblAveragePriceWthDiscounts < ISNULL(P.dblSalePrice, 0) 
				--							THEN (TempChk.dblAveragePriceWthDiscounts * TempChk.SalesQuantity)  -- (P.dblSalePrice - Chk.dblAveragePriceWthDiscounts) * ISNULL(CAST(Chk.SalesQuantity as int),0)
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
				FROM #tblTempForCalculation TempChk
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

				--FROM #tblTempForCalculation TmpChk
				--INNER JOIN
				--(
				--	SELECT intItemUOMId
				--		, intItemId
				--		, strLongUPCCode
				--		, CASE 
				--			WHEN strLongUPCCode NOT LIKE '%[^0-9]%' 
				--				THEN CONVERT(NUMERIC(32, 0),CAST(strLongUPCCode AS FLOAT))
				--			ELSE NULL
				--		END AS intLongUpcCode 
				--	FROM dbo.tblICItemUOM
				--) AS UOM
				--	ON TmpChk.UPC COLLATE Latin1_General_CI_AS = ISNULL(UOM.strLongUPCCode, '')
				--	OR CONVERT(NUMERIC(32, 0),CAST(TmpChk.UPC AS FLOAT)) = UOM.intLongUpcCode
				--INNER JOIN dbo.tblICItem I 
				--	ON I.intItemId = UOM.intItemId
				--INNER JOIN dbo.tblICItemLocation IL 
				--	ON IL.intItemId = I.intItemId
				--LEFT JOIN dbo.tblICItemPricing P 
				--	ON IL.intItemLocationId = P.intItemLocationId 
				--	AND I.intItemId = P.intItemId
				--INNER JOIN dbo.tblSMCompanyLocation CL 
				--	ON CL.intCompanyLocationId = IL.intLocationId
				--INNER JOIN dbo.tblICCategory IC 
				--	ON IC.intCategoryId = I.intCategoryId
				--INNER JOIN dbo.tblSTStore S 
				--	ON S.intCompanyLocationId = CL.intCompanyLocationId
				--WHERE S.intStoreId = @intStoreId
				--	AND I.strLotTracking = 'No'
				--	AND TmpChk.SalesQuantity > 0
				--	AND 0 < CASE
				--				WHEN @strAllowMarkUpDown = 'I'
				--					THEN TmpChk.dblAveragePrice
				--				WHEN @strAllowMarkUpDown = 'D'
				--					THEN TmpChk.dblAveragePriceWthDiscounts
				--			END
				--	AND P.dblSalePrice != CASE
				--								WHEN @strAllowMarkUpDown = 'I'
				--									THEN TmpChk.dblAveragePrice
				--								WHEN @strAllowMarkUpDown = 'D'
				--									THEN TmpChk.dblAveragePriceWthDiscounts
				--							END


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

