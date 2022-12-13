CREATE PROCEDURE [dbo].[uspMBILLoadSchedule] 
    @intDriverId AS INT,                                            
 @forDeleteId NVARCHAR(MAX) = ''                                            
AS                                                            
SET QUOTED_IDENTIFIER OFF                                                            
SET ANSI_NULLS ON                                                            
SET NOCOUNT ON                                                            
SET XACT_ABORT ON                                                            
SET ANSI_WARNINGS OFF                                                            
BEGIN                                                            
                                        
  if @forDeleteId = ''                                       
  begin                                      
  set @forDeleteId = '0'                                      
  end                                      
                                                        
 CREATE TABLE #loadOrder                                                               
 (                                                              
 intLoadId int,                                                      
 intLoadDetailId int,                                                        
 intDriverEntityId int,                                                              
 strLoadNumber nvarchar(100) COLLATE Latin1_General_CI_AS NULL,                                                              
 strType varchar(100) COLLATE Latin1_General_CI_AS NULL,                                                              
 intEntityId int NULL,                                                              
 intEntityLocationId int NULL,                                                              
 intPCompanyLocationId INT NULL,                                                  
 intSCompanyLocationId INT NULL,                                                  
 intPSubLocationId INT NULL,                                                  
 intSSubLocationId INT NULL,                                                  
 intCustomerId int NULL,                                                              
 intCustomerLocationId int NULL,                                                              
 intSellerId int NULL,                                                              
 intSalespersonId int NULL,                                                              
 strTerminalRefNo nvarchar(200) COLLATE Latin1_General_CI_AS NULL,                                                              
 intItemId int NULL,                                                              
 dblQuantity numeric(18,6) NULL,                            
 dtmPickUpFrom datetime NULL,                                                              
 dtmPickUpTo datetime NULL,                                                              
 dtmDeliveryFrom datetime NULL,                                                              
 dtmDeliveryTo datetime NULL,                                         
 intTruckId nvarchar(200) COLLATE Latin1_General_CI_AS NULL,                                        
 strTrailerNo nvarchar(200) COLLATE Latin1_General_CI_AS NULL,                      
 strLoadRefNo nvarchar(200) COLLATE Latin1_General_CI_AS NULL,                         
 strPONumber nvarchar(200) COLLATE Latin1_General_CI_AS NULL,                                     
 intHaulerId int,                                                   
 dtmScheduledDate datetime,                                                  
 intPContractDetailId INT NULL,                                                  
 intSContractDetailId INT NULL,                                                  
 intOutboundTaxGroupId INT NULL,                                                  
 intInboundTaxGroupId INT NULL ,                          
 intTMDispatchId INT NULL,                          
 intTMSiteId INT NULL,                    
 strItemUOM nvarchar(100) COLLATE Latin1_General_CI_AS NULL,                         
 )                                                           
                             
 INSERT INTO #loadOrder                                                              
 SELECT *                 
 FROM vyuMBILLoadSchedule                                                              
 WHERE intDriverEntityId = @intDriverId --AND intLoadId NOT IN (SELECT intLoadId FROM tblMBILLoadHeader where ysnPosted = 1)                                                          
                                              
          
Update a           
set a.strType = b.strType          
   ,a.strTrailerNo = b.strTrailerNo          
   ,a.intTruckId = b.intTruckId          
   ,a.intHaulerId = b.intHaulerId          
   ,a.dtmScheduledDate = b.dtmScheduledDate          
   ,a.intDriverId = b.intDriverEntityId          
From tblMBILLoadHeader a          
inner join #loadOrder b on b.intLoadId = a.intLoadId          
Where a.intDriverId = @intDriverId          
               
UPDATE a           
SET a.intDriverId = b.intDriverEntityId          
FROM tblMBILLoadHeader a            
INNER JOIN tblLGLoad b ON b.intLoadId = a.intLoadId          
WHERE (a.intDriverId = @intDriverId or b.intDriverEntityId = @intDriverId) --AND a.ysnPosted = 0          
          
INSERT INTO tblMBILLoadHeader(intLoadId                            
        ,strLoadNumber                            
        ,strType                            
        ,intTruckId                            
        ,strTrailerNo                            
        ,intDriverId                            
        ,intHaulerId                            
        ,dtmScheduledDate)                                                          
SELECT DISTINCT intLoadId                            
      ,strLoadNumber                            
      ,strType                            
      ,intTruckId                            
      ,strTrailerNo                            
      ,intDriverEntityId                            
      ,intHaulerId                            
      ,dtmScheduledDate                          
FROM #loadOrder WHERE intLoadId NOT IN (SELECT intLoadId FROM tblMBILLoadHeader)                                                      
            
Delete From tblMBILPickupDetail Where intLoadDetailId NOT IN (Select intLoadDetailId from tblLGLoadDetail) AND intLoadHeaderId IN (Select intLoadHeaderId from tblMBILLoadHeader where intDriverId = @intDriverId)            
  --//Update existing data              
 Update a               
 set   [intSellerId]  = loadDtl.[intSellerId]                                                 
    ,[intSalespersonId]  = loadDtl.[intSalespersonId]                                                  
    ,[strTerminalRefNo]  = loadDtl.[strTerminalRefNo]                                            
    ,[intEntityId]  = loadDtl.[intEntityId]                                                   
    ,[intEntityLocationId]  = loadDtl.[intEntityLocationId]                                                   
    ,[intCompanyLocationId]  = isnull([intPCompanyLocationId],intSCompanyLocationId)                                                      
    ,[intContractDetailId]  = isnull(intPContractDetailId,intSContractDetailId)                                              
    ,[intTaxGroupId]  = isnull(intOutboundTaxGroupId,intInboundTaxGroupId)                                                
    ,[dtmPickupFrom]  = loadDtl.[dtmPickUpFrom]                                                   
    ,[dtmPickupTo]  = loadDtl.[dtmPickUpTo]                                                   
    ,[strLoadRefNo]  = loadDtl.[strLoadRefNo]                                            
    ,[intItemId]  = loadDtl.[intItemId]                                                   
    ,[dblQuantity]  = loadDtl.[dblQuantity]                      
    ,[strPONumber]  = loadDtl.[strPONumber]                    
    ,[strItemUOM]  = loadDtl.[strItemUOM]               
 From tblMBILPickupDetail a              
 inner join #loadOrder loadDtl on a.intLoadDetailId = loadDtl.intLoadDetailId              
 inner join tblMBILLoadHeader h on a.intLoadHeaderId = h.intLoadHeaderId              
 Where loadDtl.intDriverEntityId = @intDriverId --and h.ysnPosted = 0         
 and a.ysnPickup = 0            
             
 INSERT INTO tblMBILPickupDetail(                                              
         [intLoadDetailId]                                                  
  ,[intLoadHeaderId]                                                   
  ,[intSellerId]                                                   
  ,[intSalespersonId]                                                  
  ,[strTerminalRefNo]                                            
  ,[intEntityId]                                                   
  ,[intEntityLocationId]                                                   
  ,[intCompanyLocationId]                                              
  ,[intContractDetailId]                                                   
  ,[intTaxGroupId]                                                   
  ,[dtmPickupFrom]                                                   
  ,[dtmPickupTo]                                                   
  ,[strLoadRefNo]                                            
  ,[intItemId]                                                   
  ,[dblQuantity]                      
  ,[strPONumber]                    
  ,[strItemUOM]                    
    )                                                   
   SELECT  distinct                                                   
   intLoadDetailId                                                  
  ,[intLoadHeaderId]                                                   
  ,[intSellerId]                                                   
  ,[intSalespersonId]                                                   
  ,[strTerminalRefNo]                                                  
  ,[intEntityId]                                                   
  ,[intEntityLocationId]                                                   
  ,isnull([intPCompanyLocationId],intSCompanyLocationId)                                                  
  ,isnull(intPContractDetailId,intSContractDetailId)                                                  
  ,isnull(intOutboundTaxGroupId,intInboundTaxGroupId)                                                  
  ,[dtmPickUpFrom]                                                   
  ,[dtmPickUpTo]                                                   
  ,(Select top 1 [strLoadRefNo] from #loadOrder po Where po.intLoadId = a.intLoadId and isnull(po.intCustomerLocationId,0) = isnull(a.intCustomerLocationId,0) and isnull(po.intEntityLocationId,0) = isnull(a.intEntityLocationId ,0) and isnull([strLoadRefNo],'') <> '')            
  ,[intItemId]                                                   
  ,[dblQuantity]                               
  ,(Select top 1 [strPONumber] from #loadOrder po Where po.intLoadId = a.intLoadId and isnull(po.intCustomerLocationId,0) = isnull(a.intCustomerLocationId,0) and isnull(po.intEntityLocationId,0) = isnull(a.intEntityLocationId ,0) and isnull([strPONumber],'') <> '')             
  ,[strItemUOM]                    
    FROM #loadOrder a                                                            
 INNER JOIN tblMBILLoadHeader load on a.intLoadId = load.intLoadId                                      
 WHERE a.intLoadDetailId NOT IN (SELECT intLoadDetailId FROM tblMBILPickupDetail)                                                        
            
Delete from tblMBILDeliveryDetail where intLoadDetailId not in(Select intLoadDetailId from tblLGLoadDetail) and ysnDelivered = 0 and intDeliveryHeaderId in(Select intDeliveryHeaderId from tblMBILDeliveryHeader where intLoadHeaderId in(Select intLoadHeaderId from tblMBILLoadHeader where intDriverId = @intDriverId and ysnPosted = 0))            
Delete from tblMBILDeliveryHeader where intLoadHeaderId in(Select intLoadHeaderId from tblMBILLoadHeader where intDriverId = @intDriverId and ysnPosted = 0) and intDeliveryHeaderId NOT IN(Select intDeliveryHeaderId from tblMBILDeliveryDetail)            
            
 --//Update delivery header Data            
 UPDATE delivery            
 SET delivery.intLoadHeaderId = load.intLoadHeaderId            
 ,delivery.intEntityId = a.intCustomerId            
 ,delivery.intEntityLocationId = a.intCustomerLocationId            
 ,delivery.intCompanyLocationId = isnull(a.intSCompanyLocationId,a.[intPCompanyLocationId])            
 ,delivery.dtmDeliveryFrom = a.dtmDeliveryFrom               
 ,delivery.dtmDeliveryTo = a.dtmDeliveryTo             
 ,delivery.intSalesPersonId = a.intSalespersonId            
 FROM tblMBILDeliveryHeader delivery            
 INNER JOIN tblMBILLoadHeader load on delivery.intLoadHeaderId = load.intLoadHeaderId            
 INNER JOIN tblMBILDeliveryDetail dtl on delivery.intDeliveryHeaderId = dtl.intDeliveryHeaderId            
 INNER JOIN #loadOrder a on dtl.intLoadDetailId = a.intLoadDetailId        
 WHERE load.intDriverId  = @intDriverId              
             
 --//INSERT IF NOT EXISTS DELIVERY HEADER            
 INSERT INTO tblMBILDeliveryHeader(intLoadHeaderId,intEntityId,intEntityLocationId,intCompanyLocationId,dtmDeliveryFrom,dtmDeliveryTo,intSalesPersonId)               
  Select load.intLoadHeaderId                                                  
   ,intCustomerId                                                  
   ,intCustomerLocationId                                                  
   ,isnull(intSCompanyLocationId,[intPCompanyLocationId])                                            
   ,a.dtmDeliveryFrom                                                  
   ,a.dtmDeliveryTo                                                  
   ,intSalespersonId                                                  
 FROM #loadOrder a                                                            
 inner join tblMBILLoadHeader load on a.intLoadId = load.intLoadId                 
 LEFT JOIN tblMBILDeliveryHeader delivery on load.intLoadHeaderId = delivery.intLoadHeaderId and                                                   
              isnull(a.intCustomerId,0) = isnull(delivery.intEntityId,0) and                                        
     case when a.intCustomerId is null then a.intSCompanyLocationId else a.intCustomerLocationId end =  case when a.intCustomerId is null then delivery.intCompanyLocationId else delivery.intEntityLocationId end                                               
 left join tblMBILDeliveryDetail dtl ON a.intLoadDetailId = dtl.intLoadDetailId and delivery.intDeliveryHeaderId = dtl.intDeliveryHeaderId             
 WHERE  delivery.intDeliveryHeaderId is null and             
 a.intDriverEntityId = @intDriverId             
 and dtl.intLoadDetailId is null            
Group by load.intLoadHeaderId                                                
   ,intCustomerId                                                  
   ,intCustomerLocationId                                                  
   ,isnull(intSCompanyLocationId,[intPCompanyLocationId])                       
   ,a.dtmDeliveryFrom                                                  
   ,a.dtmDeliveryTo                                    
   ,intSalespersonId                                                  
                                
UPDATE delivery            
Set delivery.intItemId = a.intItemId                                                            
   ,delivery.dblQuantity = a.dblQuantity            
,delivery.intPickupDetailId = pickupdetail.intPickupDetailId            
   ,delivery.intTMDispatchId = a.intTMDispatchId                          
   ,delivery.intTMSiteId = a.intTMSiteId            
   ,delivery.intDeliveryHeaderId = deliveryHdr.intDeliveryHeaderId            
FROM tblMBILDeliveryDetail delivery            
INNER JOIN #loadOrder a on a.intLoadDetailId = delivery.intLoadDetailId            
INNER JOIN tblMBILLoadHeader load on load.intLoadId = a.intLoadId            
INNER JOIN tblMBILPickupDetail pickupdetail on a.intLoadDetailId = pickupdetail.intLoadDetailId and pickupdetail.intLoadDetailId = delivery.intLoadDetailId            
INNER JOIN tblMBILDeliveryHeader deliveryHdr on load.intLoadHeaderId = deliveryHdr.intLoadHeaderId and                                                   
            isnull(a.intCustomerId,0) = isnull(deliveryHdr.intEntityId,0) and                                                   
            case when a.intCustomerId is null then a.intSCompanyLocationId else a.intCustomerLocationId end =  case when a.intCustomerId is null then deliveryHdr.intCompanyLocationId else deliveryHdr.intEntityLocationId end                        
Where a.intDriverEntityId = @intDriverId --and ysnPosted = 0         
and ysnDelivered = 0            
            
INSERT INTO tblMBILDeliveryDetail(                                                  
    intLoadDetailId                                                              
    ,intDeliveryHeaderId                                                            
    ,intItemId                                                              
    ,dblQuantity                                              
    ,intPickupDetailId                          
    ,intTMDispatchId                          
    ,intTMSiteId)                          
SELECT a.intLoadDetailId                                                     
        ,intDeliveryHeaderId                                                      
        ,a.intItemId                                                            
        ,a.dblQuantity                                                  
        ,pickupdetail.intPickupDetailId                            
        ,a.intTMDispatchId                          
        ,a.intTMSiteId                          
FROM #loadOrder a                                                            
INNER JOIN tblMBILLoadHeader load on a.intLoadId = load.intLoadId                                        
INNER JOIN tblMBILDeliveryHeader delivery on load.intLoadHeaderId = delivery.intLoadHeaderId and                                                   
            isnull(a.intCustomerId,0) = isnull(delivery.intEntityId,0) and                                                   
            isnull(a.intCustomerLocationId,0) = isnull(delivery.intEntityLocationId,0) and                                                  
            isnull(a.intSCompanyLocationId,a.intPCompanyLocationId) = delivery.intCompanyLocationId                            
left join tblMBILPickupDetail pickupdetail on a.intLoadDetailId = pickupdetail.intLoadDetailId                                     
Where a.intDriverEntityId = @intDriverId                                      
and a.intLoadDetailId NOT IN (SELECT intLoadDetailId FROM tblMBILDeliveryDetail)                        
                              
--RetainAge scenario                        
Select intLoadHeaderId,intEntityLocationId                           
into #tmp                          
From vyuMBILPickupHeader                          
Group by intLoadHeaderId,intEntityLocationId                           
having count(1) > 1                        
                          
Update pickupdetail                          
Set   pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom                          
 ,pickupdetail.dtmActualPickupTo = b.dtmActualPickupTo                          
  ,pickupdetail.intShiftId = b.intShiftId                          
  ,pickupdetail.dblPickupQuantity = LGLoadDetail.dblQuantity                         
  ,pickupdetail.dblQuantity = LGLoadDetail.dblQuantity                        
From tblMBILPickupDetail pickupdetail                        
INNER JOIN tblLGLoadDetail LGLoadDetail on pickupdetail.intLoadDetailId = LGLoadDetail.intLoadDetailId                        
INNER JOIN (                          
  Select pickup.*,dblDeliverQty = delivery.dblQuantity From tblMBILPickupDetail pickup                           
  inner join #tmp t on t.intLoadHeaderId = pickup.intLoadHeaderId and t.intEntityLocationId = isnull(pickup.intEntityLocationId,pickup.intCompanyLocationId)                          
        inner join tblMBILDeliveryDetail delivery on pickup.intLoadDetailId = delivery.intLoadDetailId                          
  Where ysnPickup = 1) b on pickupdetail.intLoadHeaderId = b.intLoadHeaderId  and isnull(pickupdetail.intEntityLocationId,0) = isnull(b.intEntityLocationId,0) and isnull(pickupdetail.intCompanyLocationId,0) = isnull(b.intCompanyLocationId,0) and b.intItemId = pickupdetail.intItemId                
       
Where pickupdetail.ysnPickup = 1                        
                          
UPDATE pickupdetail                          
SET   ysnPickup = 1                          
  ,pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom                          
  ,pickupdetail.dtmActualPickupTo = b.dtmActualPickupTo                          
  ,pickupdetail.intShiftId = b.intShiftId                          
  ,pickupdetail.dblPickupQuantity = LGLoadDetail.dblQuantity                         
  ,pickupdetail.dblQuantity = LGLoadDetail.dblQuantity                        
  ,pickupdetail.strBOL = b.strBOL                      
  ,pickupdetail.strPONumber = LGLoadDetail.strCustomerReference                      
  ,pickupdetail.dblGross = 0                  
  ,pickupdetail.dblNet = 0                  
FROM tblMBILPickupDetail pickupdetail                          
INNER JOIN tblLGLoadDetail LGLoadDetail on pickupdetail.intLoadDetailId = LGLoadDetail.intLoadDetailId                        
INNER JOIN (                          
  SELECT pickup.* FROM tblMBILPickupDetail pickup                           
  INNER JOIN #tmp t ON t.intLoadHeaderId = pickup.intLoadHeaderId and t.intEntityLocationId = isnull(pickup.intEntityLocationId,pickup.intCompanyLocationId)                          
  WHERE ysnPickup = 1) b ON pickupdetail.intLoadHeaderId = b.intLoadHeaderId and isnull(pickupdetail.intEntityLocationId,0) = isnull(b.intEntityLocationId,0) and isnull(pickupdetail.intCompanyLocationId,0) = isnull(b.intCompanyLocationId,0) and b.intItemId = pickupdetail.intItemId      
WHERE pickupdetail.ysnPickup = 0                       
                        
                        
UPDATE tblMBILDeliveryDetail                         
SET  dblQuantity = LGLoadDetail.dblQuantity,                        
     intItemId = LGLoadDetail.intItemId                        
FROM tblMBILDeliveryDetail deliveryDtl                        
INNER JOIN tblLGLoadDetail LGLoadDetail on deliveryDtl.intLoadDetailId = LGLoadDetail.intLoadDetailId                        
INNER JOIN tblLGLoad load on LGLoadDetail.intLoadId = load.intLoadId                        
WHERE deliveryDtl.ysnDelivered = 0 and load.intDriverEntityId = @intDriverId                        
  
  
  
--=====NEW DISPATCH SCREEN=====-  
--LOAD HEADER  
UPDATE MBL  
SET MBL.intDriverId = DO.intDriverEntityId,  
    MBL.intTruckId = DO.intEntityShipViaTruckId,  
 MBL.intTrailerId = DO.intEntityShipViaTrailerId  
FROM tblMBILLoadHeader MBL  
INNER JOIN tblLGDispatchOrder DO on DO.intDispatchOrderId = MBL.intDispatchOrderId  
WHERE DO.intDriverEntityId = @intDriverId  
AND (MBL.intDriverId = @intDriverId or DO.intDriverEntityId = @intDriverId)  
  
INSERT INTO tblMBILLoadHeader(intDispatchOrderId  
           ,strType  
        ,strLoadNumber  
        ,intDriverId  
        ,intTruckId  
        ,intHaulerId  
        ,intTrailerId  
        ,dtmScheduledDate  
        ,ysnPosted)  
SELECT DISTINCT LG.intDispatchOrderId  
      ,LGD.strOrderType  
      ,LG.strDispatchOrderNumber  
      ,LG.intDriverEntityId  
      ,LG.intEntityShipViaTruckId  
      ,LG.intEntityShipViaId  
      ,LG.intEntityShipViaTrailerId  
      ,LG.dtmDispatchDate  
      ,0 as ysnPosted  
FROM tblLGDispatchOrder LG   
INNER JOIN tblLGDispatchOrderDetail LGD ON LGD.intDispatchOrderId = LG.intDispatchOrderId  
WHERE intDispatchStatus = 3 AND NOT EXISTS(SELECT strLoadNumber COLLATE Latin1_General_CI_AS from tblMBILLoadHeader MB where MB.strLoadNumber = LG.strDispatchOrderNumber)   
  
  
  
--PICKUP DETAIL  
UPDATE MBP  
SET  MBP.[intSellerId] = NULL  
    ,MBP.[intSalespersonId]  = NULL  
    ,MBP.[strTerminalRefNo]  = NULL  
    ,MBP.[intEntityId]  = DO.intVendorId  
    ,MBP.[intEntityLocationId]  = DO.intVendorLocationId  
    ,MBP.[intCompanyLocationId]  = DO.intCompanyLocationId  
    ,MBP.[intContractDetailId]  = NULL  
    ,MBP.[intTaxGroupId]  = NULL  
    ,MBP.[dtmPickupFrom]  = NULL  
    ,MBP.[dtmPickupTo]  = NULL  
    ,MBP.[strLoadRefNo]  = NULL  
    ,MBP.[intItemId]  = DOD.intItemId  
    ,MBP.[dblQuantity]  = DOD.dblQuantity  
    ,MBP.[strPONumber]  = NULL  
    ,MBP.[strItemUOM]  = NULL  
FROM tblMBILPickupDetail MBP  
INNER JOIN tblMBILLoadHeader MBL on MBL.intLoadHeaderId = MBP.intLoadHeaderId  
INNER JOIN tblLGDispatchOrder DO on DO.intDispatchOrderId = MBL.intDispatchOrderId  
INNER JOIN tblLGDispatchOrderRoute DOR on DOR.intDispatchOrderRouteId = MBP.intDispatchOrderRouteId and DOR.intDispatchOrderId = DO.intDispatchOrderId  
INNER JOIN tblLGDispatchOrderDetail DOD on DOD.intDispatchOrderDetailId = DOR.intDispatchOrderDetailId and DOR.intDispatchOrderId = DOD.intDispatchOrderId  
WHERE MBL.intDriverId = @intDriverId  
  
INSERT INTO tblMBILPickupDetail(intDispatchOrderRouteId,strType,intLoadHeaderId,intEntityId,intEntityLocationId,intCompanyLocationId,intItemId,dblQuantity)  
Select DOR.intDispatchOrderRouteId,DOD.strOrderType,MBL.intLoadHeaderId,DO.intVendorId,DO.intVendorLocationId,DO.intCompanyLocationId,DOD.intItemId,DOD.dblQuantity  
from tblLGDispatchOrder DO  
inner join tblLGDispatchOrderRoute DOR on DOR.intDispatchOrderId = DO.intDispatchOrderId  
INNER JOIN tblLGDispatchOrderDetail DOD on DOD.intDispatchOrderDetailId = DOR.intDispatchOrderDetailId and DOR.intDispatchOrderId = DOD.intDispatchOrderId  
INNER JOIN tblMBILLoadHeader MBL on MBL.strLoadNumber = DO.strDispatchOrderNumber  
WHERE  intDispatchStatus = 3 AND   
  NOT EXISTS(SELECT 1 From tblMBILPickupDetail p   
    where p.intDispatchOrderRouteId = DOR.intDispatchOrderRouteId and p.intLoadHeaderId = MBL.intLoadHeaderId)
  
--DELIVERY HEADER  
UPDATE MBDH  
SET  MBDH.intLoadHeaderId = MB.intLoadHeaderId  
 ,MBDH.intEntityId = DOD.intEntityId   
 ,MBDH.intEntityLocationId = DOD.intEntityLocationId   
 ,MBDH.intCompanyLocationId = DOD.intCompanyLocationId  
 ,MBDH.dtmDeliveryFrom = NULL  
 ,MBDH.dtmDeliveryTo = NULL  
 ,MBDH.intSalesPersonId = NULL  
FROM tblMBILDeliveryHeader MBDH  
INNER JOIN tblMBILLoadHeader MB ON MB.intLoadHeaderId = MBDH.intLoadHeaderId  
INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = MB.intDispatchOrderId  
INNER JOIN tblLGDispatchOrderDetail DOD ON DOD.intDispatchOrderId = DOD.intDispatchOrderId AND ISNULL(DOD.intEntityLocationId,DOD.intCompanyLocationId) = ISNULL(MBDH.intEntityLocationId,MBDH.intCompanyLocationId)  
WHERE MB.intDriverId = @intDriverId AND intStopType = 2 and intDispatchStatus = 3  
  
  
INSERT INTO tblMBILDeliveryHeader(intLoadHeaderId,intEntityId,intEntityLocationId,intCompanyLocationId)  
SELECT DISTINCT MB.intLoadHeaderId,DOD.intEntityId, DOD.intEntityLocationId,DOD.intCompanyLocationId  
FROM tblLGDispatchOrder DO  
INNER JOIN tblLGDispatchOrderDetail DOD ON DO.intDispatchOrderId = DOD.intDispatchOrderId  
INNER JOIN tblMBILLoadHeader MB ON MB.strLoadNumber = DO.strDispatchOrderNumber  
WHERE intStopType = 2 and intDispatchStatus = 3 AND   
   NOT EXISTS(SELECT intDeliveryHeaderId
     FROM tblMBILDeliveryHeader p
     WHERE p.intLoadHeaderId = MB.intLoadHeaderId AND   
        isnull(p.intEntityLocationId,0) = isnull(DOD.intEntityLocationId,0) AND   
        isnull(p.intCompanyLocationId,0) = isnull(DOD.intCompanyLocationId,0))
  
--DELIVERY DETAIL  
UPDATE MBDL  
SET  MBDL.intItemId = DOD.intItemId                                                            
    ,MBDL.dblQuantity = DOD.dblQuantity            
 --,MBDL.intPickupDetailId = pickupdetail.intPickupDetailId            
    ,MBDL.intTMDispatchId = DOD.intTMDispatchId                          
    ,MBDL.intTMSiteId = DOD.intTMSiteId            
    ,MBDL.intDeliveryHeaderId = MBDH.intDeliveryHeaderId  
FROM tblLGDispatchOrder DO  
INNER JOIN tblLGDispatchOrderDetail DOD ON DO.intDispatchOrderId = DOD.intDispatchOrderId  
INNER JOIN tblMBILLoadHeader MBH ON MBH.strLoadNumber = DO.strDispatchOrderNumber  
INNER JOIN tblMBILDeliveryHeader MBDH ON MBH.intLoadHeaderId = MBDH.intLoadHeaderId AND ISNULL(DOD.intEntityLocationId,DOD.intCompanyLocationId) = ISNULL(MBDH.intEntityLocationId,MBDH.intCompanyLocationId)  
INNER JOIN tblMBILDeliveryDetail MBDL ON MBDL.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId and MBDL.intDeliveryHeaderId = MBDH.intDeliveryHeaderId  
WHERE DO.intDriverEntityId = @intDriverId AND intStopType = 2 and intDispatchStatus = 3  
  
INSERT INTO tblMBILDeliveryDetail(intDispatchOrderDetailId  
            ,intDeliveryHeaderId  
         ,intItemId  
         ,dblQuantity  
         ,intTMDispatchId  
         ,intTMSiteId)  
SELECT DOD.intDispatchOrderDetailId  
         ,MBDH.intDeliveryHeaderId  
      ,DOD.intItemId  
      ,DOD.dblQuantity  
      ,DOD.intTMDispatchId  
      ,DOD.intTMSiteId  
FROM tblLGDispatchOrder DO  
INNER JOIN tblLGDispatchOrderDetail DOD ON DO.intDispatchOrderId = DOD.intDispatchOrderId  
INNER JOIN tblMBILLoadHeader MBH ON MBH.strLoadNumber = DO.strDispatchOrderNumber  
INNER JOIN tblMBILDeliveryHeader MBDH ON MBH.intLoadHeaderId = MBDH.intLoadHeaderId AND ISNULL(DOD.intEntityLocationId,DOD.intCompanyLocationId) = ISNULL(MBDH.intEntityLocationId,MBDH.intCompanyLocationId)  
LEFT JOIN tblMBILDeliveryDetail MBDL ON MBDL.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId and MBDL.intDeliveryHeaderId = MBDH.intDeliveryHeaderId  
WHERE intStopType = 2 AND intDispatchStatus = 3 and MBDL.intDispatchOrderDetailId is null  
  
END