CREATE PROCEDURE [dbo].[uspSTGenerateVendorRebate]
	@intVendorId int,
	@dtmBeginningDate datetime,
	@dtmEndingDate datetime,
	@intCsvFormat INT,
	@ysnResubmit BIT,
	@strStatusMsg NVARCHAR(MAX) OUTPUT,
	@strCSVHeader NVARCHAR(MAX) OUTPUT,
	@intVendorAccountNumber INT OUTPUT
AS
BEGIN TRY
	
	-- @intCsvFormat
	-- 0 = PM Morris
    -- 1 = RJ Reynolds

	SET @strStatusMsg = ''

	SET @intVendorAccountNumber = 0

	DECLARE @intCountDays AS INT = DATEDIFF(DAY, CAST(@dtmBeginningDate AS DATE), CAST(@dtmEndingDate AS DATE)) + 1
	IF(@intCountDays > 7)
	BEGIN
		SET @strCSVHeader = ''
		SET @intVendorAccountNumber = 0
		SET @strStatusMsg = 'Selected date range have a total of [' + CAST(@intCountDays AS NVARCHAR(20)) + '] days. Selected dates should complete only 1 week of data transaction'
		
		RETURN
	END
	ELSE IF(@intCountDays < 7)
	BEGIN
		SET @strCSVHeader = ''
		SET @intVendorAccountNumber = 0
		SET @strStatusMsg = 'Selected date range have a total of [' + CAST(@intCountDays AS NVARCHAR(20)) + '] days. Selected dates should complete 1 week of data transaction'
			
		RETURN
	END

	--// START Validate Start and Ending date
	IF(@intCsvFormat = 0) -- 0 = PM Morris
	BEGIN
		-- The date should start on Sunday to Saturday
		IF(DATENAME(DW, CAST(@dtmBeginningDate AS DATE)) = 'Sunday' AND DATENAME(DW, CAST(@dtmEndingDate AS DATE)) = 'Saturday')
		BEGIN
				SET @strStatusMsg = ''
		END
		ELSE
		BEGIN
			SET @strCSVHeader = ''
			SET @intVendorAccountNumber = 0
			SET @strStatusMsg = 'Selected date range should start on Sunday to Saturday'
				
			RETURN
		END
	END
	ELSE IF(@intCsvFormat = 1) -- 1 = RJ Reynolds
	BEGIN
		-- The date should start on Monday to Sunday
		IF(DATENAME(DW, CAST(@dtmBeginningDate AS DATE)) = 'Monday' AND DATENAME(DW, CAST(@dtmEndingDate AS DATE)) = 'Sunday')
		BEGIN
			SET @strStatusMsg = ''
		END
		ELSE
		BEGIN
			SET @strCSVHeader = ''
			SET @intVendorAccountNumber = 0
			SET @strStatusMsg = 'Selected date range should start on Monday to Sunday'
				
			RETURN
		END
	END
	--// END Validate Start and Ending date


	-- // Create temp table PM Morris
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
		strLoyaltyIDRewardsNumber nvarchar(20) COLLATE Latin1_General_CI_AS NULL
	)

	---- // Create temp table RJ Reynolds
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
		[strCouponDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	)


	DECLARE @Delimiter CHAR(1)

	IF(@intCsvFormat = 0)
	BEGIN
		SET @Delimiter = '|'

		-- Check if has chain account number
		IF EXISTS(SELECT intChainAccountNumber FROM tblAPVendor WHERE intEntityId = @intVendorId AND intChainAccountNumber IS NOT NULL)
		BEGIN
			SELECT @intVendorAccountNumber = intChainAccountNumber FROM tblAPVendor
			WHERE intEntityId = @intVendorId
		END
		ELSE
		BEGIN
			SET @strCSVHeader = ''
			SET @intVendorAccountNumber = 0
			SET @strStatusMsg = 'Selected Vendor does not have Chain account number setup'
			RETURN
		END

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
							FROM (
							SELECT DISTINCT intScanTransactionId, @intVendorAccountNumber intRCN 
			, REPLACE(CONVERT(NVARCHAR, @dtmEndingDate, 111), '/', '') AS dtmWeekEndingDate
			, REPLACE(CONVERT(NVARCHAR, dtmDate, 111), '/', '') AS dtmTransactionDate 
			, CONVERT(NVARCHAR, dtmDate, 108) AS strTransactionTime
			, intTermMsgSN AS strTransactionIdCode
			, ST.intStoreNo AS strStoreNumber
			, ST.strDescription AS strStoreName
			, REPLACE(REPLACE(REPLACE(REPLACE(ST.strAddress, CHAR(10), ''), CHAR(13), ''), @Delimiter, ''), ',', '') AS strStoreAddress
			, ST.strCity AS strStoreCity
			, UPPER(LEFT(ST.strState, 2)) AS strStoreState
			, ST.strZipCode AS intStoreZipCode
			, strTrlDept AS strCategory
			, EM.strName AS strManufacturerName
			, strTrlUPC AS strSKUCode		-- 4
			, strTrlUPC AS strUpcCode		-- Check digit is included. Since RJ and PM requires check digits
			, strTrlDesc AS strSkuUpcDescription
			, CASE WHEN DEPT.ysnTobacco = 1 THEN 'PACKS' ELSE 'CANS' END AS strUnitOfMeasure
			, CASE WHEN strTrpPaycode != 'Change' THEN CAST(dblTrlQty as INT) ELSE 0 END AS intQuantitySold
			, 1 AS intConsumerUnits
			, CASE WHEN DEPT.ysnTobacco = 1 
				AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2 
			  THEN 'Y' 
			  ELSE 'N' END AS strMultiPackIndicator
			, CASE WHEN DEPT.ysnTobacco = 1 
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2
			  THEN 2
			  ELSE NULL END AS intMultiPackRequiredQuantity
			, CASE WHEN DEPT.ysnTobacco = 1 
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2
			  THEN (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty)
			  ELSE NULL END AS dblMultiPackDiscountAmount
			, REPLACE(CRP.strProgramName, ',','') as strRetailerFundedDiscountName
			, CRP.dblManufacturerBuyDownAmount as dblRetailerFundedDiscountAmount
			, CASE WHEN strTrpPaycode = 'COUPONS' THEN 'Coupon' ELSE '' END AS strMFGDealNameONE
			, CASE WHEN strTrpPaycode = 'COUPONS' THEN TR.dblTrpAmt ELSE NULL END AS dblMFGDealDiscountAmountONE
			, '' AS strMFGDealNameTWO
			, NULL AS dblMFGDealDiscountAmountTWO
			, '' AS strMFGDealNameTHREE
			, NULL AS dblMFGDealDiscountAmountTHREE
			, CASE WHEN DEPT.ysnTobacco = 1   
				AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer'
				AND TR.dblTrlQty >= 2 -- 2 Can Deal
			  THEN (TR.dblTrlUnitPrice - (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty))
			  WHEN TR.strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') 
				AND TR.dblTrlQty >= 2
			  THEN (TR.dblTrlUnitPrice - (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty))
			  WHEN TR.strTrpPaycode IN ('COUPONS')
			  THEN (TR.dblTrlUnitPrice - (TR.dblTrpAmt))
			  ELSE dblTrlUnitPrice END as dblFinalSalesPrice
			, NULL AS intStoreTelephone
			, '' AS strStoreContactName
			, '' strStoreContactEmail
			, '' strProductGroupingCode
			, '' strProductGroupingName
			, '' strLoyaltyIDRewardsNumber
		FROM (
			SELECT * FROM
			( SELECT *, ROW_NUMBER() OVER (PARTITION BY intTermMsgSN, strTrlUPC, strTrlDesc, strTrlDept, dblTrlQty, dblTrpAmt, strTrpPaycode, intStoreId, intCheckoutId ,intScanTransactionId ORDER BY strTrpPaycode DESC) AS rn
				FROM tblSTTranslogRebates
				WHERE CAST(dtmDate AS DATE) BETWEEN @dtmBeginningDate AND @dtmEndingDate
			) TRR 
			WHERE TRR.rn = 1
			AND TRR.ysnPMMSubmitted = CASE WHEN @ysnResubmit = CAST(0 AS BIT) THEN CAST(0 AS BIT) WHEN @ysnResubmit = CAST(1 AS BIT) THEN TRR.ysnPMMSubmitted END
		) TR
		INNER JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
		INNER JOIN tblSTStoreRebates SR ON SR.intStoreId = ST.intStoreId
 		JOIN tblEMEntity EM ON EM.intEntityId = @intVendorId
		JOIN tblAPVendor APV ON APV.intEntityId = EM.intEntityId
		LEFT JOIN vyuSTCigaretteRebatePrograms CRP ON CONVERT(NUMERIC(32, 0),CAST(TR.strTrlUPCwithoutCheckDigit AS FLOAT)) = CRP.intUpcCode ---->   Always compare UPC without check digit since Inventory UPC has no check digit, use IC intUpcCode
		AND (CAST(TR.dtmDate AS DATE) BETWEEN CRP.dtmStartDate AND CRP.dtmEndDate)	
		INNER JOIN (
			SELECT DISTINCT intStoreId = Rebates.intStoreId
				,ysnTobacco = Rebates.ysnTobacco
			FROM tblSTStoreRebates Rebates
			INNER JOIN tblSTStore Store
				ON Rebates.intStoreId = Store.intStoreId
			INNER JOIN tblICCategory Category
				ON Rebates.intCategoryId = Category.intCategoryId
			INNER JOIN tblICCategoryLocation CatLoc
				ON Category.intCategoryId = CatLoc.intCategoryId
				AND Store.intCompanyLocationId = CatLoc.intLocationId
		) DEPT ON DEPT.intStoreId = TR.intStoreId		
		WHERE (ST.strAddress !='' OR ST.strAddress IS NOT NULL) -- Filter Store without Address
		AND (TR.strTrlUPC != '' AND TR.strTrlUPC IS NOT NULL)
		AND TR.strTrpPaycode != 'Change' --ST-680
			) as innerquery

		IF EXISTS(SELECT * FROM @tblTempPMM)
		BEGIN
			SET @strStatusMsg = 'Success'
		END
		ELSE
		BEGIN
			SET @strStatusMsg = 'No record found'
		END

	END
	ELSE IF(@intCsvFormat = 1)
	BEGIN

		SET @Delimiter = ','

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
								FROM ( 
								SELECT DISTINCT intScanTransactionId ,(CASE WHEN ST.strDescription IS NULL THEN '' ELSE REPLACE(ST.strDescription, @Delimiter, '') END) as strOutletName
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
			
			, CASE WHEN TR.intTrlDeptNumber IN (SELECT intRegisterDepartmentId FROM [dbo].[fnSTRebateDepartment]((CAST(ST.intStoreId AS NVARCHAR(10)))) WHERE ysnTobacco = 1)
													AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
													AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
													AND TR.dblTrlQty >= 2 -- 2 Can Deal
														THEN (TR.dblTrlUnitPrice - (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty))
												WHEN TR.strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
													THEN (TR.dblTrlUnitPrice - (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty))
												WHEN strTrpPaycode = 'COUPONS' AND strTrlMatchLineTrlPromotionIDPromoType IS NULL AND strTrlUPCEntryType = 'scanned'
													THEN (TR.dblTrlUnitPrice - TR.dblTrpAmt)
												ELSE dblTrlUnitPrice 
											  END as dblPrice


			, strTrlUPC AS strUpcCode		-- Check digit is included. Since RJ and PM requires check digits
			, REPLACE(strTrlDesc, ',', ' ') AS strUpcDescription
			, CASE	WHEN DEPT.ysnTobacco = 1 THEN 'PACKS' ELSE 'CANS' END AS strUnitOfMeasure
			, CASE WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') THEN 'Y'
			  WHEN DEPT.ysnTobacco = 1
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2 
			  THEN 'Y' -- 2 Can Deal
			  WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') 
			    AND TR.dblTrlQty >= 2
			  THEN 'Y'
			  ELSE 'N' END AS strPromotionFlag

			, CASE WHEN DEPT.ysnTobacco = 1
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2 
			  THEN 'Y' -- 2 Can Deal
			  WHEN strTrpCardInfoTrpcHostID IN ('VAPS') 
			  THEN 'N' 
			  WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
			  THEN 'Y'
			  ELSE 'N' END AS strOutletMultipackFlag

			, CASE WHEN DEPT.ysnTobacco = 1
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2 
			  THEN 2 -- 2 Can Deal
			  WHEN strTrpCardInfoTrpcHostID IN ('VAPS') 
			  THEN 0 	
			  WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
			  THEN 2
			  ELSE 0 END AS intOutletMultipackQuantity

			, CASE WHEN DEPT.ysnTobacco = 1
				AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2 
			  THEN (TR.dblTrlMatchLineTrlPromoAmount / 2) / 4 -- 2 Can Deal
			  WHEN strTrpCardInfoTrpcHostID IN ('VAPS') 
			  THEN 0 
			  WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer') AND TR.dblTrlQty >= 2
			  THEN (TR.dblTrlMatchLineTrlPromoAmount / TR.dblTrlQty)
			  ELSE 0 END AS dblOutletMultipackDiscountAmount
			, '' AS strAccountPromotionName --21
			, 0 AS dblAccountDiscountAmount --22
			, CASE WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') 
			  THEN CRP.dblManufacturerDiscountAmount 
			  ELSE 0 END AS dblManufacturerDiscountAmount
			, CASE WHEN strTrpPaycode = 'COUPONS' 
				AND strTrlMatchLineTrlPromotionIDPromoType IS NULL 
				AND strTrlUPCEntryType = 'scanned'
			  THEN strTrlUPC 
			  ELSE '' END AS strCouponPid --24 COUPON
			, CASE WHEN strTrpPaycode = 'COUPONS' 
				AND strTrlMatchLineTrlPromotionIDPromoType IS NULL 
				AND strTrlUPCEntryType = 'scanned'
			  THEN dblTrpAmt 
			  ELSE 0 END as dblCouponAmount --25 COUPON
			, CASE WHEN DEPT.ysnTobacco = 1
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2  
			  THEN 'Y' -- 2 Can Deal
			  ELSE 'N' END AS strManufacturerMultipackFlag
			, CASE WHEN DEPT.ysnTobacco = 1 
				AND	TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2
			  THEN 2 -- 2 Can Deal
			  ELSE 0 END AS intManufacturerMultipackQuantity
			, CASE WHEN DEPT.ysnTobacco = 1
				AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2
			  THEN (TR.dblTrlMatchLineTrlPromoAmount / 2) / 4 -- 2 Can Deal
			  ELSE 0 END AS dblManufacturerMultipackDiscountAmount
			, CASE WHEN DEPT.ysnTobacco = 1
				AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2
			  THEN 'Two Can Deal' -- 2 Can Deal
			  WHEN CRP.strPromotionType IN ('VAPS', 'B2S$') -- This part is relaated to column 'dblManufacturerDiscountAmount'
			  THEN CRP.strManufacturerPromotionDescription
			  ELSE '' END AS strManufacturerPromotionDescription
			, REPLACE(CRP.strProgramName, ',','') AS strManufacturerBuydownDescription
			, CRP.dblManufacturerBuyDownAmount AS dblManufacturerBuydownAmount

			, CASE WHEN DEPT.ysnTobacco = 1
				AND TR.strTrlMatchLineTrlMatchName IS NOT NULL 
				AND TR.strTrlMatchLineTrlPromotionIDPromoType = 'mixAndMatchOffer' 
				AND TR.dblTrlQty >= 2
			  THEN 'Two Can Deal' -- 2 Can Deal
			  ELSE '' END AS strManufacturerMultiPackDescription
			, TR.strTrLoyaltyProgramTrloAccount as strAccountLoyaltyIDNumber
			, '' as strCouponDescription
		FROM (   
			SELECT * FROM
			(   
				SELECT *, ROW_NUMBER() OVER (PARTITION BY intTermMsgSN, strTrlUPC, strTrlDesc, strTrlDept, dblTrlQty, dblTrpAmt, strTrpPaycode, intStoreId, intCheckoutId,intScanTransactionId ORDER BY strTrpPaycode DESC) AS rn
				FROM tblSTTranslogRebates
				WHERE CAST(dtmDate AS DATE) BETWEEN @dtmBeginningDate AND @dtmEndingDate	
			) TRR WHERE TRR.rn = 1		
				AND TRR.ysnRJRSubmitted = CASE WHEN @ysnResubmit = CAST(0 AS BIT) THEN CAST(0 AS BIT) WHEN @ysnResubmit = CAST(1 AS BIT) THEN TRR.ysnRJRSubmitted END
		) TR
		JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
		INNER JOIN tblSTStoreRebates SR ON SR.intStoreId = ST.intStoreId
		LEFT JOIN vyuSTCigaretteRebatePrograms CRP ON CONVERT(NUMERIC(32, 0),CAST(TR.strTrlUPCwithoutCheckDigit AS FLOAT)) = CRP.intUpcCode 
			AND (CAST(TR.dtmDate AS DATE) BETWEEN CRP.dtmStartDate AND CRP.dtmEndDate)
		INNER JOIN (
			SELECT DISTINCT intStoreId = Rebates.intStoreId
				,ysnTobacco = Rebates.ysnTobacco
				,intRegisterDepartmentId = CatLoc.intRegisterDepartmentId
			FROM tblSTStoreRebates Rebates
			INNER JOIN tblSTStore Store
				ON Rebates.intStoreId = Store.intStoreId
			INNER JOIN tblICCategory Category
				ON Rebates.intCategoryId = Category.intCategoryId
			INNER JOIN tblICCategoryLocation CatLoc
				ON Category.intCategoryId = CatLoc.intCategoryId
				AND Store.intCompanyLocationId = CatLoc.intLocationId
		) DEPT ON DEPT.intStoreId = TR.intStoreId AND DEPT.intRegisterDepartmentId = TR.intTrlDeptNumber
		WHERE (ST.strAddress !='' OR ST.strAddress IS NOT NULL)
			AND (TR.strTrlUPC != '' AND TR.strTrlUPC IS NOT NULL)
				) as innerquery
		-- Check if has record
		IF EXISTS(SELECT * FROM @tblTempRJR)
		BEGIN
			SET @strStatusMsg = 'Success'
		END
		ELSE
		BEGIN
			SET @strStatusMsg = 'No record found'
		END

	END

	IF(@strStatusMsg = 'Success')
	BEGIN
		IF(@intCsvFormat = 0) -- 0 = PM Morris
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM @tblTempPMM)
			BEGIN
				UPDATE tblSTTranslogRebates
					SET ysnPMMSubmitted = 1
				WHERE intStoreId IN (SELECT DISTINCT ST.intStoreId FROM tblSTStore ST 
						INNER JOIN tblSTStoreRebates SR ON SR.intStoreId = ST.intStoreId  
						WHERE (ST.strAddress !='' OR ST.strAddress IS NOT NULL))
					AND CAST(dtmDate as DATE) >= @dtmBeginningDate
					AND CAST(dtmDate as DATE) <= @dtmEndingDate
					AND ysnPMMSubmitted = CASE WHEN @ysnResubmit = CAST(0 AS BIT)
										  THEN CAST(0 AS BIT)
										  WHEN @ysnResubmit = CAST(1 AS BIT)
										  THEN ysnPMMSubmitted END


				DECLARE @intNumberOfRecords int = 0
				DECLARE @intSoldQuantity int = 0
				DECLARE @dblFinalSales decimal(10, 2) = 0
				DECLARE @strScanDataProvider nvarchar(max) = 'iRely LLC'
				
				SELECT @intNumberOfRecords = COUNT(*)				-- Get total number of records
					, @intSoldQuantity = SUM(intQuantitySold)	-- Get total quantity sold
					, @dblFinalSales = SUM(dblFinalSalesPrice)	-- Get sum of the final sales price field
				FROM @tblTempPMM

				SET @strCSVHeader = CAST(ISNULL(@intNumberOfRecords, 0) as NVARCHAR(50)) + '|' + CAST(ISNULL(@intSoldQuantity, 0) as NVARCHAR(50)) + '|' + CAST(ISNULL(@dblFinalSales, 0) as NVARCHAR(50)) + '|' + @strScanDataProvider + CHAR(13)
				
				SELECT * FROM @tblTempPMM
				ORDER BY CAST(strStoreNumber AS INT) ASC

			END
		END
		ELSE IF (@intCsvFormat = 1)
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM @tblTempRJR)
			BEGIN
				UPDATE tblSTTranslogRebates
					SET ysnRJRSubmitted = 1
				WHERE intStoreId IN (SELECT DISTINCT ST.intStoreId FROM tblSTStore ST 
						INNER JOIN tblSTStoreRebates SR ON SR.intStoreId = ST.intStoreId  
						WHERE (ST.strAddress !='' OR ST.strAddress IS NOT NULL))
					AND CAST(dtmDate as DATE) >= @dtmBeginningDate
					AND CAST(dtmDate as DATE) <= @dtmEndingDate
					AND ysnRJRSubmitted = CASE WHEN @ysnResubmit = CAST(0 AS BIT)
										  THEN CAST(0 AS BIT)
										  WHEN @ysnResubmit = CAST(1 AS BIT)
										THEN ysnRJRSubmitted END

				SELECT * FROM @tblTempRJR
				ORDER BY intOutletNumber ASC

			END
		END
	END
	ELSE
	BEGIN
		SET @strStatusMsg = 'No transaction log found based on filter'
		SET @strCSVHeader = ''
		SET @intVendorAccountNumber = 0	
		RETURN
	END

END TRY
BEGIN CATCH
	SET @strStatusMsg = ERROR_MESSAGE()
END CATCH

