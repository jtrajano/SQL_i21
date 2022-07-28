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
              
   Declare @DeleteQuery as NVARCHAR(MAX) = N'Select intLoadHeaderId,intLoadDetailId into #tmp from tblMBILPickupDetail where intLoadHeaderId NOT IN('+ @forDeleteId +') and        
            intLoadHeaderId not in(Select intLoadHeaderId from tblMBILLoadHeader where ysnPosted = 1 and intDriverId = '+ cast(@intDriverId as varchar(150))+') and ysnPickup = 0        
                   
             DELETE FROM tblMBILPickupDetail  where intLoadDetailId in(select intLoadDetailId from #tmp)        
                      
               DELETE FROM tblMBILDeliveryDetail WHERE ysnDelivered = 0 and intLoadDetailId IN (Select intLoadDetailId from #tmp)     
                    
              DELETE FROM tblMBILDeliveryHeader where intDeliveryHeaderId not in(Select intDeliveryHeaderId FROM tblMBILDeliveryDetail)    
                     
              DELETE FROM tblMBILLoadHeader WHERE intLoadHeaderId NOT IN(SELECT intLoadHeaderId FROM tblMBILPickupDetail) AND intLoadHeaderId NOT IN(SELECT intLoadHeaderId FROM tblMBILDeliveryHeader)      
   '                
 EXEC(@DeleteQuery)                    
                 
                             
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
 --strPONumber nvarchar(200) COLLATE Latin1_General_CI_AS NULL,            
 strLoadRefNo nvarchar(200) COLLATE Latin1_General_CI_AS NULL,            
 intHaulerId int,                           
 dtmScheduledDate datetime,                          
 intPContractDetailId INT NULL,                          
 intSContractDetailId INT NULL,                          
 intOutboundTaxGroupId INT NULL,                          
 intInboundTaxGroupId INT NULL ,  
 intTMDispatchId INT NULL,  
 intTMSiteId INT NULL  
 )                                   
     
    
 INSERT INTO #loadOrder                                      
 SELECT *                                    
 FROM vyuMBILLoadSchedule                                      
 WHERE intDriverEntityId = @intDriverId AND intLoadId NOT IN (SELECT intLoadId FROM tblMBILLoadHeader where ysnPosted = 1)                                  
                      
                         
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
  ,[strLoadRefNo]                           
  ,[intItemId]                           
  ,[dblQuantity]                              
    FROM #loadOrder a                                    
 INNER JOIN tblMBILLoadHeader load on a.intLoadId = load.intLoadId              
 WHERE a.intLoadDetailId NOT IN (SELECT intLoadDetailId FROM tblMBILPickupDetail)                                
     
 INSERT INTO tblMBILDeliveryHeader(intLoadHeaderId,intEntityId,intEntityLocationId,intCompanyLocationId,dtmDeliveryFrom,dtmDeliveryTo,intSalesPersonId)                          
 Select load.intLoadHeaderId                          
   ,intCustomerId                          
   ,intCustomerLocationId                          
   ,isnull([intPCompanyLocationId],intSCompanyLocationId)                          
   ,dtmDeliveryFrom                          
   ,dtmDeliveryTo                          
   ,intSalespersonId                          
 FROM #loadOrder a                                    
 inner join tblMBILLoadHeader load on a.intLoadId = load.intLoadId           
    Where a.intLoadDetailId NOT IN (SELECT intLoadDetailId FROM tblMBILDeliveryDetail)                                
    Group by load.intLoadHeaderId                          
    ,intCustomerId                          
    ,intCustomerLocationId                          
    ,isnull([intPCompanyLocationId],intSCompanyLocationId)                          
    ,dtmDeliveryFrom                          
    ,dtmDeliveryTo            
    ,intSalespersonId                          
                          
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
              isnull(a.intPCompanyLocationId,a.intSCompanyLocationId) = delivery.intCompanyLocationId                    
      and isnull(a.dtmDeliveryFrom,getdate()) = isnull(delivery.dtmDeliveryFrom,getdate()) and isnull(a.dtmDeliveryTo,getdate()) = isnull(delivery.dtmDeliveryTo,getdate())      
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
  Where ysnPickup = 1) b on pickupdetail.intLoadHeaderId = b.intLoadHeaderId and pickupdetail.intEntityLocationId = b.intEntityLocationId and pickupdetail.intCompanyLocationId = b.intCompanyLocationId  
Where pickupdetail.ysnPickup = 1
  
UPDATE pickupdetail  
SET   ysnPickup = 1  
	 ,pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom  
	 ,pickupdetail.dtmActualPickupTo = b.dtmActualPickupTo  
	 ,pickupdetail.intShiftId = b.intShiftId  
	 ,pickupdetail.dblPickupQuantity = LGLoadDetail.dblQuantity 
	 ,pickupdetail.dblQuantity = LGLoadDetail.dblQuantity
	 ,pickupdetail.strBOL = b.strBOL  
FROM tblMBILPickupDetail pickupdetail  
INNER JOIN tblLGLoadDetail LGLoadDetail on pickupdetail.intLoadDetailId = LGLoadDetail.intLoadDetailId
INNER JOIN (  
  SELECT pickup.* FROM tblMBILPickupDetail pickup   
  INNER JOIN #tmp t ON t.intLoadHeaderId = pickup.intLoadHeaderId and t.intEntityLocationId = isnull(pickup.intEntityLocationId,pickup.intCompanyLocationId)  
  WHERE ysnPickup = 1) b ON pickupdetail.intLoadHeaderId = b.intLoadHeaderId and pickupdetail.intEntityLocationId = b.intEntityLocationId and pickupdetail.intCompanyLocationId = b.intCompanyLocationId
WHERE pickupdetail.ysnPickup = 0



UPDATE tblMBILDeliveryDetail 
SET  dblQuantity = LGLoadDetail.dblQuantity,
     intItemId = LGLoadDetail.intItemId
FROM tblMBILDeliveryDetail deliveryDtl
INNER JOIN tblLGLoadDetail LGLoadDetail on deliveryDtl.intLoadDetailId = LGLoadDetail.intLoadDetailId
INNER JOIN tblLGLoad load on LGLoadDetail.intLoadId = load.intLoadId
WHERE deliveryDtl.ysnDelivered = 0 and load.intDriverEntityId = @intDriverId

END 