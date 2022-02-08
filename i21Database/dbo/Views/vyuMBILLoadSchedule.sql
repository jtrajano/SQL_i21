CREATE  VIEW [dbo].[vyuMBILLoadSchedule]
AS       
  SELECT intLoadId,                        
		 intDriverEntityId,                  
         strLoadNumber,                  
         strType,               
         intEntityId = intVendorEntityId,     
         intEntityLocationId = intVendorEntityLocationId,    
         intCompanyLocationId = case strType when 'Outbound' then intSCompanyLocationId else null end,    
		 intCompanyDeliveryLocationId = case when strType = 'Inbound' then intPCompanyLocationId else null end,    
		 intCustomerId = intCustomerEntityId,    
		 intCustomerLocationId = intCustomerEntityLocationId,    
		 intItemId,    
		 dblQuantity,    
		 dtmSchedulePullDate = (Select dtmETAPOL from tblLGLoad eta Where a.intLoadId = eta.intLoadId),    
		 dtmDeliveryDate = (Select dtmETAPOD from tblLGLoad eta Where a.intLoadId = eta.intLoadId),    
		 startime = null,    
		 endtime = null,    
		 strPONumber = case strType when 'Outbound' then isnull(a.strDetailCustomerReference,a.strCustomerReference) else  isnull(a.strExternalLoadNumber,a.strDetailVendorReference) end    
  From vyuLGLoadDetailView a                  
  LEFT JOIN tblSMCompanyLocation b on a.intPCompanyLocationId = b.intCompanyLocationId                  
  LEFT JOIN tblEMEntityLocation c on a.intVendorEntityLocationId = c.intEntityLocationId                  
  WHERE isnull(ysnDispatched, 0) = 1    
        and ysnInProgress = 0                  
        and ISNULL(dblDeliveredQuantity, 0.000000) <= 0                  
        and strTransUsedBy = 'Transport Load'  
  and intLoadId not in(Select intLoadId from tblMBILPickupHeader) 