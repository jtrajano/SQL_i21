CREATE VIEW [dbo].[vyuMBILLoadSchedule]               
AS                         
  SELECT  load.intLoadId      
         ,load.intLoadDetailId      
         ,load.intDriverEntityId      
         ,load.strLoadNumber      
         ,strType      
         ,intEntityId = load.intVendorEntityId      
         ,intEntityLocationId = load.intVendorEntityLocationId      
         ,loaddetail.intPCompanyLocationId      
         ,loaddetail.intSCompanyLocationId      
         ,loaddetail.intPSubLocationId      
         ,loaddetail.intSSubLocationId      
         ,intCustomerId = load.intCustomerEntityId      
         ,intCustomerLocationId = load.intCustomerEntityLocationId      
         ,loaddetail.intSellerId      
         ,loaddetail.intSalespersonId      
         ,strTerminalRefNo = load.strDetailTerminalReference      
         ,load.intItemId      
         ,load.dblQuantity      
         ,load.dtmPickUpFrom      
         ,load.dtmPickUpTo      
         ,load.dtmDeliveryFrom      
         ,load.dtmDeliveryTo      
         ,lgLoad.intTruckId      
         ,strTrailerNo = load.strTrailerNo1      
   ,strLoadRefNo = loaddetail.strVendorReference      
         ,strPONumber = loaddetail.strCustomerReference      
         ,intHaulerId = load.intHaulerEntityId      
         ,load.dtmScheduledDate      
         ,load.intPContractDetailId      
         ,load.intSContractDetailId      
         ,intOutboundTaxGroupId      
         ,intInboundTaxGroupId      
         ,load.intTMDispatchId      
         ,load.intTMSiteId      
   ,load.strItemUOM      
From vyuLGLoadDetailView load             
INNER JOIN tblLGLoadDetail loaddetail on load.intLoadDetailId = loaddetail.intLoadDetailId    
INNER JOIN tblLGLoad lgLoad on load.intLoadId = lgLoad.intLoadId    
LEFT JOIN tblSMCompanyLocation compLocation on load.intPCompanyLocationId = compLocation.intCompanyLocationId                                    
LEFT JOIN tblEMEntityLocation entityLocation on load.intVendorEntityLocationId = entityLocation.intEntityLocationId                                            
WHERE ISNULL(load.ysnDispatched, 0) = 1                      
and strTransUsedBy = 'Transport Load'