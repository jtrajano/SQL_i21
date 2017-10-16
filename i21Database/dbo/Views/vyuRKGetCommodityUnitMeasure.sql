CREATE View vyuRKGetCommodityUnitMeasure
AS
SELECT convert(int,row_number() OVER(ORDER BY c.intCommodityId DESC)) RowNum, c.intCommodityId,c.strCommodityCode,um.intUnitMeasureId,ysnDefault,u.strUnitMeasure from tblICCommodity c
JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId
join tblICUnitMeasure u on u.intUnitMeasureId=um.intUnitMeasureId and ysnDefault=1