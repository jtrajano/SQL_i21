CREATE VIEW [dbo].[vyuMBILDeliveryDetail]        
AS        
SELECT detail.intDeliveryDetailId          
      ,detail.intDeliveryHeaderId          
      ,detail.intLoadDetailId      
      ,detail.intPickupDetailId  
      ,detail.intItemId          
      ,item.strDescription          
      ,item.strItemNo        
      ,detail.dblQuantity          
      ,detail.dblDeliveredQty          
      ,detail.strTank          
      ,detail.dblStickStartReading          
      ,detail.dblStickEndReading          
      ,detail.ysnDelivered  
      ,detail.intTMDispatchId  
      ,detail.intTMSiteId  
	  ,detail.intShiftId  
      ,detail.dblWaterInches  
      ,detail.intContractDetailId  
      ,detail.dblGross  
      ,detail.dblNet  
	  ,DOD.strReleasePONumber
FROM tblMBILDeliveryDetail detail              
INNER JOIN tblICItem item ON detail.intItemId = item.intItemId  
INNER JOIN tblMBILDeliveryHeader deliveryHeader on detail.intDeliveryHeaderId = deliveryHeader.intDeliveryHeaderId  
INNER JOIN tblMBILLoadHeader load on load.intLoadHeaderId = deliveryHeader.intLoadHeaderId  
LEFT JOIN tblLGDispatchOrderDetail DOD on DOD.intDispatchOrderDetailId = detail.intDispatchOrderDetailId
WHERE load.ysnDispatched = 1 AND NOT EXISTS(SELECT o.intDispatchId  
    FROM tblMBILOrder o   
    INNER JOIN vyuMBILInvoice i on o.intOrderId = i.intOrderId  
    WHERE o.intDispatchId = detail.intTMDispatchId)