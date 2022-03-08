CREATE VIEW vyuARGetCustomer
AS
SELECT intEntityId							= C.intEntityId
     , strName								= E.strName
     , strEmail								= E.strEmail
     , strWebsite							= E.strWebsite
     , strInternalNotes						= E.strInternalNotes
     , ysnPrint1099							= E.ysnPrint1099
     , str1099Name							= E.str1099Name
     , str1099Form							= E.str1099Form
     , str1099Type							= E.str1099Type
     , strFederalTaxId						= E.strFederalTaxId
     , dtmW9Signed							= E.dtmW9Signed
     , imgPhoto								= E.imgPhoto
     , strContactNumber						= E.strContactNumber
     , strTitle								= E.strTitle
     , strDepartment						= E.strDepartment
     , strMobile							= E.strMobile
     , strPhone								= E.strPhone
     , strPhone2							= E.strPhone2
     , strEmail2							= E.strEmail2
     , strFax								= E.strFax
     , strNotes								= E.strNotes
     , strContactMethod						= E.strContactMethod
     , strTimezone							= E.strTimezone
     , strEntityNo							= E.strEntityNo
     , strContactType						= E.strContactType
     , intDefaultLocationId					= E.intDefaultLocationId
     , ysnActive							= C.ysnActive
     , ysnReceiveEmail						= E.ysnReceiveEmail
     , strEmailDistributionOption			= E.strEmailDistributionOption
     , dtmOriginationDate					= E.dtmOriginationDate
     , strPhoneBackUp						= E.strPhoneBackUp
     , intDefaultCountryId					= E.intDefaultCountryId
     , strDocumentDelivery					= E.strDocumentDelivery
     , strNickName							= E.strNickName
     , strSuffix							= E.strSuffix
     , intEntityClassId						= E.intEntityClassId
     , strExternalERPId						= E.strExternalERPId
     , strStateTaxId						= E.strStateTaxId
     , ysnUserPortalAccess					= CASE WHEN E2C2.intEntityContactId IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
     , intUserPortalAccessAdminEntityId		= E2C2.intEntityContactId
     , intPortalRoleId						= SETR.intUserRoleID
     , strUserPortalPassword				= E2C2.strPassword
     , strPortalAccessEntityName			= E2C2.strEntityContactName
     , strPortalRole						= SETR.strRoleName
     , strCustomerNumber					= C.strCustomerNumber
     , strType								= C.strType
     , dblCreditLimit						= C.dblCreditLimit
     , dblARBalance							= C.dblARBalance
     , strAccountNumber						= C.strAccountNumber
     , strTaxNumber							= C.strTaxNumber
     , intCurrencyId						= C.intCurrencyId
     , intAccountStatusId					= C.intAccountStatusId
     , intSalespersonId						= C.intSalespersonId
     , strPricing							= C.strPricing
     , strLevel								= C.strLevel
     , dblPercent							= C.dblPercent
     , intBillToId							= C.intBillToId
     , strBillTo							= BILLTO.strLocationName
     , intShipToId							= C.intShipToId
     , strTaxState							= C.strTaxState
     , ysnPORequired						= C.ysnPORequired
     , ysnCreditHold						= C.ysnCreditHold
     , ysnStatementDetail					= C.ysnStatementDetail
     , ysnStatementCreditLimit				= C.ysnStatementCreditLimit
     , strStatementFormat					= C.strStatementFormat
     , intCreditStopDays					= C.intCreditStopDays
     , dtmCreditLimitReached				= C.dtmCreditLimitReached
     , strTaxAuthority1						= C.strTaxAuthority1
     , strTaxAuthority2						= C.strTaxAuthority2
     , ysnPrintPriceOnPrintTicket			= C.ysnPrintPriceOnPrintTicket
     , intServiceChargeId					= C.intServiceChargeId
     , ysnApplySalesTax						= C.ysnApplySalesTax
     , ysnApplyPrepaidTax					= C.ysnApplyPrepaidTax
     , dblBudgetAmountForBudgetBilling		= C.dblBudgetAmountForBudgetBilling
     , strBudgetBillingBeginMonth			= C.strBudgetBillingBeginMonth
     , strBudgetBillingEndMonth				= C.strBudgetBillingEndMonth
     , ysnCalcAutoFreight					= C.ysnCalcAutoFreight
     , strUpdateQuote						= C.strUpdateQuote
     , strCreditCode						= C.strCreditCode
     , strDiscSchedule						= C.strDiscSchedule
     , strPrintInvoice						= C.strPrintInvoice
     , ysnSpecialPriceGroup					= C.ysnSpecialPriceGroup
     , ysnExcludeDunningLetter				= C.ysnExcludeDunningLetter
     , strLinkCustomerNumber				= C.strLinkCustomerNumber
     , intReferredByCustomer				= C.intReferredByCustomer
     , ysnReceivedSignedLiscense			= C.ysnReceivedSignedLiscense
     , strDPAContract						= C.strDPAContract
     , dtmDPADate							= C.dtmDPADate
     , strGBReceiptNumber					= C.strGBReceiptNumber
     , ysnCheckoffExempt					= C.ysnCheckoffExempt
     , ysnVoluntaryCheckoff					= C.ysnVoluntaryCheckoff
     , strCheckoffState						= C.strCheckoffState
     , ysnMarketAgreementSigned				= C.ysnMarketAgreementSigned
     , intMarketZoneId						= C.intMarketZoneId
     , ysnHoldBatchGrainPayment				= C.ysnHoldBatchGrainPayment
     , ysnFederalWithholding				= C.ysnFederalWithholding
     , strAEBNumber							= C.strAEBNumber
     , strAgrimineId						= C.strAgrimineId
     , strHarvestPartnerCustomerId			= C.strHarvestPartnerCustomerId
     , strComments							= C.strComments
     , ysnTransmittedCustomer				= C.ysnTransmittedCustomer
     , dtmMembershipDate					= C.dtmMembershipDate
     , dtmBirthDate							= C.dtmBirthDate
     , dtmLastActivityDate					= C.dtmLastActivityDate
     , strStockStatus						= C.strStockStatus
     , dtmDeceasedDate						= C.dtmDeceasedDate
     , ysnHDBillableSupport					= C.ysnHDBillableSupport
     , strScreenConnectLink					= C.strScreenConnectLink
     , intTaxCodeId							= C.intTaxCodeId
     , intContractGroupId					= C.intContractGroupId
     , intBuybackGroupId					= C.intBuybackGroupId
     , intPriceGroupId						= C.intPriceGroupId
     , ysnTaxExempt							= C.ysnTaxExempt
     , ysnProspect							= C.ysnProspect
     , strJiraCustomer						= C.strJiraCustomer
     , intInterCompanyId					= C.intInterCompanyId
     , strInterCompanyId					= SIC.strCompanyName
     , intInterCompanyLocationId			= C.intInterCompanyLocationId
     , strInterCompanyLocationId			= C.strInterCompanyLocationId
     , intInterCompanyVendorId				= C.intInterCompanyVendorId
     , strInterCompanyVendorId				= C.strInterCompanyVendorId
     , strVatNumber							= C.strVatNumber
     , dblMonthlyBudget						= C.dblMonthlyBudget
     , intNoOfPeriods						= C.intNoOfPeriods
     , dtmBudgetBeginDate					= C.dtmBudgetBeginDate
     , strFLOId								= C.strFLOId
     , intCompanyLocationPricingLevelId		= C.intCompanyLocationPricingLevelId
     , intEntityTariffTypeId				= C.intEntityTariffTypeId
     , dblRevenue							= C.dblRevenue
     , intEmployeeCount						= C.intEmployeeCount
     , ysnIncludeEntityName					= C.ysnIncludeEntityName
     , ysnCustomerBudgetTieBudget			= C.ysnCustomerBudgetTieBudget
     , intInvoicePostingApprovalId			= C.intInvoicePostingApprovalId
     , intOverCreditLimitApprovalId			= C.intOverCreditLimitApprovalId
     , intOrderApprovalApprovalId			= C.intOrderApprovalApprovalId
     , intQuoteApprovalApprovalId			= C.intQuoteApprovalApprovalId
     , intOrderQuantityShortageApprovalId	= C.intOrderQuantityShortageApprovalId
     , intReceivePaymentPostingApprovalId	= C.intReceivePaymentPostingApprovalId
     , intCommisionsApprovalId				= C.intCommisionsApprovalId
     , intPastDueApprovalId					= C.intPastDueApprovalId
     , intPriceChangeApprovalId				= C.intPriceChangeApprovalId
     , ysnApprovalsNotRequired				= C.ysnApprovalsNotRequired
     , intTermsId							= C.intTermsId
     , intPaymentMethodId					= C.intPaymentMethodId
     , dtmLastServiceCharge					= C.dtmLastServiceCharge
     , intLanguageId						= E.intLanguageId
     , strClass								= ECLASS.strClass
     , strPriceGroup						= CG.strGroupName
     , strEntityLanguage					= LANG.strLanguage
     , strTariffType						= ETT.strTariffType
     , strBillToLocationName				= BILLTO.strLocationName
     , strShipToLocationName				= SHIPTO.strLocationName
     , strEntitySalesperson					= ESP.strName
     , strCurrency							= CUR.strCurrency
     , strPaymentMethod						= PM.strPaymentMethod
     , strTerm								= TERM.strTerm
     , strServiceChargeCode					= SC.strServiceChargeCode
     , strReferredCustomer					= RCUST.strName
     , strInvoicePostingApproval			= SMIP.strApprovalList
     , strOverCreditLimitApproval			= SMOCL.strApprovalList
     , strOrderApprovalApproval				= SMOA.strApprovalList
     , strQuoteApprovalApproval				= SMQA.strApprovalList
     , strOrderQuantityShortageApproval		= SMOQS.strApprovalList
     , strReceivePaymentPostingApproval		= SMRPP.strApprovalList
     , strCommisionsApproval				= SMC.strApprovalList
     , strPastDueApproval					= SMPD.strApprovalList
     , strPriceChangeApproval				= SMPC.strApprovalList
     , strMarketZoneCode					= MZ.strMarketZoneCode
     , dblRunningBalance					= ISNULL(HISTORY.dblAmountDue, 0)
     , strBatchInvoiceBy					= C.strBatchInvoiceBy
     , dtmBatchTimeFrom						= C.dtmBatchTimeFrom
     , dtmBatchTimeTo						= C.dtmBatchTimeTo
     , intConcurrencyId						= E.intConcurrencyId
     , ysnExemptCreditCardFee				= C.ysnExemptCreditCardFee
FROM tblARCustomer C
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
LEFT JOIN tblSMLanguage LANG ON E.intLanguageId = LANG.intLanguageId
LEFT JOIN tblEMEntityLocation SHIPTO ON C.intShipToId = SHIPTO.intEntityLocationId AND SHIPTO.ysnDefaultLocation = 1
LEFT JOIN tblEMEntityLocation BILLTO ON C.intBillToId = BILLTO.intEntityLocationId AND BILLTO.ysnDefaultLocation = 1
LEFT JOIN tblSMCurrency CUR ON C.intCurrencyId = CUR.intCurrencyID
LEFT JOIN tblSMTerm TERM ON C.intTermsId = TERM.intTermID
LEFT JOIN tblSMPaymentMethod PM ON C.intPaymentMethodId = PM.intPaymentMethodID
LEFT JOIN tblARServiceCharge SC ON C.intServiceChargeId = SC.intServiceChargeId
LEFT JOIN tblARCustomerGroup CG ON C.intPriceGroupId = CG.intCustomerGroupId
LEFT JOIN tblEMEntityClass ECLASS ON E.intEntityClassId = ECLASS.intEntityClassId
LEFT JOIN tblARSalesperson SP ON C.intSalespersonId = SP.intEntityId
LEFT JOIN tblEMEntity ESP ON SP.intEntityId = ESP.intEntityId
LEFT JOIN tblEMEntityTariffType ETT ON C.intEntityTariffTypeId = ETT.intEntityTariffTypeId
LEFT JOIN tblARMarketZone MZ ON C.intMarketZoneId = MZ.intMarketZoneId
LEFT JOIN tblSMApprovalList SMIP ON C.intInvoicePostingApprovalId = SMIP.intApprovalListId
LEFT JOIN tblSMApprovalList SMOCL ON C.intOverCreditLimitApprovalId = SMOCL.intApprovalListId
LEFT JOIN tblSMApprovalList SMOA ON C.intOrderApprovalApprovalId = SMOA.intApprovalListId
LEFT JOIN tblSMApprovalList SMQA ON C.intQuoteApprovalApprovalId = SMQA.intApprovalListId
LEFT JOIN tblSMApprovalList SMOQS ON C.intOrderQuantityShortageApprovalId = SMOQS.intApprovalListId
LEFT JOIN tblSMApprovalList SMRPP ON C.intReceivePaymentPostingApprovalId = SMRPP.intApprovalListId
LEFT JOIN tblSMApprovalList SMC ON C.intCommisionsApprovalId = SMC.intApprovalListId
LEFT JOIN tblSMApprovalList SMPD ON C.intPastDueApprovalId = SMPD.intApprovalListId
LEFT JOIN tblSMApprovalList SMPC ON C.intPriceChangeApprovalId = SMPC.intApprovalListId
LEFT JOIN tblEMEntity RCUST ON C.intReferredByCustomer = RCUST.intEntityId
LEFT JOIN tblSMInterCompany SIC ON C.intInterCompanyId = SIC.intInterCompanyId
OUTER APPLY (
	SELECT TOP 1 strPassword
		 , strEntityContactName
		 , intEntityId
		 , intEntityContactId
	FROM vyuEME2C2Role E2C2
	WHERE E2C2.ysnPortalAdmin = 1
	  AND E2C2.intEntityId = E.intEntityId --NOT SURE
) E2C2  
OUTER APPLY (
	SELECT TOP 1 intUserRoleID
		 , strRoleName
	FROM vyuEMUserSecurityEntityToRole SETR
	WHERE SETR.ysnPortalAdmin = 1
	  AND SETR.intEntityId = E.intEntityId
) SETR
LEFT JOIN (
	SELECT intEntityCustomerId
		 , dblAmountDue			= SUM(dblAmountDue)
	FROM vyuARCustomerHistory
	GROUP BY intEntityCustomerId
) HISTORY ON C.intEntityId = HISTORY.intEntityCustomerId