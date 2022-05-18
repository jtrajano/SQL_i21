CREATE VIEW [dbo].[vyuARCustomer]
AS
SELECT Entity.intEntityId 
     , CustoPM.strPaymentMethod
     , Cus.intPaymentMethodId
	 , Entity.strName
	 , strCustomerNumber		= CASE WHEN Cus.strCustomerNumber = '' THEN	 Entity.strEntityNo ELSE Cus.strCustomerNumber END 
	 , Cus.strType
	 , EnPhoneNo.strPhone
	 , Loc.strAddress
	 , Loc.strCity
	 , Loc.strState
	 , Loc.strZipCode 
	 , Cus.ysnActive
	 , Cus.intSalespersonId
	 , Cus.intCurrencyId
	 , Cus.intTermsId
	 , Loc.intShipViaId
	 , strShipToLocationName	= ShipToLoc.strLocationName
	 , strShipToAddress			= ShipToLoc.strAddress
	 , strShipToCity			= ShipToLoc.strCity
	 , strShipToState			= ShipToLoc.strState
	 , strShipToZipCode			= ShipToLoc.strZipCode
	 , strShipToCountry			= ShipToLoc.strCountry
	 , strBillToLocationName	= BillToLoc.strLocationName
	 , strBillToAddress			= BillToLoc.strAddress
	 , strBillToCity			= BillToLoc.strCity
	 , strBillToState			= BillToLoc.strState
	 , strBillToZipCode			= BillToLoc.strZipCode
	 , strBillToCountry			= BillToLoc.strCountry
	 , intShipToId				= ShipToLoc.intEntityLocationId
	 , intBillToId				= BillToLoc.intEntityLocationId
	 , dblCreditLimit			= ISNULL(Cus.dblCreditLimit, 0)
	 , Cus.strVatNumber
	 , strPhone1				= EnPhoneNo.strPhone
	 , strPhone2				= Con.strPhone2
	 , Loc.strCountry
	 , Loc.strLocationName
	 , ysnHasBudgetSetup		= CAST(CASE WHEN (SELECT TOP 1 1 FROM tblARCustomerBudget WHERE intEntityCustomerId = Cus.[intEntityId]) = 1 THEN 1 ELSE 0 END AS BIT)
	 , intServiceChargeId
	 , strCustomerTerm			= TERM.strTerm
	 , Con.strInternalNotes
	 , Con.strEmail
	 , intEntityLineOfBusinessIds	= STUFF(LOB.intEntityLineOfBusinessIds,1,3,'') COLLATE Latin1_General_CI_AS
	 , dblHighestDueAR			= Cus.dblHighestDueAR
	 , dblHighestAR				= Cus.dblHighestAR
	 , dtmHighestARDate			= Cus.dtmHighestARDate
	 , dtmHighestDueARDate		= Cus.dtmHighestDueARDate
FROM tblEMEntity as Entity
INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityId]
INNER JOIN [tblEMEntityToContact] as CusToCon ON Cus.[intEntityId] = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1
LEFT JOIN tblEMEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]
LEFT JOIN tblEMEntityPhoneNumber as EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
LEFT JOIN [tblEMEntityLocation] as Loc ON Cus.[intEntityId] = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
LEFT JOIN [tblEMEntityLocation] as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId
LEFT JOIN [tblEMEntityLocation] as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
LEFT JOIN tblSMPaymentMethod AS CustoPM ON Cus.intPaymentMethodId = CustoPM.intPaymentMethodID
LEFT JOIN tblSMTerm as TERM ON TERM.intTermID = Cus.intTermsId
CROSS APPLY (SELECT(SELECT '|^|' + CONVERT(VARCHAR,intLineOfBusinessId) FROM tblEMEntityLineOfBusiness WHERE intEntityId = Cus.intEntityId FOR XML PATH('')) as intEntityLineOfBusinessIds) as LOB