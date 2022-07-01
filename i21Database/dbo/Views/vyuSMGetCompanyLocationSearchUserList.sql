﻿CREATE VIEW [dbo].[vyuSMGetCompanyLocationSearchUserList]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY a.intCompanyLocationId DESC) AS INT) AS intCompanyLocationUserId, 
a.intCompanyLocationId
,a.strLocationName
,a.strLocationNumber
,a.strLocationType
,a.strAddress
,a.strZipPostalCode
,a.strCity
,a.strStateProvince
,a.strCountry
,a.strPhone
,a.strFax
,a.strEmail
,a.strWebsite
,a.dblLongitude
,a.dblLatitude
,a.strInternalNotes
,a.strUseLocationAddress
,a.strFEIN
,a.strSkipSalesmanDefault
,a.ysnSkipTermsDefault
,a.strOrderTypeDefault
,a.strPrintCashReceipts
,a.ysnPrintCashTendered
,a.strSalesTaxByLocation
,a.strDeliverPickupDefault
,a.intTaxGroupId
,a.strTaxState
,a.strTaxAuthorityId1
,a.strTaxAuthorityId2
,a.ysnOverridePatronage
,a.strOregonFacilityNumber
,a.strOutOfStockWarning
,a.strLotOverdrawnWarning
,a.strDefaultCarrier
,a.ysnOrderSection2Required
,a.strPrintonPO
,a.dblMixerSize
,a.ysnOverrideMixerSize
,a.ysnEvenBatches
,a.ysnDefaultCustomBlend
,a.ysnAgroguideInterface
,a.ysnLicensed
,a.ysnLocationActive
,a.intProfitCenter
,a.intCashAccount
,a.intDepositAccount
,a.intARAccount
,a.intAPAccount
,a.intSalesAdvAcct
,a.intPurchaseAdvAccount
,a.intFreightAPAccount
,a.intFreightExpenses
,a.intFreightIncome
,a.intServiceCharges
,a.intSalesDiscounts
,a.intCashOverShort
,a.intWriteOff
,a.intCommissionExpense
,a.intCreditCardFee
,a.intSalesAccount
,a.intCostofGoodsSold
,a.intInventory
,a.intWriteOffSold
,a.intRevalueSold
,a.intAutoNegativeSold
,a.intAPClearing
,a.intInventoryInTransit
,a.intWithholdAccountId
,a.intDiscountAccountId
,a.intInterestAccountId
,a.intPrepaidAccountId
,a.intUndepositedFundsId
,a.strInvoiceType
,a.strDefaultInvoicePrinter
,a.strPickTicketType
,a.strDefaultTicketPrinter
,a.strLastOrderNumber
,a.strLastInvoiceNumber
,a.strPrintonInvoice
,a.ysnPrintContractBalance
,a.strJohnDeereMerchant
,a.strInvoiceComments
,a.ysnUseOrderNumberforInvoiceNumber
,a.ysnOverrideOrderInvoiceNumber
,a.ysnPrintInvoiceMedTags
,a.ysnPrintPickTicketMedTags
,a.ysnSendtoEnergyTrac
,a.strDiscountScheduleType
,a.strLocationDiscount
,a.strLocationStorage
,a.strMarketZone
,a.strLastTicket
,a.ysnDirectShipLocation
,a.ysnScaleInstalled
,a.strDefaultScaleId
,a.ysnActive
,a.ysnUsingCashDrawer
,a.strCashDrawerDeviceId
,a.ysnPrintRegisterTape
,a.ysnUseUPConOrders
,a.ysnUseUPConPhysical
,a.ysnUseUPConPurchaseOrders
,a.strUPCSearchSequence
,a.strBarCodePrinterName
,a.strPriceLevel1
,a.strPriceLevel2
,a.strPriceLevel3
,a.strPriceLevel4
,a.strPriceLevel5
,a.ysnOverShortEntries
,a.strOverShortCustomer
,a.strOverShortAccount
,a.ysnAutomaticCashDepositEntries
,a.dblWithholdPercent
,a.intAllowablePickDayRange
,a.ysnAllowCreateSKUContainer
,a.ysnAllowMoveAssignedTask
,a.ysnAllowPutAwayUnitTypes
,a.ysnAutoCommentsUpdate
,a.ysnAutoPositiveReleaseForBlendedLot
,a.dblAverageDensity
,a.strBagMarksPattern
,a.intBlendProductionDockDoorUnitId
,a.intBlendProductionStagingUnitId
,a.ysnBlendAffordabilityCheck
,a.ysnCreateOutboundOrderOnBlendsheetRelease
,a.ysnCreateLoadTasks
,a.ysnCreatePutAwayTask
,a.intDefaultCarrierId
,a.strDefaultTerms
,a.intDefaultBlendProductionLocationId
,a.ysnDefaultPalletTagReprintonPositiveRelease
,a.intDefaultStatusForPreSanitizedLotId
,a.intDefaultInboundDockDoorUnitId
,a.ysnEDI944
,a.ysnEDI945
,a.ysnShiftActivityTimeDisable
,a.strFGReleaseMailCCAddress
,a.strFGReleaseMailTOAddress
,a.ysnGTINCaseCodeMandatory
,a.intHistoricalStagingTicketLocationId
,a.ysnPalletCreateDelayEnabled
,a.strLotIDPrefix
,a.strLotOrigin
,a.strMailBCCAddress
,a.strMailCCAddress
,a.strMailFromAddress
,a.strMailServer
,a.strMailServerPassword
,a.strMailServerUserDomain
,a.strMailServerUserName
,a.strMailToAddress
,a.strExternalDatabaseName
,a.strExternalServerName
,a.strExternalCLRSPURL
,a.ysnModifyAffordability
,a.ysnModifyBudget
,a.intNoOfCopiesToPrintforPalletSlip
,a.ysnOverrideAffordability
,a.ysnOverrideBudget
,a.strPalletSlipPrinterName
,a.strPhysicalCountPattern
,a.strProductAlertMailCCAddress
,a.strProductAlertMailTOAddress
,a.intProductAlertOwnerId
,a.ysnReceiptConnToERP
,a.ysnReceiptFeedToERP
,a.ysnRestrictOrdersToOneOwner
,a.intSanitizationDockDoorUnitId
,a.dblSanitizationOrderInputQtyTolerancePercentage
,a.dblSanitizationOrderOutputQtyTolerancePercentage
,a.intSanitizationStagingUnitId
,a.intSanitizationStorageUnitId
,a.ysnScanForkliftOnLogin
,a.ysnSendEmailNotificationOnReceiptOfMaterials
,a.ysnShowBlendProductionItemLineColor
,a.ysnSKUPickByUnitType
,a.strTagNoPattern
,a.strTicketLabelPrinterName
,a.strWMSMobileURL
,a.ysnInventoryTransactionFeedToERP
,a.strParentLotIdPattern
,a.strPatternId
,a.ysnProductionFeedToERP
,a.dtmDefaultTimeForEarliestStartDate
,a.intDemandNoMaxLength
,a.intDemandNoMinLength
,a.ysnEnableKittingProcess
,a.ysnBlendStageIntegration
,a.ysnProductCaseCodeScanningRequired
,a.ysnYieldAdjustmentAllowed
,a.ysnPrintInvTagOnReceivingComplete
,a.intConcurrencyId
,a.strCode
,a.strCashAccount
,a.strDepositAccount
,a.strARAccount
,a.strAPAccount
,a.strSalesAdvAcct
,a.strPurchaseAdvAccount
,a.strFreightAPAccount
,a.strFreightExpenses
,a.strFreightIncome
,a.strServiceCharges
,a.strSalesDiscounts
,a.strCashOverShort
,a.strWriteOff
,a.strCommissionExpense
,a.strCreditCardFee
,a.strSalesAccount
,a.strCostofGoodsSold
,a.strInventory
,a.strWriteOffSold
,a.strRevalueSold
,a.strAutoNegativeSold
,a.strAPClearing
,a.strInventoryInTransit
,a.strWithholdAccountId
,a.strDiscountAccountId
,a.strstrerestAccountId
,a.strPrepaidAccountId
,a.strUndepositedFundsId
,a.ysnEnableCreditCardProcessing
,a.strMerchantId
,a.strMerchantPassword
,a.intFreightTermId
,a.strFreightTerm
,b.intEntityId
FROM vyuSMGetCompanyLocationSearchList a
INNER JOIN tblSMUserSecurityCompanyLocationRolePermission b ON a.intCompanyLocationId = b.intCompanyLocationId
