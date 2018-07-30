CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityLocation] 
	 @intCommodityId NVARCHAR(max) = ''
	,@intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@dtmToDate datetime = NULL
	,@strByType nvarchar(50) = null
AS
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
DECLARE @FinalTable AS TABLE (
		 strCommodityCode NVARCHAR(200),
		 strUnitMeasure NVARCHAR(200),
		 strSeqHeader NVARCHAR(200),		 
		 dblTotal  numeric(24,10),
		 intCommodityId int,
		 intLocationId int,
		 strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS		 	
)

INSERT INTO @FinalTable(strCommodityCode,strUnitMeasure,strSeqHeader,dblTotal,intCommodityId,strLocationName)
exec uspRKDPRSubHedgePositionByCommodity  @intCommodityId= @intCommodityId,@intLocationId = 0,@intVendorId = @intVendorId,@strPurchaseSales = 'Purchase',@strPositionIncludes =@strPositionIncludes,@dtmToDate =  @dtmToDate,@strByType='ByLocation'

INSERT INTO @FinalTable(strCommodityCode,strUnitMeasure,strSeqHeader,dblTotal,intCommodityId,strLocationName)
exec uspRKDPRSubInvPositionByCommodity  @intCommodityId= @intCommodityId,@intLocationId = 0,@intVendorId = @intVendorId,@strPurchaseSales = 'Purchase',@strPositionIncludes =@strPositionIncludes,@dtmToDate =  @dtmToDate,@strByType='ByLocation'

select  CONVERT(int,ROW_NUMBER() OVER(ORDER BY strCommodityCode ASC)) AS intRowNum,* from(
SELECT distinct strCommodityCode,strUnitMeasure,intCommodityId,f.strLocationName,l.intCompanyLocationId intLocationId,
(SELECT distinct sum(dblTotal) dblInHouse FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='In-House' and t.intCommodityId=f.intCommodityId and  t.strLocationName=f.strLocationName  ) dblInHouse,
	(SELECT distinct  sum(dblTotal) dblCompanyTitled FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Company Titled Stock' and t.intCommodityId=f.intCommodityId and t.strLocationName=f.strLocationName ) dblCompanyTitled,
	(SELECT distinct sum(dblTotal) dblCaseExposure FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Price Risk'  and t.intCommodityId=f.intCommodityId and t.strLocationName=f.strLocationName ) dblCaseExposure,
	(SELECT distinct sum(dblTotal) dblBasisExposure FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Basis Risk' and t.intCommodityId=f.intCommodityId and t.strLocationName=f.strLocationName  ) dblBasisExposure,
	(SELECT distinct sum(dblTotal) dblAvailForSale FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Avail for Spot Sale' and t.intCommodityId=f.intCommodityId and t.strLocationName=f.strLocationName ) dblAvailForSale
 FROM @FinalTable f
 join tblSMCompanyLocation l on f.strLocationName=l.strLocationName) t
