CREATE VIEW [dbo].[vyuMBILPickupHeader]
AS    
Select pickup.intPickupHeaderId,    
    pickup.intLoadId,    
    pickup.strLoadNumber,    
    pickup.intDriverEntityId,    
    pickup.strType,    
    pickup.intCompanyLocationId,    
    strCompanyName,    
    strCompanyLocationName = companylocation.strLocationName,    
    strCompanyAddress = companylocation.strAddress,    
    strCompanyCity = companylocation.strCity,    
    strCompanyZipCode = companylocation.strZipPostalCode,    
    strCompanyPhone = companylocation.strPhone,    
    strCompanyEmail = companylocation.strEmail,    
    pickup.intEntityId,    
    strVendorNo = entity.strEntityNo,    
    strVendorName = entity.strName,    
    strVendorZipCode = location.strZipCode,    
    strVendorAddress = location.strAddress,    
    strVendorCity = location.strCity,    
    strVendorCountry = location.strCountry,    
    strVendorLocationName = location.strLocationName,    
    strVendorPhone = entity.strPhone,    
    strVendorEmail = entity.strEmail,    
	pickup.dtmPickupFrom,
	pickup.dtmPickupTo,
	strSeller = Seller.strName,
	strSalesPerson = Salesperson.strName,
	pickup.strTerminalRefNo,
	pickup.strPONumber  ,
	pickup.strNote,
	pickup.strBOL,
	ysnPickup
From tblMBILPickupHeader pickup    
left join tblEMEntity entity on pickup.intEntityId = entity.intEntityId    
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = pickup.intSellerId  
LEFT JOIN tblEMEntity Salesperson ON Salesperson.intEntityId = pickup.intSalespersonId  
left join tblEMEntityLocation location on pickup.intEntityLocationId = location.intEntityLocationId and pickup.intEntityId = location.intEntityId    
left join tblSMCompanyLocation companylocation on pickup.intCompanyLocationId = companylocation.intCompanyLocationId    
left join tblSMCompanySetup company on 1=1