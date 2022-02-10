CREATE VIEW [dbo].[vyuMBILLoadSchedule]    
AS           
  SELECT a.intLoadId,                            
   intDriverEntityId,                      
         strLoadNumber,                      
         strType,                   
         intEntityId = a.intVendorEntityId,         
         intEntityLocationId = a.intVendorEntityLocationId,        
         intCompanyLocationId = case strType when 'Outbound' then a.intSCompanyLocationId else null end,        
   intCompanyDeliveryLocationId = case when strType = 'Inbound' then a.intPCompanyLocationId else null end,        
   intCustomerId = a.intCustomerEntityId,        
   intCustomerLocationId = a.intCustomerEntityLocationId,    
   d.intSellerId,  
   d.intSalespersonId,    
   strTerminalRefNo = a.strDetailTerminalReference,    
   a.intItemId,        
   a.dblQuantity,     
   a.dtmPickUpFrom,        
   a.dtmPickUpTo,    
   a.dtmDeliveryFrom,    
   a.dtmDeliveryTo,    
   strPONumber = case strType when 'Outbound' then isnull(a.strDetailCustomerReference,a.strCustomerReference) else  isnull(a.strExternalLoadNumber,a.strDetailVendorReference) end        
  From vyuLGLoadDetailView a                      
  inner join tblLGLoadDetail d on a.intLoadDetailId = d.intLoadDetailId  
  LEFT JOIN tblSMCompanyLocation b on a.intPCompanyLocationId = b.intCompanyLocationId                      
  LEFT JOIN tblEMEntityLocation c on a.intVendorEntityLocationId = c.intEntityLocationId                      
  WHERE isnull(ysnDispatched, 0) = 1        
        and ysnInProgress = 0                      
        and ISNULL(a.dblDeliveredQuantity, 0.000000) <= 0                      
        and strTransUsedBy = 'Transport Load'      
  and a.intLoadId not in(Select intLoadId from tblMBILPickupHeader)  
  