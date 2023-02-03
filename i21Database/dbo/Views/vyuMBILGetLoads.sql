CREATE VIEW [dbo].[vyuMBILGetLoads]    
    
AS     
    
SELECT lh.intLoadHeaderId,     
 lh.strLoadNumber,   
 CASE WHEN dh.intEntityId IS NOT NULL THEN 'Drop Ship'
 ELSE lh.strType END as strType,
 lh.intDispatchOrderId,    
 lh.intLoadId,     
 lh.intDriverId,     
 lh.intHaulerId as intShipViaId,     
 lh.intTruckId,     
 lh.intTrailerId,     
 lh.strTrailerNo,     
 lh.dtmScheduledDate,    
 pd.intPickupDetailId,     
 pd.intEntityId as intVendorId,     
 pd.intEntityLocationId as intVendorLocationId,     
 sp.intSupplyPointId,     
 sp.strFreightSalesUnit,    
 el.intTaxGroupId as intOutboundTaxGroupId,     
 pd.intLoadDetailId,     
 isnull(pd.intSalespersonId,isnull(el.intSalespersonId,arc.intSalespersonId)) AS intSalespersonId,     
 isnull(pd.intSellerId,trc.intSellerId)intSellerId,     
 pd.intTaxGroupId,    
 pd.intContractDetailId as intReceiptContractDetailId,
 dd.intContractDetailId,     
 pd.intItemId,     
 pd.intCompanyLocationId as intReceiptCompanyLocationId,     
 el.strZipCode as strZipPostalCode,  
 pd.dblPickupQuantity,     
 pd.dblGross,     
 pd.dblNet,     
 pd.dtmPickupFrom,     
 pd.dtmPickupTo,     
 pd.dtmActualPickupFrom,     
 pd.dtmActualPickupTo,     
 pd.strBOL,     
 pd.strItemUOM,     
 pd.strLoadRefNo,     
 pd.strNote,     
 pd.strPONumber,     
 pd.strRack,     
 pd.strTerminalRefNo,     
 pd.ysnPickup,    
 dh.intDeliveryHeaderId,     
 dh.intEntityId as intCustomerId,     
 dh.intEntityLocationId as intCustomerLocationId,     
 dh.intCompanyLocationId as intDistributionCompanyLocationId,     
 isnull(dh.intSalesPersonId,isnull(el.intSalespersonId,arc.intSalespersonId)) AS intSalesPersonId,  
 dh.dtmActualDelivery,     
 dd.intDeliveryDetailId,     
 dd.intTMDispatchId,     
 dd.intTMSiteId,     
 dd.strTank,     
 dd.dblStickStartReading,     
 dd.dblStickEndReading,     
 dd.dblWaterInches,     
 dd.dblPrice,      
 dd.dblDeliveredQty,     
 dd.dblPercentFull,    
 dd.ysnDelivered,
 lh.ysnDiversion,
 lh.strDiversionNumber,
 lh.intStateId,
 pd.intDispatchOrderRouteId,
 dd.intDispatchOrderDetailId
FROM     
tblMBILPickupDetail pd     
JOIN tblMBILDeliveryDetail dd ON dd.intPickupDetailId = pd.intPickupDetailId     
LEFT JOIN tblTRSupplyPoint sp ON sp.intEntityVendorId = pd.intEntityId  AND     
       sp.intEntityLocationId = pd.intEntityLocationId     
LEFT JOIN tblEMEntityLocation el ON el.intEntityLocationId = pd.intEntityLocationId    
LEFT JOIN tblSMCompanyLocation RCL ON RCL.intCompanyLocationId = pd.intCompanyLocationId    
JOIN tblMBILDeliveryHeader dh ON dh.intDeliveryHeaderId = dd.intDeliveryHeaderId     
OUTER APPLY tblTRCompanyPreference trc  
JOIN tblMBILLoadHeader lh ON lh.intLoadHeaderId = dh.intLoadHeaderId
LEFT JOIN tblARCustomer arc ON arc.intEntityId = dh.intEntityId