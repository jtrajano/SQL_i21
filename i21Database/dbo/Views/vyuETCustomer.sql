CREATE VIEW [dbo].[vyuETCustomer]
	AS 
	
	SELECT       
		Entity.intEntityId  
		,Entity.intConcurrencyId 
		,Entity.strName AS lname
		,'' AS fname
		,'' AS mname
		,CASE WHEN Cus.strCustomerNumber = '' THEN Entity.strEntityNo ELSE Cus.strCustomerNumber END AS cust_id
		,Loc.strAddress AS addr1
		,Loc.strCity AS city
		,Loc.strState AS state
		,'' AS county
		,Loc.strZipCode AS zip
		,Con.strPhone AS phone
		,CASE WHEN Cus.ysnTaxExempt = 1 THEN 'Y' ELSE 'N' END AS tax
		,strTerm as terms
		,'' AS lien
		,Cus.dblCreditLimit AS credit
		,'N' AS cshonl
		,Entity.strName AS alphasort
		,AcctStat.strAccountStatusCode AS chrStatusCode
		,Con.strPhone2 AS SecondPhoneNo
 	FROM tblEntity AS Entity  
		INNER JOIN tblARCustomer as Cus ON Entity.intEntityId = Cus.[intEntityCustomerId]  
		INNER JOIN tblEntityToContact as CusToCon ON Cus.intEntityCustomerId = CusToCon.intEntityId and CusToCon.ysnDefaultContact = 1  
		LEFT JOIN tblEntity as Con ON CusToCon.[intEntityContactId] = Con.[intEntityId]  
		LEFT JOIN tblEntityLocation as Loc ON Cus.intEntityCustomerId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1  
		LEFT JOIN tblEntityLocation as ShipToLoc ON Cus.intShipToId = ShipToLoc.intEntityLocationId  
		LEFT JOIN tblEntityLocation as BillToLoc ON Cus.intBillToId = BillToLoc.intEntityLocationId
		LEFT JOIN tblSMTerm as SMTerm ON SMTerm.intTermID = Loc.intTermsId
		LEFT JOIN tblARAccountStatus AS AcctStat ON AcctStat.intAccountStatusId = Cus.intAccountStatusId
