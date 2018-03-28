﻿CREATE PROCEDURE [dbo].[uspSTGenerateCSV]
@intVendorId int,
@strStoreIdList NVARCHAR(MAX),
@dtmBeginningDate datetime,
@dtmEndingDate datetime,
@strTableName nvarchar(200),
@strStatusMsg NVARCHAR(1000) OUTPUT,
@strCSVHeader NVARCHAR(MAX) OUTPUT,
@intVendorAccountNumber INT OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @strStatusMsg = ''
		DECLARE @intCountAccountNumber AS INT = 0
		SET @intVendorAccountNumber = 0

		----// START Validate selected date total to 7days
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
		----// END Validate selected date total to 7days


		----// START Validate Start and Ending date
		IF(@strTableName = 'tblSTstgRebatesPMMorris')
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
		ELSE IF(@strTableName = 'tblSTstgRebatesRJReynolds')
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
		----// END Validate Start and Ending date




		----// START PM Morris File format validation
		IF(@strTableName = 'tblSTstgRebatesPMMorris')
		BEGIN
			SELECT @intCountAccountNumber = COUNT(DISTINCT intRetailAccountNumber) 
			FROM tblSTRetailAccount
			WHERE intEntityId = @intVendorId
			AND intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))

			IF(@intCountAccountNumber >= 2)
			BEGIN
				SET @strCSVHeader = ''
				SET @intVendorAccountNumber = 0
				SET @strStatusMsg = 'Selected Store does not have the same Chain Account Number'

				RETURN
			END
			ELSE IF(@intCountAccountNumber = 1)
			BEGIN
				SELECT @intVendorAccountNumber = intRetailAccountNumber
				FROM tblSTRetailAccount
				WHERE intEntityId = @intVendorId
				AND intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))
			END
		END
		----// END PM Morris File format validation



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
				[intQuantitySold] numeric(10, 2) NULL,
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
				[strCouponDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
		)

		--// CHECK if stores has address
		IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) AND (strAddress = '' OR strAddress IS NULL))
		BEGIN
			SELECT @strStatusMsg = @strStatusMsg + ',' + strDescription FROM tblSTStore WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) AND (strAddress = '' OR strAddress IS NULL)
			SET @strCSVHeader = ''
			SET @intVendorAccountNumber = 0
			SET @strStatusMsg = @strStatusMsg + ' does not have address'

			RETURN
		END
		--// END CHECK if stores has address

		--// START CHECK if Stores has department
		IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) AND (strDepartment = '' OR strDepartment IS NULL))
		BEGIN
			SELECT @strStatusMsg = COALESCE(@strStatusMsg + ',','') + strDescription FROM tblSTStore WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) AND (strDepartment = '' OR strDepartment IS NULL)
			SET @strCSVHeader = ''
			SET @intVendorAccountNumber = 0
			SET @strStatusMsg = @strStatusMsg + ' does not have department'
			RETURN
		END
		--// START CHECK if Stores has department



		--// CHECK if has records based on filter
		IF EXISTS (SELECT * FROM tblSTTranslogRebates WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) AND CAST(dtmDate as DATE) >= @dtmBeginningDate AND CAST(dtmDate as DATE) <= @dtmEndingDate AND ysnSubmitted = 0)
		BEGIN
			DECLARE @Delimiter CHAR(1)

			--START tblSTstgRebatesPMMorris
			IF(@strTableName = 'tblSTstgRebatesPMMorris')
			BEGIN

				SET @Delimiter = '|'

				---- START Validate if selected dates completes a aweek
				--DECLARE @intCountDays AS INT = DATEDIFF(DAY, @dtmBeginningDate, @dtmEndingDate) + 1
				
				--IF(@intCountDays < 7)
				--BEGIN
				--	SET @strStatusMsg = 'The selected dates should complete 1 week of data transaction, you only selected ' + CAST(@intCountDays AS NVARCHAR(10)) + ' days of transaction data'
				--	RETURN
				--END
				--ELSE IF(@intCountDays > 7)
				--BEGIN
				--	SET @strStatusMsg = 'The selected dates have more than a week of transaction data, you selected ' + CAST(@intCountDays AS NVARCHAR(10)) + ' days, It should only have 1 week'
				--	RETURN
				--END

				-- END Validate if selected dates completes a aweek

				-- GET week ending date (SATURDAY)
				-- DECLARE @NextDayID INT = 5 -- 0=Mon, 1=Tue, 2=Wed, 3=Thur, 4=Fri, 5=Sat, 6=Sun

				INSERT INTO @tblTempPMM
				SELECT DISTINCT @intVendorAccountNumber intRCN   --STRT.intRetailAccountNumber AS intRCN
								--, replace(convert(NVARCHAR, DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, @dtmBeginningDate) / 7) * 7 + 7, @NextDayID), 111), '/', '') as dtmWeekEndingDate
								, replace(convert(NVARCHAR, @dtmEndingDate, 111), '/', '') as dtmWeekEndingDate
								, replace(convert(NVARCHAR, dtmDate, 111), '/', '') as dtmTransactionDate 
								, convert(NVARCHAR, dtmDate, 108) as strTransactionTime
								, intTermMsgSN as strTransactionIdCode

								, ST.intStoreNo as strStoreNumber
								, ST.strDescription as strStoreName
								, REPLACE(REPLACE(REPLACE(REPLACE(ST.strAddress, CHAR(10), ''), CHAR(13), ''), @Delimiter, ''), ',', '') as strStoreAddress
								, ST.strCity as strStoreCity
								, UPPER(LEFT(ST.strState, 2)) as strStoreState
								, ST.strZipCode as intStoreZipCode

								--, REPLACE(REPLACE(REPLACE(REPLACE(STMAP.strAddress, CHAR(10), ''), CHAR(13), ''), @Delimiter, ''), ',', '') as strStoreAddress
								--, STMAP.strCity as strStoreCity
								--, UPPER(LEFT(STMAP.strState, 2)) as strStoreState
								--, STMAP.strZipCode as intStoreZipCode

								, strTrlDept as strCategory
								, EM.strName as strManufacturerName
								, strTrlUPC as strSKUCode --14
								, strTrlUPC as strUpcCode
								, strTrlDesc as strSkuUpcDescription
								, 'PACK' as strUnitOfMeasure
								, CAST(CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlQty ELSE 0 END as INT) as intQuantitySold
								, 1 as intConsumerUnits

								--, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 'Y' ELSE 'N' END as strMultiPackIndicator
								--, CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlQty ELSE 0 END as intMultiPackRequiredQuantity
								--, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 0.50 ELSE 0 END as dblMultiPackDiscountAmount
								, 'N' as strMultiPackIndicator
								, 0 as intMultiPackRequiredQuantity
								, 0 as dblMultiPackDiscountAmount

								, REPLACE(CRP.strProgramName, ',','') as strRetailerFundedDiscountName
								, CRP.dblManufacturerBuyDownAmount as dblRetailerFundedDiscountAmount
								, CASE WHEN strTrpPaycode = 'COUPONS' THEN 'Coupon' ELSE '' END as strMFGDealNameONE
								, CASE WHEN strTrpPaycode = 'COUPONS' THEN 0.50 ELSE 0 END as dblMFGDealDiscountAmountONE
								, '' as strMFGDealNameTWO
								, 0 as dblMFGDealDiscountAmountTWO
								, '' as strMFGDealNameTHREE
								, 0 as dblMFGDealDiscountAmountTHREE
								, CASE WHEN CRP.strProgramName IS NOT NULL THEN 0
										WHEN strTrpPaycode = 'CASH' THEN dblTrlLineTot 
										ELSE 0 END as dblFinalSalesPrice
								
								--Optional Fields
								, NULL AS intStoreTelephone
								, '' AS strStoreContactName
								, '' strStoreContactEmail
								, '' strProductGroupingCode
								, '' strProductGroupingName
								, '' strLoyaltyIDRewardsNumber
				FROM 
				(
					SELECT * FROM
						(   
							SELECT *, ROW_NUMBER() OVER (PARTITION BY intTermMsgSN, intScanTransactionId ORDER BY strTrpPaycode DESC) AS rn
							FROM tblSTTranslogRebates
						) TRR 
						WHERE TRR.rn = 1
						AND CAST(TRR.dtmDate AS DATE) BETWEEN @dtmBeginningDate AND @dtmEndingDate
				) TR
				JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
				JOIN tblSTRetailAccount STRT ON STRT.intStoreId = ST.intStoreId AND STRT.intEntityId = @intVendorId
				JOIN tblEMEntity EM ON EM.intEntityId = @intVendorId
				JOIN tblAPVendor APV ON APV.intEntityId = EM.intEntityId
				--JOIN tblSTStore STMAP ON STMAP.intStoreId = APV.intStoreStoreId
				LEFT JOIN vyuSTCigaretteRebatePrograms CRP ON TR.strTrlUPC = CRP.strLongUPCCode 
						AND (CAST(TR.dtmDate AS DATE) BETWEEN CRP.dtmStartDate AND CRP.dtmEndDate)
						AND TR.strTrpPaycode IN ('Change', 'CREDIT')
				LEFT JOIN
				(
					SELECT [intID] 
					FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)
					GROUP BY [intID]
				) x ON x.intID IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](CRP.strStoreIdList))
				WHERE TR.intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) 
				AND ysnSubmitted = 0
				AND strTrlDept COLLATE DATABASE_DEFAULT IN (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId IN (SELECT Item FROM dbo.fnSTSeparateStringToColumns(ST.strDepartment, ',')))


				-- Check if has record
				IF EXISTS(select * from @tblTempPMM)
				BEGIN
					SET @strStatusMsg = 'Success'
				END
				ELSE
				BEGIN
					SET @strStatusMsg = 'No record found'
				END
			END
			--END tblSTstgRebatesPMMorris


			-- START tblSTstgRebatesRJReynolds
			IF(@strTableName = 'tblSTstgRebatesRJReynolds')
			BEGIN
				SET @Delimiter = ','


					INSERT INTO @tblTempRJR
					SELECT DISTINCT (CASE WHEN ST.strDescription IS NULL THEN '' ELSE REPLACE(ST.strDescription, @Delimiter, '') END) as strOutletName
								, ST.intStoreNo as intOutletNumber
								, REPLACE(REPLACE(REPLACE(ST.strAddress, CHAR(10), ''), CHAR(13), ''), @Delimiter, '') as strOutletAddressOne
								, '' as strOutletAddressTwo
								, CASE WHEN ST.strCity IS NULL THEN '' ELSE REPLACE(ST.strCity, @Delimiter, '') END as strOutletCity
								, UPPER(LEFT(ST.strState, 2)) as strOutletState
								,  CASE WHEN ST.strZipCode IS NULL THEN '' ELSE ST.strZipCode END as strOutletZipCode
								, replace(convert(NVARCHAR, dtmDate, 120), ' ', '-') as strTransactionDateTime
								, CAST(intTermMsgSN AS NVARCHAR(50)) as strMarketBasketTransactionId
								, CAST(intScanTransactionId AS NVARCHAR(20)) as strScanTransactionId
								, CAST(intTrTickNumPosNum AS NVARCHAR(50)) as strRegisterId
								, dblTrlQty as intQuantity
								, dblTrlUnitPrice as dblPrice
								, strTrlUPC as strUpcCode
								, REPLACE(strTrlDesc, ',', ' ') as strUpcDescription
								, 'PACK' as strUnitOfMeasure
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'Y' ELSE 'N' END as strPromotionFlag

								, CASE WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer')
									THEN 'Y' ELSE 'N' END as strOutletMultipackFlag
								, CASE WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer')
									THEN dblTrlMatchLineTrlMatchQuantity ELSE 0 END as intOutletMultipackQuantity
									--(CASE WHEN dblTrlQty > 1 THEN dblTrlQty ELSE 2 END)
								  --ELSE 0 END as intOutletMultipackQuantity
								, CASE WHEN strTrlMatchLineTrlPromotionIDPromoType IN ('mixAndMatchOffer', 'combinationOffer')
									THEN dblTrlMatchLineTrlPromoAmount ELSE 0 END as dblOutletMultipackDiscountAmount

								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'COUPONS' ELSE '' END as strAccountPromotionName --21
								--, CASE WHEN strTrlDesc like '% OFF%' THEN strTrlDesc ELSE '' END as strAccountPromotionName --21

								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblAccountDiscountAmount --22

								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblManufacturerDiscountAmount

								, CASE WHEN strTrpPaycode = 'COUPONS' AND strTrlMatchLineTrlPromotionIDPromoType IS NULL AND strTrlUPCEntryType = 'scanned'
									THEN strTrlUPC ELSE '' END as strCouponPid --24
								, CASE WHEN strTrpPaycode = 'COUPONS' AND strTrlMatchLineTrlPromotionIDPromoType IS NULL AND strTrlUPCEntryType = 'scanned'
									THEN dblTrpAmt ELSE 0 END as dblCouponAmount --25

								, 'N' as strManufacturerMultipackFlag
								, 0 as intManufacturerMultipackQuantity
								, 0 as dblManufacturerMultipackDiscountAmount
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpPaycode ELSE '' END as strManufacturerPromotionDescription
								, REPLACE(CRP.strProgramName, ',','') as strManufacturerBuydownDescription
								, CRP.dblManufacturerBuyDownAmount as dblManufacturerBuydownAmount
								, '' as strManufacturerMultiPackDescription
								, TR.strTrLoyaltyProgramTrloAccount as strAccountLoyaltyIDNumber
								, TR.strTrLoyaltyProgramProgramID as strCouponDescription
					FROM 
					(   
						SELECT * FROM
						(   
							SELECT *, ROW_NUMBER() OVER (PARTITION BY intTermMsgSN, intScanTransactionId ORDER BY strTrpPaycode DESC) AS rn
							FROM tblSTTranslogRebates
							WHERE ysnSubmitted = 0
							AND intStoreId IN (SELECT DISTINCT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))
						) TRR 
						WHERE TRR.rn = 1
						AND CAST(TRR.dtmDate AS DATE) BETWEEN @dtmBeginningDate AND @dtmEndingDate
					) TR
					JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
					LEFT JOIN vyuSTCigaretteRebatePrograms CRP ON TR.strTrlUPC = CRP.strLongUPCCode 
						AND (CAST(TR.dtmDate AS DATE) BETWEEN CRP.dtmStartDate AND CRP.dtmEndDate)
					--LEFT JOIN
					--(
					--	SELECT DISTINCT [intID] 
					--	FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)
					--	GROUP BY [intID]
					--) x ON x.intID IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](CRP.strStoreIdList))
					WHERE TR.strTrlDept COLLATE DATABASE_DEFAULT IN (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId IN (SELECT Item FROM dbo.fnSTSeparateStringToColumns(ST.strDepartment, ',')))


					-- Check if has record
					IF EXISTS(select * from @tblTempRJR)
					BEGIN
						SET @strStatusMsg = 'Success'
					END
					ELSE
					BEGIN
						SET @strStatusMsg = 'No record found'
					END
			END
			--END tblSTstgRebatesRJReynolds
		END


		IF(@strStatusMsg = 'Success')
		BEGIN
			--START mark ysnSubmitted = 1 (mark as submitted)
			UPDATE tblSTTranslogRebates
				SET ysnSubmitted = 1
				WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))
				AND CAST(dtmDate as DATE) >= @dtmBeginningDate
				AND CAST(dtmDate as DATE) <= @dtmEndingDate
				AND ysnSubmitted = 0
			--END mark ysnSubmitted = 1 (mark as submitted)	
		END
		--ELSE IF NOT EXISTS (SELECT * FROM tblSTTranslogRebates WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) AND CAST(dtmDate as DATE) >= @dtmBeginningDate AND CAST(dtmDate as DATE) <= @dtmEndingDate AND ysnSubmitted = 0)
		ELSE
		BEGIN
			SET @strStatusMsg = 'No transaction log found based on filter'
			SET @strCSVHeader = ''
			SET @intVendorAccountNumber = 0
			
			RETURN
		END


		IF(@strTableName = 'tblSTstgRebatesPMMorris')
		BEGIN
				---------------------------------------------------CSV HEADER FOR PM MORRIS---------------------------------------------------
					DECLARE @intNumberOfRecords int = 0
					DECLARE @intSoldQuantity int = 0
					DECLARE @dblFinalSales decimal(10, 2) = 0

					--Get total number of records
					SELECT @intNumberOfRecords = COUNT(*) FROM @tblTempPMM

					--Get total quantity sold
					SELECT @intSoldQuantity = SUM(intQuantitySold) FROM @tblTempPMM


					--Get sum of the final sales price field
					SELECT @dblFinalSales = SUM(dblFinalSalesPrice) FROM @tblTempPMM


					SET @strCSVHeader = CAST(ISNULL(@intNumberOfRecords, 0) as NVARCHAR(50)) + '|' + CAST(ISNULL(@intSoldQuantity, 0) as NVARCHAR(50)) + '|' + CAST(ISNULL(@dblFinalSales, 0) as NVARCHAR(50)) + CHAR(13)
				---------------------------------------------------CSV HEADER FOR PM MORRIS---------------------------------------------------

			SELECT * FROM @tblTempPMM
			ORDER BY CAST(strStoreNumber AS INT) ASC
		END
		ELSE IF(@strTableName = 'tblSTstgRebatesRJReynolds')
		BEGIN
			SELECT * FROM @tblTempRJR
			ORDER BY intOutletNumber ASC
		END
		

		DECLARE @SQL NVARCHAR(MAX)
		SET @SQL = 'DELETE FROM ' + @strTableName
		EXEC sp_executesql @SQL

	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END