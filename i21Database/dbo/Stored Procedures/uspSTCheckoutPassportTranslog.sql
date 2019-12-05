CREATE PROCEDURE [dbo].[uspSTCheckoutPassportTranslog]
	@intStoreNo										INT,
	@UDT_Translog StagingTransactionLogPassport		READONLY,
	@ysnSuccess										BIT				OUTPUT,
	@strMessage										NVARCHAR(1000)	OUTPUT,
	@intCountRows									INT				OUTPUT
AS
BEGIN
	
	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;
    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTCheckoutPassportTranslog' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY
		
		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END

		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END

		
		-- COUNT
		DECLARE @intTableRowCount AS INT = 0
		SELECT @intTableRowCount = COUNT(*) FROM @UDT_Translog

		IF(@intTableRowCount > 0)
			BEGIN
				
				--Get StoreId
				DECLARE @intStoreId			INT,
						@strRegisterClass	NVARCHAR(50)

				SELECT
					@intStoreId			= st.intStoreId,
					@strRegisterClass	= r.strRegisterClass
				FROM tblSTStore st
				INNER JOIN tblSTRegister r
					ON st.intRegisterId = r.intRegisterId
				WHERE st.intStoreNo = @intStoreNo


				-- ==================================================================================================================
				-- START - Validate if Store has department setup for rebate
				-- ==================================================================================================================
				IF EXISTS(SELECT TOP 1 1 FROM tblSTStoreRebates WHERE intStoreId = @intStoreId)
					BEGIN
						
						--Get Number of rows
						SELECT @intCountRows = COUNT(intRowCount)
						FROM @UDT_Translog chk
						JOIN
						(
							SELECT c.intTransactionID as intTransactionID
							FROM @UDT_Translog c
							GROUP BY c.intTransactionID
						) x ON x.intTransactionID = chk.intTransactionID
						WHERE NOT EXISTS
						(
							SELECT *
							FROM dbo.tblSTTranslogRebatesPassport TR
							WHERE TR.intTransactionID = chk.intTransactionID
								AND TR.intStoreId = @intStoreId
						)


						
						IF(@intCountRows > 0)
							BEGIN
								
								-- Check Line
								-- 1. TenderInfo - strTenderCode='cash' AND strChangeFlag IN ('yes','no')
								-- 2. ItemLine - strItemlineItemCodeFormat IN ('upcA', 'upcE', 'ean8', 'ean13', 'plu', 'gtin', 'rss14', 'none') AND strItemLinePOSCode IS NOT NULL
								-- 3. FuelLine - strFuelGradeID IS NOT NULL AND intFuelPositionID IS NOT NULL
								-- 4. TransactionTax - intTaxLevelID IS NOT NULL AND dblTaxablrSalesAmount IS NOT NULL

								INSERT INTO tblSTTranslogRebatesPassport
								(
									[intScanTransactionId],
									[strTrlUPCwithoutCheckDigit],

									-- Header
									[strNAXMLPOSJournalVersion],
									[intTransmissionHeaderStoreLocationID],
									[strTransmissionHeaderVendorName],
									[strTransmissionHeaderVendorModelVersion],
									[intReportSequenceNumber],
									[intPrimaryReportPeriod],
									[intSecondaryReportPeriod],
									[dtmBeginDate],
									[dtmBeginTime],
									[dtmEndDate],
									[dtmEndTime],

									-- Body
									-- SaleEvent
									[intEventSequenceID],
									[strTrainingModeFlagValue],
									[intCashierID],
									[intRegisterID],
									[strTillID],
									[strOutsideSalesFlagValue],
									[intTransactionID],
									[dtmEventStartDate],
									[dtmEventStartTime],
									[dtmEventEndDate],
									[dtmEventEndTime],
									[dtmBusinessDate],
									[dtmReceiptDate],
									[dtmReceiptTime],
									[strOfflineFlagValue],
									[strSuspendFlagValue],

									-- LinkedTransactionInfo
									[intOriginalStoreLocationID],
									[intOriginalRegisterID],
									[intOriginalTransactionID],
									[dtmOriginalEventStartDate],
									[dtmOriginalEventStartTime],
									[dtmOriginalEventEndDate],
									[dtmOriginalEventEndTime],
									[strTransactionLinkReason],

									-- TransactionLine
									[strTransactionLineStatus],

									-- ItemLine
									-- > ItemCode
									[strItemLineItemCodeFormat],
									[strItemLinePOSCode],
									[strItemLinePOSCodeModifier],
									[strItemLinePOSCodeModifierName],
									-- > ItemTax
									[intItemLineTaxLevelID],
									-- > FuelLine
									[strFuelGradeID],
									[intFuelPositionID],
									[strPriceTierCode],
									[intTimeTierCode],
									[strServiceLevelCode],
									-- > TransactionTax
									[intTaxLevelID],
									[dblTaxableSalesAmount],
									[dblTaxCollectedAmount],
									[dblTaxableSalesRefundedAmount],
									[dblTaxRefundedAmount],
									[dblTaxExemptSalesAmount],
									[dblTaxExemptSalesRefundedAmount],
									[dblTaxForgivenSalesAmount],
									[dblTaxForgivenSalesRefundedAmount],
									[dblTaxForgivenAmount],
									-- > MerchandiseCodeLine
									[intMerchandiseCode],
									[strMerchandiseCodeLineDescription],
									[dblActualSalesPrice],
									-- > Promotion
									[strPromotionID],
									[strPromotionIDType],
									[strPromotionReason],
									[dblPromotionAmount],

									[strLineDescription],
									[strLineEntryMethod],
									[dblLineActualSalesPrice],
									[intLineMerchandiseCode],
									[intItemLineSellingUnits],
									[dblLineRegularSellPrice],
									[dblLineSalesQuantity],
									[dblLineSalesAmount],
									-- > SalesRestriction
									[strSalesRestrictFlagValue],
									[strSalesRestrictFlagType],

									-- TenderInfo
									[strTenderCode],
									[strTenderSubCode],
									[dblTenderAmount],
									[strChangeFlag],
									-- > Authorization
									[strPreAuthorizationFlag],
									[strRequestedAmount],
									[strAuthorizationResponseCode],
									[strAuthorizationResponseDescription],
									[strApprovalReferenceCode],
									[strReferenceNumber],
									[strProviderID],
									[dtmAuthorizationDate],
									[dtmAuthorizationTime],
									[strHostAuthorizedFlag],
									[strAuthorizationApprovalDescription],
									[strAuthorizingTerminalID],
									[strForceOnLineFlag],
									[strElectronicSignature],
									[dblAuthorizedChargeAmount],

									-- TransactionSummary
									[dblTransactionTotalGrossAmount],
									[dblTransactionTotalNetAmount],
									[dblTransactionTotalTaxSalesAmount],
									[dblTransactionTotalTaxExemptAmount],
									[dblTransactionTotalTaxNetAmount],
									[dblTransactionTotalGrandAmount],
									[strTransactionTotalGrandAmountDirection],

									[intStoreId],
									[ysnSubmitted],
									[ysnPMMSubmitted],
									[ysnRJRSubmitted],
									[intConcurrencyId]
								)
								SELECT 
									[intScanTransactionId]										= NULL,
									[strTrlUPCwithoutCheckDigit]								= NULL,

									-- Header
									[strNAXMLPOSJournalVersion]									= trns.strNAXMLPOSJournalVersion,
									[intTransmissionHeaderStoreLocationID]						= trns.intTransmissionHeaderStoreLocationID,
									[strTransmissionHeaderVendorName]							= trns.strTransmissionHeaderVendorName,
									[strTransmissionHeaderVendorModelVersion]					= trns.strTransmissionHeaderVendorModelVersion,
									[intReportSequenceNumber]									= trns.intReportSequenceNumber,
									[intPrimaryReportPeriod]									= trns.intPrimaryReportPeriod,
									[intSecondaryReportPeriod]									= trns.intSecondaryReportPeriod,
									[dtmBeginDate]												= trns.dtmBeginDate,
									[dtmBeginTime]												= trns.dtmBeginTime,
									[dtmEndDate]												= trns.dtmEndDate,
									[dtmEndTime]												= trns.dtmEndTime,

									-- Body
									-- SaleEvent
									[intEventSequenceID]										= trns.intEventSequenceID,
									[strTrainingModeFlagValue]									= trns.strTrainingModeFlagValue,
									[intCashierID]												= trns.intCashierID,
									[intRegisterID]												= trns.intRegisterID,
									[strTillID]													= trns.strTillID,
									[strOutsideSalesFlagValue]									= trns.strOutsideSalesFlagValue,
									[intTransactionID]											= trns.intTransactionID,
									[dtmEventStartDate]											= dtmEventStartDate,
									[dtmEventStartTime]											= dtmEventStartTime,
									[dtmEventEndDate],
									[dtmEventEndTime],
									[dtmBusinessDate],
									[dtmReceiptDate],
									[dtmReceiptTime],
									[strOfflineFlagValue],
									[strSuspendFlagValue],

									-- LinkedTransactionInfo
									[intOriginalStoreLocationID],
									[intOriginalRegisterID],
									[intOriginalTransactionID],
									[dtmOriginalEventStartDate],
									[dtmOriginalEventStartTime],
									[dtmOriginalEventEndDate],
									[dtmOriginalEventEndTime],
									[strTransactionLinkReason],

									-- TransactionLine
									[strTransactionLineStatus],

									-- ItemLine
									-- > ItemCode
									[strItemLineItemCodeFormat],
									[strItemLinePOSCode],
									[strItemLinePOSCodeModifier],
									[strItemLinePOSCodeModifierName],
									-- > ItemTax
									[intItemLineTaxLevelID],
									-- > FuelLine
									[strFuelGradeID],
									[intFuelPositionID],
									[strPriceTierCode],
									[intTimeTierCode],
									[strServiceLevelCode],
									-- > TransactionTax
									[intTaxLevelID],
									[dblTaxableSalesAmount],
									[dblTaxCollectedAmount],
									[dblTaxableSalesRefundedAmount],
									[dblTaxRefundedAmount],
									[dblTaxExemptSalesAmount],
									[dblTaxExemptSalesRefundedAmount],
									[dblTaxForgivenSalesAmount],
									[dblTaxForgivenSalesRefundedAmount],
									[dblTaxForgivenAmount],
									-- > MerchandiseCodeLine
									[intMerchandiseCode],
									[strMerchandiseCodeLineDescription],
									[dblActualSalesPrice],
									-- > Promotion
									[strPromotionID],
									[strPromotionIDType],
									[strPromotionReason],
									[dblPromotionAmount],

									[strLineDescription],
									[strLineEntryMethod],
									[dblLineActualSalesPrice],
									[intLineMerchandiseCode],
									[intItemLineSellingUnits],
									[dblLineRegularSellPrice],
									[dblLineSalesQuantity],
									[dblLineSalesAmount],
									-- > SalesRestriction
									[strSalesRestrictFlagValue],
									[strSalesRestrictFlagType],

									-- TenderInfo
									[strTenderCode],
									[strTenderSubCode],
									[dblTenderAmount],
									[strChangeFlag],
									-- > Authorization
									[strPreAuthorizationFlag],
									[strRequestedAmount],
									[strAuthorizationResponseCode],
									[strAuthorizationResponseDescription],
									[strApprovalReferenceCode],
									[strReferenceNumber],
									[strProviderID],
									[dtmAuthorizationDate],
									[dtmAuthorizationTime],
									[strHostAuthorizedFlag],
									[strAuthorizationApprovalDescription],
									[strAuthorizingTerminalID],
									[strForceOnLineFlag],
									[strElectronicSignature],
									[dblAuthorizedChargeAmount],

									-- TransactionSummary
									[dblTransactionTotalGrossAmount],
									[dblTransactionTotalNetAmount],
									[dblTransactionTotalTaxSalesAmount],
									[dblTransactionTotalTaxExemptAmount],
									[dblTransactionTotalTaxNetAmount],
									[dblTransactionTotalGrandAmount],
									[strTransactionTotalGrandAmountDirection],

									[intStoreId]												= @intStoreId,
									[ysnSubmitted]												= CAST(0 AS BIT),
									[ysnPMMSubmitted]											= CAST(0 AS BIT),
									[ysnRJRSubmitted]											= CAST(0 AS BIT),
									[intConcurrencyId]											= 1
								FROM 
									@UDT_Translog trns
								JOIN
								(
									SELECT c.intTransactionID as intTransactionID
									FROM @UDT_Translog c
									GROUP BY c.intTransactionID
								) x ON x.intTransactionID = trns.intTransactionID
								WHERE NOT EXISTS
								(
									SELECT *
									FROM dbo.tblSTTranslogRebatesPassport TR
									WHERE TR.intTransactionID = trns.intTransactionID
										AND TR.intStoreId = @intStoreId
								)
								ORDER BY trns.intTransactionID ASC
									


								SET @ysnSuccess = CAST(1 AS BIT)
								SET @strMessage = 'Success'

								GOTO ExitWithCommit

							END
						ELSE IF(@intCountRows = 0)
							BEGIN
								SET @ysnSuccess = CAST(0 AS BIT)
								SET @strMessage = 'Transaction Log file is already been exported.'
							END


					END
				ELSE 
					BEGIN
						SET @ysnSuccess = CAST(0 AS BIT)
						SET @strMessage = 'Store has no department setup for rebate.'
					END
				-- ==================================================================================================================
				-- END - Validate if Store has department setup for rebate
				-- ==================================================================================================================

			END
		ELSE IF(@intTableRowCount = 0)
			BEGIN
				SET @ysnSuccess = CAST(0 AS BIT)
				SET @strMessage = 'CPJR file is empty'
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