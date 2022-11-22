CREATE VIEW [dbo].[vyuQMSearchCommodityAttribute2]
	AS 
SELECT intCommodityAttributeId2	= CA.intCommodityAttributeId2
	 , intCommodityId			= C.intCommodityId
	 , strAttribute2			= CA.strAttribute2
FROM tblICCommodityAttribute2 CA	
INNER JOIN tblICCommodity C ON C.intCommodityId = CA.intCommodityId
