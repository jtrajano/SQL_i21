--
	--This Stored Procedure is used in Copy To Store screen. Go to Store -> Select Store -> Duplicate. 
--
CREATE PROCEDURE [dbo].[uspSTDuplicateStore]
	@strToLocation				NVARCHAR(MAX),
	@intStoreId					INT,
	@chkDepartment				BIT,
	@chkTaxFile					BIT,
	@chkMOP						BIT,
	@chkVendorCrossReference	BIT,
	@chkSetupDetails			BIT,
	@chkRebates					BIT,
	@chkPumpItems				BIT,
	@chkMetrics					BIT,
	@chkATMFundSetup			BIT,
	@chkChangeFundSetup			BIT,
	@ysnSuccess					BIT OUTPUT,
	@strResultMessage			VARCHAR(MAX) OUTPUT
AS
BEGIN

BEGIN TRANSACTION

	BEGIN TRY
	
	IF OBJECT_ID('tempdb..#tmpToLocation') IS NULL 
		BEGIN

			CREATE TABLE #tmpToLocation (
				intLocationId INT 
			)
		END
	
	IF OBJECT_ID('tempdb..#tmpToLocationValidate') IS NULL 
		BEGIN

			CREATE TABLE #tmpToLocationValidate (
				intLocationId INT 
			)
		END
	 

	INSERT INTO #tmpToLocation (
		intLocationId
	)
	SELECT DISTINCT intID AS intLocationId 
	FROM [dbo].[fnGetRowsFromDelimitedValues](@strToLocation)

	
	INSERT INTO #tmpToLocationValidate (
		intLocationId
	)
	SELECT DISTINCT intID AS intLocationId 
	FROM [dbo].[fnGetRowsFromDelimitedValues](@strToLocation)


	DECLARE @newStoreTransactionId INT = 0
	SELECT @newStoreTransactionId = MAX(intStoreNo) FROM tblSTStore 
	SET @newStoreTransactionId = @newStoreTransactionId + 1

	DECLARE @NewStoreId INT
	DECLARE @intLocationId INT
	DECLARE @intSourceLocationId INT
	DECLARE @intLocationCount INT
	DECLARE @ysnValidateSuccess BIT = 'false'

	SET @intLocationCount = (SELECT COUNT('') FROM #tmpToLocation)

	--Validate first if selected TO Locations are already existing. If ALL LOCATIONS are existing, do not proceed
	WHILE EXISTS (SELECT * FROM #tmpToLocationValidate)
		BEGIN
			SELECT TOP 1 @intLocationId = intLocationId FROM #tmpToLocationValidate
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intCompanyLocationId = @intLocationId)
				BEGIN
					SET @ysnValidateSuccess = 'true'
				END

			DELETE FROM #tmpToLocationValidate
			WHERE intLocationId = @intLocationId
		END

	IF @ysnValidateSuccess = 'false'
		BEGIN
			SET @ysnSuccess = 'false'
			SET @strResultMessage = 'Selected location/s are already existing'

			COMMIT
			RETURN
		END
	

	--Start Processing of creation of store
	WHILE EXISTS (SELECT * FROM #tmpToLocation)
		BEGIN
			SELECT TOP 1 @intLocationId = intLocationId FROM #tmpToLocation
			SELECT TOP 1 @intSourceLocationId = intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId

			IF NOT EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intCompanyLocationId = @intLocationId)
				BEGIN
						
					--DETAILS & SETUP TAB--
					INSERT INTO tblSTStore
					(
							intStoreNo
						,strDescription
						,strRegion
						,strDistrict
						,strAddress
						,strCity
						,strState
						,strCountry
						,strZipCode
						,strPhone
						,strFax
						,strEmail
						,strWebsite
						,intProfitCenter
						,ysnStoreOnHost
						,strPricebookAutomated
						,strHandheldCostBasis
						,intDefaultVendorId
						,intCompanyLocationId
						,strGLCoId
						,strARCoId
						,intNextOrderNo
						,ysnUsePricebook
						,intMaxPlu
						,ysnUseLargePlu
						,ysnUseCfn
						,strCfnSiteId
						,strManagersName
						,strManagersPassword
						,ysnInterfaceChecksToCheckbook
						,strCheckbook
						,strQuickbookInterfaceClass
						,strBarcodePrinterName
						,dblServiceChargeRate
						,ysnUseArStatements
						--,dtmLastShiftOpenDate
						--,intLastShiftNo
						--,dtmLastPhysicalImportDate
						--,dtmLastStatementRollDate
						,ysnShiftPhysicalQuantityRecieved
						,ysnShiftPhysicalQuantitySold
						,strHandheldDeviceModel
						,strDepositLookupType
						,intDefaultPaidoutId
						,intCustomerChargeMopId
						,intCashTransctionMopId
						,ysnAllowMassPriceChanges
						,ysnUsingTankMonitors
						--,strRegisterName
						,intMaxRegisterPlu
						,strReportDepartmentAtGrossOrNet
						,intLoyaltyDiscountMopId
						,intLoyaltyDiscountCategoryId
						,ysnBreakoutPropCardTotal
						,intRemovePropCardMopId
						,intAddPropCardMopId
						,strPropNetworkCardName
						,strAllowRegisterMarkUpDown
						,strRegisterCheckoutDataEntry
						,strReconcileFuels
						,ysnRecieveProductByDepartment
						,ysnKeepArATStore
						,ysnUsingCheckWriter
						,ysnLoadFuelCost
						,ysnUseSafeFunds
						,ysnClearPricebookFieldsOnAdd
						,intNumberOfShifts
						,ysnUpdatePriceFromReciept
						,strGLSalesIndicator
						,ysnUpdateCaseCost
						,dtmInvoiceCloseDate
						,strTaxIdPassword
						,intRegisterId
						,dtmRegisterPricebookUpdateDate
						,dtmRegisterPricebookUpdateTime
						,dtmRegisterItemListUpdateDate
						,dtmRegisterItemListUpdateTime
						,dtmRegisterComboUpdateDate
						,dtmRegisterComboUpdateTime
						,dtmRegisterMixMatchUpdateDate
						,dtmRegisterMixMatchUpdateTime
						,intPassportFileNumber
						,strFalconDataPath
						,intFalconComPort
						,intFalconBaudRate
						,intInventoryCloseShiftNo
						,dtmInventoryCutoffDate
						,intInventoryCutoffShiftNo
						,dtmDepartmentLevelDate
						,strStatementFooter1
						,strStatementFooter2
						,strStatementFooter3
						,strStatementFooter4
						,intScnBackupSeqNo
						,intIpiBackupSeqNo
						,intRtlBackupSeqNo
						,intPhyBackupSeqNo
						,intBegVendorNumberId
						,intEndVendorNumberId
						,dtmBegReceiptDate
						,dtmEndReceiptDate
						,strBegOrderNo
						,strEndOrderNo
						,ysnRecieptErrors
						,dtmEndOfDayDate
						,intEndOfDayShiftNo
						,intTaxGroupId
						,intCheckoutCustomerId
						,intCustomerChargesItemId
						,intOverShortItemId
						,strStoreAppWebUrl
						,guidStoreAppConnectionId
						,strStoreAppMacAddress
						,dtmStoreAppLastDateLog
						--,intChangeFundBegBalanceItemId
						--,intChangeFundEndBalanceItemId
						--,intChangeFundReplenishItemId
						--,intATMFundBegBalanceItemId
						--,intATMFundEndBalanceItemId
						--,intATMFundReplenishedItemId
						--,intATMFundVarianceItemId
						--,intATMFundWithdrawalItemId
						--,strHandheldScannerServerFolderPath
						,intConcurrencyId
						,ysnLotterySetupMode
						,ysnActive
						,ysnConsignmentStore
						,ysnConsStopAutoProcessIfValuesDontMatch
						,ysnConsMeterReadingsForDollars
						,ysnConsAddOutsideFuelDiscounts
						,dblConsCommissionRawMarkup
						,dblConsCommissionDealerPercentage
						,ysnConsBankDepositDraft
						,intConsFuelOverShortItemId
						,intConsBankDepositDraftId
						,intConsDelearCommissionARAccountId
						,intConsDealerCommissionItemId
						,dblConsMatchTolerance
						,intConsFuelDiscountItemId
						,ysnConsIncludeTaxesInCostBasis
						,ysnConsIncludeFreightChargesInCostBasis
					)
					SELECT TOP 1
						@newStoreTransactionId
						,(SELECT TOP 1 strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId)
						,strRegion
						,strDistrict
						,strAddress
						,strCity
						,strState
						,strCountry
						,strZipCode
						,strPhone
						,strFax
						,strEmail
						,strWebsite
						,intProfitCenter
						,ysnStoreOnHost
						,strPricebookAutomated
						,strHandheldCostBasis
						,intDefaultVendorId
						,@intLocationId
						,strGLCoId
						,strARCoId
						,intNextOrderNo
						,ysnUsePricebook
						,intMaxPlu
						,ysnUseLargePlu
						,ysnUseCfn
						,strCfnSiteId
						,strManagersName
						,strManagersPassword
						,ysnInterfaceChecksToCheckbook
						,strCheckbook
						,strQuickbookInterfaceClass
						,strBarcodePrinterName
						,dblServiceChargeRate
						,ysnUseArStatements
						--,dtmLastShiftOpenDate
						--,intLastShiftNo
						--,dtmLastPhysicalImportDate
						--,dtmLastStatementRollDate
						,ysnShiftPhysicalQuantityRecieved
						,ysnShiftPhysicalQuantitySold
						,strHandheldDeviceModel
						,strDepositLookupType
						,intDefaultPaidoutId
						,intCustomerChargeMopId
						,intCashTransctionMopId
						,ysnAllowMassPriceChanges
						,ysnUsingTankMonitors
						--,strRegisterName
						,intMaxRegisterPlu
						,strReportDepartmentAtGrossOrNet
						,intLoyaltyDiscountMopId
						,intLoyaltyDiscountCategoryId
						,ysnBreakoutPropCardTotal
						,intRemovePropCardMopId
						,intAddPropCardMopId
						,strPropNetworkCardName
						,strAllowRegisterMarkUpDown
						,strRegisterCheckoutDataEntry
						,strReconcileFuels
						,ysnRecieveProductByDepartment
						,ysnKeepArATStore
						,ysnUsingCheckWriter
						,ysnLoadFuelCost
						,ysnUseSafeFunds
						,ysnClearPricebookFieldsOnAdd
						,intNumberOfShifts
						,ysnUpdatePriceFromReciept
						,strGLSalesIndicator
						,ysnUpdateCaseCost
						,dtmInvoiceCloseDate
						,strTaxIdPassword
						,intRegisterId
						,dtmRegisterPricebookUpdateDate
						,dtmRegisterPricebookUpdateTime
						,dtmRegisterItemListUpdateDate
						,dtmRegisterItemListUpdateTime
						,dtmRegisterComboUpdateDate
						,dtmRegisterComboUpdateTime
						,dtmRegisterMixMatchUpdateDate
						,dtmRegisterMixMatchUpdateTime
						,intPassportFileNumber
						,strFalconDataPath
						,intFalconComPort
						,intFalconBaudRate
						,intInventoryCloseShiftNo
						,dtmInventoryCutoffDate
						,intInventoryCutoffShiftNo
						,dtmDepartmentLevelDate
						,strStatementFooter1
						,strStatementFooter2
						,strStatementFooter3
						,strStatementFooter4
						,intScnBackupSeqNo
						,intIpiBackupSeqNo
						,intRtlBackupSeqNo
						,intPhyBackupSeqNo
						,intBegVendorNumberId
						,intEndVendorNumberId
						,dtmBegReceiptDate
						,dtmEndReceiptDate
						,strBegOrderNo
						,strEndOrderNo
						,ysnRecieptErrors
						,dtmEndOfDayDate
						,intEndOfDayShiftNo
						,intTaxGroupId
						,intCheckoutCustomerId
						,intCustomerChargesItemId
						,intOverShortItemId
						,strStoreAppWebUrl
						,guidStoreAppConnectionId
						,strStoreAppMacAddress
						,dtmStoreAppLastDateLog
						--,''
						--,intChangeFundBegBalanceItemId
						--,intChangeFundEndBalanceItemId
						--,intChangeFundReplenishItemId
						--,intATMFundBegBalanceItemId
						--,intATMFundEndBalanceItemId
						--,intATMFundReplenishedItemId
						--,intATMFundVarianceItemId
						--,intATMFundWithdrawalItemId
						,intConcurrencyId
						,ysnLotterySetupMode
						,ysnActive
						,ysnConsignmentStore
						,ysnConsStopAutoProcessIfValuesDontMatch
						,ysnConsMeterReadingsForDollars
						,ysnConsAddOutsideFuelDiscounts
						,dblConsCommissionRawMarkup
						,dblConsCommissionDealerPercentage
						,ysnConsBankDepositDraft
						,intConsFuelOverShortItemId
						,intConsBankDepositDraftId
						,intConsDelearCommissionARAccountId
						,intConsDealerCommissionItemId
						,dblConsMatchTolerance
						,intConsFuelDiscountItemId
						,ysnConsIncludeTaxesInCostBasis
						,ysnConsIncludeFreightChargesInCostBasis
					FROM tblSTStore
					WHERE ISNULL(intStoreId,0) = ISNULL(@intStoreId,0)

					SET @NewStoreId = SCOPE_IDENTITY()

					
					--intCheckoutCustomerId
					--IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intCheckoutCustomerId IS NOT NULL AND intStoreId = @intStoreId)
					--	BEGIN
					--		DECLARE @intCheckoutCustomerId AS INT = (SELECT TOP 1 intCheckoutCustomerId FROM tblSTStore WHERE intCheckoutCustomerId IS NOT NULL AND intStoreId = @intStoreId)

					--		EXEC dbo.uspSTCopyItemLocation
					--		@intSourceItemId 			= @intCheckoutCustomerId,
					--		@intSourceLocationId		= @intSourceLocationId,
					--		@intToLocationId 			= @intLocationId
					--	END
						
					--intCustomerChargesItemId
					IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intCustomerChargesItemId IS NOT NULL AND intStoreId = @intStoreId)
						BEGIN
							DECLARE @intCustomerChargesItemId AS INT = (SELECT TOP 1 intCustomerChargesItemId FROM tblSTStore WHERE intCustomerChargesItemId IS NOT NULL AND intStoreId = @intStoreId)

							EXEC dbo.uspSTCopyItemLocation
							@intSourceItemId 			= @intCustomerChargesItemId,
							@intSourceLocationId		= @intSourceLocationId,
							@intToLocationId 			= @intLocationId
						END

					--intOverShortItemId
					IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intOverShortItemId IS NOT NULL AND intStoreId = @intStoreId)
						BEGIN
							DECLARE @intOverShortItemId AS INT = (SELECT TOP 1 intOverShortItemId FROM tblSTStore WHERE intOverShortItemId IS NOT NULL AND intStoreId = @intStoreId)

							EXEC dbo.uspSTCopyItemLocation
							@intSourceItemId 			= @intOverShortItemId,
							@intSourceLocationId		= @intSourceLocationId,
							@intToLocationId 			= @intLocationId
						END

					--intConsDealerCommissionItemId
					IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intConsDealerCommissionItemId IS NOT NULL AND intStoreId = @intStoreId)
						BEGIN
							DECLARE @intConsDealerCommissionItemId AS INT = (SELECT TOP 1 intConsDealerCommissionItemId FROM tblSTStore WHERE intConsDealerCommissionItemId IS NOT NULL AND intStoreId = @intStoreId)

							EXEC dbo.uspSTCopyItemLocation
							@intSourceItemId 			= @intConsDealerCommissionItemId,
							@intSourceLocationId		= @intSourceLocationId,
							@intToLocationId 			= @intLocationId
						END

					--@intConsFuelDiscountItemId
					IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intConsFuelDiscountItemId IS NOT NULL AND intStoreId = @intStoreId)
						BEGIN
							DECLARE @intConsFuelDiscountItemId AS INT = (SELECT TOP 1 intConsFuelDiscountItemId FROM tblSTStore WHERE intConsFuelDiscountItemId IS NOT NULL AND intStoreId = @intStoreId)

							EXEC dbo.uspSTCopyItemLocation
							@intSourceItemId 			= @intConsFuelDiscountItemId,
							@intSourceLocationId		= @intSourceLocationId,
							@intToLocationId 			= @intLocationId
						END

					--REGISTER TAB--
					INSERT INTO tblSTRegister
					(
							intStoreId
						,strRegisterName
						,strRegisterClass
						,ysnRegisterDataLoad
						,ysnCheckoutLoad
						,ysnPricebookBuild
						,ysnImportPricebook
						,ysnComboBuild
						,ysnMixMatchBuild
						,ysnItemListBuild
						,strRubyPullType
						,intPortNumber
						,intLineSpeed
						,intDataBits
						,intStopBits
						,strParity
						,intTimeOut
						,ysnUseModem
						,strPhoneNumber
						,intNumberOfTerminals
						,ysnSupportComboSales
						,ysnSupportMixMatchSales
						,ysnDepartmentTotals
						,ysnPluItemTotals
						,ysnSummaryTotals
						,ysnCashierTotals
						,ysnElectronicJournal
						,ysnLoyaltyTotals
						,ysnProprietaryTotals
						,ysnPromotionTotals
						,ysnFuelTotals
						,ysnPayrollTimeWorked
						,ysnPaymentMethodTotals
						,ysnFuelTankTotals
						,ysnNetworkTotals
						,intPeriodNo
						,intSetNo
						,strSapphirePullType
						,ysnSAPPHIRECaptureTransactionLog
						,intSAPPHIRECaptureIntervalMinutes
						,strSAPPHIRECheckoutPullTime
						,intSAPPHIRECheckoutPullTimePeriodId
						,intSAPPHIRECheckoutPullTimeSetId
						,ysnSAPPHIREAutoUpdatePassword
						,intSAPPHIREPasswordIntervalDays
						,intSAPPHIREPasswordIncrementNo
						,ysnDealTotals
						,ysnHourlyTotals
						,ysnTaxTotals
						,ysnTransctionLog
						,ysnPostCashCardAsARDetail
						,intClubChargesCreditCardId
						,intFuelDriveOffMopId
						,strProgramPath
						,strWayneRegisterType
						,intMaxSkus
						,intWayneDefaultReportChain
						,intDiscountMopId
						,strUpdateSalesFrom
						,intBaudRate
						,intWayneComPort
						,intPCIriqForComPort
						,intWayneSequenceNo
						,strXmlVersion
						--,strRegisterInboxPath
						--,strRegisterOutboxPath
						,strRegisterStoreId
						,intTaxStrategyIdForTax1
						,intTaxStrategyIdForTax2
						,intTaxStrategyIdForTax3
						,intTaxStrategyIdForTax4
						,intNonTaxableStrategyId
						,ysnSupportPropFleetCards
						,intDebitCardMopId
						,intLotteryWinnersMopId
						,ysnCreateCfnAtImport
						--,strArchivePath
						,intPurgeInterval
						,intConcurrencyId
					)
					SELECT
							@NewStoreId
						,CASE WHEN strRegisterClass = 'SAPPHIRE/COMMANDER'
							THEN CAST('COMMANDER-' + strRegisterName + '-' + CAST((SELECT TOP 1 intStoreNo FROM tblSTStore WHERE intStoreId = @NewStoreId) AS VARCHAR(20)) AS VARCHAR(20))
						ELSE CAST(strRegisterClass + '-' + strRegisterName + ' - ' + CAST((SELECT TOP 1 intStoreNo FROM tblSTStore WHERE intStoreId = @NewStoreId) AS VARCHAR(20)) AS VARCHAR(20))
						END AS strRegisterName
						,strRegisterClass
						,ysnRegisterDataLoad
						,ysnCheckoutLoad
						,ysnPricebookBuild
						,ysnImportPricebook
						,ysnComboBuild
						,ysnMixMatchBuild
						,ysnItemListBuild
						,strRubyPullType
						,intPortNumber
						,intLineSpeed
						,intDataBits
						,intStopBits
						,strParity
						,intTimeOut
						,ysnUseModem
						,strPhoneNumber
						,intNumberOfTerminals
						,ysnSupportComboSales
						,ysnSupportMixMatchSales
						,ysnDepartmentTotals
						,ysnPluItemTotals
						,ysnSummaryTotals
						,ysnCashierTotals
						,ysnElectronicJournal
						,ysnLoyaltyTotals
						,ysnProprietaryTotals
						,ysnPromotionTotals
						,ysnFuelTotals
						,ysnPayrollTimeWorked
						,ysnPaymentMethodTotals
						,ysnFuelTankTotals
						,ysnNetworkTotals
						,intPeriodNo
						,intSetNo
						,strSapphirePullType
						,ysnSAPPHIRECaptureTransactionLog
						,intSAPPHIRECaptureIntervalMinutes
						,strSAPPHIRECheckoutPullTime
						,intSAPPHIRECheckoutPullTimePeriodId
						,intSAPPHIRECheckoutPullTimeSetId
						,ysnSAPPHIREAutoUpdatePassword
						,intSAPPHIREPasswordIntervalDays
						,intSAPPHIREPasswordIncrementNo
						,ysnDealTotals
						,ysnHourlyTotals
						,ysnTaxTotals
						,ysnTransctionLog
						,ysnPostCashCardAsARDetail
						,intClubChargesCreditCardId
						,intFuelDriveOffMopId
						,strProgramPath
						,strWayneRegisterType
						,intMaxSkus
						,intWayneDefaultReportChain
						,intDiscountMopId
						,strUpdateSalesFrom
						,intBaudRate
						,intWayneComPort
						,intPCIriqForComPort
						,intWayneSequenceNo
						,strXmlVersion
						--,strRegisterInboxPath
						--,strRegisterOutboxPath
						,strRegisterStoreId
						,intTaxStrategyIdForTax1
						,intTaxStrategyIdForTax2
						,intTaxStrategyIdForTax3
						,intTaxStrategyIdForTax4
						,intNonTaxableStrategyId
						,ysnSupportPropFleetCards
						,intDebitCardMopId
						,intLotteryWinnersMopId
						,ysnCreateCfnAtImport
						--,strArchivePath
						,intPurgeInterval
						,intConcurrencyId
						FROM tblSTRegister 
						WHERE intStoreId = @intStoreId

					DECLARE @intRegisterId INT = 0
					DECLARE @newRegisterCreated BIT = 0

					IF (EXISTS(SELECT '' FROM tblSTRegister WHERE intStoreId = @intStoreId))
					BEGIN
						DECLARE @NewRegisterName NVARCHAR(50)

						SET @intRegisterId = SCOPE_IDENTITY()
						SET @newRegisterCreated = 1

						SELECT @NewRegisterName = strRegisterName
						FROM tblSTRegister
						WHERE intRegisterId = @intRegisterId

						UPDATE tblSTStore 
						SET intRegisterId = SCOPE_IDENTITY(), strRegisterName = @NewRegisterName
						WHERE intStoreId = @NewStoreId

						DECLARE @intOldRegisterId INT
						SELECT TOP 1 @intOldRegisterId = intRegisterId
						FROM tblSTRegister 
						WHERE intStoreId = @intStoreId

						INSERT INTO tblSTRegisterFileConfiguration
						(
								intRegisterId
							,intImportFileHeaderId
							,strFileType
							,strFilePrefix
							,strFileNamePattern
							,strFolderPath
							,strURICommand
							,strStoredProcedure
							,intConcurrencyId
						)
						SELECT
							@intRegisterId
							,intImportFileHeaderId
							,strFileType
							,strFilePrefix
							,strFileNamePattern
							,strFolderPath
							,strURICommand
							,strStoredProcedure
							,intConcurrencyId
						FROM 
						tblSTRegisterFileConfiguration WHERE intRegisterId = @intOldRegisterId
					END

					IF @chkDepartment = 'true'
						BEGIN
							
							IF EXISTS (SELECT TOP 1 1 intCategoryLocationId FROM tblICCategoryLocation WHERE intLocationId = @intSourceLocationId)
								BEGIN
									IF OBJECT_ID('tempdb..#tmpDepartmentLocation') IS NOT NULL 
										BEGIN

											DROP TABLE #tmpDepartmentLocation
										END

									SELECT * INTO #tmpDepartmentLocation FROM tblICCategoryLocation WHERE intLocationId = @intSourceLocationId
									
									DECLARE @intCategoryLocationId AS INT = 0
									DECLARE @intCategoryId AS INT = 0

									WHILE EXISTS (SELECT * FROM #tmpDepartmentLocation)
										BEGIN

											SELECT TOP 1 @intCategoryLocationId = intCategoryLocationId FROM #tmpDepartmentLocation
											SELECT TOP 1 @intCategoryId = intCategoryId FROM #tmpDepartmentLocation

											IF NOT EXISTS (SELECT TOP 1 1 intCategoryLocationId FROM tblICCategoryLocation WHERE intCategoryId = @intCategoryId AND intLocationId = @intLocationId)
											BEGIN

											BEGIN TRY

												EXEC dbo.uspSTCopyCategoryLocation
												@intCategorySourceId 		  = @intCategoryId,
												@intCategoryLocationSourceId  = @intCategoryLocationId,
												@intCopyFromLocationId		  = @intSourceLocationId,
												@intCopyToLocationId 		  = @intLocationId
											END TRY
											BEGIN CATCH
												SELECT @intCategoryId
												SELECT @intCategoryLocationId
												SELECT @intSourceLocationId
												SELECT @intLocationId
											END CATCH
											END



											DELETE FROM #tmpDepartmentLocation
											WHERE intCategoryLocationId = @intCategoryLocationId

										END
								END
						END

					IF @chkRebates = 'true' 
						BEGIN
							--REBASTES TAB--
							INSERT INTO tblSTStoreRebates
							(
									intStoreId
								,intCategoryId
								,ysnTobacco
								,intConcurrencyId
							)
							SELECT
								@NewStoreId
								,intCategoryId
								,ysnTobacco
								,intConcurrencyId
							FROM tblSTStoreRebates
							WHERE intStoreId = @intStoreId
							AND @chkRebates = 'true'

							IF EXISTS (SELECT TOP 1 1 intStoreRebatesId FROM tblSTStoreRebates WHERE intStoreId = @intStoreId)
								BEGIN
									IF OBJECT_ID('tempdb..#tmpStoreRebates') IS NOT NULL 
										BEGIN

											DROP TABLE #tmpStoreRebates
										END

									SELECT * INTO #tmpStoreRebates FROM tblSTStoreRebates WHERE intStoreId = @intStoreId
									
									DECLARE @intStoreRebateId AS INT = 0

									WHILE EXISTS (SELECT * FROM #tmpStoreRebates)
										BEGIN
											SELECT TOP 1 @intStoreRebateId = intStoreRebateId FROM #tmpStoreRebates

											SELECT TOP 1 @intCategoryLocationId = intCategoryLocationId, @intCategoryId = cl.intCategoryId  
											FROM #tmpStoreRebates sr
											JOIN tblICCategoryLocation cl
												ON sr.intCategoryId = cl.intCategoryId
												AND cl.intLocationId = @intSourceLocationId

											IF NOT EXISTS (SELECT TOP 1 1 intCategoryLocationId FROM tblICCategoryLocation WHERE intCategoryId = @intCategoryId AND intLocationId = @intLocationId)
											BEGIN
												EXEC dbo.uspSTCopyCategoryLocation
												@intCategorySourceId 		  = @intCategoryId,
												@intCategoryLocationSourceId  = @intCategoryLocationId,
												@intCopyFromLocationId		  = @intSourceLocationId,
												@intCopyToLocationId 		  = @intLocationId
											END



											DELETE FROM #tmpStoreRebates
											WHERE intStoreRebateId = @intStoreRebateId

										END
								END

						END

					--PAYMENT OPTION-- 
					IF @chkMOP = 'true'
						BEGIN
							INSERT INTO tblSTPaymentOption
							(
									intStoreId
								,strPaymentOptionId
								,strDescription
								,intItemId
								,intAccountId
								,strRegisterMop
								,ysnDepositable
								,intConcurrencyId
							)
							SELECT 
								@NewStoreId
								,strPaymentOptionId
								,strDescription
								,intItemId
								,intAccountId
								,strRegisterMop
								,ysnDepositable
								,intConcurrencyId
							FROM 
							tblSTPaymentOption
							WHERE intStoreId = @intStoreId
							
							IF EXISTS (SELECT TOP 1 1 intPaymentOptionId FROM tblSTPaymentOption WHERE intStoreId = @intStoreId)
								BEGIN
									IF OBJECT_ID('tempdb..#tmpPaymentOption') IS NOT NULL 
										BEGIN

											DROP TABLE #tmpPaymentOption
										END

									SELECT * INTO #tmpPaymentOption FROM tblSTPaymentOption WHERE intStoreId = @intStoreId
									
									DECLARE @intItemId AS INT = 0
									DECLARE @intItemLocationId AS INT = 0
									DECLARE @intPaymentOptionId AS INT = 0

									WHILE EXISTS (SELECT * FROM #tmpPaymentOption WHERE intStoreId = @intStoreId)
										BEGIN
											SELECT TOP 1 @intPaymentOptionId = intPaymentOptionId FROM #tmpPaymentOption

											SELECT TOP 1 @intItemId = po.intItemId 
											FROM #tmpPaymentOption po

											IF NOT EXISTS (SELECT TOP 1 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId)
											BEGIN
												EXEC dbo.uspSTCopyItemLocation
												@intSourceItemId 			= @intItemId,
												@intSourceLocationId		= @intSourceLocationId,
												@intToLocationId 			= @intLocationId
											END



											DELETE FROM #tmpPaymentOption
											WHERE intPaymentOptionId = @intPaymentOptionId

										END
								END
							END

							
					--Vendor Department Cross Reference-- 
					IF @chkVendorCrossReference = 'true'
						BEGIN
							IF EXISTS (SELECT TOP 1 1 intCategoryLocationId FROM tblICCategoryLocation WHERE intLocationId = @intLocationId)
								BEGIN
									INSERT INTO tblICCategoryVendor
									(
										intCategoryId	
										,intCategoryLocationId	
										,intVendorId
										,intVendorSetupId
										,strVendorDepartment
										,ysnAddOrderingUPC
										,ysnUpdateExistingRecords
										,ysnAddNewRecords	
										,ysnUpdatePrice
										,intFamilyId
										,intSellClassId
										,intOrderClassId	
										,strComments	
										,intConcurrencyId
										,dtmDateCreated
										,intCreatedByUserId
									)
									SELECT 
										CV.intCategoryId	
										,(SELECT TOP 1 intCategoryLocationId FROM tblICCategoryLocation WHERE intLocationId = @intLocationId)	
										,CV.intVendorId
										,CV.intVendorSetupId
										,CV.strVendorDepartment
										,CV.ysnAddOrderingUPC
										,CV.ysnUpdateExistingRecords
										,CV.ysnAddNewRecords	
										,CV.ysnUpdatePrice
										,CV.intFamilyId
										,CV.intSellClassId
										,CV.intOrderClassId	
										,CV.strComments	
										,CV.intConcurrencyId
										,CV.dtmDateCreated
										,CV.intCreatedByUserId
									FROM tblICCategoryVendor CV
									JOIN tblICCategoryLocation CL
										ON CV.intCategoryLocationId = CL.intCategoryLocationId
									WHERE CL.intLocationId = @intSourceLocationId
								END
						END

					--PUMP ITEM--
					IF @chkPumpItems = 'true'
						BEGIN
							INSERT INTO tblSTPumpItem
							(
									intStoreId
								,intItemUOMId
								,dblPrice
								,intTaxGroupId
								,intCategoryId
								,strRegisterFuelId1
								,strRegisterFuelId2
								,intConcurrencyId
							)
							SELECT 
								@NewStoreId
								,intItemUOMId
								,dblPrice
								,intTaxGroupId
								,intCategoryId
								,strRegisterFuelId1
								,strRegisterFuelId2
								,intConcurrencyId
							FROM tblSTPumpItem
							WHERE intStoreId = @intStoreId

							
							IF EXISTS (SELECT TOP 1 1 intStorePumpItemId FROM tblSTPumpItem WHERE intStoreId = @intStoreId)
								BEGIN
									IF OBJECT_ID('tempdb..#tmpPumpItem') IS NOT NULL 
										BEGIN

											DROP TABLE #tmpPumpItem
										END

									SELECT * INTO #tmpPumpItem FROM tblSTPumpItem WHERE intStoreId = @intStoreId
									
									--DECLARE @intItemId AS INT = 0
									--DECLARE @intItemLocationId AS INT = 0
									DECLARE @intPumpItemId AS INT = 0

									WHILE EXISTS (SELECT * FROM #tmpPumpItem WHERE intStoreId = @intStoreId)
										BEGIN
											SELECT TOP 1 @intPumpItemId = intStorePumpItemId FROM #tmpPumpItem

											SELECT TOP 1 @intItemId = UOM.intItemId 
											FROM #tmpPumpItem pi
											JOIN tblICItemUOM UOM
											ON pi.intItemUOMId = UOM.intItemUOMId

											IF NOT EXISTS (SELECT TOP 1 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId)
											BEGIN
												EXEC dbo.uspSTCopyItemLocation
												@intSourceItemId 			= @intItemId,
												@intSourceLocationId		= @intSourceLocationId,
												@intToLocationId 			= @intLocationId
											END

											DELETE FROM #tmpPumpItem
											WHERE intStorePumpItemId = @intPumpItemId

										END
								END
						END

					--TAX TOTALS--
					IF @chkTaxFile = 'true'
						BEGIN
							INSERT INTO tblSTStoreTaxTotals
							(
									intStoreId
								,intTaxCodeId
								,intItemId
								,intConcurrencyId
							)
							SELECT 
								@NewStoreId
								,intTaxCodeId
								,intItemId
								,intConcurrencyId
							FROM 
							tblSTStoreTaxTotals
							WHERE intStoreId = @intStoreId
							AND @chkTaxFile = 'true'

							
							IF EXISTS (SELECT TOP 1 1 intStoreTaxTotalId FROM tblSTStoreTaxTotals WHERE intStoreId = @intStoreId)
								BEGIN
									IF OBJECT_ID('tempdb..#tmpStoreTaxTotal') IS NOT NULL 
										BEGIN

											DROP TABLE #tmpStoreTaxTotal
										END

									SELECT * INTO #tmpStoreTaxTotal FROM tblSTStoreTaxTotals WHERE intStoreId = @intStoreId
									
									--DECLARE @intItemId AS INT = 0
									--DECLARE @intItemLocationId AS INT = 0
									DECLARE @intStoreTaxTotalId AS INT = 0

									WHILE EXISTS (SELECT * FROM #tmpStoreTaxTotal WHERE intStoreId = @intStoreId)
										BEGIN
											SELECT TOP 1 @intStoreTaxTotalId = intStoreTaxTotalId FROM #tmpStoreTaxTotal

											SELECT TOP 1 @intItemId = intItemId 
											FROM #tmpStoreTaxTotal 

											IF NOT EXISTS (SELECT TOP 1 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId)
											BEGIN
												EXEC dbo.uspSTCopyItemLocation
												@intSourceItemId 			= @intItemId,
												@intSourceLocationId		= @intSourceLocationId,
												@intToLocationId 			= @intLocationId
											END

											DELETE FROM #tmpStoreTaxTotal
											WHERE intStoreTaxTotalId = @intStoreTaxTotalId

										END
								END
						END

							
					--METRICS--
					IF @chkMetrics = 'true'
						BEGIN
							INSERT INTO tblSTStoreMetrics
							(
									intStoreId
								,strMetricsDescription
								,intMetricItemId
								,intOffsetItemId
								,intRegisterImportFieldId
								,intDepartmentId
								,intConcurrencyId
							)
							SELECT 
								@NewStoreId
								,strMetricsDescription
								,intMetricItemId
								,intOffsetItemId
								,intRegisterImportFieldId
								,intDepartmentId
								,intConcurrencyId
							FROM tblSTStoreMetrics
							WHERE intStoreId = @intStoreId
							AND @chkMetrics = 'true'

							IF EXISTS (SELECT TOP 1 1 intStoreMetricsId FROM tblSTStoreMetrics WHERE intStoreId = @intStoreId)
								BEGIN
									IF OBJECT_ID('tempdb..#tmpStoreMetrics') IS NOT NULL 
										BEGIN

											DROP TABLE #tmpStoreMetrics
										END

									SELECT * INTO #tmpStoreMetrics FROM tblSTStoreMetrics WHERE intStoreId = @intStoreId
									
									--DECLARE @intItemId AS INT = 0
									--DECLARE @intItemLocationId AS INT = 0
									DECLARE @intStoreMetricsId AS INT = 0

									WHILE EXISTS (SELECT * FROM #tmpStoreMetrics WHERE intStoreId = @intStoreId)
										BEGIN
											SELECT TOP 1 @intStoreMetricsId = intStoreMetricsId FROM #tmpStoreMetrics

											SELECT TOP 1 @intItemId = intMetricItemId 
											FROM #tmpStoreMetrics 

											IF NOT EXISTS (SELECT TOP 1 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId)
											BEGIN
												EXEC dbo.uspSTCopyItemLocation
												@intSourceItemId 			= @intItemId,
												@intSourceLocationId		= @intSourceLocationId,
												@intToLocationId 			= @intLocationId
											END

											DELETE FROM #tmpStoreMetrics
											WHERE intStoreMetricsId = @intStoreMetricsId

										END
								END
						END 
							
					--ATM FUND SETUP--
					IF @chkATMFundSetup = 'true'
						BEGIN

							UPDATE tblSTStore 
							SET tblSTStore.intATMFundBegBalanceItemId 	= (SELECT TOP 1 intATMFundBegBalanceItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							, tblSTStore.intATMFundEndBalanceItemId		= (SELECT TOP 1 intATMFundEndBalanceItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							, tblSTStore.intATMFundReplenishedItemId	= (SELECT TOP 1 intATMFundReplenishedItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							, tblSTStore.intATMFundVarianceItemId		= (SELECT TOP 1 intATMFundVarianceItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							, tblSTStore.intATMFundWithdrawalItemId		= (SELECT TOP 1 intATMFundWithdrawalItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							WHERE intStoreId = @NewStoreId


							--intATMFundBegBalanceItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intATMFundBegBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intATMFundBegBalanceItemId AS INT = (SELECT TOP 1 intATMFundBegBalanceItemId FROM tblSTStore WHERE intATMFundBegBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intATMFundBegBalanceItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
							
							--intATMFundEndBalanceItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intATMFundEndBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intATMFundEndBalanceItemId AS INT = (SELECT TOP 1 intATMFundEndBalanceItemId FROM tblSTStore WHERE intATMFundEndBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intATMFundEndBalanceItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END

								
							--intATMFundReplenishedItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intATMFundReplenishedItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intATMFundReplenishedItemId AS INT = (SELECT TOP 1 intATMFundReplenishedItemId FROM tblSTStore WHERE intATMFundReplenishedItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intATMFundReplenishedItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
							
							--intATMFundVarianceItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intATMFundVarianceItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intATMFundVarianceItemId AS INT = (SELECT TOP 1 intATMFundVarianceItemId FROM tblSTStore WHERE intATMFundVarianceItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intATMFundVarianceItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
							
							--intATMFundWithdrawalItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intATMFundWithdrawalItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intATMFundWithdrawalItemId AS INT = (SELECT TOP 1 intATMFundWithdrawalItemId FROM tblSTStore WHERE intATMFundWithdrawalItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intATMFundWithdrawalItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
						END

					--CHANGE FUND--
					IF @chkChangeFundSetup = 'true'
						BEGIN						
							UPDATE tblSTStore 
							SET tblSTStore.intChangeFundBegBalanceItemId 	= (SELECT TOP 1 intChangeFundBegBalanceItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							, tblSTStore.intChangeFundEndBalanceItemId		= (SELECT TOP 1 intChangeFundEndBalanceItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							, tblSTStore.intChangeFundReplenishItemId	= (SELECT TOP 1 intChangeFundReplenishItemId FROM tblSTStore WHERE intStoreId = @intStoreId)
							WHERE intStoreId = @NewStoreId


							INSERT INTO tblSTStoreChangeFund
							(
								intStoreId
								,strDescription
								,dblValue
								,intConcurrencyId
							)
							SELECT 
								@NewStoreId
								,strDescription
								,dblValue
								,intConcurrencyId
							FROM tblSTStoreChangeFund
							WHERE intStoreId = @intStoreId

							--intChangeFundBegBalanceItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intChangeFundBegBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intChangeFundBegBalanceItemId AS INT = (SELECT TOP 1 intChangeFundBegBalanceItemId FROM tblSTStore WHERE intChangeFundBegBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intChangeFundBegBalanceItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
							
							--intChangeFundEndBalanceItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intChangeFundEndBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intChangeFundEndBalanceItemId AS INT = (SELECT TOP 1 intChangeFundEndBalanceItemId FROM tblSTStore WHERE intChangeFundEndBalanceItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intChangeFundEndBalanceItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
							
							--intChangeFundReplenishItemId
							IF EXISTS (SELECT TOP 1 1 FROM tblSTStore WHERE intChangeFundReplenishItemId IS NOT NULL AND intStoreId = @intStoreId)
								BEGIN
									DECLARE @intChangeFundReplenishItemId AS INT = (SELECT TOP 1 intChangeFundReplenishItemId FROM tblSTStore WHERE intChangeFundReplenishItemId IS NOT NULL AND intStoreId = @intStoreId)

									EXEC dbo.uspSTCopyItemLocation
									@intSourceItemId 			= @intChangeFundReplenishItemId,
									@intSourceLocationId		= @intSourceLocationId,
									@intToLocationId 			= @intLocationId
								END
						END


							
					SET @newStoreTransactionId = @newStoreTransactionId + 1
				END
			
			DELETE FROM #tmpToLocation WHERE intLocationId = @intLocationId
		END




	DROP TABLE #tmpToLocation
	DROP TABLE #tmpToLocationValidate
	
	SET @ysnSuccess = 'true'

	IF (@intLocationCount > 1)
	BEGIN
		SET @strResultMessage = 'Successfully created new Stores and new Registers to use with them. Credentials for the new Registers, however, still need to be manually entered.'
	END 
	ELSE IF (@newRegisterCreated = 0)
	BEGIN
		SET @strResultMessage = 'Successfully created new store'
	END
	ELSE
	BEGIN
		SET @strResultMessage = 'Successfully created new store and a new Register to use with it. Credentials for the new Register, however, still need to be manually entered. The new Register is called ' + @NewRegisterName
	END
	
	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH

	SELECT ERROR_MESSAGE()
	SET @ysnSuccess = 'false'
	SET @strResultMessage = 'Something failed during creation of new store/s: ' + ERROR_MESSAGE()

	ROLLBACK TRANSACTION

	SELECT TOP 1
	 0 as intStoreId
	,'' as intStoreNo
	,CAST(0 as BIT) as ysnResult

	END CATCH
	
END