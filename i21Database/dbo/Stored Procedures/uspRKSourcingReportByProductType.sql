CREATE PROC [dbo].[uspRKSourcingReportByProductType] 
       @dtmFromDate DATETIME = NULL,
       @dtmToDate DATETIME = NULL,
       @intCommodityId int = NULL,
       @intUnitMeasureId int = NULL,
       @ysnVendorProducer bit = null,
	   	   @intBookId int = null,
	   @intSubBookId int = null,
	   @intAOPId int = null

AS

DECLARE @QtyByVendor AS TABLE(
		intRowNum int,	
		strName nvarchar(max),	
		strOrigin nvarchar(max),	
		strProductType nvarchar(max),	
		dblQty numeric(24,10),
		dblTotPurchased numeric(24,10),
		intConcurrencyId int,
		dblCompanySpend numeric(24,10),
		intCompanyLocationId int	 					
		)

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
		strOrigin nvarchar(100),
		strProductType nvarchar(100),
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
		strPricingType  nvarchar(100),
		strItemNo  nvarchar(100)
		)

INSERT INTO @GetStandardQty(intRowNum,intContractDetailId,strEntityName,intContractHeaderId,strContractSeq,dblQty,dblReturnQty,dblBalanceQty,dblNoOfLots,dblFuturesPrice,
							dblSettlementPrice,dblBasis,dblRatio,dblPrice,dblTotPurchased,strOrigin,strProductType,	dblStandardRatio,dblStandardQty,intItemId,
							dblStandardPrice,dblPPVBasis,strLocationName,dblNewPPVPrice,dblStandardValue,dblPPV,dblPPVNew,strPricingType,strItemNo)

EXEC [uspRKSourcingReportByProductTypeDetail] @dtmFromDate = @dtmFromDate,
       @dtmToDate = @dtmToDate,
       @intCommodityId  = @intCommodityId,
       @intUnitMeasureId = @intUnitMeasureId ,
	   @strEntityName  = null,
       @ysnVendorProducer = @ysnVendorProducer,
	   @strProductType= null,
	   @strOrigin = null,
	   @intBookId = @intBookId,
	   @intSubBookId  = @intSubBookId,
	   @intAOPId= @intAOPId,
	   @strLocationName=''


select  CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT) as intRowNum,1 as intConcurrencyId,* from(
SELECT strEntityName strName,strLocationName,strOrigin,strProductType,sum(dblBalanceQty) dblQty,sum(dblTotPurchased) dblTotPurchased,
(sum(dblTotPurchased)/SUM(CASE WHEN isnull(sum(dblTotPurchased),0)=0 then 1 else sum(dblTotPurchased) end) OVER ())*100 dblCompanySpend,sum(dblStandardQty) dblStandardQty
FROM @GetStandardQty
GROUP BY strEntityName,strEntityName,strLocationName,strOrigin,strProductType)t

