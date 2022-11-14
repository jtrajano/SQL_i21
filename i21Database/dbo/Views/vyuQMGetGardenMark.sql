CREATE VIEW vyuQMGetGardenMark
AS
SELECT intGardenMarkId		= GM.intGardenMarkId
	 , intConcurrencyId		= GM.intConcurrencyId
     , strGardenMark		= GM.strGardenMark
	 , intOriginId			= GM.intOriginId
	 , strOrigin			= O.strDescription
	 , intCountryId			= GM.intCountryId
	 , strCountry			= C.strCountry
	 , intProducerId		= GM.intProducerId
	 , strProducer			= P.strName
	 , intProductLineId		= GM.intProductLineId
	 , strProductLine		= PL.strDescription
     , dtmCertifiedDate		= GM.dtmCertifiedDate
	 , dtmExpiryDate		= GM.dtmExpiryDate
FROM tblQMGardenMark GM
LEFT JOIN tblICCommodityAttribute O ON GM.intOriginId = O.intCommodityAttributeId AND O.strType = 'Origin'
LEFT JOIN tblSMCountry C ON GM.intCountryId = C.intCountryID
LEFT JOIN tblEMEntity P ON GM.intProducerId = P.intEntityId
LEFT JOIN tblICCommodityProductLine PL ON GM.intProductLineId = PL.intCommodityProductLineId