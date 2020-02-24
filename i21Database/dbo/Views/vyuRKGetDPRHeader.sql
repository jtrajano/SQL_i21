CREATE VIEW [dbo].[vyuRKGetDPRHeader]

AS
	
SELECT H.intDPRHeaderId
	, H.imgReportId
	, H.strPositionIncludes
	, H.strPositionBy
	, H.dtmEndDate
	, H.ysnVendorCustomerPosition
	, H.strPurchaseSale
	, H.intEntityId
	, E.strName
	, H.intCommodityId
	, strCommodity = C.strCommodityCode
	, H.intItemId
	, I.strItemNo
	, strItemDescription = I.strDescription
	, H.intLocationId
	, CL.strLocationName
	, H.ysnCrush
	, H.intConcurrencyId
FROM tblRKDPRHeader H
LEFT JOIN tblEMEntity E ON E.intEntityId = H.intEntityId
LEFT JOIN tblICCommodity C ON C.intCommodityId = H.intCommodityId
LEFT JOIN tblICItem I ON I.intItemId = H.intItemId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = H.intLocationId