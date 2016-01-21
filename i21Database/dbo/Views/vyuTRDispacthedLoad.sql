CREATE VIEW [dbo].[vyuTRDispatchedLoad]
	AS 
select 
LG.intLoadId,
LG.intLoadDetailId,
LG.intLoadNumber,
LG.strType,
LG.intItemId,
LG.intVendorEntityId as intEntityVendorId,
(select top 1 intSupplyPointId from dbo.tblTRSupplyPoint SP where SP.intEntityLocationId = LG.intVendorEntityLocationId) as intSupplyPointId,
LG.intPCompanyLocationId as intInboundCompanyLocationId,
LG.intPContractDetailId as intInboundContractDetailId,
LG.dblQuantity as dblInboundQuantiy,
dblInboundPrice = CASE
						WHEN LG.dblPCashPrice is NOT NULL or LG.dblPCashPrice != 0							        
						   THEN LG.dblPCashPrice
						WHEN LG.dblPCashPrice is NULL or LG.dblPCashPrice = 0
						   THEN [dbo].[fnTRGetRackPrice]
                                (
                                   LG.dtmScheduledDate 	
	                               ,(select top 1 intSupplyPointId from dbo.tblTRSupplyPoint SP where SP.intEntityLocationId = LG.intVendorEntityLocationId) 
	                               ,LG.intItemId 
                                  )  
						END,
LG.strCustomer as strTerminalName,
(select strLocationName from tblEntityLocation EM where EM.intEntityLocationId = LG.intVendorEntityLocationId) as strSupplyPoint,
LG.strPLocationName strLocationName,
IsNull(LG.strItemNo,(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId)) as strInboundItemNo,
LG.strPContractNumber as strInboundContractNumber,
LG.intCustomerEntityId as intEntityCustomerId,
IsNull(LG.intSCompanyLocationId,LG.intPCompanyLocationId) as intOutboundCompanyLocationId, 
LG.intCustomerEntityLocationId as intShipToLocationId,
(select top 1 intSalespersonId from tblARCustomer AR where AR.intEntityCustomerId = LG.intCustomerEntityId) as intEntitySalespersonId,
(select strName from vyuARCustomer AR where AR.intEntityCustomerId = LG.intCustomerEntityId) as strCustomerNumber,
(select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = IsNull(LG.intSCompanyLocationId,LG.intPCompanyLocationId)) as strOutboundLocationName,
(select top 1 SP.strName from tblARCustomer AR 
                                    Left Join vyuEMEntity SP on AR.intSalespersonId = SP.intEntityId
									 where AR.intEntityCustomerId = LG.intCustomerEntityId) as strOutboundSalespersonId,
LG.strShipTo as strShipTo,
LG.intItemId as intOutboundItemId,
LG.dblQuantity as dblOutboundQuantity,
LG.dblSCashPrice as dblOutboundPrice,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId) as strOutboundItemNo,
LG.strSContractNumber as strOutboundContractNumber,
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
LG.intSContractDetailId as intOutboundContractDetailId,
ysnDirectShip = CASE
						WHEN LG.intPurchaseSale = 3							        
						   THEN cast(1 as bit)
						   ELSE cast (0 as bit)
						END,
LG.ysnInProgress,
LG.intLoadId as intOutboundLoadId,
LG.strExternalLoadNumber as strSupplierLoadNumber,
(select strPricingType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId ) as strInboundPricingType,
(select strPricingType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId  ) as strOutboundPricingType,
(select dblAdjustment from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId )  as dblInboundAdjustment,
(select dblAdjustment from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId )  as dblOutboundAdjustment,
(select top 1 strZipCode from dbo.tblTRSupplyPoint SP
                                    join dbo.tblEntityLocation EL on SP.intEntityLocationId = EL.intEntityLocationId and SP.intEntityVendorId = EL.intEntityId
									where SP.intEntityLocationId = LG.intVendorEntityLocationId) as strZipCode,
(select top 1 SP.intRackPriceSupplyPointId from dbo.tblTRSupplyPoint SP where SP.intEntityLocationId = LG.intVendorEntityLocationId) as intRackPriceSupplyPointId,
(select top 1 intItemUOMId from tblICItemUOM IT where IT.intItemId = LG.intItemId) as intItemUOMId,
(select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId ) as strInboundIndexType,
(select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId) as strOutboundIndexType,
intInboundIndexRackPriceSupplyPointId  = CASE
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId ),0) = 'Fixed' 							        
								     THEN isNull((select top 1 intRackPriceSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId ),(select top 1 intSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId )) 
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intPContractDetailId ),0) != 'Fixed' 
								     THEN null
								  END,
intOutboundIndexRackPriceSupplyPointId  = CASE
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ),0) = 'Fixed' 							        
								     THEN isNull((select top 1 intRackPriceSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ),(select top 1 intSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId )) 
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ),0) != 'Fixed' 
								     THEN null
								  END,
(select top 1 intTaxGroupId from dbo.tblTRSupplyPoint SP where SP.intEntityLocationId = LG.intVendorEntityLocationId) as intInboundTaxGroupId ,
(select top 1 TX.strTaxGroup from dbo.tblTRSupplyPoint SP 
                                     LEFT JOIN tblSMTaxGroup TX on SP.intTaxGroupId = TX.intTaxGroupId
									 where SP.intEntityLocationId = LG.intVendorEntityLocationId) as strInboundTaxGroup,
(select top 1 EM.intTaxGroupId from tblEntityLocation EM where EM.intEntityLocationId = LG.intCustomerEntityLocationId) as intOutboundTaxGroupId,
(select top 1 strTaxGroup from tblEntityLocation EM
                               LEFT JOIN tblSMTaxGroup TX on EM.intTaxGroupId = TX.intTaxGroupId 
                               where EM.intEntityLocationId = LG.intCustomerEntityLocationId) as strOutboundTaxGroup
from dbo.vyuLGLoadView LG
where 
 (IsNull(LG.ysnDispatched,0)=1)  and (IsNull(LG.dblDeliveredQuantity,0) <= 0) and (LG.strType != 'Outbound')
UNION ALL
select 
LG.intLoadId,
LG.intLoadDetailId,
LG.intLoadNumber,
LG.strType,
LG.intItemId,
NULL as intEntityVendorId,
NULL as intSupplyPointId,
NULL as intInboundCompanyLocationId,
NULL as intInboundContractDetailId,
LG.dblQuantity as dblInboundQuantiy,
LG.dblSCashPrice as dblInboundPrice,
NULL as strTerminalName,
NULL as strSupplyPoint,
LG.strSLocationName strLocationName,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId) as strInboundItemNo,
NULL as intInboundContractNumber,
LG.intCustomerEntityId as intEntityCustomerId,
LG.intSCompanyLocationId as intOutboundCompanyLocationId, 
LG.intCustomerEntityLocationId as intShipToLocationId,
(select top 1 intSalespersonId from tblARCustomer AR where AR.intEntityCustomerId = LG.intCustomerEntityId) as intEntitySalespersonId,
(select strCustomerNumber from tblARCustomer AR where AR.intEntityCustomerId = LG.intCustomerEntityId) as strCustomerNumber,
(select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = LG.intSCompanyLocationId) as strOutboundLocationName,
(select top 1 SP.strName from tblARCustomer AR 
                                    Left Join vyuEMEntity SP on AR.intSalespersonId = SP.intEntityId
									 where AR.intEntityCustomerId = LG.intCustomerEntityId) as strOutboundSalespersonId,
(select strLocationName from tblEntityLocation EML where EML.intEntityLocationId = LG.intCustomerEntityLocationId) as strShipTo,
LG.intItemId as intOutboundItemId,
LG.dblQuantity as dblOutboundQuantity,
LG.dblSCashPrice as dblOutboundPrice,
(select strItemNo from tblICItem IC where IC.intItemId = LG.intItemId) as strOutboundItemNo,
LG.strSContractNumber as strOutboundContractNumber,
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
LG.intSContractDetailId as intOutboundContractDetailId,
ysnDirectShip = CASE
						WHEN LG.intPurchaseSale = 3							        
						   THEN cast(1 as bit)
						   ELSE cast (0 as bit)
						END,
LG.ysnInProgress,
LG.intLoadId as intOutboundLoadId,
LG.strExternalLoadNumber as strSupplierLoadNumber,
null as strInboundPricingType,
(select strPricingType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId  ) as strOutboundPricingType,
null as dblInboundAdjustment,
(select dblAdjustment from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId  ) as dblOutboundAdjustment,
(select strZipPostalCode from dbo.tblSMCompanyLocation SM where LG.intSCompanyLocationId = SM.intCompanyLocationId) as strZipCode,
NULL as intRackPriceSupplyPointId,
(select top 1 intItemUOMId from tblICItemUOM IT where IT.intItemId = LG.intItemId) as intItemUOMId, 
NULL as strInboundIndexType,
(select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ) as strOutboundIndexType,
NULL as intInboundIndexRackPriceSupplyPointId,   
intOutboundIndexRackPriceSupplyPointId  = CASE
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ),0) = 'Fixed' 							        
								     THEN isNull((select top 1 intRackPriceSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ),(select top 1 intSupplyPointId from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId )) 
								  WHEN isNull((select top 1 strIndexType from vyuCTContractDetailView CT where CT.intContractDetailId = LG.intSContractDetailId ),0) != 'Fixed' 
								     THEN null
								  END,
NULL as intInboundTaxGroupId ,
NULL as strInboundTaxGroup,
(select top 1 EM.intTaxGroupId from tblEntityLocation EM where EM.intEntityLocationId = LG.intCustomerEntityLocationId) as intOutboundTaxGroupId,
(select top 1 strTaxGroup from tblEntityLocation EM
                               LEFT JOIN tblSMTaxGroup TX on EM.intTaxGroupId = TX.intTaxGroupId 
                               where EM.intEntityLocationId = LG.intCustomerEntityLocationId) as strOutboundTaxGroup

from dbo.vyuLGLoadView LG
where 
 (IsNull(LG.ysnDispatched,0)=1)  and (IsNull(LG.dblDeliveredQuantity,0) <= 0) and (LG.strType = 'Outbound')
