CREATE VIEW vyuQMGetOriginCountries
AS
SELECT CA.intCountryID AS CountryId
	,CA.strDescription AS Country
FROM tblICCommodity C
JOIN tblICCommodityAttribute CA ON CA.intCommodityId = C.intCommodityId
	AND CA.strType = 'Origin'
	AND C.strCommodityCode = 'Coffee'
