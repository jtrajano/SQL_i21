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
 ,a.ysnDispatched = b.ysnDispatched
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
FROM #loadOrder WHERE NOT EXISTS (SELECT intLoadId FROM tblMBILLoadHeader where tblMBILLoadHeader.intLoadId = #loadOrder.intLoadId)

Delete From tblMBILPickupDetail Where intLoadDetailId NOT IN (Select intLoadDetailId from tblLGLoadDetail) AND intLoadHeaderId IN (Select intLoadHeaderId from tblMBILLoadHeader where intDriverId = @intDriverId) and ysnPickup = 0
--//Update existing data
 Update a 
 set [intSellerId]= loadDtl.[intSellerId] 
,[intSalespersonId]= loadDtl.[intSalespersonId]
,[strTerminalRefNo]= loadDtl.[strTerminalRefNo]
,[intEntityId]= loadDtl.[intEntityId] 
,[intEntityLocationId]= loadDtl.[intEntityLocationId] 
,[intCompanyLocationId]= isnull([intPCompanyLocationId],intSCompanyLocationId)
,[intContractDetailId]= intPContractDetailId
,[intTaxGroupId]= isnull(intOutboundTaxGroupId,intInboundTaxGroupId)
,[dtmPickupFrom]= loadDtl.[dtmPickUpFrom] 
,[dtmPickupTo]= loadDtl.[dtmPickUpTo] 
,[strLoadRefNo]= loadDtl.[strLoadRefNo]
,[intItemId]= loadDtl.[intItemId] 
,[dblQuantity]= loadDtl.[dblQuantity]
,[strPONumber]= loadDtl.[strPONumber]
,[strItemUOM]= loadDtl.[strItemUOM]
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
,[dblGross]
,[dblNet]
,[dblPickupQuantity]
) 
 SELECT distinct 
 intLoadDetailId
,[intLoadHeaderId] 
,[intSellerId] 
,[intSalespersonId] 
,[strTerminalRefNo]
,[intEntityId] 
,[intEntityLocationId] 
,isnull([intPCompanyLocationId],intSCompanyLocationId)
,intPContractDetailId
,isnull(intOutboundTaxGroupId,intInboundTaxGroupId)
,[dtmPickUpFrom] 
,[dtmPickUpTo] 
,(Select top 1 [strLoadRefNo] from #loadOrder po Where po.intLoadId = a.intLoadId and isnull(po.intCustomerLocationId,0) = isnull(a.intCustomerLocationId,0) and isnull(po.intEntityLocationId,0) = isnull(a.intEntityLocationId ,0) and isnull([strLoadRefNo],'') <> '')
,[intItemId] 
,[dblQuantity] 
,(Select top 1 [strPONumber] from #loadOrder po Where po.intLoadId = a.intLoadId and isnull(po.intCustomerLocationId,0) = isnull(a.intCustomerLocationId,0) and isnull(po.intEntityLocationId,0) = isnull(a.intEntityLocationId ,0) and isnull([strPONumber],'') <> '') 
,[strItemUOM]
,0 as dblGross
,0 as dblNet
,0 as dblPickupQuantity
FROM #loadOrder a 
 INNER JOIN tblMBILLoadHeader load on a.intLoadId = load.intLoadId 
 WHERE NOT EXISTS(SELECT intLoadDetailId FROM tblMBILPickupDetail where tblMBILPickupDetail.intLoadDetailId = a.intLoadDetailId)

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
 WHERE load.intDriverId= @intDriverId
 
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
 case when a.intCustomerId is null then a.intSCompanyLocationId else a.intCustomerLocationId end =case when a.intCustomerId is null then delivery.intCompanyLocationId else delivery.intEntityLocationId end 


 left join tblMBILDeliveryDetail dtl ON a.intLoadDetailId = dtl.intLoadDetailId and delivery.intDeliveryHeaderId = dtl.intDeliveryHeaderId 
 WHERE delivery.intDeliveryHeaderId is null and 
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
 ,delivery.intContractDetailId = isnull(a.intSContractDetailId,t.intContractDetailId)
FROM tblMBILDeliveryDetail delivery
INNER JOIN #loadOrder a on a.intLoadDetailId = delivery.intLoadDetailId
INNER JOIN tblMBILLoadHeader load on load.intLoadId = a.intLoadId
INNER JOIN tblMBILPickupDetail pickupdetail on a.intLoadDetailId = pickupdetail.intLoadDetailId and pickupdetail.intLoadDetailId = delivery.intLoadDetailId
LEFT JOIN tblTMOrder t on a.intTMDispatchId = t.intDispatchId
INNER JOIN tblMBILDeliveryHeader deliveryHdr on load.intLoadHeaderId = deliveryHdr.intLoadHeaderId and 
isnull(a.intCustomerId,0) = isnull(deliveryHdr.intEntityId,0) and 
case when a.intCustomerId is null then a.intSCompanyLocationId else a.intCustomerLocationId end =case when a.intCustomerId is null then deliveryHdr.intCompanyLocationId else deliveryHdr.intEntityLocationId end

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
,dblDeliveredQty
,intContractDetailId)
SELECT a.intLoadDetailId
,intDeliveryHeaderId
,a.intItemId
,a.dblQuantity
,pickupdetail.intPickupDetailId
,a.intTMDispatchId
,a.intTMSiteId
 ,0 as dblDeliveredQty
,isnull(a.intSContractDetailId,t.intContractDetailId)
FROM #loadOrder a
INNER JOIN tblMBILLoadHeader load on a.intLoadId = load.intLoadId
INNER JOIN tblMBILDeliveryHeader delivery on load.intLoadHeaderId = delivery.intLoadHeaderId and 
isnull(a.intCustomerId,0) = isnull(delivery.intEntityId,0) and 
isnull(a.intCustomerLocationId,0) = isnull(delivery.intEntityLocationId,0) and
isnull(a.intSCompanyLocationId,a.intPCompanyLocationId) = delivery.intCompanyLocationId
left join tblMBILPickupDetail pickupdetail on a.intLoadDetailId = pickupdetail.intLoadDetailId 
LEFT JOIN tblTMOrder t on a.intTMDispatchId = t.intDispatchId
Where a.intDriverEntityId = @intDriverId
and NOT EXISTS (SELECT intLoadDetailId FROM tblMBILDeliveryDetail where tblMBILDeliveryDetail.intLoadDetailId = a.intLoadDetailId) 


UPDATE tblMBILDeliveryDetail 
SET dblQuantity = LGLoadDetail.dblQuantity,
 intItemId = LGLoadDetail.intItemId
FROM tblMBILDeliveryDetail deliveryDtl
INNER JOIN tblLGLoadDetail LGLoadDetail on deliveryDtl.intLoadDetailId = LGLoadDetail.intLoadDetailId
INNER JOIN tblLGLoad load on LGLoadDetail.intLoadId = load.intLoadId
WHERE deliveryDtl.ysnDelivered = 0 and load.intDriverEntityId = @intDriverId

--RetainAge scenario
Select intLoadHeaderId,intEntityLocationId 
into #tmp
From vyuMBILPickupHeader
Group by intLoadHeaderId,intEntityLocationId 
having count(1) > 1

Update pickupdetail
Set pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom
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
Where ysnPickup = 1) b on pickupdetail.intLoadHeaderId = b.intLoadHeaderId and isnull(pickupdetail.intEntityLocationId,0) = isnull(b.intEntityLocationId,0) and isnull(pickupdetail.intCompanyLocationId,0) = isnull(b.intCompanyLocationId,0) and b.intItemId = pickupdetail.intItemId
 
Where pickupdetail.ysnPickup = 1

UPDATE pickupdetail
SET ysnPickup = 1
,pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom
,pickupdetail.dtmActualPickupTo = b.dtmActualPickupTo
,pickupdetail.intShiftId = b.intShiftId
,pickupdetail.dblPickupQuantity = LGLoadDetail.dblQuantity 
,pickupdetail.dblQuantity = LGLoadDetail.dblQuantity
,pickupdetail.strBOL = b.strBOL
,pickupdetail.strPONumber = LGLoadDetail.strCustomerReference 
FROM tblMBILPickupDetail pickupdetail
INNER JOIN tblLGLoadDetail LGLoadDetail on pickupdetail.intLoadDetailId = LGLoadDetail.intLoadDetailId
INNER JOIN (
SELECT pickup.* FROM tblMBILPickupDetail pickup 
INNER JOIN #tmp t ON t.intLoadHeaderId = pickup.intLoadHeaderId and t.intEntityLocationId = isnull(pickup.intEntityLocationId,pickup.intCompanyLocationId)
WHERE ysnPickup = 1) b ON pickupdetail.intLoadHeaderId = b.intLoadHeaderId and isnull(pickupdetail.intEntityLocationId,0) = isnull(b.intEntityLocationId,0) and isnull(pickupdetail.intCompanyLocationId,0) = isnull(b.intCompanyLocationId,0) and b.intItemId = pickupdetail.intItemId
WHERE pickupdetail.ysnPickup = 0 


--=====NEW DISPATCH SCREEN=====-
--LOAD HEADER
UPDATE MBL
SET MBL.intDriverId = DO.intDriverEntityId,
MBL.intTruckId = DO.intEntityShipViaTruckId,
 MBL.intTrailerId = DO.intEntityShipViaTrailerId ,
 MBL.ysnDispatched = case when isnull(DO.intDispatchStatus,0) = 3 then 1 else 0 end,
 MBL.strType = case when DO.intVendorId is null then 'Outbound' ELSE 'Drop Ship' end
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
,case when LG.intVendorLocationId is null then 'Outbound' ELSE 'Drop Ship' end strOrderType
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
SET MBP.[intSellerId] = DO.intSellerId
,MBP.[intSalespersonId]= DO.intSalespersonId
,MBP.[strTerminalRefNo]= NULL
,MBP.[intEntityId]= DOD.intVendorId
,MBP.[intEntityLocationId]= DOD.intVendorLocationId
,MBP.[intCompanyLocationId]= DOD.intCompanyLocationId
,MBP.[intContractDetailId]= NULL
,MBP.[intTaxGroupId]= NULL
,MBP.[dtmPickupFrom]= NULL
,MBP.[dtmPickupTo]= NULL
,MBP.[strLoadRefNo]= DO.strLoadRef
,MBP.[intItemId]= DOD.intItemId
,MBP.[dblQuantity]= DOD.dblQuantity
,MBP.[strPONumber]= NULL 
,MBP.[strItemUOM]= NULL
,MBP.[strBOL] = ''
,MBP.intDispatchOrderRouteId = DOR.intDispatchOrderRouteId
FROM tblMBILPickupDetail MBP
INNER JOIN tblMBILLoadHeader MBL on MBL.intLoadHeaderId = MBP.intLoadHeaderId
INNER JOIN tblLGDispatchOrder DO on DO.intDispatchOrderId = MBL.intDispatchOrderId
INNER JOIN tblLGDispatchOrderDetail DOD on DO.intDispatchOrderId = DOD.intDispatchOrderId
INNER JOIN tblLGDispatchOrderRoute DOR on DOD.intDispatchOrderId = DOR.intDispatchOrderId AND DOD.intItemId = DOR.intItemId AND DOR.intStopType = 1 and MBP.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId
WHERE MBL.intDriverId = @intDriverId and MBP.ysnPickup = 0

INSERT INTO tblMBILPickupDetail(intDispatchOrderDetailId,strType,intLoadHeaderId,intEntityId,intEntityLocationId,intCompanyLocationId,intSellerId,intSalespersonId,strLoadRefNo,intItemId,dblQuantity,intDispatchOrderRouteId)
Select DOD.intDispatchOrderDetailId,DOD.strOrderType,MBL.intLoadHeaderId,DOD.intVendorId,DOD.intVendorLocationId,DOD.intCompanyLocationId,DO.intSellerId,DOD.intSalespersonId,DOD.strLoadRef,DOD.intItemId,DOD.dblQuantity,DOR.intDispatchOrderRouteId
from tblLGDispatchOrder DO
INNER JOIN tblLGDispatchOrderDetail DOD on DO.intDispatchOrderId = DOD.intDispatchOrderId
INNER JOIN tblLGDispatchOrderRoute DOR on DOD.intDispatchOrderId = DOR.intDispatchOrderId AND DOD.intItemId = DOR.intItemId AND DOR.intStopType = 1
INNER JOIN tblMBILLoadHeader MBL on MBL.strLoadNumber = DO.strDispatchOrderNumber 
WHERE intDispatchStatus = 3 AND DO.intDriverEntityId = @intDriverId AND
NOT EXISTS(SELECT 1 From tblMBILPickupDetail p 
where p.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId and p.intLoadHeaderId = MBL.intLoadHeaderId)

--DELIVERY HEADER

INSERT INTO tblMBILDeliveryHeader(intLoadHeaderId,intEntityId,intEntityLocationId,intCompanyLocationId)
SELECT DISTINCT MB.intLoadHeaderId
			   ,CASE WHEN TMS.ysnCompanySite  = 1 then NULL ELSE DOD.intEntityId END intEntityId
			   ,DOD.intEntityLocationId
			   ,TMS.intLocationId intCompanyLocationId
FROM tblLGDispatchOrder DO
INNER JOIN tblLGDispatchOrderDetail DOD ON DO.intDispatchOrderId = DOD.intDispatchOrderId
INNER JOIN tblMBILLoadHeader MB ON MB.strLoadNumber = DO.strDispatchOrderNumber
INNER JOIN tblTMDispatch TMD on TMD.intDispatchID = DOD.intTMDispatchId
INNER JOIN tblTMSite TMS on TMS.intSiteID = TMD.intSiteID
WHERE intStopType = 2 and intDispatchStatus = 3 AND 
 NOT EXISTS(SELECT intDeliveryHeaderId
 FROM tblMBILDeliveryHeader p
 WHERE p.intLoadHeaderId = MB.intLoadHeaderId  AND DO.intDriverEntityId = @intDriverId AND 
isnull(p.intEntityLocationId,0) = isnull(DOD.intEntityLocationId,0) AND 
isnull(p.intCompanyLocationId,0) = isnull(CASE WHEN TMS.ysnCompanySite  = 1 then TMS.intLocationId ELSE DO.intCompanyLocationId END,isnull(p.intCompanyLocationId,0)))

UPDATE MBDH
SET MBDH.intLoadHeaderId = MB.intLoadHeaderId
,MBDH.intEntityId = CASE WHEN TMS.ysnCompanySite  = 1 then NULL ELSE DOD.intEntityId END
,MBDH.intEntityLocationId = DOD.intEntityLocationId 
,MBDH.intCompanyLocationId = TMS.intLocationId
,MBDH.dtmDeliveryFrom = NULL
,MBDH.dtmDeliveryTo = NULL
,MBDH.intSalesPersonId = NULL
FROM tblMBILDeliveryHeader MBDH
INNER JOIN tblMBILLoadHeader MB ON MB.intLoadHeaderId = MBDH.intLoadHeaderId
INNER JOIN tblLGDispatchOrder DO ON DO.intDispatchOrderId = MB.intDispatchOrderId
INNER JOIN tblLGDispatchOrderDetail DOD ON DOD.intDispatchOrderId = DOD.intDispatchOrderId AND ISNULL(DOD.intEntityLocationId,DO.intCompanyLocationId) = ISNULL(MBDH.intEntityLocationId,MBDH.intCompanyLocationId)
INNER JOIN tblTMDispatch TMD on TMD.intDispatchID = DOD.intTMDispatchId
INNER JOIN tblTMSite TMS on TMS.intSiteID = TMD.intSiteID
WHERE MB.intDriverId = @intDriverId AND intStopType = 2 and intDispatchStatus = 3and exists(Select * from tblMBILDeliveryDetail d Where MBDH.intDeliveryHeaderId = d.intDeliveryHeaderId and ysnDelivered = 0)

 


--DELIVERY DETAIL
INSERT INTO tblMBILDeliveryDetail(intDispatchOrderDetailId
,intDeliveryHeaderId
 ,intItemId
 ,dblQuantity
 ,intTMDispatchId
 ,intTMSiteId
 ,dblDeliveredQty
 ,intContractDetailId)
SELECT DOD.intDispatchOrderDetailId
 ,MBDH.intDeliveryHeaderId
,DOD.intItemId
,DOD.dblQuantity
,DOD.intTMDispatchId
,DOD.intTMSiteId 
,0 as dblDeliveredQty
,t.intContractDetailId
FROM tblLGDispatchOrder DO
INNER JOIN tblLGDispatchOrderDetail DOD ON DO.intDispatchOrderId = DOD.intDispatchOrderId
INNER JOIN tblMBILLoadHeader MBH ON MBH.strLoadNumber = DO.strDispatchOrderNumber
INNER JOIN tblTMDispatch TMD on TMD.intDispatchID = DOD.intTMDispatchId
INNER JOIN tblTMSite TMS on TMS.intSiteID = TMD.intSiteID
INNER JOIN tblMBILDeliveryHeader MBDH ON MBH.intLoadHeaderId = MBDH.intLoadHeaderId AND ISNULL(DOD.intEntityLocationId,CASE WHEN TMS.ysnCompanySite  = 1 THEN TMS.intLocationId else DO.intCompanyLocationId end) = ISNULL(MBDH.intEntityLocationId,MBDH.intCompanyLocationId)
LEFT JOIN tblMBILDeliveryDetail MBDL ON MBDL.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId and MBDL.intDeliveryHeaderId = MBDH.intDeliveryHeaderId 
LEFT JOIN tblTMOrder t on DOD.intTMDispatchId = t.intDispatchId
WHERE intStopType = 2 AND intDispatchStatus = 3 and MBDL.intDispatchOrderDetailId is null  AND DO.intDriverEntityId = @intDriverId

UPDATE MBDL
SET MBDL.intItemId = DOD.intItemId
,MBDL.dblQuantity = DOD.dblQuantity
,MBDL.intPickupDetailId = MBP.intPickupDetailId
,MBDL.intTMDispatchId = DOD.intTMDispatchId
,MBDL.intTMSiteId = DOD.intTMSiteId
,MBDL.intDeliveryHeaderId = MBDH.intDeliveryHeaderId
,MBDL.intContractDetailId = t.intContractDetailId
FROM tblLGDispatchOrder DO
INNER JOIN tblLGDispatchOrderDetail DOD ON DO.intDispatchOrderId = DOD.intDispatchOrderId
INNER JOIN tblMBILLoadHeader MBH ON MBH.strLoadNumber = DO.strDispatchOrderNumber
INNER JOIN tblTMDispatch TMD on TMD.intDispatchID = DOD.intTMDispatchId
INNER JOIN tblTMSite TMS on TMS.intSiteID = TMD.intSiteID
INNER JOIN tblMBILDeliveryHeader MBDH ON MBH.intLoadHeaderId = MBDH.intLoadHeaderId AND ISNULL(DOD.intEntityLocationId,CASE WHEN TMS.ysnCompanySite  = 1 THEN TMS.intLocationId else DO.intCompanyLocationId end) = ISNULL(MBDH.intEntityLocationId,MBDH.intCompanyLocationId)
INNER JOIN tblMBILDeliveryDetail MBDL ON MBDL.intDispatchOrderDetailId = DOD.intDispatchOrderDetailId and MBDL.intDeliveryHeaderId = MBDH.intDeliveryHeaderId
LEFT JOIN tblMBILPickupDetail MBP on MBP.intDispatchOrderDetailId = MBDL.intDispatchOrderDetailId
LEFT JOIN tblTMOrder t on MBDL.intTMDispatchId = t.intDispatchId
WHERE DO.intDriverEntityId = @intDriverId AND intStopType = 2 and intDispatchStatus = 3 and MBDL.ysnDelivered = 0

Update dd
set dd.intPickupDetailId = p.intPickupDetailId
From tblMBILLoadHeader h
inner join tblMBILPickupDetail p on h.intLoadHeaderId = p.intLoadHeaderId
inner join tblMBILDeliveryHeader dh on dh.intLoadHeaderId = h.intLoadHeaderId and p.intLoadHeaderId = dh.intLoadHeaderId
inner join tblMBILDeliveryDetail dd on dh.intDeliveryHeaderId = dd.intDeliveryHeaderId and (p.intDispatchOrderDetailId = dd.intDispatchOrderDetailId or p.intLoadDetailId = dd.intLoadDetailId)
Where p.intPickupDetailId <> dd.intPickupDetailId and h.intDriverId = @intDriverId

DELETE FROM tblMBILPickupDetail WHERE intDispatchOrderDetailId NOT IN(SELECT intDispatchOrderDetailId FROM tblLGDispatchOrderDetail) and intDispatchOrderDetailId is not null and intLoadHeaderId IN(Select intLoadHeaderId from tblMBILLoadHeader where intDriverId = @intDriverId) and ysnPickup = 0
DELETE FROM tblMBILDeliveryDetail WHERE intDispatchOrderDetailId NOT IN(SELECT intDispatchOrderDetailId FROM tblLGDispatchOrderDetail) and intDispatchOrderDetailId is not null and 
 intDeliveryHeaderId IN(Select intDeliveryHeaderId from tblMBILDeliveryHeader d join tblMBILLoadHeader l on d.intLoadHeaderId = d.intLoadHeaderId where l.intDriverId = @intDriverId) and ysnDelivered = 0
DELETE FROM tblMBILDeliveryHeader WHERE NOT EXISTS(SELECT intDeliveryHeaderId FROM tblMBILDeliveryDetail WHERE tblMBILDeliveryDetail.intDeliveryHeaderId = tblMBILDeliveryHeader.intDeliveryHeaderId) and intLoadHeaderId IN(SELECT intLoadHeaderId FROM tblMBILLoadHeader where intDriverId = @intDriverId)
DELETE FROM tblMBILLoadHeader WHERE intDispatchOrderId NOT IN(SELECT intDispatchOrderId FROM tblLGDispatchOrder) and intDispatchOrderId is not null AND intDriverId = @intDriverId  and intLoadHeaderId not in(Select intLoadHeaderId from tblMBILDeliveryHeader)


--RetainAge scenario
Select intLoadHeaderId,intEntityLocationId 
into #tmpDispatch 
From vyuMBILPickupHeader
Where intDriverId = @intDriverId
Group by intLoadHeaderId,intEntityLocationId 
having count(1) > 1

Update pickupdetail
Set pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom
 ,pickupdetail.dtmActualPickupTo = b.dtmActualPickupTo
,pickupdetail.intShiftId = b.intShiftId
,pickupdetail.dblPickupQuantity = LGLoadDetail.dblQuantity 
,pickupdetail.dblQuantity = LGLoadDetail.dblQuantity
From tblMBILPickupDetail pickupdetail
INNER JOIN tblLGDispatchOrderDetail LGLoadDetail on pickupdetail.intDispatchOrderDetailId = LGLoadDetail.intDispatchOrderDetailId
INNER JOIN (
Select pickup.*,dblDeliverQty = delivery.dblQuantity From tblMBILPickupDetail pickup 
inner join #tmpDispatch t on t.intLoadHeaderId = pickup.intLoadHeaderId and t.intEntityLocationId = isnull(pickup.intEntityLocationId,pickup.intCompanyLocationId)
inner join tblMBILDeliveryDetail delivery on pickup.intDispatchOrderDetailId = delivery.intDispatchOrderDetailId
Where ysnPickup = 1) b on pickupdetail.intLoadHeaderId = b.intLoadHeaderId and isnull(pickupdetail.intEntityLocationId,0) = isnull(b.intEntityLocationId,0) and isnull(pickupdetail.intCompanyLocationId,0) = isnull(b.intCompanyLocationId,0) and b.intItemId = pickupdetail.intItemId
 
Where pickupdetail.ysnPickup = 1

UPDATE pickupdetail
SET ysnPickup = 1
,pickupdetail.dtmActualPickupFrom = b.dtmActualPickupFrom
,pickupdetail.dtmActualPickupTo = b.dtmActualPickupTo
,pickupdetail.intShiftId = b.intShiftId
,pickupdetail.dblPickupQuantity = LGLoadDetail.dblQuantity 
,pickupdetail.dblQuantity = LGLoadDetail.dblQuantity
,pickupdetail.strBOL = b.strBOL
,pickupdetail.strPONumber = LGLoadDetail.strPONumber
,pickupdetail.intCompanyLocationId = b.intCompanyLocationId
,pickupdetail.dblGross = 0
,pickupdetail.dblNet = 0
FROM tblMBILPickupDetail pickupdetail
INNER JOIN tblLGDispatchOrderDetail LGLoadDetail on pickupdetail.intDispatchOrderDetailId = LGLoadDetail.intDispatchOrderDetailId
INNER JOIN (
SELECT pickup.* FROM tblMBILPickupDetail pickup 
INNER JOIN #tmpDispatch t ON t.intLoadHeaderId = pickup.intLoadHeaderId and t.intEntityLocationId = isnull(pickup.intEntityLocationId,pickup.intCompanyLocationId)
WHERE ysnPickup = 1) b ON pickupdetail.intLoadHeaderId = b.intLoadHeaderId and isnull(pickupdetail.intEntityLocationId,0) = isnull(b.intEntityLocationId,0) and isnull(pickupdetail.intCompanyLocationId,isnull(b.intCompanyLocationId,0)) = isnull(b.intCompanyLocationId,0) and b.intItemId = pickupdetail.intItemId
WHERE pickupdetail.ysnPickup = 0

Update tblMBILDeliveryDetail
set dblQuantity = t.dblQuantity
From(
Select min(intDeliveryDetailId)intDeliveryDetailId ,t.dblQuantity
From tblMBILDeliveryDetail d
inner join tblTMOrder t on d.intTMDispatchId = t.intDispatchId
INNER JOIN tblTMDispatch tm on t.intDispatchId = tm.intDispatchID 
where t.intContractDetailId is not null and t.ysnOverage is null  and isnull(ysnDelivered,0) = 0 and tm.intDriverID = @intDriverId
Group by t.dblQuantity
)t 
Where tblMBILDeliveryDetail.intDeliveryDetailId = t.intDeliveryDetailId

Update tblMBILDeliveryDetail
set dblQuantity = t.dblQuantity,
	intContractDetailId = null
From(
Select max(intDeliveryDetailId)intDeliveryDetailId ,t.dblQuantity
From tblMBILDeliveryDetail d
inner join tblTMOrder t on d.intTMDispatchId = t.intDispatchId
INNER JOIN tblTMDispatch tm on t.intDispatchId = tm.intDispatchID
where t.intContractDetailId is null and t.ysnOverage = 1  and isnull(ysnDelivered,0) = 0 and tm.intDriverID = @intDriverId
Group by t.dblQuantity
)t 
Where tblMBILDeliveryDetail.intDeliveryDetailId = t.intDeliveryDetailId

END