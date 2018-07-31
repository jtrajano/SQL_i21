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
                WHERE cd.intContractTypeId in(1,2) and 
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
                                ,
                                                isnull(invQty, 0)
                                -isnull(PurBasisDelivary,0) 
                                 + (isnull(OpenPurQty, 0) -isnull(OpenSalQty, 0))
                                + isnull(dblCollatralSales,0) 
                                + isnull(SlsBasisDeliveries,0)
                                + CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=1 then  0 ELSE -isnull(DP ,0) end 
                                 AS dblTotal,
                                @intCommodityUnitMeasureId,@intCommodityId,
                                isnull(invQty, 0) invQty ,-isnull(PurBasisDelivary,0) as PurBasisDelivary, isnull(OpenPurQty, 0) as OpenPurQty,
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
                                                                AND s.intLocationId= case when isnull(@intLocationId,0)=0 then s.intLocationId else @intLocationId end        AND iuom.ysnStockUnit=1 AND ISNULL(dblOnHand,0) <>0                                                            
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

                                                ,(SELECT sum(ISNULL(dblTotal,0)) dblTotal FROM 
                                                (SELECT 
                                dbo.fnCTConvertQuantityToTargetCommodityUOM(CT.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0)) AS dblTotal
                                                FROM tblLGDeliveryPickDetail Del
                                                INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
                                                INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
                                                INNER JOIN @tblGetOpenContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId 
                                                                                                AND  CT.intCompanyLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                )
                                                WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
                                                AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
                                                
                                                UNION ALL
                                                
                                                SELECT 
                                dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal
                                                FROM tblICInventoryReceipt r
                                                INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
                                                INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
                                                                                                                                                AND  st.intProcessingLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                )
                                                INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 
                                                WHERE cd.intCommodityId = @intCommodityId  and st.strTicketStatus <> 'V'
                                                AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end)t) as PurBasisDelivary,

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
                                                                AND s.intLocationId= case when isnull(@intLocationId,0)=0 then s.intLocationId else @intLocationId end        AND iuom.ysnStockUnit=1 AND ISNULL(dblOnHand,0) <>0                                                            
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


                                                                
                                                                                                                
                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strTicketNumber,strLocationName,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblQtyReceived,intCommodityId,strCurrency)
               SELECT @strDescription, 'Net Payable  ($)' [strType],dblTotal dblTotal,
                strTicketNumber,strLocationName,dtmTicketDateTime,strCustomerReference,strDistributionOption,
                                dblQtyReceived,intCommodityId,strCurrency
                FROM(                                                                 
                        SELECT DISTINCT ri.intInventoryReceiptId
                        ,cl.strLocationName
                        ,st.strTicketNumber
                        ,st.dtmTicketDateTime
                        ,strCustomerReference
                        ,'CNT' strDistributionOption
                        ,null AS dblUnitCost
                        ,null dblUnitCost1,                           
								isnull((Select sum(dblTotal-isnull(dblAmountPaid,0)) FROM vyuAPPayables bd      
                                WHERE b.strBillId=bd.strBillId ),0) dblTotal
							,sum(ri.dblOpenReceive) over(partition by r.intInventoryReceiptId) AS dblQtyReceived 
                        ,st.intCommodityId
                        , cur.strCurrency
                        FROM tblICInventoryReceipt r
                        INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
						INNER JOIN tblICItem i on i.intItemId=ri.intItemId and i.strType='Inventory'
                        INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption = 'CNT'
                        JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
                        INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=ri.intLineNo AND cd.intPricingTypeId = 1   
								AND r.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                ELSE isnull(ysnLicensed, 0) END
                                )
                        INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
						LEFT join tblAPBillDetail d on d.intInventoryReceiptItemId=ri.intInventoryReceiptItemId
						LEFT join tblAPBill b on b.intBillId=d.intBillId
                        WHERE intSourceType = 1 and st.strTicketStatus <> 'V'
                                        AND strReceiptType IN ('Purchase Contract')       AND cd.intCommodityId = @intCommodityId           
                                        AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
                          UNION ALL
                                
                                                                             
                        SELECT DISTINCT ri.intInventoryReceiptId
								,cl.strLocationName
								,st.strTicketNumber
								,st.dtmTicketDateTime
								,strCustomerReference
								,'CNT' strDistributionOption
								,null AS dblUnitCost
								,null dblUnitCost1,                           
										isnull((Select sum(dblTotal-isnull(dblAmountPaid,0)) FROM vyuAPPayables bd      
										WHERE b.strBillId=bd.strBillId ),0) dblTotal
									,sum(ri.dblOpenReceive) over(partition by r.intInventoryReceiptId) AS dblQtyReceived 
								,st.intCommodityId
								, cur.strCurrency
                        FROM tblICInventoryReceipt r
                        INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
                        inner join tblICItem i on ri.intItemId=i.intItemId and i.strType='Inventory'
                        INNER JOIN tblICItemUOM iu on iu.intItemUOMId=ri.intUnitMeasureId
                        INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId 
                                    AND strDistributionOption='SPT' and  intSourceType = 1 
                                    AND strReceiptType IN ('Purchase Contract') AND i.intCommodityId = @intCommodityId  
                        JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId 
                                                                                                                                                                                                                        AND r.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
								)
                        INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId                        
                        INNER JOIN tblICCommodityUnitMeasure um on um.intCommodityId= @intCommodityId and um.intUnitMeasureId=iu.intUnitMeasureId 
						LEFT join tblAPBillDetail d on d.intInventoryReceiptItemId=ri.intInventoryReceiptItemId
						LEFT join tblAPBill b on b.intBillId=d.intBillId        
                        WHERE r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end and
                        st.strTicketStatus <> 'V')t where dblTotal <>0 
                 

				                                                                                
                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,
                dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
                SELECT @strDescription, 'Net Receivable  ($)' [strType],isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,strLocationName,
                                                intContractHeaderId,strContractNumber
                                                ,strTicketNumber
                                                ,dtmTicketDateTime
                                                ,strCustomerReference
                                                ,strDistributionOption, dblUCost
                                                ,dblQtyReceived,@intCommodityId,strCurrency                                
                                FROM (
                                                SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
                                                                ,cl.strLocationName
                                                                ,st.strTicketNumber
                                                                ,st.dtmTicketDateTime
                                                                ,strCustomerReference
                                                                ,'Contract' strDistributionOption
                                                                ,cd.intContractHeaderId
                                                                ,cd.strContractNumber
                                                                ,isi.dblUnitPrice dblUCost
                                                                ,(isi.dblQuantity * isi.dblUnitPrice)+isnull(pi.dblAmount,0) AS dblUnitCost
                                                                ,(select sum(R.dblPayment) from              tblARInvoiceDetail I 
                                                                                LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId                                                                            
                                                                                where isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId and isnull(R.dblPayment, 0)>0) dblQtyReceived
                                                                ,st.intCommodityId,cd.intUnitMeasureId,cur.strCurrency
                                                FROM tblICInventoryShipment ici
                                                INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId                                          
                                                INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
                                                join tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
                                                INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1 
                                                                                                                                                                                                                                                AND st.intProcessingLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                ELSE isnull(ysnLicensed, 0) END
                                                                                                                                                )
                                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId                           
                                                LEFT JOIN tblICInventoryShipmentCharge pi on ici.intInventoryShipmentId                =pi.intInventoryShipmentId
                                                WHERE intOrderType IN (1) AND intSourceType = 1          AND st.intCommodityId = @intCommodityId
                                                                AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end          
                                                                and st.strTicketStatus <> 'V'
                                                ) t
                                
UNION 
                SELECT @strDescription, 'Net Receivable  ($)' [strType],isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,strLocationName,
                                                intContractHeaderId,strContractNumber
                                                ,strTicketNumber
                                                ,dtmTicketDateTime
                                                ,strCustomerReference
                                                ,strDistributionOption, dblUCost
                                                ,dblQtyReceived,@intCommodityId,strCurrency 
                                FROM (
                                                SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
                                                                ,cl.strLocationName
                                                                ,st.strTicketNumber
                                                                ,st.dtmTicketDateTime
                                                                ,strCustomerReference
                                                                ,'Spot Sale' strDistributionOption
                                                                ,null as intContractHeaderId
                                                                ,null as strContractNumber
                                                                ,isi.dblUnitPrice dblUCost
                                                                ,(isi.dblQuantity * isi.dblUnitPrice)+isnull(pi.dblAmount,0) AS dblUnitCost
                                                                ,st.intCommodityId
                                                                ,(select sum(R.dblPayment) from              tblARInvoiceDetail I 
                                                                                LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId                                                                            
                                                                                where isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId and isnull(R.dblPayment, 0)>0) dblQtyReceived
                                                                ,isi.intItemUOMId as intUnitMeasureId,cur.strCurrency
                                                FROM tblICInventoryShipment ici
                                                INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
                                                INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
                                                join tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
                                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId 
                                                                                                                                                AND st.intProcessingLocationId  IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                                LEFT JOIN tblICInventoryShipmentCharge pi on ici.intInventoryShipmentId                =pi.intInventoryShipmentId
                                                WHERE intOrderType IN (4)
                                                                AND intSourceType = 1
                                                                AND st.intCommodityId = @intCommodityId and st.strTicketStatus <> 'V'
                                                                AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
                                                ) t            
                                                


				 INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strTicketNumber,strLocationName,dtmTicketDateTime,
                                                         strCustomerReference,strDistributionOption,dblQtyReceived,intCommodityId,strCurrency)

               SELECT @strDescription, 'NP Un-Paid Quantity' [strType],dblTotal dblTotal,
                strTicketNumber,strLocationName,dtmTicketDateTime,strCustomerReference,strDistributionOption,
                                dblQtyReceived,intCommodityId,strCurrency
                FROM(                                                                 
                        SELECT DISTINCT ri.intInventoryReceiptId,ri.intInventoryReceiptItemId 
                        ,cl.strLocationName
                        ,st.strTicketNumber
                        ,st.dtmTicketDateTime
                        ,strBillId strCustomerReference
                        ,'CNT' strDistributionOption
 
	              
							,( select sum(dblUnpaidQty) dblUnpaidQty from(
								SELECT  sum((bd.dblQtyReceived) - (b.dblTotal-(isnull(b.dblAmountDue,0)))/dblCost)  dblUnpaidQty
								FROM tblAPBill b
								join tblAPBillDetail bd on b.intBillId=bd.intBillId
								WHERE b1.intBillId = bd.intBillId and b.dblAmountDue<>0		 )t		
				
								) dblTotal
							--sum((bd.dblQtyReceived) - (b.dblTotal-(isnull(b.dblAmountDue,0)))/dblCost) over(partition by b.intBillId) AS dblTotal 
							,sum(ri.dblOpenReceive) over(partition by r.intInventoryReceiptId) AS dblQtyReceived 
                        ,st.intCommodityId
                        , cur.strCurrency
                        FROM tblICInventoryReceipt r
                        INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
						INNER JOIN tblICItem i on i.intItemId=ri.intItemId and i.strType='Inventory'
                        INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption = 'CNT'
                        JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
                        INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=ri.intLineNo AND cd.intPricingTypeId = 1   
								AND r.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                ELSE isnull(ysnLicensed, 0) END
                                )
                        INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
						LEFT join tblAPBillDetail bd on bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId
						LEFT join tblAPBill b1 on b1.intBillId=bd.intBillId
                        WHERE intSourceType = 1 and st.strTicketStatus <> 'V'
                                        AND strReceiptType IN ('Purchase Contract')       AND cd.intCommodityId = @intCommodityId           
                                        AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
										and b1.dblAmountDue<>0	
                          UNION ALL
                                
                                                                             
                        SELECT DISTINCT ri.intInventoryReceiptId,ri.intInventoryReceiptItemId 
                        ,cl.strLocationName
                        ,st.strTicketNumber
                        ,st.dtmTicketDateTime
                        ,strBillId strCustomerReference
                        ,'SPT' strDistributionOption
	              
							,( select sum(dblUnpaidQty) dblUnpaidQty from(
								SELECT  sum((bd.dblQtyReceived) - (b.dblTotal-(isnull(b.dblAmountDue,0)))/dblCost)  dblUnpaidQty
								FROM tblAPBill b
								join tblAPBillDetail bd on b.intBillId=bd.intBillId
								WHERE b1.intBillId = bd.intBillId and b.dblAmountDue<>0		 )t		
				
								) dblTotal
							--sum((bd.dblQtyReceived) - (b.dblTotal-(isnull(b.dblAmountDue,0)))/dblCost) over(partition by b.intBillId) AS dblTotal 
							,sum(ri.dblOpenReceive) over(partition by r.intInventoryReceiptId) AS dblQtyReceived 
                        ,st.intCommodityId
                        , cur.strCurrency
                        FROM tblICInventoryReceipt r
                        INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
                        inner join tblICItem i on ri.intItemId=i.intItemId and i.strType='Inventory'
                        INNER JOIN tblICItemUOM iu on iu.intItemUOMId=ri.intUnitMeasureId
                        INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId 
                                    AND strDistributionOption='SPT' and  intSourceType = 1 
                                    AND strReceiptType IN ('Purchase Contract') AND i.intCommodityId = @intCommodityId  
                        JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId                                                                                                                                                                                                                         AND r.intLocationId   IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
								WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
								WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
								ELSE isnull(ysnLicensed, 0) END
								)
                        INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId                        
                        INNER JOIN tblICCommodityUnitMeasure um on um.intCommodityId= @intCommodityId and um.intUnitMeasureId=iu.intUnitMeasureId 
									LEFT join tblAPBillDetail bd on bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId
						LEFT join tblAPBill b1 on b1.intBillId=bd.intBillId     
                         WHERE r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end and
                        st.strTicketStatus <> 'V')t where dblTotal <>0 

                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
                select @strDescription,'NR Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
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
                UNION
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
                WHERE intContractTypeId in(1,2)  and CD.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
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

                INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)
                SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,
                                                intContractHeaderId,strContractNumber,strLocationName
                                                ,strTicketNumber
                                                ,dtmTicketDateTime
                                                ,strCustomerReference
                                                ,strDistributionOption, dblUcost
                                                ,dblQtyReceived,@intCommodityId,strCurrency                                
                                FROM (
                                                SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
                                                                ,cl.strLocationName
                                                                ,st.strTicketNumber
                                                                ,st.dtmTicketDateTime
                                                                ,strCustomerReference
                                                                ,'Contract' strDistributionOption
                                                                ,cd.intContractHeaderId
                                                                ,cd.strContractNumber
                                                                ,isi.dblUnitPrice dblUcost
                                                                ,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
                                                                ,R.dblPayment as dblQtyReceived
                                                                ,st.intCommodityId,cd.intUnitMeasureId,cur.strCurrency
                                                FROM tblICInventoryShipment ici
                                                INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
                                                INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
                                                INNER JOIN @tblGetOpenContractDetail cd ON  cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
                                                                                                                                                                AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
                                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
                                                LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
                                                LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
                                                WHERE intOrderType IN (1) AND intSourceType = 1          AND st.intCommodityId = @intCommodityId
                                                                AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end          
                                                                AND st.intEntityId= @intVendorId and   st.strTicketStatus <> 'V'
                                                ) t
                                
UNION 
                                SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,
                                                intContractHeaderId,strContractNumber,strLocationName
                                                ,strTicketNumber
                                                ,dtmTicketDateTime
                                                ,strCustomerReference
                                                ,strDistributionOption, dblUCost
                                                ,dblQtyReceived,@intCommodityId,strCurrency 
                                FROM (
                                                SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
                                                                ,cl.strLocationName
                                                                ,st.strTicketNumber
                                                                ,st.dtmTicketDateTime
                                                                ,strCustomerReference
                                                                ,'Spot Sale' strDistributionOption
                                                                ,null as intContractHeaderId
                                                                ,null as strContractNumber
                                                                ,isi.dblUnitPrice AS dblUCost
                                                                ,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
                                                                ,st.intCommodityId
                                                                ,R.dblPayment as dblQtyReceived,
                                                                isi.intItemUOMId as intUnitMeasureId,cur.strCurrency
                                                FROM tblICInventoryShipment ici
                                                INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
                                                INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
                                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
                                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
                                                                                                                                                                AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                                LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
                                                LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
                                                WHERE intOrderType IN (4)
                                                                AND intSourceType = 1
                                                                AND st.intCommodityId = @intCommodityId
                                                                AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
                                                                AND st.intEntityId= @intVendorId  and st.strTicketStatus <> 'V'   
                                                ) t            
                                                                
                INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strCurrency)

                SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,
                                                intContractHeaderId,strContractNumber
                                                ,strTicketNumber
                                                ,dtmTicketDateTime
                                                ,strCustomerReference
                                                ,strDistributionOption, dblUnitCost
                                                ,dblQtyReceived,@intCommodityId,strCurrency                                
                                FROM (
                                                SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
                                                                ,cl.strLocationName
                                                                ,st.strTicketNumber
                                                                ,st.dtmTicketDateTime
                                                                ,strCustomerReference
                                                                ,'Contract' strDistributionOption
                                                                ,cd.intContractHeaderId
                                                                ,cd.strContractNumber
                                                                ,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
                                                                ,R.dblAmountDue dblQtyReceived
                                                                ,st.intCommodityId,cd.intUnitMeasureId,cur.strCurrency
                                                FROM tblICInventoryShipment ici
                                                INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
                                                INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')                                  
                                                INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
                                                                                                                                                                                                                AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=cd.intCurrencyId
                                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
                                                LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
                                                LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
                                                WHERE intOrderType IN (1) AND intSourceType = 1          AND st.intCommodityId = @intCommodityId
                                                                AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end          
                                                                AND st.intEntityId= @intVendorId             and st.strTicketStatus <> 'V'
                                                ) t
                                
UNION 

                                SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber
                                                ,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption, dblUnitCost,dblQtyReceived,@intCommodityId,strCurrency
                                                
                                FROM (
                                                SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
                                                                ,cl.strLocationName
                                                                ,st.strTicketNumber
                                                                ,st.dtmTicketDateTime
                                                                ,strCustomerReference
                                                                ,'Spot Sale' strDistributionOption
                                                                ,null as intContractHeaderId
                                                                ,null as strContractNumber
                                                                ,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
                                                                ,st.intCommodityId
                                                                ,R.dblAmountDue dblQtyReceived,
                                                                isi.intItemUOMId as intUnitMeasureId,cur.strCurrency
                                                FROM tblICInventoryShipment ici
                                                INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
                                                INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
                                                                                                                                                                                                                AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
                                                                                                                                WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
                                                                                                                                WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
                                                                                                                                ELSE isnull(ysnLicensed, 0) END)
                                                INNER JOIN tblSMCurrency cur on cur.intCurrencyID=st.intCurrencyId
                                                INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
                                                LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
                                                LEFT JOIN tblARPaymentDetail R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblPayment, 0)>0
                                                WHERE intOrderType IN (4)
                                                                AND intSourceType = 1
                                                                AND st.intCommodityId = @intCommodityId
                                                                AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
                                                                AND st.intEntityId= @intVendorId  and st.strTicketStatus <> 'V'   
                                                ) t            

                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)

                select strCommodityCode,'NP Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
                                                                                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType
                                                                                FROM @tempFinal where strType='Net Payable  ($)' and intCommodityId=@intCommodityId

                INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
                strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId,strContractType)
                select @strDescription,'NR Un-Paid Quantity' strType,dblTotal/case when isnull(dblUnitCost,0)=0 then 1 else dblUnitCost end,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
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
                UNION

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