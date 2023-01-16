CREATE VIEW [dbo].[vyuMBILPickupHeader]                        
AS                            
SELECT                         
   detail.intLoadHeaderId                        
   ,intEntityId = case when load.strType = 'Outbound' and entity.intEntityId is null then NULL else entity.intEntityId end                        
   ,intEntityLocationId = case when load.strType = 'Outbound' and entity.intEntityId is null then detail.intCompanyLocationId else detail.intEntityLocationId end                        
   ,strName = case when load.strType = 'Outbound' and entity.intEntityId is null then company.strCompanyName else entity.strName end                        
   ,strLocation = case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strLocationName else location.strLocationName end                        
   ,strAddress = case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strAddress  else location.strAddress end                      
   ,strCity = case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strCity else location.strCity end                       
   ,strZipCode = case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strZipPostalCode else location.strZipCode end                       
   ,strEmail = case when load.strType = 'Outbound' and entity.intEntityId is null then company.strEmail else entity.strEmail end                       
   ,strPhone = case when load.strType = 'Outbound' and entity.intEntityId is null then company.strPhone else entity.strPhone end                
   ,load.strType                        
   ,load.strLoadNumber         
   --,isnull(detail.strPONumber,'') strPONumber    
   ,isnull(strTerminalRefNo,'')strTerminalRefNo                        
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
   ,ysnPickup             
   ,detail.intSellerId        
   ,dblQuantity = sum(detail.dblQuantity)        
   ,dblPickupQuantity = sum(detail.dblPickupQuantity)        
   ,dblGross = sum(detail.dblGross)        
   ,dblNet = sum(detail.dblNet)        
FROM tblMBILPickupDetail detail                              
INNER JOIN tblMBILLoadHeader load on detail.intLoadHeaderId = load.intLoadHeaderId                        
INNER JOIN tblICItem item on detail.intItemId = item.intItemId                        
LEFT join tblEMEntity entity on detail.intEntityId = entity.intEntityId                                
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = detail.intSellerId                              
LEFT JOIN tblEMEntity Salesperson ON Salesperson.intEntityId = detail.intSalespersonId                              
left join tblEMEntityLocation location on detail.intEntityLocationId = location.intEntityLocationId and detail.intEntityId = location.intEntityId                                
left join tblSMCompanyLocation companylocation on detail.intCompanyLocationId = companylocation.intCompanyLocationId                                
left join tblSMCompanySetup company on 1=1        
Group by detail.intLoadHeaderId                        
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then NULL else entity.intEntityId end                        
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then detail.intCompanyLocationId else detail.intEntityLocationId end                        
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then company.strCompanyName else entity.strName end                        
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strLocationName else location.strLocationName end                        
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strAddress  else location.strAddress end                      
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strCity else location.strCity end                       
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then companylocation.strZipPostalCode else location.strZipCode end                       
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then company.strEmail else entity.strEmail end                       
   ,case when load.strType = 'Outbound' and entity.intEntityId is null then company.strPhone else entity.strPhone end                
   ,load.strType            
   ,load.strLoadNumber       
   --,isnull(detail.strPONumber,'')      
   ,isnull(strTerminalRefNo,'')                     
   ,Seller.strName                        
   ,Salesperson.strName                        
   ,detail.strRack                        
   ,detail.strNote                        
   ,detail.dtmPickupFrom                        
   ,detail.dtmPickupTo                        
   ,detail.dtmActualPickupFrom                        
   ,detail.dtmActualPickupTo                        
   ,load.intDriverId                    
   ,case when detail.strType = 'Outbound' then companylocation.dblLongitude else location.dblLongitude end                
   ,case when detail.strType = 'Outbound' then companylocation.dblLatitude else location.dblLatitude end                 
   ,ysnPickup             
   ,detail.intSellerId