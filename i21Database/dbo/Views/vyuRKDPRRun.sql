CREATE VIEW vyuRKDPRRun
AS

SELECT 
	intRunNumber
	, dtmRunDateTime
	, u.strUserName
	, strCommodityCode
	, dtmDPRDate
	, strDPRPositionIncludes
	, strDPRPositionBy
	, strDPRPurchaseSale
	, strDPRVendorCustomer 
FROM tblRKDPRRunLog dpr
INNER JOIN tblSMUserSecurity u ON u.intEntityId = dpr.intUserId
