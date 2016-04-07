CREATE VIEW [dbo].[vyuTRDispatchedLoad]
	AS 

SELECT LG.intLoadId
	, LG.intLoadDetailId
	, LG.strLoadNumber
	, LG.strType
	, LG.intItemId
	, LG.intVendorEntityId AS intEntityVendorId
	, SupplyPoint.intSupplyPointId AS intSupplyPointId
	, LG.intPCompanyLocationId AS intInboundCompanyLocationId
	, LG.intPContractDetailId AS intInboundContractDetailId
	, LG.dblQuantity AS dblInboundQuantiy
	, dblInboundPrice = CASE WHEN LG.dblPCashPrice IS NOT NULL OR LG.dblPCashPrice != 0
								THEN LG.dblPCashPrice
							WHEN LG.dblPCashPrice IS NULL OR LG.dblPCashPrice = 0
								THEN [dbo].[fnTRGetRackPrice](LG.dtmScheduledDate, SupplyPoint.intSupplyPointId, LG.intItemId)
							END
	, LG.strVendor AS strTerminalName
	, SupplyPoint.strSupplyPoint AS strSupplyPoint
	, LG.strPLocationName strLocationName
	, LG.strItemNo AS strInboundItemNo
	, LG.strPContractNumber AS strInboundContractNumber
	, LG.intCustomerEntityId AS intEntityCustomerId
	, ISNULL(LG.intSCompanyLocationId, LG.intPCompanyLocationId) AS intOutboundCompanyLocationId
	, LG.intCustomerEntityLocationId AS intShipToLocationId
	, Customer.intSalespersonId AS intEntitySalespersonId
	, Customer.strName AS strCustomerNumber
	, (select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = ISNULL(LG.intSCompanyLocationId,LG.intPCompanyLocationId)) AS strOutboundLocationName
	, (select top 1 SP.strName from tblARCustomer AR LEFT JOIN vyuEMEntity SP on AR.intSalespersonId = SP.intEntityId where AR.intEntityCustomerId = LG.intCustomerEntityId) AS strOutboundSalespersonId
	, LG.strShipTo AS strShipTo
	, LG.intItemId AS intOutboundItemId
	, LG.dblQuantity AS dblOutboundQuantity
	, LG.dblSCashPrice AS dblOutboundPrice
	, LG.strItemNo AS strOutboundItemNo
	, LG.strSContractNumber AS strOutboundContractNumber
	, LG.dtmScheduledDate
	, LG.dtmDispatchedDate
	, LG.intHaulerEntityId AS intShipViaId
	, (SELECT TOP 1 intSellerId FROM tblTRCompanyPreference) AS intSellerId
	, LG.intDriverEntityId AS intDriverId
	, LG.strTruckNo AS strTractor
	, LG.strTrailerNo1 AS strTrailer
	, LG.strHauler AS strShipVia
	, (SELECT TOP 1 EM.strName FROM tblTRCompanyPreference CP JOIN tblEMEntity EM ON CP.intSellerId = EM.intEntityId) AS strSeller
	, LG.strDriver AS strSalespersonId
	, LG.intSContractDetailId AS intOutboundContractDetailId
	, ysnDirectShip = CASE WHEN LG.intPurchaseSale = 3 THEN CAST(1 AS BIT)
						ELSE CAST(0 AS BIT) END
	, LG.ysnInProgress
	, LG.intLoadId AS intOutboundLoadId
	, LG.strExternalLoadNumber AS strSupplierLoadNumber
	, PurchaseContract.strPricingType AS strInboundPricingType
	, SalesContract.strPricingType AS strOutboundPricingType
	, PurchaseContract.dblAdjustment AS dblInboundAdjustment
	, SalesContract.dblAdjustment AS dblOutboundAdjustment
	, SupplyPoint.strZipCode AS strZipCode
	, SupplyPoint.intRackPriceSupplyPointId AS intRackPriceSupplyPointId
	, LG.intItemUOMId AS intItemUOMId
	, PurchaseContract.strIndexType AS strInboundIndexType
	, SalesContract.strIndexType AS strOutboundIndexType
	, intInboundIndexRackPriceSupplyPointId = CASE WHEN ISNULL(PurchaseContract.strIndexType, 0) = 'Fixed'
														THEN ISNULL(PurchaseContract.intRackPriceSupplyPointId, PurchaseContract.intSupplyPointId)
													ELSE NULL END
	, intOutboundIndexRackPriceSupplyPointId  = CASE WHEN ISNULL(SalesContract.strIndexType, 0) = 'Fixed'
														THEN ISNULL(SalesContract.intRackPriceSupplyPointId, SalesContract.intSupplyPointId)
													ELSE NULL END
	, SupplyPoint.intTaxGroupId AS intInboundTaxGroupId
	, SupplyPoint.strTaxGroup AS strInboundTaxGroup
	, OutboundLocation.intTaxGroupId AS intOutboundTaxGroupId
	, OutboundTax.strTaxGroup AS strOutboundTaxGroup
FROM dbo.vyuLGLoadDetailView LG
LEFT JOIN vyuCTContractDetailView PurchaseContract ON PurchaseContract.intContractDetailId = LG.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SalesContract ON SalesContract.intContractDetailId = LG.intSContractDetailId
LEFT JOIN vyuTRSupplyPointView SupplyPoint ON SupplyPoint.intEntityLocationId = LG.intVendorEntityLocationId
LEFT JOIN tblEMEntityLocation OutboundLocation ON OutboundLocation.intEntityLocationId = LG.intCustomerEntityLocationId 
LEFT JOIN tblSMTaxGroup OutboundTax ON OutboundTax.intTaxGroupId = OutboundLocation.intTaxGroupId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = LG.intCustomerEntityId
WHERE (ISNULL(LG.ysnDispatched, 0) = 1)
	AND (ISNULL(LG.dblDeliveredQuantity, 0) <= 0)
	AND (LG.strType != 'Outbound')

UNION ALL

SELECT LG.intLoadId
	, LG.intLoadDetailId
	, LG.strLoadNumber
	, LG.strType
	, LG.intItemId
	, NULL AS intEntityVendorId
	, NULL AS intSupplyPointId
	, NULL AS intInboundCompanyLocationId
	, NULL AS intInboundContractDetailId
	, LG.dblQuantity AS dblInboundQuantiy
	, LG.dblSCashPrice AS dblInboundPrice
	, NULL AS strTerminalName
	, NULL AS strSupplyPoint
	, LG.strSLocationName strLocationName
	, LG.strItemNo AS strInboundItemNo
	, NULL AS intInboundContractNumber
	, LG.intCustomerEntityId AS intEntityCustomerId
	, LG.intSCompanyLocationId AS intOutboundCompanyLocationId
	, LG.intCustomerEntityLocationId AS intShipToLocationId
	, Customer.intSalespersonId AS intEntitySalespersonId
	, Customer.strCustomerNumber AS strCustomerNumber
	, (select strLocationName from tblSMCompanyLocation SM where SM.intCompanyLocationId = LG.intSCompanyLocationId) AS strOutboundLocationName
	, (select top 1 SP.strName from tblARCustomer AR Left Join vyuEMEntity SP on AR.intSalespersonId = SP.intEntityId where AR.intEntityCustomerId = LG.intCustomerEntityId) AS strOutboundSalespersonId
	, Customer.strLocationName AS strShipTo
	, LG.intItemId AS intOutboundItemId
	, LG.dblQuantity AS dblOutboundQuantity
	, LG.dblSCashPrice AS dblOutboundPrice
	, LG.strItemNo AS strOutboundItemNo
	, LG.strSContractNumber AS strOutboundContractNumber
	, LG.dtmScheduledDate
	, LG.dtmDispatchedDate
	, LG.intHaulerEntityId AS intShipViaId
	, (SELECT TOP 1 intSellerId FROM tblTRCompanyPreference) AS intSellerId
	, LG.intDriverEntityId AS intDriverId
	, LG.strTruckNo AS strTractor
	, LG.strTrailerNo1 AS strTrailer
	, LG.strHauler AS strShipVia
	, (SELECT TOP 1 EM.strName FROM tblTRCompanyPreference CP JOIN tblEMEntity EM ON CP.intSellerId = EM.intEntityId) AS strSeller
	, LG.strDriver AS strSalespersonId
	, LG.intSContractDetailId AS intOutboundContractDetailId
	, ysnDirectShip = CASE WHEN LG.intPurchaseSale = 3 THEN CAST(1 AS BIT)
						   ELSE CAST (0 AS BIT) END
	, LG.ysnInProgress
	, LG.intLoadId AS intOutboundLoadId
	, LG.strExternalLoadNumber AS strSupplierLoadNumber
	, NULL AS strInboundPricingType
	, SalesContract.strPricingType AS strOutboundPricingType
	, NULL AS dblInboundAdjustment
	, SalesContract.dblAdjustment AS dblOutboundAdjustment
	, (SELECT strZipPostalCode FROM dbo.tblSMCompanyLocation SM WHERE LG.intSCompanyLocationId = SM.intCompanyLocationId) AS strZipCode
	, NULL AS intRackPriceSupplyPointId
	, LG.intItemUOMId AS intItemUOMId
	, NULL AS strInboundIndexType
	, SalesContract.strIndexType AS strOutboundIndexType
	, NULL AS intInboundIndexRackPriceSupplyPointId
	, intOutboundIndexRackPriceSupplyPointId = CASE WHEN ISNULL(SalesContract.strIndexType, 0) = 'Fixed'
														THEN ISNULL(SalesContract.intRackPriceSupplyPointId, SalesContract.intSupplyPointId)
													ELSE NULL END
	, NULL AS intInboundTaxGroupId
	, NULL AS strInboundTaxGroup
	, OutboundLocation.intTaxGroupId AS intOutboundTaxGroupId
	, OutboundTax.strTaxGroup AS strOutboundTaxGroup
FROM dbo.vyuLGLoadDetailView LG
LEFT JOIN vyuCTContractDetailView PurchaseContract ON PurchaseContract.intContractDetailId = LG.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SalesContract ON SalesContract.intContractDetailId = LG.intSContractDetailId
LEFT JOIN tblEMEntityLocation OutboundLocation ON OutboundLocation.intEntityLocationId = LG.intCustomerEntityLocationId 
LEFT JOIN tblSMTaxGroup OutboundTax ON OutboundTax.intTaxGroupId = OutboundLocation.intTaxGroupId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = LG.intCustomerEntityId
WHERE (ISNULL(LG.ysnDispatched, 0) = 1)
	AND (ISNULL(LG.dblDeliveredQuantity, 0) <= 0)
	AND (LG.strType = 'Outbound')