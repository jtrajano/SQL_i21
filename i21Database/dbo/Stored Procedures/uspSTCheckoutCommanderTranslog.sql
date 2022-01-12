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
						@strRegisterClass	NVARCHAR(50),
						@intRegisterClassId INT

				SELECT
					@intStoreId			= chk.intStoreId,
					@strRegisterClass	= r.strRegisterClass,
					@intRegisterClassId = setup.intRegisterSetupId
				FROM tblSTCheckoutHeader chk
				INNER JOIN tblSTStore st
					ON chk.intStoreId = st.intStoreId
				INNER JOIN tblSTRegister r
					ON st.intRegisterId = r.intRegisterId
				INNER JOIN tblSTRegisterSetup setup
					ON r.strRegisterClass = setup.strRegisterClass
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
									OR c.strTransType = 'network sale'
									OR c.strTransType = 'void'
									OR c.strTransType = 'refund void'
									OR c.strTransType = 'refund sale'
									OR c.strTransType = 'refund network sale'
									OR c.strTransType = 'suspended sale'
									OR c.strTransType = 'suspended network sale')
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
								OR c.strTransType = 'network sale'
								OR c.strTransType = 'void'
								OR c.strTransType = 'refund void'
								OR c.strTransType = 'refund sale'
								OR c.strTransType = 'refund network sale'
								OR c.strTransType = 'suspended sale'
								OR c.strTransType = 'suspended network sale')
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
							[dblTrlPrcOvrd],
							[strTrlDesc],
							[strTrlUPC],
							[strTrlModifier],
							[strTrlUPCEntryType],
							[strTrloLnItemDiscProgramId],
							[dblTrloLnItemDiscDiscAmt],
							[dblTrloLnItemDiscQty],
							[intTrloLnItemDiscTaxCred],

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
							[intScanTransactionId]				= NULLIF(ROW_NUMBER() OVER(PARTITION BY CAST(intTermMsgSN AS BIGINT), strTrpPaycode ORDER BY intRowCount ASC), ''),
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
							[dblTrlPrcOvrd]						= dblTrlPrcOvrd,
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
							[strTrloLnItemDiscProgramId]		= strTrloLnItemDiscProgramId,
							[dblTrloLnItemDiscDiscAmt]			= dblTrloLnItemDiscDiscAmt,
							[dblTrloLnItemDiscQty]				= dblTrloLnItemDiscQty,
							[intTrloLnItemDiscTaxCred]			= intTrloLnItemDiscTaxCred,

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

							[intRegisterClassId]					= @intRegisterClassId,
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
										OR c.strTransType = 'network sale'
										OR c.strTransType = 'void'
										OR c.strTransType = 'refund sale'
										OR c.strTransType = 'refund network sale'
										OR c.strTransType = 'refund void'
										OR c.strTransType = 'suspended sale'
										OR c.strTransType = 'suspended network sale')
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