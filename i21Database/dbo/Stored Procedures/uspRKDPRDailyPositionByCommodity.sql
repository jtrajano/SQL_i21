CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodity] 
	 @intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@dtmToDate datetime = NULL
	,@strByType nvarchar(50)
AS
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
DECLARE @FinalTable AS TABLE (
		 strCommodityCode NVARCHAR(200),
		 strUnitMeasure NVARCHAR(200),
		 strSeqHeader NVARCHAR(200),		 
		 dblTotal  numeric(24,10),
		 intCommodityId int		 	
)

INSERT INTO @FinalTable(strCommodityCode,strUnitMeasure,strSeqHeader,dblTotal,intCommodityId)
exec uspRKDPRHedgeDailyPositionDetail  @intCommodityId= '',@intLocationId = 0,@intVendorId = @intVendorId,@strPurchaseSales = 'Purchase',@strPositionIncludes =@strPositionIncludes,@dtmToDate =  @dtmToDate,@strByType='ByCommodity'

INSERT INTO @FinalTable(strCommodityCode,strUnitMeasure,strSeqHeader,dblTotal,intCommodityId)
exec uspRKDPRInvDailyPositionDetail  @intCommodityId= '',@intLocationId = 0,@intVendorId = @intVendorId,@strPurchaseSales = 'Purchase',@strPositionIncludes =@strPositionIncludes,@dtmToDate =  @dtmToDate,@strByType='ByCommodity'

SELECT distinct strCommodityCode,strUnitMeasure,intCommodityId,
(SELECT distinct sum(dblTotal) dblInHouse FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='In-House' and t.strCommodityCode=f.strCommodityCode ) dblInHouse,
	(SELECT sum(dblTotal) dblCompanyTitled FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Company Titled Stock' and t.strCommodityCode=f.strCommodityCode ) dblCompanyTitled,
	(SELECT sum(dblTotal) dblCaseExposure FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Price Risk'  and t.strCommodityCode=f.strCommodityCode) dblCaseExposure,
	(SELECT sum(dblTotal) dblBasisExposure FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Basis Risk' and t.strCommodityCode=f.strCommodityCode  ) dblBasisExposure,
	(SELECT sum(dblTotal) dblAvailForSale FROM @FinalTable t WHERE ROUND(dblTotal,0) <> 0 AND strSeqHeader='Avail for Spot Sale' and t.strCommodityCode=f.strCommodityCode ) dblAvailForSale
 FROM @FinalTable f