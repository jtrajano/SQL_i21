CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodity] 
	 @intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@dtmToDate datetime = NULL
AS

DECLARE @tblGetOpenContractDetail TABLE (
		intRowNum int, 
		strCommodityCode  nvarchar(100),
		intCommodityId int, 
		intContractHeaderId int, 
	    strContractNumber  nvarchar(100),
		strLocationName  nvarchar(100),
		dtmEndDate datetime,
		dblBalance DECIMAL(24,10),
		intUnitMeasureId int, 	
		intPricingTypeId int,
		intContractTypeId int,
		intCompanyLocationId int,
		strContractType  nvarchar(100), 
		strPricingType  nvarchar(100),
		intCommodityUnitMeasureId int,
		intContractDetailId int,
		intContractStatusId int,
		intEntityId int,
		intCurrencyId int,
		strType	  nvarchar(100),
		intItemId int,
		strItemNo  nvarchar(100),
		dtmContractDate datetime,
		strEntityName  nvarchar(100),
		strCustomerContract  nvarchar(100)
		,intFutureMarketId int
		,intFutureMonthId int)

INSERT INTO @tblGetOpenContractDetail (intRowNum,strCommodityCode,intCommodityId,intContractHeaderId,strContractNumber,strLocationName,dtmEndDate,dblBalance,intUnitMeasureId,intPricingTypeId,intContractTypeId,
	   intCompanyLocationId,strContractType,strPricingType,intCommodityUnitMeasureId,intContractDetailId,intContractStatusId,intEntityId,intCurrencyId,strType,intItemId,strItemNo ,dtmContractDate,strEntityName,strCustomerContract
	   ,intFutureMarketId,intFutureMonthId)
EXEC uspRKDPRContractDetail 0, @dtmToDate

SELECT 	s.dblQuantity dblTotal,i.intItemId,s.strLocationName,s.strItemNo,s.intLocationId intLocationId,i.intCommodityId into #invQty
	FROM vyuICGetInventoryValuation s  		
	JOIN tblICItem i on i.intItemId=s.intItemId
	JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   		  
	WHERE  iuom.ysnStockUnit=1 AND ISNULL(s.dblQuantity,0) <>0
				and convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)

SELECT * into #tempCollateral FROM (
		SELECT  ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmTransactionDate DESC) intRowNum,intCollateralId,co.intCommodityId,intLocationId,c.intContractHeaderId,
		c.dblRemainingQuantity dblRemainingQuantity,c.intUnitMeasureId,ch.intContractTypeId
		FROM tblRKCollateralHistory c
		JOIN tblICCommodity co on co.intCommodityId=c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c.intCommodityId AND c.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch on c.intContractHeaderId=ch.intContractHeaderId and ch.intContractStatusId <> 3
		WHERE  convert(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 									
		) a where   a.intRowNum =1

DECLARE @tblGetOpenFutureByDate TABLE (
		intFutOptTransactionId int, 
		intOpenContract  int)
INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId,intOpenContract)
EXEC uspRKGetOpenContractByDate 0, @dtmToDate

DECLARE @tblGetStorageDetailByDate TABLE (
		intRowNum int, 
		intCustomerStorageId int,
		intCompanyLocationId int	
		,[Loc] nvarchar(100)
		,[Delivery Date] datetime
		,[Ticket] nvarchar(100)
		,intEntityId int
		,[Customer] nvarchar(100)
		,[Receipt] nvarchar(100)
		,[Disc Due] numeric(24,10)
		,[Storage Due] numeric(24,10)
		,[Balance] numeric(24,10)
		,intStorageTypeId int
		,[Storage Type] nvarchar(100)
		,intCommodityId int
		,[Commodity Code] nvarchar(100)
		,[Commodity Description] nvarchar(100)
		,strOwnedPhysicalStock nvarchar(100)
		,ysnReceiptedStorage bit
		,ysnDPOwnedType bit
		,ysnGrainBankType bit
		,ysnCustomerStorage bit
		,strCustomerReference  nvarchar(100)
 		,dtmLastStorageAccrueDate  datetime
 		,strScheduleId nvarchar(100)
		,strItemNo nvarchar(100)
		,strLocationName nvarchar(100)
		,intCommodityUnitMeasureId int
		,intItemId int)

INSERT INTO @tblGetStorageDetailByDate
EXEC uspRKGetStorageDetailByDate 0, @dtmToDate
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
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intContractStatusId <> 3 
			AND cd.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND cd.intPricingTypeId IN (1, 3)
			WHERE cd.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = cd.intCompanyLocationId
			) t
		) AS OpenPurQty
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail CD
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 
			AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 3)
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
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
			WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
			) t
		) AS OpenPurchasesQty
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail CD
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 2)
			WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
			) t
		) AS OpenSalesQty
	,(
		 select  sum(Qty) from(
		SELECT (dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(dblTotal,0))) AS Qty
		FROM #invQty s
		JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=s.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   
		WHERE s.intLocationId = cl.intCompanyLocationId AND s.intCommodityId = c.intCommodityId AND iuom.ysnStockUnit = 1 
		) t)AS invQty
	,isnull((
			SELECT isnull(SUM(dblRemainingQuantity), 0) CollateralPurchase
			FROM (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((SUM(dblRemainingQuantity)), 0)) dblRemainingQuantity
					,intContractHeaderId
				FROM #tempCollateral c2
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c2.intCommodityId AND c2.intUnitMeasureId = ium.intUnitMeasureId
				WHERE c2.intContractTypeId = 2 AND c2.intCommodityId = c.intCommodityId AND c2.intLocationId = cl.intCompanyLocationId
				GROUP BY intContractHeaderId
					,ium.intCommodityUnitMeasureId
				) t
			), 0) AS dblCollatralSales
	,isnull((
			SELECT isnull(SUM(dblRemainingQuantity), 0) CollateralSale
			FROM (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(dblRemainingQuantity, 0)) dblRemainingQuantity
					,intContractHeaderId
				FROM #tempCollateral c2
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c2.intCommodityId AND c2.intUnitMeasureId = ium.intUnitMeasureId
				WHERE c2.intContractTypeId=1 AND c2.intCommodityId = c.intCommodityId AND c2.intLocationId = cl.intCompanyLocationId
				) t
			), 0) AS dblCollatralPurchase
	,(
		SELECT sum(SlsBasisDeliveries)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(ri.dblQuantity, 0)) AS SlsBasisDeliveries
			FROM tblICInventoryTransaction it
			join tblICInventoryShipment r on r.strShipmentNumber=it.strTransactionId  
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
			WHERE cd.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId
				and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			) t
		) AS SlsBasisDeliveries
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM @tblGetStorageDetailByDate s
			WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId
			) t
		) AS OffSite
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM @tblGetStorageDetailByDate s
			WHERE s.intCommodityId = c.intCommodityId AND ysnDPOwnedType = 1 AND s.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END
			) t
		) AS DP
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM @tblGetStorageDetailByDate s
			WHERE s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId AND strOwnedPhysicalStock = 'Customer' AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END
			
			UNION ALL
			SELECT SUM(dblTotal)  dblTotal from(
			SELECT distinct    dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId,((SCT.dblNetUnits * SCDS.dblSplitPercent) / 100)) dblTotal
			FROM tblSCDeliverySheet SCD 
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 					
			INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId --and SC.intEntityId=SCDS.intEntityId
			INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
			INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 				
			WHERE
			 isnull(GR.intStorageScheduleTypeId,0) > 0 and isnull(SCD.ysnPost,0) =1 and 
			 SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId 
			 AND l.intCompanyLocationId = cl.intCompanyLocationId AND strOwnedPhysicalStock = 'Customer' AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			 ) t where dblTotal >0 
			 UNION ALL
			 SELECT SUM(dblTotal)  dblTotal from(
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, ((SCT.dblNetUnits * SCDS.dblSplitPercent) / 100)) dblTotal
			FROM tblSCDeliverySheet SCD
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
			INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
			INNER JOIN tblICItem i ON i.intItemId = SCT.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			INNER JOIN tblSMCompanyLocation l ON SCT.intProcessingLocationId = l.intCompanyLocationId
			INNER JOIN tblEMEntity E ON E.intEntityId = SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
			WHERE SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId AND l.intCompanyLocationId = cl.intCompanyLocationId 
			AND strOwnedPhysicalStock = 'Customer' AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			and isnull(SCD.ysnPost,0) =0 AND GR.intStorageScheduleTypeId > 0
			) t where dblTotal >0 
			)t1
		) AS DPCustomer
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM @tblGetStorageDetailByDate s
			WHERE s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END
			
			UNION ALL
			
			SELECT SUM(dblTotal)  dblTotal from(
			SELECT distinct   GR1.intCustomerStorageId,E.intEntityId, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId,GR1.dblUnits) dblTotal
			FROM tblSCDeliverySheet SCD 
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
			INNER JOIN tblGRStorageHistory GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId
			INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId and GR1.intEntityId=SCDS.intEntityId
			INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
			INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 				
			WHERE
			 isnull(GR.intStorageScheduleTypeId,0) > 0 and isnull(SCD.ysnPost,0) =1 and 
			 SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId 
			 AND l.intCompanyLocationId = cl.intCompanyLocationId  AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			 ) t where dblTotal >0 
			 UNION ALL
			 SELECT SUM(dblTotal)  dblTotal from(
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, ((SCT.dblNetUnits * SCDS.dblSplitPercent) / 100)) dblTotal
			FROM tblSCDeliverySheet SCD
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
			INNER JOIN tblSCDeliverySheetHistory SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
			INNER JOIN tblICItem i ON i.intItemId = SCT.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			INNER JOIN tblSMCompanyLocation l ON SCT.intProcessingLocationId = l.intCompanyLocationId
			INNER JOIN tblEMEntity E ON E.intEntityId = SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
			WHERE SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId AND l.intCompanyLocationId = cl.intCompanyLocationId 
			 AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			and isnull(SCD.ysnPost,0) =0 AND GR.intStorageScheduleTypeId > 0	
			) t where dblTotal >0 
			)t1
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
			FROM tblICInventoryTransaction it
			join tblICInventoryReceipt r on r.strReceiptNumber=it.strTransactionId
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
			INNER JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = st.intProcessingLocationId
			WHERE cd.intCommodityId = c.intCommodityId AND cl1.intCompanyLocationId = cl.intCompanyLocationId
				and convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
			) t
		) AS PurBasisDelivary
	,(
		SELECT sum(dblTotal)
		FROM (
			(
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(st.dblNetUnits, 0)) AS dblTotal
				FROM tblSCTicket st
				JOIN tblICItem i1 ON i1.intItemId = st.intItemId AND st.strDistributionOption = 'HLD'
				JOIN tblICItemUOM iuom ON i1.intItemId = iuom.intItemId AND ysnStockUnit = 1
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i1.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
				WHERE st.intCommodityId = c.intCommodityId AND st.intProcessingLocationId = cl.intCompanyLocationId AND st.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN st.intEntityId ELSE @intVendorId END AND isnull(st.intDeliverySheetId, 0) = 0
				)
			) t
		) AS OnHold
INTO #Physical
FROM tblSMCompanyLocation cl
JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId AND lo.intLocationId IN (
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
		)
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

SELECT DISTINCT c.intCommodityId
	,strLocationName
	,intLocationId
	,strCommodityCode
	,u.intUnitMeasureId
	,u.strUnitMeasure
	,(
		SELECT SUM(dblNetHedge) dblNetHedge
		FROM (
			SELECT CASE WHEN ft.strBuySell = 'Buy' THEN (
								ft.intNoOfContract - isnull((
										SELECT sum(intMatchQty)
										FROM tblRKOptionsMatchPnS l
										WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId
										), 0)
								) ELSE - (
							ft.intNoOfContract - isnull((
									SELECT sum(intMatchQty)
									FROM tblRKOptionsMatchPnS s
									WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId
									), 0)
							) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
						), 0) * m.dblContractSize AS dblNetHedge
			FROM tblRKFutOptTransaction ft
			INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId AND ft.intLocationId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			INNER JOIN tblSMCompanyLocation l ON ft.intLocationId = l.intCompanyLocationId
			INNER JOIN tblICCommodity ic ON ft.intCommodityId = ic.intCommodityId
			INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			WHERE ft.intCommodityId = c.intCommodityId AND intLocationId = cl.intCompanyLocationId AND ft.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN ft.intEntityId ELSE @intVendorId END AND intFutOptTransactionId NOT IN (
					SELECT intFutOptTransactionId
					FROM tblRKOptionsPnSExercisedAssigned
					) AND intFutOptTransactionId NOT IN (
					SELECT intFutOptTransactionId
					FROM tblRKOptionsPnSExpired
					)
			) t
		) dblOptionNetHedge
	,(
		SELECT sum(dblNetHedge) dblFutNetHedge
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END * dblContractSize) AS dblNetHedge
			FROM @tblGetOpenFutureByDate oc
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
			WHERE ic.intCommodityId = c.intCommodityId AND f.intLocationId = cl.intCompanyLocationId AND f.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN f.intEntityId ELSE @intVendorId END
			) t
		) dblFutNetHedge
INTO #Future
FROM tblSMCompanyLocation cl
JOIN tblRKFutOptTransaction lo ON lo.intLocationId = cl.intCompanyLocationId AND lo.intLocationId IN (
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
		)
JOIN tblICCommodity c ON c.intCommodityId = lo.intCommodityId
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

SELECT DISTINCT ISNULL(a.intCommodityId, b.intCommodityId) intCommodityId
	,isnull(a.intLocationId, b.intLocationId) intLocationId
	,isnull(a.strCommodityCode, b.strCommodityCode) strCommodityCode
	,isnull(a.strLocationName, b.strLocationName) strLocationName
	,isnull(a.intUnitMeasureId, b.intUnitMeasureId) intUnitMeasureId
	,isnull(a.strUnitMeasure, b.strUnitMeasure) strUnitMeasure
	,a.OpenPurQty
	,a.OpenSalQty
	,a.ReceiptProductQty
	,a.OpenPurchasesQty
	,a.OpenSalesQty
	,invQty
	,dblCollatralSales
	,dblCollatralPurchase
	,SlsBasisDeliveries
	,OffSite
	,DP
	,DPCustomer
	,dblGrainBalance
	,PurBasisDelivary
	,OnHold
	,b.dblFutNetHedge
	,b.dblOptionNetHedge
INTO #TempContractFutByLocation
FROM #Physical a
FULL JOIN #Future b ON a.intLocationId = b.intLocationId AND a.intCommodityId = b.intCommodityId

SELECT strLocationName
	,OpenPurchasesQty
	,OpenSalesQty
	,intCommodityId
	,strCommodityCode
	,intUnitMeasureId
	,strUnitMeasure
	,isnull(CompanyTitled, 0) - (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0)) AS dblCompanyTitled
	,isnull(CashExposure, 0) AS dblCaseExposure
	,isnull(CompanyTitled, 0) AS dblBasisExposure
	,isnull(CompanyTitled, 0) - isnull(ReceiptProductQty, 0) AS dblAvailForSale
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
		,isnull(invQty, 0) + CASE WHEN (
					SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN isnull(OffSite, 0) ELSE 0 END + CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN 0 ELSE - isnull(DP, 0) END + (isnull(dblCollatralPurchase, 0) - isnull(dblCollatralSales, 0)) + isnull(SlsBasisDeliveries, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0)) AS CompanyTitled
		,isnull(invQty, 0) - isnull(PurBasisDelivary, 0) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + isnull(dblCollatralSales, 0) + isnull(SlsBasisDeliveries, 0) + CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN 0 ELSE - isnull(DP, 0) END + isnull(dblOptionNetHedge, 0) + isnull(dblFutNetHedge, 0) AS CashExposure
		,isnull(ReceiptProductQty, 0) ReceiptProductQty
		,isnull(OpenPurchasesQty, 0) OpenPurchasesQty
		,isnull(OpenSalesQty, 0) OpenSalesQty
		,isnull(OpenPurQty, 0) OpenPurQty
		,CASE WHEN isnull(@intVendorId, 0) = 0 THEN 
		isnull(invQty, 0) + isnull(dblGrainBalance, 0) + isnull(OnHold, 0) 
			ELSE isnull(DPCustomer, 0) + isnull(OnHold, 0) END AS InHouse
	FROM (
		SELECT *
		FROM #TempContractFutByLocation
		) t
	) t1

DECLARE @intUnitMeasureId INT
DECLARE @strUnitMeasure NVARCHAR(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId
FROM tblRKCompanyPreference

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

IF isnull(@intVendorId, 0) = 0
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
		,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN t.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure
		,CASE WHEN ((isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN OpenPurchasesQty ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, OpenPurchasesQty)) END OpenPurchasesQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN OpenSalesQty ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, OpenSalesQty)) END OpenSalesQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblCompanyTitled ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblCompanyTitled)) END dblCompanyTitled
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblCaseExposure ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblCaseExposure)) END dblCaseExposure
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblBasisExposure ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblBasisExposure)) END OpenSalQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblAvailForSale ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblAvailForSale)) END dblAvailForSale
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblInHouse ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblInHouse)) END dblInHouse
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblBasisExposure ELSE Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblBasisExposure)) END dblBasisExposure
	FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
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