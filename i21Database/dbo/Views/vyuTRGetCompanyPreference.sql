CREATE VIEW [dbo].[vyuTRGetCompanyPreference]
	AS 

SELECT CP.intCompanyPreferenceId
	, CP.intItemForFreightId
	, strItemForFreight = FreightItem.strItemNo
	, CP.intSurchargeItemId
	, strSurchargeItem = SurchargeItem.strItemNo
	, CP.intShipViaId
	, strShipVia = ShipVia.strShipVia
	, CP.intSellerId
	, strSeller = Seller.strShipVia
	, CP.strRackPriceToUse
    , CP.ysnItemizeSurcharge
	, CP.intFreightCostAllocationMethod
	, strFreightCostAllocationMethod = (CASE WHEN CP.intFreightCostAllocationMethod = 1 THEN 'Bulk Plant Loads Only'
											WHEN CP.intFreightCostAllocationMethod = 2 THEN 'All Loads'
											WHEN CP.intFreightCostAllocationMethod = 3 THEN 'No Load'
											ELSE NULL END)
	, CP.intRackPriceImportMappingId
	, strRackPriceImportMapping = Import.strLayoutTitle
    , CP.ysnImportSupplyPoint
    , CP.ysnImportTrucks
	, CP.intConcurrencyId
FROM tblTRCompanyPreference CP
LEFT JOIN tblSMImportFileHeader Import on Import.intImportFileHeaderId = CP.intRackPriceImportMappingId
LEFT JOIN tblSMShipVia ShipVia on ShipVia.intEntityId = CP.intShipViaId
LEFT JOIN tblSMShipVia Seller on Seller.intEntityId = CP.intSellerId
LEFT JOIN tblICItem FreightItem on FreightItem.intItemId = CP.intItemForFreightId
LEFT JOIN tblICItem SurchargeItem on SurchargeItem.intItemId = CP.intSurchargeItemId