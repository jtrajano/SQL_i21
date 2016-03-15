CREATE View vyuRKGetCommodityUnitMeasure
AS
SELECT convert(int,row_number() OVER(ORDER BY c.intCommodityId DESC)) RowNum, c.intCommodityId,c.strCommodityCode,intUnitMeasureId,ysnDefault from tblICCommodity c
JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId