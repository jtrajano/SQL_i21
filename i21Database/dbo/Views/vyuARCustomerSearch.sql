CREATE VIEW [dbo].[vyuARCustomerSearch]
AS
SELECT intEntityId				= ENTITY.intEntityId
     , intEntityCustomerId		= ENTITY.intEntityId   	 
	 , intSalespersonId			= SALESPERSON.intEntityId
	 , intCurrencyId			= CUSTOMER.intCurrencyId
	 , intTermsId				= CUSTOMER.intTermsId
	 , intShipToId				= CUSTOMER.intShipToId
	 , intBillToId				= CUSTOMER.intBillToId
	 , strName					= ENTITY.strName
	 , strCustomerNumber		= CASE WHEN ISNULL(CUSTOMER.strCustomerNumber, '') = '' THEN ENTITY.strEntityNo ELSE CUSTOMER.strCustomerNumber END	 
	 , strVatNumber				= CUSTOMER.strVatNumber
	 , strFLOId					= CUSTOMER.strFLOId
	 , strStockStatus			= CUSTOMER.strStockStatus	 
	 , strStatementFormat		= CUSTOMER.strStatementFormat
	 , strAccountNumber			= CUSTOMER.strAccountNumber
	 , strSalespersonId			= SALESPERSON.strSalespersonId
	 , strSalesPersonName		= SALESPERSON.strSalesPersonName
	 , strTerm					= CUSTOMER.strTerm
	 , dtmMembershipDate		= CUSTOMER.dtmMembershipDate
	 , dtmBirthDate				= CUSTOMER.dtmBirthDate
	 , dtmLastActivityDate		= CUSTOMER.dtmLastActivityDate
	 , dblCreditLimit			= ISNULL(CUSTOMER.dblCreditLimit, 0)
	 , dblARBalance				= ISNULL(CUSTOMER.dblARBalance, 0)
	 , dblMonthlyBudget			= ISNULL(CUSTOMER.dblMonthlyBudget, 0)
	 , ysnIncludeEntityName		= CUSTOMER.ysnIncludeEntityName
	 , ysnPORequired			= CUSTOMER.ysnPORequired
	 , ysnStatementCreditLimit	= CUSTOMER.ysnStatementCreditLimit
	 , ysnTaxExempt				= CUSTOMER.ysnTaxExempt
	 , ysnActive				= CUSTOMER.ysnActive
	 , ysnHasBudgetSetup		= CUSTOMER.ysnHasBudgetSetup
	 , intEntityContactId		= CONTACT.intEntityContactId
	 , strPhone					= CONTACT.strPhone
	 , strPhone1				= CONTACT.strPhone1
	 , strPhone2				= CONTACT.strPhone2
	 , strContactName			= CONTACT.strName
	 , strInternalNotes			= CONTACT.strInternalNotes
	 , strEmail					= CONTACT.strEmail
	 , intShipViaId				= CUSTOMERLOCATION.intShipViaId
	 , intFreightTermId			= CUSTOMERLOCATION.intFreightTermId
	 , intTaxGroupId			= CUSTOMERLOCATION.intTaxGroupId 
	 , strAddress				= CUSTOMERLOCATION.strAddress
	 , strCity					= CUSTOMERLOCATION.strCity
	 , strState					= CUSTOMERLOCATION.strState
	 , strZipCode				= CUSTOMERLOCATION.strZipCode
	 , strCheckPayeeName		= CUSTOMERLOCATION.strCheckPayeeName
	 , strTaxGroup				= CUSTOMERLOCATION.strTaxGroup
	 , strShipViaName			= CUSTOMERLOCATION.strShipVia
	 , strFreightTerm			= CUSTOMERLOCATION.strFreightTerm
	 , strCounty				= CUSTOMERLOCATION.strCounty
	 , strCountry				= CUSTOMERLOCATION.strCountry
	 , strLocationName			= CUSTOMERLOCATION.strLocationName
     , strShipToLocationName	= SHIPTOLOCATION.strLocationName
     , strShipToAddress			= SHIPTOLOCATION.strAddress 
     , strShipToCity			= SHIPTOLOCATION.strCity
     , strShipToState			= SHIPTOLOCATION.strState
     , strShipToZipCode			= SHIPTOLOCATION.strZipCode
     , strShipToCountry			= SHIPTOLOCATION.strCountry
     , strBillToLocationName	= BILLTOLOCATION.strLocationName
     , strBillToAddress			= BILLTOLOCATION.strAddress
     , strBillToCity			= BILLTOLOCATION.strCity
     , strBillToState			= BILLTOLOCATION.strState
     , strBillToZipCode			= BILLTOLOCATION.strZipCode
     , strBillToCountry			= BILLTOLOCATION.strCountry
	 , strBillToPhone			= BILLTOLOCATION.strPhone
	 , intServiceChargeId		= CUSTOMER.intServiceChargeId
	 , intPaymentMethodId		= CUSTOMER.intPaymentMethodId
	 , strPaymentMethod			= CUSTOMER.strPaymentMethod
	 , ysnCreditHold
	 , intWarehouseId			= SHIPTOLOCATION.intWarehouseId
	 , strWarehouseName			= SHIPTOLOCATION.strWarehouseName
	 , intEntityLineOfBusinessIds = STUFF(LOB.intEntityLineOfBusinessIds,1,3,'') COLLATE Latin1_General_CI_AS
	 , intCreditStopDays		= CUSTOMER.intCreditStopDays
	 , strCreditCode			= CUSTOMER.strCreditCode
	 , dtmCreditLimitReached	= CUSTOMER.dtmCreditLimitReached
	 , intCreditLimitReached	= DATEDIFF(DAYOFYEAR, CUSTOMER.dtmCreditLimitReached, GETDATE())
	 , ysnHasCreditApprover		= CUSTOMER.ysnHasCreditApprover
FROM tblEMEntity ENTITY
INNER JOIN (
	SELECT C.intEntityId
		 , intSalespersonId
		 , intCurrencyId
		 , intTermsId
		 , intShipToId
		 , intBillToId
		 , strCustomerNumber
		 , strVatNumber
		 , strFLOId
		 , strStockStatus
		 , strStatementFormat
		 , strAccountNumber
		 , dtmMembershipDate
		 , dtmBirthDate
		 , dtmLastActivityDate
		 , dblCreditLimit
		 , dblARBalance
		 , dblMonthlyBudget
		 , ysnIncludeEntityName
		 , ysnStatementCreditLimit
		 , ysnPORequired
		 , C.ysnActive
		 , ysnTaxExempt
		 , strTerm				= TERM.strTerm
		 , ysnHasBudgetSetup	= CAST(CASE WHEN (BUDGET.ysnHasBudgetSetup) = 1 THEN 1 ELSE 0 END AS BIT)
		 , intServiceChargeId	= C.intServiceChargeId
		 , intPaymentMethodId	= C.intPaymentMethodId
		 , strPaymentMethod		= PAYMENTMETHOD.strPaymentMethod
		 , ysnCreditHold
		 , intCreditStopDays
		 , strCreditCode
		 , dtmCreditLimitReached
		 , ysnHasCreditApprover		= CAST(CASE WHEN CREDITAPPROVER.intApproverCount > 0 THEN 1 ELSE 0 END AS BIT)
	FROM dbo.tblARCustomer C WITH (NOLOCK)	
	LEFT JOIN (
		SELECT intTermID
			 , strTerm
		FROM dbo.tblSMTerm WITH (NOLOCK)
	) TERM ON C.intTermsId = TERM.intTermID
	LEFT JOIN (
		SELECT intPaymentMethodId = intPaymentMethodID
			 , strPaymentMethod
		FROM dbo.tblSMPaymentMethod WITH (NOLOCK)
	) PAYMENTMETHOD ON C.intPaymentMethodId = PAYMENTMETHOD.intPaymentMethodId
	OUTER APPLY (
		SELECT TOP 1 1 AS ysnHasBudgetSetup
		FROM dbo.tblARCustomerBudget WITH (NOLOCK)
		WHERE intEntityCustomerId = C.intEntityId
	) BUDGET
	OUTER APPLY(
		SELECT COUNT(ARC.intEntityId) AS intApproverCount
		FROM dbo.tblARCustomer ARC
		INNER JOIN dbo.tblEMEntityRequireApprovalFor ERA
			ON ARC.intEntityId = ERA.[intEntityId]
		INNER JOIN tblSMScreen SC
			ON ERA.intScreenId = SC.intScreenId
			AND SC.strScreenName = 'Invoice'
		WHERE ARC.intEntityId = C.intEntityId
	) CREDITAPPROVER
) CUSTOMER ON ENTITY.intEntityId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT intEntityId			= ETC.intEntityId
		 , strPhone				= ETCE.strPhone
		 , strPhone1			= EPN.strPhone
		 , strPhone2			= ETCE.strPhone2
		 , strName				= ETCE.strName
		 , strEmail				= ETCE.strEmail
		 , intEntityContactId	= ETC.intEntityContactId
		 , strInternalNotes		= ETCE.strInternalNotes
	FROM dbo.tblEMEntityToContact ETC WITH (NOLOCK) 
	INNER JOIN (
		SELECT intEntityId
			 , strName
			 , strPhone
			 , strPhone2
			 , strEmail
			 , strInternalNotes
		FROM dbo.tblEMEntity WITH(NOLOCK)
	) ETCE ON ETC.intEntityContactId = ETCE.intEntityId	
	LEFT JOIN tblEMEntityPhoneNumber EPN ON ETC.intEntityContactId = EPN.intEntityId	
	WHERE ETC.ysnDefaultContact = 1
) CONTACT ON CUSTOMER.intEntityId = CONTACT.intEntityId
LEFT JOIN (
	SELECT L.intEntityId
		 , L.intShipViaId
		 , L.intFreightTermId
		 , L.intTaxGroupId 
		 , L.intCountyTaxCodeId
		 , L.intSalespersonId
		 , L.strAddress
		 , L.strCity
		 , L.strState
		 , L.strZipCode
		 , L.strCheckPayeeName
		 , strTaxGroup		= TAXGROUP.strTaxGroup
		 , strShipVia		= SHIPVIA.strName
		 , strFreightTerm	= FREIGHTTERM.strFreightTerm
		 , strCounty		= TAXCODE.strCounty
		 , intWarehouseId	= ISNULL(L.intWarehouseId, -99)
		 , strWarehouseName	= WH.strWarehouseName
		 , strLocationName
		 , strCountry
	FROM dbo.tblEMEntityLocation L WITH (NOLOCK)
	LEFT JOIN (
		SELECT intTaxGroupId
			 , strTaxGroup
		FROM dbo.tblSMTaxGroup WITH (NOLOCK)
	) TAXGROUP ON L.intTaxGroupId = TAXGROUP.intTaxGroupId
	LEFT JOIN (
		SELECT intEntityId
			 , strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) SHIPVIA ON L.intShipViaId = SHIPVIA.intEntityId
	LEFT JOIN (
		SELECT intFreightTermId
			 , strFreightTerm
		FROM dbo.tblSMFreightTerms WITH (NOLOCK)
	) FREIGHTTERM ON L.intFreightTermId = FREIGHTTERM.intFreightTermId
	LEFT JOIN (
		SELECT intTaxCodeId
			 , strCounty
		FROM dbo.tblSMTaxCode
	) TAXCODE ON L.intCountyTaxCodeId = TAXCODE.intTaxCodeId
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strWarehouseName	= strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	) WH ON L.intWarehouseId = WH.intCompanyLocationId
	WHERE L.ysnDefaultLocation = 1
) CUSTOMERLOCATION ON CUSTOMER.intEntityId = CUSTOMERLOCATION.intEntityId
LEFT JOIN (
	SELECT intEntityLocationId
		 , intSalespersonId
		 , strLocationName
		 , strAddress
		 , strCity
		 , strState
		 , strZipCode
		 , strCountry
		 , intWarehouseId
		 , strWarehouseName
	FROM dbo.tblEMEntityLocation EL WITH (NOLOCK)
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strWarehouseName	= strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	) WH ON EL.intWarehouseId = WH.intCompanyLocationId
) SHIPTOLOCATION ON CUSTOMER.intShipToId = SHIPTOLOCATION.intEntityLocationId
LEFT JOIN (
	SELECT intEntityLocationId
		 , strLocationName
		 , strAddress
		 , strCity
		 , strState
		 , strZipCode
		 , strCountry
		 , strPhone
	FROM dbo.tblEMEntityLocation WITH (NOLOCK)
) BILLTOLOCATION ON CUSTOMER.intBillToId = BILLTOLOCATION.intEntityLocationId
LEFT JOIN (
	SELECT S.intEntityId
		 , strSalespersonId	    = CASE WHEN ISNULL(S.strSalespersonId, '') = '' THEN ST.strEntityNo ELSE S.strSalespersonId END
		 , strSalesPersonName	= ST.strName
	FROM dbo.tblARSalesperson S WITH (NOLOCK)
	INNER JOIN (
		SELECT intEntityId
			 , strName
			 , strEntityNo
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) ST on S.intEntityId = ST.intEntityId
) SALESPERSON ON SALESPERSON.intEntityId = ISNULL(SHIPTOLOCATION.intSalespersonId, CUSTOMER.intSalespersonId)
CROSS APPLY (SELECT(SELECT '|^|' + CONVERT(VARCHAR,intLineOfBusinessId) FROM tblEMEntityLineOfBusiness WHERE intEntityId = CUSTOMER.intEntityId FOR XML PATH('')) as intEntityLineOfBusinessIds) as LOB