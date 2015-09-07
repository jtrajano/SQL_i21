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
(select strLocationName from tblEntityLocation EM where EM.intEntityLocationId = LG.intEntityLocationId) as strSupplyPoint,
LG.strLocationName,
LG.strItemNo as strInboundItemNo,
LG.strContractNumber as strInboundContractNumber,
LG.intCounterPartyEntityId as intEntityCustomerId,
LG.intCounterPartyCompanyLocationId as intOutboundCompanyLocationId, 
LG.intCounterPartyEntityLocationId as intShipToLocationId,
(select top 1 intSalespersonId from tblARCustomer AR where AR.intEntityCustomerId = LG.intCounterPartyEntityId) as intEntitySalespersonId,
(select strCustomerNumber from tblARCustomer AR where AR.intEntityCustomerId = LG.intCounterPartyEntityId) as strCustomerNumber,
(select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = LG.intCounterPartyCompanyLocationId) as strOutboundLocationName,
(select top 1 SP.strEntityNo from tblARCustomer AR 
                                    Left Join vyuEMEntity SP on AR.intSalespersonId = SP.intEntityId
									 where AR.intEntityCustomerId = LG.intCounterPartyEntityId) as strOutboundSalespersonId,
LG.strCounterPartyLocationName as strShipTo,
LG.intCounterPartyItemId as intOutboundItemId,
LG.dblQuantity as dblOutboundQuantity,
LG.dblCounterPartyCashPrice as dblOutboundPrice,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intCounterPartyItemId) as strOutboundItemNo,
LG.strCounterPartyContractNumber as strOutboundContractNumber,
LG.dtmScheduledDate,
LG.dtmDispatchedDate,
LG.intHaulerEntityId as intShipViaId,
(select top 1 intSellerId from tblTRCompanyPreference) as intSellerId,
LG.intDriverEntityId as intDriverId,
LG.strTruckNo as strTractor,
LG.strTrailerNo1 as strTrailer,
LG.strHauler as strShipVia,
(select top 1 EM.strName from tblTRCompanyPreference CP 
                               join tblEntity EM on CP.intSellerId = EM.intEntityId) as strSeller,
LG.strDriver as strSalespersonId,
LG.intCounterPartyContractDetailId as intOutboundContractDetailId,
LG.ysnDirectShip,
LG.ysnInProgress,
LG.intCounterPartyLoadId as intOutboundLoadId,
LG.strExternalLoadNumber as strSupplierLoadNumber,
(select strPricingType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ) as strInboundPricingType,
(select strPricingType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId  ) as strOutboundPricingType,
(select dblAdjustment from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId )  as dblInboundAdjustment,
(select dblAdjustment from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId )  as dblOutboundAdjustment,
(select top 1 strZipCode from dbo.tblTRSupplyPoint SP
                                    join dbo.tblEntityLocation EL on SP.intEntityLocationId = EL.intEntityLocationId and SP.intEntityVendorId = EL.intEntityId
									where SP.intEntityLocationId = LG.intEntityLocationId) as strZipCode,
(select top 1 SP.intRackPriceSupplyPointId from dbo.tblTRSupplyPoint SP where SP.intEntityLocationId = LG.intEntityLocationId) as intRackPriceSupplyPointId,
(select top 1 intItemUOMId from tblICItemUOM IT where IT.intItemId = LG.intItemId) as intItemUOMId,
(select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ) as strInboundIndexType,
(select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId) as strOutboundIndexType,
intInboundIndexRackPriceSupplyPointId  = CASE
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ),0) = 'Fixed' 							        
								     THEN isNull((select top 1 intRackPriceSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ),(select top 1 intSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId )) 
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ),0) != 'Fixed' 
								     THEN null
								  END,
intOutboundIndexRackPriceSupplyPointId  = CASE
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId ),0) = 'Fixed' 							        
								     THEN isNull((select top 1 intRackPriceSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId ),(select top 1 intSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId )) 
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intCounterPartyContractDetailId ),0) != 'Fixed' 
								     THEN null
								  END
from dbo.vyuLGLoadView LG
where 
 (IsNull(LG.ysnDispatched,0)=1)  and (IsNull(LG.dblDeliveredQuantity,0) <= 0) and
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
(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId) as strInboundItemNo,
NULL as intInboundContractNumber,
LG.intEntityId as intEntityCustomerId,
LG.intCompanyLocationId as intOutboundCompanyLocationId, 
LG.intEntityLocationId as intShipToLocationId,
(select top 1 intSalespersonId from tblARCustomer AR where AR.intEntityCustomerId = LG.intEntityId) as intEntitySalespersonId,
(select strCustomerNumber from tblARCustomer AR where AR.intEntityCustomerId = LG.intEntityId) as strCustomerNumber,
(select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = LG.intCompanyLocationId) as strOutboundLocationName,
(select top 1 SP.strEntityNo from tblARCustomer AR 
                                    Left Join vyuEMEntity SP on AR.intSalespersonId = SP.intEntityId
									 where AR.intEntityCustomerId = LG.intEntityId) as strOutboundSalespersonId,
(select strLocationName from tblEntityLocation EML where EML.intEntityLocationId = LG.intEntityLocationId) as strShipTo,
LG.intItemId as intOutboundItemId,
LG.dblQuantity as dblOutboundQuantity,
LG.dblCashPrice as dblOutboundPrice,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId) as strOutboundItemNo,
LG.strContractNumber as strOutboundContractNumber,
LG.dtmScheduledDate,
LG.dtmDispatchedDate,
LG.intHaulerEntityId as intShipViaId,
(select top 1 intSellerId from tblTRCompanyPreference) as intSellerId,
LG.intDriverEntityId as intDriverId,
LG.strTruckNo as strTractor,
LG.strTrailerNo1 as strTrailer,
LG.strHauler as strShipVia,
(select top 1 EM.strName from tblTRCompanyPreference CP 
                               join tblEntity EM on CP.intSellerId = EM.intEntityId) as strSeller,
LG.strDriver as strSalespersonId,
LG.intContractDetailId as intOutboundContractDetailId,
LG.ysnDirectShip,
LG.ysnInProgress,
LG.intLoadId as intOutboundLoadId,
LG.strExternalLoadNumber as strSupplierLoadNumber,
null as strInboundPricingType,
(select strPricingType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId  ) as strOutboundPricingType,
null as dblInboundAdjustment,
(select dblAdjustment from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId  ) as dblOutboundAdjustment,
(select strZipPostalCode from dbo.tblSMCompanyLocation SM where LG.intCompanyLocationId = SM.intCompanyLocationId) as strZipCode,
NULL as intRackPriceSupplyPointId,
(select top 1 intItemUOMId from tblICItemUOM IT where IT.intItemId = LG.intItemId) as intItemUOMId, 
NULL as strInboundIndexType,
(select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ) as strOutboundIndexType,
NULL as intInboundIndexRackPriceSupplyPointId,   
intOutboundIndexRackPriceSupplyPointId  = CASE
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ),0) = 'Fixed' 							        
								     THEN isNull((select top 1 intRackPriceSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ),(select top 1 intSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId )) 
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intContractDetailId ),0) != 'Fixed' 
								     THEN null
								  END
from dbo.vyuLGLoadView LG
where 
 (IsNull(LG.ysnDispatched,0)=1)  and (IsNull(LG.dblDeliveredQuantity,0) <= 0) and
((IsNull(LG.ysnDirectShip,0) = 0 and LG.strType ='Outbound'))	