CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
	@intCheckoutId							INT,
	@UDT_Translog StagingTransactionLog		READONLY,
	@ysnSuccess								BIT				OUTPUT,
	@strMessage								NVARCHAR(1000)	OUTPUT,
	@intCountRows							INT				OUTPUT
AS
BEGIN

	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCheckoutCommanderTranslog' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY


		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END

		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END

		-- ==================================================================================================================  
		-- Start Validate if Translog xml file matches the Mapping on i21 
		-- ------------------------------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM @UDT_Translog)
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
						SET @strMessage = 'Commander Translog XML file did not match the layout mapping'

						GOTO ExitWithCommit
			END
		-- ------------------------------------------------------------------------------------------------------------------
		-- End Validate if Translog xml file matches the Mapping on i21   
		-- ==================================================================================================================

		-- COUNT
		DECLARE @intTableRowCount AS INT = 0
		SELECT @intTableRowCount = COUNT(*) FROM @UDT_Translog


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
						SET @strMessage = 'No Department setup on selected Store. Need to setup for rebate.'
					END




					-- Check if has records
				IF EXISTS(SELECT COUNT(intTranslogId) FROM tblSTTranslogRebates)
					BEGIN
						--Get Number of rows
						SELECT @intCountRows = COUNT(*)
						FROM @UDT_Translog chk
						JOIN
						(
							SELECT c.intTermMsgSN as termMsgSN
							FROM @UDT_Translog c
								WHERE (c.strTransType = 'sale'
								OR c.strTransType = 'network sale')
								AND c.dtmDate IS NOT NULL
							GROUP BY c.intTermMsgSN
						) x ON x.termMsgSN = chk.intTermMsgSN
						WHERE NOT EXISTS
						(
							SELECT *
								FROM dbo.tblSTTranslogRebates TR
								WHERE TR.dtmDate = chk.dtmDate --CAST(left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) AS DATETIME)
									AND TR.intTermMsgSNterm = chk.intTermMsgSNterm
									AND TR.intTermMsgSN = chk.intTermMsgSN
									AND TR.intTrTickNumPosNum = chk.intTrTickNumPosNum
									AND TR.intTrTickNumTrSeq  = chk.intTrTickNumTrSeq
									AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.strTransType COLLATE DATABASE_DEFAULT
									AND TR.intStoreNumber = chk.intStoreNumber
						)
						AND chk.dtmDate IS NOT NULL
					END
				ELSE
					BEGIN
						SELECT @intCountRows = COUNT(c.intTermMsgSN)
						FROM @UDT_Translog c
							WHERE (c.strTransType = 'sale'
							OR c.strTransType = 'network sale')
							AND c.dtmDate IS NOT NULL
						GROUP BY c.intTermMsgSN
					END




				IF(@intCountRows > 0)
					BEGIN
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
							[intTrlDeptNumber],
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


							[intStoreId],
							[intCheckoutId],
							[ysnSubmitted],
							[ysnPMMSubmitted],
							[ysnRJRSubmitted],
							[intConcurrencyId]

						)
						SELECT
							[intScanTransactionId]				= NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(intTermMsgSN AS BIGINT), strTrpPaycode ORDER BY CAST(intTermMsgSN AS INT)), ''),
							[strTrlUPCwithoutCheckDigit]		= CASE
																	WHEN (@strRegisterClass = N'SAPPHIRE/COMMANDER')
																		THEN CASE
																				WHEN (strTrlUPC IS NOT NULL AND strTrlUPC != '' AND LEN(strTrlUPC) = 14 AND SUBSTRING(strTrlUPC, 1, 1) = '0')
																					THEN LEFT (strTrlUPC, LEN (strTrlUPC)-1) -- Remove Check digit on last character
																				ELSE NULL
																		END
																	WHEN (@strRegisterClass = N'PASSPORT')
																		THEN NULLIF(strTrlUPC, '')
																	ELSE
																		NULLIF(strTrlUPC, '')
																END,
							-- transSet
							[intTransSetPeriodID]				= intTransSetPeriodID,
							[strTransSetPeriodame]				= strTransSetPeriodame,
							[dtmTransSetLongId]					= dtmTransSetLongId,
							[dtmTransSetShortId]				= dtmTransSetShortId,
							[intTransSetSite]					= intTransSetSite,
							[dtmOpenedTime]						= dtmOpenedTime,
							[dtmClosedTime]						= dtmClosedTime,

							-- startTotals
							[dblInsideSales]					= dblInsideSales,
							[dblInsideGrand]					= dblInsideGrand,
							[dblOutsideSales]					= dblOutsideSales,
							[dblOutsideGrand]					= dblOutsideGrand,
							[dblOverallSales]					= dblOverallSales,
							[dblOverallGrand]					= dblOverallGrand,

							-- trans
							[strTransType]						= strTransType,
							[strTransRecalled]					= strTransRecalled,
							[strTransRollback]					= strTransRollback,
							[strTransFuelPrepayCompletion]		= strTransFuelPrepayCompletion,
							-- trHeader
							[intTermMsgSN]						= intTermMsgSN,
							[strTermMsgSNtype]					= strTermMsgSNtype,
							[intTermMsgSNterm]					= intTermMsgSNterm,
							-- trTickNum
							[intTrTickNumPosNum]				= intTrTickNumPosNum,
							[intTrTickNumTrSeq]					= intTrTickNumTrSeq,
							[intTrUniqueSN]						= intTrUniqueSN,
							[strPeriodNameHOUR]					= strPeriodNameHOUR,
							[intPeriodNameHOURSeq]				= intPeriodNameHOURSeq,
							[intPeriodNameHOURLevel]			= intPeriodNameHOURLevel,
							[strPeriodNameSHIFT]				= strPeriodNameSHIFT,
							[intPeriodNameSHIFTSeq]				= intPeriodNameSHIFTSeq,
							[intPeriodNameSHIFTLevel]			= intPeriodNameSHIFTLevel,
							[strPeriodNameDAILY]				= strPeriodNameDAILY,
							[intPeriodNameDAILYSeq]				= intPeriodNameDAILYSeq,
							[intPeriodNameDAILYLevel]			= intPeriodNameDAILYLevel,
							[dtmDate]							= dtmDate,
							[intDuration]						= intDuration,
							[intTill]							= intTill,

							-- cashier
							[strCashier]						= strCashier,
							[intCashierSysId]					= intCashierSysId,
							[strCashierEmpNum]					= strCashierEmpNum,
							[intCashierPosNum]					= intCashierPosNum,
							[intCashierPeriod]					= intCashierPeriod,
							[intCashierDrawer]					= intCashierDrawer,
							-- originalCashier
							[strOriginalCashier]				= strOriginalCashier,
							[intOriginalCashierSysid]			= intOriginalCashierSysid,
							[strOriginalCashierEmpNum]			= strOriginalCashierEmpNum,
							[intOriginalCashierPosNum]			= intOriginalCashierPosNum,
							[intOriginalCashierPeriod]			= intOriginalCashierPeriod,
							[intOriginalCashierDrawer]			= intOriginalCashierDrawer,

							[intStoreNumber]					= intStoreNumber,
							[strTrFuelOnlyCst]					= strTrFuelOnlyCst,
							[strPopDiscTran]					= strPopDiscTran,
							[dblCoinDispensed]					= dblCoinDispensed,

							-- trValue
							[dblTrValueTrTotNoTax]				= dblTrValueTrTotNoTax,
							[dblTrValueTrTotWTax]				= dblTrValueTrTotWTax,
							[dblTrValueTrTotTax]				= dblTrValueTrTotTax,
							-- taxAmts
							[dblTaxAmtsTaxAmt]					= dblTaxAmtsTaxAmt,
							[intTaxAmtsTaxAmtSysid]				= intTaxAmtsTaxAmtSysid,
							[strTaxAmtsTaxAmtCat]				= strTaxAmtsTaxAmtCat,
							[dblTaxAmtsTaxRate]					= dblTaxAmtsTaxRate,
							[intTaxAmtsTaxRateSysid]			= intTaxAmtsTaxRateSysid,
							[strTaxAmtsTaxRateCat]				= strTaxAmtsTaxRateCat,
							[dblTaxAmtsTaxNet]					= dblTaxAmtsTaxNet,
							[intTaxAmtsTaxNetSysid]				= intTaxAmtsTaxNetSysid,
							[strTaxAmtsTaxNetCat]				= strTaxAmtsTaxNetCat,
							[dblTaxAmtsTaxAttribute]			= dblTaxAmtsTaxAttribute,
							[intTaxAmtsTaxAttributeSysid]		= intTaxAmtsTaxAttributeSysid,
							[strTaxAmtsTaxAttributeCat]			= strTaxAmtsTaxAttributeCat,

							[dblTrCurrTot]						= dblTrCurrTot,
							[strTrCurrTotLocale]				= strTrCurrTotLocale,
							[dblTrSTotalizer]					= dblTrSTotalizer,
							[dblTrGTotalizer]					= dblTrGTotalizer,
							-- trFstmp
							[dblTrFstmpTrFstmpTot]				= dblTrFstmpTrFstmpTot,
							[dblTrFstmpTrFstmpTax]				= dblTrFstmpTrFstmpTax,
							[dblTrFstmpTrFstmpChg]				= dblTrFstmpTrFstmpChg,
							[dblTrFstmpTrFstmpTnd]				= dblTrFstmpTrFstmpTnd,
							-- trCshBk
							[dblTrCshBkAmt]						= dblTrCshBkAmt,
							[dblTrCshBkAmtMop]					= dblTrCshBkAmtMop,
							[dblTrCshBkAmtCat]					= dblTrCshBkAmtCat,
							[strCustDOB]						= strCustDOB,
							[dblRecallAmt]						= dblRecallAmt,

							-- trExNetProds
							[intTrExNetProdTrENPPcode]			= intTrExNetProdTrENPPcode,
							[dblTrExNetProdTrENPAmount]			= dblTrExNetProdTrENPAmount,
							[dblTrExNetProdTrENPItemCnt]		= dblTrExNetProdTrENPItemCnt,

							-- trLoyalty
							[strTrLoyaltyProgramProgramID]		= strTrLoyaltyProgramProgramID,
							[dblTrLoyaltyProgramTrloSubTotal]	= dblTrLoyaltyProgramTrloSubTotal,
							[dblTrLoyaltyProgramTrloAutoDisc]	= dblTrLoyaltyProgramTrloAutoDisc,
							[dblTrLoyaltyProgramTrloCustDisc]	= dblTrLoyaltyProgramTrloCustDisc,
							[strTrLoyaltyProgramTrloAccount]	= strTrLoyaltyProgramTrloAccount,
							[strTrLoyaltyProgramTrloEntryMeth]	= strTrLoyaltyProgramTrloEntryMeth,
							[strTrLoyaltyProgramTrloAuthReply]	= strTrLoyaltyProgramTrloAuthReply,

							-- trLines
							[ysnTrLineDuplicate]				= ysnTrLineDuplicate,
							[strTrLineType]						= strTrLineType,
							[strTrLineUnsettled]				= strTrLineUnsettled,
							[dblTrlTaxesTrlTax]					= dblTrlTaxesTrlTax,
							[intTrlTaxesTrlTaxSysid]			= intTrlTaxesTrlTaxSysid,
							[strTrlTaxesTrlTaxCat]				= strTrlTaxesTrlTaxCat,
							[intTrlTaxesTrlTaxReverse]			= intTrlTaxesTrlTaxReverse,
							[dblTrlTaxesTrlRate]				= dblTrlTaxesTrlRate,
							[intTrlTaxesTrlRateSysid]			= intTrlTaxesTrlRateSysid,
							[strTrlTaxesTrlRateCat]				= strTrlTaxesTrlRateCat,

							-- trlFlags
							[strTrlFlagsTrlBdayVerif]			= strTrlFlagsTrlBdayVerif,
							[strTrlFlagsTrlFstmp]				= strTrlFlagsTrlFstmp,
							[strTrlFlagsTrlPLU]					= strTrlFlagsTrlPLU,
							[strTrlFlagsTrlUpdPluCust]			= strTrlFlagsTrlUpdPluCust,
							[strTrlFlagsTrlUpdDepCust]			= strTrlFlagsTrlUpdDepCust,
							[strTrlFlagsTrlCatCust]				= strTrlFlagsTrlCatCust,
							[strTrlFlagsTrlFuelSale]			= strTrlFlagsTrlFuelSale,
							[strTrlFlagsTrlMatch]				= strTrlFlagsTrlMatch,

							[strTrlDept]						= strTrlDept,
							[intTrlDeptNumber]					= intTrlDeptNumber,
							[strTrlDeptType]					= strTrlDeptType,
							[strTrlCat]							= strTrlCat,
							[intTrlCatNumber]					= intTrlCatNumber,
							[strTrlNetwCode]					= strTrlNetwCode,
							[dblTrlQty]							= dblTrlQty,
							[dblTrlSign]						= dblTrlSign,
							[dblTrlSellUnitPrice]				= dblTrlSellUnitPrice,
							[dblTrlUnitPrice]					= dblTrlUnitPrice,
							[dblTrlLineTot]						= dblTrlLineTot,
							[strTrlDesc]						= strTrlDesc,

							-- NOTE: in the future if we will be supporting PASSPORT for rebate file
								-- Assumption
								-- COMMANDER file  -  check digit is included
								-- PASSPORT  file  -  check digit is NOT included
							--[strTrlUPC]							= strTrlUPC,
							[strTrlUPC]							= CASE
																	WHEN (@strRegisterClass = N'SAPPHIRE/COMMANDER')
																		THEN NULLIF(strTrlUPC, '')
																	WHEN (@strRegisterClass = N'PASSPORT')
																		THEN NULLIF(strTrlUPC, '') + CAST(dbo.fnSTGenerateCheckDigit(dbo.fnSTGenerateCheckDigit(NULLIF(strTrlUPC, ''))) AS NVARCHAR(1))
																	ELSE
																		NULLIF(strTrlUPC, '')
																END,
							[strTrlModifier]					= strTrlModifier,
							[strTrlUPCEntryType]				= strTrlUPCEntryType,

							-- NEW
							-- trlFuel
							[strTrlFuelType]					= strTrlFuelType,
							[strTrlFuelSeq]						= strTrlFuelSeq,
							[strTrlFuelPosition]				= strTrlFuelPosition,
							[strTrlFuelDepst]					= strTrlFuelDepst,
							[strTrlFuelProd]					= strTrlFuelProd,
							[strTrlFuelProdSysid]				= strTrlFuelProdSysid,
							[strTrlFuelProdNAXMLFuelGradeID]	= strTrlFuelProdNAXMLFuelGradeID,
							[strTrlFuelSvcMode]					= strTrlFuelSvcMode,
							[strTrlFuelSvcModeSysid]			= strTrlFuelSvcModeSysid,
							[strTrlFuelMOP]						= strTrlFuelMOP,
							[strTrlFuelMOPSysid]				= strTrlFuelMOPSysid,
							[strTrlFuelVolume]					= strTrlFuelVolume,
							[strTrlFuelBasePrice]				= strTrlFuelBasePrice,

							-- trPayline
							[strTrPaylineType]					= strTrPaylineType,
							[intTrPaylineSysid]					= intTrPaylineSysid,
							[strTrPaylineLocale]				= strTrPaylineLocale,
							[strTrpPaycode]						= strTrpPaycode,
							[intTrpPaycodeMop]					= intTrpPaycodeMop,
							[intTrpPaycodeCat]					= intTrpPaycodeCat,
							[strTrPaylineNacstendercode]		= strTrPaylineNacstendercode,
							[strTrPaylineNacstendersubcode]		= strTrPaylineNacstendersubcode,
							[dblTrpAmt]							= dblTrpAmt,

							-- trpCardInfo
							[strTrpCardInfoTrpcAccount]			= strTrpCardInfoTrpcAccount,
							[strTrpCardInfoTrpcCCName]			= strTrpCardInfoTrpcCCName,
							[intTrpCardInfoTrpcCCNameProdSysid]	= intTrpCardInfoTrpcCCNameProdSysid,
							[strTrpCardInfoTrpcHostID]			= strTrpCardInfoTrpcHostID,
							[strTrpCardInfoTrpcAuthCode]		= strTrpCardInfoTrpcAuthCode,
							[strTrpCardInfoTrpcAuthSrc]			= strTrpCardInfoTrpcAuthSrc,
							[strTrpCardInfoTrpcTicket]			= strTrpCardInfoTrpcTicket,
							[strTrpCardInfoTrpcEntryMeth]		= strTrpCardInfoTrpcEntryMeth,
							[intTrpCardInfoTrpcBatchNr]			= intTrpCardInfoTrpcBatchNr,
							[intTrpCardInfoTrpcSeqNr]			= intTrpCardInfoTrpcSeqNr,
							[dtmTrpCardInfoTrpcAuthDateTime]	= dtmTrpCardInfoTrpcAuthDateTime,
							[strTrpCardInfoTrpcRefNum]			= strTrpCardInfoTrpcRefNum,
							[strTrpCardInfoMerchInfoTrpcmMerchID]	= strTrpCardInfoMerchInfoTrpcmMerchID,
							[strTrpCardInfoMerchInfoTrpcmTermID]	= strTrpCardInfoMerchInfoTrpcmTermID,

							[strTrpCardInfoTrpcAcquirerBatchNr]		= strTrpCardInfoTrpcAcquirerBatchNr,

							-- trlMatchLine
							[strTrlMatchLineTrlMatchName]			= strTrlMatchLineTrlMatchName,
							[dblTrlMatchLineTrlMatchQuantity]		= dblTrlMatchLineTrlMatchQuantity,
							[dblTrlMatchLineTrlMatchPrice]			= dblTrlMatchLineTrlMatchPrice,
							[intTrlMatchLineTrlMatchMixes]			= intTrlMatchLineTrlMatchMixes,
							[dblTrlMatchLineTrlPromoAmount]			= dblTrlMatchLineTrlPromoAmount,
							[strTrlMatchLineTrlPromotionID]			= strTrlMatchLineTrlPromotionID,
							[strTrlMatchLineTrlPromotionIDPromoType]	= strTrlMatchLineTrlPromotionIDPromoType,
							[intTrlMatchLineTrlMatchNumber]				= intTrlMatchLineTrlMatchNumber,


							[intStoreId]							= @intStoreId,
							[intCheckoutId]							= @intCheckoutId,
							[ysnSubmitted]							= CAST(0 AS BIT),
							[ysnPMMSubmitted]						= CAST(0 AS BIT),
							[ysnRJRSubmitted]						= CAST(0 AS BIT),
							[intConcurrencyId]						= 1

						FROM @UDT_Translog chk
						JOIN
							(
								SELECT c.intTermMsgSN as termMsgSN
								FROM @UDT_Translog c
									WHERE (c.strTransType = 'sale'
									OR c.strTransType = 'network sale')
									AND c.dtmDate IS NOT NULL
								GROUP BY c.intTermMsgSN
							) x ON x.termMsgSN = chk.intTermMsgSN
							WHERE NOT EXISTS
							(
								SELECT * 
								FROM dbo.tblSTTranslogRebates TR
								WHERE TR.dtmDate = chk.dtmDate --CAST(left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) AS DATETIME)
									AND TR.intTermMsgSNterm = chk.intTermMsgSNterm
									AND TR.intTermMsgSN = chk.intTermMsgSN
									AND TR.intTrTickNumPosNum = chk.intTrTickNumPosNum
									AND TR.intTrTickNumTrSeq  = chk.intTrTickNumTrSeq
									AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.strTransType COLLATE DATABASE_DEFAULT
									AND TR.intStoreNumber = chk.intStoreNumber
							)
							AND chk.dtmDate IS NOT NULL
							ORDER BY chk.intTermMsgSNterm ASC



							SET @ysnSuccess = CAST(1 AS BIT)
							SET @strMessage = 'Success'

							GOTO ExitWithCommit

					END
				ELSE IF(@intCountRows = 0)
					BEGIN
						SET @ysnSuccess = CAST(0 AS BIT)
						SET @strMessage = 'Transaction Log file is already been exported.'

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
									, @strMessage
									, ''
									, ''
									, @intCheckoutId
									, 1
							)

							GOTO ExitWithCommit
							-- ==================================================================================================================
							-- END - Insert message if Transaction Log is already been exported
							-- ==================================================================================================================
					END
				ELSE IF(@intTableRowCount = 0)
					BEGIN
						SET @strMessage = 'Selected register file is empty'
						SET @intCountRows = 0

						GOTO ExitWithCommit
					END

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

					ROLLBACK TRANSACTION
				END
			END

		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessage = @strMessage + '. Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END







ExitPost:

--CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
--	@intCheckoutId Int,
--	@strStatusMsg NVARCHAR(250) OUTPUT,
--	@intCountRows int OUTPUT
--AS
--BEGIN
--	BEGIN TRY

--		BEGIN TRANSACTION

--		-- ==================================================================================================================
--		-- Start Validate if Translog xml file matches the Mapping on i21
--		-- ------------------------------------------------------------------------------------------------------------------
--		IF NOT EXISTS(SELECT TOP 1 1 FROM #tempCheckoutInsert)
--			BEGIN
--						-- Add to error logging
--						INSERT INTO tblSTCheckoutErrorLogs
--						(
--							strErrorType
--							, strErrorMessage
--							, strRegisterTag
--							, strRegisterTagValue
--							, intCheckoutId
--							, intConcurrencyId
--						)
--						VALUES
--						(
--							'XML LAYOUT MAPPING'
--							, 'Commander Translog XML file did not match the layout mapping'
--							, ''
--							, ''
--							, @intCheckoutId
--							, 1
--						)

--						SET @intCountRows = 0
--						SET @strStatusMsg = 'Commander Translog XML file did not match the layout mapping'

--						GOTO ExitWithCommit
--			END
--		-- ------------------------------------------------------------------------------------------------------------------
--		-- End Validate if Translog xml file matches the Mapping on i21
--		-- ==================================================================================================================





--		-- ==================================================================================================================
--		-- [START] Custom create temp table from xml file
--		-- ==================================================================================================================

--		-- ==================================================================================================================
--		-- [END] Custom create temp table from xml file
--		-- ==================================================================================================================






--		DECLARE @intTableRowCount AS INT = 0

--		SELECT @intTableRowCount = COUNT(*)
--		FROM #tempCheckoutInsert


--		IF(@intTableRowCount > 0)
--		BEGIN

--			--Get StoreId
--			DECLARE @intStoreId			INT,
--					@strRegisterClass	NVARCHAR(50)

--			SELECT
--				@intStoreId			= chk.intStoreId,
--				@strRegisterClass	= r.strRegisterClass
--			FROM tblSTCheckoutHeader chk
--			INNER JOIN tblSTStore st
--				ON chk.intStoreId = st.intStoreId
--			INNER JOIN tblSTRegister r
--				ON st.intRegisterId = r.intRegisterId
--			WHERE chk.intCheckoutId = @intCheckoutId


--			-- ==================================================================================================================
--			-- START - Validate if Store has department setup for rebate
--			-- ==================================================================================================================
--			IF EXISTS(SELECT TOP 1 1 FROM tblSTStoreRebates WHERE intStoreId = @intStoreId)
--				BEGIN

--					INSERT INTO tblSTCheckoutErrorLogs
--					(
--						strErrorType
--						, strErrorMessage
--						, strRegisterTag
--						, strRegisterTagValue
--						, intCheckoutId
--						, intConcurrencyId
--					)
--					SELECT
--						'Transaction Log' AS strErrorType
--						, 'No Department setup on selected Store. Need to setup for rebate.' AS strErrorMessage
--						, '' AS strRegisterTag
--						, '' AS strRegisterTagValue
--						, @intCheckoutId AS intCheckoutId
--						, 1 AS intConcurrencyId

--					SET @intCountRows = 0
--					SET @strStatusMsg = 'No Department setup on selected Store. Need to setup for rebate.'
--				END


--			-- Check if has records
--			IF EXISTS(SELECT COUNT(intTranslogId) FROM tblSTTranslogRebates)
--				BEGIN
--					--Get Number of rows
--					SELECT @intCountRows = COUNT(*)
--					FROM #tempCheckoutInsert chk
--					JOIN
--					(
--						SELECT c.trHeadertermMsgSN as termMsgSN
--						FROM #tempCheckoutInsert c
--						--WHERE c.trLinetrlDept IN (
--						--							SELECT strDepartment FROM @TempTableDepartments
--						--						 )
--							WHERE (c.transtype = 'sale'
--							OR c.transtype = 'network sale')
--							AND c.trHeaderdate != ''
--						GROUP BY c.trHeadertermMsgSN
--					) x ON x.termMsgSN = chk.trHeadertermMsgSN
--					WHERE NOT EXISTS
--					(
--						SELECT *
--							FROM dbo.tblSTTranslogRebates TR
--							WHERE TR.dtmDate = CAST(left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) AS DATETIME)
--								AND TR.intTermMsgSNterm = chk.termMsgSNterm
--								AND TR.intTermMsgSN = chk.trHeadertermMsgSN
--								AND TR.intTrTickNumPosNum = chk.cashierposNum
--								AND TR.intTrTickNumTrSeq  = chk.trTickNumtrSeq
--								AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.transtype COLLATE DATABASE_DEFAULT
--								AND TR.intStoreNumber = chk.trHeaderstoreNumber
--					)
--					AND chk.trHeaderdate != ''
--				END
--			ELSE
--				BEGIN
--					SELECT @intCountRows = COUNT(c.trHeadertermMsgSN)
--					FROM #tempCheckoutInsert c
--					--WHERE c.trLinetrlDept IN (
--					--							SELECT strDepartment FROM @TempTableDepartments
--					--						 )
--						WHERE (c.transtype = 'sale'
--						OR c.transtype = 'network sale')
--						AND c.trHeaderdate != ''
--					GROUP BY c.trHeadertermMsgSN
--				END


--			--PRINT 'Rows count: ' + Cast(@intCountRows as nvarchar(50))


--			IF(@intCountRows > 0)
--				BEGIN

--					BEGIN TRY
--							INSERT INTO dbo.tblSTTranslogRebates
--							(
--								[dtmOpenedTime],
--								[dtmClosedTime],
--								[dblInsideSales],
--								[dblInsideGrand],
--								[dblOutsideSales],
--								[dblOutsideGrand],
--								[dblOverallSales],
--								[dblOverallGrand],

--								[strTransType],
--								[strTransRecalled],
--								[strTransRollback],
--								[strTransFuelPrepayCompletion],

--								[intScanTransactionId],

--								[intTermMsgSN],
--								[strTermMsgSNtype],
--								[intTermMsgSNterm],
--								[intTrTickNumPosNum],
--								[intTrTickNumTrSeq],
--								[intTrUniqueSN],                        -- NEW
--								[strPeriodNameHOUR],             		-- Modified
--								[intPeriodNameHOURSeq],                 -- Modified
--								[intPeriodNameHOURLevel],	            -- Modified
--								[strPeriodNameSHIFT],                   -- Modified
--								[intPeriodNameSHIFTSeq],                -- Modified
--								[intPeriodNameSHIFTLevel],              -- Modified
--								[strPeriodNameDAILY],                   -- Modified
--								[intPeriodNameDAILYSeq],                -- Modified
--								[intPeriodNameDAILYLevel],              -- Modified
--								[dtmDate],
--								[intDuration],
--								[intTill],
--								[strCashier],
--								[intCashierPeriod],
--								[intCashierPosNum],
--								[intCashierEmpNum],
--								[intCashierSysId],
--								[intCashierDrawer],
--								[strOriginalCashier],
--								[intOriginalCashierPeriod],
--								[intOriginalCashierPosNum],
--								[intOriginalCashierEmpNum],
--								[intOriginalCashierSysid],
--								[intOriginalCashierDrawer],
--								[intStoreNumber],
--								[strTrFuelOnlyCst],
--								[strPopDiscTran],
--								[dblCoinDispensed],
--								[dblTrValueTrTotNoTax],
--								[dblTrValueTrTotWTax],
--								[dblTrValueTrTotTax],
--								[dblTaxAmtsTaxAmt],
--								[intTaxAmtsTaxAmtSysid],
--								[strTaxAmtsTaxAmtCat],
--								[dblTaxAmtsTaxRate],
--								[intTaxAmtsTaxRateSysid],
--								[strTaxAmtsTaxRateCat],
--								[dblTaxAmtsTaxNet],
--								[intTaxAmtsTaxNetSysid],
--								[strTaxAmtsTaxNetCat],
--								[dblTaxAmtsTaxAttribute],
--								[intTaxAmtsTaxAttributeSysid],
--								[strTaxAmtsTaxAttributeCat],
--								[dblTrCurrTot],
--								[strTrCurrTotLocale],
--								[dblTrSTotalizer],
--								[dblTrGTotalizer],
--								[dblTrFstmpTrFstmpTot],
--								[dblTrFstmpTrFstmpTax],
--								[dblTrFstmpTrFstmpChg],
--								[dblTrFstmpTrFstmpTnd],
--								[strTrLoyaltyProgramProgramID],
--								[dblTrLoyaltyProgramTrloSubTotal],
--								[dblTrLoyaltyProgramTrloAutoDisc],
--								[dblTrLoyaltyProgramTrloCustDisc],
--								[strTrLoyaltyProgramTrloAccount],
--								[strTrLoyaltyProgramTrloEntryMeth],
--								[strTrLoyaltyProgramTrloAuthReply],
--								[dblTrCshBkAmt],
--								[dblTrCshBkAmtMop],
--								[dblTrCshBkAmtCat],
--								[strCustDOB],
--								[dblRecallAmt],
--								[intTrExNetProdTrENPPcode],
--								[dblTrExNetProdTrENPAmount],
--								[dblTrExNetProdTrENPItemCnt],                      -- NEW
--								[strTrLineType],
--								[ysnTrLineDuplicate],                              -- NEW
--								[strTrLineUnsettled],
--								[dblTrlTaxesTrlTax],
--								[intTrlTaxesTrlTaxSysid],
--								[strTrlTaxesTrlTaxCat],
--								[intTrlTaxesTrlTaxReverse],
--								[dblTrlTaxesTrlRate],
--								[intTrlTaxesTrlRateSysid],
--								[strTrlTaxesTrlRateCat],
--								[strTrlFlagsTrlBdayVerif],
--								[strTrlFlagsTrlFstmp],                             -- NEW
--								[strTrlFlagsTrlPLU],
--								[strTrlFlagsTrlUpdPluCust],
--								[strTrlFlagsTrlUpdDepCust],
--								[strTrlFlagsTrlCatCust],
--								[strTrlFlagsTrlFuelSale],
--								[strTrlFlagsTrlMatch],
--								[strTrlDept],
--								[strTrlDeptType],
--								[intTrlDeptNumber],
--								[strTrlCat],                     				  -- trLine type="preFuel"
--								[strTrlCatNumber],               				  -- trLine type="preFuel"
--								[strTrlNetwCode],
--								[dblTrlQty],
--								[dblTrlSign],
--								[dblTrlSellUnitPrice],
--								[dblTrlUnitPrice],
--								[dblTrlLineTot],
--								[strTrlDesc],
--								[strTrlUPC],
--								[strTrlUPCwithoutCheckDigit],
--								[strTrlModifier],
--								[strTrlUPCEntryType],
--								[strTrPaylineType],
--								[intTrPaylineSysid],
--								[strTrPaylineLocale],
--								[strTrpPaycode],
--								[intTrpPaycodeCat],
--								[intTrpPaycodeMop],
--								[strTrPaylineNacstendersubcode],
--								[strTrPaylineNacstendercode],
--								[dblTrpAmt],
--								[strTrpCardInfoTrpcAccount],
--								[strTrpCardInfoTrpcCCName],
--								[intTrpCardInfoTrpcCCNameProdSysid],
--								[strTrpCardInfoTrpcHostID],
--								[strTrpCardInfoTrpcAuthCode],
--								[strTrpCardInfoTrpcAuthSrc],
--								[strTrpCardInfoTrpcTicket],
--								[strTrpCardInfoTrpcEntryMeth],
--								[strTrpCardInfoTrpcBatchNr],
--								[strTrpCardInfoTrpcSeqNr],
--								[dtmTrpCardInfoTrpcAuthDateTime],
--								[strTrpCardInfoTrpcRefNum],
--								[strTrpCardInfoMerchInfoTrpcmMerchID],
--								[strTrpCardInfoMerchInfoTrpcmTermID],
--								[strTrlMatchLineTrlMatchName] ,
--								[dblTrlMatchLineTrlMatchQuantity],
--								[dblTrlMatchLineTrlMatchPrice],
--								[intTrlMatchLineTrlMatchMixes],
--								[dblTrlMatchLineTrlPromoAmount],
--								[strTrlMatchLineTrlPromotionID],
--								[strTrlMatchLineTrlPromotionIDPromoType],
--								[intTrlMatchLineTrlMatchNumber],

--								[intStoreId],
--								[intCheckoutId],
--								[ysnSubmitted],
--								[ysnPMMSubmitted],
--								[ysnRJRSubmitted],
--								[intConcurrencyId]
--							)
--							SELECT
--								-- transSet
--								[dtmOpenedTime]								= (CASE WHEN chk.transSetopenedTime = '' THEN NULL ELSE left(REPLACE(chk.transSetopenedTime, 'T', ' '), len(chk.transSetopenedTime) - 6) END),
--								[dtmClosedTime]								= (CASE WHEN chk.transSetclosedTime = '' THEN NULL ELSE left(REPLACE(chk.transSetclosedTime, 'T', ' '), len(chk.transSetclosedTime) - 6) END),
--								[dblInsideSales]							= (CASE WHEN chk.startTotalsinsideSales = '' THEN NULL ELSE chk.startTotalsinsideSales END),
--								[dblInsideGrand]							= (CASE WHEN chk.startTotalsinsideGrand = '' THEN NULL ELSE chk.startTotalsinsideGrand END),
--								[dblOutsideSales]							= (CASE WHEN chk.startTotalsoutsideSales = '' THEN NULL ELSE chk.startTotalsoutsideSales END),
--								[dblOutsideGrand]							= (CASE WHEN chk.startTotalsoutsideGrand = '' THEN NULL ELSE chk.startTotalsoutsideGrand END),
--								[dblOverallSales]							= (CASE WHEN chk.startTotalsoverallSales = '' THEN NULL ELSE chk.startTotalsoverallSales END),
--								[dblOverallGrand]							= (CASE WHEN chk.startTotalsoverallGrand = '' THEN NULL ELSE chk.startTotalsoverallGrand END),

--								-- trans
--								[strTransType]								= NULLIF(chk.transtype, ''),
--								[strTransRecalled]							= NULLIF(chk.transrecalled, ''),
--								[strTransRollback]							= NULLIF(chk.transrollback, ''),
--								[strTransFuelPrepayCompletion]				= NULLIF(chk.transfuelPrepayCompletion, ''),

--								-- auto generated
--								[intScanTransactionId]						= NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(chk.trHeadertermMsgSN AS BIGINT), chk.trPaylinetrpPaycode ORDER BY CAST(chk.intRowCount AS INT)), ''),

--								-- trHeader
--								[intTermMsgSN]								= NULLIF(chk.trHeadertermMsgSN, ''),
--								[strTermMsgSNtype]							= NULLIF(chk.termMsgSNtype, ''),
--								[intTermMsgSNterm]							= NULLIF(chk.termMsgSNterm, ''),
--								[intTrTickNumPosNum]						= NULLIF(chk.trTickNumposNum, ''),
--								[intTrTickNumTrSeq]							= NULLIF(chk.trTickNumtrSeq, ''),
--								[intTrUniqueSN]								= NULLIF(chk.trHeadertrUniqueSN, ''),                   -- NEW
--								[strPeriodNameHOUR]							= NULLIF(chk.periodname, ''),             				-- Modified
--								[intPeriodNameHOURSeq]						= NULLIF(chk.periodseq, ''),							-- Modified
--								[intPeriodNameHOURLevel]					= NULLIF(chk.periodlevel, ''),							-- Modified
--								[strPeriodNameSHIFT]						= NULL,                   -- Modified
--								[intPeriodNameSHIFTSeq]						= NULL,                -- Modified
--								[intPeriodNameSHIFTLevel]					= NULL,              -- Modified
--								[strPeriodNameDAILY]						= NULL,                  -- Modified
--								[intPeriodNameDAILYSeq]						= NULL,                -- Modified
--								[intPeriodNameDAILYLevel]					= NULL,              -- Modified
--								[dtmDate]									= (CASE WHEN chk.trHeaderdate = '' THEN NULL ELSE left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) END),
--								[intDuration]								= NULLIF(chk.trHeaderduration, ''),
--								[intTill]									= NULLIF(chk.trHeadertill, ''),
--								[strCashier]								= NULLIF(chk.trHeadercashier, ''),
--								[intCashierPeriod]							= NULLIF(chk.cashierperiod, ''),
--								[intCashierPosNum]							= NULLIF(chk.cashierposNum, ''),
--								[intCashierEmpNum]							= NULLIF(chk.cashierempNum, ''),
--								[intCashierSysId]							= NULLIF(chk.cashiersysid, ''),
--								[intCashierDrawer]							= NULLIF(chk.cashierdrawer, ''),
--								[strOriginalCashier]						= CONVERT(NVARCHAR(100), ISNULL(NULLIF(chk.trHeaderoriginalCashier, ''), NULL)),
--								[intOriginalCashierPeriod]					= NULLIF(chk.originalCashierperiod, ''),
--								[intOriginalCashierPosNum]					= NULLIF(chk.originalCashierposNum, ''),
--								[intOriginalCashierEmpNum]					= NULLIF(chk.originalCashierempNum, ''),
--								[intOriginalCashierSysid]					= NULLIF(chk.originalCashiersysid, ''),
--								[intOriginalCashierDrawer]					= NULLIF(chk.originalCashierdrawer, ''),
--								[intStoreNumber]							= CONVERT(BIGINT, ISNULL(NULLIF(chk.trHeaderstoreNumber, ''), NULL)),
--								[strTrFuelOnlyCst]							= NULLIF(chk.trHeadertrFuelOnlyCst, ''),
--								[strPopDiscTran]							= NULLIF(chk.trHeaderpopDiscTran, ''),
--								[dblCoinDispensed]							= CONVERT(DECIMAL(18, 2), ISNULL(NULLIF(chk.trHeadercoinDispensed, ''), NULL)),

--								-- trValue
--								[dblTrValueTrTotNoTax]						= NULLIF(chk.trValuetrTotNoTax, ''),
--								[dblTrValueTrTotWTax]						= NULLIF(chk.trValuetrTotWTax, ''),
--								[dblTrValueTrTotTax]						= NULLIF(chk.trValuetrTotTax, ''),
--								[dblTaxAmtsTaxAmt]							= NULLIF(chk.taxAmtstaxAmt, ''),
--								[intTaxAmtsTaxAmtSysid]						= NULLIF(chk.taxAmtsysid, ''),
--								[strTaxAmtsTaxAmtCat]						= NULLIF(chk.taxAmtcat, ''),
--								[dblTaxAmtsTaxRate]							= NULLIF(chk.taxAmtstaxRate, ''),
--								[intTaxAmtsTaxRateSysid]					= NULLIF(chk.taxRatesysid, ''),
--								[strTaxAmtsTaxRateCat]						= NULLIF(chk.taxRatecat, ''),
--								[dblTaxAmtsTaxNet]							= NULLIF(chk.taxAmtstaxNet, ''),
--								[intTaxAmtsTaxNetSysid]						= NULLIF(chk.taxNetsysid, ''),
--								[strTaxAmtsTaxNetCat]						= NULLIF(chk.taxNetcat, ''),
--								[dblTaxAmtsTaxAttribute]					= NULLIF(chk.taxAmtstaxAttribute, ''),
--								[intTaxAmtsTaxAttributeSysid]				= NULLIF(chk.taxAttributesysid, ''),
--								[strTaxAmtsTaxAttributeCat]					= NULLIF(chk.taxAttributecat, ''),
--								[dblTrCurrTot]								= NULLIF(chk.trValuetrCurrTot, ''),
--								[strTrCurrTotLocale]						= NULLIF(chk.trCurrTotlocale, ''),
--								[dblTrSTotalizer]							= NULLIF(chk.trValuetrSTotalizer, ''),
--								[dblTrGTotalizer]							= NULLIF(chk.trValuetrGTotalizer, ''),
--								[dblTrFstmpTrFstmpTot]						= NULLIF(chk.trFstmptrFstmpTot, ''),
--								[dblTrFstmpTrFstmpTax]						= NULLIF(chk.trFstmptrFstmpTax, ''),
--								[dblTrFstmpTrFstmpChg]						= NULLIF(chk.trFstmptrFstmpChg, ''),
--								[dblTrFstmpTrFstmpTnd]						= NULLIF(chk.trFstmptrFstmpTnd, ''),

--								-- trLoyalty
--								[strTrLoyaltyProgramProgramID]				= NULLIF(chk.trLoyaltyProgramprogramID, ''),
--								[dblTrLoyaltyProgramTrloSubTotal]			= NULLIF(chk.trLoyaltyProgramtrloSubTotal, ''),
--								[dblTrLoyaltyProgramTrloAutoDisc]			= NULLIF(chk.trLoyaltyProgramtrloAutoDisc, ''),
--								[dblTrLoyaltyProgramTrloCustDisc]			= NULLIF(chk.trLoyaltyProgramtrloCustDisc, ''),
--								[strTrLoyaltyProgramTrloAccount]			= NULLIF(chk.trLoyaltyProgramtrloAccount, ''),
--								[strTrLoyaltyProgramTrloEntryMeth]			= NULLIF(chk.trLoyaltyProgramtrloEntryMeth, ''),
--								[strTrLoyaltyProgramTrloAuthReply]			= NULLIF(chk.trLoyaltyProgramtrloAuthReply, ''),

--								-- trCshBk
--								[dblTrCshBkAmt]								= NULLIF(chk.trCshBktrCshBkAmt, ''),
--								[dblTrCshBkAmtMop]							= NULLIF(chk.trCshBkAmtmop, ''),
--								[dblTrCshBkAmtCat]							= NULLIF(chk.trCshBkAmtcat, ''),
--								[strCustDOB]								= NULLIF(chk.trValuecustDOB, ''),
--								[dblRecallAmt]								= NULLIF(chk.trValuerecallAmt, ''),

--								-- trExNetProds
--								[intTrExNetProdTrENPPcode]					= NULLIF(chk.trExNetProdtrENPPcode, ''),							--***--
--								[dblTrExNetProdTrENPAmount]					= NULLIF(chk.trExNetProdtrENPAmount, ''),						--***--
--								[dblTrExNetProdTrENPItemCnt]				= NULLIF(chk.trExNetProdtrENPItemCnt, ''),                      -- NEW

--								-- trLines
--								[strTrLineType]								= NULLIF(chk.trLinetype, ''),
--								[ysnTrLineDuplicate]						= CASE WHEN NULLIF(chk.trLineduplicate, '') = 'true' THEN 1 ELSE 0 END,           -- NEW
--								[strTrLineUnsettled]						= NULLIF(chk.trLineunsettled, ''),
--								[dblTrlTaxesTrlTax]							= NULLIF(chk.trlTaxestrlTax, ''),
--								[intTrlTaxesTrlTaxSysid]					= NULLIF(chk.trlTaxsysid, ''),
--								[strTrlTaxesTrlTaxCat]						= NULLIF(chk.trlTaxcat, ''),
--								[intTrlTaxesTrlTaxReverse]					= NULLIF(chk.trlTaxreverse, ''),
--								[dblTrlTaxesTrlRate]						= NULLIF(chk.trlTaxestrlRate, ''),
--								[intTrlTaxesTrlRateSysid]					= NULLIF(chk.trlRatesysid, ''),
--								[strTrlTaxesTrlRateCat]						= NULLIF(chk.trlRatecat, ''),
--								-- trlFlags
--								[strTrlFlagsTrlBdayVerif]					= NULLIF(chk.trlFlagstrlBdayVerif, '') ,
--								[strTrlFlagsTrlFstmp]                       = NULL,														-- NEW
--								[strTrlFlagsTrlPLU]							= NULLIF(chk.trlFlagstrlPLU, ''),
--								[strTrlFlagsTrlUpdPluCust]					= NULLIF(chk.trlFlagstrlUpdPluCust, ''),
--								[strTrlFlagsTrlUpdDepCust]					= NULLIF(chk.trlFlagstrlUpdDepCust, ''),
--								[strTrlFlagsTrlCatCust]						= NULLIF(chk.trlFlagstrlCatCust, ''),
--								[strTrlFlagsTrlFuelSale]					= NULLIF(chk.trlFlagstrlFuelSale, ''),
--								[strTrlFlagsTrlMatch]						= NULLIF(chk.trlFlagstrlMatch, ''),
--								[strTrlDept]								= NULLIF(chk.trLinetrlDept, ''),
--								[strTrlDeptType]							= NULLIF(chk.trlDepttype, ''),
--								[intTrlDeptNumber]							= NULLIF(chk.trlDeptnumber, ''),
--								[strTrlCat]									= NULLIF(chk.trLinetrlCat, ''),                 			  -- trLine type="preFuel"
--								[strTrlCatNumber]							= NULLIF(chk.trlCatnumber, ''),               				  -- trLine type="preFuel"
--								[strTrlNetwCode]							= NULLIF(chk.trLinetrlNetwCode, ''),
--								[dblTrlQty]									= NULLIF(chk.trLinetrlQty, ''),
--								[dblTrlSign]								= NULLIF(chk.trLinetrlSign, ''),
--								[dblTrlSellUnitPrice]						= NULLIF(chk.trLinetrlSellUnit, ''),
--								[dblTrlUnitPrice]							= NULLIF(chk.trLinetrlUnitPrice, ''),
--								[dblTrlLineTot]								= NULLIF(chk.trLinetrlLineTot, ''),
--								[strTrlDesc]								= NULLIF(chk.trLinetrlDesc, ''),

--								-- NOTE: in the future if we will be supporting PASSPORT for rebate file
--								-- Assumption
--								-- COMMANDER file  -  check digit is included
--								-- PASSPORT  file  -  check digit is NOT included
--								--
--								-- Check Register Class by
--								--SELECT TOP 1
--								--	r.strRegisterClass
--								--FROM tblSTTranslogRebates tlr
--								--INNER JOIN tblSTCheckoutHeader chk
--								--	ON tlr.intCheckoutId = chk.intCheckoutId
--								--INNER JOIN tblSTStore st
--								--	ON chk.intStoreId = st.intStoreId
--								--INNER JOIN tblSTRegister r
--								--	ON st.intRegisterId = r.intRegisterId
--								--WHERE chk.intCheckoutId = @intCheckoutId
--								--
--								-- IF strRegisterClass = PASSPORT
--								--	 THEN INSERT UPC with check digit to column 'strTrlUPC'						(Since PASSPORT is not generating UPC with check digit then calculate check digit using chk.trLinetrlUPC)
--								--	 THEN INSERT UPC without check digit to column 'strTrlUPCwithoutCheckDigit' (Just insert using chk.trLinetrlUPC since PASSPORT is generating UPC without check digit)
--								--
--								-- ELSE IF strRegisterClass = COMMANDER
--								--	 THEN INSERT UPC with check digit to column 'strTrlUPC'						(Since COMMANDER is generating UPC with check digit then just use chk.trLinetrlUPC)
--								--	 THEN INSERT UPC without check digit to column 'strTrlUPCwithoutCheckDigit' (Just remove the last digit of chk.trLinetrlUPC)
--								--[strTrlUPC]									= NULLIF(chk.trLinetrlUPC, ''),
--								--[strTrlUPCwithoutCheckDigit]				= CASE
--								--												WHEN (chk.trLinetrlUPC IS NOT NULL AND chk.trLinetrlUPC != '' AND LEN(chk.trLinetrlUPC) = 14 AND SUBSTRING(chk.trLinetrlUPC, 1, 1) = '0')
--								--													THEN LEFT (chk.trLinetrlUPC, LEN (chk.trLinetrlUPC)-1) -- Remove Check digit on last character
--								--												ELSE NULL
--								--											END,
--								[strTrlUPC]									= CASE
--																				WHEN (@strRegisterClass = N'SAPPHIRE/COMMANDER')
--																					THEN NULLIF(chk.trLinetrlUPC, '')
--																				WHEN (@strRegisterClass = N'PASSPORT')
--																					THEN NULLIF(chk.trLinetrlUPC, '') + CAST(dbo.fnSTGenerateCheckDigit(dbo.fnSTGenerateCheckDigit(NULLIF(chk.trLinetrlUPC, ''))) AS NVARCHAR(1))
--																				ELSE
--																					NULLIF(chk.trLinetrlUPC, '')
--																			END,
--								[strTrlUPCwithoutCheckDigit]				= CASE
--																				WHEN (@strRegisterClass = N'SAPPHIRE/COMMANDER')
--																					THEN CASE
--																							WHEN (chk.trLinetrlUPC IS NOT NULL AND chk.trLinetrlUPC != '' AND LEN(chk.trLinetrlUPC) = 14 AND SUBSTRING(chk.trLinetrlUPC, 1, 1) = '0')
--																								THEN LEFT (chk.trLinetrlUPC, LEN (chk.trLinetrlUPC)-1) -- Remove Check digit on last character
--																							ELSE NULL
--																						END
--																				WHEN (@strRegisterClass = N'PASSPORT')
--																					THEN NULLIF(chk.trLinetrlUPC, '')
--																				ELSE
--																					NULLIF(chk.trLinetrlUPC, '')
--																			END,


--								[strTrlModifier]							= NULLIF(chk.trLinetrlModifier, ''),
--								[strTrlUPCEntryType]						= NULLIF(chk.trLinetrlUPCEntry, ''),

--								-- trPaylines
--								[strTrPaylineType]							= NULLIF(chk.trPaylinetype, ''),
--								[intTrPaylineSysid]							= NULLIF(chk.trPaylinesysid, ''),
--								[strTrPaylineLocale]						= NULLIF(chk.trPaylinelocale, ''),
--								[strTrpPaycode]								= NULLIF(chk.trPaylinetrpPaycode, ''),
--								[intTrpPaycodeCat]							= NULLIF(chk.trpPaycodecat, ''),			--***--
--								[intTrpPaycodeMop]							= NULLIF(chk.trpPaycodemop, ''),			--***--
--								[strTrPaylineNacstendersubcode]				= NULLIF(chk.trpPaycodenacstendersubcode, ''),
--								[strTrPaylineNacstendercode]				= NULLIF(chk.trpPaycodenacstendercode, ''),
--								[dblTrpAmt]									= NULLIF(chk.trPaylinetrpAmt, ''),
--								[strTrpCardInfoTrpcAccount]					= NULLIF(chk.trpCardInfotrpcAccount, ''),
--								[strTrpCardInfoTrpcCCName]					= NULLIF(chk.trpCardInfotrpcCCName, ''),
--								[intTrpCardInfoTrpcCCNameProdSysid]			= NULLIF(chk.trpcCCNamesysid, ''),					-- NULLIF(chk.trpcCCNameprodSysid, ''),
--								[strTrpCardInfoTrpcHostID]					= NULLIF(chk.trpCardInfotrpcHostID, ''),
--								[strTrpCardInfoTrpcAuthCode]				= NULLIF(chk.trpCardInfotrpcAuthCode, ''),
--								[strTrpCardInfoTrpcAuthSrc]					= NULLIF(chk.trpCardInfotrpcAuthSrc, ''),
--								[strTrpCardInfoTrpcTicket]					= NULLIF(chk.trpCardInfotrpcTicket, ''),
--								[strTrpCardInfoTrpcEntryMeth]				= NULLIF(chk.trpCardInfotrpcEntryMeth, ''),
--								[strTrpCardInfoTrpcBatchNr]					= NULLIF(chk.trpCardInfotrpcBatchNr, ''),
--								[strTrpCardInfoTrpcSeqNr]					= NULLIF(chk.trpCardInfotrpcSeqNr, ''),
--								[dtmTrpCardInfoTrpcAuthDateTime]			= (CASE WHEN chk.trpCardInfotrpcAuthDateTime = '' THEN NULL ELSE left(REPLACE(chk.trpCardInfotrpcAuthDateTime, 'T', ' '), len(chk.trpCardInfotrpcAuthDateTime) - 6) END),
--								[strTrpCardInfoTrpcRefNum]					= NULLIF(chk.trpCardInfotrpcRefNum, ''),
--								-- trpcMerchInfo
--								[strTrpCardInfoMerchInfoTrpcmMerchID] = NULLIF(chk.trpcMerchInfotrpcmMerchID, ''),
--								[strTrpCardInfoMerchInfoTrpcmTermID] = NULLIF(chk.trpcMerchInfotrpcmTermID, ''),
--								-- trlMixMatches
--								[strTrlMatchLineTrlMatchName] = NULLIF(chk.trlMatchLinetrlMatchName, ''),
--								[dblTrlMatchLineTrlMatchQuantity] = NULLIF(chk.trlMatchLinetrlMatchQuantity, ''),
--								[dblTrlMatchLineTrlMatchPrice] = NULLIF(chk.trlMatchLinetrlMatchPrice, ''),
--								[intTrlMatchLineTrlMatchMixes] = NULLIF(chk.trlMatchLinetrlMatchMixes, ''),
--								[dblTrlMatchLineTrlPromoAmount] = NULLIF(chk.trlMatchLinetrlPromoAmount, ''),
--								[strTrlMatchLineTrlPromotionID] = NULLIF(chk.trlMatchLinetrlPromotionID, ''),
--								[strTrlMatchLineTrlPromotionIDPromoType] = NULLIF(chk.trlPromotionIDpromotype, ''),
--								[intTrlMatchLineTrlMatchNumber] = NULLIF(chk.trlMatchLinetrlMatchNumber, ''),      -- LAST

--								[intStoreId] = @intStoreId,
--								[intCheckoutId] = @intCheckoutId,
--								[ysnSubmitted] = 0,
--								[ysnPMMSubmitted] = 0,
--								[ysnRJRSubmitted] = 0,
--								[intConcurrencyId] = 0
--							FROM #tempCheckoutInsert chk
--							JOIN
--							(
--								SELECT c.trHeadertermMsgSN as termMsgSN
--								FROM #tempCheckoutInsert c
--								--WHERE c.trLinetrlDept IN (
--								--							SELECT strDepartment FROM @TempTableDepartments
--								--						 )
--									WHERE (c.transtype = 'sale'
--									OR c.transtype = 'network sale')
--									AND c.trHeaderdate != ''
--								GROUP BY c.trHeadertermMsgSN
--							) x ON x.termMsgSN = chk.trHeadertermMsgSN
--							WHERE NOT EXISTS
--							(
--								SELECT *
--								FROM dbo.tblSTTranslogRebates TR
--								WHERE TR.dtmDate = CAST(left(REPLACE(chk.trHeaderdate, 'T', ' '), len(chk.trHeaderdate) - 6) AS DATETIME)
--									AND TR.intTermMsgSNterm = chk.termMsgSNterm
--									AND TR.intTermMsgSN = chk.trHeadertermMsgSN
--									AND TR.intTrTickNumPosNum = chk.cashierposNum
--									AND TR.intTrTickNumTrSeq  = chk.trTickNumtrSeq
--									AND TR.strTransType COLLATE DATABASE_DEFAULT = chk.transtype COLLATE DATABASE_DEFAULT
--									AND TR.intStoreNumber = chk.trHeaderstoreNumber
--							)
--							ORDER BY chk.trHeadertermMsgSN, chk.intRowCount ASC

--							SET @strStatusMsg = 'Success'
--							GOTO ExitWithCommit

--					END TRY
--					BEGIN CATCH
--						SET @strStatusMsg = 'Transaction Log Rebates: ' + ERROR_MESSAGE()
--						GOTO ExitWithRollback
--					END CATCH

--				END
--			ELSE IF(@intCountRows = 0)
--				BEGIN
--					SET @strStatusMsg = 'Transaction Log file is already been exported.'
--					SET @intCountRows = 0

--					-- ==================================================================================================================
--					-- START - Insert message if Transaction Log is already been exported
--					-- ==================================================================================================================
--					INSERT INTO tblSTCheckoutErrorLogs
--					(
--							strErrorType
--							, strErrorMessage
--							, strRegisterTag
--							, strRegisterTagValue
--							, intCheckoutId
--							, intConcurrencyId
--					)
--					VALUES
--					(
--							'Transaction Log'
--							, @strStatusMsg
--							, ''
--							, ''
--							, @intCheckoutId
--							, 1
--					)

--					GOTO ExitWithCommit
--					-- ==================================================================================================================
--					-- END - Insert message if Transaction Log is already been exported
--					-- ==================================================================================================================

--					GOTO ExitWithCommit
--				END
--			END
--		ELSE IF(@intTableRowCount = 0)
--			BEGIN
--				SET @strStatusMsg = 'Selected register file is empty'
--				SET @intCountRows = 0
--				GOTO ExitWithCommit
--			END

--	END TRY

--	BEGIN CATCH
--		SET @intCountRows = 0
--		SET @strStatusMsg = ERROR_MESSAGE()
--		GOTO ExitWithCommit
--	END CATCH
--END


--ExitWithCommit:
--	-- Commit Transaction
--	COMMIT TRANSACTION --@TransactionName
--	GOTO ExitPost


--ExitWithRollback:
--    -- Rollback Transaction here
--	IF @@TRANCOUNT > 0
--		BEGIN
--			ROLLBACK TRANSACTION --@TransactionName
--		END

--ExitPost: