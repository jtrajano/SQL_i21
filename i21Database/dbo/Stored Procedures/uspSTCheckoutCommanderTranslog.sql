CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
	@intCheckoutId Int,
	@strStatusMsg NVARCHAR(250) OUTPUT,
	@intCountRows int OUTPUT
AS
BEGIN
	BEGIN TRY
		
		BEGIN TRANSACTION

		-- ==================================================================================================================  
		-- Start Validate if Translog xml file matches the Mapping on i21 
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
							, 'Commander Translog XML file did not match the layout mapping'
							, ''
							, ''
							, @intCheckoutId
							, 1
						)

						SET @intCountRows = 0
						SET @strStatusMsg = 'Commander Translog XML file did not match the layout mapping'

						GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if Translog xml file matches the Mapping on i21   
		-- ==================================================================================================================

		DECLARE @intTableRowCount AS INT = 0

		SELECT @intTableRowCount = COUNT(*) 
		FROM #tempCheckoutInsert


		IF(@intTableRowCount > 0)
		BEGIN

			--Get StoreId
			DECLARE @intStoreId INT

			SELECT @intStoreId = intStoreId 
			FROM tblSTCheckoutHeader 
			WHERE intCheckoutId = @intCheckoutId

			
			-- ================================================================================================================== 
			-- START - Validate if Store has department setup for rebate
			-- ================================================================================================================== 
			IF EXISTS(SELECT TOP 1 1 
			          FROM tblSTStore
				      WHERE intStoreId = @intStoreId
						AND (strDepartment = '' OR strDepartment IS NULL))
				BEGIN

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
						'Transaction Log' AS strErrorType
						, 'No Department setup on selected Store. Need to setup for rebate.' AS strErrorMessage
						, '' AS strRegisterTag
						, '' AS strRegisterTagValue
						, @intCheckoutId AS intCheckoutId
						, 1 AS intConcurrencyId
					FROM tblSTStore ST
					WHERE ST.intStoreId = @intStoreId
						AND (ST.strDepartment = '' OR ST.strDepartment IS NULL)

					SET @intCountRows = 0
					SET @strStatusMsg = 'No Department setup on selected Store. Need to setup for rebate.'

					GOTO ExitWithCommit
				END
			-- ==================================================================================================================  
			-- END - Validate if Store has department setup for rebate 
			-- ==================================================================================================================


			-------------------------------------------START GET Department
			--// Get Department Id from Store
			DECLARE @strDepartments AS NVARCHAR(MAX)


			SELECT @strDepartments = strDepartment 
			FROM tblSTStore
			WHERE intStoreId = @intStoreId

			IF(@strDepartments = '')
			BEGIN
				SET @intCountRows = 0
				SET @strStatusMsg = 'Store does not have setup for Tobacco Department'
				RETURN
			END

			--// Create Temp table
			DECLARE @TempTableDepartments TABLE 
			(
				strDepartment NVARCHAR(100)
			)

			--// Create dynamic sqlQuery
			DECLARE @strDynamicQuery as NVARCHAR(MAX)
			SET @strDynamicQuery = 'SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId IN (' + @strDepartments + ')'

			--// Insert to tempTable
			INSERT @TempTableDepartments
			EXEC (@strDynamicQuery)

			IF NOT EXISTS (SELECT * FROM @TempTableDepartments)
			BEGIN
				SET @intCountRows = 0
				SET @strStatusMsg = 'Tobacco department does not exist'
				RETURN
			END
			-------------------------------------------END GET Department



			-- Check if department exist in XML file
			IF NOT EXISTS(SELECT COUNT(c.trHeadertermMsgSN) 
					      FROM #tempCheckoutInsert c 
			              WHERE c.trLinetrlDept IN (
												SELECT strDepartment FROM @TempTableDepartments
											 ) 
							AND (c.transtype = 'sale' 
							OR c.transtype = 'network sale') 
						  GROUP BY c.trHeadertermMsgSN)
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
						SELECT c.trHeadertermMsgSN as termMsgSN
						FROM #tempCheckoutInsert c
						WHERE c.trLinetrlDept IN (
													SELECT strDepartment FROM @TempTableDepartments
												 ) 
							AND (c.transtype = 'sale' 
							OR c.transtype = 'network sale')
							AND c.trHeaderdate != ''
						GROUP BY c.trHeadertermMsgSN
					) x ON x.termMsgSN = chk.trHeadertermMsgSN
					WHERE NOT EXISTS
					(
						SELECT * 
							FROM dbo.tblSTTranslogRebates TR
							WHERE TR.dtmDate = CAST(left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) AS DATETIME)
							AND TR.intTermMsgSNterm = chk.termMsgSNterm
							AND TR.intTermMsgSN = chk.trHeadertermMsgSN 
							AND TR.intTrTickNumPosNum = chk.cashierposNum 
							AND TR.intTrTickNumTrSeq  = chk.trTickNumtrSeq
							AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.transtype COLLATE DATABASE_DEFAULT
							AND TR.intStoreNumber = chk.trHeaderstoreNumber
					)
					AND chk.trHeaderdate != ''
				END
			ELSE
				BEGIN
					SELECT @intCountRows = COUNT(c.trHeadertermMsgSN)
					FROM #tempCheckoutInsert c 
					WHERE c.trLinetrlDept IN (
												SELECT strDepartment FROM @TempTableDepartments
											 ) 
						AND (c.transtype = 'sale' 
						OR c.transtype = 'network sale')
						AND c.trHeaderdate != ''
					GROUP BY c.trHeadertermMsgSN
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
					(CASE WHEN chk.transSetopenedTime = '' THEN NULL ELSE left(REPLACE(chk.transSetopenedTime, 'T', ' '), len(chk.transSetopenedTime) - 6) END)
					, (CASE WHEN chk.transSetclosedTime = '' THEN NULL ELSE left(REPLACE(chk.transSetclosedTime, 'T', ' '), len(chk.transSetclosedTime) - 6) END)
					, (CASE WHEN chk.startTotalsinsideSales = '' THEN NULL ELSE chk.startTotalsinsideSales END)
					, (CASE WHEN chk.startTotalsinsideGrand = '' THEN NULL ELSE chk.startTotalsinsideGrand END)
					, (CASE WHEN chk.startTotalsoutsideSales = '' THEN NULL ELSE chk.startTotalsoutsideSales END)
					, (CASE WHEN chk.startTotalsoutsideGrand = '' THEN NULL ELSE chk.startTotalsoutsideGrand END)
					, (CASE WHEN chk.startTotalsoverallSales = '' THEN NULL ELSE chk.startTotalsoverallSales END)
					, (CASE WHEN chk.startTotalsoverallGrand = '' THEN NULL ELSE chk.startTotalsoverallGrand END)

					, NULLIF(chk.transtype, '')
					, NULLIF(chk.transrecalled, '')
					, NULLIF(chk.transrollback, '')
					, NULLIF(chk.transfuelPrepayCompletion, '')
					, NULLIF(chk.termMsgSNtype, '')
					, NULLIF(chk.termMsgSNterm, '')

					, NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(chk.trHeadertermMsgSN AS BIGINT), chk.trPaylinetrpPaycode ORDER BY CAST(chk.intRowCount AS INT)), '') AS intScanTransactionId

					, NULLIF(chk.trHeadertermMsgSN, '')
					, NULLIF(chk.periodlevel, '')
					, NULLIF(chk.periodseq, '')
					, NULLIF(chk.periodname, '')
					, (CASE WHEN chk.trHeaderdate = '' THEN NULL ELSE left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) END)
					, NULLIF(chk.trHeaderduration, '')
					, NULLIF(chk.trHeadertill, '')
					, NULLIF(chk.cashiersysid, '')
					, NULLIF(chk.cashierempNum, '')
					, NULLIF(chk.cashierposNum, '')
					, NULLIF(chk.cashierperiod, '')
					, NULLIF(chk.cashierdrawer, '')
					, NULLIF(chk.trHeadercashier, '')
					, NULLIF(chk.originalCashiersysid, '')
					, NULLIF(chk.originalCashierempNum, '')
					, NULLIF(chk.originalCashierposNum, '')
					, NULLIF(chk.originalCashierperiod, '')
					, NULLIF(chk.originalCashierdrawer, '')
					, CONVERT(NVARCHAR(100), ISNULL(NULLIF(chk.trHeaderoriginalCashier, ''), NULL))
					, CONVERT(BIGINT, ISNULL(NULLIF(chk.trHeaderstoreNumber, ''), NULL))
					, CONVERT(DECIMAL(18, 2), ISNULL(NULLIF(chk.trHeadercoinDispensed, ''), NULL))
					, NULLIF(chk.trHeaderpopDiscTran, '')
					, NULLIF(chk.trHeadertrFuelOnlyCst, '')
					, NULLIF(chk.trTickNumposNum, '')
					, NULLIF(chk.trTickNumtrSeq, '')
					, NULLIF(chk.trValuetrTotNoTax, '')
					, NULLIF(chk.trValuetrTotWTax, '')
					, NULLIF(chk.trValuetrTotTax, '')
					, NULLIF(chk.trCurrTotlocale, '')
					, NULLIF(chk.trValuetrCurrTot, '')
					, NULLIF(chk.trValuetrSTotalizer, '')
					, NULLIF(chk.trValuetrGTotalizer, '')
					, NULLIF(chk.trValuecustDOB, '')
					, NULLIF(chk.trValuerecallAmt, '')
					, NULLIF(chk.taxAmtsysid, '')
					, NULLIF(chk.taxAmtcat, '')
					, NULLIF(chk.taxAmtstaxAmt, '')
					, NULLIF(chk.taxRatesysid, '')
					, NULLIF(chk.taxRatecat, '')
					, NULLIF(chk.taxAmtstaxRate, '')
					, NULLIF(chk.taxNetsysid, '')
					, NULLIF(chk.taxNetcat, '')
					, NULLIF(chk.taxAmtstaxNet, '')
					, NULLIF(chk.taxAttributesysid, '')
					, NULLIF(chk.taxAttributecat, '')
					, NULLIF(chk.taxAmtstaxAttribute, '')
					, NULLIF(chk.trFstmptrFstmpTot, '')
					, NULLIF(chk.trFstmptrFstmpTax, '')
					, NULLIF(chk.trFstmptrFstmpChg, '')
					, NULLIF(chk.trFstmptrFstmpTnd, '')
					, NULLIF(chk.trCshBkAmtmop, '')
					, NULLIF(chk.trCshBkAmtcat, '')
					, NULLIF(chk.trCshBktrCshBkAmt, '')
					--, NULLIF(chk.trENPPcode, '')
					--, NULLIF(chk.trENPAmount, '')
					, NULLIF(chk.trLoyaltyProgramprogramID, '')
					, NULLIF(chk.trLoyaltyProgramtrloSubTotal, '')
					, NULLIF(chk.trLoyaltyProgramtrloAutoDisc, '')
					, NULLIF(chk.trLoyaltyProgramtrloCustDisc, '')
					, NULLIF(chk.trLoyaltyProgramtrloAccount, '')
					, NULLIF(chk.trLoyaltyProgramtrloEntryMeth, '')
					, NULLIF(chk.trLoyaltyProgramtrloAuthReply, '')
					, NULLIF(chk.trLinetype, '')
					, NULLIF(chk.trLineunsettled, '')
					, NULLIF(chk.trlDeptnumber, '')
					, NULLIF(chk.trlDepttype, '')
					, NULLIF(chk.trLinetrlDept, '')
					, NULLIF(chk.trLinetrlNetwCode, '')
					, NULLIF(chk.trLinetrlQty, '')
					, NULLIF(chk.trLinetrlSign, '')
					, NULLIF(chk.trLinetrlSellUnit, '')
					, NULLIF(chk.trLinetrlUnitPrice, '')
					, NULLIF(chk.trLinetrlLineTot, '')
					, NULLIF(chk.trLinetrlDesc, '')
					, NULLIF(chk.trLinetrlUPC, '')
					, NULLIF(chk.trLinetrlModifier, '')
					, NULLIF(chk.trLinetrlUPCEntry, '')
					, NULLIF(chk.trlCatnumber, '')
					, NULLIF(chk.trLinetrlCat, '')
					, NULLIF(chk.trlTaxsysid, '')
					, NULLIF(chk.trlTaxcat, '')
					, NULLIF(chk.trlTaxreverse, '')
					, NULLIF(chk.trlTaxestrlTax, '')
					, NULLIF(chk.trlRatesysid, '')

					, NULLIF(chk.trlRatecat, '')
					, NULLIF(chk.trlTaxestrlRate, '')
					, NULLIF(chk.trlFlagstrlPLU, '')
					, NULLIF(chk.trlFlagstrlUpdPluCust, '')
					, NULLIF(chk.trlFlagstrlUpdDepCust, '')
					, NULLIF(chk.trlFlagstrlCatCust, '')
					, NULLIF(chk.trlFlagstrlFuelSale, '')
					, NULLIF(chk.trlFlagstrlMatch, '')
					, NULLIF(chk.trlFlagstrlBdayVerif, '')
					, NULLIF(chk.trlMatchLinetrlMatchNumber, '')
					, NULLIF(chk.trlMatchLinetrlMatchName, '')
					, NULLIF(chk.trlMatchLinetrlMatchQuantity, '')
					, NULLIF(chk.trlMatchLinetrlMatchPrice, '')
					, NULLIF(chk.trlMatchLinetrlMatchMixes, '')
					, NULLIF(chk.trlMatchLinetrlPromoAmount, '')
					, NULLIF(chk.trlPromotionIDpromotype, '')
					, NULLIF(chk.trlMatchLinetrlPromotionID, '')
					, NULLIF(chk.trPaylinetype, '')
					, NULLIF(chk.trPaylinesysid, '')
					, NULLIF(chk.trPaylinelocale, '')
					--, NULLIF(chk.trpPaycodemop, '')
					--, NULLIF(chk.trpPaycodecat, '')
					, NULLIF(chk.trpPaycodenacstendercode, '')
					, NULLIF(chk.trpPaycodenacstendersubcode, '')
					, NULLIF(chk.trPaylinetrpPaycode, '')
					, NULLIF(chk.trPaylinetrpAmt, '')
					, NULLIF(chk.trpCardInfotrpcAccount, '')
					, NULLIF(chk.trpcCCNameprodSysid, '')
					, NULLIF(chk.trpCardInfotrpcCCName, '')
					, NULLIF(chk.trpCardInfotrpcHostID, '')
					, NULLIF(chk.trpCardInfotrpcAuthCode, '')
					, NULLIF(chk.trpCardInfotrpcAuthSrc, '')
					, NULLIF(chk.trpCardInfotrpcTicket, '')
					, NULLIF(chk.trpCardInfotrpcEntryMeth, '')
					, NULLIF(chk.trpCardInfotrpcBatchNr, '')
					, NULLIF(chk.trpCardInfotrpcSeqNr, '')
					, (CASE WHEN chk.trpCardInfotrpcAuthDateTime = '' THEN NULL ELSE left(REPLACE(chk.trpCardInfotrpcAuthDateTime, 'T', ' '), len(chk.trpCardInfotrpcAuthDateTime) - 6) END) --NULLIF(chk.trpcAuthDateTime, '')
					, NULLIF(chk.trpCardInfotrpcRefNum, '')
					, NULLIF(chk.trpcMerchInfotrpcmMerchID, '')
					, NULLIF(chk.trpcMerchInfotrpcmTermID, '')

					, @intStoreId
					, @intCheckoutId
					, 0
					, 0
					, 0
					, 0
				FROM #tempCheckoutInsert chk
				JOIN
				(
					SELECT c.trHeadertermMsgSN as termMsgSN
					FROM #tempCheckoutInsert c
					WHERE c.trLinetrlDept IN (
												SELECT strDepartment FROM @TempTableDepartments
											 )
						AND (c.transtype = 'sale' 
						OR c.transtype = 'network sale')
						AND c.trHeaderdate != ''
					GROUP BY c.trHeadertermMsgSN
				) x ON x.termMsgSN = chk.trHeadertermMsgSN
				WHERE NOT EXISTS
				(
					SELECT * 
					FROM dbo.tblSTTranslogRebates TR
					WHERE TR.dtmDate = CAST(left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) AS DATETIME)
						AND TR.intTermMsgSNterm = chk.termMsgSNterm
						AND TR.intTermMsgSN = chk.trHeadertermMsgSN 
						AND TR.intTrTickNumPosNum = chk.cashierposNum 
						AND TR.intTrTickNumTrSeq  = chk.trTickNumtrSeq
						AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.transtype COLLATE DATABASE_DEFAULT
						AND TR.intStoreNumber = chk.storeNumberlocale
				)
				ORDER BY chk.trHeadertermMsgSN, chk.intRowCount ASC

				SET @strStatusMsg = 'Success'
				GOTO ExitWithCommit
			END
			ELSE IF(@intCountRows = 0)
			BEGIN
				SET @strStatusMsg = 'Transaction Log file is already been exported.'
				SET @intCountRows = 0

				-- ================================================================================================================== 
				-- START - Insert message if Transaction Log is already been exported
				-- ================================================================================================================== 
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
						'Transaction Log'
						, @strStatusMsg
						, ''
						, ''
						, @intCheckoutId
						, 1
				)
				-- ==================================================================================================================  
				-- END - Insert message if Transaction Log is already been exported
				-- ==================================================================================================================

				GOTO ExitWithCommit
			END
		END
		ELSE IF(@intTableRowCount = 0)
		BEGIN
			SET @strStatusMsg = 'Selected register file is empty'
			SET @intCountRows = 0
			GOTO ExitWithCommit
		END

	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
		GOTO ExitWithCommit
	END CATCH
END


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost


--ExitWithRollback:
--    -- Rollback Transaction here
--	IF @@TRANCOUNT > 0
--		BEGIN
--			ROLLBACK TRANSACTION --@TransactionName
--		END

ExitPost: