CREATE VIEW vyuQMSearchCommodityProductLine
AS
SELECT intCommodityId				= C.intCommodityId
	 , intCommodityProductLineId	= CPL.intCommodityProductLineId
	 , strDescription				= CPL.strDescription
	 , strCommodityCode				= C.strCommodityCode
FROM tblICCommodity C
INNER JOIN tblICCommodityProductLine CPL ON C.intCommodityId = CPL.intCommodityId