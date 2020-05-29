CREATE VIEW vyuRKDPRRun
AS

SELECT DISTINCT 
	intRunNumber
	, dtmRunDateTime
	, u.strUserName
	, strCommodityCode
	, dtmDPRDate
	, strDPRPositionIncludes
	, strDPRPositionBy
	, strDPRPurchaseSale
	, strDPRVendorCustomer 
FROM tblRKTempDPRDetailLog dpr
inner join tblSMUserSecurity u ON u.intEntityId = dpr.intUserId
