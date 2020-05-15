CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
	@intCheckoutId Int,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows int OUTPUT
AS
BEGIN
	Begin Try

		DECLARE @intTableRowCount AS INT = 0
		SELECT @intTableRowCount = COUNT(*) FROM #tempCheckoutInsert

		IF(@intTableRowCount > 0)
		BEGIN
			--Get StoreId
			DECLARE @intStoreId int
			SELECT @intStoreId = intStoreId 
			FROM tblSTCheckoutHeader 
			WHERE intCheckoutId = @intCheckoutId

			-------------------------------------------START GET Department
			----// Get Department Id from Store
			--DECLARE @strDepartments AS NVARCHAR(MAX)
			--SELECT @strDepartments = strDepartment 
			--FROM tblSTStore
			--WHERE intStoreId = @intStoreId

			--IF(@strDepartments = '')
			--BEGIN
			--	SET @intCountRows = 0
			--	SET @strStatusMsg = 'Store does not have setup for Tobacco Department'
			--	RETURN
			--END


			--// Create Temp table
			DECLARE @TempTableDepartments TABLE 
			(
			    intRegisterDepartmentId INT
				, strCategoryCode NVARCHAR(100)
			)

			INSERT INTO @TempTableDepartments
			(
				intRegisterDepartmentId
				, strCategoryCode
			)
			SELECT 
				CatLoc.intRegisterDepartmentId
				, Category.strCategoryCode
			FROM tblSTStoreRebates Rebates
			INNER JOIN tblSTStore Store
				ON Rebates.intStoreId = Store.intStoreId
			INNER JOIN tblICCategory Category
				ON Rebates.intCategoryId = Category.intCategoryId
			INNER JOIN tblICCategoryLocation CatLoc
				ON Category.intCategoryId = CatLoc.intCategoryId
				AND Store.intCompanyLocationId = CatLoc.intLocationId
			WHERE Store.intStoreId = @intStoreId

			IF NOT EXISTS(SELECT TOP 1 1 FROM @TempTableDepartments)
			BEGIN
				SET @intCountRows = 0
				SET @strStatusMsg = 'Store does not have setup for Tobacco Department'
				RETURN
			END

			----// Create dynamic sqlQuery
			--DECLARE @strDynamicQuery as NVARCHAR(MAX)
			--SET @strDynamicQuery = 'SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId IN (' + @strDepartments + ')'

			----// Insert to tempTable
			--INSERT @TempTableDepartments
			--EXEC (@strDynamicQuery)

			--IF NOT EXISTS (SELECT * FROM @TempTableDepartments)
			--BEGIN
			--	SET @intCountRows = 0
			--	SET @strStatusMsg = 'Tobacco department does not exist'
			--	RETURN
			--END
			-------------------------------------------END GET Department

			-- Check if department exist in XML file
			IF NOT EXISTS(SELECT COUNT(c.termMsgSN) FROM #tempCheckoutInsert c 
			              WHERE c.TrlDeptNumber IN (SELECT intRegisterDepartmentId FROM @TempTableDepartments) 
			              AND (c.transtype = 'sale' OR c.transtype = 'network sale') GROUP BY c.termMsgSN)
			BEGIN
				SET @intCountRows = 0
				SET @strStatusMsg = 'Store department does not exists in register file'
				RETURN
			END

			-- Check if has records
			IF EXISTS(SELECT COUNT(intTranslogId) FROM tblSTTranslogRebates)
				BEGIN
					--Get Number of rows
					SELECT @intCountRows = COUNT(*) 
					FROM #tempCheckoutInsert chk
					JOIN
					(
						SELECT c.termMsgSN as termMsgSN
						FROM #tempCheckoutInsert c
						WHERE c.TrlDeptNumber IN (SELECT intRegisterDepartmentId FROM @TempTableDepartments) 
						AND (c.transtype = 'sale' OR c.transtype = 'network sale')
						AND c.date != ''
						GROUP BY c.termMsgSN
					) x ON x.termMsgSN = chk.termMsgSN
					WHERE NOT EXISTS
					(
						SELECT * 
							FROM dbo.tblSTTranslogRebates TR
							WHERE TR.dtmDate = CAST(left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6) AS DATETIME)
							AND TR.intTermMsgSNterm = chk.termMsgSNterm
							AND TR.intTermMsgSN = chk.termMsgSN 
							AND TR.intTrTickNumPosNum = chk.posNum 
							AND TR.intTrTickNumTrSeq  = chk.trSeq
							AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.transtype COLLATE DATABASE_DEFAULT
							AND TR.intStoreNumber = chk.storeNumber
					)
					AND chk.date != ''
				END
			ELSE
				BEGIN
					SELECT @intCountRows = COUNT(c.termMsgSN)
					FROM #tempCheckoutInsert c 
					WHERE c.TrlDeptNumber IN (SELECT intRegisterDepartmentId FROM @TempTableDepartments) 
					AND (c.transtype = 'sale' OR c.transtype = 'network sale')
					AND c.date != ''
					GROUP BY c.termMsgSN
				END

			--PRINT 'Rows count: ' + Cast(@intCountRows as nvarchar(50))

			IF(@intCountRows > 0)
			BEGIN
				INSERT INTO dbo.tblSTTranslogRebates 
				(
					[dtmOpenedTime]
				   ,[dtmClosedTime]
				   ,[dblInsideSales]
				   ,[dblInsideGrand]
				   ,[dblOutsideSales]
				   ,[dblOutsideGrand]
				   ,[dblOverallSales]
				   ,[dblOverallGrand]

				   ,[strTransType]
				   ,[strTransRecalled]
				   ,[strTransRollback]
				   ,[strTransFuelPrepayCompletion]
				   ,[strTermMsgSNtype]
				   ,[intTermMsgSNterm]

				   ,[intScanTransactionId]

				   ,[intTermMsgSN]
				   ,[intPeriodLevel]
				   ,[intPeriodSeq]
				   ,[strPeriodName]
				   ,[dtmDate]
				   ,[intDuration]
				   ,[intTill]
				   ,[intCashierSysId]
				   ,[intCashierEmpNum]
				   ,[intCashierPosNum]
				   ,[intCashierPeriod]
				   ,[intCashierDrawer]
				   ,[strCashier]     
				   ,[intOriginalCashierSysid]
				   ,[intOriginalCashierEmpNum]
				   ,[intOriginalCashierPosNum]
				   ,[intOriginalCashierPeriod]
				   ,[intOriginalCashierDrawer]
				   ,[strOriginalCashier]
				   ,[intStoreNumber]
				   ,[dblCoinDispensed]
				   ,[strPopDiscTran]
				   ,[strTrFuelOnlyCst]
				   ,[intTrTickNumPosNum] --
				   ,[intTrTickNumTrSeq]  --
				   ,[dblTrValueTrTotNoTax]
				   ,[dblTrValueTrTotWTax]
				   ,[dblTrValueTrTotTax]
				   ,[strTrCurrTotLocale]
				   ,[dblTrCurrTot]
				   ,[dblTrSTotalizer]
				   ,[dblTrGTotalizer]
				   ,[strCustDOB]
				   ,[dblRecallAmt]
				   ,[intTaxAmtsTaxAmtSysid]
				   ,[strTaxAmtsTaxAmtCat]
				   ,[dblTaxAmtsTaxAmt]
				   ,[intTaxAmtsTaxRateSysid]
				   ,[strTaxAmtsTaxRateCat]
				   ,[dblTaxAmtsTaxRate]
				   ,[intTaxAmtsTaxNetSysid]
				   ,[strTaxAmtsTaxNetCat]
				   ,[dblTaxAmtsTaxNet]
				   ,[intTaxAmtsTaxAttributeSysid]
				   ,[strTaxAmtsTaxAttributeCat]
				   ,[dblTaxAmtsTaxAttribute]
				   ,[dblTrFstmpTrFstmpTot]
				   ,[dblTrFstmpTrFstmpTax]
				   ,[dblTrFstmpTrFstmpChg]
				   ,[dblTrFstmpTrFstmpTnd]
				   ,[dblTrCshBkAmtMop]
				   ,[dblTrCshBkAmtCat]
				   ,[dblTrCshBkAmt]
				   --,[intTrExNetProdTrENPPcode]
				   --,[dblTrExNetProdTrENPAmount]
				   ,[strTrLoyaltyProgramProgramID]
				   ,[dblTrLoyaltyProgramTrloSubTotal]
				   ,[dblTrLoyaltyProgramTrloAutoDisc]
				   ,[dblTrLoyaltyProgramTrloCustDisc]
				   ,[strTrLoyaltyProgramTrloAccount]
				   ,[strTrLoyaltyProgramTrloEntryMeth]
				   ,[strTrLoyaltyProgramTrloAuthReply]
				   ,[strTrLineType]
				   ,[strTrLineUnsettled]
				   ,[intTrlDeptNumber]
				   ,[strTrlDeptType]
				   ,[strTrlDept]
				   ,[strTrlNetwCode]
				   ,[dblTrlQty]
				   ,[dblTrlSign]
				   ,[dblTrlSellUnitPrice]
				   ,[dblTrlUnitPrice]
				   ,[dblTrlLineTot]
				   ,[strTrlDesc]
				   ,[strTrlUPC]
				   ,[strTrlModifier]
				   ,[strTrlUPCEntryType]
				   ,[strTrlCatNumber]
				   ,[strTrlCat]
				   ,[intTrlTaxesTrlTaxSysid]
				   ,[strTrlTaxesTrlTaxCat]
				   ,[intTrlTaxesTrlTaxReverse]
				   ,[dblTrlTaxesTrlTax]
				   ,[intTrlTaxesTrlRateSysid]

				   ,[strTrlTaxesTrlRateCat]
				   ,[dblTrlTaxesTrlRate]
				   ,[strTrlFlagsTrlPLU]
				   ,[strTrlFlagsTrlUpdPluCust]
				   ,[strTrlFlagsTrlUpdDepCust]
				   ,[strTrlFlagsTrlCatCust]
				   ,[strTrlFlagsTrlFuelSale]
				   ,[strTrlFlagsTrlMatch]
				   ,[strTrlFlagsTrlBdayVerif]
				   ,[intTrlMatchLineTrlMatchNumber]
				   ,[strTrlMatchLineTrlMatchName]
				   ,[dblTrlMatchLineTrlMatchQuantity]
				   ,[dblTrlMatchLineTrlMatchPrice]
				   ,[intTrlMatchLineTrlMatchMixes]
				   ,[dblTrlMatchLineTrlPromoAmount]
				   ,[strTrlMatchLineTrlPromotionIDPromoType]
				   ,[strTrlMatchLineTrlPromotionID]
				   ,[strTrPaylineType]
				   ,[intTrPaylineSysid]
				   ,[strTrPaylineLocale]
				   --,[intTrpPaycodeMop]
				   --,[intTrpPaycodeCat]
				   ,[strTrPaylineNacstendercode]
				   ,[strTrPaylineNacstendersubcode]
				   ,[strTrpPaycode]
				   ,[dblTrpAmt]
				   ,[strTrpCardInfoTrpcAccount]
				   ,[intTrpCardInfoTrpcCCNameProdSysid]
				   ,[strTrpCardInfoTrpcCCName]
				   ,[strTrpCardInfoTrpcHostID]
				   ,[strTrpCardInfoTrpcAuthCode]
				   ,[strTrpCardInfoTrpcAuthSrc]
				   ,[strTrpCardInfoTrpcTicket]
				   ,[strTrpCardInfoTrpcEntryMeth]
				   ,[strTrpCardInfoTrpcBatchNr]
				   ,[strTrpCardInfoTrpcSeqNr]
				   ,[dtmTrpCardInfoTrpcAuthDateTime]
				   ,[strTrpCardInfoTrpcRefNum]
				   ,[strTrpCardInfoMerchInfoTrpcmMerchID]
				   ,[strTrpCardInfoMerchInfoTrpcmTermID]

				   ,[intStoreId]
				   ,[intCheckoutId]
				   ,[ysnSubmitted]
				   ,[ysnPMMSubmitted]
				   ,[ysnRJRSubmitted]
				   ,[intConcurrencyId] --142
				)
				SELECT 	
					(CASE WHEN chk.openedTime = '' THEN NULL ELSE left(REPLACE(chk.openedTime, 'T', ' '), len(chk.openedTime) - 6) END)
					, (CASE WHEN chk.closedTime = '' THEN NULL ELSE left(REPLACE(chk.closedTime, 'T', ' '), len(chk.closedTime) - 6) END)
					, (CASE WHEN chk.insideSales = '' THEN NULL ELSE chk.insideSales END)
					, (CASE WHEN chk.insideGrand = '' THEN NULL ELSE chk.insideGrand END)
					, (CASE WHEN chk.outsideSales = '' THEN NULL ELSE chk.outsideSales END)
					, (CASE WHEN chk.outsideGrand = '' THEN NULL ELSE chk.outsideGrand END)
					, (CASE WHEN chk.overallSales = '' THEN NULL ELSE chk.overallSales END)
					, (CASE WHEN chk.overallGrand = '' THEN NULL ELSE chk.overallGrand END)

					, NULLIF(chk.transtype, '')
					, NULLIF(chk.transrecalled, '')
					, NULLIF(chk.transrollback, '')
					, NULLIF(chk.transfuelPrepayCompletion, '')
					, NULLIF(chk.termMsgSNtype, '')
					, NULLIF(chk.termMsgSNterm, '')

					, NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(chk.termMsgSN AS BIGINT), (CASE WHEN chk.date = '' THEN NULL ELSE left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6) END) ORDER BY CAST(chk.intRowCount AS INT)), '') AS intScanTransactionId

					, NULLIF(chk.termMsgSN, '')
					, NULLIF(chk.periodlevel, '')
					, NULLIF(chk.periodseq, '')
					, NULLIF(chk.periodname, '')
					, (CASE WHEN chk.date = '' THEN NULL ELSE left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6) END)
					, NULLIF(chk.duration, '')
					, NULLIF(chk.till, '')
					, NULLIF(chk.cashiersysid, '')
					, NULLIF(chk.cashierempNum, '')
					, NULLIF(chk.cashierposNum, '')
					, NULLIF(chk.cashierperiod, '')
					, NULLIF(chk.cashierdrawer, '')
					, NULLIF(chk.cashier, '')
					, NULLIF(chk.originalCashiersysid, '')
					, NULLIF(chk.originalCashierempNum, '')
					, NULLIF(chk.originalCashierposNum, '')
					, NULLIF(chk.originalCashierperiod, '')
					, NULLIF(chk.originalCashierdrawer, '')
					, CONVERT(NVARCHAR(100), ISNULL(NULLIF(chk.originalCashier, ''), NULL))
					, CONVERT(BIGINT, ISNULL(NULLIF(chk.storeNumber, ''), NULL))
					, CONVERT(DECIMAL(18, 2), ISNULL(NULLIF(chk.coinDispensed, ''), NULL))
					, NULLIF(chk.popDiscTran, '')
					, NULLIF(chk.trFuelOnlyCst, '')
					, NULLIF(chk.posNum, '')
					, NULLIF(chk.trSeq, '')
					, NULLIF(chk.trTotNoTax, '')
					, NULLIF(chk.trTotWTax, '')
					, NULLIF(chk.trTotTax, '')
					, NULLIF(chk.trCurrTotlocale, '')
					, NULLIF(chk.trCurrTot, '')
					, NULLIF(chk.trSTotalizer, '')
					, NULLIF(chk.trGTotalizer, '')
					, NULLIF(chk.custDOB, '')
					, NULLIF(chk.recallAmt, '')
					, NULLIF(chk.taxAmtsysid, '')
					, NULLIF(chk.taxAmtcat, '')
					, NULLIF(chk.taxAmt, '')
					, NULLIF(chk.taxRatesysid, '')
					, NULLIF(chk.taxRatecat, '')
					, NULLIF(chk.taxRate, '')
					, NULLIF(chk.taxNetsysid, '')
					, NULLIF(chk.taxNetcat, '')
					, NULLIF(chk.taxNet, '')
					, NULLIF(chk.taxAttributesysid, '')
					, NULLIF(chk.taxAttributecat, '')
					, NULLIF(chk.taxAttribute, '')
					, NULLIF(chk.trFstmpTot, '')
					, NULLIF(chk.trFstmpTax, '')
					, NULLIF(chk.trFstmpChg, '')
					, NULLIF(chk.trFstmpTnd, '')
					, NULLIF(chk.trCshBkAmtmop, '')
					, NULLIF(chk.trCshBkAmtcat, '')
					, NULLIF(chk.trCshBkAmt, '')
					--, NULLIF(chk.trENPPcode, '')
					--, NULLIF(chk.trENPAmount, '')
					, NULLIF(chk.trLoyaltyProgramprogramID, '')
					, NULLIF(chk.trloSubTotal, '')
					, NULLIF(chk.trloAutoDisc, '')
					, NULLIF(chk.trloCustDisc, '')
					, NULLIF(chk.trloAccount, '')
					, NULLIF(chk.trloEntryMeth, '')
					, NULLIF(chk.trloAuthReply, '')
					, NULLIF(chk.trLinetype, '')
					, NULLIF(chk.trLineunsettled, '')
					, NULLIF(chk.trlDeptnumber, '')
					, NULLIF(chk.trlDepttype, '')
					, NULLIF(chk.trlDept, '')
					, NULLIF(chk.trlNetwCode, '')
					, NULLIF(chk.trlQty, '')
					, NULLIF(chk.trlSign, '')
					, NULLIF(chk.trlSellUnit, '')
					, NULLIF(chk.trlUnitPrice, '')
					, NULLIF(chk.trlLineTot, '')
					, NULLIF(chk.trlDesc, '')
					, NULLIF(chk.trlUPC, '')
					, NULLIF(chk.trlModifier, '')
					, NULLIF(chk.trlUPCEntrytype, '')
					, NULLIF(chk.trlCatnumber, '')
					, NULLIF(chk.trlCat, '')
					, NULLIF(chk.trlTaxsysid, '')
					, NULLIF(chk.trlTaxcat, '')
					, NULLIF(chk.trlTaxreverse, '')
					, NULLIF(chk.trlTax, '')
					, NULLIF(chk.trlRatesysid, '')

					, NULLIF(chk.trlRatecat, '')
					, NULLIF(chk.trlRate, '')
					, NULLIF(chk.trlPLU, '')
					, NULLIF(chk.trlUpdPluCust, '')
					, NULLIF(chk.trlUpdDepCust, '')
					, NULLIF(chk.trlCatCust, '')
					, NULLIF(chk.trlFuelSale, '')
					, NULLIF(chk.trlMatch, '')
					, NULLIF(chk.trlBdayVerif, '')
					, NULLIF(chk.trlMatchNumber, '')
					, NULLIF(chk.trlMatchName, '')
					, NULLIF(chk.trlMatchQuantity, '')
					, NULLIF(chk.trlMatchPrice, '')
					, NULLIF(chk.trlMatchMixes, '')
					, NULLIF(chk.trlPromoAmount, '')
					, NULLIF(chk.trlPromotionIDpromotype, '')
					, NULLIF(chk.trlPromotionID, '')
					, NULLIF(chk.trPaylinetype, '')
					, NULLIF(chk.trPaylinesysid, '')
					, NULLIF(chk.trPaylinelocale, '')
					--, NULLIF(chk.trpPaycodemop, '')
					--, NULLIF(chk.trpPaycodecat, '')
					, NULLIF(chk.trpPaycodenacstendercode, '')
					, NULLIF(chk.trpPaycodenacstendersubcode, '')
					, NULLIF(chk.trpPaycode, '')
					, NULLIF(chk.trpAmt, '')
					, NULLIF(chk.trpcAccount, '')
					, NULLIF(chk.trpcCCNameprodSysid, '')
					, NULLIF(chk.trpcCCName, '')
					, NULLIF(chk.trpcHostID, '')
					, NULLIF(chk.trpcAuthCode, '')
					, NULLIF(chk.trpcAuthSrc, '')
					, NULLIF(chk.trpcTicket, '')
					, NULLIF(chk.trpcEntryMeth, '')
					, NULLIF(chk.trpcBatchNr, '')
					, NULLIF(chk.trpcSeqNr, '')
					, (CASE WHEN chk.trpcAuthDateTime = '' THEN NULL ELSE left(REPLACE(chk.trpcAuthDateTime, 'T', ' '), len(chk.trpcAuthDateTime) - 6) END) --NULLIF(chk.trpcAuthDateTime, '')
					, NULLIF(chk.trpcRefNum, '')
					, NULLIF(chk.trpcmMerchID, '')
					, NULLIF(chk.trpcmTermID, '')

					, @intStoreId
					, @intCheckoutId
					, 0
					, 0
					, 0
					, 0
				FROM #tempCheckoutInsert chk
				JOIN
				(
					SELECT c.termMsgSN as termMsgSN
					FROM #tempCheckoutInsert c
					--WHERE c.trlDept = 'CIGARETTES' 
					WHERE c.TrlDeptNumber IN (SELECT intRegisterDepartmentId FROM @TempTableDepartments)
					AND (c.transtype = 'sale' OR c.transtype = 'network sale')
					AND c.date != ''
					GROUP BY c.termMsgSN
				) x ON x.termMsgSN = chk.termMsgSN
				WHERE NOT EXISTS
				(
					SELECT * 
					FROM dbo.tblSTTranslogRebates TR
					WHERE TR.dtmDate = CAST(left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6) AS DATETIME)
					AND TR.intTermMsgSNterm = chk.termMsgSNterm
					AND TR.intTermMsgSN = chk.termMsgSN 
					AND TR.intTrTickNumPosNum = chk.posNum 
					AND TR.intTrTickNumTrSeq  = chk.trSeq
					AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.transtype COLLATE DATABASE_DEFAULT
					AND TR.intStoreNumber = chk.storeNumber
				)
				ORDER BY chk.termMsgSN, chk.intRowCount ASC

				SET @strStatusMsg = 'Success'
			END
			ELSE IF(@intCountRows = 0)
			BEGIN
				SET @strStatusMsg = 'Register file is already been exported'
				SET @intCountRows = 0
			END
		END
		ELSE IF(@intTableRowCount = 0)
		BEGIN
			SET @strStatusMsg = 'Selected register file is empty'
			SET @intCountRows = 0
		END

	End Try

	Begin Catch
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END