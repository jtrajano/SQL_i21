CREATE PROCEDURE [dbo].[uspApiSchemaTransformCustomer] (
      @guiApiUniqueId UNIQUEIDENTIFIER
    , @guiLogId UNIQUEIDENTIFIER
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON

-- VALIDATE
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Name'
    , strValue = SC.strCustomerName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Customer Name is blank.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(strCustomerName, ''))) = '' 

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Location Name'
    , strValue = SC.strLocationName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Location Name is blank.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(strLocationName, ''))) = '' 

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
	  guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Entity No'
    , strValue = strEntityNumber
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Entity No ('+ SC.strEntityNumber + ') already exists.'
FROM tblApiSchemaCustomer SC
WHERE SC.guiApiUniqueId = @guiApiUniqueId
AND EXISTS (SELECT TOP 1 NULL FROM tblEMEntity WHERE strEntityNo = strEntityNumber)

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Number'
    , strValue = strCustomerNumber
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Customer Number ('+ SC.strCustomerNumber + ') has special characters.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND PATINDEX('%[^a-zA-Z0-9]%', RTRIM(LTRIM(SC.strCustomerNumber))) > 0

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Number'
    , strValue = strCustomerNumber
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Customer Number ('+ strCustomerNumber + ') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND EXISTS (SELECT TOP 1 NULL FROM tblARCustomer WHERE strCustomerNumber = SC.strCustomerNumber)

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Language'
    , strValue = SC.strLanguage
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Language ('+ SC.strLanguage + ') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(strLanguage, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intLanguageId FROM tblSMLanguage WHERE strLanguage = strLanguage))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Currency'
    , strValue = SC.strCurrency
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Curreny ('+ SC.strCurrency +') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE SC.guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strCurrency, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = SC.strCurrency))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Ship Via'
    , strValue = SC.strShipVia
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Ship Via ('+ SC.strShipVia +') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE SC.guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strShipVia, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 SMSV.intEntityId FROM tblSMShipVia SMSV JOIN tblEMEntity EME on SMSV.intEntityId = EME.intEntityId WHERE SMSV.strShipVia = SC.strShipVia))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Freight Term'
    , strValue = SC.strFreightTerm
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Freight Term ('+ SC.strFreightTerm +') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strFreightTerm, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intFreightTermId FROM tblSMFreightTerms WHERE strFreightTerm = SC.strFreightTerm))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Terms'
    , strValue = SC.strTerms
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Terms ('+ SC.strTerms +') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE SC.guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strTerms, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = SC.strTerms))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Document Delivery'
    , strValue = SC.strDocumentDelivery
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Document Delivery (' +  SC.strDocumentDelivery + ') does not exists. Use one IN (Direct Mail, Email, Fax, Web Portal).'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strDocumentDelivery, ''))) <> '' AND SC.strDocumentDelivery NOT IN ('Direct Mail', 'Email', 'Fax', 'Web Portal')

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Payment Method'
    , strValue = SC.strPaymentMethod
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Payment Method (' +  strPaymentMethod + ') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strPaymentMethod, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = SC.strPaymentMethod))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Salesperson'
    , strValue = SC.strSalesperson
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Salesperson (' +  SC.strSalesperson + ') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(strSalesperson, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 ARS.intEntityId FROM tblARSalesperson ARS JOIN tblEMEntity EME ON ARS.intEntityId = EME.intEntityId WHERE ARS.strSalespersonId = SC.strSalesperson or EME.strEntityNo = SC.strSalesperson))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Tax County'
    , strValue = SC.strTaxCounty
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Tax County ('+ SC.strTaxCounty +') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strTaxCounty, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intTaxCodeId FROM tblSMTaxCode WHERE strCounty = SC.strTaxCounty))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Credit Code'
    , strValue = SC.strCreditCode
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Credit Code ('+ SC.strCreditCode +') does not exists. Use one IN (Always Allow, Normal, Monitoring, Always Hold, Reject Orders).'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strCreditCode, ''))) <> '' AND SC.strCreditCode NOT IN ('Always Allow', 'Normal', 'Monitoring', 'Always Hold', 'Reject Orders')

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Budget Begin Date'
    , strValue = SC.strBudgetBeginDate
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Budget Begin Date ('+ SC.strBudgetBeginDate +') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strBudgetBeginDate, ''))) <> '' AND ISDATE(SC.strBudgetBeginDate) <> 1

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Statement Format'
    , strValue = SC.strStatementFormat
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Statement Format ('+ SC.strStatementFormat +') does not exists. Use one IN (Open Item, Open Statement - Lazer, Balance Forward, Budget Reminder, Payment Activity, Running Balance, Full Details - No Card Lock, None).'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strStatementFormat, ''))) <> '' AND SC.strStatementFormat NOT IN ('Open Item', 'Open Statement - Lazer', 'Balance Forward', 'Budget Reminder', 'Payment Activity', 'Running Balance', 'Full Details - No Card Lock', 'None')

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Service Charge'
    , strValue = SC.strServiceCharge
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Service Charge ('+ SC.strServiceCharge +') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strServiceCharge, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intServiceChargeId FROM tblARServiceCharge WHERE strServiceChargeCode = SC.strServiceCharge))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Last Service Charge Date'
    , strValue = SC.strLastServiceChargeDate
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Last Service Charge Date ('+ SC.strLastServiceChargeDate +') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strLastServiceChargeDate, ''))) <> '' AND ISDATE(SC.strLastServiceChargeDate) <> 1

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Update Quote'
    , strValue = SC.strUpdateQuote
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Update Quote ('+ SC.strUpdateQuote +') does not exists. Use one IN (Yes, No, Deviation).'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strUpdateQuote, ''))) <> '' AND SC.strUpdateQuote NOT IN ('Yes', 'No', 'Deviation')


INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Print Invoice'
    , strValue = SC.strPrintInvoice
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SC.intRowNumber
    , strMessage = 'Print Invoice ('+ SC.strPrintInvoice +') does not exists. Use one IN (Yes, Petrolac Only,Transports Only, None).'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SC.strPrintInvoice, ''))) <> '' AND SC.strPrintInvoice NOT IN ('Yes', 'Petrolac Only', 'Transports Only','None')

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Account Status'
    , strValue = SC.strStatus
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Status (' +  SC.strStatus + ') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strStatus, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 intAccountStatusId FROM tblARAccountStatus WHERE strAccountStatusCode = SC.strStatus))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Current System'
    , strValue = SC.strCurrentSystem
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = intRowNumber
    , strMessage = 'Current System (' +  SC.strCurrentSystem + ') does not exists.'
FROM tblApiSchemaCustomer SC
WHERE guiApiUniqueId = @guiApiUniqueId
AND (RTRIM(LTRIM(ISNULL(SC.strCurrentSystem, ''))) <> '' AND NOT EXISTS(SELECT TOP 1 EME.intEntityId FROM tblEMEntity EME join tblEMEntityType EMET ON EME.intEntityId = EMET.intEntityId and EMET.strType = 'Competitor' WHERE strName = SC.strCurrentSystem))

-- TRANSFORM
DECLARE @intEntityId	INT
DECLARE	@intContactId	INT
DECLARE @intLocationId	INT

DECLARE   @strEntityNumber				NVARCHAR(100)
		, @strCustomerName				NVARCHAR(100)
		, @strOriginationDate			NVARCHAR(100)
		, @strDocumentDelivery			NVARCHAR(100)
		, @strExternalERP				NVARCHAR(100)
		, @strFederalTax				NVARCHAR(100)
		, @strStateTax					NVARCHAR(100)
		, @strSuffix					NVARCHAR(100)
		, @strEmail						NVARCHAR(100)
		, @strLanguage					NVARCHAR(100)
		, @strInternalNotes				NVARCHAR(100)
		, @strLocationName				NVARCHAR(100)
		, @strPrintedName				NVARCHAR(100)
		, @strAddress					NVARCHAR(100)
		, @strCity						NVARCHAR(100)
		, @strState						NVARCHAR(100)
		, @strZip						NVARCHAR(100)
		, @strCountry 					NVARCHAR(100)
		, @strTimezone					NVARCHAR(100)
		, @strCurrency					NVARCHAR(100)
		, @strTerms						NVARCHAR(100)
		, @strShipVia					NVARCHAR(100)
		, @strFreightTerm				NVARCHAR(100)
		, @strType						NVARCHAR(100)
		, @strStatus					NVARCHAR(100)
		, @strPaymentMethod				NVARCHAR(100)
		, @strAccountNo					NVARCHAR(100)
		, @strSalesperson				NVARCHAR(100)
		, @strFLO						NVARCHAR(100)
		, @strTaxNumber					NVARCHAR(100)
		, @strExemptAllTax				NVARCHAR(100)
		, @strEmployeeCount				NVARCHAR(100)
		, @strVatNumber					NVARCHAR(100)
		, @strRevenue					NVARCHAR(100)
		, @strCreditLimit				NVARCHAR(100)
		, @strCreditStopDays			NVARCHAR(100)
		, @strCreditCode				NVARCHAR(100)
		, @strActive					NVARCHAR(100)
		, @strPORequired				NVARCHAR(100)
		, @strCreditHold				NVARCHAR(100)
		, @strBudgetBeginDate			NVARCHAR(100)
		, @strBudgetMonthly				NVARCHAR(100)
		, @strBudgetNoPeriod			NVARCHAR(100)
		, @strBudgetTieCustomerAging	NVARCHAR(100)
		, @strStatementDetail			NVARCHAR(100)
		, @strStatementCreditLimit		NVARCHAR(100)
		, @strStatementFormat			NVARCHAR(100)
		, @strServiceCharge				NVARCHAR(100)
		, @strTaxCounty					NVARCHAR(100)
		, @strLastServiceChargeDate		NVARCHAR(100)
		, @strApplyPrepaidTax			NVARCHAR(100)
		, @strApplySalesTax				NVARCHAR(100)
		, @strCalculateAutoFreight		NVARCHAR(100)
		, @strUpdateQuote				NVARCHAR(100)
		, @strDiscountSchedule			NVARCHAR(100)
		, @strPrintInvoice				NVARCHAR(100)
		, @strLinkCustomerNumber		NVARCHAR(100)
		, @strReferencebyCustomer		NVARCHAR(100)
		, @strSpecialPriceGroup			NVARCHAR(100)
		, @strExcludeDunningLetter		NVARCHAR(100)
		, @strReceivedSignedLicense		NVARCHAR(100)
		, @strPrintPriceOnPickTicket	NVARCHAR(100)
		, @strIncludeNameInAddress		NVARCHAR(100)
		, @strCustomerNumber			NVARCHAR(100)
		, @strPhone						NVARCHAR(100)
		, @strMobileNo					NVARCHAR(100)
		, @strCurrentSystem				NVARCHAR(100)
		, @intRowNumber					INT

DECLARE cursorSC CURSOR LOCAL FAST_FORWARD
FOR
SELECT
	  strEntityNumber
	, strCustomerName
	, strOriginationDate
	, strDocumentDelivery
	, strExternalERP
	, strFederalTax
	, strStateTax
	, strSuffix
	, strEmail
	, strLanguage
	, strInternalNotes
	, strLocationName
	, strPrintedName
	, strAddress
	, strCity
	, strState
	, strZip
	, strCountry 
	, strTimezone
	, strCurrency
	, strTerms
	, strShipVia
	, strFreightTerm
	, strType
	, strStatus
	, strPaymentMethod
	, strAccountNo
	, strSalesperson
	, strFLO
	, strTaxNumber
	, strExemptAllTax
	, strEmployeeCount
	, strVatNumber
	, strRevenue
	, strCreditLimit
	, strCreditStopDays
	, strCreditCode
	, strActive
	, strPORequired
	, strCreditHold
	, strBudgetBeginDate
	, strBudgetMonthly
	, strBudgetNoPeriod
	, strBudgetTieCustomerAging
	, strStatementDetail
	, strStatementCreditLimit
	, strStatementFormat
	, strServiceCharge
	, strTaxCounty
	, strLastServiceChargeDate
	, strApplyPrepaidTax
	, strApplySalesTax
	, strCalculateAutoFreight
	, strUpdateQuote
	, strDiscountSchedule
	, strPrintInvoice
	, strLinkCustomerNumber
	, strReferencebyCustomer
	, strSpecialPriceGroup
	, strExcludeDunningLetter
	, strReceivedSignedLicense
	, strPrintPriceOnPickTicket
	, strIncludeNameInAddress
	, strCustomerNumber
	, strPhone
	, strMobileNo
	, strCurrentSystem
	, intRowNumber
FROM	tblApiSchemaCustomer SC
WHERE	guiApiUniqueId = @guiApiUniqueId
AND		intRowNumber NOT IN (SELECT intRowNo FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId)

OPEN cursorSC;

FETCH NEXT FROM cursorSC INTO 
	  @strEntityNumber
	, @strCustomerName
	, @strOriginationDate
	, @strDocumentDelivery
	, @strExternalERP
	, @strFederalTax
	, @strStateTax
	, @strSuffix
	, @strEmail
	, @strLanguage
	, @strInternalNotes
	, @strLocationName
	, @strPrintedName
	, @strAddress
	, @strCity
	, @strState
	, @strZip
	, @strCountry 
	, @strTimezone
	, @strCurrency
	, @strTerms
	, @strShipVia
	, @strFreightTerm
	, @strType
	, @strStatus
	, @strPaymentMethod
	, @strAccountNo
	, @strSalesperson
	, @strFLO
	, @strTaxNumber
	, @strExemptAllTax
	, @strEmployeeCount
	, @strVatNumber
	, @strRevenue
	, @strCreditLimit
	, @strCreditStopDays
	, @strCreditCode
	, @strActive
	, @strPORequired
	, @strCreditHold
	, @strBudgetBeginDate
	, @strBudgetMonthly
	, @strBudgetNoPeriod
	, @strBudgetTieCustomerAging
	, @strStatementDetail
	, @strStatementCreditLimit
	, @strStatementFormat
	, @strServiceCharge
	, @strTaxCounty
	, @strLastServiceChargeDate
	, @strApplyPrepaidTax
	, @strApplySalesTax
	, @strCalculateAutoFreight
	, @strUpdateQuote
	, @strDiscountSchedule
	, @strPrintInvoice
	, @strLinkCustomerNumber
	, @strReferencebyCustomer
	, @strSpecialPriceGroup
	, @strExcludeDunningLetter
	, @strReceivedSignedLicense
	, @strPrintPriceOnPickTicket
	, @strIncludeNameInAddress
	, @strCustomerNumber
	, @strPhone
	, @strMobileNo
	, @strCurrentSystem
	, @intRowNumber
WHILE @@FETCH_STATUS = 0
BEGIN
	IF(ISNULL(@strEntityNumber, '') = '')
	BEGIN
		EXEC uspSMGetStartingNumber 43, @strEntityNumber OUT
	END

	INSERT INTO tblEMEntity(
		  strEntityNo
		, strName
		, strContactNumber 
		, dtmOriginationDate 
		, strDocumentDelivery 
		, strExternalERPId
		, strFederalTaxId 
		, strStateTaxId
	)
	SELECT 
		  @strEntityNumber
		, @strCustomerName
		, ''
		, CASE WHEN ISNULL(@strOriginationDate, '') <> '' THEN CASE WHEN ISDATE(@strOriginationDate) = 1 THEN CAST(@strOriginationDate AS DATETIME) ELSE GETDATE() END ELSE GETDATE() END
		, @strDocumentDelivery
		, @strExternalERP
		, @strFederalTax
		, @strStateTax

	SET @intEntityId = @@IDENTITY

	INSERT INTO tblEMEntity(
		  strName
		, strContactNumber
		, strSuffix
		, strEmail 
		, intLanguageId 
		, strInternalNotes
	)
	SELECT 
		  @strCustomerName
		, ''
		, @strSuffix 
		, @strEmail
		, (SELECT TOP 1 intLanguageId FROM tblSMLanguage WHERE strLanguage = @strLanguage)
		, @strInternalNotes

	SET @intContactId = @@IDENTITY

	INSERT INTO tblEMEntityLocation(
		  intEntityId
		, strLocationName
		, strCheckPayeeName
		, strAddress
		, strCity
		, strState
		, strZipCode
		, strCountry
		, strTimezone
		, intDefaultCurrencyId
		, intTermsId
		, intShipViaId 
		, ysnDefaultLocation
		, intFreightTermId
	)
	SELECT 
		  @intEntityId
		, @strLocationName 
		, CASE WHEN ISNULL(@strPrintedName, '') = '' THEN @strCustomerName ELSE @strPrintedName END
		, @strAddress
		, @strCity
		, @strState 
		, @strZip
		, @strCountry
		, @strTimezone
		, (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = @strCurrency)
		, (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = @strTerms)
		, (SELECT TOP 1 SMSV.intEntityId FROM tblSMShipVia SMSV JOIN tblEMEntity EME on SMSV.intEntityId = EME.intEntityId WHERE SMSV.strShipVia = @strShipVia)
		, 1
		, (SELECT TOP 1 intFreightTermId FROM tblSMFreightTerms WHERE strFreightTerm = @strFreightTerm)

	SET @intLocationId = @@IDENTITY

	INSERT INTO tblEMEntityToContact(
		  intEntityId
		, intEntityContactId 
		, intEntityLocationId 
		, ysnPortalAccess
		, ysnDefaultContact
	)
	SELECT 
		  @intEntityId 
		, @intContactId 
		, @intLocationId 
		, 0 
		, 1
			
	INSERT INTO tblEMEntityType(
		  intEntityId
		, strType 
		, intConcurrencyId
	)
	SELECT 
		  @intEntityId
		, 'Customer'
		, 1

	SET @strCustomerNumber = CASE WHEN ISNULL(@strCustomerNumber, '') = '' THEN @strEntityNumber ELSE @strCustomerNumber END

	INSERT INTO tblARCustomer (
		  intEntityId
		, strType
		, strAccountNumber
		, intCurrencyId
		, intPaymentMethodId
		, intTermsId
		, intSalespersonId
		, strFLOId
		, strTaxNumber
		, ysnTaxExempt
		, intTaxCodeId
		, strVatNumber
		, intEmployeeCount
		, dblRevenue
		, dblCreditLimit
		, intCreditStopDays
		, strCreditCode
		, ysnActive
		, ysnPORequired
		, ysnCreditHold
		, dtmBudgetBeginDate
		, dblMonthlyBudget
		, intNoOfPeriods
		, ysnCustomerBudgetTieBudget
		, ysnStatementDetail
		, ysnStatementCreditLimit
		, strStatementFormat
		, intServiceChargeId
		, dtmLastServiceCharge
		, ysnApplyPrepaidTax
		, ysnApplySalesTax
		, ysnCalcAutoFreight
		, strUpdateQuote
		, strDiscSchedule
		, strPrintInvoice
		, strLinkCustomerNumber
		, intReferredByCustomer
		, ysnSpecialPriceGroup
		, ysnExcludeDunningLetter
		, ysnReceivedSignedLiscense
		, ysnPrintPriceOnPrintTicket
		, ysnIncludeEntityName
		, intBillToId
		, intShipToId
		, dblARBalance
		, strCustomerNumber
		, guiApiUniqueId
	)
SELECT 
	  @intEntityId
	, (CASE WHEN ISNULL(@strType, '') NOT IN ('Company', 'Person') THEN 'Company' ELSE @strType END)
	, @strAccountNo
	, (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = @strCurrency)
	, (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = @strPaymentMethod)
	, (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = @strTerms)
	, (SELECT TOP 1 ARS.intEntityId FROM tblARSalesperson ARS 
			JOIN tblEMEntity EME ON ARS.intEntityId = EME.intEntityId 
	   WHERE ARS.strSalespersonId = @strSalesperson OR 
			 EME.strEntityNo = @strSalesperson)
	, @strFLO
	, @strTaxNumber
	, (CASE WHEN LOWER(ISNULL(@strExemptAllTax, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END)
	, (CASE WHEN @strTaxCounty <> '' THEN (SELECT TOP 1 intTaxCodeId FROM tblSMTaxCode WHERE strCounty = @strTaxCounty) ELSE @strTaxCounty END)
	, @strVatNumber
	, CASE WHEN ISNULL(@strEmployeeCount, '') <> '' AND ISNUMERIC(@strEmployeeCount) = 1 THEN @strEmployeeCount ELSE 0 END
	, CASE WHEN ISNULL(@strRevenue, '') <> '' AND ISNUMERIC(@strRevenue) = 1 THEN @strRevenue ELSE 0 END
	, CASE WHEN ISNULL(@strCreditLimit, '') <> '' AND ISNUMERIC(@strCreditLimit) = 1 THEN @strCreditLimit ELSE 0 END
	, CASE WHEN ISNULL(@strCreditStopDays, '') <> '' AND ISNUMERIC(@strCreditStopDays) = 1 THEN @strCreditStopDays ELSE 0 END
	, @strCreditCode
	, CASE WHEN LOWER(ISNULL(@strActive, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strPORequired, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strCreditHold, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CAST(@strBudgetBeginDate as DATETIME)
	, CASE WHEN ISNULL(@strBudgetMonthly, '') <> '' AND ISNUMERIC(@strBudgetMonthly) = 1 THEN @strBudgetMonthly ELSE 0 END
	, CASE WHEN ISNULL(@strBudgetNoPeriod, '') <> '' AND ISNUMERIC(@strBudgetNoPeriod) = 1 THEN @strBudgetNoPeriod ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strBudgetTieCustomerAging, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strStatementDetail, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strStatementCreditLimit, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, @strStatementFormat
	, (CASE WHEN @strServiceCharge <> '' THEN (SELECT TOP 1 intServiceChargeId FROM tblARServiceCharge WHERE strServiceChargeCode = @strServiceCharge) ELSE @strTaxCounty END)
	, @strLastServiceChargeDate
	, CASE WHEN LOWER(ISNULL(@strApplyPrepaidTax, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strApplySalesTax, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strCalculateAutoFreight, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, @strUpdateQuote
	, CASE WHEN ISNULL(@strDiscountSchedule, '') <> '' AND ISNUMERIC(@strDiscountSchedule) = 1 THEN @strDiscountSchedule ELSE 0 END
	, @strPrintInvoice
	, @strLinkCustomerNumber
	, @strReferencebyCustomer
	, CASE WHEN LOWER(ISNULL(@strSpecialPriceGroup, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strExcludeDunningLetter, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strReceivedSignedLicense, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strPrintPriceOnPickTicket, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, CASE WHEN LOWER(ISNULL(@strIncludeNameInAddress, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END
	, @intLocationId
	, @intLocationId
	, 0
	, @strCustomerNumber
	, @guiApiUniqueId

	IF @strPhone <> ''
	BEGIN			
		INSERT INTO tblEMEntityPhoneNumber(intEntityId, strPhone)
		select @intContactId, @strPhone
	END

	IF @strMobileNo <> ''
	BEGIN			
		INSERT INTO tblEMEntityMobileNumber(intEntityId, strPhone, intCountryId)
		SELECT @intContactId, @strMobileNo, null
	END

	IF(@strStatus <> '')
	BEGIN
		INSERT INTO tblARCustomerAccountStatus( intEntityCustomerId, intAccountStatusId)
		SELECT @intEntityId, (SELECT TOP 1 intAccountStatusId FROM tblARAccountStatus WHERE strAccountStatusCode = @strStatus)
	END
			
	IF @strCurrentSystem <> ''
	BEGIN
		INSERT INTO tblARCustomerCompetitor(intEntityCustomerId, intEntityId)
		SELECT @intEntityId, (SELECT TOP 1 EME.intEntityId FROM tblEMEntity EME join tblEMEntityType EMET ON EME.intEntityId = EMET.intEntityId and EMET.strType = 'Competitor' WHERE strName = @strCurrentSystem)
	END

	INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
	SELECT
		  guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Customer Number'
		, strValue = @strCustomerNumber
		, strLogLevel = 'Info'
		, strStatus = 'Success'
		, intRowNo = @intRowNumber
		, strMessage = 'The record was imported successfully.'
	FROM tblApiSchemaCustomer SC
	WHERE guiApiUniqueId = @guiApiUniqueId
	

	FETCH NEXT FROM cursorSC INTO 
          @strEntityNumber
		, @strCustomerName
		, @strOriginationDate
		, @strDocumentDelivery
		, @strExternalERP
		, @strFederalTax
		, @strStateTax
		, @strSuffix
		, @strEmail
		, @strLanguage
		, @strInternalNotes
		, @strLocationName
		, @strPrintedName
		, @strAddress
		, @strCity
		, @strState
		, @strZip
		, @strCountry 
		, @strTimezone
		, @strCurrency
		, @strTerms
		, @strShipVia
		, @strFreightTerm
		, @strType
		, @strStatus
		, @strPaymentMethod
		, @strAccountNo
		, @strSalesperson
		, @strFLO
		, @strTaxNumber
		, @strExemptAllTax
		, @strEmployeeCount
		, @strVatNumber
		, @strRevenue
		, @strCreditLimit
		, @strCreditStopDays
		, @strCreditCode
		, @strActive
		, @strPORequired
		, @strCreditHold
		, @strBudgetBeginDate
		, @strBudgetMonthly
		, @strBudgetNoPeriod
		, @strBudgetTieCustomerAging
		, @strStatementDetail
		, @strStatementCreditLimit
		, @strStatementFormat
		, @strServiceCharge
		, @strTaxCounty
		, @strLastServiceChargeDate
		, @strApplyPrepaidTax
		, @strApplySalesTax
		, @strCalculateAutoFreight
		, @strUpdateQuote
		, @strDiscountSchedule
		, @strPrintInvoice
		, @strLinkCustomerNumber
		, @strReferencebyCustomer
		, @strSpecialPriceGroup
		, @strExcludeDunningLetter
		, @strReceivedSignedLicense
		, @strPrintPriceOnPickTicket
		, @strIncludeNameInAddress
		, @strCustomerNumber
		, @strPhone
		, @strMobileNo
		, @strCurrentSystem
		, @intRowNumber
END

CLOSE cursorSC;
DEALLOCATE cursorSC;

-- FINALIZE
DECLARE @intTotalRowsImported INT

SET @intTotalRowsImported = (
    SELECT COUNT(*) 
    FROM tblARCustomer
    WHERE guiApiUniqueId = @guiApiUniqueId
)

UPDATE tblApiImportLog
SET 
      strStatus = 'Completed'
    , strResult = CASE WHEN @intTotalRowsImported = 0 THEN 'Failed' ELSE 'Success' END
    , intTotalRecordsCreated = @intTotalRowsImported
    , intTotalRowsImported = @intTotalRowsImported
    , dtmImportFinishDateUtc = GETUTCDATE()
WHERE guiApiImportLogId = @guiLogId