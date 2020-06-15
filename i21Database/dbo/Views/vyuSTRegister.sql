CREATE VIEW [dbo].[vyuSTRegister]
AS
SELECT reg.intRegisterId
	--, reg.intStoreId
	, st.intStoreId
	, st.intStoreNo
	, reg.strRegisterName
	, reg.strRegisterClass
	, reg.ysnRegisterDataLoad
	, reg.ysnCheckoutLoad
	, reg.ysnPricebookBuild
	, reg.ysnImportPricebook
	, reg.ysnComboBuild
	, reg.ysnMixMatchBuild
	, reg.ysnItemListBuild
	, reg.strRegisterPassword
	, reg.strRubyPullType
	, reg.intPortNumber
	, reg.intLineSpeed
	, reg.intDataBits
	, reg.intStopBits
	, reg.strParity
	, reg.intTimeOut
	, reg.ysnUseModem
	, reg.strPhoneNumber
	, reg.intNumberOfTerminals
	, reg.ysnSupportComboSales
	, reg.ysnSupportMixMatchSales
	, reg.ysnDepartmentTotals
	, reg.ysnPluItemTotals
	, reg.ysnSummaryTotals
	, reg.ysnCashierTotals
	, reg.ysnElectronicJournal
	, reg.ysnLoyaltyTotals
	, reg.ysnProprietaryTotals
	, reg.ysnPromotionTotals
	, reg.ysnFuelTotals
	, reg.ysnPayrollTimeWorked
	, reg.ysnPaymentMethodTotals
	, reg.ysnFuelTankTotals
	, reg.ysnNetworkTotals
	, reg.intPeriodNo
	, reg.intSetNo
	, reg.strSapphirePullType
	, reg.strSapphireIpAddress
	, reg.strSAPPHIREUserName
	, strSAPPHIREPassword = CASE
								WHEN (reg.strSAPPHIREPassword IS NOT NULL AND reg.strSAPPHIREPassword != '')
									THEN dbo.fnAESDecryptASym(reg.strSAPPHIREPassword)
								ELSE NULL
							END COLLATE Latin1_General_CI_AS
	, reg.intSAPPHIRECheckoutPullTimePeriodId
	, strSAPPHIRECheckoutPullTimePeriodId = CASE
												WHEN (reg.intSAPPHIRECheckoutPullTimePeriodId = 1)
													THEN 'Shift Close'
												WHEN (reg.intSAPPHIRECheckoutPullTimePeriodId = 2)
													THEN 'Day Close'
											END COLLATE Latin1_General_CI_AS
	, reg.intSAPPHIRECheckoutPullTimeSetId
	, strSAPPHIRECheckoutPullTimeSetId = CASE
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 1)
												THEN 'Current Data'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 2)
												THEN 'Last Close Data'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 3)
												THEN 'Last Close Data - 1'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 4)
												THEN 'Last Close Data - 2'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 5)
												THEN 'Last Close Data - 3'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 6)
												THEN 'Last Close Data - 4'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 7)
												THEN 'Last Close Data - 5'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 8)
												THEN 'Last Close Data - 6'
											WHEN (reg.intSAPPHIRECheckoutPullTimeSetId = 9)
												THEN 'Last Close Data - 7'
										END COLLATE Latin1_General_CI_AS
	, reg.strSAPPHIRECheckoutPullTime
	, reg.ysnSAPPHIREAutoUpdatePassword
	, reg.dtmSAPPHIRELastPasswordChangeDate
	, strSAPPHIREBasePassword = CASE
									WHEN (reg.strSAPPHIREBasePassword IS NOT NULL AND reg.strSAPPHIREBasePassword != '')
										THEN dbo.fnAESDecryptASym(reg.strSAPPHIREBasePassword)
									ELSE NULL
								END COLLATE Latin1_General_CI_AS
	, reg.intSAPPHIREPasswordIntervalDays
	, reg.intSAPPHIREPasswordIncrementNo
	, ysnHasStore = CASE
						WHEN (st.intRegisterId IS NOT NULL)
							THEN CAST(1 AS BIT)
						ELSE CAST(0 AS BIT)
					END
	, reg.ysnDealTotals
	, reg.ysnHourlyTotals
	, reg.ysnTaxTotals
	, reg.ysnTransctionLog
	, reg.ysnPostCashCardAsARDetail
	, reg.intClubChargesCreditCardId
	, reg.intFuelDriveOffMopId
	, reg.strProgramPath
	, reg.strWayneRegisterType
	, reg.intMaxSkus
	, reg.intWayneDefaultReportChain
	, reg.intDiscountMopId
	, reg.strUpdateSalesFrom
	, reg.intBaudRate
	, reg.intWayneComPort
	, reg.intPCIriqForComPort
	, reg.strWaynePassWord
	, reg.intWayneSequenceNo
	, reg.strXmlVersion
	, reg.strRegisterStoreId
	, reg.intTaxStrategyIdForTax1
	, reg.intTaxStrategyIdForTax2
	, reg.intTaxStrategyIdForTax3
	, reg.intTaxStrategyIdForTax4
	, reg.intNonTaxableStrategyId
	, reg.ysnSupportPropFleetCards
	, reg.intDebitCardMopId
	, reg.intLotteryWinnersMopId
	, reg.ysnCreateCfnAtImport
	, reg.strFTPPath
	, reg.strFTPUserName
	, reg.strFTPPassword
	, reg.intPurgeInterval
	, reg.intConcurrencyId 
FROM tblSTRegister reg
INNER JOIN tblSTStore st
	ON st.intStoreId = reg.intStoreId

--SELECT R.intRegisterId
--    , R.intStoreId
--    , R.strRegisterName
--    , R.strRegisterClass
--    ,S.intStoreNo 
--FROM tblSTRegister R
--INNER JOIN tblSTStore S 
--	ON S.intStoreId = R.intStoreId

