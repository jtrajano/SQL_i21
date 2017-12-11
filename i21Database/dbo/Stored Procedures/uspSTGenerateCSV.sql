﻿CREATE PROCEDURE [dbo].[uspSTGenerateCSV]
@intVendorId int,
@strStoreIdList NVARCHAR(MAX),
@dtmBeginningDate datetime,
@dtmEndingDate datetime,
@strTableName nvarchar(200),
@strStatusMsg NVARCHAR(250) OUTPUT,
@strCSV NVARCHAR(MAX) OUTPUT
AS
BEGIN
	Begin Try

		--Get Vendor Name
		DECLARE @strVendorName NVARCHAR(200)
		SELECT @strVendorName = strName FROM tblEMEntity WHERE intEntityId = @intVendorId

		--START Insert StoreId to table
		DECLARE @strCharacter CHAR(1)
		SET @strCharacter = ','

		DECLARE @tblStoreIdList TABLE (intCount int,intStoreId int)

		DECLARE @intCount int = 1

		DECLARE @StartIndex INT, @EndIndex INT
 
		SET @StartIndex = 1
		IF SUBSTRING(@strStoreIdList, LEN(@strStoreIdList) - 1, LEN(@strStoreIdList)) <> @strCharacter
		BEGIN
			 SET @strStoreIdList = @strStoreIdList + @strCharacter
		END

		WHILE CHARINDEX(@strCharacter, @strStoreIdList) > 0
		BEGIN
			 SET @EndIndex = CHARINDEX(@strCharacter, @strStoreIdList)
           
			 INSERT INTO @tblStoreIdList
			 SELECT 
					@intCount,
					CAST(SUBSTRING(@strStoreIdList, @StartIndex, @EndIndex - 1) AS INT)
           
			 SET @intCount = @intCount + 1
			 SET @strStoreIdList = SUBSTRING(@strStoreIdList, @EndIndex + 1, LEN(@strStoreIdList))
		END
		--END Insert StoreId to table

		SELECT * FROM @tblStoreIdList


		--START Loop to all store Id
		DECLARE @intStoreIdMin int, @intStoreIdMax int
		SELECT @intStoreIdMin = MIN(intStoreId), @intStoreIdMax = MAX(intStoreId)
		FROM @tblStoreIdList

		WHILE(@intStoreIdMin <= @intStoreIdMax)
		BEGIN

			IF EXISTS (SELECT * FROM tblSTTranslogRebates WHERE intStoreId = @intStoreIdMin AND CAST(dtmOpenedTime as DATE) >= @dtmBeginningDate AND CAST(dtmClosedTime as DATE) <= @dtmEndingDate AND ysnSubmitted = 0)
			BEGIN
			    -- GET week ending date (SATURDAY)
				DECLARE @NextDayID INT = 5 -- 0=Mon, 1=Tue, 2=Wed, 3=Thur, 4=Fri, 5=Sat, 6=Sun
				DECLARE @dtmGetWeekEndingDate DATETIME
				SET @dtmGetWeekEndingDate = DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, @dtmEndingDate) / 7) * 7 + 7, @NextDayID)

				--START Insert data from tblSTstgRebatesPMMorris
				IF(@strTableName = 'tblSTstgRebatesPMMorris')
				BEGIN
					INSERT INTO tblSTstgRebatesPMMorris
					(
						intManagementOrRetailNumber
						, strWeekEndingDate
						, strTransactionDate 
						, strTransactionTime
						, strTransactionIdCode 
						, strStoreNumber
						, strStoreName
						, strStoreAddress
						, strStoreCity
						, strStoreState
						, intStoreZipCode
						, strCategory
						, strManufacturerName
						, strSKUCode
						, strUpcCode
						, strSkuUpcDescription
						, strUnitOfMeasure
						, intQuantitySold
						, intConsumerUnits
						, strMultiPackIndicator
						, intMultiPackRequiredQuantity
						, dblMultiPackDiscountAmount
						, strRetailerFundedDIscountName
						, dblRetailerFundedDiscountAmount
						, strMFGDealNameONE
						, dblMFGDealDiscountAmountONE
						, strMFGDealNameTWO
						, dblMFGDealDiscountAmountTWO
						, strMFGDealNameTHREE
						, dblMFGDealDiscountAmountTHREE
						, dblFinalSalesPrice
					)
					SELECT
						x.intRCN
						, x.dtmWeekEndingDate 
						, x.dtmTransactionDate
						, x.strTransactionTime
						, x.strTransactionIdCode 
						, x.strStoreNumber
						, x.strStoreName
						, x.strStoreAddress
						, x.strStoreCity
						, x.strStoreState
						, x.intStoreZipCode
						, x.strCategory
						, x.strManufacturerName
						, x.strSKUCode
						, x.strUpcCode
						, x.strSkuUpcDescription
						, x.strUnitOfMeasure
						, x.intQuantitySold
						, x.intConsumerUnits
						, x.strMultiPackIndicator
						, x.intMultiPackRequiredQuantity
						, x.dblMultiPackDiscountAmount
						, x.strRetailerFundedDiscountName
						, x.dblRetailerFundedDiscountAmount
						, x.strMFGDealNameONE
						, x.dblMFGDealDiscountAmountONE
						, x.strMFGDealNameTWO
						, x.dblMFGDealDiscountAmountTWO
						, x.strMFGDealNameTHREE
						, x.dblMFGDealDiscountAmountTHREE
						, x.dblFinalSalesPrice
					FROM
					(
						SELECT
								624419 as intRCN
								--, FORMAT(CAST(dtmClosedTime AS DATE), 'yyyyMMdd') as dtmWeekEndingDate 
								--, FORMAT(CAST(dtmDate AS DATE), 'yyyyMMdd') as dtmTransactionDate
								--, FORMAT(dtmDate, 'hh:mm:ss') as strTransactionTime
								--, replace(convert(NVARCHAR, dtmClosedTime, 111), '/', '') as dtmWeekEndingDate 
								, replace(convert(NVARCHAR, @dtmGetWeekEndingDate, 111), '/', '') as dtmWeekEndingDate
								, replace(convert(NVARCHAR, dtmDate, 111), '/', '') as dtmTransactionDate 
								, convert(NVARCHAR, dtmDate, 108) as strTransactionTime
								, intTermMsgSN as strTransactionIdCode
								, ST.intStoreNo as strStoreNumber
								, ST.strDescription as strStoreName
								, ST.strAddress as strStoreAddress
								, ST.strCity as strStoreCity
								, UPPER(LEFT(ST.strState, 2)) as strStoreState
								, ST.strZipCode as intStoreZipCode
								, strTrlDept as strCategory
								, @strVendorName as strManufacturerName
								, '' as strSKUCode
								, strTrlUPC as strUpcCode
								, strTrlDesc as strSkuUpcDescription
								, 'PACK' as strUnitOfMeasure
								, CAST(CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlQty ELSE 0 END as INT) as intQuantitySold
								, 1 as intConsumerUnits
								, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 'Y' ELSE 'N' END as strMultiPackIndicator
								, CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlQty ELSE 0 END as intMultiPackRequiredQuantity
								, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 0.50 ELSE 0 END as dblMultiPackDiscountAmount
								, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 'Sale' ELSE '' END as strRetailerFundedDiscountName
								, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 0.50 ELSE 0 END as dblRetailerFundedDiscountAmount
								, CASE WHEN strTrpPaycode = 'COUPONS' THEN 'Coupon' ELSE '' END as strMFGDealNameONE
								, CASE WHEN strTrpPaycode = 'COUPONS' THEN 0.50 ELSE 0 END as dblMFGDealDiscountAmountONE
								, '' as strMFGDealNameTWO
								, 0 as dblMFGDealDiscountAmountTWO
								, '' as strMFGDealNameTHREE
								, 0 as dblMFGDealDiscountAmountTHREE
								, CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlLineTot ELSE 0 END as dblFinalSalesPrice
							FROM tblSTTranslogRebates TR
							JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
							WHERE TR.intStoreId = @intStoreIdMin AND CAST(TR.dtmOpenedTime as DATE) >= @dtmBeginningDate AND CAST(TR.dtmClosedTime as DATE) <= @dtmEndingDate AND ysnSubmitted = 0
					) x
				END
				--END Insert data from tblSTstgRebatesPMMorris

				--START Insert data from tblSTstgRebatesRJReynolds
				IF(@strTableName = 'tblSTstgRebatesRJReynolds')
				BEGIN
					INSERT INTO tblSTstgRebatesRJReynolds
					(
						strOutletName
						, intOutletNumber
						, strOutletAddressOne 
						, strOutletAddressTwo
						, strOutletCity
						, strOutletState 
						, strOutletZipCode
						, strTransactionDateTime
						, strMarketBasketTransactionId
						, strScanTransactionId
						, strRegisterId
						, intQuantity
						, dblPrice
						, strUpcCode
						, strUpcDescription
						, strUnitOfMeasure
						, strPromotionFlag
						, strOutletMultipackFlag
						, intOutletMultipackQuantity
						, dblOutletMultipackDiscountAmount
						, strAccountPromotionName
						, dblAccountDiscountAmount
						, dblManufacturerDiscountAmount
						, strCouponPid
						, dblCouponAmount
						
						, strManufacturerMultipackFlag
						, intManufacturerMultipackQuantity
						, dblManufacturerMultipackDiscountAmount
						, strManufacturerPromotionDescription
						, strManufacturerBuydownDescription
						, dblManufacturerBuydownAmount
						, strManufacturerMultiPackDescription
						, strAccountLoyaltyIDNumber
						, strCouponDescription
					)
					SELECT
						x.strOutletName
						, x.intOutletNumber
						, x.strOutletAddressOne 
						, x.strOutletAddressTwo
						, x.strOutletCity
						, x.strOutletState 
						, x.strOutletZipCode
						, x.strTransactionDateTime
						, x.strMarketBasketTransactionId
						, x.strScanTransactionId
						, x.strRegisterId
						, x.intQuantity
						, x.dblPrice
						, x.strUpcCode
						, x.strUpcDescription
						, x.strUnitOfMeasure
						, x.strPromotionFlag
						, x.strOutletMultipackFlag
						, x.intOutletMultipackQuantity
						, x.dblOutletMultipackDiscountAmount
						, x.strAccountPromotionName
						, x.dblAccountDiscountAmount
						, x.dblManufacturerDiscountAmount
						, x.strCouponPid
						, x.dblCouponAmount
						
						, x.strManufacturerMultipackFlag
						, x.intManufacturerMultipackQuantity
						, x.dblManufacturerMultipackDiscountAmount
						, x.strManufacturerPromotionDescription
						, x.strManufacturerBuydownDescription
						, x.dblManufacturerBuydownAmount
						, x.strManufacturerMultiPackDescription
						, x.strAccountLoyaltyIDNumber
						, x.strCouponDescription
					FROM
					(
						SELECT
								CASE WHEN ST.strDescription IS NULL THEN '' ELSE ST.strDescription END as strOutletName
								, ST.intStoreNo as intOutletNumber
								, CASE WHEN ST.strAddress IS NULL THEN '' ELSE ST.strAddress END as strOutletAddressOne
								, '' as strOutletAddressTwo
								, CASE WHEN ST.strCity IS NULL THEN '' ELSE ST.strCity END as strOutletCity
								, UPPER(LEFT(ST.strState, 2)) as strOutletState
								,  CASE WHEN ST.strZipCode IS NULL THEN '' ELSE ST.strZipCode END as strOutletZipCode
								--, FORMAT(CAST(dtmDate AS datetime), 'yyyy-MM-dd-HH:mm:ss') as strTransactionDateTime
								, replace(convert(NVARCHAR, dtmDate, 120), ' ', '-') as strTransactionDateTime
								, intTermMsgSN as strMarketBasketTransactionId
								, intTermMsgSN as strScanTransactionId
								, intPosNum as strRegisterId
								, dblTrlQty as intQuantity
								, dblTrlLineTot as dblPrice
								, strTrlUPC as strUpcCode
								, strTrlDesc as strUpcDescription
								, 'PACK' as strUnitOfMeasure
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'Y' ELSE 'N' END as strPromotionFlag
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'Y' ELSE 'N' END as strOutletMultipackFlag

								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN 
									(CASE WHEN dblTrlQty > 1 THEN dblTrlQty ELSE 2 END)
								  ELSE 0 END as intOutletMultipackQuantity

								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblOutletMultipackDiscountAmount
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'COUPONS' ELSE '' END as strAccountPromotionName
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblAccountDiscountAmount
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblManufacturerDiscountAmount
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpCouponEntryMethod ELSE '' END as strCouponPid
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblCouponAmount

								, 'N' as strManufacturerMultipackFlag
								, 0 as intManufacturerMultipackQuantity
								, 0 as dblManufacturerMultipackDiscountAmount
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpPaycode ELSE '' END as strManufacturerPromotionDescription
								, '' as strManufacturerBuydownDescription
								, 0 as dblManufacturerBuydownAmount
								, '' as strManufacturerMultiPackDescription
								, '123789' as strAccountLoyaltyIDNumber
								, 'Loyalty coupon desc' as strCouponDescription
							FROM tblSTTranslogRebates TR
							JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
							WHERE TR.intStoreId = @intStoreIdMin 
							AND CAST(TR.dtmOpenedTime as DATE) >= @dtmBeginningDate 
							AND CAST(TR.dtmClosedTime as DATE) <= @dtmEndingDate 
							AND ysnSubmitted = 0
							AND strTrLinetype = 'plu'
					) x
				END
				--END Insert data from tblSTstgRebatesRJReynolds

				--Mark
			END
			
			PRINT @intStoreIdMin
		
			SET @intStoreIdMin = @intStoreIdMin + 1
		END
		--END Loop to all store Id

		--CHECK IF table has values
		DECLARE @Count int
		DECLARE @CreateCSV bit = 0
		IF(@strTableName = 'tblSTstgRebatesPMMorris')
		BEGIN
			IF EXISTS (SELECT 1 FROM tblSTstgRebatesPMMorris)
			BEGIN
				SET @CreateCSV = 1
			END
		END
		IF(@strTableName = 'tblSTstgRebatesRJReynolds')
		BEGIN
			IF EXISTS (SELECT 1 FROM tblSTstgRebatesRJReynolds)
			BEGIN
				SET @CreateCSV = 1
			END
		END


		--Convert table to CSV
		IF(@CreateCSV = 1)
		BEGIN			
				DECLARE @intMin int, @intMax int

				SET @strCSV = ''

				---------------------------------------------------CSV HEADER FOR PM MORRIS---------------------------------------------------
				IF(@strTableName = 'tblSTstgRebatesPMMorris')
				BEGIN
					DECLARE @intNumberOfRecords int
					DECLARE @intSoldQuantity int
					DECLARE @dblFinalSales decimal(10, 2)

					--Get total number of records
					SELECT @intNumberOfRecords = COUNT(*) FROM tblSTstgRebatesPMMorris

					--Get total quantity sold
					SELECT @intSoldQuantity = SUM(intQuantitySold) FROM tblSTstgRebatesPMMorris

					--Get sum of the final sales price field
					SELECT @dblFinalSales = SUM(dblFinalSalesPrice) FROM tblSTstgRebatesPMMorris

					SET @strCSV = CAST(@intNumberOfRecords as NVARCHAR(50)) + '|' + CAST(@intSoldQuantity as NVARCHAR(50)) + '|' + CAST(@dblFinalSales as NVARCHAR(50)) + '|'
				END
				---------------------------------------------------CSV HEADER FOR PM MORRIS---------------------------------------------------

				DECLARE @intLoopCount int = 0

				--START tblSTstgRebatesPMMorris
				IF(@strTableName = 'tblSTstgRebatesPMMorris')
				BEGIN
					--GET values
					SELECT @intMin = MIN(intPMMId), @intMax = MAX(intPMMId)
					FROM tblSTstgRebatesPMMorris

					SET @intLoopCount = 0

					DECLARE @intManagementOrRetailNumber INT
							, @strWeekEndingDate nvarchar(20)
							, @strTransactionDate nvarchar(20)
							, @strTransactionTime nvarchar(10)
							, @strTransactionIdCode nvarchar(50)
							, @strStoreNumber nvarchar(10)
							, @strStoreName nvarchar(50)
							, @strStoreAddress nvarchar(60)
							, @strStoreCity nvarchar(50)
							, @strStoreState nvarchar(2)
							, @intStoreZipCode int
							, @strCategory nvarchar(20)
							, @strManufacturerName nvarchar(250)
							, @strSKUCode nvarchar(50)
							, @strUpcCode nvarchar(14)
							, @strSkuUpcDescription nvarchar(50)
							, @strUnitOfMeasure nvarchar(20)
							, @intQuantitySold numeric(10, 2)
							, @intConsumerUnits int
							, @strMultiPackIndicator nvarchar(1)
							, @intMultiPackRequiredQuantity int
							, @dblMultiPackDiscountAmount numeric(10, 2)
							, @strRetailerFundedDIscountName nvarchar(20)
							, @dblRetailerFundedDiscountAmount numeric(10, 2)
							, @strMFGDealNameONE nvarchar(20)
							, @dblMFGDealDiscountAmountONE numeric(10, 2)
							, @strMFGDealNameTWO nvarchar(20)
							, @dblMFGDealDiscountAmountTWO numeric(10, 2)
							, @strMFGDealNameTHREE nvarchar(20)
							, @dblMFGDealDiscountAmountTHREE numeric(10, 2)
							, @dblFinalSalesPrice numeric(10, 2)

					WHILE(@intMin <= @intMax)
					BEGIN
						IF EXISTS (SELECT * FROM tblSTstgRebatesPMMorris WHERE intPMMId = @intMin)
						BEGIN
							SELECT @intManagementOrRetailNumber = intManagementOrRetailNumber
								   , @strWeekEndingDate = strWeekEndingDate
								   , @strTransactionDate = strTransactionDate
								   , @strTransactionTime = strTransactionTime
								   , @strTransactionIdCode = strTransactionIdCode
								   , @strStoreNumber = strStoreNumber
								   , @strStoreName = strStoreName
								   , @strStoreAddress = strStoreAddress
								   , @strStoreCity = strStoreCity
								   , @strStoreState = strStoreState
								   , @intStoreZipCode = intStoreZipCode
								   , @strCategory = strCategory
								   , @strManufacturerName = strManufacturerName
								   , @strSKUCode = strSKUCode
								   , @strUpcCode = strUpcCode
								   , @strSkuUpcDescription = strSkuUpcDescription
								   , @strUnitOfMeasure = strUnitOfMeasure
								   , @intQuantitySold = intQuantitySold
								   , @intConsumerUnits = intConsumerUnits
								   , @strMultiPackIndicator = strMultiPackIndicator
								   , @intMultiPackRequiredQuantity = intMultiPackRequiredQuantity
								   , @dblMultiPackDiscountAmount = dblMultiPackDiscountAmount
								   , @strRetailerFundedDIscountName = strRetailerFundedDIscountName
								   , @dblRetailerFundedDiscountAmount = dblRetailerFundedDiscountAmount
								   , @strMFGDealNameONE = strMFGDealNameONE
								   , @dblMFGDealDiscountAmountONE = dblMFGDealDiscountAmountONE
								   , @strMFGDealNameTWO = strMFGDealNameTWO
								   , @dblMFGDealDiscountAmountTWO = dblMFGDealDiscountAmountTWO
								   , @strMFGDealNameTHREE = strMFGDealNameTHREE
								   , @dblMFGDealDiscountAmountTHREE = dblMFGDealDiscountAmountTHREE
								   , @dblFinalSalesPrice = dblFinalSalesPrice
							FROM tblSTstgRebatesPMMorris WHERE intPMMId = @intMin

							--Removed CAST(@intManagementOrRetailNumber as NVARCHAR(20))
							SET @strCSV = @strCSV + CHAR(13) + CAST(@intManagementOrRetailNumber as NVARCHAR(50)) + '|' + CAST(REPLACE(@strWeekEndingDate, '-', '') as NVARCHAR(20)) + '|' + CAST(REPLACE(@strTransactionDate, '-', '') as NVARCHAR(50))
														+ '|' + @strTransactionTime + '|' + @strTransactionIdCode + '|' + @strStoreNumber + '|' + @strStoreName + '|' + @strStoreAddress + '|' + @strStoreCity + '|' + @strStoreState
														+ '|' + CAST(@intStoreZipCode as NVARCHAR(50)) + '|' + @strCategory + '|' + @strManufacturerName + '|' + @strSKUCode + '|' + @strUpcCode + '|' + @strSkuUpcDescription 
														+ '|' + @strUnitOfMeasure + '|' + CAST(@intQuantitySold as NVARCHAR(50)) + '|' + CAST(@intConsumerUnits as NVARCHAR(50)) + '|' + @strMultiPackIndicator 
														+ '|' + CAST(@intMultiPackRequiredQuantity as NVARCHAR(50)) + '|' + CAST(@dblMultiPackDiscountAmount as NVARCHAR(50)) + '|' + @strRetailerFundedDIscountName 
														+ '|' + CAST(@dblRetailerFundedDiscountAmount as NVARCHAR(50)) + '|' + @strMFGDealNameONE + '|' + CAST(@dblMFGDealDiscountAmountONE as NVARCHAR(50)) + '|' + @strMFGDealNameTWO
														+ '|' + CAST(@dblMFGDealDiscountAmountTWO as NVARCHAR(50)) + '|' + @strMFGDealNameTHREE + '|' + CAST(@dblMFGDealDiscountAmountTHREE as NVARCHAR(50)) + '|' + CAST(@dblFinalSalesPrice as NVARCHAR(50))
														--For fields (32-37)
														+ '|' + '' + '|' + '' + '|' + '' + '|' + '' + '|' + '' + '|' + '' + '|'

							SET @intLoopCount = @intLoopCount + 1
						END

						SET @intMin = @intMin + 1
					END
				END
				--END tblSTstgRebatesPMMorris

				-- START tblSTstgRebatesRJReynolds
				IF(@strTableName = 'tblSTstgRebatesRJReynolds')
				BEGIN
					--GET values
					SELECT @intMin = MIN(intRJRId), @intMax = MAX(intRJRId)
					FROM tblSTstgRebatesRJReynolds

					SET @intLoopCount = 0

					DECLARE @strOutletName nvarchar(50)
							, @intOutletNumber int
							, @strOutletAddressOne nvarchar(100)
							, @strOutletAddressTwo nvarchar(100)
							, @strOutletCity nvarchar(50)
							, @strOutletState nvarchar(50)
							, @strOutletZipCode nvarchar(5)
							, @strTransactionDateTime nvarchar(50)
							, @strMarketBasketTransactionId nvarchar(300)
							, @strScanTransactionId nvarchar(300)
							, @strRegisterId nvarchar(300)
							, @intQuantity int
							, @dblPrice decimal(18, 6)
							--, @strUpcCode nvarchar(14)
							, @strUpcDescription nvarchar(100)
							--, @strUnitOfMeasure nvarchar(20)
							, @strPromotionFlag nvarchar(1)
							, @strOutletMultipackFlag nvarchar(1)
							, @intOutletMultipackQuantity int
							, @dblOutletMultipackDiscountAmount decimal(18, 6)
							, @strAccountPromotionName nvarchar(50)
							, @dblAccountDiscountAmount decimal(18, 6)
							, @dblManufacturerDiscountAmount decimal(18, 6)
							, @strCouponPid nvarchar(20)
							, @dblCouponAmount decimal(18, 6)

							, @strManufacturerMultipackFlag nvarchar(1)
							, @intManufacturerMultipackQuantity int
							, @dblManufacturerMultipackDiscountAmount decimal(18,6)
							, @strManufacturerPromotionDescription nvarchar(100)
							, @strManufacturerBuydownDescription nvarchar(100)
							, @dblManufacturerBuydownAmount decimal(18,6)
							, @strManufacturerMultiPackDescription nvarchar(100)
							, @strAccountLoyaltyIDNumber nvarchar(50)
							, @strCouponDescription nvarchar(50)

					WHILE(@intMin <= @intMax)
					BEGIN
						IF EXISTS (SELECT * FROM tblSTstgRebatesRJReynolds WHERE intRJRId = @intMin)
						BEGIN
							SELECT @strOutletName = strOutletName
									, @intOutletNumber = intOutletNumber
									, @strOutletAddressOne = strOutletAddressOne
									, @strOutletAddressTwo = strOutletAddressTwo
									, @strOutletCity = strOutletCity
									, @strOutletState = strOutletState
									, @strOutletZipCode = strOutletZipCode
									, @strTransactionDateTime = strTransactionDateTime
									, @strMarketBasketTransactionId = strMarketBasketTransactionId
									, @strScanTransactionId = strScanTransactionId
									, @strRegisterId = strRegisterId
									, @intQuantity = intQuantity
									, @dblPrice = dblPrice
									, @strUpcCode = strUpcCode
									, @strUpcDescription = strUpcDescription
									, @strUnitOfMeasure = strUnitOfMeasure
									, @strPromotionFlag = strPromotionFlag
									, @strOutletMultipackFlag = strOutletMultipackFlag
									, @intOutletMultipackQuantity = intOutletMultipackQuantity
									, @dblOutletMultipackDiscountAmount = dblOutletMultipackDiscountAmount
									, @strAccountPromotionName = strAccountPromotionName
									, @dblAccountDiscountAmount = dblAccountDiscountAmount
									, @dblManufacturerDiscountAmount = dblManufacturerDiscountAmount
									, @strCouponPid = strCouponPid
									, @dblCouponAmount = dblCouponAmount

									, @strManufacturerMultipackFlag	= strManufacturerMultipackFlag
									, @intManufacturerMultipackQuantity = intManufacturerMultipackQuantity
									, @dblManufacturerMultipackDiscountAmount = dblManufacturerMultipackDiscountAmount
									, @strManufacturerPromotionDescription = strManufacturerPromotionDescription
									, @strManufacturerBuydownDescription = strManufacturerBuydownDescription
									, @dblManufacturerBuydownAmount = dblManufacturerBuydownAmount
									, @strManufacturerMultiPackDescription = strManufacturerMultiPackDescription
									, @strAccountLoyaltyIDNumber = strAccountLoyaltyIDNumber
									, @strCouponDescription = strCouponDescription

							FROM tblSTstgRebatesRJReynolds WHERE intRJRId = @intMin

							SET @strCSV = @strCSV + CHAR(13) + @strOutletName + ',' + CAST(@intOutletNumber as NVARCHAR(20)) + ',' + @strOutletAddressOne + ',' + @strOutletAddressTwo + ',' + @strOutletCity + ',' + @strOutletState + ',' + @strOutletZipCode
														+ ',' + @strTransactionDateTime + ',' + @strMarketBasketTransactionId + ',' + @strScanTransactionId + ',' + @strRegisterId
														+ ',' + CAST(@intQuantity as NVARCHAR(50)) + ',' + CAST(@dblPrice as NVARCHAR(50)) + ',' + @strUpcCode + ',' + @strUpcDescription + ',' + @strUnitOfMeasure + ',' + @strPromotionFlag
														+ ',' + @strOutletMultipackFlag + ',' + CAST(@intOutletMultipackQuantity as NVARCHAR(50)) + ',' + CAST(@dblOutletMultipackDiscountAmount as NVARCHAR(50)) + ',' + @strAccountPromotionName
														+ ',' + CAST(@dblAccountDiscountAmount as NVARCHAR(50)) + ',' + CAST(@dblManufacturerDiscountAmount as NVARCHAR(50))+ ',' + ISNULL(CAST(@strCouponPid as NVARCHAR(20)) ,'') + ',' + CAST(@dblCouponAmount as NVARCHAR(50))
														+ ',' + @strManufacturerMultipackFlag + ',' + CAST(@intManufacturerMultipackQuantity AS NVARCHAR(50)) + ',' + CAST(@dblManufacturerMultipackDiscountAmount AS NVARCHAR(50)) + ',' + @strManufacturerPromotionDescription
														+ ',' + @strManufacturerBuydownDescription + ',' + CAST(@dblManufacturerBuydownAmount AS NVARCHAR(50)) + ',' + @strManufacturerMultiPackDescription + ',' + @strAccountLoyaltyIDNumber + ',' + @strCouponDescription
							
							SET @intLoopCount = @intLoopCount + 1
						END

						SET @intMin = @intMin + 1
					END
				END
				--END tblSTstgRebatesRJReynolds

				--START mark ysnSubmitted = 1 (mark as submitted)
				SELECT @intStoreIdMin = MIN(intStoreId), @intStoreIdMax = MAX(intStoreId)
				FROM @tblStoreIdList

				WHILE(@intStoreIdMin <= @intStoreIdMax)
				BEGIN

					UPDATE tblSTTranslogRebates
					SET ysnSubmitted = 1
					WHERE intStoreId = @intStoreIdMin 
					AND CAST(dtmOpenedTime as DATE) >= @dtmBeginningDate 
					AND CAST(dtmClosedTime as DATE) <= @dtmEndingDate 
					AND ysnSubmitted = 0

					SET @intStoreIdMin = @intStoreIdMin + 1
				END 
				--END mark ysnSubmitted = 1 (mark as submitted)

				SET @strStatusMsg = 'Success'
		END

		ELSE IF(@CreateCSV = 0)
		BEGIN
			SET @strStatusMsg = 'No records found in ' + @strTableName
		END
	
		DECLARE @SQL NVARCHAR(MAX)
		SET @SQL = 'DELETE FROM ' + @strTableName
		EXEC sp_executesql @SQL

	End Try

	Begin Catch
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END