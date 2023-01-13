CREATE VIEW [dbo].[vyuTRDispatchedLoad]
	AS 

SELECT LG.intLoadId
	, LG.intLoadDetailId
	, strLoadNumber = CASE WHEN ISNULL(LG.strExternalLoadNumber, '') = '' THEN LG.strLoadNumber ELSE LG.strExternalLoadNumber END
	, LG.strType
	, LG.intItemId
	, intEntityVendorId = CASE WHEN (LG.strType != 'Outbound') THEN LG.intVendorEntityId
								ELSE NULL END
	, intSupplyPointId = CASE WHEN (LG.strType != 'Outbound') THEN SP.intSupplyPointId
								ELSE NULL END
	, intInboundCompanyLocationId = ISNULL(LG.intPCompanyLocationId, LG.intSCompanyLocationId) 
	, intInboundContractDetailId = CASE WHEN (LG.strType != 'Outbound') THEN LG.intPContractDetailId
											ELSE NULL END
	, dblInboundQuantiy = LG.dblQuantity
	, dblInboundPrice = CASE WHEN (LG.strType != 'Outbound') THEN ISNULL(CASE WHEN LG.dblPCashPrice IS NOT NULL OR LG.dblPCashPrice != 0
																			THEN LG.dblPCashPrice
																		WHEN LG.dblPCashPrice IS NULL OR LG.dblPCashPrice = 0
																			THEN [dbo].[fnTRGetRackPrice](LG.dtmScheduledDate, SP.intSupplyPointId, LG.intItemId,DEFAULT)
																		END, 0)
							WHEN LG.strType = 'Outbound' AND ISNULL(LG.dblSCashPrice, 0) = 0 THEN ItemS.dblReceiveLastCost 
							ELSE ISNULL(LG.dblSCashPrice, 0) END
	, strTerminalName = CASE WHEN (LG.strType != 'Outbound') THEN LG.strVendor
								ELSE NULL END
	, strSupplyPoint = LG.strShipFrom
	, strLocationName = CASE WHEN (LG.strType != 'Outbound') THEN LG.strPLocationName
								ELSE LG.strSLocationName END
	, strInboundItemNo = LG.strItemNo
	, strInboundContractNumber = CASE WHEN (LG.strType != 'Outbound') THEN LG.strPContractNumber
										ELSE NULL END
	, intEntityCustomerId = LG.intCustomerEntityId
	, intOutboundCompanyLocationId = ISNULL(LG.intSCompanyLocationId, LG.intPCompanyLocationId)
	, intShipToLocationId = LG.intCustomerEntityLocationId
	, intEntitySalespersonId = Customer.intSalespersonId
	, strCustomerNumber = Customer.strName
	, strOutboundLocationName = ISNULL(LG.strSLocationName, LG.strPLocationName)
	, strOutboundSalespersonId = ISNULL(LGSalesperson.strName, ISNULL(CLSalesperson.strName, CSalesperson.strName))
	, LG.strShipTo
	, intOutboundItemId = LG.intItemId
	, dblOutboundQuantity = ISNULL(LG.dblQuantity, 0.000000)
	, dblOutboundPrice = ISNULL(LG.dblSCashPrice, 0.000000)
	, strOutboundItemNo = LG.strItemNo
	, strOutboundContractNumber = LG.strSContractNumber
	, LG.dtmScheduledDate
	, LG.dtmDispatchedDate
	, dtmDeliveredDate = ISNULL(LG.dtmDeliveredDate, LG.dtmScheduledDate)
	, intShipViaId = CASE WHEN LG.intHaulerEntityId IS NULL THEN Config.intShipViaId ELSE LG.intHaulerEntityId END
	, Config.intSellerId
	, intDriverId = LG.intDriverEntityId
	, strDriver = LG.strDriver
	, strTractor = LG.strTruckNo
	, strTrailer = LG.strTrailerNo1
	, strShipVia = CASE WHEN LG.intHaulerEntityId IS NULL THEN ShipVia.strName ELSE LG.strHauler END 
	, strSeller = Seller.strName
	, strSalespersonId = LG.strDriver
	, intOutboundContractDetailId = LG.intSContractDetailId
	, ysnDirectShip = CASE WHEN LG.intPurchaseSale = 3
								THEN CAST(1 AS BIT)
							ELSE CAST (0 AS BIT) END
	, LG.ysnInProgress
	, intOutboundLoadId = LG.intLoadId
	, strSupplierLoadNumber = LG.strExternalLoadNumber
	, strZipCode = (CASE WHEN ISNULL(LG.intVendorEntityLocationId, '') <> '' THEN LG.strZipCode
						ELSE ReceiptLocation.strZipPostalCode END)
	, intRackPriceSupplyPointId = CASE WHEN (LG.strType != 'Outbound') THEN SP.intRackPriceSupplyPointId
										ELSE NULL END
	, LG.intItemUOMId
	, LG.strInboundPricingType
	, LG.strOutboundPricingType
	, LG.dblInboundAdjustment
	, LG.dblOutboundAdjustment
	, LG.strInboundIndexType
	, LG.strOutboundIndexType
	, LG.intInboundIndexRackPriceSupplyPointId 
	, LG.intOutboundIndexRackPriceSupplyPointId
	, LG.intInboundTaxGroupId
	, LG.strInboundTaxGroup
	, LG.intOutboundTaxGroupId
	, LG.strOutboundTaxGroup
	, dblDeliveredQuantity = ISNULL(LG.dblDeliveredQuantity, 0.000000)
	, ysnClosed = CASE WHEN (ISNULL(LG.dblDeliveredQuantity, 0.000000) <= 0) THEN CAST(0 AS BIT)
						ELSE CAST(1 AS BIT) END
	, LG.strTransUsedBy
	, ysnBrokered = CASE WHEN (Config.intSellerId IS NOT NULL AND (Config.intSellerId <> ISNULL(LG.intSellerId, 0))) THEN 1 ELSE 0 END
	, LG.intSalespersonId
	, intSiteId = LG.intTMSiteId
	, intSiteNumber = TS.intSiteNumber
	, strSupplyPointGrossOrNet = SP.strGrossOrNet
	, strSaleUnits = CEL.strSaleUnits
	, strFreightSalesUnit = SP.strFreightSalesUnit
	, LG.intTMDispatchId  
	, LG.strOrderNumber  
FROM vyuLGLoadDetailView LG
LEFT JOIN tblSMCompanyLocation ReceiptLocation ON ReceiptLocation.intCompanyLocationId = ISNULL(LG.intPCompanyLocationId, LG.intSCompanyLocationId)
LEFT JOIN tblTRCompanyPreference Config ON Config.intCompanyPreferenceId = Config.intCompanyPreferenceId
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = Config.intSellerId
LEFT JOIN tblEMEntity ShipVia ON ShipVia.intEntityId = Config.intShipViaId
LEFT JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = LG.intVendorEntityLocationId AND SP.intEntityVendorId = LG.intVendorEntityId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityId = LG.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LG.intCustomerEntityLocationId
LEFT JOIN vyuEMEntity LGSalesperson ON LGSalesperson.intEntityId = LG.intSalespersonId AND LGSalesperson.strType = 'Salesperson'
LEFT JOIN vyuEMEntity CSalesperson ON CSalesperson.intEntityId = Customer.intSalespersonId AND CSalesperson.strType = 'Salesperson'
LEFT JOIN vyuEMEntity CLSalesperson ON CLSalesperson.intEntityId = CEL.intSalespersonId AND CLSalesperson.strType = 'Salesperson'
LEFT JOIN vyuICGetItemStock ItemS ON ItemS.intItemId = LG.intItemId AND ItemS.intLocationId = LG.intSCompanyLocationId
LEFT JOIN tblTMSite TS ON LG.intTMSiteId = TS.intSiteID
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LG.intCustomerEntityLocationId
WHERE ISNULL(LG.ysnDispatched, 0) = 1