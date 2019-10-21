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





		-- ==================================================================================================================
		-- [START] Custom create temp table from xml file
		-- ==================================================================================================================

		-- ==================================================================================================================
		-- [END] Custom create temp table from xml file
		-- ==================================================================================================================






		DECLARE @intTableRowCount AS INT = 0

		SELECT @intTableRowCount = COUNT(*) 
		FROM #tempCheckoutInsert


		IF(@intTableRowCount > 0)
		BEGIN

			--Get StoreId
			DECLARE @intStoreId			INT,
					@strRegisterClass	NVARCHAR(50)

			SELECT 
				@intStoreId			= chk.intStoreId,
				@strRegisterClass	= r.strRegisterClass
			FROM tblSTCheckoutHeader chk
			INNER JOIN tblSTStore st
				ON chk.intStoreId = st.intStoreId
			INNER JOIN tblSTRegister r
				ON st.intRegisterId = r.intRegisterId
			WHERE chk.intCheckoutId = @intCheckoutId

			
			-- ================================================================================================================== 
			-- START - Validate if Store has department setup for rebate
			-- ================================================================================================================== 
			IF EXISTS(SELECT TOP 1 1 FROM tblSTStoreRebates WHERE intStoreId = @intStoreId)
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
					SELECT
						'Transaction Log' AS strErrorType
						, 'No Department setup on selected Store. Need to setup for rebate.' AS strErrorMessage
						, '' AS strRegisterTag
						, '' AS strRegisterTagValue
						, @intCheckoutId AS intCheckoutId
						, 1 AS intConcurrencyId

					SET @intCountRows = 0
					SET @strStatusMsg = 'No Department setup on selected Store. Need to setup for rebate.'
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
						--WHERE c.trLinetrlDept IN (
						--							SELECT strDepartment FROM @TempTableDepartments
						--						 ) 
							WHERE (c.transtype = 'sale' 
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
					--WHERE c.trLinetrlDept IN (
					--							SELECT strDepartment FROM @TempTableDepartments
					--						 ) 
						WHERE (c.transtype = 'sale' 
						OR c.transtype = 'network sale')
						AND c.trHeaderdate != ''
					GROUP BY c.trHeadertermMsgSN
				END


			--PRINT 'Rows count: ' + Cast(@intCountRows as nvarchar(50))


			IF(@intCountRows > 0)
				BEGIN
					
					BEGIN TRY
							INSERT INTO dbo.tblSTTranslogRebates 
							(
								[dtmOpenedTime],
								[dtmClosedTime],
								[dblInsideSales],
								[dblInsideGrand],
								[dblOutsideSales],
								[dblOutsideGrand],
								[dblOverallSales],
								[dblOverallGrand],

								[strTransType],
								[strTransRecalled],
								[strTransRollback],
								[strTransFuelPrepayCompletion],

								[intScanTransactionId],

								[intTermMsgSN],
								[strTermMsgSNtype],
								[intTermMsgSNterm],
								[intTrTickNumPosNum],
								[intTrTickNumTrSeq],
								[intTrUniqueSN],                        -- NEW 
								[strPeriodNameHOUR],             		-- Modified 
								[intPeriodNameHOURSeq],                 -- Modified 
								[intPeriodNameHOURLevel],	            -- Modified 
								[strPeriodNameSHIFT],                   -- Modified 
								[intPeriodNameSHIFTSeq],                -- Modified 
								[intPeriodNameSHIFTLevel],              -- Modified 
								[strPeriodNameDAILY],                   -- Modified 
								[intPeriodNameDAILYSeq],                -- Modified 
								[intPeriodNameDAILYLevel],              -- Modified 
								[dtmDate],
								[intDuration],
								[intTill],
								[strCashier],
								[intCashierPeriod],
								[intCashierPosNum],
								[intCashierEmpNum],
								[intCashierSysId],
								[intCashierDrawer], 
								[strOriginalCashier],
								[intOriginalCashierPeriod],
								[intOriginalCashierPosNum],
								[intOriginalCashierEmpNum],
								[intOriginalCashierSysid],
								[intOriginalCashierDrawer],
								[intStoreNumber],
								[strTrFuelOnlyCst],
								[strPopDiscTran],
								[dblCoinDispensed],
								[dblTrValueTrTotNoTax],
								[dblTrValueTrTotWTax],
								[dblTrValueTrTotTax],
								[dblTaxAmtsTaxAmt],
								[intTaxAmtsTaxAmtSysid],
								[strTaxAmtsTaxAmtCat],
								[dblTaxAmtsTaxRate],
								[intTaxAmtsTaxRateSysid],
								[strTaxAmtsTaxRateCat],
								[dblTaxAmtsTaxNet],
								[intTaxAmtsTaxNetSysid],
								[strTaxAmtsTaxNetCat],
								[dblTaxAmtsTaxAttribute],
								[intTaxAmtsTaxAttributeSysid],
								[strTaxAmtsTaxAttributeCat],
								[dblTrCurrTot],
								[strTrCurrTotLocale],	
								[dblTrSTotalizer],
								[dblTrGTotalizer],
								[dblTrFstmpTrFstmpTot],
								[dblTrFstmpTrFstmpTax],
								[dblTrFstmpTrFstmpChg],
								[dblTrFstmpTrFstmpTnd],
								[strTrLoyaltyProgramProgramID],
								[dblTrLoyaltyProgramTrloSubTotal],
								[dblTrLoyaltyProgramTrloAutoDisc],
								[dblTrLoyaltyProgramTrloCustDisc],
								[strTrLoyaltyProgramTrloAccount],
								[strTrLoyaltyProgramTrloEntryMeth],
								[strTrLoyaltyProgramTrloAuthReply],
								[dblTrCshBkAmt],
								[dblTrCshBkAmtMop],
								[dblTrCshBkAmtCat],
								[strCustDOB],
								[dblRecallAmt],
								[intTrExNetProdTrENPPcode],
								[dblTrExNetProdTrENPAmount],
								[dblTrExNetProdTrENPItemCnt],                      -- NEW
								[strTrLineType],
								[ysnTrLineDuplicate],                              -- NEW
								[strTrLineUnsettled],
								[dblTrlTaxesTrlTax],
								[intTrlTaxesTrlTaxSysid],
								[strTrlTaxesTrlTaxCat],
								[intTrlTaxesTrlTaxReverse],
								[dblTrlTaxesTrlRate],
								[intTrlTaxesTrlRateSysid],
								[strTrlTaxesTrlRateCat],
								[strTrlFlagsTrlBdayVerif],
								[strTrlFlagsTrlFstmp],                             -- NEW
								[strTrlFlagsTrlPLU],
								[strTrlFlagsTrlUpdPluCust],
								[strTrlFlagsTrlUpdDepCust],
								[strTrlFlagsTrlCatCust],
								[strTrlFlagsTrlFuelSale],
								[strTrlFlagsTrlMatch],
								[strTrlDept],
								[strTrlDeptType],
								[intTrlDeptNumber],
								[strTrlCat],                     				  -- trLine type="preFuel"
								[strTrlCatNumber],               				  -- trLine type="preFuel"
								[strTrlNetwCode],
								[dblTrlQty],
								[dblTrlSign],
								[dblTrlSellUnitPrice],
								[dblTrlUnitPrice],
								[dblTrlLineTot],
								[strTrlDesc],
								[strTrlUPC],
								[strTrlUPCwithoutCheckDigit],
								[strTrlModifier],
								[strTrlUPCEntryType],
								[strTrPaylineType],
								[intTrPaylineSysid],
								[strTrPaylineLocale],
								[strTrpPaycode],
								[intTrpPaycodeCat],
								[intTrpPaycodeMop],
								[strTrPaylineNacstendersubcode],
								[strTrPaylineNacstendercode],
								[dblTrpAmt],
								[strTrpCardInfoTrpcAccount],
								[strTrpCardInfoTrpcCCName],
								[intTrpCardInfoTrpcCCNameProdSysid],
								[strTrpCardInfoTrpcHostID],
								[strTrpCardInfoTrpcAuthCode],
								[strTrpCardInfoTrpcAuthSrc],
								[strTrpCardInfoTrpcTicket],
								[strTrpCardInfoTrpcEntryMeth],
								[strTrpCardInfoTrpcBatchNr],
								[strTrpCardInfoTrpcSeqNr],
								[dtmTrpCardInfoTrpcAuthDateTime],
								[strTrpCardInfoTrpcRefNum],
								[strTrpCardInfoMerchInfoTrpcmMerchID],
								[strTrpCardInfoMerchInfoTrpcmTermID],	
								[strTrlMatchLineTrlMatchName] ,
								[dblTrlMatchLineTrlMatchQuantity],
								[dblTrlMatchLineTrlMatchPrice],
								[intTrlMatchLineTrlMatchMixes],
								[dblTrlMatchLineTrlPromoAmount],
								[strTrlMatchLineTrlPromotionID],
								[strTrlMatchLineTrlPromotionIDPromoType],
								[intTrlMatchLineTrlMatchNumber],

								[intStoreId],
								[intCheckoutId],
								[ysnSubmitted],
								[ysnPMMSubmitted],
								[ysnRJRSubmitted],
								[intConcurrencyId]
							)
							SELECT 	
								-- transSet
								[dtmOpenedTime]								= (CASE WHEN chk.transSetopenedTime = '' THEN NULL ELSE left(REPLACE(chk.transSetopenedTime, 'T', ' '), len(chk.transSetopenedTime) - 6) END),
								[dtmClosedTime]								= (CASE WHEN chk.transSetclosedTime = '' THEN NULL ELSE left(REPLACE(chk.transSetclosedTime, 'T', ' '), len(chk.transSetclosedTime) - 6) END),
								[dblInsideSales]							= (CASE WHEN chk.startTotalsinsideSales = '' THEN NULL ELSE chk.startTotalsinsideSales END),
								[dblInsideGrand]							= (CASE WHEN chk.startTotalsinsideGrand = '' THEN NULL ELSE chk.startTotalsinsideGrand END),
								[dblOutsideSales]							= (CASE WHEN chk.startTotalsoutsideSales = '' THEN NULL ELSE chk.startTotalsoutsideSales END),
								[dblOutsideGrand]							= (CASE WHEN chk.startTotalsoutsideGrand = '' THEN NULL ELSE chk.startTotalsoutsideGrand END),
								[dblOverallSales]							= (CASE WHEN chk.startTotalsoverallSales = '' THEN NULL ELSE chk.startTotalsoverallSales END),
								[dblOverallGrand]							= (CASE WHEN chk.startTotalsoverallGrand = '' THEN NULL ELSE chk.startTotalsoverallGrand END),

								-- trans
								[strTransType]								= NULLIF(chk.transtype, ''),
								[strTransRecalled]							= NULLIF(chk.transrecalled, ''),
								[strTransRollback]							= NULLIF(chk.transrollback, ''),
								[strTransFuelPrepayCompletion]				= NULLIF(chk.transfuelPrepayCompletion, ''),

								-- auto generated
								[intScanTransactionId]						= NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(chk.trHeadertermMsgSN AS BIGINT), chk.trPaylinetrpPaycode ORDER BY CAST(chk.intRowCount AS INT)), ''),

								-- trHeader
								[intTermMsgSN]								= NULLIF(chk.trHeadertermMsgSN, ''),
								[strTermMsgSNtype]							= NULLIF(chk.termMsgSNtype, ''),
								[intTermMsgSNterm]							= NULLIF(chk.termMsgSNterm, ''),
								[intTrTickNumPosNum]						= NULLIF(chk.trTickNumposNum, ''),
								[intTrTickNumTrSeq]							= NULLIF(chk.trTickNumtrSeq, ''),
								[intTrUniqueSN]								= NULLIF(chk.trHeadertrUniqueSN, ''),                   -- NEW 
								[strPeriodNameHOUR]							= NULLIF(chk.periodname, ''),             				-- Modified 
								[intPeriodNameHOURSeq]						= NULLIF(chk.periodseq, ''),							-- Modified 
								[intPeriodNameHOURLevel]					= NULLIF(chk.periodlevel, ''),							-- Modified 
								[strPeriodNameSHIFT]						= NULL,                   -- Modified 
								[intPeriodNameSHIFTSeq]						= NULL,                -- Modified 
								[intPeriodNameSHIFTLevel]					= NULL,              -- Modified 
								[strPeriodNameDAILY]						= NULL,                  -- Modified 
								[intPeriodNameDAILYSeq]						= NULL,                -- Modified 
								[intPeriodNameDAILYLevel]					= NULL,              -- Modified 
								[dtmDate]									= (CASE WHEN chk.trHeaderdate = '' THEN NULL ELSE left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) END),
								[intDuration]								= NULLIF(chk.trHeaderduration, ''),
								[intTill]									= NULLIF(chk.trHeadertill, ''),
								[strCashier]								= NULLIF(chk.trHeadercashier, ''),
								[intCashierPeriod]							= NULLIF(chk.cashierperiod, ''),
								[intCashierPosNum]							= NULLIF(chk.cashierposNum, ''),
								[intCashierEmpNum]							= NULLIF(chk.cashierempNum, ''),
								[intCashierSysId]							= NULLIF(chk.cashiersysid, ''),
								[intCashierDrawer]							= NULLIF(chk.cashierdrawer, ''), 
								[strOriginalCashier]						= CONVERT(NVARCHAR(100), ISNULL(NULLIF(chk.trHeaderoriginalCashier, ''), NULL)),
								[intOriginalCashierPeriod]					= NULLIF(chk.originalCashierperiod, ''),
								[intOriginalCashierPosNum]					= NULLIF(chk.originalCashierposNum, ''),
								[intOriginalCashierEmpNum]					= NULLIF(chk.originalCashierempNum, ''),
								[intOriginalCashierSysid]					= NULLIF(chk.originalCashiersysid, ''),
								[intOriginalCashierDrawer]					= NULLIF(chk.originalCashierdrawer, ''),
								[intStoreNumber]							= CONVERT(BIGINT, ISNULL(NULLIF(chk.trHeaderstoreNumber, ''), NULL)),
								[strTrFuelOnlyCst]							= NULLIF(chk.trHeadertrFuelOnlyCst, ''),
								[strPopDiscTran]							= NULLIF(chk.trHeaderpopDiscTran, ''),
								[dblCoinDispensed]							= CONVERT(DECIMAL(18, 2), ISNULL(NULLIF(chk.trHeadercoinDispensed, ''), NULL)),

								-- trValue
								[dblTrValueTrTotNoTax]						= NULLIF(chk.trValuetrTotNoTax, ''),
								[dblTrValueTrTotWTax]						= NULLIF(chk.trValuetrTotWTax, ''),
								[dblTrValueTrTotTax]						= NULLIF(chk.trValuetrTotTax, ''),
								[dblTaxAmtsTaxAmt]							= NULLIF(chk.taxAmtstaxAmt, ''),
								[intTaxAmtsTaxAmtSysid]						= NULLIF(chk.taxAmtsysid, ''),
								[strTaxAmtsTaxAmtCat]						= NULLIF(chk.taxAmtcat, ''),
								[dblTaxAmtsTaxRate]							= NULLIF(chk.taxAmtstaxRate, ''),
								[intTaxAmtsTaxRateSysid]					= NULLIF(chk.taxRatesysid, ''),
								[strTaxAmtsTaxRateCat]						= NULLIF(chk.taxRatecat, ''),
								[dblTaxAmtsTaxNet]							= NULLIF(chk.taxAmtstaxNet, ''),
								[intTaxAmtsTaxNetSysid]						= NULLIF(chk.taxNetsysid, ''),
								[strTaxAmtsTaxNetCat]						= NULLIF(chk.taxNetcat, ''),
								[dblTaxAmtsTaxAttribute]					= NULLIF(chk.taxAmtstaxAttribute, ''),
								[intTaxAmtsTaxAttributeSysid]				= NULLIF(chk.taxAttributesysid, ''),
								[strTaxAmtsTaxAttributeCat]					= NULLIF(chk.taxAttributecat, ''),
								[dblTrCurrTot]								= NULLIF(chk.trValuetrCurrTot, ''),
								[strTrCurrTotLocale]						= NULLIF(chk.trCurrTotlocale, ''),	
								[dblTrSTotalizer]							= NULLIF(chk.trValuetrSTotalizer, ''),
								[dblTrGTotalizer]							= NULLIF(chk.trValuetrGTotalizer, ''),
								[dblTrFstmpTrFstmpTot]						= NULLIF(chk.trFstmptrFstmpTot, ''),
								[dblTrFstmpTrFstmpTax]						= NULLIF(chk.trFstmptrFstmpTax, ''),
								[dblTrFstmpTrFstmpChg]						= NULLIF(chk.trFstmptrFstmpChg, ''),
								[dblTrFstmpTrFstmpTnd]						= NULLIF(chk.trFstmptrFstmpTnd, ''),

								-- trLoyalty
								[strTrLoyaltyProgramProgramID]				= NULLIF(chk.trLoyaltyProgramprogramID, ''),
								[dblTrLoyaltyProgramTrloSubTotal]			= NULLIF(chk.trLoyaltyProgramtrloSubTotal, ''),
								[dblTrLoyaltyProgramTrloAutoDisc]			= NULLIF(chk.trLoyaltyProgramtrloAutoDisc, ''),
								[dblTrLoyaltyProgramTrloCustDisc]			= NULLIF(chk.trLoyaltyProgramtrloCustDisc, ''),
								[strTrLoyaltyProgramTrloAccount]			= NULLIF(chk.trLoyaltyProgramtrloAccount, ''),
								[strTrLoyaltyProgramTrloEntryMeth]			= NULLIF(chk.trLoyaltyProgramtrloEntryMeth, ''),
								[strTrLoyaltyProgramTrloAuthReply]			= NULLIF(chk.trLoyaltyProgramtrloAuthReply, ''),

								-- trCshBk
								[dblTrCshBkAmt]								= NULLIF(chk.trCshBktrCshBkAmt, ''),
								[dblTrCshBkAmtMop]							= NULLIF(chk.trCshBkAmtmop, ''),
								[dblTrCshBkAmtCat]							= NULLIF(chk.trCshBkAmtcat, ''),
								[strCustDOB]								= NULLIF(chk.trValuecustDOB, ''),
								[dblRecallAmt]								= NULLIF(chk.trValuerecallAmt, ''),

								-- trExNetProds
								[intTrExNetProdTrENPPcode]					= NULLIF(chk.trExNetProdtrENPPcode, ''),							--***--
								[dblTrExNetProdTrENPAmount]					= NULLIF(chk.trExNetProdtrENPAmount, ''),						--***--
								[dblTrExNetProdTrENPItemCnt]				= NULLIF(chk.trExNetProdtrENPItemCnt, ''),                      -- NEW

								-- trLines
								[strTrLineType]								= NULLIF(chk.trLinetype, ''),
								[ysnTrLineDuplicate]						= CASE WHEN NULLIF(chk.trLineduplicate, '') = 'true' THEN 1 ELSE 0 END,           -- NEW
								[strTrLineUnsettled]						= NULLIF(chk.trLineunsettled, ''),
								[dblTrlTaxesTrlTax]							= NULLIF(chk.trlTaxestrlTax, ''),
								[intTrlTaxesTrlTaxSysid]					= NULLIF(chk.trlTaxsysid, ''),
								[strTrlTaxesTrlTaxCat]						= NULLIF(chk.trlTaxcat, ''),
								[intTrlTaxesTrlTaxReverse]					= NULLIF(chk.trlTaxreverse, ''),
								[dblTrlTaxesTrlRate]						= NULLIF(chk.trlTaxestrlRate, ''),
								[intTrlTaxesTrlRateSysid]					= NULLIF(chk.trlRatesysid, ''),
								[strTrlTaxesTrlRateCat]						= NULLIF(chk.trlRatecat, ''),
								-- trlFlags
								[strTrlFlagsTrlBdayVerif]					= NULLIF(chk.trlFlagstrlBdayVerif, '') ,
								[strTrlFlagsTrlFstmp]                       = NULL,														-- NEW
								[strTrlFlagsTrlPLU]							= NULLIF(chk.trlFlagstrlPLU, ''),
								[strTrlFlagsTrlUpdPluCust]					= NULLIF(chk.trlFlagstrlUpdPluCust, ''),
								[strTrlFlagsTrlUpdDepCust]					= NULLIF(chk.trlFlagstrlUpdDepCust, ''),
								[strTrlFlagsTrlCatCust]						= NULLIF(chk.trlFlagstrlCatCust, ''),
								[strTrlFlagsTrlFuelSale]					= NULLIF(chk.trlFlagstrlFuelSale, ''),
								[strTrlFlagsTrlMatch]						= NULLIF(chk.trlFlagstrlMatch, ''),
								[strTrlDept]								= NULLIF(chk.trLinetrlDept, ''),
								[strTrlDeptType]							= NULLIF(chk.trlDepttype, ''),
								[intTrlDeptNumber]							= NULLIF(chk.trlDeptnumber, ''),
								[strTrlCat]									= NULLIF(chk.trLinetrlCat, ''),                 			  -- trLine type="preFuel"
								[strTrlCatNumber]							= NULLIF(chk.trlCatnumber, ''),               				  -- trLine type="preFuel"
								[strTrlNetwCode]							= NULLIF(chk.trLinetrlNetwCode, ''),
								[dblTrlQty]									= NULLIF(chk.trLinetrlQty, ''),
								[dblTrlSign]								= NULLIF(chk.trLinetrlSign, ''),
								[dblTrlSellUnitPrice]						= NULLIF(chk.trLinetrlSellUnit, ''),
								[dblTrlUnitPrice]							= NULLIF(chk.trLinetrlUnitPrice, ''),
								[dblTrlLineTot]								= NULLIF(chk.trLinetrlLineTot, ''),
								[strTrlDesc]								= NULLIF(chk.trLinetrlDesc, ''),

								-- NOTE: in the future if we will be supporting PASSPORT for rebate file
								-- Assumption
								-- COMMANDER file  -  check digit is included
								-- PASSPORT  file  -  check digit is NOT included
								--
								-- Check Register Class by
								--SELECT TOP 1
								--	r.strRegisterClass 
								--FROM tblSTTranslogRebates tlr
								--INNER JOIN tblSTCheckoutHeader chk
								--	ON tlr.intCheckoutId = chk.intCheckoutId
								--INNER JOIN tblSTStore st
								--	ON chk.intStoreId = st.intStoreId
								--INNER JOIN tblSTRegister r
								--	ON st.intRegisterId = r.intRegisterId
								--WHERE chk.intCheckoutId = @intCheckoutId
								--
								-- IF strRegisterClass = PASSPORT
								--	 THEN INSERT UPC with check digit to column 'strTrlUPC'						(Since PASSPORT is not generating UPC with check digit then calculate check digit using chk.trLinetrlUPC)
								--	 THEN INSERT UPC without check digit to column 'strTrlUPCwithoutCheckDigit' (Just insert using chk.trLinetrlUPC since PASSPORT is generating UPC without check digit)
								--
								-- ELSE IF strRegisterClass = COMMANDER
								--	 THEN INSERT UPC with check digit to column 'strTrlUPC'						(Since COMMANDER is generating UPC with check digit then just use chk.trLinetrlUPC)
								--	 THEN INSERT UPC without check digit to column 'strTrlUPCwithoutCheckDigit' (Just remove the last digit of chk.trLinetrlUPC)
								--[strTrlUPC]									= NULLIF(chk.trLinetrlUPC, ''),
								--[strTrlUPCwithoutCheckDigit]				= CASE 
								--												WHEN (chk.trLinetrlUPC IS NOT NULL AND chk.trLinetrlUPC != '' AND LEN(chk.trLinetrlUPC) = 14 AND SUBSTRING(chk.trLinetrlUPC, 1, 1) = '0')
								--													THEN LEFT (chk.trLinetrlUPC, LEN (chk.trLinetrlUPC)-1) -- Remove Check digit on last character
								--												ELSE NULL
								--											END,
								[strTrlUPC]									= CASE
																				WHEN (@strRegisterClass = N'SAPPHIRE/COMMANDER')
																					THEN NULLIF(chk.trLinetrlUPC, '')
																				WHEN (@strRegisterClass = N'PASSPORT')
																					THEN NULLIF(chk.trLinetrlUPC, '') + CAST(dbo.fnSTGenerateCheckDigit(dbo.fnSTGenerateCheckDigit(NULLIF(chk.trLinetrlUPC, ''))) AS NVARCHAR(1))
																				ELSE
																					NULLIF(chk.trLinetrlUPC, '')
																			END,
								[strTrlUPCwithoutCheckDigit]				= CASE
																				WHEN (@strRegisterClass = N'SAPPHIRE/COMMANDER')
																					THEN CASE 
																							WHEN (chk.trLinetrlUPC IS NOT NULL AND chk.trLinetrlUPC != '' AND LEN(chk.trLinetrlUPC) = 14 AND SUBSTRING(chk.trLinetrlUPC, 1, 1) = '0')
																								THEN LEFT (chk.trLinetrlUPC, LEN (chk.trLinetrlUPC)-1) -- Remove Check digit on last character
																							ELSE NULL
																						END
																				WHEN (@strRegisterClass = N'PASSPORT')
																					THEN NULLIF(chk.trLinetrlUPC, '')
																				ELSE
																					NULLIF(chk.trLinetrlUPC, '')
																			END,


								[strTrlModifier]							= NULLIF(chk.trLinetrlModifier, ''),
								[strTrlUPCEntryType]						= NULLIF(chk.trLinetrlUPCEntry, ''),

								-- trPaylines
								[strTrPaylineType]							= NULLIF(chk.trPaylinetype, ''),
								[intTrPaylineSysid]							= NULLIF(chk.trPaylinesysid, ''),
								[strTrPaylineLocale]						= NULLIF(chk.trPaylinelocale, ''),
								[strTrpPaycode]								= NULLIF(chk.trPaylinetrpPaycode, ''),
								[intTrpPaycodeCat]							= NULLIF(chk.trpPaycodecat, ''),			--***--
								[intTrpPaycodeMop]							= NULLIF(chk.trpPaycodemop, ''),			--***--
								[strTrPaylineNacstendersubcode]				= NULLIF(chk.trpPaycodenacstendersubcode, ''),
								[strTrPaylineNacstendercode]				= NULLIF(chk.trpPaycodenacstendercode, ''),
								[dblTrpAmt]									= NULLIF(chk.trPaylinetrpAmt, ''),
								[strTrpCardInfoTrpcAccount]					= NULLIF(chk.trpCardInfotrpcAccount, ''),
								[strTrpCardInfoTrpcCCName]					= NULLIF(chk.trpCardInfotrpcCCName, ''),
								[intTrpCardInfoTrpcCCNameProdSysid]			= NULLIF(chk.trpcCCNamesysid, ''),					-- NULLIF(chk.trpcCCNameprodSysid, ''),
								[strTrpCardInfoTrpcHostID]					= NULLIF(chk.trpCardInfotrpcHostID, ''),
								[strTrpCardInfoTrpcAuthCode]				= NULLIF(chk.trpCardInfotrpcAuthCode, ''),
								[strTrpCardInfoTrpcAuthSrc]					= NULLIF(chk.trpCardInfotrpcAuthSrc, ''),
								[strTrpCardInfoTrpcTicket]					= NULLIF(chk.trpCardInfotrpcTicket, ''),
								[strTrpCardInfoTrpcEntryMeth]				= NULLIF(chk.trpCardInfotrpcEntryMeth, ''),
								[strTrpCardInfoTrpcBatchNr]					= NULLIF(chk.trpCardInfotrpcBatchNr, ''),
								[strTrpCardInfoTrpcSeqNr]					= NULLIF(chk.trpCardInfotrpcSeqNr, ''),
								[dtmTrpCardInfoTrpcAuthDateTime]			= (CASE WHEN chk.trpCardInfotrpcAuthDateTime = '' THEN NULL ELSE left(REPLACE(chk.trpCardInfotrpcAuthDateTime, 'T', ' '), len(chk.trpCardInfotrpcAuthDateTime) - 6) END),
								[strTrpCardInfoTrpcRefNum]					= NULLIF(chk.trpCardInfotrpcRefNum, ''),
								-- trpcMerchInfo
								[strTrpCardInfoMerchInfoTrpcmMerchID] = NULLIF(chk.trpcMerchInfotrpcmMerchID, ''),
								[strTrpCardInfoMerchInfoTrpcmTermID] = NULLIF(chk.trpcMerchInfotrpcmTermID, ''),
								-- trlMixMatches
								[strTrlMatchLineTrlMatchName] = NULLIF(chk.trlMatchLinetrlMatchName, ''),
								[dblTrlMatchLineTrlMatchQuantity] = NULLIF(chk.trlMatchLinetrlMatchQuantity, ''),
								[dblTrlMatchLineTrlMatchPrice] = NULLIF(chk.trlMatchLinetrlMatchPrice, ''),
								[intTrlMatchLineTrlMatchMixes] = NULLIF(chk.trlMatchLinetrlMatchMixes, ''),
								[dblTrlMatchLineTrlPromoAmount] = NULLIF(chk.trlMatchLinetrlPromoAmount, ''),
								[strTrlMatchLineTrlPromotionID] = NULLIF(chk.trlMatchLinetrlPromotionID, ''),
								[strTrlMatchLineTrlPromotionIDPromoType] = NULLIF(chk.trlPromotionIDpromotype, ''),
								[intTrlMatchLineTrlMatchNumber] = NULLIF(chk.trlMatchLinetrlMatchNumber, ''),      -- LAST 

								[intStoreId] = @intStoreId,
								[intCheckoutId] = @intCheckoutId,
								[ysnSubmitted] = 0,
								[ysnPMMSubmitted] = 0,
								[ysnRJRSubmitted] = 0,
								[intConcurrencyId] = 0
							FROM #tempCheckoutInsert chk
							JOIN
							(
								SELECT c.trHeadertermMsgSN as termMsgSN
								FROM #tempCheckoutInsert c
								--WHERE c.trLinetrlDept IN (
								--							SELECT strDepartment FROM @TempTableDepartments
								--						 )
									WHERE (c.transtype = 'sale' 
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
							ORDER BY chk.trHeadertermMsgSN, chk.intRowCount ASC

							SET @strStatusMsg = 'Success'
							GOTO ExitWithCommit

					END TRY
					BEGIN CATCH
						SET @strStatusMsg = 'Transaction Log Rebates: ' + ERROR_MESSAGE()
						GOTO ExitWithRollback
					END CATCH
						
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

					GOTO ExitWithCommit
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


ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END

ExitPost: