CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
                                 @intCommodityId nvarchar(max)= null
                                ,@intLocationId int = null
                                ,@intVendorId int = null
                                ,@strPurchaseSales nvarchar(50) = null
                                ,@strPositionIncludes NVARCHAR(100) = NULL
AS

IF isnull(@strPurchaseSales,'') <> ''
BEGIN
                if @strPurchaseSales='Purchase'
                BEGIN
                                SELECT @strPurchaseSales='Sale'
                END
                ELSE
                BEGIN
                                SELECT @strPurchaseSales='Purchase'
                END
END

DECLARE @Commodity AS TABLE 
(
intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
intCommodity  INT
)
INSERT INTO @Commodity(intCommodity)
SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
                 
DECLARE @tempFinal AS TABLE (
                                intRow INT IDENTITY(1,1),
                                intContractHeaderId int,
                                strContractNumber NVARCHAR(200),
                                intFutOptTransactionHeaderId int,
                                strInternalTradeNo NVARCHAR(200),
                                strCommodityCode NVARCHAR(200),   
                                 strType  NVARCHAR(50), 
                                 strSubType  NVARCHAR(50), 
                                 strContractType NVARCHAR(50),
                                strLocationName NVARCHAR(100),
                                strContractEndMonth NVARCHAR(50),
                                intInventoryReceiptItemId INT
                                ,strTicketNumber  NVARCHAR(50)
                                ,dtmTicketDateTime DATETIME
                                ,strCustomerReference NVARCHAR(100)
                                ,strDistributionOption NVARCHAR(50)
                                ,dblUnitCost NUMERIC(24, 10)
                                ,dblQtyReceived NUMERIC(24, 10)
                                ,dblTotal DECIMAL(24,10)
                                ,intSeqNo int
                                ,intFromCommodityUnitMeasureId int
                                ,intToCommodityUnitMeasureId int
                                ,intCommodityId int
                                ,strAccountNumber NVARCHAR(100)
                                ,strTranType NVARCHAR(20)
                                ,dblNoOfLot NUMERIC(24, 10)
                                ,dblDelta NUMERIC(24, 10)
                                ,intBrokerageAccountId int
                                ,strInstrumentType nvarchar(50)
                                ,invQty NUMERIC(24, 10),
                                PurBasisDelivary NUMERIC(24, 10),
                                OpenPurQty NUMERIC(24, 10),
                                OpenSalQty NUMERIC(24, 10), 
                                 dblCollatralSales NUMERIC(24, 10), 
                                 SlsBasisDeliveries NUMERIC(24, 10),
                                intNoOfContract NUMERIC(24, 10),
                                dblContractSize NUMERIC(24, 10),
                                CompanyTitled NUMERIC(24, 10),
                                strCurrency nvarchar(50),
                                intCompanyLocationId int
)

DECLARE @Final AS TABLE (
                                intRow INT IDENTITY(1,1),
                                intContractHeaderId int,
                                strContractNumber NVARCHAR(200),
                                intFutOptTransactionHeaderId int,
                                strInternalTradeNo NVARCHAR(200),
                                strCommodityCode NVARCHAR(200),   
                                 strType  NVARCHAR(50), 
                                 strSubType NVARCHAR(50), 
                                 strContractType NVARCHAR(50),
                                strLocationName NVARCHAR(100),
                                strContractEndMonth NVARCHAR(50),
                                intInventoryReceiptItemId INT
                                ,strTicketNumber  NVARCHAR(50)
                                ,dtmTicketDateTime DATETIME
                                ,strCustomerReference NVARCHAR(100)
                                ,strDistributionOption NVARCHAR(50)
                                ,dblUnitCost NUMERIC(24, 10)
                                ,dblQtyReceived NUMERIC(24, 10)
                                ,dblTotal DECIMAL(24,10)
                                ,strUnitMeasure NVARCHAR(50)
                                ,intSeqNo int
                                ,intFromCommodityUnitMeasureId int
                                ,intToCommodityUnitMeasureId int
                                ,intCommodityId int
                                ,strAccountNumber NVARCHAR(100)
                                ,strTranType NVARCHAR(20)
                                ,dblNoOfLot NUMERIC(24, 10)
                                ,dblDelta NUMERIC(24, 10)
                                ,intBrokerageAccountId int
                                ,strInstrumentType nvarchar(50)
                                ,invQty NUMERIC(24, 10),
                                PurBasisDelivary NUMERIC(24, 10),
                                OpenPurQty NUMERIC(24, 10),
                                OpenSalQty NUMERIC(24, 10), 
                                 dblCollatralSales NUMERIC(24, 10), 
                                 SlsBasisDeliveries NUMERIC(24, 10),
                                intNoOfContract NUMERIC(24, 10),
                                dblContractSize NUMERIC(24, 10),
                                CompanyTitled NUMERIC(24, 10),
                                strCurrency nvarchar(50)
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intOneCommodityId int
declare @intCommodityUnitMeasureId int
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
                SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
                SELECT @strDescription = strCommodityCode FROM tblICCommodity     WHERE intCommodityId = @intCommodityId
                SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
IF  @intCommodityId >0
BEGIN
DECLARE @tblGetOpenContractDetail TABLE (
strCommodityCode nvarchar(100),
intCommodityId int,
intContractHeaderId int,
strContractNumber nvarchar(100),
strLocationName nvarchar(100),
dtmEndDate datetime,
dblBalance numeric(18,6),
intUnitMeasureId int,
intPricingTypeId int,
intContractTypeId int,
intCompanyLocationId int,
strContractType nvarchar(100),
strPricingType nvarchar(100),
intCommodityUnitMeasureId int,
intContractDetailId int,
intContractStatusId int,
intEntityId int,
intCurrencyId int,
strType nvarchar(100))
insert into @tblGetOpenContractDetail (strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
                   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType )
SELECT strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
                   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType 
FROM vyuRKContractDetail where intCommodityId=@intCommodityId

if isnull(@intVendorId,0) = 0
BEGIN
                INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId)
                SELECT * FROM 
                (SELECT cd.strCommodityCode,cd.intContractHeaderId,strContractNumber,cd.strType [strType],'Physical' strContractType,strLocationName,
                                RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
                dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((cd.dblBalance),0)) AS dblTotal
                   ,cd.intUnitMeasureId,@intCommodityId as intCommodityId,cd.intCompanyLocationId 
                FROM @tblGetOpenContractDetail cd
                WHERE cd.intContractTypeId in(1,2) AND cd.intPricingTypeId IN (1,2,3) and 
                                cd.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
                AND cd.intCompanyLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 THEN cd.intCompanyLocationId ELSE @intLocationId END)t
                                WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                )

                -- Hedge
                INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
                                                                                                intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot)                                
                
                SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge','Future' strContractType,strLocationName, strFutureMonth,
                HedgedQty,@intCommodityUnitMeasureId intFromCommodityUnitMeasureId,@intCommodityId intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot
                FROM (
                                SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,f.intCommodityId,dtmFutureMonthsDate,
                dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,  
                                case when f.strBuySell = 'Buy' then ISNULL(intOpenContract, 0) else ISNULL(intOpenContract, 0) end                *             dblContractSize) AS HedgedQty,
                                l.strLocationName,left(strFutureMonth,4) +  '20'+convert(nvarchar(2),intYear) strFutureMonth,m.intUnitMeasureId,
                                e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
                                case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType,
                                case when f.strBuySell = 'Buy' then ISNULL(intOpenContract, 0) else ISNULL(intOpenContract, 0) end dblNoOfLot 
                                FROM vyuRKGetOpenContract oc
                                JOIN tblRKFutOptTransaction f on oc.intFutOptTransactionId=f.intFutOptTransactionId and oc.intOpenContract <> 0
                                INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId                  
                                INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
                                JOIN tblICCommodityUnitMeasure cuc1 on f.intCommodityId=cuc1.intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId
                                INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
                                INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId 
                                                                                                                                                                                AND  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                                                )
                                INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
                                INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1                 
                                WHERE ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
                                                AND f.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then f.intLocationId else @intLocationId end                                        
                                ) t            

--             -- Option NetHEdge
                INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
                                                                                                intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)                
                                SELECT DISTINCT strCommodityCode,ft.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,'Future',strLocationName,
                                                                left(strFutureMonth,4) +  '20'+convert(nvarchar(2),intYear) strFutureMonth,                                                      
                                                                CASE WHEN ft.strBuySell = 'Buy' THEN (
                                                                                                ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
                                                                                                WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId     ), 0)
                                                                                                ) ELSE - (ft.intNoOfContract - isnull((        SELECT sum(intMatchQty)                FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId    ), 0)
                                                                                                ) END * isnull((
                                                                                                SELECT TOP 1 dblDelta
                                                                                                FROM tblRKFuturesSettlementPrice sp
                                                                                                INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                                                                                WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                                                                                AND ft.dblStrike = mm.dblStrike
                                                                                                ORDER BY dtmPriceDate DESC
                                                                ),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,ft.intCommodityId,                                                                
                                e.strName + '-' + strAccountNumber AS strAccountNumber,                         
                                strBuySell AS TranType, 
                                CASE WHEN ft.strBuySell = 'Buy' THEN (
                                                                                ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
                                                                                ELSE - (ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)
                                                                ) END AS dblNoOfLot, 
                                isnull((SELECT TOP 1 dblDelta
                                FROM tblRKFuturesSettlementPrice sp
                                INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                AND ft.dblStrike = mm.dblStrike
                                ORDER BY dtmPriceDate DESC
                                ),0) AS dblDelta,ft.intBrokerageAccountId,case when ft.intInstrumentTypeId  = 1 then 'Futures' else 'Options ' end as strInstrumentType
                FROM tblRKFutOptTransaction ft
                INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
                                                                                                                                                                                AND  ft.intLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                                )
                INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
                INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
                INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
                INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
                INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
                WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
                                                SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned             ) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
--                             -- Net Hedge option end                                               
                INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries)

SELECT @strDescription,'Price Risk' [strType],'Physical' strContractType

 ,isnull(invQty, 0) 
-isnull(PurBasisDelivary,0)
 + (isnull(OpenPurQty, 0) -isnull(OpenSalQty, 0))
+ isnull(dblCollatralSales,0) 
+ isnull(SlsBasisDeliveries,0)
+ CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then  0 ELSE -isnull(DP ,0) end 
AS dblTotal,
@intCommodityUnitMeasureId,@intCommodityId,
case when invQty<PurBasisDelivary then 0 else  isnull(invQty, 0) end invQty ,-case when invQty<PurBasisDelivary then 0 else  isnull(PurBasisDelivary,0) end as PurBasisDelivary, isnull(OpenPurQty, 0) as OpenPurQty,
-isnull(OpenSalQty, 0) OpenSalQty,  isnull(dblCollatralSales,0) dblCollatralSales, isnull(SlsBasisDeliveries,0)
SlsBasisDeliveries                             
FROM (
SELECT (SELECT sum(qty) Qty from (
                            SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(s.dblOnHand ,0)))  qty,s.intLocationId intLocationId
                            from
                            vyuICGetItemStockUOM s                            
                            JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
                            JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=s.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId                                                                                   
                            WHERE s.intCommodityId  = @intCommodityId
                            AND s.intLocationId= case when isnull(@intLocationId,0)=0 then s.intLocationId else @intLocationId end        AND s.ysnStockUnit=1 AND ISNULL(dblOnHand,0) <>0                                                            
                            )t             WHERE intLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                                                            ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                                                                            )) AS invQty
            ,( SELECT sum(dblBalance) dblBalance from (
                            SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
                            FROM @tblGetOpenContractDetail cd
                            WHERE intContractTypeId = 1 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
                            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
                            )t             WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                            ELSE isnull(ysnLicensed, 0) END
                                                            )
            ) AS OpenPurQty
            ,( SELECT sum(dblBalance) dblBalance from (
                            SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
                            FROM @tblGetOpenContractDetail cd
                            WHERE cd.intContractStatusId <> 3 AND intContractTypeId = 2 AND cd.intPricingTypeId IN (1, 3)
                            AND cd.intCommodityId  = @intCommodityId 
                            AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
                            )t             WHERE  intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                            ELSE isnull(ysnLicensed, 0) END
                                                            )) AS OpenSalQty,                                                            
            (select sum(dblTotal) dblTotal from (
                                            SELECT 
                            dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
                                            ,ch.intCompanyLocationId
                                            FROM vyuGRGetStorageDetail ch
                                            WHERE ch.intCommodityId  = @intCommodityId               AND ysnDPOwnedType = 1
                                                            AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
                                            )t             WHERE intCompanyLocationId  IN (
                                                                                            SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                            ELSE isnull(ysnLicensed, 0) END
                            ) ) AS DP

            ,(select sum(dblPurBasisQty) from(
				select sum(dblPurBasisQty) dblPurBasisQty,intCommodityId ,intCompanyLocationId,strContractNumber from(
				SELECT CD.intContractDetailId, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN CD.dblQuantity - ISNULL(CD.dblBalance,0) - ISNULL(FD.dblQuantity,0) > 0 THEN
				CD.dblQuantity - ISNULL(CD.dblBalance,0) - ISNULL(FD.dblQuantity,0) ELSE 0  END) dblPurBasisQty ,intCompanyLocationId,CH.intCommodityId,strContractNumber
				FROM tblCTContractDetail CD
				join tblCTContractHeader CH on CH.intContractHeaderId=CD.intContractHeaderId and intContractTypeId=1 and CD.intPricingTypeId=2
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CH.intCommodityId AND CD.intUnitMeasureId = ium.intUnitMeasureId
				LEFT   JOIN	tblCTPriceFixation		    PF  ON  PF.intContractDetailId	=	CD.intContractDetailId 
				LEFT   JOIN	 (SELECT  intPriceFixationId,SUM(dblQuantity) AS  dblQuantity
								FROM	   tblCTPriceFixationDetail
								GROUP   BY  intPriceFixationId)
													FD  ON  FD.intPriceFixationId	  =	 PF.intPriceFixationId
				where CH.intCommodityId=c.intCommodityId and CD.intCompanyLocationId=case when isnull(@intLocationId,0)=0 then   CD.intCompanyLocationId else @intLocationId end  )t  group by intCommodityId ,intCompanyLocationId,strContractNumber)t1
				where dblPurBasisQty<>0 AND intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                            ELSE isnull(ysnLicensed, 0) END
                                                                                                            )) 
				as PurBasisDelivary,

            isnull((SELECT SUM(dblRemainingQuantity) CollateralSale
            FROM ( 
            SELECT 
                            -dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0))  dblRemainingQuantity,
                                            intContractHeaderId                                                                      
                                            FROM tblRKCollateral c1                                                                                                                                                
                                            JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
                                                                                                            AND  c1.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                            ELSE isnull(ysnLicensed, 0) END
                                                                                                            )
                                            WHERE c1.intCommodityId = c.intCommodityId 
                                            AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end and strType = 'Sales'
                                            ) t           
            ), 0) AS dblCollatralSales                                                

,(SELECT sum(SlsBasisDeliveries) FROM
            ( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
FROM tblICInventoryShipment r  
INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractTypeId = 2 and cd.intContractStatusId <> 3 
                                                                                                            AND  cd.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                            WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                            ELSE isnull(ysnLicensed, 0) END
                                                                                                            )
WHERE cd.intCommodityId = c.intCommodityId AND 
cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then   cd.intCompanyLocationId else @intLocationId end  
)t) as SlsBasisDeliveries   	  
								                                               
    FROM tblICCommodity c
    WHERE c.intCommodityId  = @intCommodityId
    ) t
                                                                
                INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intNoOfContract)                
                SELECT @strDescription,'Price Risk' [strType],'Future'
                                ,intOpenContract AS dblTotal,
                                @intCommodityUnitMeasureId,@intCommodityId,
                                intOpenContract intNoOfContract
                FROM (select sum(intOpenContract)intOpenContract
                                                from(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,@intCommodityUnitMeasureId, intOpenContract*dblContractSize) as intOpenContract 
	from vyuRKGetOpenContract oc  
		JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0
			INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId AND f.intLocationId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			INNER JOIN tblICCommodity ic ON f.intCommodityId = ic.intCommodityId
			JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
			INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
			INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		WHERE f.intCommodityId=@intCommodityId
		AND f.intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end
		 )t) intOpenContract   
		
----	-- Option NetHedge
	INSERT INTO @tempFinal (strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intNoOfContract,dblContractSize)	
		SELECT DISTINCT strCommodityCode,'Price Risk','Option',
	
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,ft.intCommodityId,
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0) AS dblNoOfContract1, isnull(m.dblContractSize,0) dblContractSize

                FROM tblRKFutOptTransaction ft
                INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
                                                                                                                                                                AND  intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                )
                INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
                INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
                INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
                INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
                INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
                WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
                                                SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned             ) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
----                         -- Net Hedge option end
                
                INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,strContractNumber,CompanyTitled,OpenPurQty,OpenSalQty)
SELECT @strDescription,
                                'Basis Risk' [strType],'Physical'
                                ,isnull(CompanyTitled, 0) AS dblTotal,

                                @intCommodityUnitMeasureId,@intCommodityId,null strContractNumber,isnull(CompanyTitled, 0) CompanyTitled,isnull(OpenPurchasesQty, 0) OpenPurchasesQty,-isnull(OpenSalesQty, 0)
                FROM (
              SELECT 
                                                   isnull(invQty, 0) 
                                                   + CASE WHEN (
                                  SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
                                  FROM tblRKCompanyPreference
                                  ) = 1 THEN isnull(OffSite, 0) ELSE 0 END + CASE WHEN (
                                  SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
                                  FROM tblRKCompanyPreference
                                  ) = 1 THEN 0 ELSE -isnull(DP ,0) END 
                                                                                                                                   + isnull(dblCollatralSales, 0) 
                                                                                                                                   + isnull(SlsBasisDeliveries, 0)
                                                                                                                                   +(isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))
                                                                                                                                    AS CompanyTitled

                                                ,OpenPurchasesQty
                                                ,OpenSalesQty,DP
                                FROM (
                                                                SELECT (SELECT sum(qty) Qty from (
                                                                SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(s.dblOnHand ,0))) qty,s.intLocationId intLocationId
                                                                FROM vyuICGetItemStockUOM s                               
                                                                JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
                                                                JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=s.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId                                                                                   
                                                                WHERE s.intCommodityId  = @intCommodityId
                                                                AND s.intLocationId= case when isnull(@intLocationId,0)=0 then s.intLocationId else @intLocationId end        AND s.ysnStockUnit=1 AND ISNULL(dblOnHand,0) <>0                                                            
                                                                )t             WHERE intLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                                                                                                                )) AS invQty
                                                                , ( SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal,
                                                                                                                                  intCompanyLocationId
                                  FROM vyuGRGetStorageDetail s
                                  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND s.intCommodityId = @intCommodityId 
                                                                                                                                  AND s.intCompanyLocationId = s.intCompanyLocationId 
                                  ) t WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                                                                                                                ))  AS OffSite
                                                                ,( select sum(dblBalance) dblBalance from (
                                                                                SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,
                                                                                intCompanyLocationId
                                                                                FROM @tblGetOpenContractDetail cd
                                                                                WHERE intContractTypeId = 1 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
                                                                                AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
                                                                                )t             WHERE intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                ))  AS OpenPurchasesQty
                                                                ,( select sum(dblBalance) dblBalance from (
                                                                                SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance,intCompanyLocationId
                                                                                FROM @tblGetOpenContractDetail cd
                                                                                WHERE intContractTypeId = 2 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
                                                                                AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
                                                                                )t WHERE intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                ))  AS OpenSalesQty
                                                                ,(select sum(dblTotal) dblTotal from (
                                                                                SELECT 
                                                                dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
                                                                                ,ch.intCompanyLocationId
                                                                                FROM vyuGRGetStorageDetail ch
                                                                                WHERE ch.intCommodityId  = @intCommodityId               AND ysnDPOwnedType = 1
                                                                                                AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
                                                                                )t             WHERE intCompanyLocationId  IN (
                                                                SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                ) ) AS DP
                                                ,(SELECT sum(SlsBasisDeliveries) FROM
                                                                                                ( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
                                                                                  FROM tblICInventoryShipment r  
                                                                                  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
                                                                                  INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractTypeId = 2 and cd.intContractStatusId <> 3 
                                                                                                                                                                                                AND  cd.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                                                                )
                                                                                  WHERE cd.intCommodityId = c.intCommodityId AND 
                                                                                  cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then   cd.intCompanyLocationId else @intLocationId end  
                                                                                  )t) as SlsBasisDeliveries 
                                ,          isnull((SELECT SUM(dblRemainingQuantity) CollateralSale
                     FROM ( 
                     SELECT 
                     case when strType = 'Purchase' then 
                                                                                                 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0)) else
                     -dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(dblRemainingQuantity,0)) end dblRemainingQuantity,
                                  intContractHeaderId,c1.intLocationId                             
                                  FROM tblRKCollateral c1                                                            
                                  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
                                  WHERE c1.intCommodityId = c.intCommodityId 
                                  AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end) t  
                                                                                                                                  WHERE intLocationId  IN (
                                                                                                                                                                SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                                ELSE isnull(ysnLicensed, 0) END                                                  )   
                     ), 0) AS dblCollatralSales 
             
                                                                
                                                FROM tblICCommodity c
                                                WHERE c.intCommodityId  = @intCommodityId
                                                ) t
                                ) t1


                                                                
                                                                                                                
                INSERT INTO @tempFinal (
					strCommodityCode
					,strType
					,dblTotal
					,strTicketNumber
					,strLocationName
					,dtmTicketDateTime
					,strCustomerReference
					,strDistributionOption
					,dblQtyReceived
					,intCommodityId
					,strCurrency
					)
				SELECT  
					@strDescription
					,'Net Payable  ($)' [strType]
					,dblAmountDue 
					,strTicketNumber
					,strLocationName
					,dtmDate dtmTicketDateTime
					,strCustomerReference
					,'' strDistributionOption
					,dblUnpaidQuantity
					,intCommodityId
					,strCurrency
                FROM(	
					SELECT *
					FROM (
						SELECT A.dtmDate
							,B.[intEntityId]
							,A.intBillId
							,A.strBillId
							,A.strVendorOrderNumber
							,tmpAgingSummaryTotal.dblTotal
							,tmpAgingSummaryTotal.dblAmountDue
							,tmpAgingSummaryTotal.dblAmountPaid
							,dblOriginalQuantity
							,CASE WHEN tmpAgingSummaryTotal.dblAmountPaid = 0 THEN dblOriginalQuantity ELSE dblOriginalQuantity - (tmpAgingSummaryTotal.dblAmountPaid / (tmpAgingSummaryTotal.dblTotal/dblOriginalQuantity)) END AS dblUnpaidQuantity
							,CASE WHEN tmpAgingSummaryTotal.dblAmountPaid = 0 THEN 0 ELSE (tmpAgingSummaryTotal.dblAmountPaid / (tmpAgingSummaryTotal.dblTotal/dblOriginalQuantity)) END AS dblPaidQuantity
							,C.strName AS strCustomerReference
							,NULL AS strReceiptNumber
							,NULL AS strTicketNumber
							,NULL AS strShipmentNumber
							,NULL AS strContractNumber
							,NULL AS strLoadNumber
							,L.strLocationName
							,E.strCommodityCode
							,E.intCommodityId
							,Cur.strCurrency
						FROM (
							SELECT intBillId
								,SUM(tmpAPPayables.dblTotal) AS dblTotal
								,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
								,SUM(tmpAPPayables.dblDiscount) AS dblDiscount
								,SUM(tmpAPPayables.dblInterest) AS dblInterest
								,(SELECT SUM(ISNULL(dblQtyReceived,0)) FROM tblAPBillDetail WHERE intBillId = tmpAPPayables.intBillId AND intInventoryReceiptChargeId IS NULL) AS dblOriginalQuantity
								,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
							FROM (
								SELECT intBillId
									,dblTotal
									,dblAmountDue
									,dblAmountPaid
									,dblDiscount
									,dblInterest
									,dtmDate
								FROM dbo.vyuAPPayables
								) tmpAPPayables
							GROUP BY intBillId
							UNION ALL
							SELECT 
								intBillId
								,SUM(tmpAPPrepaidPayables.dblTotal) AS dblTotal
								,0 --SUM(tmpAPPrepaidPayables.dblAmountPaid) AS dblAmountPaid
								,SUM(tmpAPPrepaidPayables.dblDiscount)AS dblDiscount
								,SUM(tmpAPPrepaidPayables.dblInterest) AS dblInterest
								,(SELECT SUM(dblQtyReceived) FROM tblAPBillDetail WHERE intBillId = tmpAPPrepaidPayables.intBillId AND intInventoryReceiptChargeId IS NULL) AS dblNetWeight
								,CAST((SUM(tmpAPPrepaidPayables.dblTotal) + SUM(tmpAPPrepaidPayables.dblInterest) - SUM(tmpAPPrepaidPayables.dblAmountPaid) - SUM(tmpAPPrepaidPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
							FROM (SELECT --DISTINCT 
									intBillId
									,dblTotal
									,dblAmountDue
									,dblAmountPaid
									,dblDiscount
									,dblInterest
									,dtmDate
									,intPrepaidRowType
								FROM dbo.vyuAPPrepaidPayables) tmpAPPrepaidPayables 
							GROUP BY intBillId, intPrepaidRowType
							) AS tmpAgingSummaryTotal
						LEFT JOIN dbo.tblAPBill A ON A.intBillId = tmpAgingSummaryTotal.intBillId
						LEFT JOIN (
							dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId
							) ON B.[intEntityId] = A.[intEntityVendorId]
						LEFT JOIN tblSMCompanyLocation L ON A.intStoreLocationId = L.intCompanyLocationId
						LEFT JOIN vyuAPVoucherCommodity E ON E.intBillId = tmpAgingSummaryTotal.intBillId
						INNER JOIN tblSMCurrency Cur ON A.intCurrencyId = Cur.intCurrencyID
						WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
						AND E.intCommodityId = @intCommodityId 
						AND L.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then L.intCompanyLocationId else @intLocationId end
						AND L.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
											WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
											ELSE isnull(ysnLicensed, 0) END
											)
						) MainQuery
						
				) t
                 

				                                                                                
                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,
                dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
				SELECT
					@strDescription, 
					strType, dblAmountDue AS dblTotal
					,strLocationName
					,'' intContractHeaderId,'' strContractNumber,strInvoiceNumber strTicketNumber
					,dtmDate dtmTicketDateTime
					,strCustomerName strCustomerReference
					,strDistributionOption, 0 dblUCost
					,CASE WHEN dblPayment = 0 THEN dblOriginalQuantity ELSE dblOriginalQuantity - (dblPayment / (dblInvoiceTotal/dblOriginalQuantity)) END dblQtyReceived
					,@intCommodityId
					,strCurrency	
				FROM (		
					SELECT 
						'Net Receivable  ($)' [strType]
						,'' AS strSubType
						,dblInvoiceTotal
						,dblAmountDue
						,dblPayment
						,strInvoiceNumber
						,intInvoiceId
						,strLocationName
						,intCompanyLocationId
						,dtmDate
						,strCustomerName
						,'' as strDistributionOption
						,(SELECT SUM(ISNULL(dblQtyShipped,0)) FROM tblARInvoiceDetail WHERE intInvoiceId = IFP.intInvoiceId AND intInventoryShipmentChargeId IS NULL) AS dblOriginalQuantity
						,(SELECT TOP 1 intCommodityId FROM tblARInvoiceDetail id INNER JOIN tblICItem i ON id.intItemId = i.intItemId WHERE intInvoiceId = IFP.intInvoiceId AND intInventoryShipmentChargeId IS NULL) AS intCommodityId
						,(SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = IFP.intCurrencyId) AS strCurrency
					FROM
						vyuARInvoicesForPayment IFP
					WHERE   ysnPosted = 1
					AND dblAmountDue <> 0
					AND strType = 'Standard'
				
				) a WHERE intCommodityId = @intCommodityId
					AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
					AND intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
																WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
																ELSE isnull(ysnLicensed, 0) END
																)


				  INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
				 select @strDescription,'NP Un-Paid Quantity' strType,dblQtyReceived,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType from @tempFinal where strType= 'Net Payable  ($)' and intCommodityId=@intCommodityId


                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
                select @strDescription,'NR Un-Paid Quantity' strType,dblQtyReceived,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType from @tempFinal where strType= 'Net Receivable  ($)' and intCommodityId=@intCommodityId

                
                INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
				SELECT @strDescription
					,'Avail for Spot Sale' [strType],sum(dblTotal)-sum(dblPurQty),@intCommodityUnitMeasureId,@intCommodityId from(
					select dblTotal,
					(SELECT sum(Qty) FROM (
								SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty ,CD.intCompanyLocationId                 
								FROM @tblGetOpenContractDetail  CD  
								WHERE  intContractTypeId=1 and intPricingTypeId in(1,2) and CD.intCommodityId=@intCommodityId
									and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end 
							)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
											WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
											ELSE isnull(ysnLicensed, 0) END)			
							) dblPurQty
   				FROM @tempFinal t where strType='Basis Risk' and t.intCommodityId=@intCommodityId)t	

                select @intUnitMeasureId =null
                select @strUnitMeasure =null
                SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
                SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
                INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
                dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
                                ,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency)

                SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
                    case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then dblTotal else
                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,dblTotal)) end dblTotal,
                                case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
                                strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType                 ,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then invQty else
                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,invQty)) end invQty,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then PurBasisDelivary else
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId ,PurBasisDelivary)) end PurBasisDelivary,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then OpenPurQty else
                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,OpenPurQty)) end OpenPurQty,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then OpenSalQty else
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId ,OpenSalQty)) end OpenSalQty,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then dblCollatralSales else
                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,dblCollatralSales)) end dblCollatralSales,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then SlsBasisDeliveries else
                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId ,SlsBasisDeliveries)) end SlsBasisDeliveries
                                ,intNoOfContract,dblContractSize,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then CompanyTitled else
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId ,CompanyTitled)) end CompanyTitled
                                ,strCurrency  
                FROM @tempFinal t
                JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
                JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
                LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
                WHERE t.intCommodityId= @intCommodityId  and strType not in('Net Payable  ($)','Net Receivable  ($)')
                
				INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
                dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
                                ,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency)
                SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
                    dblTotal dblTotal,
                                case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
                                ,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency
                FROM @tempFinal t
                JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
                JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
                WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')

END
ELSE
BEGIN
                INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strSubType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intCompanyLocationId)
                SELECT * FROM (
                SELECT strCommodityCode,intContractHeaderId,
                strContractNumber
                                ,strContractType+ ' ' + strPricingType [strType],strContractType+ ' ' + strPricingType strSubType,'Physical' strContractType
                                ,strLocationName,
                                RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
                dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) AS dblTotal
                                ,CD.intUnitMeasureId,@intCommodityId as intCommodityId,intCompanyLocationId
                FROM @tblGetOpenContractDetail CD
                WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and CD.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
                AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
                AND intEntityId= @intVendorId) t 
                WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                
                INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
                SELECT  @strDescription, 'Quantity Purchase' [strType],'Quantity Purchase',isnull(dblOpenReceive,0) dblTotal,
                                                cd.intContractHeaderId, strContractNumber,
                                                                                cl.strLocationName
                                                                ,r.strReceiptNumber strTicketNumber
                                                                ,r.dtmReceiptDate dtmTicketDateTime
                                                                ,r.strVendorRefNo as strCustomerReference
                                                                ,'Purchase Contract' as strDistributionOption
                                                                ,dblUnitCost AS dblUnitCost
                                                                ,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
                                                                ,cd.intCommodityId
                FROM tblICInventoryReceipt r
                INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
                INNER JOIN @tblGetOpenContractDetail cd ON  cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=ri.intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
                                                                                                                                AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                WHERE cd.intCommodityId = @intCommodityId and cd.intEntityId=@intVendorId 
                AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end

                UNION

                SELECT @strDescription, 'Quantity Purchase' [strType], 'Quantity Purchase',isnull(dblOpenReceive,0) dblTotal
                                                                ,null as intContractHeaderId, null as strContractNumber
                                                                ,cl.strLocationName
                                                                ,r.strReceiptNumber strTicketNumber
                                                                ,r.dtmReceiptDate dtmTicketDateTime
                                                                ,r.strVendorRefNo as strCustomerReference
                                                                ,'Direct' as strDistributionOption
                                                                ,dblUnitCost AS dblUnitCost
                                                                ,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
                                                                ,i.intCommodityId                                           
                FROM tblICInventoryReceipt r
                INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
                AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
                INNER JOIN tblICItem i on ri.intItemId=i.intItemId 
                                                                                                                                AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
                WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorId
                AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end                
                
                INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
SELECT  @strDescription, 'Quantity Sales' [strType], 'Quantity Sales',isnull(dblQuantity,0) dblTotal,
                                cd.intContractHeaderId,strContractNumber
                                                ,cd.strLocationName
                                                ,s.strShipmentNumber strTicketNumber
                                                ,s.dtmShipDate dtmTicketDateTime
                                                ,s.strReferenceNumber as strCustomerReference
                                                ,'Spot Sale' as strDistributionOption
                                                ,dblUnitPrice AS dblUnitCost
                                                ,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
                                                ,cd.intCommodityId
                                FROM tblICInventoryShipment s
                                join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
                                JOIN @tblGetOpenContractDetail cd on cd.intContractDetailId=si.intLineNo         
                                                                                                                                AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                join tblICItem i on si.intItemId=i.intItemId  WHERE i.intCommodityId=@intCommodityId and s.intEntityCustomerId=@intVendorId
                                AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
                                
                UNION
                                SELECT @strDescription, 'Quantity Sales' [strType],'Quantity Sales',ISNULL(dblQuantity,0) dblTotal
                                                ,cd.intContractHeaderId, strContractNumber
                                                ,cd.strLocationName
                                                ,s.strShipmentNumber strTicketNumber
                                                ,s.dtmShipDate dtmTicketDateTime
                                                ,s.strReferenceNumber as strCustomerReference
                                                ,'Sales Contract' as strDistributionOption
                                                ,dblUnitPrice AS dblUnitCost
                                                ,isnull(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
                                                ,cd.intCommodityId
                                from tblICInventoryShipment s
                                JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
                                JOIN @tblGetOpenContractDetail cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2  
                                                                                                                                                                AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                AND cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorId 
                                AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end           
                
                INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
                SELECT  @strDescription, 'Purchase Gross Dollars' [strType], 'Purchase Gross Dollars',isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) dblTotal,
                                                cd.intContractHeaderId,strContractNumber
                                                ,cl.strLocationName
                                                ,r.strReceiptNumber strTicketNumber
                                                ,r.dtmReceiptDate dtmTicketDateTime
                                                ,r.strVendorRefNo as strCustomerReference
                                                ,'Purchase Contract' as strDistributionOption
                                                ,dblUnitCost AS dblUnitCost
                                                ,isnull(dblOpenReceive,0) AS dblQtyReceived
                                                ,cd.intCommodityId,cur.strCurrency                                        
                                FROM tblICInventoryReceipt r
                                INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
                                INNER JOIN @tblGetOpenContractDetail cd ON  cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId 
                                                                                                                                AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
                                WHERE cd.intCommodityId = @intCommodityId and cd.intEntityId=@intVendorId 
                                AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end

                                UNION

                                SELECT  @strDescription, 'Purchase Gross Dollars' [strType], 'Purchase Gross Dollars',isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) dblTotal,
                                                                                null as intContractHeaderId, null as strContractNumber
                                                                                ,cl.strLocationName
                                                                                ,r.strReceiptNumber strTicketNumber
                                                                                ,r.dtmReceiptDate dtmTicketDateTime
                                                                                ,r.strVendorRefNo as strCustomerReference
                                                                                ,'Direct' as strDistributionOption
                                                                                ,dblUnitCost AS dblUnitCost
                                                                                ,isnull(dblOpenReceive,0) AS dblQtyReceived
                                                                                ,intCommodityId,cur.strCurrency
                                FROM tblICInventoryReceipt r
                                INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
                                AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
                                INNER JOIN tblICItem i on ri.intItemId=i.intItemId
                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId 
                                                                                                                                AND r.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=r.intCurrencyId
                                WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorId
                                AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end                        

    INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
SELECT @strDescription, 'Sales Gross Dollars' [strType], 'Sales Gross Dollars',ISNULL(dblQuantity,0) dblTotal,
                                                cd.intContractHeaderId, cd.strContractNumber
                                                ,cd.strLocationName
                                                ,s.strShipmentNumber strTicketNumber
                                                ,s.dtmShipDate dtmTicketDateTime
                                                ,s.strReferenceNumber as strCustomerReference
                                                ,'Purchase Contract' as strDistributionOption                                       
                                                ,dblUnitPrice AS dblUnitCost
                                                ,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
                                                ,cd.intCommodityId,cur.strCurrency
                                FROM tblICInventoryShipment s
                                JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
                                JOIN tblICItem i on si.intItemId=i.intItemId 
                                JOIN @tblGetOpenContractDetail cd on cd.intContractDetailId=si.intLineNo 
                                                                                                                AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
                                WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorId  
                                AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
                                UNION
                                SELECT @strDescription, 'Sales Gross Dollars' [strType], 'Sales Gross Dollars',ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) dblTotal,
                                                cd.intContractHeaderId, cd.strContractNumber
                                                ,cd.strLocationName
                                                ,s.strShipmentNumber strTicketNumber
                                                ,s.dtmShipDate dtmTicketDateTime
                                                ,s.strReferenceNumber as strCustomerReference
                                                ,'Direct' as strDistributionOption
                                                ,dblUnitPrice AS dblUnitCost
                                                ,ISNULL(dblQuantity,0) AS dblQtyReceived
                                                ,cd.intCommodityId,cur.strCurrency
                                FROM tblICInventoryShipment s
                                JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId=si.intInventoryShipmentId 
                                JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2 
                                                                                                                                                AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)  
                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
                                AND cd.intCommodityId=@intCommodityId AND cd.intEntityId=@intVendorId 
                                AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end           

				                                                                                                    
                INSERT INTO @tempFinal (
					strCommodityCode
					,strType
					,dblTotal
					,strTicketNumber
					,strLocationName
					,dtmTicketDateTime
					,strCustomerReference
					,strDistributionOption
					,dblQtyReceived
					,intCommodityId
					,strCurrency
					)
				SELECT  
					@strDescription
					,'Net Payable  ($)' [strType]
					,dblAmountDue 
					,strTicketNumber
					,strLocationName
					,dtmDate dtmTicketDateTime
					,strCustomerReference
					,'' strDistributionOption
					,dblUnpaidQuantity
					,intCommodityId
					,strCurrency
                FROM(	
					SELECT *
					FROM (
						SELECT A.dtmDate
							,B.[intEntityId]
							,A.intBillId
							,A.strBillId
							,A.strVendorOrderNumber
							,tmpAgingSummaryTotal.dblTotal
							,tmpAgingSummaryTotal.dblAmountDue
							,tmpAgingSummaryTotal.dblAmountPaid
							,dblOriginalQuantity
							,CASE WHEN tmpAgingSummaryTotal.dblAmountPaid = 0 THEN dblOriginalQuantity ELSE dblOriginalQuantity - (tmpAgingSummaryTotal.dblAmountPaid / (tmpAgingSummaryTotal.dblTotal/dblOriginalQuantity)) END AS dblUnpaidQuantity
							,CASE WHEN tmpAgingSummaryTotal.dblAmountPaid = 0 THEN 0 ELSE (tmpAgingSummaryTotal.dblAmountPaid / (tmpAgingSummaryTotal.dblTotal/dblOriginalQuantity)) END AS dblPaidQuantity
							,C.strName AS strCustomerReference
							,NULL AS strReceiptNumber
							,NULL AS strTicketNumber
							,NULL AS strShipmentNumber
							,NULL AS strContractNumber
							,NULL AS strLoadNumber
							,L.strLocationName
							,E.strCommodityCode
							,E.intCommodityId
							,Cur.strCurrency
						FROM (
							SELECT intBillId
								,SUM(tmpAPPayables.dblTotal) AS dblTotal
								,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
								,SUM(tmpAPPayables.dblDiscount) AS dblDiscount
								,SUM(tmpAPPayables.dblInterest) AS dblInterest
								,(SELECT SUM(ISNULL(dblQtyReceived,0)) FROM tblAPBillDetail WHERE intBillId = tmpAPPayables.intBillId AND intInventoryReceiptChargeId IS NULL) AS dblOriginalQuantity
								,(SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS dblAmountDue
							FROM (
								SELECT intBillId
									,dblTotal
									,dblAmountDue
									,dblAmountPaid
									,dblDiscount
									,dblInterest
									,dtmDate
								FROM dbo.vyuAPPayables
								) tmpAPPayables
							GROUP BY intBillId
							UNION ALL
							SELECT 
								intBillId
								,SUM(tmpAPPrepaidPayables.dblTotal) AS dblTotal
								,0 --SUM(tmpAPPrepaidPayables.dblAmountPaid) AS dblAmountPaid
								,SUM(tmpAPPrepaidPayables.dblDiscount)AS dblDiscount
								,SUM(tmpAPPrepaidPayables.dblInterest) AS dblInterest
								,(SELECT SUM(dblQtyReceived) FROM tblAPBillDetail WHERE intBillId = tmpAPPrepaidPayables.intBillId AND intInventoryReceiptChargeId IS NULL) AS dblNetWeight
								,CAST((SUM(tmpAPPrepaidPayables.dblTotal) + SUM(tmpAPPrepaidPayables.dblInterest) - SUM(tmpAPPrepaidPayables.dblAmountPaid) - SUM(tmpAPPrepaidPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
							FROM (SELECT --DISTINCT 
									intBillId
									,dblTotal
									,dblAmountDue
									,dblAmountPaid
									,dblDiscount
									,dblInterest
									,dtmDate
									,intPrepaidRowType
								FROM dbo.vyuAPPrepaidPayables) tmpAPPrepaidPayables 
							GROUP BY intBillId, intPrepaidRowType
							) AS tmpAgingSummaryTotal
						LEFT JOIN dbo.tblAPBill A ON A.intBillId = tmpAgingSummaryTotal.intBillId
						LEFT JOIN (
							dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId
							) ON B.[intEntityId] = A.[intEntityVendorId]
						LEFT JOIN tblSMCompanyLocation L ON A.intStoreLocationId = L.intCompanyLocationId
						LEFT JOIN vyuAPVoucherCommodity E ON E.intBillId = tmpAgingSummaryTotal.intBillId
						INNER JOIN tblSMCurrency Cur ON A.intCurrencyId = Cur.intCurrencyID
						WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
						AND E.intCommodityId = @intCommodityId 
						AND L.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then L.intCompanyLocationId else @intLocationId end
						AND L.intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
											WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
											WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
											ELSE isnull(ysnLicensed, 0) END
											)
						 AND C.intEntityId = @intVendorId 
						) MainQuery
						
				) t
                                                                
                INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
				SELECT
					@strDescription, 
					strType, strSubType,dblAmountDue AS dblTotal
					,intInvoiceId AS intInventoryReceiptItemId
					,strLocationName
					,'' intContractHeaderId,'' strContractNumber,strInvoiceNumber strTicketNumber
					,dtmDate dtmTicketDateTime
					,strCustomerName strCustomerReference
					,strDistributionOption, 0 dblUCost
					,CASE WHEN dblPayment = 0 THEN dblOriginalQuantity ELSE dblOriginalQuantity - (dblPayment / (dblInvoiceTotal/dblOriginalQuantity)) END dblQtyReceived
					,@intCommodityId
					,strCurrency	
				FROM (		
					SELECT 
						'Net Receivable  ($)' [strType]
						,'' AS strSubType
						,dblInvoiceTotal
						,dblAmountDue
						,dblPayment
						,strInvoiceNumber
						,intInvoiceId
						,strLocationName
						,intCompanyLocationId
						,dtmDate
						,strCustomerName
						,'' as strDistributionOption
						,(SELECT SUM(ISNULL(dblQtyShipped,0)) FROM tblARInvoiceDetail WHERE intInvoiceId = IFP.intInvoiceId AND intInventoryShipmentChargeId IS NULL) AS dblOriginalQuantity
						,(SELECT TOP 1 intCommodityId FROM tblARInvoiceDetail id INNER JOIN tblICItem i ON id.intItemId = i.intItemId WHERE intInvoiceId = IFP.intInvoiceId AND intInventoryShipmentChargeId IS NULL) AS intCommodityId
						,(SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = IFP.intCurrencyId) AS strCurrency
					FROM
						vyuARInvoicesForPayment IFP
					WHERE   ysnPosted = 1
					AND dblAmountDue <> 0
					AND strType = 'Standard'
					AND intEntityCustomerId = @intVendorId 
				
				) a WHERE intCommodityId = @intCommodityId
					AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
					AND intCompanyLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
																WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
																ELSE isnull(ysnLicensed, 0) END
																)
					 

--        

                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)

                select strCommodityCode,'NP Un-Paid Quantity' strType,dblQtyReceived,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType
                                                                                FROM @tempFinal where strType='Net Payable  ($)' and intCommodityId=@intCommodityId

                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
                select @strDescription,'NR Un-Paid Quantity' strType,dblQtyReceived,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType from @tempFinal where strType= 'Net Receivable  ($)' and intCommodityId=@intCommodityId

                SELECT @intUnitMeasureId =null
                SELECT @strUnitMeasure =null
                SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
                SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
                INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 
                dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
                                ,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency)

                SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth,          
                    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
                                case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
                                strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType
                              ,Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,invQty)) invQty,
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,PurBasisDelivary)) PurBasisDelivary,
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurQty)) OpenPurQty,
                                                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalQty)) OpenSalQty,
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCollatralSales)) dblCollatralSales,
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,SlsBasisDeliveries)) SlsBasisDeliveries
                                ,intNoOfContract,dblContractSize,
                                Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
                                case when (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,CompanyTitled)) CompanyTitled
                                  ,strCurrency
                FROM @tempFinal t
                JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
                JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
                LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
                WHERE t.intCommodityId= @intCommodityId and strType not in('Net Payable  ($)','Net Receivable  ($)')
                
				INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 
                dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
                                ,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency)
                SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,
                strContractEndMonth, dblTotal dblTotal,case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,
				strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
                                ,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency
                FROM @tempFinal t
                JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
                JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
                WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')
                
END
END
SELECT @mRowNumber = MIN(intCommodityIdentity)  FROM @Commodity       WHERE intCommodityIdentity > @mRowNumber              
END

UPDATE @Final set intSeqNo = 1 where strType='Purchase Priced'
UPDATE @Final set intSeqNo = 2 where strType='Purchase Basis'
UPDATE @Final set intSeqNo = 3 where strType='Purchase HTA'
UPDATE @Final set intSeqNo = 4 where strType='Sale Priced'
UPDATE @Final set intSeqNo = 5 where strType='Sale Basis'
UPDATE @Final set intSeqNo = 6 where strType='Sale HTA'
UPDATE @Final set intSeqNo = 7 where strType='Net Hedge'
UPDATE @Final set intSeqNo = 8 where strType='Price Risk'
UPDATE @Final set intSeqNo = 9 where strType='Basis Risk'
UPDATE @Final set intSeqNo = 10 where strType='Net Payable  ($)'
UPDATE @Final set intSeqNo = 11 where strType='NP Un-Paid Quantity'
UPDATE @Final set intSeqNo = 12 where strType='Net Receivable  ($)'
UPDATE @Final set intSeqNo = 13 where strType='NR Un-Paid Quantity'
UPDATE @Final set intSeqNo = 14 where strType='Avail for Spot Sale'
                
IF isnull(@intVendorId,0) = 0
BEGIN
                SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
                                                ,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
                                                                invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency                                  
                FROM @Final where dblTotal <> 0 
                ORDER BY intSeqNo ASC,case when isnull(intContractHeaderId,0)=0 then intFutOptTransactionHeaderId else intContractHeaderId end desc
END
ELSE
BEGIN
                SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strSubType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
                                                ,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
                                                                invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled,strCurrency                                  
                FROM @Final where dblTotal <> 0 and strSubType NOT like '%'+@strPurchaseSales+'%'  
                ORDER BY intSeqNo ASC,case when isnull(intContractHeaderId,0)=0 then intFutOptTransactionHeaderId else intContractHeaderId end desc
END
