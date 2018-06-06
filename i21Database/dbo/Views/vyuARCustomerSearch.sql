CREATE VIEW [dbo].[vyuARCustomerSearch]
AS
SELECT intEntityId				= ENTITY.intEntityId
     , intEntityCustomerId		= ENTITY.intEntityId   	 
	 , intSalespersonId			= CUSTOMER.intSalespersonId
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
	 , strSalespersonId			= CUSTOMER.strSalespersonId
	 , strSalesPersonName		= CUSTOMER.strSalesPersonName
	 , strTerm					= CUSTOMER.strTerm
	 , dtmMembershipDate		= CUSTOMER.dtmMembershipDate
	 , dtmBirthDate				= CUSTOMER.dtmBirthDate
	 , dtmLastActivityDate		= CUSTOMER.dtmLastActivityDate
	 , dblCreditLimit			= CUSTOMER.dblCreditLimit
	 , dblARBalance				= CUSTOMER.dblARBalance
	 , ysnIncludeEntityName		= CUSTOMER.ysnIncludeEntityName
	 , ysnPORequired			= CUSTOMER.ysnPORequired
	 , ysnStatementCreditLimit	= CUSTOMER.ysnStatementCreditLimit
	 , ysnTaxExempt				= CUSTOMER.ysnTaxExempt
	 , ysnActive				= CUSTOMER.ysnActive
	 , ysnHasBudgetSetup		= CUSTOMER.ysnHasBudgetSetup
	 , intEntityContactId		= CONTACT.intEntityContactId
	 , strPhone					= CONTACT.strPhone
	 , strContactName			= CONTACT.strName
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
	 , intEntityLineOfBusinessIds = STUFF(LOB.intEntityLineOfBusinessIds,1,3,'')
	 , intCreditStopDays		= CUSTOMER.intCreditStopDays
	 , strCreditCode			= CUSTOMER.strCreditCode
	 , dtmCreditLimitReached	= CUSTOMER.dtmCreditLimitReached
	 , intCreditLimitReached	= DATEDIFF(DAYOFYEAR, GETDATE(), CUSTOMER.dtmCreditLimitReached)
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
		 , ysnIncludeEntityName
		 , ysnStatementCreditLimit
		 , ysnPORequired
		 , C.ysnActive
		 , ysnTaxExempt
		 , strSalespersonId		= SALESPERSON.strSalespersonId
		 , strSalesPersonName	= SALESPERSON.strSalesPersonName
		 , strTerm				= TERM.strTerm
		 , ysnHasBudgetSetup	= CAST(CASE WHEN (BUDGET.ysnHasBudgetSetup) = 1 THEN 1 ELSE 0 END AS BIT)
		 , intServiceChargeId	= C.intServiceChargeId
		 , intPaymentMethodId	= C.intPaymentMethodId
		 , strPaymentMethod		= PAYMENTMETHOD.strPaymentMethod
		 , ysnCreditHold
		 , intCreditStopDays
		 , strCreditCode
		 , dtmCreditLimitReached		 
	FROM dbo.tblARCustomer C WITH (NOLOCK)
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
	) SALESPERSON ON C.intSalespersonId = SALESPERSON.intEntityId
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
) CUSTOMER ON ENTITY.intEntityId = CUSTOMER.intEntityId
LEFT JOIN (
	SELECT ETC.intEntityId
		 , ETCE.strPhone
		 , ETCE.strName
		 , ETC.intEntityContactId
	FROM dbo.tblEMEntityToContact ETC WITH (NOLOCK) 
	INNER JOIN (
		SELECT intEntityId
			 , strName
			 , strPhone
		FROM dbo.tblEMEntity WITH(NOLOCK)
	) ETCE ON ETC.intEntityContactId = ETCE.intEntityId	
	WHERE ETC.ysnDefaultContact = 1
) CONTACT ON CUSTOMER.intEntityId = CONTACT.intEntityId
LEFT JOIN (
	SELECT L.intEntityId
		 , L.intShipViaId
		 , L.intFreightTermId
		 , L.intTaxGroupId 
		 , L.intCountyTaxCodeId
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
	WHERE ysnDefaultLocation = 1
) CUSTOMERLOCATION ON CUSTOMER.intEntityId = CUSTOMERLOCATION.intEntityId
LEFT JOIN (
	SELECT intEntityLocationId
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
CROSS APPLY (SELECT(SELECT '|^|' + CONVERT(VARCHAR,intLineOfBusinessId) FROM tblEMEntityLineOfBusiness WHERE intEntityId = CUSTOMER.intEntityId FOR XML PATH('')) as intEntityLineOfBusinessIds) as LOB