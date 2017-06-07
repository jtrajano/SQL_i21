CREATE VIEW [dbo].vyuTMDYMOCustomerLabelReport  
AS 
	
	SELECT 
		strCustomerNumber = Ent.strEntityNo
		,strCustomerName = Ent.strName
		,strCustomerCity = Loc.strCity
		,strCustomerState = Loc.strState
		,strZipCode = Loc.strZipCode
		,strCustomerCityState = (CASE WHEN Loc.strCity IS NOT NULL OR Loc.strCity = '' 
										THEN ', ' + RTRIM (Loc.strState) 
										ELSE RTRIM(Loc.strState) 
								END)
		,strCustomerStateZip = (CASE WHEN Loc.strState IS NOT NULL OR Loc.strState = '' 
									THEN ' ' + RTRIM (Loc.strZipCode)
									ELSE RTRIM (Loc.strZipCode) 
								END)
		,strAddress = Loc.strAddress
		,strLocation = Loc.strLocationName
		,ysnActive = Cus.ysnActive
	FROM tblEMEntity Ent
	INNER JOIN tblARCustomer Cus 
		ON Ent.intEntityId = Cus.[intEntityId]
	INNER JOIN tblEMEntityToContact CustToCon 
		ON Cus.[intEntityId] = CustToCon.intEntityId 
			and CustToCon.ysnDefaultContact = 1
	INNER JOIN tblEMEntity Con 
		ON CustToCon.intEntityContactId = Con.intEntityId
	INNER JOIN tblEMEntityLocation Loc 
		ON Ent.intEntityId = Loc.intEntityId 
			and Loc.ysnDefaultLocation = 1

GO