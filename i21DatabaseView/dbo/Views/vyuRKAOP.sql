CREATE VIEW vyuRKAOP
	
AS

SELECT CAST(ROW_NUMBER() OVER (ORDER BY intCommodityId) AS INT) as intRowNum,*,1 as intConcurrencyId from(
SELECT DISTINCT strYear,dtmFromDate,dtmToDate,intCommodityId  
FROM tblCTAOP)t