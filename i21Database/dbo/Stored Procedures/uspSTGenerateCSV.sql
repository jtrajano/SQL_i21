CREATE PROCEDURE [dbo].[uspSTGenerateCSV]
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
		SET @strStatusMsg = ''

		--// CREATE storeId table
		DECLARE @tblStoreIdList TABLE (intCount int,intStoreId int)
		

		--// START Insert StoreId to table
		DECLARE @strCharacter CHAR(1)
		SET @strCharacter = ','
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
		--// END Insert StoreId to table


		--// CHECK if stores has address
		IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) AND (strAddress = '' OR strAddress IS NULL))
		BEGIN
			SELECT @strStatusMsg = @strStatusMsg + ',' + strDescription FROM tblSTStore WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) AND (strAddress = '' OR strAddress IS NULL)
			SET @strCSV = ''
			SET @strStatusMsg = @strStatusMsg + ' does not have address'

			RETURN
		END
		--// END CHECK if stores has address


		--// START CHECK if Stores has department
		IF EXISTS(SELECT * FROM tblSTStore WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) AND (strDepartment = '' OR strDepartment IS NULL))
		BEGIN
			SELECT @strStatusMsg = COALESCE(@strStatusMsg + ',','') + strDescription FROM tblSTStore WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) AND (strDepartment = '' OR strDepartment IS NULL)
			SET @strCSV = ''
			SET @strStatusMsg = @strStatusMsg + ' does not have department'
			RETURN
		END
		--// START CHECK if Stores has department

		--// CHECK if has records based on filter
		IF EXISTS (SELECT * FROM tblSTTranslogRebates WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) AND CAST(dtmDate as DATE) >= @dtmBeginningDate AND CAST(dtmDate as DATE) <= @dtmEndingDate AND ysnSubmitted = 0)
		BEGIN
			DECLARE @Delimiter CHAR(1)

			--START tblSTstgRebatesPMMorris
			IF(@strTableName = 'tblSTstgRebatesPMMorris')
			BEGIN
				SET @Delimiter = '|'

				-- GET week ending date (SATURDAY)
				DECLARE @NextDayID INT = 5 -- 0=Mon, 1=Tue, 2=Wed, 3=Thur, 4=Fri, 5=Sat, 6=Sun

				--SELECT @strCSV = COALESCE(@strCSV,'') 
				--	    + CAST(STRT.intRetailAccountNumber AS NVARCHAR(50)) + @Delimiter + CAST(replace(convert(NVARCHAR, DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, @dtmEndingDate) / 7) * 7 + 7, @NextDayID), 111), '/', '') AS NVARCHAR(20)) + @Delimiter
				--	    + CAST(replace(convert(NVARCHAR, TR.dtmDate, 111), '/', '') AS NVARCHAR(20)) + @Delimiter + CAST(convert(NVARCHAR, dtmDate, 108) AS NVARCHAR(20)) + @Delimiter
				--		+ CAST(TR.intTermMsgSN AS NVARCHAR(50))  + @Delimiter + CAST(ST.intStoreNo AS NVARCHAR(50)) + @Delimiter
				--		+ ST.strDescription + @Delimiter + ST.strAddress + @Delimiter
				--		+ ST.strCity + @Delimiter + UPPER(LEFT(ST.strState, 2)) + @Delimiter
				--		+ ST.strZipCode + @Delimiter + strTrlDept + @Delimiter
				--		+ EM.strName + @Delimiter + '' + @Delimiter
				--		+ TR.strTrlUPC + @Delimiter + TR.strTrlDesc + @Delimiter
				--		+ 'PACK' + @Delimiter + (CASE WHEN TR.strTrpPaycode = 'CASH' THEN CAST(TR.dblTrlQty AS NVARCHAR(50)) ELSE '0' END) + @Delimiter
				--		+ '1' + @Delimiter + (CASE WHEN strTrpPaycode = 'CASH' AND TR.dblTrlQty >= 2 THEN 'Y' ELSE 'N' END) + @Delimiter
				--		+ (CASE WHEN TR.strTrpPaycode = 'CASH' THEN CAST(TR.dblTrlQty AS NVARCHAR(50)) ELSE '0' END) + @Delimiter + (CASE WHEN TR.strTrpPaycode = 'CASH' AND TR.dblTrlQty >= 2 THEN '0.50' ELSE '0' END) + @Delimiter
				--	    + (CASE WHEN TR.strTrpPaycode = 'CASH' AND TR.dblTrlQty >= 2 THEN 'Sale' ELSE '' END) + @Delimiter + (CASE WHEN TR.strTrpPaycode = 'CASH' AND TR.dblTrlQty >= 2 THEN '0.50' ELSE '0' END) + @Delimiter
				--		+ (CASE WHEN TR.strTrpPaycode = 'COUPONS' THEN 'Coupon' ELSE '' END) + @Delimiter + (CASE WHEN TR.strTrpPaycode = 'COUPONS' THEN '0.50' ELSE '0' END) + @Delimiter
				--		+ '' + @Delimiter + '0' + @Delimiter
				--		+ '' + @Delimiter + '0' + @Delimiter
				--		+ (CASE WHEN TR.strTrpPaycode = 'CASH' THEN CAST(TR.dblTrlLineTot AS NVARCHAR(50)) ELSE '0' END) + CHAR(13)
				INSERT INTO tblSTstgRebatesPMMorris
				SELECT STRT.intRetailAccountNumber AS intRCN
								, replace(convert(NVARCHAR, DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, @dtmEndingDate) / 7) * 7 + 7, @NextDayID), 111), '/', '') as dtmWeekEndingDate
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
								, EM.strName as strManufacturerName
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
				JOIN tblSTRetailAccount STRT ON STRT.intStoreId = ST.intStoreId AND STRT.intEntityId = @intVendorId
				JOIN tblEMEntity EM ON EM.intEntityId = @intVendorId
				WHERE TR.intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) 
				AND CAST(TR.dtmDate as DATE) >= @dtmBeginningDate 
				AND CAST(TR.dtmDate as DATE) <= @dtmEndingDate 
				AND ysnSubmitted = 0
				AND strTrlDept COLLATE DATABASE_DEFAULT IN (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId IN (SELECT Item FROM dbo.fnSTSeparateStringToColumns(ST.strDepartment, ',')))

				SET @strStatusMsg = 'Success'
			END
			--END tblSTstgRebatesPMMorris


			-- START tblSTstgRebatesRJReynolds
			IF(@strTableName = 'tblSTstgRebatesRJReynolds')
			BEGIN
				SET @Delimiter = ','
					--SELECT @strCSV = COALESCE(@strCSV,'') 
					--		+ (CASE WHEN ST.strDescription IS NULL THEN '' ELSE REPLACE(ST.strDescription, ',', ' ') END) + @Delimiter + CAST(ST.intStoreNo AS NVARCHAR(20)) + @Delimiter
					--		+ (CASE WHEN ST.strAddress IS NULL THEN '' ELSE REPLACE(ST.strAddress, ',', ' ') END) + @Delimiter + '' + @Delimiter
					--		+ (CASE WHEN ST.strCity IS NULL THEN '' ELSE ST.strCity END) + @Delimiter + UPPER(LEFT(ST.strState, 2)) + @Delimiter
					--		+ (CASE WHEN ST.strZipCode IS NULL THEN '' ELSE ST.strZipCode END) + @Delimiter + CAST(replace(convert(NVARCHAR, dtmDate, 120), ' ', '-') AS NVARCHAR(20)) + @Delimiter
					--		+ CAST(intTermMsgSN AS NVARCHAR(50)) + @Delimiter + CAST(intScanTransactionId AS NVARCHAR(20)) + @Delimiter
					--		+ CAST(intTrTickNumPosNum AS NVARCHAR(50)) + @Delimiter + CAST(dblTrlQty as NVARCHAR(50)) + @Delimiter
					--		+ CAST(dblTrlLineTot AS NVARCHAR(50)) + @Delimiter + strTrlUPC + @Delimiter
					--		+ REPLACE(strTrlDesc, ',', ' ') + @Delimiter + 'PACK' + @Delimiter
					--		+ (CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'Y' ELSE 'N' END) + @Delimiter + CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'Y' ELSE 'N' END + @Delimiter
					--		+ CAST(CASE WHEN strTrpPaycode IN ('COUPONS') THEN (CASE WHEN dblTrlQty > 1 THEN dblTrlQty ELSE 2 END) ELSE 0 END AS NVARCHAR(50)) + @Delimiter + CAST((CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END) AS NVARCHAR(50)) + @Delimiter
					--		+ (CASE WHEN strTrpPaycode IN ('COUPONS') THEN 'COUPONS' ELSE '' END) + @Delimiter + (CASE WHEN strTrpPaycode IN ('COUPONS') THEN CAST(dblTrpAmt AS NVARCHAR(50)) ELSE '0' END) + @Delimiter
					--		+ (CASE WHEN strTrpPaycode IN ('COUPONS') THEN CAST(dblTrpAmt AS NVARCHAR(50)) ELSE '0' END) + @Delimiter + (CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpPaycode ELSE '' END) + @Delimiter
					--		+ (CASE WHEN strTrpPaycode IN ('COUPONS') THEN CAST(dblTrpAmt AS NVARCHAR(50)) ELSE '0' END) + @Delimiter + 'N' + @Delimiter
					--		+ '0' + @Delimiter + '0' + @Delimiter 
					--		+ (CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpPaycode ELSE '' END) + @Delimiter + '' + @Delimiter
					--		+ '0' + @Delimiter + '' + @Delimiter 
					--		+ TR.strTrLoyaltyProgramTrloAccount + @Delimiter + TR.strTrLoyaltyProgramProgramID + @Delimiter
					--		+ CHAR(13)
					INSERT INTO tblSTstgRebatesRJReynolds
					SELECT CASE WHEN ST.strDescription IS NULL THEN '' ELSE REPLACE(ST.strDescription, ',', ' ') END as strOutletName
								, ST.intStoreNo as intOutletNumber
								, CASE WHEN ST.strAddress IS NULL THEN '' ELSE REPLACE(ST.strAddress, ',', ' ') END as strOutletAddressOne
								, '' as strOutletAddressTwo
								, CASE WHEN ST.strCity IS NULL THEN '' ELSE ST.strCity END as strOutletCity
								, UPPER(LEFT(ST.strState, 2)) as strOutletState
								,  CASE WHEN ST.strZipCode IS NULL THEN '' ELSE ST.strZipCode END as strOutletZipCode
								--, FORMAT(CAST(dtmDate AS datetime), 'yyyy-MM-dd-HH:mm:ss') as strTransactionDateTime
								, replace(convert(NVARCHAR, dtmDate, 120), ' ', '-') as strTransactionDateTime
								, CAST(intTermMsgSN AS NVARCHAR(50)) as strMarketBasketTransactionId

								--, ROW_NUMBER() OVER(PARTITION BY intTermMsgSN, strTrpPaycode ORDER BY intTranslogId) as strScanTransactionId
								, CAST(intScanTransactionId AS NVARCHAR(20)) as strScanTransactionId

								, CAST(intTrTickNumPosNum AS NVARCHAR(50)) as strRegisterId
								, dblTrlQty as intQuantity
								, dblTrlLineTot as dblPrice
								, strTrlUPC as strUpcCode
								, REPLACE(strTrlDesc, ',', ' ') as strUpcDescription
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
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpPaycode ELSE '' END as strCouponPid
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN dblTrpAmt ELSE 0 END as dblCouponAmount

								, 'N' as strManufacturerMultipackFlag
								, 0 as intManufacturerMultipackQuantity
								, 0 as dblManufacturerMultipackDiscountAmount
								, CASE WHEN strTrpPaycode IN ('COUPONS') THEN strTrpPaycode ELSE '' END as strManufacturerPromotionDescription
								, '' as strManufacturerBuydownDescription
								, 0 as dblManufacturerBuydownAmount
								, '' as strManufacturerMultiPackDescription
								, TR.strTrLoyaltyProgramTrloAccount as strAccountLoyaltyIDNumber
								, TR.strTrLoyaltyProgramProgramID as strCouponDescription
					FROM tblSTTranslogRebates TR
					JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
					WHERE TR.intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) 
					AND CAST(TR.dtmDate as DATE) >= @dtmBeginningDate
					AND CAST(TR.dtmDate as DATE) <= @dtmEndingDate
					AND ysnSubmitted = 0
					AND strTrLineType = 'plu'
					AND strTrlDept COLLATE DATABASE_DEFAULT IN (SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId IN (SELECT Item FROM dbo.fnSTSeparateStringToColumns(ST.strDepartment, ',')))

					SET @strStatusMsg = 'Success'
			END
		END


			IF(@strStatusMsg = 'Success')
			BEGIN
				--START mark ysnSubmitted = 1 (mark as submitted)
				UPDATE tblSTTranslogRebates
					SET ysnSubmitted = 1
					WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList)
					AND CAST(dtmDate as DATE) >= @dtmBeginningDate
					AND CAST(dtmDate as DATE) <= @dtmEndingDate
					AND ysnSubmitted = 0
				--END mark ysnSubmitted = 1 (mark as submitted)	
			END


		ELSE IF NOT EXISTS (SELECT * FROM tblSTTranslogRebates WHERE intStoreId IN (SELECT intStoreId FROM @tblStoreIdList) AND CAST(dtmDate as DATE) >= @dtmBeginningDate AND CAST(dtmDate as DATE) <= @dtmEndingDate AND ysnSubmitted = 0)
		BEGIN
			SET @strStatusMsg = 'No transaction log found based on filter'
		END
		
		IF(@strTableName = 'tblSTstgRebatesPMMorris')
		BEGIN
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

					SET @strCSV = CAST(@intNumberOfRecords as NVARCHAR(50)) + '|' + CAST(@intSoldQuantity as NVARCHAR(50)) + '|' + CAST(@dblFinalSales as NVARCHAR(50)) + '|' + CHAR(13)
				END
				---------------------------------------------------CSV HEADER FOR PM MORRIS---------------------------------------------------

			SELECT * FROM tblSTstgRebatesPMMorris
		END
		ELSE IF(@strTableName = 'tblSTstgRebatesRJReynolds')
		BEGIN
			SELECT * FROM tblSTstgRebatesRJReynolds
		END
		

		DECLARE @SQL NVARCHAR(MAX)
		SET @SQL = 'DELETE FROM ' + @strTableName
		EXEC sp_executesql @SQL

		

	End Try

	Begin Catch
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END