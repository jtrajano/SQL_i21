CREATE VIEW [dbo].[vyuTRDispatchedLoad]
	AS 

SELECT LG.intLoadId
	, LG.intLoadDetailId
	, strLoadNumber = ISNULL(LG.strExternalLoadNumber, LG.strLoadNumber)
	, LG.strType
	, LG.intItemId
	, intEntityVendorId = CASE WHEN (LG.strType != 'Outbound') THEN LG.intVendorEntityId
								ELSE NULL END
	, intSupplyPointId = CASE WHEN (LG.strType != 'Outbound') THEN SP.intSupplyPointId
								ELSE NULL END
	, intInboundCompanyLocationId = CASE WHEN (LG.strType != 'Outbound') THEN LG.intPCompanyLocationId
											ELSE NULL END
	, intInboundContractDetailId = CASE WHEN (LG.strType != 'Outbound') THEN LG.intPContractDetailId
											ELSE NULL END
	, dblInboundQuantiy = LG.dblQuantity
	, dblInboundPrice = CASE WHEN (LG.strType != 'Outbound') THEN ISNULL(CASE WHEN LG.dblPCashPrice IS NOT NULL OR LG.dblPCashPrice != 0
																			THEN LG.dblPCashPrice
																		WHEN LG.dblPCashPrice IS NULL OR LG.dblPCashPrice = 0
																			THEN [dbo].[fnTRGetRackPrice](LG.dtmScheduledDate, SP.intSupplyPointId, LG.intItemId)
																		END, 0)
							ELSE ISNULL(LG.dblSCashPrice, 0) END
	, strTerminalName = CASE WHEN (LG.strType != 'Outbound') THEN LG.strVendor
								ELSE NULL END
	, strSupplyPoint = CASE WHEN (LG.strType != 'Outbound') THEN VendorLocation.strLocationName
								ELSE NULL END
	, strLocationName = CASE WHEN (LG.strType != 'Outbound') THEN LG.strPLocationName
								ELSE LG.strSLocationName END
	, strInboundItemNo = Item.strItemNo
	, strInboundContractNumber = CASE WHEN (LG.strType != 'Outbound') THEN LG.strPContractNumber
										ELSE NULL END
	, intEntityCustomerId = LG.intCustomerEntityId
	, intOutboundCompanyLocationId = CASE WHEN (LG.strType != 'Outbound') THEN ISNULL(LG.intSCompanyLocationId, LG.intPCompanyLocationId)
											ELSE LG.intSCompanyLocationId END
	, intShipToLocationId = LG.intCustomerEntityLocationId
	, intEntitySalespersonId = Customer.intSalespersonId
	, strCustomerNumber = Customer.strName
	, strOutboundLocationName = Location.strLocationName
	, strOutboundSalespersonId = Salesperson.strName
	, strShipTo = CASE WHEN (LG.strType != 'Outbound') THEN LG.strShipTo
						ELSE CustomerLocation.strLocationName END
	, intOutboundItemId = LG.intItemId
	, dblOutboundQuantity = ISNULL(LG.dblQuantity, 0)
	, dblOutboundPrice = ISNULL(LG.dblSCashPrice, 0)
	, strOutboundItemNo = Item.strItemNo
	, strOutboundContractNumber = LG.strSContractNumber
	, LG.dtmScheduledDate
	, LG.dtmDispatchedDate
	, dtmDeliveredDate = ISNULL(LG.dtmDeliveredDate, LG.dtmScheduledDate)
	, intShipViaId = LG.intHaulerEntityId
	, Config.intSellerId
	, intDriverId = LG.intDriverEntityId
	, strTractor = LG.strTruckNo
	, strTrailer = LG.strTrailerNo1
	, strShipVia = LG.strHauler
	, strSeller = Seller.strName
	, strSalespersonId = LG.strDriver
	, intOutboundContractDetailId = LG.intSContractDetailId
	, ysnDirectShip = CASE WHEN LG.intPurchaseSale = 3
								THEN CAST(1 AS BIT)
							ELSE CAST (0 AS BIT) END
	, LG.ysnInProgress
	, intOutboundLoadId = LG.intLoadId
	, strSupplierLoadNumber = LG.strExternalLoadNumber
	, strInboundPricingType = CASE WHEN (LG.strType != 'Outbound') THEN PurchaseContract.strPricingType
									ELSE NULL END
	, strOutboundPricingType = SalesContract.strPricingType
	, dblInboundAdjustment = ISNULL(CASE WHEN (LG.strType != 'Outbound') THEN PurchaseContract.dblAdjustment
									ELSE NULL END, 0)
	, dblOutboundAdjustment = ISNULL(SalesContract.dblAdjustment, 0)
	, strZipCode = VendorLocation.strZipCode
	, intRackPriceSupplyPointId = CASE WHEN (LG.strType != 'Outbound') THEN SP.intRackPriceSupplyPointId
										ELSE NULL END
	, intItemUOMId = ItemUOM.intItemUOMId
	, strInboundIndexType = CASE WHEN (LG.strType != 'Outbound') THEN PurchaseContract.strIndexType
									ELSE NULL END
	, strOutboundIndexType = SalesContract.strIndexType
	, intInboundIndexRackPriceSupplyPointId = CASE WHEN (LG.strType != 'Outbound') THEN (CASE WHEN ISNULL(PurchaseContract.strIndexType, 0) = 'Fixed'
																								THEN ISNULL(PurchaseContract.intRackPriceSupplyPointId, PurchaseContract.intSupplyPointId)
																							WHEN ISNULL(PurchaseContract.strIndexType, 0) != 'Fixed'
																								THEN NULL
																							END)
													ELSE NULL END
	, intOutboundIndexRackPriceSupplyPointId  = CASE WHEN ISNULL(SalesContract.strIndexType, 0) = 'Fixed'
														THEN ISNULL(SalesContract.intRackPriceSupplyPointId, SalesContract.intSupplyPointId)
													WHEN ISNULL(SalesContract.strIndexType, 0) != 'Fixed'
														THEN NULL
													END
	, intInboundTaxGroupId = CASE WHEN (LG.strType != 'Outbound') THEN SP.intTaxGroupId
									ELSE NULL END
	, strInboundTaxGroup = CASE WHEN (LG.strType != 'Outbound') THEN VendorTax.strTaxGroup
								ELSE NULL END
	, intOutboundTaxGroupId = CustomerLocation.intTaxGroupId
	, strOutboundTaxGroup = CustomerTax.strTaxGroup
FROM vyuLGLoadDetailView LG
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = ISNULL(LG.intSCompanyLocationId, LG.intPCompanyLocationId)
LEFT JOIN tblTRCompanyPreference Config ON Config.intCompanyPreferenceId = Config.intCompanyPreferenceId
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = Config.intSellerId
LEFT JOIN tblICItem Item ON Item.intItemId = LG.intItemId
CROSS APPLY (SELECT TOP 1 * FROM tblICItemUOM WHERE tblICItemUOM.intItemId = LG.intItemId ORDER BY tblICItemUOM.ysnStockUnit DESC) ItemUOM
LEFT JOIN vyuCTContractDetailView PurchaseContract ON PurchaseContract.intContractDetailId = LG.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SalesContract ON SalesContract.intContractDetailId = LG.intSContractDetailId
LEFT JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = LG.intVendorEntityLocationId AND SP.intEntityVendorId = LG.intVendorEntityId
LEFT JOIN tblEMEntityLocation VendorLocation ON VendorLocation.intEntityLocationId = LG.intVendorEntityLocationId
LEFT JOIN tblSMTaxGroup VendorTax ON VendorTax.intTaxGroupId = VendorLocation.intTaxGroupId
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityCustomerId = LG.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CustomerLocation ON CustomerLocation.intEntityLocationId = LG.intCustomerEntityLocationId
LEFT JOIN tblSMTaxGroup CustomerTax ON CustomerTax.intTaxGroupId = CustomerLocation.intTaxGroupId
LEFT JOIN vyuEMEntity Salesperson ON Salesperson.intEntityId = Customer.intSalespersonId AND Salesperson.strType = 'Salesperson'
WHERE ISNULL(LG.ysnDispatched, 0) = 1
	AND ISNULL(LG.dblDeliveredQuantity, 0) <= 0