CREATE VIEW vyuQMSearchCommodityAttribute
AS
SELECT intCommodityId			= C.intCommodityId
	 , intCommodityAttributeId	= CA.intCommodityAttributeId
	 , strType					= CA.strType
	 , strDescription			= CA.strDescription
	 , strCommodityCode			= C.strCommodityCode
	 , intCountryId				= COUNTRY.intCountryID
	 , strCountry				= COUNTRY.strCountry
FROM tblICCommodity C
INNER JOIN tblICCommodityAttribute CA ON C.intCommodityId = CA.intCommodityId
OUTER APPLY (
	SELECT C.intCountryID
		 , C.strCountry
	FROM tblSMCountry C
	WHERE CA.strType = 'Origin'
	  AND CA.strDescription = C.strCountry
) COUNTRY
WHERE CA.strType IN ('Origin', 'ProductType', 'Grade')