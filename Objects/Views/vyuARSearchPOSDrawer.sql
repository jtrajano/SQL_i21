CREATE VIEW [dbo].[vyuARSearchPOSDrawer]
AS 
SELECT  intPOSId = POS.intPOSId
		, intPOSLogId = POS.intPOSLogId
		, strReceiptNumber = POS.strReceiptNumber
		, intCompanyLocationId = DRAW.intCompanyLocationId
		, intCompanyLocationPOSDrawerId = DRAW.intCompanyLocationPOSDrawerId
		, strPOSDrawerName = DRAW.strPOSDrawerName 
FROM tblARPOS POS WITH (NOLOCK)
INNER JOIN tblARPOSLog LOGs ON POS.intPOSLogId = LOGs.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON LOGs.intPOSEndOfDayId = EOD.intPOSEndOfDayId
INNER JOIN tblSMCompanyLocationPOSDrawer DRAW ON EOD.intCompanyLocationPOSDrawerId = DRAW.intCompanyLocationPOSDrawerId