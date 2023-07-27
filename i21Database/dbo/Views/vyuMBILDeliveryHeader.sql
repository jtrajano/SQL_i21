CREATE VIEW [dbo].[vyuMBILDeliveryHeader]        
AS        
SELECT delivery.intDeliveryHeaderId,           
    delivery.intLoadHeaderId,               
    delivery.strDeliveryNumber,     
    intDriverEntityId = load.intDriverId,                
    load.strType,                
    load.strLoadNumber,        
     intLocationId = isnull(delivery.intEntityLocationId,delivery.intCompanyLocationId),                
    strCompanyName = company.strCompanyName,                
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
    strCustomerPhone = entityPhone.strPhone,                
    strCustomerEmail = entity.strEmail,        
	 delivery.dtmDeliveryFrom,        
	 delivery.dtmDeliveryTo,        
	 delivery.dtmActualDelivery    
	,dblLongitude = case when delivery.intEntityLocationId is null then companylocation.dblLongitude else location.dblLongitude end    
	 ,dblLatitude = case when delivery.intEntityLocationId is null then companylocation.dblLatitude else location.dblLatitude end    
FROM tblMBILDeliveryHeader delivery                
INNER JOIN tblMBILLoadHeader load on delivery.intLoadHeaderId = load.intLoadHeaderId        
LEFT JOIN tblEMEntity entity ON delivery.intEntityId = entity.intEntityId                
LEFT JOIN tblEMEntityLocation location ON delivery.intEntityLocationId = location.intEntityLocationId and delivery.intEntityId = location.intEntityId    
LEFT JOIN tblEMEntityToContact entityToContact ON entity.intEntityId = entityToContact.intEntityId AND entityToContact.ysnDefaultContact = 1   
LEFT JOIN tblEMEntityPhoneNumber entityPhone ON entityToContact.intEntityContactId = entityPhone.intEntityId    
LEFT JOIN tblSMCompanyLocation companylocation ON delivery.intCompanyLocationId = companylocation.intCompanyLocationId                
LEFT JOIN tblSMCompanySetup company ON 1 = 1     
WHERE load.ysnDispatched = 1 and intDeliveryHeaderId in(Select intDeliveryHeaderId from tblMBILDeliveryDetail where ysnDelivered = 0 AND 
NOT EXISTS(SELECT o.intDispatchId
			FROM tblMBILOrder o 
			INNER JOIN vyuMBILInvoice i on o.intOrderId = i.intOrderId
			WHERE o.intDispatchId = tblMBILDeliveryDetail.intTMDispatchId))