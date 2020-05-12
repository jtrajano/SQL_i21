CREATE VIEW [dbo].[vyuETExportCustomer]
AS 
	
	SELECT       
		Entity.intEntityId  
		,Entity.intConcurrencyId 
		,Entity.strName AS lname
		,'' COLLATE Latin1_General_CI_AS AS fname
		,'' COLLATE Latin1_General_CI_AS AS mname
		,EMPhone.strPhone as phone
		,SUBSTRING(dbo.fnEMSplitWithGetByIdx(Loc.strAddress, CHAR(10), 1),1,50) COLLATE Latin1_General_CI_AS as addr1
		,SUBSTRING(dbo.fnEMSplitWithGetByIdx(Loc.strAddress, CHAR(10), 2),1,50) COLLATE Latin1_General_CI_AS as addr2 
		,SUBSTRING(dbo.fnEMSplitWithGetByIdx(Loc.strAddress, CHAR(10), 3),1,50) COLLATE Latin1_General_CI_AS as addr3
		,Loc.strZipCode zip
		,Loc.strState [state]
		,Loc.strCity [city]
		,Cus.strType [type]
		,SMTerm.strTermCode as terms
		,AcctStat.strAccountStatusCode AS chrStatusCode
		,TaxCode.strCounty as county
		,ISNULL(Cus.dblCreditLimit,0) AS credit
		--,CASE WHEN Cus.ysnTaxExempt = 1 THEN 'Y' ELSE 'N' END AS tax

		,CASE WHEN Cus.strCustomerNumber = '' THEN Entity.strEntityNo ELSE Cus.strCustomerNumber END AS cust_id
		,CASE WHEN Cus.strLevel LIKE '%1%' THEN '1' 
			 WHEN  Cus.strLevel LIKE '%2%' THEN '2' 
			 WHEN  Cus.strLevel LIKE '%3%' THEN '3' 
			 WHEN  Cus.strLevel LIKE '%4%' THEN '4' 
			 WHEN  Cus.strLevel LIKE '%5%' THEN '5' 
			 WHEN  Cus.strLevel LIKE '%6%' THEN '6' 
			 ELSE ''
		END COLLATE Latin1_General_CI_AS AS lien
		,'N' COLLATE Latin1_General_CI_AS AS cshonl
		,Entity.strName AS alphasort		
		,Con.strPhone2 AS SecondPhoneNo
		--,Con.ysnActive AS active
		
		--,credit = Cus.dblCreditLimit
		,active = Cus.ysnActive
		,tax = case when Cus.ysnApplyPrepaidTax = 1 then 'P' 
				when Cus.ysnApplySalesTax = 1 then 'Y'
				else 'N' END COLLATE Latin1_General_CI_AS
		,TaxGroupId = ISNULL(CAST(ShipToLoc.intTaxGroupId AS NVARCHAR(20)),'')
 	FROM tblEMEntity AS Entity  
		INNER JOIN tblEMEntityType as EntType
			ON Entity.intEntityId = EntType.intEntityId and EntType.strType = 'Customer'
		INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityId]  and Cus.ysnActive = 1
		INNER JOIN [tblEMEntityToContact] as CusToCon ON Cus.[intEntityId] = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1  
		LEFT JOIN tblEMEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]  
		LEFT JOIN [tblEMEntityLocation] as Loc ON Cus.[intEntityId] = Loc.intEntityId AND Loc.ysnDefaultLocation = 1  
		LEFT JOIN [tblEMEntityLocation] as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId  
		LEFT JOIN [tblEMEntityLocation] as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
		LEFT JOIN tblSMTerm as SMTerm ON  Cus.intTermsId = SMTerm.intTermID 
		LEFT JOIN tblARAccountStatus AS AcctStat ON AcctStat.intAccountStatusId = Cus.intAccountStatusId
		LEFT JOIN tblEMEntityPhoneNumber AS EMPhone ON CusToCon.intEntityContactId = EMPhone.intEntityId
		LEFT JOIN tblSMTaxCode TaxCode on Cus.intTaxCodeId = TaxCode.intTaxCodeId	