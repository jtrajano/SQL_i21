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
 --INNER JOIN #loadOrder a on load.intLoadHeaderId = delivery.intLoadHeaderId and                                               
 --       isnull(a.intCustomerId,0) = isnull(delivery.intEntityId,0) and                                               
 --       isnull(a.intCustomerLocationId,0) = isnull(delivery.intEntityLocationId,0) and                                              
 --       isnull(a.intSCompanyLocationId,a.intPCompanyLocationId) = delivery.intCompanyLocationId         
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
              --isnull(a.intCustomerLocationId,0) = isnull(delivery.intEntityLocationId,0) and                                              
              --isnull(a.intSCompanyLocationId,a.intPCompanyLocationId) = delivery.intCompanyLocationId                                             
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
   ,delivery.intContractDetailId = t.intContractDetailId
FROM tblMBILDeliveryDetail delivery        
INNER JOIN #loadOrder a on a.intLoadDetailId = delivery.intLoadDetailId        
INNER JOIN tblMBILLoadHeader load on load.intLoadId = a.intLoadId        
INNER JOIN tblMBILPickupDetail pickupdetail on a.intLoadDetailId = pickupdetail.intLoadDetailId and pickupdetail.intLoadDetailId = delivery.intLoadDetailId    
LEFT JOIN tblTMOrder t on a.intTMDispatchId = t.intDispatchId
INNER JOIN tblMBILDeliveryHeader deliveryHdr on load.intLoadHeaderId = deliveryHdr.intLoadHeaderId and                                               
            isnull(a.intCustomerId,0) = isnull(deliveryHdr.intEntityId,0) and                                               
            case when a.intCustomerId is null then a.intSCompanyLocationId else a.intCustomerLocationId end =  case when a.intCustomerId is null then deliveryHdr.intCompanyLocationId else deliveryHdr.intEntityLocationId end        
            --isnull(a.intCustomerLocationId,0) = isnull(deliveryHdr.intEntityLocationId,0) and                                              
            --isnull(a.intSCompanyLocationId,a.intPCompanyLocationId) = deliveryHdr.intCompanyLocationId                         
Where a.intDriverEntityId = @intDriverId --and ysnPosted = 0     
and ysnDelivered = 0        
        
INSERT INTO tblMBILDeliveryDetail(                                              
    intLoadDetailId                                                          
    ,intDeliveryHeaderId                                                        
    ,intItemId                                                          
    ,dblQuantity                                          
    ,intPickupDetailId                      
    ,intTMDispatchId                      
    ,intTMSiteId
	,intContractDetailId)                      
SELECT a.intLoadDetailId                                                 
        ,intDeliveryHeaderId                                                  
        ,a.intItemId                                                        
        ,a.dblQuantity                                              
        ,pickupdetail.intPickupDetailId                        
        ,a.intTMDispatchId                      
        ,a.intTMSiteId                      
		,t.intContractDetailId
FROM #loadOrder a                                                        
INNER JOIN tblMBILLoadHeader load on a.intLoadId = load.intLoadId                                    
INNER JOIN tblMBILDeliveryHeader delivery on load.intLoadHeaderId = delivery.intLoadHeaderId and                                               
            isnull(a.intCustomerId,0) = isnull(delivery.intEntityId,0) and                                               
            isnull(a.intCustomerLocationId,0) = isnull(delivery.intEntityLocationId,0) and                                              
            isnull(a.intSCompanyLocationId,a.intPCompanyLocationId) = delivery.intCompanyLocationId                        
left join tblMBILPickupDetail pickupdetail on a.intLoadDetailId = pickupdetail.intLoadDetailId        
LEFT JOIN tblTMOrder t on a.intTMDispatchId = t.intDispatchId
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

END