CREATE VIEW [dbo].[vyuTRGetBulkPlantFreight]
	AS

SELECT Detail.intBulkPlantFreightId
	, Detail.intCompanyLocationId
	, Location.strLocationName
	, Detail.strZipCode
	, Detail.intCategoryId
	, strCategory = Category.strCategoryCode
	, Detail.strFreightType
	, Detail.intShipViaId
	, ShipVia.strShipVia
	, Detail.dblFreightAmount
	, Detail.dblFreightRate
	, Detail.dblFreightMiles
	, Detail.dblMinimumUnits
	, Detail.intEntityTariffTypeId
	, Tariff.strTariffType
FROM tblTRBulkPlantFreight Detail
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Detail.intCompanyLocationId
LEFT JOIN tblICCategory Category ON Category.intCategoryId = Detail.intCategoryId
LEFT JOIN vyuEMSearchShipVia ShipVia ON ShipVia.[intEntityId] = Detail.intShipViaId
LEFT JOIN tblEMEntityTariffType Tariff ON Tariff.intEntityTariffTypeId = Detail.intEntityTariffTypeId