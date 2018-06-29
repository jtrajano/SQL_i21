CREATE VIEW [dbo].[vyuGRStorageScheduleRuleNotMapped]
AS
SELECT
 intStorageScheduleRuleId       = S.intStorageScheduleRuleId
,intCommodity			        = S.intCommodity
,strCommodityCode		        = Com.strCommodityCode	
,intCurrencyID			        = S.intCurrencyID
,strCurrency			        = Cur.strCurrency
,ysnDPOwnedType			        = ST.ysnDPOwnedType
,intUnitMeasureId		        = S.intUnitMeasureId
,strUnitMeasure			        = UOM.strUnitMeasure
FROM tblGRStorageScheduleRule S
JOIN tblGRStorageType ST       ON ST.intStorageScheduleTypeId = S.intStorageType
JOIN tblICCommodity   Com      ON Com.intCommodityId		  = S.intCommodity
JOIN tblSMCurrency    Cur      ON Cur.intCurrencyID			  = S.intCurrencyID
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId	      = S.intUnitMeasureId