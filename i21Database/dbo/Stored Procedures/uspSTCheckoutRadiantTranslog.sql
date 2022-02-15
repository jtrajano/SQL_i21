CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantTranslog]
	@intStoreNo										INT,
	@UDT_Translog StagingTransactionLogRadiant		READONLY,
	@ysnSuccess										BIT				OUTPUT,
	@strMessage										NVARCHAR(1000)	OUTPUT,
	@intCountRows									INT				OUTPUT
AS
BEGIN
	
	SET XACT_ABORT OFF
	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCheckoutRadiantTranslog' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY
		
		

		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END

		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END


		-- Set default value
		SET @ysnSuccess = CAST(1 AS BIT)
		SET @strMessage = ''
		SET @intCountRows = 0


		
		-- COUNT
		DECLARE @intTableRowCount AS INT = 0
		SELECT @intTableRowCount = COUNT(*) FROM @UDT_Translog

		IF(@intTableRowCount > 0)
			BEGIN
				
				--Get StoreId
				DECLARE @intStoreId			INT,
						@strRegisterClass	NVARCHAR(50),
						@intRegisterClassId INT

				SELECT
					@intStoreId			= st.intStoreId,
					@strRegisterClass	= r.strRegisterClass,
					@intRegisterClassId = setup.intRegisterSetupId
				FROM tblSTStore st
				INNER JOIN tblSTRegister r
					ON st.intRegisterId = r.intRegisterId
				INNER JOIN tblSTRegisterSetup setup
					ON r.strRegisterClass = setup.strRegisterClass
				WHERE st.intStoreNo = @intStoreNo


				-- ==================================================================================================================
				-- START - Validate if Store has department setup for rebate
				-- ==================================================================================================================
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTStoreRebates WHERE intStoreId = @intStoreId)
					BEGIN
						
						--Get Number of rows
						SELECT @intCountRows = COUNT(chk.intRowCount)
						FROM @UDT_Translog chk
						INNER JOIN @UDT_Translog tender
							ON chk.intTransactionID = tender.intTransactionID
						WHERE (
								-- MAIN
								(chk.strItemLineItemCodeFormat IS NOT NULL AND chk.strItemLinePOSCode IS NOT NULL)
								OR
								(chk.strFuelGradeID IS NOT NULL AND chk.intFuelPositionID IS NOT NULL)
							  )
							  AND
							  (
							     -- TENDER
								 tender.strTenderCode IN ('outsideMobileCr', 'outsideCredit', 'coupons', 'debitCards', 'creditCards', 'cash', 'loyaltyOffer', 'check', 'houseCharges') 
								 AND 
								 tender.strChangeFlag IN ('yes','no')
							  )
							  AND NOT EXISTS
							  (
								SELECT *
								FROM tblSTTranslogRebates TR
								WHERE TR.intTermMsgSN = chk.intTransactionID
							  )


						
						IF(@intCountRows > 0)
							BEGIN
								
								-- Check Line
								-- 1. TenderInfo - strTenderCode='cash' AND strChangeFlag IN ('yes','no')
								-- 2. ItemLine - strItemlineItemCodeFormat IN ('upcA', 'upcE', 'ean8', 'ean13', 'plu', 'gtin', 'rss14', 'none') AND strItemLinePOSCode IS NOT NULL
								-- 3. FuelLine - strFuelGradeID IS NOT NULL AND intFuelPositionID IS NOT NULL
								-- 4. TransactionTax - intTaxLevelID IS NOT NULL AND dblTaxablrSalesAmount IS NOT NULL

								BEGIN TRY

									INSERT INTO tblSTTranslogRebates
									(
										[intScanTransactionId],
										[strTrlUPCwithoutCheckDigit],
										-- transSet
										[intTransSetPeriodID],
										[strTransSetPeriodame],
										[dtmTransSetLongId],
										[dtmTransSetShortId],
										[intTransSetSite],
										[dtmOpenedTime],
										[dtmClosedTime],
										-- startTotals
										[dblInsideSales],
										[dblInsideGrand],
										[dblOutsideSales],
										[dblOutsideGrand],
										[dblOverallSales],
										[dblOverallGrand],

										-- trans
										[strTransType],
										[strTransRecalled],
										[strTransRollback],
										[strTransFuelPrepayCompletion],
										-- trHeader
										[intTermMsgSN],
										[strTermMsgSNtype],
										[intTermMsgSNterm],
										-- trTickNum
										[intTrTickNumPosNum],
										[intTrTickNumTrSeq],
										[intTrUniqueSN],
										[strPeriodNameHOUR],
										[intPeriodNameHOURSeq],
										[intPeriodNameHOURLevel],
										[strPeriodNameSHIFT],
										[intPeriodNameSHIFTSeq],
										[intPeriodNameSHIFTLevel],
										[strPeriodNameDAILY],
										[intPeriodNameDAILYSeq],
										[intPeriodNameDAILYLevel],
										[dtmDate],
										[intDuration],
										[intTill],

										-- cashier
										[strCashier],
										[intCashierSysId],
										[strCashierEmpNum],
										[intCashierPosNum],
										[intCashierPeriod],
										[intCashierDrawer],
										-- originalCashier
										[strOriginalCashier],
										[intOriginalCashierSysid],
										[strOriginalCashierEmpNum],
										[intOriginalCashierPosNum],
										[intOriginalCashierPeriod],
										[intOriginalCashierDrawer],

										[intStoreNumber],
										[strTrFuelOnlyCst],
										[strPopDiscTran],
										[dblCoinDispensed],

										-- trValue
										[dblTrValueTrTotNoTax],
										[dblTrValueTrTotWTax],
										[dblTrValueTrTotTax],
										-- taxAmts
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
										-- trFstmp
										[dblTrFstmpTrFstmpTot],
										[dblTrFstmpTrFstmpTax],
										[dblTrFstmpTrFstmpChg],
										[dblTrFstmpTrFstmpTnd],
										-- trCshBk
										[dblTrCshBkAmt],
										[dblTrCshBkAmtMop],
										[dblTrCshBkAmtCat],
										[strCustDOB],
										[dblRecallAmt],

										-- trExNetProds
										[intTrExNetProdTrENPPcode],
										[dblTrExNetProdTrENPAmount],
										[dblTrExNetProdTrENPItemCnt],

										-- trLoyalty
										[strTrLoyaltyProgramProgramID],
										[dblTrLoyaltyProgramTrloSubTotal],
										[dblTrLoyaltyProgramTrloAutoDisc],
										[dblTrLoyaltyProgramTrloCustDisc],
										[strTrLoyaltyProgramTrloAccount],
										[strTrLoyaltyProgramTrloEntryMeth],
										[strTrLoyaltyProgramTrloAuthReply],

										-- trLines
										[ysnTrLineDuplicate],
										[strTrLineType],
										[strTrLineUnsettled],
										[dblTrlTaxesTrlTax],
										[intTrlTaxesTrlTaxSysid],
										[strTrlTaxesTrlTaxCat],
										[intTrlTaxesTrlTaxReverse],
										[dblTrlTaxesTrlRate],
										[intTrlTaxesTrlRateSysid],
										[strTrlTaxesTrlRateCat],

										-- trlFlags
										[strTrlFlagsTrlBdayVerif],
										[strTrlFlagsTrlFstmp],
										[strTrlFlagsTrlPLU],
										[strTrlFlagsTrlUpdPluCust],
										[strTrlFlagsTrlUpdDepCust],
										[strTrlFlagsTrlCatCust],
										[strTrlFlagsTrlFuelSale],
										[strTrlFlagsTrlMatch],

										[strTrlDept],
										[strTrlDeptNumber],
										[strTrlDeptType],
										[strTrlCat],
										[intTrlCatNumber],
										[strTrlNetwCode],
										[dblTrlQty],
										[dblTrlSign],
										[dblTrlSellUnitPrice],
										[dblTrlUnitPrice],
										[dblTrlLineTot],
										[strTrlDesc],
										[strTrlUPC],
										[strTrlModifier],
										[strTrlUPCEntryType],

										-- NEW
										-- trlFuel
										[strTrlFuelType],
										[strTrlFuelSeq],
										[strTrlFuelPosition],
										[strTrlFuelDepst],
										[strTrlFuelProd],
										[strTrlFuelProdSysid],
										[strTrlFuelProdNAXMLFuelGradeID],
										[strTrlFuelSvcMode],
										[strTrlFuelSvcModeSysid],
										[strTrlFuelMOP],
										[strTrlFuelMOPSysid],
										[strTrlFuelVolume],
										[strTrlFuelBasePrice],

										-- trPayline
										[strTrPaylineType],
										[intTrPaylineSysid],
										[strTrPaylineLocale],
										[strTrpPaycode],
										[intTrpPaycodeMop],
										[intTrpPaycodeCat],
										[strTrPaylineNacstendercode],
										[strTrPaylineNacstendersubcode],
										[dblTrpAmt],

										-- trpCardInfo
										[strTrpCardInfoTrpcAccount],
										[strTrpCardInfoTrpcCCName],
										[intTrpCardInfoTrpcCCNameProdSysid],
										[strTrpCardInfoTrpcHostID],
										[strTrpCardInfoTrpcAuthCode],
										[strTrpCardInfoTrpcAuthSrc],
										[strTrpCardInfoTrpcTicket],
										[strTrpCardInfoTrpcEntryMeth],
										[intTrpCardInfoTrpcBatchNr],												-- MODIFIED FROM NVARCHAR(50) to INT
										[intTrpCardInfoTrpcSeqNr],													-- MODIFIED FROM NVARCHAR(50) to INT
										[dtmTrpCardInfoTrpcAuthDateTime],
										[strTrpCardInfoTrpcRefNum],
										[strTrpCardInfoMerchInfoTrpcmMerchID],
										[strTrpCardInfoMerchInfoTrpcmTermID],

										[strTrpCardInfoTrpcAcquirerBatchNr],

										-- trlMatchLine
										[strTrlMatchLineTrlMatchName],
										[dblTrlMatchLineTrlMatchQuantity],
										[dblTrlMatchLineTrlMatchPrice],
										[intTrlMatchLineTrlMatchMixes],
										[dblTrlMatchLineTrlPromoAmount],
										[strTrlMatchLineTrlPromotionID],
										[strTrlMatchLineTrlPromotionIDPromoType],
										[intTrlMatchLineTrlMatchNumber],

										[intRegisterClassId],
										[intStoreId],
										[intCheckoutId],
										[ysnSubmitted],
										[ysnPMMSubmitted],
										[ysnRJRSubmitted],
										[intConcurrencyId]

									)
									SELECT
										-- [intScanTransactionId]				= NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(chk.intTransactionID AS BIGINT), tender.strTenderCode, tender.strChangeFlag ORDER BY intRowCount ASC), ''),
										[intScanTransactionId]				= NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(chk.intTransactionID AS BIGINT), tender.strTenderCode, tender.strChangeFlag ORDER BY chk.intRowCount ASC), ''),
										[strTrlUPCwithoutCheckDigit]		= NULLIF(chk.strItemLinePOSCode, ''),
										[intTransSetPeriodID]				= NULL,
										[strTransSetPeriodame]				= NULL,
										[dtmTransSetLongId]					= NULL,
										[dtmTransSetShortId]				= NULL,
										[intTransSetSite]					= chk.intTransmissionHeaderStoreLocationID,
										[dtmOpenedTime]						= CONVERT(DATETIME, CONVERT(CHAR(8), chk.dtmBeginDate, 112) + ' ' + CONVERT(CHAR(8), chk.dtmBeginTime, 108)),
										[dtmClosedTime]						= CONVERT(DATETIME, CONVERT(CHAR(8), chk.dtmEndDate, 112) + ' ' + CONVERT(CHAR(8), chk.dtmEndTime, 108)),
										--[strNAXMLPOSVersion]				= chk.strNAXMLPOSJournalVersion,																					-- NEW


										-- startTotals
										[dblInsideSales]					= NULL,
										[dblInsideGrand]					= NULL,
										[dblOutsideSales]					= NULL,
										[dblOutsideGrand]					= NULL,
										[dblOverallSales]					= NULL,
										[dblOverallGrand]					= NULL,

										-- trans
										[strTransType]						= NULL,
										[strTransRecalled]					= NULL,
										[strTransRollback]					= NULL,
										[strTransFuelPrepayCompletion]		= NULL,
										-- trHeader
										[intTermMsgSN]						= chk.intTransactionID,
										[strTermMsgSNtype]					= NULL,
										[intTermMsgSNterm]					= NULL,
										-- trTickNum
										[intTrTickNumPosNum]				= NULL,
										[intTrTickNumTrSeq]					= NULL,
										[intTrUniqueSN]						= NULL,
										[strPeriodNameHOUR]					= NULL,
										[intPeriodNameHOURSeq]				= NULL,
										[intPeriodNameHOURLevel]			= NULL,
										[strPeriodNameSHIFT]				= NULL,
										[intPeriodNameSHIFTSeq]				= NULL,
										[intPeriodNameSHIFTLevel]			= NULL,
										[strPeriodNameDAILY]				= NULL,
										[intPeriodNameDAILYSeq]				= NULL,
										[intPeriodNameDAILYLevel]			= NULL,
										[dtmDate]							= CONVERT(DATETIME, CONVERT(CHAR(8), chk.dtmEventEndDate, 112) + ' ' + CONVERT(CHAR(8), chk.dtmEventEndTime, 108)),
										[intDuration]						= NULL,
										[intTill]							= CAST(chk.strTillID AS INT),

										-- cashier
										[strCashier]						= NULL,
										[intCashierSysId]					= chk.intCashierID,
										[strCashierEmpNum]					= NULL,
										[intCashierPosNum]					= NULL,
										[intCashierPeriod]					= NULL,
										[intCashierDrawer]					= NULL,
										-- originalCashier
										[strOriginalCashier]				= NULL,
										[intOriginalCashierSysid]			= NULL,
										[strOriginalCashierEmpNum]			= NULL,
										[intOriginalCashierPosNum]			= NULL,
										[intOriginalCashierPeriod]			= NULL,
										[intOriginalCashierDrawer]			= NULL,

										[intStoreNumber]					= chk.intTransmissionHeaderStoreLocationID,
										[strTrFuelOnlyCst]					= NULL,
										[strPopDiscTran]					= NULL,
										[dblCoinDispensed]					= NULL,

										-- trValue
										[dblTrValueTrTotNoTax]				= NULL,
										[dblTrValueTrTotWTax]				= NULL,
										[dblTrValueTrTotTax]				= NULL,
										-- taxAmts
										[dblTaxAmtsTaxAmt]					= NULL,
										[intTaxAmtsTaxAmtSysid]				= NULL,
										[strTaxAmtsTaxAmtCat]				= NULL,
										[dblTaxAmtsTaxRate]					= NULL,
										[intTaxAmtsTaxRateSysid]			= NULL,
										[strTaxAmtsTaxRateCat]				= NULL,
										[dblTaxAmtsTaxNet]					= NULL,
										[intTaxAmtsTaxNetSysid]				= NULL,
										[strTaxAmtsTaxNetCat]				= NULL,
										[dblTaxAmtsTaxAttribute]			= NULL,
										[intTaxAmtsTaxAttributeSysid]		= NULL,
										[strTaxAmtsTaxAttributeCat]			= NULL,

										[dblTrCurrTot]						= NULL,
										[strTrCurrTotLocale]				= NULL,
										[dblTrSTotalizer]					= NULL,
										[dblTrGTotalizer]					= NULL,
										-- trFstmp
										[dblTrFstmpTrFstmpTot]				= NULL,
										[dblTrFstmpTrFstmpTax]				= NULL,
										[dblTrFstmpTrFstmpChg]				= NULL,
										[dblTrFstmpTrFstmpTnd]				= NULL,
										-- trCshBk
										[dblTrCshBkAmt]						= NULL,
										[dblTrCshBkAmtMop]					= NULL,
										[dblTrCshBkAmtCat]					= NULL,
										[strCustDOB]						= NULL,
										[dblRecallAmt]						= NULL,

										-- trExNetProds
										[intTrExNetProdTrENPPcode]			= NULL,
										[dblTrExNetProdTrENPAmount]			= NULL,
										[dblTrExNetProdTrENPItemCnt]		= NULL,

										-- trLoyalty
										[strTrLoyaltyProgramProgramID]		= NULL,
										[dblTrLoyaltyProgramTrloSubTotal]	= NULL,
										[dblTrLoyaltyProgramTrloAutoDisc]	= NULL,
										[dblTrLoyaltyProgramTrloCustDisc]	= NULL,
										[strTrLoyaltyProgramTrloAccount]	= NULL,
										[strTrLoyaltyProgramTrloEntryMeth]	= NULL,
										[strTrLoyaltyProgramTrloAuthReply]	= NULL,

										-- trLines
										[ysnTrLineDuplicate]				= NULL,
										[strTrLineType]						= CASE
																				WHEN chk.strItemLineItemCodeFormat IN ('upcA', 'upcE', 'ean8', 'ean13', 'plu', 'gtin', 'rss14', 'none') AND chk.strItemLinePOSCode IS NOT NULL
																					THEN 'ItemLine'
																				WHEN chk.strFuelGradeID IS NOT NULL AND chk.intFuelPositionID IS NOT NULL
																					THEN 'FuelLine'
																			END,
										[strTrLineUnsettled]				= NULL,
										[dblTrlTaxesTrlTax]					= NULL,
										[intTrlTaxesTrlTaxSysid]			= NULL,
										[strTrlTaxesTrlTaxCat]				= NULL,
										[intTrlTaxesTrlTaxReverse]			= NULL,
										[dblTrlTaxesTrlRate]				= NULL,
										[intTrlTaxesTrlRateSysid]			= NULL,
										[strTrlTaxesTrlRateCat]				= NULL,

										-- trlFlags
										[strTrlFlagsTrlBdayVerif]			= NULL,
										[strTrlFlagsTrlFstmp]				= NULL,
										[strTrlFlagsTrlPLU]					= NULL,
										[strTrlFlagsTrlUpdPluCust]			= NULL,
										[strTrlFlagsTrlUpdDepCust]			= NULL,
										[strTrlFlagsTrlCatCust]				= NULL,
										[strTrlFlagsTrlFuelSale]			= NULL,
										[strTrlFlagsTrlMatch]				= NULL,

										[strTrlDept]						= chk.strMerchandiseCodeLineDescription,
										[strTrlDeptNumber]					= chk.intLineMerchandiseCode,
										[strTrlDeptType]					= NULL,
										[strTrlCat]							= NULL,
										[intTrlCatNumber]					= NULL,
										[strTrlNetwCode]					= NULL,
										[dblTrlQty]							= chk.dblLineSalesQuantity,
										[dblTrlSign]						= NULL,
										[dblTrlSellUnitPrice]				= NULL,
										[dblTrlUnitPrice]					= chk.dblLineRegularSellPrice,
										[dblTrlLineTot]						= chk.dblLineSalesAmount,
										[strTrlDesc]						= chk.strLineDescription,


										--	-- Assumption
										--	-- COMMANDER file  -  check digit is included
										--	-- PASSPORT  file  -  check digit is NOT included
										--	-- RADIANT  file  -  check digit is NOT included
										[strTrlUPC]							= chk.strItemLinePOSCode,
										[strTrlModifier]					= NULL,
										[strTrlUPCEntryType]				= chk.strLineEntryMethod,

										-- NEW
										-- trlFuel
										[strTrlFuelType]					= NULL,
										[strTrlFuelSeq]						= NULL,
										[strTrlFuelPosition]				= chk.intFuelPositionID,
										[strTrlFuelDepst]					= NULL,
										[strTrlFuelProd]					= NULL,
										[strTrlFuelProdSysid]				= NULL,
										[strTrlFuelProdNAXMLFuelGradeID]	= chk.strFuelGradeID,
										[strTrlFuelSvcMode]					= NULL,
										[strTrlFuelSvcModeSysid]			= NULL,
										[strTrlFuelMOP]						= NULL,
										[strTrlFuelMOPSysid]				= NULL,
										[strTrlFuelVolume]					= NULL,
										[strTrlFuelBasePrice]				= NULL,

										-- trPayline
										[strTrPaylineType]					= NULL,
										[intTrPaylineSysid]					= NULL,
										[strTrPaylineLocale]				= NULL,
										[strTrpPaycode]						= CASE
																				WHEN (tender.strTenderCode='cash' AND tender.strChangeFlag = 'no')
																					THEN 'CASH'
																				WHEN (tender.strTenderCode='cash' AND tender.strChangeFlag = 'yes')
																					THEN 'Change'
																				WHEN (tender.strTenderCode='creditCards' AND tender.strChangeFlag = 'no')
																					THEN 'CREDIT'
																				WHEN (tender.strTenderCode='debitCards' AND tender.strChangeFlag = 'no')
																					THEN 'DEBIT'
																				WHEN (tender.strTenderCode='debitCards' AND tender.strChangeFlag = 'yes')
																					THEN 'DEBIT CHG'
																				WHEN (tender.strTenderCode='coupons' AND tender.strChangeFlag = 'no')
																					THEN 'COUPONS'
																				WHEN (tender.strTenderCode='check' AND tender.strChangeFlag = 'no')
																					THEN 'CHECK'
																				WHEN (tender.strTenderCode='houseCharges' AND tender.strChangeFlag = 'no')
																					THEN 'HOUSE CHARGE'
																			END,
										[intTrpPaycodeMop]					= NULL,
										[intTrpPaycodeCat]					= NULL,
										[strTrPaylineNacstendercode]		= NULL,
										[strTrPaylineNacstendersubcode]		= tender.strTenderSubCode,
										[dblTrpAmt]							= tender.dblTenderAmount,

										-- trpCardInfo
										[strTrpCardInfoTrpcAccount]				= NULL,
										[strTrpCardInfoTrpcCCName]				= NULL,
										[intTrpCardInfoTrpcCCNameProdSysid]		= NULL,
										[strTrpCardInfoTrpcHostID]				= NULL,
										[strTrpCardInfoTrpcAuthCode]			= NULL,
										[strTrpCardInfoTrpcAuthSrc]				= NULL,
										[strTrpCardInfoTrpcTicket]				= NULL,
										[strTrpCardInfoTrpcEntryMeth]			= NULL,
										[intTrpCardInfoTrpcBatchNr]				= NULL,
										[intTrpCardInfoTrpcSeqNr]				= NULL,
										[dtmTrpCardInfoTrpcAuthDateTime]		= NULL,
										[strTrpCardInfoTrpcRefNum]				= NULL,
										[strTrpCardInfoMerchInfoTrpcmMerchID]	= NULL,
										[strTrpCardInfoMerchInfoTrpcmTermID]	= NULL,

										[strTrpCardInfoTrpcAcquirerBatchNr]		= NULL,

										-- trlMatchLine
										[strTrlMatchLineTrlMatchName]				= chk.strLineDescription,
										[dblTrlMatchLineTrlMatchQuantity]			= NULL,
										[dblTrlMatchLineTrlMatchPrice]				= NULL,
										[intTrlMatchLineTrlMatchMixes]				= NULL,
										[dblTrlMatchLineTrlPromoAmount]				= chk.dblPromotionAmount,  -- Usually this is negative amount
										[strTrlMatchLineTrlPromotionID]				= chk.strPromotionID,
										[strTrlMatchLineTrlPromotionIDPromoType]	= chk.strPromotionReason,
										[intTrlMatchLineTrlMatchNumber]				= NULL,

										[intRegisterClassId]					= @intRegisterClassId,
										[intStoreId]							= @intStoreId,
										[intCheckoutId]							= NULL,
										[ysnSubmitted]							= CAST(0 AS BIT),
										[ysnPMMSubmitted]						= CAST(0 AS BIT),
										[ysnRJRSubmitted]						= CAST(0 AS BIT),
										[intConcurrencyId]						= 1

									FROM @UDT_Translog chk
									INNER JOIN @UDT_Translog tender
										ON chk.intTransactionID = tender.intTransactionID
									WHERE (
											-- MAIN
											(chk.strItemLineItemCodeFormat IS NOT NULL AND chk.strItemLinePOSCode IS NOT NULL)
											OR
											(chk.strFuelGradeID IS NOT NULL AND chk.intFuelPositionID IS NOT NULL)
										  )
										  AND
										  (
											-- TENDER
											tender.strTenderCode IN ('outsideMobileCr', 'outsideCredit', 'coupons', 'debitCards', 'creditCards', 'cash', 'loyaltyOffer', 'check', 'houseCharges') 
											AND 
											tender.strChangeFlag IN ('yes','no')
										  )
										  AND NOT EXISTS
										  (
											SELECT *
											FROM tblSTTranslogRebates TR
											WHERE TR.intTermMsgSN = chk.intTransactionID
										  )
									ORDER BY chk.intTransactionID ASC

								END TRY
								BEGIN CATCH
									SET @ysnSuccess = CAST(0 AS BIT)
									SET @strMessage = 'Error on insert to transaction log table: ' + ERROR_MESSAGE()

									GOTO ExitWithRollback
								END CATCH




								SET @ysnSuccess = CAST(1 AS BIT)
								SET @strMessage = 'Success'

								GOTO ExitWithCommit

							END
						ELSE IF(@intCountRows = 0)
							BEGIN
								SET @ysnSuccess = CAST(0 AS BIT)
								SET @strMessage = 'Transaction Log file is already been exported.'

								GOTO ExitWithRollback
							END


					END
				ELSE 
					BEGIN
						SET @ysnSuccess = CAST(0 AS BIT)
						SET @strMessage = 'Store has no department setup for rebate.'

						GOTO ExitWithRollback
					END
				-- ==================================================================================================================
				-- END - Validate if Store has department setup for rebate
				-- ==================================================================================================================

			END
		ELSE IF(@intTableRowCount = 0)
			BEGIN
				SET @ysnSuccess = CAST(0 AS BIT)
				SET @strMessage = 'POSJOURNAL file is empty'

				GOTO ExitWithRollback
			END

	END TRY
	BEGIN CATCH
		SET @ysnSuccess = CAST(0 AS BIT)
		SET @strMessage = 'End script error: ' + ERROR_MESSAGE()

		GOTO ExitWithRollback
	END CATCH

END

 




ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost



ExitWithRollback:

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strMessage = @strMessage + '. Will Rollback Transaction.'
					PRINT '@strMessage: ' + @strMessage
					ROLLBACK TRANSACTION
				END
			END

		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessage = @strMessage + '. Will Rollback to Save point.'
						PRINT '@strMessage: ' + @strMessage
						ROLLBACK TRANSACTION @Savepoint
					END
			END





ExitPost:



