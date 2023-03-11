CREATE VIEW [dbo].[vyuMFLocationLeadTime]  
AS  
SELECT intLocationLeadTimeId
	 , intOriginId
	 , strOrigin
	 , intBuyingCenterId
	 , strBuyingCenter = CompanyLocation.strLocationName
	 , intReceivingPlantId
	 , strReceivingPlant
	 , intReceivingStorageLocation
	 , strReceivingStorageLocation = SubLocation.strSubLocationName
	 , intChannelId
	 , strChannel = MarketZone.strMarketZoneCode
	 , intPortOfDispatchId
	 , strPortOfDispatch
	 , intPortOfArrivalId
	 , strPortOfArrival
	 , dblPurchaseToShipment
	 , dblPortToPort
	 , dblPortToMixingUnit
	 , dblMUToAvailableForBlending
	 , intEntityId = LeadTime.intEntityId
	 , strShippingLine
	 , strOriginCode = C.strISOCode
	 , strReceivingPlantCode = RP.strOregonFacilityNumber
	 , strPortOfDispatchCity = D.strVAT
	 , strPortOfArrivalCity	= A.strVAT
FROM tblMFLocationLeadTime AS LeadTime
INNER JOIN tblSMCompanyLocation AS CompanyLocation ON LeadTime.intBuyingCenterId = CompanyLocation.intCompanyLocationId
INNER JOIN tblSMCompanyLocationSubLocation AS SubLocation ON SubLocation.intCompanyLocationSubLocationId=LeadTime.intReceivingStorageLocation
INNER JOIN tblARMarketZone AS MarketZone ON MarketZone.intMarketZoneId=LeadTime.intChannelId
INNER JOIN tblSMCompanyLocation RP ON LeadTime.intReceivingPlantId = RP.intCompanyLocationId
INNER JOIN tblSMCountry C ON LeadTime.intOriginId = C.intCountryID
INNER JOIN tblSMCity D ON LeadTime.intPortOfDispatchId = D.intCityId
INNER JOIN tblSMCity A ON LeadTime.intPortOfArrivalId = A.intCityId