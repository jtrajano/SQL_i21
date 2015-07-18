﻿CREATE VIEW [dbo].[vyuTRDispatchedLoad]
	AS 
select 
LG.intLoadId,
LG.intLoadNumber,
LG.strType,
LG.intItemId,
LG.intEntityId as intEntityVendorId,
(select top 1 intSupplyPointId from dbo.tblTRSupplyPoint SP where SP.intEntityLocationId = LG.intEntityLocationId) as intSupplyPointId,
LG.intCompanyLocationId as intInboundCompanyLocationId,
LG.intContractDetailId as intInboundContractDetailId,
LG.dblQuantity as dblInboundQuantiy,
LG.dblCashPrice as dblInboundPrice,
LG.strCustomer as strTerminalName,
LG.strShipFromTo as strSupplyPoint,
LG.strLocationName,
LG.strItemNo as strInboundItemNo,
LG.intContractNumber as intInboundContractNumber,
LG.intCounterPartyEntityId as intEntityCustomerId,
LG.intCounterPartyCompanyLocationId as intOutboundCompanyLocationId, 
LG.intCounterPartyEntityLocationId as intShipToLocationId,
(select top 1 intSalespersonId from tblARCustomer AR where AR.intEntityCustomerId = LG.intCounterPartyEntityId) as intEntitySalespersonId,
(select strCustomerNumber from tblARCustomer AR where AR.intEntityCustomerId = LG.intCounterPartyEntityId) as strCustomerNumber,
(select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = LG.intCounterPartyCompanyLocationId) as strOutboundLocationName,
(select top 1 strSalespersonId from tblARCustomer AR 
                                    Left Join tblARSalesperson SP on AR.intSalespersonId = SP.intEntitySalespersonId
									 where AR.intEntityCustomerId = LG.intCounterPartyEntityId) as strOutboundSalespersonId,
LG.strCounterPartyLocationName as strShipTo,
LG.intCounterPartyItemId as intOutboundItemId,
LG.dblQuantity as dblOutboundQuantity,
LG.dblCounterPartyCashPrice as dblOutboundPrice,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intCounterPartyItemId) as strOutboundItemNo,
LG.intCounterPartyContractNumber as intOutboundContractNumber,
LG.dtmDeliveredDate,
LG.intHaulerEntityId as intShipViaId,
LG.intHaulerEntityId as intSellerId,
LG.intDriverEntityId as intDriverId,
LG.strTruckNo as strTractor,
LG.strTrailerNo1 as strTrailer,
LG.strHauler as strShipVia,
LG.strHauler as strSeller,
LG.strDriver as strSalespersonId,
LG.intCounterPartyContractDetailId as intOutboundContractDetailId,
LG.ysnDirectShip,
LG.ysnInProgress,
LG.intCounterPartyLoadId as intOutboundLoadId
from dbo.vyuLGLoadView LG
where 
 (IsNull(LG.ysnDispatched,0)=1) and (IsNull(LG.ysnInProgress,0) = 0) and (IsNull(LG.dblDeliveredQuantity,0) <= 0) and
((IsNull(LG.ysnDirectShip,0) = 1 and LG.strType ='Inbound') 
or (IsNull(LG.ysnDirectShip,0) = 0 and LG.strType ='Inbound'))
UNION ALL
select 
LG.intLoadId,
LG.intLoadNumber,
LG.strType,
LG.intItemId,
NULL as intEntityVendorId,
NULL as intSupplyPointId,
NULL as intInboundCompanyLocationId,
NULL as intInboundContractDetailId,
LG.dblQuantity as dblInboundQuantiy,
LG.dblCashPrice as dblInboundPrice,
NULL as strTerminalName,
NULL as strSupplyPoint,
LG.strLocationName,
LG.strItemNo as strInboundItemNo,
NULL as intInboundContractNumber,
LG.intEntityId as intEntityCustomerId,
LG.intCompanyLocationId as intOutboundCompanyLocationId, 
LG.intEntityLocationId as intShipToLocationId,
(select top 1 intSalespersonId from tblARCustomer AR where AR.intEntityCustomerId = LG.intEntityId) as intEntitySalespersonId,
(select strCustomerNumber from tblARCustomer AR where AR.intEntityCustomerId = LG.intEntityId) as strCustomerNumber,
(select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = LG.intCompanyLocationId) as strOutboundLocationName,
(select top 1 strSalespersonId from tblARCustomer AR 
                                    Left Join tblARSalesperson SP on AR.intSalespersonId = SP.intEntitySalespersonId
									 where AR.intEntityCustomerId = LG.intEntityId) as strOutboundSalespersonId,
LG.strShipFromTo as strShipTo,
LG.intItemId as intOutboundItemId,
LG.dblQuantity as dblOutboundQuantity,
LG.dblCashPrice as dblOutboundPrice,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId) as strOutboundItemNo,
LG.intContractNumber as intOutboundContractNumber,
LG.dtmDeliveredDate,
LG.intHaulerEntityId as intShipViaId,
LG.intHaulerEntityId as intSellerId,
LG.intDriverEntityId as intDriverId,
LG.strTruckNo as strTractor,
LG.strTrailerNo1 as strTrailer,
LG.strHauler as strShipVia,
LG.strHauler as strSeller,
LG.strDriver as strSalespersonId,
LG.intContractDetailId as intOutboundContractDetailId,
LG.ysnDirectShip,
LG.ysnInProgress,
LG.intLoadId as intOutboundLoadId
from dbo.vyuLGLoadView LG
where 
 (IsNull(LG.ysnDispatched,0)=1) and (IsNull(LG.ysnInProgress,0) = 0) and (IsNull(LG.dblDeliveredQuantity,0) <= 0) and
((IsNull(LG.ysnDirectShip,0) = 0 and LG.strType ='Outbound'))	
	

