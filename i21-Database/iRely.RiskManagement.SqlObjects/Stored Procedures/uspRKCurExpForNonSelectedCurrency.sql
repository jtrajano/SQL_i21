CREATE PROC uspRKCurExpForNonSelectedCurrency
		 @intWeightUOMId int = null
		,@intCompanyId int = null
		,@intCommodityId int 
		,@dtmMarketPremium datetime =null
		,@dtmClosingPrice datetime=null
		,@intCurrencyId int

AS


--DECLARE @tblGetOpenContractDetail TABLE (
--		intRowNum int, 
--		strCommodityCode  nvarchar(100),
--		intCommodityId int, 
--		intContractHeaderId int, 
--	    strContractNumber  nvarchar(100),
--		strLocationName  nvarchar(100),
--		dtmEndDate datetime,
--		dblBalance DECIMAL(24,10),
--		intUnitMeasureId int, 	
--		intPricingTypeId int,
--		intContractTypeId int,
--		intCompanyLocationId int,
--		strContractType  nvarchar(100), 
--		strPricingType  nvarchar(100),
--		intCommodityUnitMeasureId int,
--		intContractDetailId int,
--		intContractStatusId int,
--		intEntityId int,
--		intCurrencyId int,
--		strType	  nvarchar(100),
--		intItemId int,
--		strItemNo  nvarchar(100),
--		dtmContractDate datetime,
--		strEntityName  nvarchar(100),
--		strCustomerContract  nvarchar(100)
--				,intFutureMarketId int
--		,intFutureMonthId int)

--declare @getDate datetime
--set @getDate = convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)

--INSERT INTO @tblGetOpenContractDetail (intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
--	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType,intItemId,strItemNo ,dtmContractDate,strEntityName,strCustomerContract
--	   	   ,intFutureMarketId,intFutureMonthId)
--EXEC uspRKDPRContractDetail @intCommodityId, @getDate

SELECT  convert(int,ROW_NUMBER() OVER(order by intContractSeq)) as intRowNum
		,ch.strContractNumber+'-'+CONVERT(NVARCHAR,cd.intContractSeq) strContractNumber
		,e.strName
		,cd.dblBalance dblQuantity
		,um.strUnitMeasure strUnitMeasure
		,10.3 dblOrigPrice
		,c.strCurrency+'/'+um.strUnitMeasure strOrigPriceUOM
		,9.5 dblPrice
		, CONVERT(VARCHAR(11), cd.dtmStartDate, 106) +'-'+CONVERT(VARCHAR(11), cd.dtmEndDate, 106) dtmPeriod
		,'S' strContractType
		,909.5 dblUSDValue
		,strCompanyName
		,1 as intConcurrencyId
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and ch.intContractTypeId=2
--join @tblGetOpenContractDetail scd on scd.intContractDetailId=cd.intContractDetailId
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
JOIN tblICItemUOM u on u.intItemUOMId=cd.intItemUOMId 
JOIN tblICUnitMeasure um on um.intUnitMeasureId=u.intUnitMeasureId
JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId
LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
WHERE cd.intCurrencyId<>@intCurrencyId and ch.intCommodityId=@intCommodityId