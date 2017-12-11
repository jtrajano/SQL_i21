CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodity] 
	@intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
AS

DECLARE @tblFinalDetail TABLE (
	intRowNum INT
	,strLocationName NVARCHAR(500) COLLATE Latin1_General_CI_AS
	,intLocationId INT
	,intCommodityId INT
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,OpenPurchasesQty DECIMAL(24, 10)
	,OpenSalesQty DECIMAL(24, 10)
	,dblCompanyTitled DECIMAL(24, 10)
	,dblCaseExposure DECIMAL(24, 10)
	,OpenSalQty DECIMAL(24, 10)
	,dblAvailForSale DECIMAL(24, 10)
	,dblInHouse DECIMAL(24, 10)
	,dblBasisExposure DECIMAL(24, 10)
	)

DECLARE @strCommodity NVARCHAR(MAX)

SET @strCommodity = ''

SELECT @strCommodity = CASE WHEN @strCommodity = '' THEN LTRIM(intCommodityId) ELSE @strCommodity + ',' + LTRIM(intCommodityId) END
FROM tblICCommodity

IF isnull(@strCommodity, '') = ''
	RETURN

DECLARE @intCommodityId NVARCHAR(max) = ''

SELECT @intCommodityId = @strCommodity

DECLARE @Commodity AS TABLE (
	intCommodityIdentity INT IDENTITY(1, 1) PRIMARY KEY
	,intCommodity INT
	)

INSERT INTO @Commodity (intCommodity)
SELECT Item Collate Latin1_General_CI_AS
FROM [dbo].[fnSplitString](@intCommodityId, ',')

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
INSERT INTO @tblGetOpenContractDetail (strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType )
SELECT strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType 
FROM vyuRKContractDetail

SELECT strLocationName
	,OpenPurchasesQty
	,OpenSalesQty
	,intCommodityId
	,strCommodityCode
	,intUnitMeasureId
	,strUnitMeasure
	,isnull(CompanyTitled, 0)-(isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0)) AS dblCompanyTitled
	,isnull(CashExposure, 0) AS dblCaseExposure
	,isnull(CompanyTitled, 0)  AS dblBasisExposure
	,isnull(CompanyTitled, 0)  - isnull(ReceiptProductQty, 0) AS dblAvailForSale
	,isnull(InHouse, 0) AS dblInHouse
	,intLocationId
INTO #temp
FROM (
	SELECT strLocationName
		,intCommodityId
		,strCommodityCode
		,strUnitMeasure
		,intUnitMeasureId
		,intLocationId
		,isnull(invQty, 0)+ 
		 CASE WHEN (
					SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN isnull(OffSite, 0) ELSE 0 END + CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN 0 ELSE -isnull(DP ,0) END 
		+ (isnull(dblCollatralPurchase, 0) -isnull(dblCollatralSales, 0)) 
		 + isnull(SlsBasisDeliveries, 0) 
		 +(isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))
		 AS CompanyTitled
		,
		isnull(invQty, 0) 
		- isnull(PurBasisDelivary, 0)
		 + (isnull(OpenPurQty, 0)- isnull(OpenSalQty, 0))
		 + isnull(dblCollatralSales, 0) +
		  isnull(SlsBasisDeliveries, 0) 
				+CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN  0 ELSE -isnull(DP ,0)  END
					+isnull(dblPriceRisk1,0)+isnull(dblPriceRisk2,0)
		AS CashExposure
		,isnull(ReceiptProductQty, 0) ReceiptProductQty
		,isnull(OpenPurchasesQty, 0) OpenPurchasesQty
		,isnull(OpenSalesQty, 0) OpenSalesQty
		,isnull(OpenPurQty, 0) OpenPurQty
		,CASE WHEN isnull(@intVendorId, 0) = 0 THEN isnull(invQty, 0) + isnull(dblGrainBalance, 0) + isnull(OnHold, 0) --+ isnull(DP ,0)
			ELSE isnull(DPCustomer, 0) + isnull(OnHold, 0) END AS InHouse
	FROM (
		SELECT DISTINCT c.intCommodityId
			,strLocationName
			,intLocationId
			,strCommodityCode
			,u.intUnitMeasureId
			,u.strUnitMeasure
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((cd.dblBalance), 0)) AS Qty
					FROM @tblGetOpenContractDetail cd
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND 
							cd.intContractStatusId <> 3 AND cd.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND cd.intPricingTypeId IN (1, 2)
					WHERE cd.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = cd.intCompanyLocationId
					) t
				) AS OpenPurQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM @tblGetOpenContractDetail CD
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 2)
					WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenSalQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM @tblGetOpenContractDetail CD
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
					WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS ReceiptProductQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM @tblGetOpenContractDetail CD
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 
					AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
					WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenPurchasesQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM @tblGetOpenContractDetail CD
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 
						AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 2)
					WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenSalesQty
			,(		
				SELECT sum(s.dblOnHand) AS Qty
					FROM vyuICGetItemStockUOM s
					WHERE s.intLocationId = cl.intCompanyLocationId AND s.intCommodityId = c.intCommodityId AND ysnStockUnit=1
				
				) AS invQty

  				,isnull((
                    SELECT isnull(SUM(dblRemainingQuantity), 0) CollateralSale
                    FROM (
                            SELECT 
							dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, 
							isnull((SUM(dblRemainingQuantity)), 0)) dblRemainingQuantity
                                ,intContractHeaderId                                                
                            FROM tblRKCollateral c2
                            LEFT JOIN tblRKCollateralAdjustment ca ON c2.intCollateralId = ca.intCollateralId
                            JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c2.intCommodityId AND c2.intUnitMeasureId = ium.intUnitMeasureId
                            WHERE strType = 'Sales' AND c2.intCommodityId = c.intCommodityId AND c2.intLocationId = cl.intCompanyLocationId
                            GROUP BY intContractHeaderId
                                ,ium.intCommodityUnitMeasureId
                            ) t

                    ), 0) AS  dblCollatralSales
				,isnull((
                    SELECT isnull(SUM(dblRemainingQuantity), 0) CollateralSale
                    FROM (
                            SELECT 
							dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(dblRemainingQuantity,0)) dblRemainingQuantity
                                ,intContractHeaderId                                                
                            FROM tblRKCollateral c2
                            LEFT JOIN tblRKCollateralAdjustment ca ON c2.intCollateralId = ca.intCollateralId
                            JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c2.intCommodityId AND c2.intUnitMeasureId = ium.intUnitMeasureId
                            WHERE strType = 'Purchase' AND c2.intCommodityId = c.intCommodityId AND c2.intLocationId = cl.intCompanyLocationId

                            ) t

                    ), 0) AS dblCollatralPurchase
                     ,(
                           SELECT sum(SlsBasisDeliveries)
                           FROM (
                                  SELECT
								  dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0)) AS SlsBasisDeliveries
                                  FROM tblICInventoryShipment r
									INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
									INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2	
																				and cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
									JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
                                  WHERE cd.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId 
                                  ) t
                           ) AS SlsBasisDeliveries
                     ,(
                           SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
                                  FROM vyuGRGetStorageDetail s
                                  WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId 
                                  ) t
                           ) AS OffSite
                     ,(
                           SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
                                  FROM vyuGRGetStorageDetail s
                                  WHERE s.intCommodityId = c.intCommodityId AND ysnDPOwnedType = 1 AND s.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END 
                                  ) t
                           ) AS DP
                     ,(
                           SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
                                  FROM vyuGRGetStorageDetail s
                                  WHERE s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId AND strOwnedPhysicalStock = 'Customer' AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END 
                                  ) t
                           ) AS DPCustomer
                     ,(
                           SELECT Sum(dblTotal)
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
                                  FROM vyuGRGetStorageDetail s
                                  WHERE s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END 
                                  ) t
                           ) AS dblGrainBalance

                     ,(
                           SELECT sum(dblTotal) dblTotal
                           FROM (
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((PLDetail.dblLotPickedQty), 0)) AS dblTotal
                                  FROM tblLGDeliveryPickDetail Del
                                  INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
                                  INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
                                  INNER JOIN @tblGetOpenContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId AND CT.intContractStatusId <> 3
																	
                                  JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CT.intCommodityId AND CT.intUnitMeasureId = ium.intUnitMeasureId
                                  INNER JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = CT.intCompanyLocationId
                                  WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = c.intCommodityId AND cl1.intCompanyLocationId = cl.intCompanyLocationId 
                                  
                                  UNION
                                  
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(ri.dblReceived, 0)) AS dblTotal
                                  FROM tblICInventoryReceipt r
                                  INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
                                  INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
                                  INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
                                   JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
                                  INNER JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = st.intProcessingLocationId
                                  WHERE cd.intCommodityId = c.intCommodityId AND cl1.intCompanyLocationId = cl.intCompanyLocationId     
                                  ) t  
                           )  AS PurBasisDelivary
                     ,(
                           SELECT sum(dblTotal)
                           FROM (
                                  (
                                         SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(st.dblNetUnits, 0)) AS dblTotal
                                         FROM tblSCTicket st
                                         JOIN tblICItem i1 ON i1.intItemId = st.intItemId AND st.strDistributionOption = 'HLD'
                                         JOIN tblICItemUOM iuom ON i1.intItemId = iuom.intItemId AND ysnStockUnit = 1
                                         JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i1.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
                                         WHERE st.intCommodityId = c.intCommodityId AND st.intProcessingLocationId = cl.intCompanyLocationId AND st.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN st.intEntityId ELSE @intVendorId END 

						)
					) t
				) AS OnHold
				,(select sum(intOpenContract) intOpenContract
				 from(SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId, intOpenContract*dblContractSize) as intOpenContract 
				from vyuRKGetOpenContract otr  
				JOIN tblRKFutOptTransaction t on otr.intFutOptTransactionId=t.intFutOptTransactionId
				JOIN tblRKFutureMarket m on t.intFutureMarketId=m.intFutureMarketId
				JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and m.intUnitMeasureId=cuc1.intUnitMeasureId
				WHERE t.intCommodityId=c.intCommodityId
				AND t.intLocationId =  cl.intCompanyLocationId
				 )t) dblPriceRisk2 
		
			,(select sum(dblNoOfContract) from (SELECT 
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
				),0)*m.dblContractSize AS dblNoOfContract
			FROM tblRKFutOptTransaction ft
			INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
			INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
			INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
			INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			WHERE ft.intCommodityId = c.intCommodityId AND intLocationId =  cl.intCompanyLocationId AND intFutOptTransactionId NOT IN (
					SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired))t)
		AS dblPriceRisk1

		FROM tblSMCompanyLocation cl
		JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId and  lo.intLocationId  IN (
													SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
													WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
													ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICItem i ON lo.intItemId = i.intItemId
		JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
		LEFT JOIN tblICCommodityUnitMeasure um ON c.intCommodityId = um.intCommodityId
		LEFT JOIN tblICUnitMeasure u ON um.intUnitMeasureId = u.intUnitMeasureId
		WHERE ysnDefault = 1 
		GROUP BY c.intCommodityId
			,strCommodityCode
			,cl.intCompanyLocationId
			,cl.strLocationName
			,intLocationId
			,u.intUnitMeasureId
			,u.strUnitMeasure
			,um.intCommodityUnitMeasureId
		) t
	) t1


DECLARE @intUnitMeasureId INT
DECLARE @strUnitMeasure NVARCHAR(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId
FROM tblRKCompanyPreference

IF isnull(@intVendorId, 0) = 0
BEGIN
	SELECT @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUnitMeasureId

	INSERT INTO @tblFinalDetail
	SELECT DISTINCT convert(INT, row_number() OVER (ORDER BY t.intCommodityId,intLocationId)) intRowNum
		,t.strLocationName
		,intLocationId
		,t.intCommodityId
		,strCommodityCode
		,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN t.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure		
		,CASE WHEN ((isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN OpenPurchasesQty else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , OpenPurchasesQty)) end OpenPurchasesQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN OpenSalesQty else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , OpenSalesQty)) end OpenSalesQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblCompanyTitled else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblCompanyTitled)) end dblCompanyTitled
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblCaseExposure ELSE
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblCaseExposure)) end dblCaseExposure
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblBasisExposure ELSE
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblBasisExposure)) end OpenSalQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblAvailForSale else
		 Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblAvailForSale)) end dblAvailForSale
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblInHouse else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblInHouse))end dblInHouse
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblBasisExposure else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblBasisExposure)) end dblBasisExposure
	FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
	WHERE t.intCommodityId IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@intCommodityId, ',')
			) 
	ORDER BY strCommodityCode
END
ELSE
BEGIN
	SELECT @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUnitMeasureId

	INSERT INTO @tblFinalDetail
	SELECT DISTINCT convert(INT, row_number() OVER (
				ORDER BY t.intCommodityId
					,intLocationId
				)) intRowNum
		,t.strLocationName
		,intLocationId
		,t.intCommodityId
		,strCommodityCode
		,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure
		,0.00 OpenPurchasesQty
		,0.00 OpenSalesQty
		,0.00 dblCompanyTitled
		,0.00 dblCaseExposure
		,0.00 OpenSalQty
		,0.00 dblAvailForSale
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblInHouse)), 0) dblInHouse
		,0.00 dblBasisExposure
	FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
	WHERE t.intCommodityId IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@intCommodityId, ',')
			)
	ORDER BY strCommodityCode
END

SELECT intCommodityId
	,strCommodityCode
	,strUnitMeasure
	,sum(isnull(OpenPurchasesQty, 0)) OpenPurchasesQty
	,sum(isnull(OpenSalesQty, 0)) OpenSalesQty
	,sum(isnull(dblCompanyTitled, 0)) dblCompanyTitled
	,sum(isnull(dblCaseExposure, 0)) dblCaseExposure
	,sum(isnull(OpenSalQty, 0)) OpenSalQty
	,sum(isnull(dblAvailForSale, 0)) dblAvailForSale
	,sum(isnull(dblInHouse, 0)) dblInHouse
	,sum(isnull(dblBasisExposure, 0)) dblBasisExposure
FROM @tblFinalDetail
GROUP BY intCommodityId
	,strCommodityCode
	,strUnitMeasure