CREATE VIEW [dbo].[vyuQMSearchCommodityAttributeAuction]
	AS 
SELECT intCommodityAttributeId	= CA.intCommodityAttributeId
	 , intCommodityId			= C.intCommodityId
	 , strDescription			= CA.strDescription
	 , strType					= CA.strType
FROM tblICCommodity C
INNER JOIN tblICCommodityAttribute CA ON C.intCommodityId = CA.intCommodityId
