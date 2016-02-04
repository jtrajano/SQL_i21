CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
		 @intCommodityId nvarchar(max)
		,@intLocationId int = NULL
AS

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
	 
DECLARE @tempFinal AS TABLE (
		 intRow INT IDENTITY(1,1),
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
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
)

DECLARE @Final AS TABLE (

		 intRow INT IDENTITY(1,1),
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
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
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intOneCommodityId int

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
IF  @intCommodityId >0
BEGIN
INSERT INTO @tempFinal (strCommodityCode,strContractNumber,strType,strLocationName,strContractEndMonth,dblTotal)
	SELECT strCommodityCode,strContractNumber
		,strContractType+ ' ' + strPricingType [strType]
		,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,isnull(dblBalance, 0) AS dblTotal
	FROM vyuCTContractDetailView  
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

-- Hedge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,dblTotal)		
	SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge',strLocationName, strFutureMonth,HedgedQty
	FROM (
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end	

		
		UNION ALL
		
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,-(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end
			
		) t	

	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal)
	SELECT @strDescription,'Cash Exposure' [strType]
		,(isnull(invQty, 0) - isnull(ReserveQty, 0)) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + (((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) * isnull(dblContractSize,0)) AS dblTota

	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				WHERE i1.intCommodityId  = @intCommodityId
					AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end					
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i1.intCommodityId  = @intCommodityId
					AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
				) AS ReserveQty
			,(
				SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
				FROM tblCTContractDetail CD
				INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
					AND PT.intPricingTypeId IN (
						1
						,3
						)
				INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				WHERE CH.intCommodityId  = @intCommodityId
					AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
				) AS OpenPurQty
			,(
				SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
				FROM tblCTContractDetail CD
				INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
					AND PT.intPricingTypeId IN (
						1
						,3
						)
				INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				WHERE CH.intCommodityId  = @intCommodityId
					AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
				) AS OpenSalQty
			,(
				SELECT TOP 1 rfm.dblContractSize AS dblContractSize
				FROM tblRKFutOptTransaction otr
				INNER JOIN tblRKFutureMarket rfm ON rfm.intFutureMarketId = otr.intFutureMarketId
				WHERE otr.intCommodityId  = @intCommodityId
				AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				GROUP BY rfm.intFutureMarketId
					,rfm.dblContractSize
				) dblContractSize
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Sell'
					AND otr.intCommodityId  = @intCommodityId
					AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				) FutSBalTransQty
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Buy'
					AND otr.intCommodityId  = @intCommodityId
					AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				) AS FutLBalTransQty
			,(
				SELECT SUM(psd.dblMatchQty)
				FROM tblRKMatchFuturesPSHeader psh
				INNER JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
				WHERE psh.intCommodityId  = @intCommodityId				
					AND psh.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then psh.intCompanyLocationId else @intLocationId end
				) FutMatchedQty
		FROM tblICCommodity c
		WHERE c.intCommodityId  = @intCommodityId
		) t
	

	
	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal)
	SELECT @strDescription,
		'Basis Exposure' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) AS dblTotal
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) + CASE 
				WHEN (
						SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
						FROM tblRKCompanyPreference
						) = 1
					THEN OffSite
				ELSE 0
				END + CASE 
				WHEN (
						SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
						FROM tblRKCompanyPreference
						) = 1
					THEN DP
				ELSE 0
				END + dblCollatralSales + SlsBasisDeliveries AS CompanyTitled
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT isnull((
						SELECT sum(isnull(it1.dblUnitOnHand, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						WHERE i1.intCommodityId  = @intCommodityId
							AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
						), 0) AS invQty
				,isnull((
						SELECT SUM(isnull(sr1.dblQty, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
						WHERE i1.intCommodityId  = @intCommodityId
							AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
						), 0) AS ReserveQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS OpenPurchasesQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 2
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end
						
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					) AS DP
				,(
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) AS dblCollatralSales
					FROM (
						SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c1
						INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c1.intCommodityId  = @intCommodityId							
							AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					) AS dblCollatralSales
				,(
					SELECT isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
						AND cd.intPricingTypeId = 2
						AND ri.intOrderId = 1
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					WHERE ch.intCommodityId  = @intCommodityId
						AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		) t1
	
INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strContractEndMonth,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived
			)
	SELECT @strDescription, 'Net Payable  ($)' [strType],dblUnitCost - dblQtyReceived AS dblTotal
		,intInventoryReceiptItemId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strContractEndMonth
			,strCustomerReference
			,strDistributionOption, 
			 dblUnitCost
			,dblQtyReceived			
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ri.dblLineTotal AS dblUnitCost
				,ch.strContractNumber
				,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived				
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1	AND strReceiptType IN ('Purchase Contract')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) AS t
		
		UNION 
		
		SELECT @strDescription, 'NP Un-Paid Quantity' [strType],dblUnitCost - dblQtyReceived AS dblTotal
			,intInventoryReceiptItemId,'' as strContractNumber, strLocationName,strTicketNumber,dtmTicketDateTime,'' as strContractEndMonth,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived	
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.strTicketNumber,st.dtmTicketDateTime,strCustomerReference
				,strDistributionOption,ri.dblLineTotal AS dblUnitCost
				,(	SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
				 ) AS dblQtyReceived,st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1	AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId	AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) AS t
		

		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strContractEndMonth,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived
			)
		SELECT DISTINCT @strDescription, 'NP Un-Paid Quantity' [strType],dblOrderQty - dblBillQty AS dblTotal,ri.intInventoryReceiptItemId,ch.strContractNumber,cl.strLocationName
						,st.strTicketNumber,st.dtmTicketDateTime,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,strCustomerReference,strDistributionOption,dblOrderQty AS dblUnitCost,dblBillQty AS dblQtyReceived
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1	AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId
			AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end	
		

		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived)
		
		SELECT DISTINCT @strDescription, 'Net Payable  ($)' [strType],dblOrderQty - dblBillQty AS dblTotal,ri.intInventoryReceiptItemId,cl.strLocationName,st.strTicketNumber,st.dtmTicketDateTime,'' as strContractEndMonth,strCustomerReference,strDistributionOption
			,dblOrderQty AS dblUnitCost,dblBillQty AS dblQtyReceived
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1	AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId 
		AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end	
		
		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
				strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived
		)	
		
		SELECT @strDescription, 'Net Receivable  ($)' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strContractNumber
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ch.strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
				,st.intCommodityId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	

			) t
		
		UNION ALL
		
		SELECT @strDescription, 'Net Receivable  ($)' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strContractNumber
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
		
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,'' as strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
			) t
			
	
			INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,strContractNumber,strTicketNumber,dtmTicketDateTime,
				strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived)	

		   SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strContractNumber
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ch.strContractNumber
				,isi.dblQuantity AS dblUnitCost
				,(
					SELECT isnull(SUM(I.dblQtyShipped), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t
		
		UNION ALL
		
		SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,'' strContractNumber
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,isi.dblQuantity AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(I.dblQtyShipped), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t

	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal)
	SELECT @strDescription
		,'Avail for Spot Sale' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) - isnull(ReceiptProductQty, 0) AS dblTotal
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) + CASE 
				WHEN (
						SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
						FROM tblRKCompanyPreference
						) = 1
					THEN OffSite
				ELSE 0
				END + CASE 
				WHEN (
						SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
						FROM tblRKCompanyPreference
						) = 1
					THEN DP
				ELSE 0
				END + dblCollatralSales + SlsBasisDeliveries AS CompanyTitled
			,ReceiptProductQty
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT (
					SELECT sum(isnull(it1.dblUnitOnHand, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i1.intCommodityId  = @intCommodityId
						AND il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end						
					) AS invQty
				,(
					SELECT SUM(isnull(sr1.dblQty, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					WHERE i1.intCommodityId  = @intCommodityId
						AND il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
					) AS ReserveQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS ReceiptProductQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS OpenPurchasesQty --req              
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 2
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					) AS DP
				,(
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) AS dblCollatralSales
					FROM (
						SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c1
						INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c1.intCommodityId  = @intCommodityId
							AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					) AS dblCollatralSales
				,(
					SELECT isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
						AND cd.intPricingTypeId = 2
						AND ri.intOrderId = 1
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					WHERE ch.intCommodityId  = @intCommodityId
						AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		)t1

DECLARE @intUnitMeasureId int
DECLARE @intFromCommodityUnitMeasureId int
DECLARE @intToCommodityUnitMeasureId int
DECLARE @StrUnitMeasure nvarchar(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'') <> ''
BEGIN
	SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId = @intCommodityId
	SELECT @StrUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
END
ELSE
BEGIN
	SELECT @StrUnitMeasure=c.strUnitMeasure
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	join tblICUnitMeasure c on c.intUnitMeasureId=cuc.intUnitMeasureId 	
	WHERE t.intCommodityId  = @intCommodityId
END

BEGIN

		IF ISNULL(@intUnitMeasureId, 0) <> 0
		BEGIN
		INSERT INTO @Final (strCommodityCode ,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractEndMonth, 
		 dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived )
		
		SELECT strCommodityCode ,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractEndMonth, 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) dblTotal,
		 @StrUnitMeasure as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived 
		FROM @tempFinal ORDER BY strCommodityCode,CONVERT(DATETIME,'01 '+ strContractEndMonth) asc

		END
		ELSE
		BEGIN
		INSERT INTO @Final (strCommodityCode ,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractEndMonth,dblTotal,strUnitMeasure 
			,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived)
			SELECT strCommodityCode ,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractEndMonth,dblTotal,@StrUnitMeasure as strUnitMeasure 
			,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived
			 FROM @tempFinal ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) asc
		END
END	
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END

UPDATE @Final set intSeqNo = 1 where strType='Purchase Priced'
UPDATE @Final set intSeqNo = 2 where strType='Purchase Basis'
UPDATE @Final set intSeqNo = 3 where strType='Purchase HTA'
UPDATE @Final set intSeqNo = 4 where strType='Sale Priced'
UPDATE @Final set intSeqNo = 5 where strType='Sale Basis'
UPDATE @Final set intSeqNo = 6 where strType='Sale HTA'
UPDATE @Final set intSeqNo = 7 where strType='Net Hedge'
UPDATE @Final set intSeqNo = 8 where strType='Cash Exposure'
UPDATE @Final set intSeqNo = 9 where strType='Basis Exposure'
UPDATE @Final set intSeqNo = 10 where strType='Net Payable  ($)'
UPDATE @Final set intSeqNo = 11 where strType='NP Un-Paid Quantity'
UPDATE @Final set intSeqNo = 12 where strType='Net Receivable  ($)'
UPDATE @Final set intSeqNo = 13 where strType='NR Un-Paid Quantity'
UPDATE @Final set intSeqNo = 14 where strType='Avail for Spot Sale'

SELECT intSeqNo,intRow, strCommodityCode ,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractEndMonth,dblTotal,strUnitMeasure 
			,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived			
FROM @Final
--WHERE isnull(dblTotal,0) <> 0
 ORDER BY strCommodityCode,intSeqNo,CONVERT(DATETIME,'01 '+ strContractEndMonth) ASC