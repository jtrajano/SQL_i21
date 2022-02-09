CREATE VIEW [dbo].[vyuMBILDeliveryHeader]
AS
SELECT delivery.intDeliveryHeaderId,        
    delivery.intLoadId,        
    delivery.strLoadNumber,        
    delivery.intDriverEntityId,        
    delivery.strType,        
    delivery.intCompanyLocationId,        
    strCompanyName = case when strType = 'Inbound' then company.strCompanyName else null end,        
    strCompanyLocationName = companylocation.strLocationName,        
    strCompanyAddress = companylocation.strAddress,        
    strCompanyCity = companylocation.strCity,        
    strCompanyZipCode = companylocation.strZipPostalCode,        
    strCompanyPhone = companylocation.strPhone,        
    strCompanyEmail = companylocation.strEmail,        
    intCustomerId = delivery.intEntityId,        
    intCustomerNo = entity.strEntityNo,        
    strCustomerName = entity.strName,        
    strCustomerZipCode = location.strZipCode,        
    strCustomerAddress = location.strAddress,        
    strCustomerCity = location.strCity,        
    strCustomerCountry = location.strCountry,        
    strCustomerLocation = location.strLocationName,        
    strCustomerPhone = location.strPhone,        
    strCustomerEmail = entity.strEmail,
	delivery.dtmDeliveryFrom,
	delivery.dtmDeliveryTo,
	delivery.dtmActualDelivery
FROM tblMBILDeliveryHeader delivery        
LEFT JOIN tblEMEntity entity ON delivery.intEntityId = entity.intEntityId        
LEFT JOIN tblEMEntityLocation location ON delivery.intEntityLocationId = location.intEntityLocationId and delivery.intEntityId = location.intEntityId        
LEFT JOIN tblSMCompanyLocation companylocation ON delivery.intCompanyLocationId = companylocation.intCompanyLocationId        
LEFT JOIN tblSMCompanySetup company ON 1 = 1
