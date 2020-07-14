CREATE PROCEDURE [dbo].[uspSTRebatePreviewSubmission]
	@strStoreIdList NVARCHAR(MAX),
	@dtmBeginningDate DATETIME,
	@dtmEndingDate DATETIME,
	@intCsvFormat INT,
	@intVendorId INT,
	@ysnResubmit BIT,
	@strStatusMsg NVARCHAR(1000) OUTPUT,
	@intCountRows int OUTPUT
AS
BEGIN
	BEGIN TRY
		
		-- @intCsvFormat
		-- 0 = PM Morris
        -- 1 = RJ Reynolds

		DECLARE @tempTable TABLE (
			  dtmDate DATETIME
			, dtmTime NVARCHAR(20)
			, strStoreName NVARCHAR(150)
			, intTermMsgSN BIGINT
			, dblQty DECIMAL(18, 2)
			, dblPrice DECIMAL(18, 2)
			, strDepartment NVARCHAR(100)
			, strUpc NVARCHAR(100)
			, strDescription NVARCHAR(250)
		)

		---- // Create temp table PMM
		DECLARE @tblTempPMM TABLE (
				[intManagementOrRetailNumber] int NULL,
				[strWeekEndingDate] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[strTransactionDate] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[strTransactionTime] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
				[strTransactionIdCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strStoreNumber] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
				[strStoreName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strStoreAddress] nvarchar(60) COLLATE Latin1_General_CI_AS NULL,
				[strStoreCity] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strStoreState] nvarchar(2) COLLATE Latin1_General_CI_AS NULL,
				[intStoreZipCode] int NULL,
				[strCategory] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[strManufacturerName] nvarchar(250) COLLATE Latin1_General_CI_AS NULL,
				[strSKUCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strUpcCode] nvarchar(14) COLLATE Latin1_General_CI_AS NULL,
				[strSkuUpcDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strUnitOfMeasure] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[intQuantitySold] INT NULL, --numeric(10, 2) NULL,
				[intConsumerUnits] int NULL,
				[strMultiPackIndicator] nvarchar(1) COLLATE Latin1_General_CI_AS NULL,
				[intMultiPackRequiredQuantity] int NULL,
				[dblMultiPackDiscountAmount] numeric(10, 2) NULL,
				[strRetailerFundedDIscountName] nvarchar(150) COLLATE Latin1_General_CI_AS NULL,
				[dblRetailerFundedDiscountAmount] numeric(10, 2) NULL,
				[strMFGDealNameONE] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[dblMFGDealDiscountAmountONE] numeric(10, 2) NULL,
				[strMFGDealNameTWO] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[dblMFGDealDiscountAmountTWO] numeric(10, 2) NULL,
				[strMFGDealNameTHREE] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[dblMFGDealDiscountAmountTHREE] numeric(10, 2) NULL,
				[dblFinalSalesPrice] numeric(10, 2) NULL,
				
				--Optional Fields
				intStoreTelephone int NULL,
				strStoreContactName nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				strStoreContactEmail nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				strProductGroupingCode nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
				strProductGroupingName nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				strLoyaltyIDRewardsNumber nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[strDepartment] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
		)


		---- // Create temp table RJR
		DECLARE @tblTempRJR TABLE (
				[strOutletName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[intOutletNumber] int NULL,
				[strOutletAddressOne] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				[strOutletAddressTwo] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				[strOutletCity] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strOutletState] nvarchar(2) COLLATE Latin1_General_CI_AS NULL,
				[strOutletZipCode] nvarchar(5) COLLATE Latin1_General_CI_AS NULL,
				[strTransactionDateTime] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strMarketBasketTransactionId] nvarchar(300) COLLATE Latin1_General_CI_AS NULL,
				[strScanTransactionId] nvarchar(300) COLLATE Latin1_General_CI_AS NULL,
				[strRegisterId] nvarchar(300) COLLATE Latin1_General_CI_AS NULL,
				[intQuantity] int NULL,
				[dblPrice] decimal(18, 6) NULL,
				[strUpcCode] nvarchar(14) COLLATE Latin1_General_CI_AS NULL,
				[strUpcDescription] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				[strUnitOfMeasure] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
				[strPromotionFlag] nvarchar(1) COLLATE Latin1_General_CI_AS NULL,
				[strOutletMultipackFlag] nvarchar(1) COLLATE Latin1_General_CI_AS NULL,
				[intOutletMultipackQuantity] int NULL,
				[dblOutletMultipackDiscountAmount] decimal(18, 6) NULL,
				[strAccountPromotionName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[dblAccountDiscountAmount] decimal(18, 6) NULL,
				[dblManufacturerDiscountAmount] decimal(18, 6) NULL,
				[strCouponPid] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
				[dblCouponAmount] decimal(18, 6) NULL,
				[strManufacturerMultipackFlag] nvarchar(1) COLLATE Latin1_General_CI_AS NULL,
				[intManufacturerMultipackQuantity] int NULL,
				[dblManufacturerMultipackDiscountAmount] decimal(18, 6) NULL,
				[strManufacturerPromotionDescription] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				[strManufacturerBuydownDescription] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				[dblManufacturerBuydownAmount] decimal(18, 6) NULL,
				[strManufacturerMultiPackDescription] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
				[strAccountLoyaltyIDNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strCouponDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
				[strDepartment] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
		)



		DECLARE @Delimiter AS NVARCHAR(5)

		-- 0 = PM Morris
		IF(@intCsvFormat = 0)
			BEGIN
				
				DECLARE @intVendorAccountNumber AS INT = (
															SELECT intChainAccountNumber FROM tblAPVendor
															WHERE intEntityId = @intVendorId
														 )
				BEGIN TRY
					INSERT INTO @tblTempPMM
					SELECT 
								intRCN
								,dtmWeekEndingDate
								,dtmTransactionDate
								,strTransactionTime
								,strTransactionIdCode
								,strStoreNumber
								,strStoreName
								,strStoreAddress
								,strStoreCity
								,strStoreState
								,intStoreZipCode
								,strCategory
								,strManufacturerName
								,strSKUCode
								,strUpcCode
								,strSkuUpcDescription
								,strUnitOfMeasure
								,intQuantitySold
								,intConsumerUnits
								,strMultiPackIndicator
								,intMultiPackRequiredQuantity
								,dblMultiPackDiscountAmount
								,strRetailerFundedDiscountName
								,dblRetailerFundedDiscountAmount
								,strMFGDealNameONE
								,dblMFGDealDiscountAmountONE
								,strMFGDealNameTWO
								,dblMFGDealDiscountAmountTWO
								,strMFGDealNameTHREE
								,dblMFGDealDiscountAmountTHREE
								,dblFinalSalesPrice
								,intStoreTelephone
								,strStoreContactName
								,strStoreContactEmail
								,strProductGroupingCode
								,strProductGroupingName
								,strLoyaltyIDRewardsNumber
								,strDepartment
							FROM (
							SELECT DISTINCT intScanTransactionId
									, @intVendorAccountNumber intRCN
									, replace(convert(NVARCHAR, @dtmEndingDate, 111), '/', '') as dtmWeekEndingDate
									, replace(convert(NVARCHAR, dtmDate, 111), '/', '') as dtmTransactionDate 
									, convert(NVARCHAR, dtmDate, 108) as strTransactionTime
									, intTermMsgSN as strTransactionIdCode
									, ST.intStoreNo as strStoreNumber
									, ST.strDescription as strStoreName
									, REPLACE(REPLACE(REPLACE(REPLACE(ST.strAddress, CHAR(10), ''), CHAR(13), ''), '|', ''), ',', '') as strStoreAddress
									, ST.strCity as strStoreCity
									, UPPER(LEFT(ST.strState, 2)) as strStoreState
									, ST.strZipCode as intStoreZipCode
									, strTrlDept as strCategory
									, EM.strName as strManufacturerName
									, strTrlUPC as strSKUCode --14
									, strTrlUPC as strUpcCode
									, strTrlDesc as strSkuUpcDescription
									, CASE	
										-- WHEN TR.strTrlDept = 'OTP'
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1) 
											THEN 'CANS'
										--WHEN TR.strTrlDept = 'CIGARETTES'
										--	THEN 'PACKS'
										ELSE 'PACKS'
									  END as strUnitOfMeasure
									, CASE 
										WHEN strTrpPaycode != 'Change' 
											THEN CAST(dblTrlQty as INT) 
										ELSE 0 
									  END as intQuantitySold
									, 1 as intConsumerUnits
									, CASE
										-- 2 Can Deal
										--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)
											AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2
												THEN 'Y'
										ELSE 'N'
									  END AS strMultiPackIndicator	
									, CASE
										-- 2 Can Deal
										--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)
											AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2
												THEN 2
										ELSE NULL
									  END as intMultiPackRequiredQuantity
									, CASE
										-- 2 Can Deal
										--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1) 
											AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2
												THEN (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty)
										ELSE NULL
									  END as dblMultiPackDiscountAmount
									, REPLACE(CRP.strProgramName, ',','') as strRetailerFundedDiscountName
									, CRP.dblManufacturerBuyDownAmount as dblRetailerFundedDiscountAmount
									, CASE 
										WHEN strTrpPaycode = 'COUPONS' 
											THEN 'Coupon' 
										ELSE '' 
									  END as strMFGDealNameONE
									, CASE 
										WHEN strTrpPaycode = 'COUPONS' 
											THEN TR.dblTrpAmt 
										ELSE NULL 
									  END as dblMFGDealDiscountAmountONE
									, '' as strMFGDealNameTWO
									, NULL as dblMFGDealDiscountAmountTWO
									, '' as strMFGDealNameTHREE
									, NULL as dblMFGDealDiscountAmountTHREE

									, ((TR.dblTrlLineTot) - (CASE 
																--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2
																WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1) 
																	AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
																	AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
																	AND TR.dblTrlQty >= 2
																		THEN TR.dblTrlMatchLineTrlPromoAmount
																WHEN TR.strTrpPaycode IN ('LOTTERY PO', 'COUPONS')
																	THEN TR.dblTrpAmt
																ELSE 0
															 END)) as dblFinalSalesPrice

									-- Optional Fields
									, NULL AS intStoreTelephone
									, '' AS strStoreContactName
									, '' strStoreContactEmail
									, '' strProductGroupingCode
									, '' strProductGroupingName
									, '' strLoyaltyIDRewardsNumber
									, [strDepartment] = CASE
															WHEN uom.intItemUOMId IS NOT NULL
																THEN category.strCategoryCode
															ELSE ''
														END
					FROM 
					(
						SELECT * FROM
							(   
								SELECT *, ROW_NUMBER() OVER (PARTITION BY intTermMsgSN, strTrlUPC, strTrlDesc, strTrlDept, dblTrlQty, dblTrpAmt, strTrpPaycode, intStoreId, intCheckoutId,intScanTransactionId ORDER BY strTrpPaycode DESC) AS rn
								FROM tblSTTranslogRebates
								WHERE CAST(dtmDate AS DATE) BETWEEN @dtmBeginningDate AND @dtmEndingDate
							) TRR 
							WHERE TRR.rn = 1
							AND TRR.ysnPMMSubmitted = CASE
														WHEN @ysnResubmit = CAST(0 AS BIT)
															THEN CAST(0 AS BIT)
														WHEN @ysnResubmit = CAST(1 AS BIT)
															THEN TRR.ysnPMMSubmitted
													END
					) TR
					JOIN tblSTStore ST 
						ON ST.intStoreId = TR.intStoreId
					JOIN tblEMEntity EM 
						ON EM.intEntityId = @intVendorId
					JOIN tblAPVendor APV 
						ON APV.intEntityId = EM.intEntityId
					LEFT JOIN tblICItemUOM uom
						ON TR.strTrlUPCwithoutCheckDigit = uom.strLongUPCCode
					LEFT JOIN tblICItem item
						ON uom.intItemId = item.intItemId
					LEFT JOIN tblICCategory category
						ON item.intCategoryId = category.intCategoryId
					LEFT JOIN vyuSTCigaretteRebatePrograms CRP 
						ON CONVERT(NUMERIC(32, 0),CAST(TR.strTrlUPCwithoutCheckDigit AS FLOAT)) = CRP.intUpcCode ---->   Always compare UPC without check digit since Inventory UPC has no check digit, use IC intUpcCode
							AND (CAST(TR.dtmDate AS DATE) BETWEEN CRP.dtmStartDate AND CRP.dtmEndDate)
					WHERE TR.intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) 
						AND (TR.strTrlUPC != '' AND TR.strTrlUPC IS NOT NULL)
						AND TR.strTrpPaycode != 'Change' --ST-680
						AND TR.intTrlDeptNumber IN (SELECT DISTINCT intRegisterDepartmentId FROM fnSTRebateDepartment(CAST(ST.intStoreId AS NVARCHAR(10))))
				) as innerQuery

				END TRY		
				BEGIN CATCH
					SET @intCountRows = 0
					SET @strStatusMsg = ERROR_MESSAGE()
				END CATCH


				BEGIN TRY

					INSERT INTO @tempTable
					(
						dtmDate
						, dtmTime
						, strStoreName
						, intTermMsgSN
						, dblQty
						, dblPrice
						, strDepartment
						, strUpc
						, strDescription
					)
					SELECT
						dtmDate				= CAST(PM.strTransactionDate AS DATE)
						, dtmTime			= CONVERT(VARCHAR, CAST(PM.strTransactionTime AS TIME), 108)
						, strStoreName		= PM.strStoreName
						, intTermMsgSN		= CAST(PM.strTransactionIdCode AS BIGINT)
						, dblQty			= PM.intQuantitySold
						, dblPrice			= PM.dblFinalSalesPrice
						, strDepartment		= PM.strDepartment
						, strUpc			= PM.strUpcCode
						, strDescription	= PM.strSkuUpcDescription
					FROM @tblTempPMM PM

				END TRY		
				BEGIN CATCH
					SET @intCountRows = 0
					SET @strStatusMsg = ERROR_MESSAGE()
				END CATCH
					
			END

		-- 1 = RJ Reynolds
		ELSE IF(@intCsvFormat = 1)
			BEGIN
				SET @Delimiter = ','

				BEGIN TRY
					
					INSERT INTO @tblTempRJR
					SELECT 
									strOutletName
									,intOutletNumber
									,strOutletAddressOne
									,strOutletAddressTwo
									,strOutletCity
									,strOutletState
									,strOutletZipCode
									,strTransactionDateTime
									,strMarketBasketTransactionId
									,strScanTransactionId
									,strRegisterId
									,intQuantity
									,dblPrice
									,strUpcCode
									,strUpcDescription
									,strUnitOfMeasure
									,strPromotionFlag
									,strOutletMultipackFlag
									,intOutletMultipackQuantity
									,dblOutletMultipackDiscountAmount
									,strAccountPromotionName
									,dblAccountDiscountAmount
									,dblManufacturerDiscountAmount
									,strCouponPid
									,dblCouponAmount
									,strManufacturerMultipackFlag
									,intManufacturerMultipackQuantity
									,dblManufacturerMultipackDiscountAmount
									,strManufacturerPromotionDescription
									,strManufacturerBuydownDescription
									,dblManufacturerBuydownAmount
									,strManufacturerMultiPackDescription
									,strAccountLoyaltyIDNumber
									,strCouponDescription
									,strDepartment
								FROM ( 
								SELECT DISTINCT intScanTransactionId,  (CASE WHEN ST.strDescription IS NULL THEN '' ELSE REPLACE(ST.strDescription, @Delimiter, '') END) as strOutletName
									, ST.intStoreNo as intOutletNumber
									, REPLACE(REPLACE(REPLACE(ST.strAddress, CHAR(10), ''), CHAR(13), ''), @Delimiter, '') as strOutletAddressOne
									, '' as strOutletAddressTwo
									, CASE WHEN ST.strCity IS NULL THEN '' ELSE REPLACE(ST.strCity, @Delimiter, '') END as strOutletCity
									, UPPER(LEFT(ST.strState, 2)) as strOutletState
									,  CASE WHEN ST.strZipCode IS NULL THEN '' ELSE ST.strZipCode END as strOutletZipCode
									, CONVERT(NVARCHAR, dtmDate, 120) as strTransactionDateTime
									, CAST(intTermMsgSN AS NVARCHAR(50)) as strMarketBasketTransactionId
									, CAST(intScanTransactionId AS NVARCHAR(20)) as strScanTransactionId
									, CAST(intTrTickNumPosNum AS NVARCHAR(50)) as strRegisterId
									, dblTrlQty as intQuantity

									-- PRICE
									, CASE 
										--WHEN TR.strTrlDept = 'OTP' AND TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2 -- 2 Can Deal
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)  
											AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2 -- 2 Can Deal
												THEN (TR.dblTrlUnitPrice - (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty))
										WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
											THEN (dblTrlUnitPrice - (dblTrlMatchLineTrlPromoAmount / dblTrlQty))
										ELSE dblTrlUnitPrice 
									  END as dblPrice

									, strTrlUPC as strUpcCode
									, REPLACE(strTrlDesc, ',', ' ') as strUpcDescription
									, CASE	
										--WHEN TR.strTrlDept = 'OTP'
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)
											THEN 'CANS'
										--WHEN TR.strTrlDept = 'CIGARETTES'
										--	THEN 'PACKS'
										ELSE 'PACKS'
									  END as strUnitOfMeasure

									, CASE 
										WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') THEN 'Y'
										--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)
											AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2 
												THEN 'Y' -- 2 Can Deal
										WHEN strTrpCardInfoTrpcHostID IN ('VAPS') AND strTrlMatchLineTrlMatchName IS NOT NULL AND dblTrlMatchLineTrlPromoAmount IS NOT NULL 
											THEN 'Y' 
										WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
											THEN 'Y'
										ELSE 'N' 	
									  END as strPromotionFlag

									  -- Multi-Pack Discount
									, CASE 
										WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') THEN 'N'
										--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1) 
											AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2 
												THEN 'Y' -- 2 Can Deal
										WHEN strTrpCardInfoTrpcHostID IN ('VAPS') 
											THEN 'N' 
										WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
											THEN 'Y'
										ELSE 'N' 
									  END as strOutletMultipackFlag
									, CASE 
										WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') THEN 0
										--WHEN TR.strTrlDept = 'OTP' AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2 -- 2 Can Deal
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1) 
											AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2 -- 2 Can Deal
												THEN 2
										WHEN strTrpCardInfoTrpcHostID IN ('VAPS') 
											THEN 0 	
										WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
											THEN 2 --dblTrlMatchLineTrlMatchQuantity 
										ELSE 0 
									  END as intOutletMultipackQuantity
									, CASE 
										WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') THEN 0
										--WHEN TR.strTrlDept = 'OTP' AND TR.strTrlMatchLineTrlMatchName IS NOT NULL AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' AND TR.dblTrlQty >= 2 -- 2 Can Deal
										WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)
											AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
											AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
											AND TR.dblTrlQty >= 2 -- 2 Can Deal
												THEN TR.dblTrlMatchLineTrlPromoAmount
										WHEN strTrpCardInfoTrpcHostID IN ('VAPS') 
											THEN 0 
										WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
											THEN TR.dblTrlMatchLineTrlPromoAmount
										ELSE 0 
									  END as dblOutletMultipackDiscountAmount
									, '' as strAccountPromotionName --21
									, 0 as dblAccountDiscountAmount --22

									, CASE 
										WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') 
											THEN CRP.dblManufacturerDiscountAmount 
										WHEN strTrpCardInfoTrpcHostID IN ('VAPS') AND strTrlMatchLineTrlMatchName IS NOT NULL AND dblTrlMatchLineTrlPromoAmount IS NOT NULL 
											THEN dblTrlMatchLineTrlPromoAmount
										ELSE 0 
									  END as dblManufacturerDiscountAmount

									-- COUPONS
									, CASE WHEN strTrpPaycode = 'COUPONS' AND strTrlMatchLineTrlPromotionIDPromoType IS NULL AND strTrlUPCEntryType = 'scanned'
										THEN strTrlUPC ELSE '' END as strCouponPid --24 COUPON
									, CASE WHEN strTrpPaycode = 'COUPONS' AND strTrlMatchLineTrlPromotionIDPromoType IS NULL AND strTrlUPCEntryType = 'scanned'
										THEN dblTrpAmt ELSE 0 END as dblCouponAmount --25 COUPON

									, 'N' as strManufacturerMultipackFlag
									, 0 as intManufacturerMultipackQuantity
									, 0 as dblManufacturerMultipackDiscountAmount

									, CASE 
										WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') 
											THEN CRP.strManufacturerPromotionDescription 
										WHEN strTrpCardInfoTrpcHostID IN ('VAPS') AND strTrlMatchLineTrlMatchName IS NOT NULL AND dblTrlMatchLineTrlPromoAmount IS NOT NULL 
											THEN strTrlDesc
										ELSE '' 
									  END as strManufacturerPromotionDescription

									, REPLACE(CRP.strProgramName, ',','') as strManufacturerBuydownDescription
									, CRP.dblManufacturerBuyDownAmount as dblManufacturerBuydownAmount
									, '' as strManufacturerMultiPackDescription
									, TR.strTrLoyaltyProgramTrloAccount as strAccountLoyaltyIDNumber
									, '' as strCouponDescription
									, [strDepartment] = CASE
															WHEN uom.intItemUOMId IS NOT NULL
																THEN category.strCategoryCode
															ELSE ''
														END
						FROM 
						(   
							SELECT * FROM
							(   
								SELECT *, ROW_NUMBER() OVER (PARTITION BY intTermMsgSN, strTrlUPC, strTrlDesc, strTrlDept, dblTrlQty, dblTrpAmt, strTrpPaycode, intStoreId, intCheckoutId, intScanTransactionId ORDER BY strTrpPaycode DESC) AS rn
								FROM tblSTTranslogRebates
							) TRR 
							WHERE TRR.rn = 1		
								AND CAST(TRR.dtmDate AS DATE) BETWEEN @dtmBeginningDate AND @dtmEndingDate	
								AND TRR.ysnRJRSubmitted = CASE
															WHEN @ysnResubmit = CAST(0 AS BIT)
																THEN CAST(0 AS BIT)
															WHEN @ysnResubmit = CAST(1 AS BIT)
																THEN TRR.ysnRJRSubmitted
														END
						) TR
						INNER JOIN tblSTStore ST 
							ON ST.intStoreId = TR.intStoreId
						LEFT JOIN tblICItemUOM uom
							ON TR.strTrlUPCwithoutCheckDigit = uom.strLongUPCCode
						LEFT JOIN tblICItem item
							ON uom.intItemId = item.intItemId
						LEFT JOIN tblICCategory category
							ON item.intCategoryId = category.intCategoryId
						LEFT JOIN vyuSTCigaretteRebatePrograms CRP 
							ON CONVERT(NUMERIC(32, 0),CAST(TR.strTrlUPCwithoutCheckDigit AS FLOAT)) = CRP.intUpcCode ---->   Always compare UPC without check digit since Inventory UPC has no check digit, use IC intUpcCode
								AND (CAST(TR.dtmDate AS DATE) BETWEEN CRP.dtmStartDate AND CRP.dtmEndDate)
						WHERE TR.intTrlDeptNumber IN (SELECT DISTINCT intRegisterDepartmentId FROM fnSTRebateDepartment(CAST(ST.intStoreId AS NVARCHAR(10))))
								) as innerQuery


				END TRY
				BEGIN CATCH
					SET @intCountRows = 0
					SET @strStatusMsg = ERROR_MESSAGE()
				END CATCH


				BEGIN TRY

					INSERT INTO @tempTable
					(
						  dtmDate
						, dtmTime
						, strStoreName
						, intTermMsgSN
						, dblQty
						, dblPrice
						, strDepartment
						, strUpc
						, strDescription
					)
					SELECT 
						  dtmDate			= CAST(CONVERT(DATE, RJ.strTransactionDateTime, 120) AS DATE)
						, dtmTime			= CONVERT(VARCHAR, CONVERT(TIME, RJ.strTransactionDateTime, 120), 108)
						, strStoreName		= RJ.strOutletName
						, intTermMsgSN		= CAST(RJ.strMarketBasketTransactionId AS BIGINT)
						, dblQty			= RJ.intQuantity
						, dblPrice			= RJ.dblPrice
						, strDepartment		= RJ.strDepartment
						, strUpc			= RJ.strUpcCode
						, strDescription	= RJ.strUpcDescription
					FROM @tblTempRJR RJ

				END TRY
				BEGIN CATCH
					SET @intCountRows = 0
					SET @strStatusMsg = ERROR_MESSAGE()
				END CATCH

			END

		SELECT @intCountRows = COUNT(*) FROM @tempTable

		--This select will return to server side
		SELECT * FROM @tempTable
	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END