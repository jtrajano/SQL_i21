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
	 , strReceivingPlantCode = CompanyLocation.strLocationNumber
	 , strPortOfDispatchCity = D.strCity
	 , strPortOfArrivalCity	= A.strCity
FROM tblMFLocationLeadTime AS LeadTime
INNER JOIN tblSMCompanyLocation AS CompanyLocation ON LeadTime.intBuyingCenterId = CompanyLocation.intCompanyLocationId
INNER JOIN tblSMCompanyLocationSubLocation AS SubLocation ON SubLocation.intCompanyLocationSubLocationId=LeadTime.intReceivingStorageLocation
INNER JOIN tblARMarketZone AS MarketZone ON MarketZone.intMarketZoneId=LeadTime.intChannelId
LEFT JOIN tblSMCountry C ON LeadTime.intOriginId = C.intCountryID
LEFT JOIN tblSMCity D ON LeadTime.intPortOfDispatchId = D.intCityId
LEFT JOIN tblSMCity A ON LeadTime.intPortOfArrivalId = A.intCityId