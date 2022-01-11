CREATE VIEW [dbo].[vyuTRGetCompanyPreference]
	AS 

SELECT CP.intCompanyPreferenceId
	, CP.intItemForFreightId
	, strItemForFreight = FreightItem.strItemNo
	, strCostMethodFreight = FreightItem.strCostMethod
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
											ELSE NULL END) COLLATE Latin1_General_CI_AS
	, CP.intRackPriceImportMappingId
	, strRackPriceImportMapping = Import.strLayoutTitle
	, strBolImportFormat = ImportBol.strLayoutTitle
	, strRackPriceImportFormat = ImportRack.strLayoutTitle
    , CP.ysnImportSupplyPoint
    , CP.ysnImportTrucks
	, CP.intBolImportFormatId
	, CP.strBolImportReceivingFolder
	, CP.strBolImportProcessingFolder
	, CP.strBolImportArchiveFolder
	, CP.strBolImageImportReceivingFolder
	, CP.strBolImageImportProcessingFolder
	, CP.intRackPriceImportFormatId
	, CP.strRackPriceImportReceivingFolder
	, CP.strRackPriceImportProcessingFolder
	, CP.strRackPriceImportArchiveFolder
	, CP.intConcurrencyId
	, CP.ysnFreightInRequired
	, CP.ysnComboFreight
FROM tblTRCompanyPreference CP
LEFT JOIN tblSMImportFileHeader Import on Import.intImportFileHeaderId = CP.intRackPriceImportMappingId
LEFT JOIN tblSMImportFileHeader ImportBol ON ImportBol.intImportFileHeaderId = CP.intBolImportFormatId 
LEFT JOIN tblSMImportFileHeader ImportRack ON ImportRack.intImportFileHeaderId = CP.intRackPriceImportFormatId
LEFT JOIN tblSMShipVia ShipVia on ShipVia.intEntityId = CP.intShipViaId
LEFT JOIN tblSMShipVia Seller on Seller.intEntityId = CP.intSellerId
LEFT JOIN tblICItem FreightItem on FreightItem.intItemId = CP.intItemForFreightId
LEFT JOIN tblICItem SurchargeItem on SurchargeItem.intItemId = CP.intSurchargeItemId