CREATE PROCEDURE [dbo].[uspMBILLoadSchedule]   
    @intDriverId AS INT    
AS    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    
BEGIN    
    
 Select intLoadId into #forDeleteMBILLoad From tblMBILPickupHeader WHERE ysnPickup = 1 and intDriverEntityId = @intDriverId    
    DELETE FROM tblMBILPickupDetail WHERE intPickupHeaderId not in(Select intPickupHeaderId from tblMBILPickupHeader where intLoadId in(Select intLoadId from #forDeleteMBILLoad))    
    DELETE FROM tblMBILDeliveryDetail WHERE intDeliveryHeaderId not in(Select intDeliveryHeaderId from tblMBILDeliveryHeader where intLoadId in(Select intLoadId from #forDeleteMBILLoad))    
    DELETE FROM tblMBILPickupHeader WHERE intLoadId not in(Select intLoadId From #forDeleteMBILLoad)    
    DELETE FROM tblMBILDeliveryHeader WHERE intLoadId not in(Select intLoadId From #forDeleteMBILLoad)    
     
  CREATE TABLE #loadOrder     
  (    
   intLoadId int,  
   intDriverEntityId int,    
   strLoadNumber nvarchar(100) COLLATE Latin1_General_CI_AS NULL,    
   strType varchar(100) COLLATE Latin1_General_CI_AS NULL,    
   intEntityId int NULL,    
   intEntityLocationId int NULL,    
   intCompanyLocationId int NULL,    
   intCompanyDeliveryLocationId int NULL,    
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
   strPONumber nvarchar(200) COLLATE Latin1_General_CI_AS NULL    
  )    
    
 INSERT INTO #loadOrder    
    SELECT *  
    FROM vyuMBILLoadSchedule    
    WHERE intDriverEntityId = @intDriverId AND intLoadId NOT IN (SELECT intLoadId FROM tblMBILPickupHeader)    
   
   INSERT INTO tblMBILPickupHeader(  
    intLoadId    
            ,intDriverEntityId    
            ,strLoadNumber    
            ,strType    
            ,intEntityId    
            ,intEntityLocationId    
            ,intCompanyLocationId    
   ,intSellerId    
   ,intSalespersonId    
   ,strTerminalRefNo    
            ,dtmPickupFrom    
            ,dtmPickupTo    
            ,strPONumber  
  )  
   SELECT  a.intLoadId    
    ,a.intDriverEntityId  
    ,a.strLoadNumber  
    ,a.strType   
    ,a.intEntityId  
    ,a.intEntityLocationId  
    ,a.intCompanyLocationId  
    ,a.intSellerId   
    ,a.intSalespersonId    
    ,a.strTerminalRefNo    
    ,a.dtmPickUpFrom   
    ,a.dtmPickUpTo   
    ,a.strPONumber    
        FROM #loadOrder a  
        GROUP BY a.intLoadId    
    ,a.intDriverEntityId  
    ,a.strLoadNumber  
    ,a.strType   
    ,a.intEntityId  
    ,a.intEntityLocationId  
    ,a.intCompanyLocationId  
    ,a.intSellerId   
    ,a.intSalespersonId    
    ,a.strTerminalRefNo    
    ,a.dtmPickUpFrom   
    ,a.dtmPickUpTo   
    ,a.strPONumber   
  
  INSERT INTO tblMBILDeliveryHeader(  
    intLoadId    
            ,intDriverEntityId    
   ,strLoadNumber    
            ,strType    
            ,intEntityId    
            ,intEntityLocationId    
            ,intCompanyLocationId    
      ,dtmDeliveryFrom    
      ,dtmDeliveryTo  
  )  
        SELECT   a.intLoadId    
    ,intDriverEntityId    
    ,strLoadNumber    
    ,strType    
    ,a.intCustomerId    
    ,intCustomerLocationId  
    ,intCompanyLocationId   
    ,dtmDeliveryFrom    
    ,dtmDeliveryTo  
        FROM #loadOrder a  
        GROUP BY a.intLoadId    
    ,intDriverEntityId    
    ,strLoadNumber    
    ,strType    
    ,a.intCustomerId    
    ,intCustomerLocationId  
    ,intCompanyLocationId    
    ,dtmDeliveryFrom    
    ,dtmDeliveryTo  
  
  INSERT INTO tblMBILPickupDetail(intPickupHeaderId,intItemId,dblQuantity)  
  SELECT    b.intPickupHeaderId  
    ,intItemId  
                ,sum(dblQuantity)dblQuantity    
        FROM #loadOrder a  
  INNER JOIN tblMBILPickupHeader b on a.intLoadId = b.intLoadId and isnull(a.intEntityLocationId,a.intCompanyLocationId) = isnull(b.intEntityLocationId,b.intCompanyLocationId) and a.intDriverEntityId = @intDriverId  
        --WHERE a.intLoadId = 1026  
        GROUP BY  b.intPickupHeaderId  
     ,a.intEntityId  
    ,a.intEntityLocationId  
    ,a.intCompanyLocationId  
    ,a.intLoadId    
    ,intItemId  
  
  INSERT INTO tblMBILDeliveryDetail(    
    intDeliveryHeaderId  
    ,intItemId    
    ,dblQuantity    
  )    
  SELECT  b.intDeliveryHeaderId  
    ,intItemId  
                ,sum(dblQuantity)dblQuantity    
        FROM #loadOrder a  
  INNER JOIN tblMBILDeliveryHeader b on a.intLoadId = b.intLoadId and isnull(a.intCustomerLocationId,a.intCompanyDeliveryLocationId) = isnull(b.intEntityLocationId,b.intCompanyLocationId) and a.intDriverEntityId = @intDriverId  
        GROUP BY  b.intDeliveryHeaderId  
     ,a.intEntityId  
    ,a.intEntityLocationId  
    ,a.intCompanyLocationId  
    ,a.intLoadId    
    ,intItemId  
  
  update tblMBILDeliveryDetail  
  set intPickupDetailId = b.intPickupDetailId  
  from  
  tblMBILDeliveryHeader h  
  inner join tblMBILDeliveryDetail d on h.intDeliveryHeaderId = d.intDeliveryHeaderId  
  inner join (  
   SELECT a.intLoadId  
    ,c.intPickupDetailId  
    ,a.intItemId  
    ,intCustomerLocationId = isnull(a.intCustomerLocationId,a.intCompanyDeliveryLocationId)  
    FROM #loadOrder a  
    INNER JOIN tblMBILPickupHeader b on a.intLoadId = b.intLoadId and isnull(a.intEntityLocationId,a.intCompanyLocationId) = isnull(b.intEntityLocationId,b.intCompanyLocationId) and a.intDriverEntityId = 915  
    Inner Join tblMBILPickupDetail c on b.intPickupHeaderId = c.intPickupHeaderId and a.intItemId = c.intItemId  
    ) b on h.intLoadId = b.intLoadId and d.intItemId = b.intItemId and isnull(h.intEntityLocationId,h.intCompanyLocationId) = b.intCustomerLocationId  
    
END    
    
    