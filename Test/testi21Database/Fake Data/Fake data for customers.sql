CREATE PROCEDURE [testi21Database].[Fake data for customers]
AS
BEGIN	
	EXEC tSQLt.FakeTable 'dbo.tblSMTerm', @Identity = 1;
	EXEC tSQLt.FakeTable 'dbo.tblARCustomer';
	EXEC tSQLt.FakeTable 'dbo.tblEMEntityLocation', @Identity = 1;

	DECLARE @Customer_Paul_Unlimited AS NVARCHAR(50) = 'Paul Unlimited'
	DECLARE @Customer_Paul_Unlimited_Id AS INT = 1


	INSERT INTO dbo.tblSMTerm (
		strTerm
		,strType
		,dblDiscountEP
		,intBalanceDue
		,intDiscountDay
		,dblAPR
		,strTermCode
		,ysnAllowEFT
		,intDayofMonthDue
		,intDueNextMonth
		,dtmDiscountDate
		,dtmDueDate
		,ysnActive
		,intSort
		,intConcurrencyId
	)
	SELECT 
		strTerm				= 'Net 15 Days'
		,strType			= 'Standard'
		,dblDiscountEP		= 0.00
		,intBalanceDue		= 15
		,intDiscountDay		= 0
		,dblAPR				= 0.000000
		,strTermCode		= '15'
		,ysnAllowEFT		=  1
		,intDayofMonthDue	= 0
		,intDueNextMonth	= 0
		,dtmDiscountDate	= NULL 
		,dtmDueDate			= NULL
		,ysnActive			= 1
		,intSort			= 1
		,intConcurrencyId	= 1

	INSERT INTO dbo.tblEMEntityLocation (
		strLocationName
		,strAddress
		,strCity
		,strCountry
		,strState
		,strZipCode
		,strPhone
		,strFax
		,strPricingLevel
		,strNotes
		,intShipViaId
		--,intTaxCodeId
		,intTermsId
		,intWarehouseId
		,ysnDefaultLocation
		,intConcurrencyId	
	)
	SELECT 
		strLocationName			= 'Warehouse Unlimited'
		,strAddress				= 'P.O. Box 403585'
		,strCity				= 'Houston'
		,strCountry				= 'United States'
		,strState				= 'TX'
		,strZipCode				= '93706'
		,strPhone				= ''
		,strFax					= ''
		,strPricingLevel		= ''
		,strNotes				= ''
		,intShipViaId			= NULL 
		-- ,intTaxCodeId			= NULL 
		,intTermsId				= 1
		,intWarehouseId			= NULL 
		,ysnDefaultLocation		= 1
		,intConcurrencyId		= 1

	INSERT INTO dbo.tblARCustomer (
			intEntityCustomerId 
			,strCustomerNumber
			,strType
			,dblCreditLimit
			,dblARBalance
			,strAccountNumber
			,strTaxNumber
			,strCurrency
			,intCurrencyId
			,intAccountStatusId
			,intSalespersonId
			,strPricing
			,strLevel
			,dblPercent
			,strTimeZone
			,ysnActive
			,intDefaultContactId
			,intDefaultLocationId
			,intBillToId
			,intShipToId
			,strTaxState
			,ysnPORequired
			,ysnCreditHold
			,ysnStatementDetail
			,strStatementFormat
			,intCreditStopDays
			,strTaxAuthority1
			,strTaxAuthority2
			,ysnPrintPriceOnPrintTicket
			,intServiceChargeId
			,ysnApplySalesTax
			,ysnApplyPrepaidTax
			,dblBudgetAmountForBudgetBilling
			,strBudgetBillingBeginMonth
			,strBudgetBillingEndMonth
			,ysnCalcAutoFreight
			,strUpdateQuote
			,strCreditCode
			,strDiscSchedule
			,strPrintInvoice
			,ysnSpecialPriceGroup
			,ysnExcludeDunningLetter
			,strLinkCustomerNumber
			,intReferredByCustomer
			,ysnReceivedSignedLiscense
			,strDPAContract
			,dtmDPADate
			,strGBReceiptNumber
			,ysnCheckoffExempt
			,ysnVoluntaryCheckoff
			,strCheckoffState
			,ysnMarketAgreementSigned
			,intMarketZoneId
			,ysnHoldBatchGrainPayment
			,ysnFederalWithholding
			,strAEBNumber
			,strAgrimineId
			,strHarvestPartnerCustomerId
			,strComments
			,ysnTransmittedCustomer
			,dtmMembershipDate
			,dtmBirthDate
			,strStockStatus
			,strPatronClass
			,dtmDeceasedDate
			,ysnSubjectToFWT
			,ysnHDBillableSupport
			,intTaxCodeId
			,intContractGroupId
			,intBuybackGroupId
			,intPriceGroupId
			,ysnTaxExempt
			,intConcurrencyId	
	)
	SELECT	intEntityCustomerId					= @Customer_Paul_Unlimited_Id
			,strCustomerNumber					= @Customer_Paul_Unlimited
			,strType							= 'Company'
			,dblCreditLimit						= 0.00
			,dblARBalance						= 0.00
			,strAccountNumber					= ''
			,strTaxNumber						= ''
			,strCurrency						= ''
			,intCurrencyId						= NULL 
			,intAccountStatusId					= NULL
			,intSalespersonId					= NULL
			,strPricing							= 'None'
			,strLevel							= ''
			,dblPercent							= 0.000000
			,strTimeZone						= '(UTC-08:00) Pacific Time (US & Canada)'
			,ysnActive							= 1
			,intDefaultContactId				= 1
			,intDefaultLocationId				= 1
			,intBillToId						= 1
			,intShipToId						= 1
			,strTaxState						= 'CA'
			,ysnPORequired						= 0
			,ysnCreditHold						= 0	
			,ysnStatementDetail					= 0
			,strStatementFormat					= ''
			,intCreditStopDays					= 0 
			,strTaxAuthority1					= NULL 
			,strTaxAuthority2					= NULL 
			,ysnPrintPriceOnPrintTicket			= 0 
			,intServiceChargeId					= NULL
			,ysnApplySalesTax					= 0
			,ysnApplyPrepaidTax					= 0
			,dblBudgetAmountForBudgetBilling	= 0.000000
			,strBudgetBillingBeginMonth			= ''
			,strBudgetBillingEndMonth			= ''
			,ysnCalcAutoFreight					= 0
			,strUpdateQuote						= ''
			,strCreditCode						= ''
			,strDiscSchedule					= ''
			,strPrintInvoice					= ''
			,ysnSpecialPriceGroup				= 0
			,ysnExcludeDunningLetter			= 0 
			,strLinkCustomerNumber				= ''
			,intReferredByCustomer				= NULL 
			,ysnReceivedSignedLiscense			= 0
			,strDPAContract						= ''
			,dtmDPADate							= NULL 
			,strGBReceiptNumber					= ''
			,ysnCheckoffExempt					= 0
			,ysnVoluntaryCheckoff				= 0 
			,strCheckoffState					= ''
			,ysnMarketAgreementSigned			= 0
			,intMarketZoneId					= NULL 
			,ysnHoldBatchGrainPayment			= 0
			,ysnFederalWithholding				= 0 
			,strAEBNumber						= ''
			,strAgrimineId						= ''
			,strHarvestPartnerCustomerId		= ''
			,strComments						= ''
			,ysnTransmittedCustomer				= 0 
			,dtmMembershipDate					= NULL 
			,dtmBirthDate						= NULL 
			,strStockStatus						= ''
			,strPatronClass						= ''
			,dtmDeceasedDate					= NULL 
			,ysnSubjectToFWT					= 0 
			,ysnHDBillableSupport				= 0 
			,intTaxCodeId						= NULL
			,intContractGroupId					= NULL
			,intBuybackGroupId					= NULL
			,intPriceGroupId					= NULL
			,ysnTaxExempt						= 0 
			,intConcurrencyId					= 1

END