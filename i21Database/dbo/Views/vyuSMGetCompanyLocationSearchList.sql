CREATE VIEW [dbo].[vyuSMGetCompanyLocationSearchList]
AS 
SELECT 
 compLoc.[intCompanyLocationId]
,compLoc.[strLocationName]
,compLoc.[strLocationNumber]
,compLoc.[strLocationType]
,compLoc.[strAddress]
,compLoc.[strZipPostalCode]
,compLoc.[strCity]
,compLoc.[strStateProvince]
,compLoc.[strCountry]
,compLoc.[strPhone]
,compLoc.[strFax]
,compLoc.[strEmail]
,compLoc.[strWebsite]
,compLoc.[dblLongitude]
,compLoc.[dblLatitude]
,compLoc.[strInternalNotes]
,compLoc.[strUseLocationAddress]
,compLoc.[strSkipSalesmanDefault]
,compLoc.[ysnSkipTermsDefault]
,compLoc.[strOrderTypeDefault]
,compLoc.[strPrintCashReceipts]
,compLoc.[ysnPrintCashTendered]
,compLoc.[strSalesTaxByLocation]
,compLoc.[strDeliverPickupDefault]
,compLoc.[intTaxGroupId]
,compLoc.[strTaxState]
,compLoc.[strTaxAuthorityId1]
,compLoc.[strTaxAuthorityId2]
,compLoc.[ysnOverridePatronage]
,compLoc.[strOutOfStockWarning]
,compLoc.[strLotOverdrawnWarning]
,compLoc.[strDefaultCarrier]
,compLoc.[ysnOrderSection2Required]
,compLoc.[strPrintonPO]
,compLoc.[dblMixerSize]
,compLoc.[ysnOverrideMixerSize]
,compLoc.[ysnEvenBatches]
,compLoc.[ysnDefaultCustomBlend]
,compLoc.[ysnAgroguideInterface]
,compLoc.[ysnLocationActive]
,compLoc.[intProfitCenter]
,compLoc.[intCashAccount]
,compLoc.[intDepositAccount]
,compLoc.[intARAccount]
,compLoc.[intAPAccount]
,compLoc.[intSalesAdvAcct]
,compLoc.[intPurchaseAdvAccount]
,compLoc.[intFreightAPAccount]
,compLoc.[intFreightExpenses]
,compLoc.[intFreightIncome]
,compLoc.[intServiceCharges]
,compLoc.[intSalesDiscounts]
,compLoc.[intCashOverShort]
,compLoc.[intWriteOff]
,compLoc.[intCreditCardFee]
,compLoc.[intSalesAccount]
,compLoc.[intCostofGoodsSold]
,compLoc.[intInventory]
,compLoc.[intWriteOffSold]
,compLoc.[intRevalueSold]
,compLoc.[intAutoNegativeSold]
,compLoc.[intAPClearing]
,compLoc.[intInventoryInTransit]
,compLoc.[intWithholdAccountId]
,compLoc.[intDiscountAccountId]
,compLoc.[intInterestAccountId]
,compLoc.[intPrepaidAccountId]
,compLoc.[intUndepositedFundsId]
,compLoc.[strInvoiceType]
,compLoc.[strDefaultInvoicePrinter]
,compLoc.[strPickTicketType]
,compLoc.[strDefaultTicketPrinter]
,compLoc.[strLastOrderNumber]
,compLoc.[strLastInvoiceNumber]
,compLoc.[strPrintonInvoice]
,compLoc.[ysnPrintContractBalance]
,compLoc.[strJohnDeereMerchant]
,compLoc.[strInvoiceComments]
,compLoc.[ysnUseOrderNumberforInvoiceNumber]
,compLoc.[ysnOverrideOrderInvoiceNumber]
,compLoc.[ysnPrintInvoiceMedTags]
,compLoc.[ysnPrintPickTicketMedTags]
,compLoc.[ysnSendtoEnergyTrac]
,compLoc.[strDiscountScheduleType]
,compLoc.[strLocationDiscount]
,compLoc.[strLocationStorage]
,compLoc.[strMarketZone]
,compLoc.[strLastTicket]
,compLoc.[ysnDirectShipLocation]
,compLoc.[ysnScaleInstalled]
,compLoc.[strDefaultScaleId]
,compLoc.[ysnActive]
,compLoc.[ysnUsingCashDrawer]
,compLoc.[strCashDrawerDeviceId]
,compLoc.[ysnPrintRegisterTape]
,compLoc.[ysnUseUPConOrders]
,compLoc.[ysnUseUPConPhysical]
,compLoc.[ysnUseUPConPurchaseOrders]
,compLoc.[strUPCSearchSequence]
,compLoc.[strBarCodePrinterName]
,compLoc.[strPriceLevel1]
,compLoc.[strPriceLevel2]
,compLoc.[strPriceLevel3]
,compLoc.[strPriceLevel4]
,compLoc.[strPriceLevel5]
,compLoc.[ysnOverShortEntries]
,compLoc.[strOverShortCustomer]
,compLoc.[strOverShortAccount]
,compLoc.[ysnAutomaticCashDepositEntries]
,compLoc.[dblWithholdPercent]
,compLoc.[intAllowablePickDayRange]
,compLoc.[ysnAllowCreateSKUContainer]
,compLoc.[ysnAllowMoveAssignedTask]
,compLoc.[ysnAllowPutAwayUnitTypes]
,compLoc.[ysnAutoCommentsUpdate]
,compLoc.[ysnAutoPositiveReleaseForBlendedLot]
,compLoc.[dblAverageDensity]
,compLoc.[strBagMarksPattern]
,compLoc.[intBlendProductionDockDoorUnitId]
,compLoc.[intBlendProductionStagingUnitId]
,compLoc.[ysnBlendAffordabilityCheck]
,compLoc.[ysnCreateOutboundOrderOnBlendsheetRelease]
,compLoc.[ysnCreateLoadTasks]
,compLoc.[ysnCreatePutAwayTask]
,compLoc.[intDefaultCarrierId]
,compLoc.[strDefaultTerms]
,compLoc.[intDefaultBlendProductionLocationId]
,compLoc.[ysnDefaultPalletTagReprintonPositiveRelease]
,compLoc.[intDefaultStatusForPreSanitizedLotId]
,compLoc.[intDefaultInboundDockDoorUnitId]
,compLoc.[ysnEDI944]
,compLoc.[ysnEDI945]
,compLoc.[ysnShiftActivityTimeDisable]
,compLoc.[strFGReleaseMailCCAddress]
,compLoc.[strFGReleaseMailTOAddress]
,compLoc.[ysnGTINCaseCodeMandatory]
,compLoc.[intHistoricalStagingTicketLocationId]
,compLoc.[ysnPalletCreateDelayEnabled]
,compLoc.[strLotIDPrefix]
,compLoc.[strLotOrigin]
,compLoc.[strMailBCCAddress]
,compLoc.[strMailCCAddress]
,compLoc.[strMailFromAddress]
,compLoc.[strMailServer]
,compLoc.[strMailServerPassword]
,compLoc.[strMailServerUserDomain]
,compLoc.[strMailServerUserName]
,compLoc.[strMailToAddress]
,compLoc.[strExternalDatabaseName]
,compLoc.[strExternalServerName]
,compLoc.[strExternalCLRSPURL]
,compLoc.[ysnModifyAffordability]
,compLoc.[ysnModifyBudget]
,compLoc.[intNoOfCopiesToPrintforPalletSlip]
,compLoc.[ysnOverrideAffordability]
,compLoc.[ysnOverrideBudget]
,compLoc.[strPalletSlipPrinterName]
,compLoc.[strPhysicalCountPattern]
,compLoc.[strProductAlertMailCCAddress]
,compLoc.[strProductAlertMailTOAddress]
,compLoc.[intProductAlertOwnerId]
,compLoc.[ysnReceiptConnToERP]
,compLoc.[ysnReceiptFeedToERP]
,compLoc.[ysnRestrictOrdersToOneOwner]
,compLoc.[intSanitizationDockDoorUnitId]
,compLoc.[dblSanitizationOrderInputQtyTolerancePercentage]
,compLoc.[dblSanitizationOrderOutputQtyTolerancePercentage]
,compLoc.[intSanitizationStagingUnitId]
,compLoc.[intSanitizationStorageUnitId]
,compLoc.[ysnScanForkliftOnLogin]
,compLoc.[ysnSendEmailNotificationOnReceiptOfMaterials]
,compLoc.[ysnShowBlendProductionItemLineColor]
,compLoc.[ysnSKUPickByUnitType]
,compLoc.[strTagNoPattern]
,compLoc.[strTicketLabelPrinterName]
,compLoc.[strWMSMobileURL]
,compLoc.[ysnInventoryTransactionFeedToERP]
,compLoc.[strParentLotIdPattern]
,compLoc.[strPatternId]
,compLoc.[ysnProductionFeedToERP]
,compLoc.[dtmDefaultTimeForEarliestStartDate]
,compLoc.[intDemandNoMaxLength]
,compLoc.[intDemandNoMinLength]
,compLoc.[ysnEnableKittingProcess]
,compLoc.[ysnBlendStageIntegration]
,compLoc.[ysnProductCaseCodeScanningRequired]
,compLoc.[ysnYieldAdjustmentAllowed]
,compLoc.[ysnPrintInvTagOnReceivingComplete]
,compLoc.[intConcurrencyId]
,ISNULL(acctSgmt.strCode, '') strCode
,ISNULL(cash.[strAccountId], '') as strCashAccount
,ISNULL(deposit.[strAccountId], '') as strDepositAccount
,ISNULL(arAccount.[strAccountId], '') as strARAccount
,ISNULL(apAccount.[strAccountId], '') as strAPAccount
,ISNULL(salesAdvAcct.[strAccountId], '') as strSalesAdvAcct
,ISNULL(purchaseAdvAccount.[strAccountId], '') as strPurchaseAdvAccount
,ISNULL(freightAPAccount.[strAccountId], '') as strFreightAPAccount
,ISNULL(freightExpenses.[strAccountId], '') as strFreightExpenses
,ISNULL(freightIncome.[strAccountId], '') as strFreightIncome
,ISNULL(serviceCharges.[strAccountId], '') as strServiceCharges
,ISNULL(salesDiscounts.[strAccountId], '') as strSalesDiscounts
,ISNULL(cashOverShort.[strAccountId], '') as strCashOverShort
,ISNULL(writeOff.[strAccountId], '') as strWriteOff
,ISNULL(creditCardFee.[strAccountId], '') as strCreditCardFee
,ISNULL(salesAccount.[strAccountId], '') as strSalesAccount
,ISNULL(costofGoodsSold.[strAccountId], '') as strCostofGoodsSold
,ISNULL(inventory.[strAccountId], '') as strInventory
,ISNULL(writeOffSold.[strAccountId], '') as strWriteOffSold
,ISNULL(revalueSold.[strAccountId], '') as strRevalueSold
,ISNULL(autoNegativeSold.[strAccountId], '') as strAutoNegativeSold
,ISNULL(apClearing.[strAccountId], '') as strAPClearing
,ISNULL(inventoryInTransit.[strAccountId], '') as strInventoryInTransit
,ISNULL(withholdAccountId.[strAccountId], '') as strWithholdAccountId
,ISNULL(discountAccountId.[strAccountId], '') as strDiscountAccountId
,ISNULL(interestAccountId.[strAccountId], '') as strstrerestAccountId
,ISNULL(prepaidAccountId.[strAccountId], '') as strPrepaidAccountId
,ISNULL(undepositedFundsId.[strAccountId], '') as strUndepositedFundsId
FROM tblSMCompanyLocation compLoc
LEFT OUTER JOIN dbo.tblGLAccountSegment acctSgmt ON compLoc.intProfitCenter = acctSgmt.intAccountSegmentId
LEFT JOIN tblGLAccount cash ON compLoc.intCashAccount = cash.intAccountId
LEFT JOIN tblGLAccount deposit ON compLoc.intDepositAccount = deposit.intAccountId
LEFT JOIN tblGLAccount arAccount ON compLoc.intARAccount = arAccount.intAccountId
LEFT JOIN tblGLAccount apAccount ON compLoc.intAPAccount = apAccount.intAccountId
LEFT JOIN tblGLAccount salesAdvAcct ON compLoc.intSalesAdvAcct = salesAdvAcct.intAccountId
LEFT JOIN tblGLAccount purchaseAdvAccount ON compLoc.intPurchaseAdvAccount = purchaseAdvAccount.intAccountId
LEFT JOIN tblGLAccount freightAPAccount ON compLoc.intFreightAPAccount = freightAPAccount.intAccountId
LEFT JOIN tblGLAccount freightExpenses ON compLoc.intFreightExpenses = freightExpenses.intAccountId
LEFT JOIN tblGLAccount freightIncome ON compLoc.intFreightIncome = freightIncome.intAccountId
LEFT JOIN tblGLAccount serviceCharges ON compLoc.intServiceCharges = serviceCharges.intAccountId
LEFT JOIN tblGLAccount salesDiscounts ON compLoc.intSalesDiscounts = salesDiscounts.intAccountId
LEFT JOIN tblGLAccount cashOverShort ON compLoc.intCashOverShort = cashOverShort.intAccountId
LEFT JOIN tblGLAccount writeOff ON compLoc.intWriteOff = writeOff.intAccountId
LEFT JOIN tblGLAccount creditCardFee ON compLoc.intCreditCardFee = creditCardFee.intAccountId
LEFT JOIN tblGLAccount salesAccount ON compLoc.intSalesAccount = salesAccount.intAccountId
LEFT JOIN tblGLAccount costofGoodsSold ON compLoc.intCostofGoodsSold = costofGoodsSold.intAccountId
LEFT JOIN tblGLAccount inventory ON compLoc.intInventory = inventory.intAccountId
LEFT JOIN tblGLAccount writeOffSold ON compLoc.intWriteOffSold = writeOffSold.intAccountId
LEFT JOIN tblGLAccount revalueSold ON compLoc.intRevalueSold = revalueSold.intAccountId
LEFT JOIN tblGLAccount autoNegativeSold ON compLoc.intAutoNegativeSold = autoNegativeSold.intAccountId
LEFT JOIN tblGLAccount apClearing ON compLoc.intAPClearing = apClearing.intAccountId
LEFT JOIN tblGLAccount inventoryInTransit ON compLoc.intInventoryInTransit = inventoryInTransit.intAccountId
LEFT JOIN tblGLAccount withholdAccountId ON compLoc.intWithholdAccountId = withholdAccountId.intAccountId
LEFT JOIN tblGLAccount discountAccountId ON compLoc.intDiscountAccountId = discountAccountId.intAccountId
LEFT JOIN tblGLAccount interestAccountId ON compLoc.intInterestAccountId = interestAccountId.intAccountId
LEFT JOIN tblGLAccount prepaidAccountId ON compLoc.intPrepaidAccountId = prepaidAccountId.intAccountId
LEFT JOIN tblGLAccount undepositedFundsId ON compLoc.intUndepositedFundsId = undepositedFundsId.intAccountId
