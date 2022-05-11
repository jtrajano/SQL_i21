CREATE VIEW [dbo].[vyuMBILLoadSchedule]         
AS                   
  SELECT load.intLoadId,     
    load.intLoadDetailId,                                   
   load.intDriverEntityId,                              
         load.strLoadNumber,                              
         strType,                           
         intEntityId = load.intVendorEntityId,                 
         intEntityLocationId = load.intVendorEntityLocationId,                
   loaddetail.intPCompanyLocationId,      
   loaddetail.intSCompanyLocationId,      
         loaddetail.intPSubLocationId,      
   loaddetail.intSSubLocationId,                
   intCustomerId = load.intCustomerEntityId,                
     intCustomerLocationId = load.intCustomerEntityLocationId,            
     loaddetail.intSellerId,          
     loaddetail.intSalespersonId,            
     strTerminalRefNo = load.strDetailTerminalReference,            
     load.intItemId,                
     load.dblQuantity,             
     load.dtmPickUpFrom,                
     load.dtmPickUpTo,            
     load.dtmDeliveryFrom,            
     load.dtmDeliveryTo,        
     intTruckId = scTruck.intTruckDriverReferenceId,           
     strTrailerNo = load.strTrailerNo1,         
     strPONumber = case strType when 'Outbound' then isnull(load.strDetailCustomerReference,load.strCustomerReference) else  isnull(load.strExternalLoadNumber,load.strDetailVendorReference) end,      
     intHaulerId = load.intHaulerEntityId,      
     load.dtmScheduledDate,      
     load.intPContractDetailId,      
     load.intSContractDetailId,      
     intOutboundTaxGroupId,      
     intInboundTaxGroupId      
  From vyuLGLoadDetailView load       
  INNER JOIN tblLGLoadDetail loaddetail on load.intLoadDetailId = loaddetail.intLoadDetailId          
  LEFT JOIN tblSMCompanyLocation compLocation on load.intPCompanyLocationId = compLocation.intCompanyLocationId                              
  LEFT JOIN tblEMEntityLocation entityLocation on load.intVendorEntityLocationId = entityLocation.intEntityLocationId                              
  LEFT JOIN tblSCTruckDriverReference scTruck on scTruck.strData = load.strTruckNo        
  WHERE isnull(load.ysnDispatched, 0) = 1                
        and load.ysnInProgress = 0                              
        and ISNULL(load.dblDeliveredQuantity, 0.000000) <= 0                              
        and strTransUsedBy = 'Transport Load'              
  --and load.intLoadId not in(Select intLoadId from tblMBILLoadHeader)   