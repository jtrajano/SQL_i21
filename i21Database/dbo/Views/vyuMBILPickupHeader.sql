CREATE VIEW [dbo].[vyuMBILPickupHeader]        
AS            
SELECT Distinct        
   detail.intLoadHeaderId        
   ,intEntityId = case when load.strType = 'Outbound' then NULL else entity.intEntityId end        
   ,intEntityLocationId = case when load.strType = 'Outbound' then detail.intCompanyLocationId else detail.intEntityLocationId end        
   ,strName = case when load.strType = 'Outbound' then company.strCompanyName else entity.strName end        
   ,strLocation = case when load.strType = 'Outbound' then companylocation.strLocationName else location.strLocationName end        
   ,strAddress = case when load.strType = 'Outbound' then companylocation.strAddress  else location.strAddress end      
   ,strCiy = case when load.strType = 'Outbound' then companylocation.strCity else location.strCity end       
   ,strZipCode = case when load.strType = 'Outbound' then companylocation.strZipPostalCode else location.strZipCode end       
   ,strEmail = case when load.strType = 'Outbound' then company.strEmail else entity.strEmail end       
   ,strPhone = case when load.strType = 'Outbound' then company.strPhone else entity.strPhone end
   ,load.strType        
   ,load.strLoadNumber    
   ,detail.strPONumber      
   ,strTerminalRefNo        
   ,strSeller = Seller.strName        
   ,strSalesPerson = Salesperson.strName        
   ,detail.strRack        
   ,detail.strNote        
   ,detail.dtmPickupFrom        
   ,detail.dtmPickupTo        
   ,detail.dtmActualPickupFrom        
   ,detail.dtmActualPickupTo        
   ,load.intDriverId    
   ,dblLongitude = case when detail.strType = 'Outbound' then companylocation.dblLongitude else location.dblLongitude end
   ,dblLatitude =  case when detail.strType = 'Outbound' then companylocation.dblLatitude else location.dblLatitude end        
FROM tblMBILPickupDetail detail              
INNER JOIN tblMBILLoadHeader load on detail.intLoadHeaderId = load.intLoadHeaderId        
INNER JOIN tblICItem item on detail.intItemId = item.intItemId        
LEFT join tblEMEntity entity on detail.intEntityId = entity.intEntityId                
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = detail.intSellerId              
LEFT JOIN tblEMEntity Salesperson ON Salesperson.intEntityId = detail.intSalespersonId              
left join tblEMEntityLocation location on detail.intEntityLocationId = location.intEntityLocationId and detail.intEntityId = location.intEntityId                
left join tblSMCompanyLocation companylocation on detail.intCompanyLocationId = companylocation.intCompanyLocationId                
left join tblSMCompanySetup company on 1=1