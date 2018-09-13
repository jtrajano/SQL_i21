CREATE PROC [dbo].[uspRKSourcingReport] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,           
       @ysnVendorProducer bit = null,
	   @intBookId int = null,
	   @intSubBookId int = null,
	    @strYear nvarchar(10) = null,
	   @dtmAOPFromDate datetime = null,
	   @dtmAOPToDate datetime = null,	
	   @intCurrencyId int = null

AS 


DECLARE @GetStandardQty AS TABLE(
		intRowNum int,
		intContractDetailId int,
		strEntityName nvarchar(max),
		intContractHeaderId int,
		strContractSeq nvarchar(100),
		dblQty numeric(24,10),
		dblReturnQty numeric(24,10),
		dblBalanceQty numeric(24,10),
		dblNoOfLots numeric(24,10),
		dblFuturesPrice numeric(24,10),
		dblSettlementPrice numeric(24,10),
		dblBasis numeric(24,10),
		dblRatio numeric(24,10),
		dblPrice numeric(24,10),
		dblTotPurchased numeric(24,10), 
		dblStandardRatio  numeric(24,10),
		dblStandardQty  numeric(24,10),
		intItemId  int,
		dblStandardPrice  numeric(24,10),
		dblPPVBasis  numeric(24,10),
		dblNewPPVPrice  numeric(24,10),
		dblStandardValue numeric(24,10),
		dblPPV numeric(24,10),
		dblPPVNew numeric(24,10),
		strLocationName nvarchar(100),
		strPricingType nvarchar(100),
		strItemNo nvarchar(100),
		strProductType nvarchar(100),
		strCurrency nvarchar(100),
		strUnitMeasure nvarchar(100)
		)

insert into @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,
							dblNoOfLots,dblFuturesPrice,dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased, dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,strLocationName,dblNewPPVPrice,dblStandardValue,dblPPV,dblPPVNew,strPricingType,strItemNo,strProductType,strCurrency,strUnitMeasure)

exec [uspRKSourcingReportDetail] @dtmFromDate = @dtmFromDate,
       @dtmToDate = @dtmToDate,
       @intCommodityId  = @intCommodityId,
       @intUnitMeasureId = @intUnitMeasureId ,
	   @strEntityName  = null,
       @ysnVendorProducer = @ysnVendorProducer,
	   @intBookId = @intBookId,
	   @intSubBookId  = @intSubBookId,	   
	   @strYear=@strYear,@dtmAOPFromDate=@dtmAOPFromDate,@dtmAOPToDate=@dtmAOPToDate,
	   @strLocationName='',
	   @intCurrencyId=@intCurrencyId

	   
select  CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,1 as intConcurrencyId,* from(
SELECT strEntityName strName,strLocationName,sum(dblBalanceQty) dblQty,sum(dblTotPurchased) dblTotPurchased,
(sum(dblTotPurchased)/SUM(CASE WHEN isnull(sum(dblTotPurchased),0)=0 then 1 else sum(dblTotPurchased) end) OVER ())*100 dblCompanySpend,sum(dblStandardQty) dblStandardQty
FROM @GetStandardQty
GROUP BY strEntityName,strEntityName,strLocationName)ty