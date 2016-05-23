﻿CREATE VIEW [dbo].[vyuETCustomer]
	AS 
	
	SELECT       
		Entity.intEntityId  
		,Entity.intConcurrencyId 
		,Entity.strName AS lname
		,'' AS fname
		,'' AS mname
		,EMPhone.strPhone as phone
		,dbo.fnEMSplitWithGetByIdx(Loc.strAddress, CHAR(10), 1) as addr1
		,dbo.fnEMSplitWithGetByIdx(Loc.strAddress, CHAR(10), 2) as addr2 
		,dbo.fnEMSplitWithGetByIdx(Loc.strAddress, CHAR(10), 3) as addr3
		,Loc.strZipCode zip
		,Loc.strState [state]
		,Loc.strCity [city]
		,Cus.strType [type]
		,SMTerm.strTermCode as terms
		,AcctStat.strAccountStatusCode AS chrStatusCode
		,TaxCode.strCounty as county
		,Cus.dblCreditLimit AS credit
		,CASE WHEN Cus.ysnTaxExempt = 1 THEN 'Y' ELSE 'N' END AS tax

		,CASE WHEN Cus.strCustomerNumber = '' THEN Entity.strEntityNo ELSE Cus.strCustomerNumber END AS cust_id
		,'' AS lien
		,'N' AS cshonl
		,Entity.strName AS alphasort		
		,Con.strPhone2 AS SecondPhoneNo
		,Con.ysnActive AS active

 	FROM tblEMEntity AS Entity  
		INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityCustomerId]  
		INNER JOIN [tblEMEntityToContact] as CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1  
		LEFT JOIN tblEMEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]  
		LEFT JOIN [tblEMEntityLocation] as Loc ON Cus.intEntityCustomerId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1  
		LEFT JOIN [tblEMEntityLocation] as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId  
		LEFT JOIN [tblEMEntityLocation] as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
		LEFT JOIN tblSMTerm as SMTerm ON SMTerm.intTermID = Loc.intTermsId
		LEFT JOIN tblARAccountStatus AS AcctStat ON AcctStat.intAccountStatusId = Cus.intAccountStatusId
		LEFT JOIN tblEMEntityPhoneNumber AS EMPhone ON Entity.intEntityId = EMPhone.intEntityId
		LEFT JOIN tblSMTaxCode TaxCode on Cus.intTaxCodeId = TaxCode.intTaxCodeId 
