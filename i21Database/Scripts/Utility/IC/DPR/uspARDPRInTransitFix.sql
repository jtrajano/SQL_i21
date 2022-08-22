CREATE OR ALTER PROCEDURE uspARDprInTransitFix
AS 

-- Data fix from AR-14113
BEGIN TRY
	BEGIN TRANSACTION 

	DECLARE @InvoicesForSummaryLog InvoiceId
	DECLARE @intEntityUserSecurityId INT = 1

	INSERT INTO @InvoicesForSummaryLog
	(
		 strSourceTransaction
		,strBatchId
	)
	SELECT strTransactionId, strBatchNumber
	FROM 
		tblARPostResult
	WHERE 
		strTransactionId IN (
			SELECT 
				strTransactionNumber
			FROM 
				tblRKSummaryLog
			WHERE 
				strAction IN ('Unposted Invoice', 'Posted Invoice')
				AND strMessage = 'Transaction successfully posted.'
				AND strTransactionNumber NOT IN (SELECT strTransactionId FROM tblICInventoryTransaction)
			GROUP BY 
				strTransactionNumber
			HAVING 
				COUNT(strTransactionNumber) = 1
	)

	INSERT INTO tblRKSummaryLog
	(
		 strBatchId
		,dtmCreatedDate
		,strBucketType
		,intActionId
		,strAction
		,RKSL.strTransactionType
		,intTransactionRecordId
		,intTransactionRecordHeaderId
		,strDistributionType
		,strTransactionNumber
		,dtmTransactionDate
		,intContractDetailId
		,intContractHeaderId
		,intFutureMarketId
		,intFutureMonthId
		,intFutOptTransactionId
		,intCommodityId
		,intItemId
		,intProductTypeId
		,intOrigUOMId
		,intBookId
		,intSubBookId
		,intLocationId
		,strInOut
		,dblOrigNoOfLots
		,dblContractSize
		,dblOrigQty
		,dblPrice
		,intEntityId
		,intTicketId
		,intCurrencyId
		,intUserId
		,strNotes
		,strMiscField
		,ysnNegate
		,intRefSummaryLogId
	)
	SELECT
		strBatchId = IFSL.strBatchId
		,dtmCreatedDate
		,strBucketType
		,48
		,'Posted Invoice'
		,RKSL.strTransactionType
		,intTransactionRecordId
		,intTransactionRecordHeaderId
		,strDistributionType
		,strTransactionNumber
		,dtmTransactionDate
		,intContractDetailId
		,intContractHeaderId
		,intFutureMarketId
		,intFutureMonthId
		,intFutOptTransactionId
		,intCommodityId
		,intItemId
		,intProductTypeId
		,intOrigUOMId
		,intBookId
		,intSubBookId
		,intLocationId
		,'OUT'
		,dblOrigNoOfLots
		,dblContractSize
		,dblOrigQty * -1
		,dblPrice
		,intEntityId
		,intTicketId
		,intCurrencyId
		,intUserId
		,strNotes
		,strMiscField
		,ysnNegate
		,intRefSummaryLogId
	FROM 
		tblRKSummaryLog RKSL INNER JOIN @InvoicesForSummaryLog  IFSL
			ON RKSL.strTransactionNumber = IFSL.strSourceTransaction

	SELECT 
		strBatchId
		, strSourceTransaction
		, 'Without Valuation and has unposted entry in tblRKSummaryLog'
	FROM 
		@InvoicesForSummaryLog

	DELETE FROM @InvoicesForSummaryLog

	-- With Valuation
	INSERT INTO @InvoicesForSummaryLog
	(
		 strSourceTransaction
		,strBatchId
	)
	SELECT		ARPR.strTransactionId, ARPR.strBatchNumber
	FROM		tblARPostResult ARPR
	INNER JOIN	(
		select 
			t.strTransactionId
			,[valuation qty] = isnull(t2.dblQty, 0) 
			,[dpr qty] = isnull(r.dblQty, 0) 
		from 
			tblICItem i inner join tblICCommodity c
				on c.intCommodityId = i.intCommodityId
			outer apply (
				select distinct 
					t.strTransactionId
				from 
					tblICInventoryTransaction t 
				where
					t.intItemId = i.intItemId
					and t.intInTransitSourceLocationId is not null
			) t 

			outer apply (
				select 
					dblQty = sum(t2.dblQty) 
				from 
					tblICInventoryTransaction t2
				where
					t2.strTransactionId = t.strTransactionId
					and t2.intInTransitSourceLocationId is not null 
					and t2.dblQty <> 0 
					and t2.dblQty is not null 
			) t2

			outer apply (
				select 
					dblQty = sum(l.dblOrigQty) 
				from tblRKSummaryLog l
				where
					l.strTransactionNumber = t.strTransactionId
					and l.strBucketType = 'Sales In-Transit'
					and c.strCommodityCode IN ('Soybean Meal', 'Soybean Hull Pellets', 'Loose Soybean Hulls', 'Crude Soybean Oil', 'Soybeans', 'Transload Meal')
			) r 
		where
			c.strCommodityCode IN ('Soybean Meal', 'Soybean Hull Pellets', 'Loose Soybean Hulls', 'Crude Soybean Oil', 'Soybeans', 'Transload Meal')
			and isnull(t2.dblQty, 0) <> isnull(r.dblQty, 0) 
	) INVOICEFORLOGGING
	ON			ARPR.strTransactionId = INVOICEFORLOGGING.strTransactionId
	INNER JOIN tblARInvoice ARI
	ON ARPR.strTransactionId = ARI.strInvoiceNumber
	OUTER APPLY (
		SELECT	strBatchId, strTransactionNumber
		FROM	tblRKSummaryLog
		WHERE	strTransactionNumber = ARPR.strTransactionId
		AND		strBatchId	= ARPR.strBatchNumber
	) RKSL
	WHERE		RKSL.strBatchId IS NULL
	AND			ARPR.strMessage = 'Transaction successfully posted.'
	GROUP BY	ARPR.strTransactionId, ARPR.strBatchNumber

	SELECT strBatchId, strSourceTransaction, 'With Valuation'
	FROM @InvoicesForSummaryLog

	DECLARE @SummaryLogs AS RKSummaryLog 

	BEGIN 
		INSERT INTO @SummaryLogs (	
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordHeaderId
			,intTransactionRecordId
			,strTransactionNumber 
			,dtmTransactionDate 
			,intContractDetailId 
			,intContractHeaderId 
			,intTicketId 
			,intCommodityId 
			,intCommodityUOMId 
			,intItemId 
			,intBookId 
			,intSubBookId 
			,intLocationId 
			,intFutureMarketId 
			,intFutureMonthId 
			,dblNoOfLots 
			,dblQty 
			,dblPrice 
			,intEntityId 
			,ysnDelete 
			,intUserId 
			,strNotes
			,strDistributionType
			,intActionId
		)
		SELECT 
			strBatchId = IFSL.strBatchId
			,strBucketType = 
				CASE 
					WHEN t.strTransactionForm IN ('Inventory Receipt', 'Inventory Transfer', 'Inbound Shipments') THEN 'Purchase In-Transit'
					WHEN t.strTransactionForm IN ('Inventory Shipment', 'Outbound Shipment', 'Invoice') THEN 'Sales In-Transit'
				END 
			,strTransactionType = v.strTransactionType
			,intTransactionRecordHeaderId = t.intTransactionId
			,intTransactionRecordId = t.intTransactionDetailId
			,strTransactionNumber = t.strTransactionId
			,dtmTransactionDate = t.dtmDate
			,intContractDetailId = COALESCE(
				receipt.intContractDetailId
				, shipment.intContractDetailId
				, invoice.intContractDetailId
				, logistics.intContractDetailId
			)
			,intContractHeaderId = COALESCE(
				receipt.intContractHeaderId
				, shipment.intContractHeaderId
				, invoice.intContractHeaderId
				, logistics.intContractHeaderId
			)
			,intTicketId = v.intTicketId
			,intCommodityId = v.intCommodityId
			,intCommodityUOMId = commodityUOM.intCommodityUnitMeasureId
			,intItemId = t.intItemId
			,intBookId = NULL
			,intSubBookId = NULL
			,intLocationId = v.intLocationId
			,intFutureMarketId = NULL
			,intFutureMonthId = NULL
			,dblNoOfLots = NULL
			,dblQty = t.dblQty
			,dblPrice = t.dblCost
			,intEntityId = v.intEntityId
			,ysnDelete = 0
			,intUserId = @intEntityUserSecurityId
			,strNotes = t.strDescription
			,strDistributionType = ''
			,intActionId = 
					CASE	
					WHEN t.strTransactionForm = 'Produce' THEN 2
					WHEN t.strTransactionForm = 'Consume' THEN 3
					WHEN t.strTransactionForm = 'Inventory Transfer' THEN 4
					WHEN t.strTransactionForm = 'Inventory Receipt' THEN 
						CASE 
							WHEN contractDetail.strPricingType = 'Priced' THEN 5
							WHEN contractDetail.strPricingType = 'Basis' THEN 6
							WHEN contractDetail.strPricingType = 'DP (Priced Later)' THEN 45
							ELSE 8 -- Spot Priced
						END
					WHEN t.strTransactionForm = 'Inventory Shipment' THEN 
						CASE 
							WHEN contractDetail.strPricingType = 'Priced' THEN 10
							WHEN contractDetail.strPricingType = 'Basis' THEN 11
							--WHEN contractDetail.strPricingType = 'DP (Priced Later)' THEN 1
							ELSE 12 -- Spot Priced
						END
					WHEN t.strTransactionForm = 'Inventory Adjustment' THEN 				
						CASE 
							WHEN t.intTransactionTypeId = 10 THEN 20 --Inventory Adjustment - Quantity Change
							WHEN t.intTransactionTypeId = 14 THEN 21 --Inventory Adjustment - UOM Change
							WHEN t.intTransactionTypeId = 15 THEN 22 --Inventory Adjustment - Item Change
							WHEN t.intTransactionTypeId = 16 THEN 23 --Inventory Adjustment - Lot Status Change
							WHEN t.intTransactionTypeId = 17 THEN 24 --Inventory Adjustment - Split Lot
							WHEN t.intTransactionTypeId = 18 THEN 25 --Inventory Adjustment - Expiry Date Change
							WHEN t.intTransactionTypeId = 19 THEN 26 --Inventory Adjustment - Lot Merge
							WHEN t.intTransactionTypeId = 20 THEN 27 --Inventory Adjustment - Lot Move
							WHEN t.intTransactionTypeId = 43 THEN 28 --Inventory Adjustment - Ownership Change
							WHEN t.intTransactionTypeId = 47 THEN 29 --Inventory Adjustment - Opening Inventory
							WHEN t.intTransactionTypeId = 48 THEN 30 --Inventory Adjustment - Change Lot Weight
							ELSE NULL
						END 	
					WHEN t.strTransactionForm = 'Inbound Shipments' THEN 31			
					WHEN t.strTransactionForm = 'Outbound Shipment' THEN 32
					WHEN t.strTransactionForm = 'Invoice' AND  t.ysnIsUnposted = 0 THEN 48 --Posted Invoice
					WHEN t.strTransactionForm = 'Invoice' AND  t.ysnIsUnposted = 1 THEN 60 --Unposted Invoice
					ELSE 
						NULL
					END 
		FROM	
			tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
				ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICItemUOM iu
				ON iu.intItemUOMId = t.intItemUOMId
			INNER JOIN tblICUnitMeasure u
				ON u.intUnitMeasureId = iu.intUnitMeasureId
			INNER JOIN tblICCommodityUnitMeasure commodityUOM
				ON commodityUOM.intCommodityId = v.intCommodityId 
				AND commodityUOM.intUnitMeasureId = u.intUnitMeasureId	
			INNER JOIN @InvoicesForSummaryLog IFSL
				ON	t.strTransactionId = IFSL.strSourceTransaction
				AND t.strBatchId = IFSL.strBatchId

			OUTER APPLY (
				SELECT 
					intContractDetailId = ISNULL(ri.intContractDetailId, CASE WHEN r.strReceiptType IN ('Purchase Contract', 'Inventory Return') THEN ri.intLineNo ELSE NULL END ) 
					,intContractHeaderId = ISNULL(ri.intContractHeaderId, CASE WHEN r.strReceiptType IN ('Purchase Contract', 'Inventory Return') THEN ri.intOrderId ELSE NULL END )
				FROM 
					tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				WHERE
					t.strTransactionForm = 'Inventory Receipt'
					AND r.strReceiptNumber = t.strTransactionId
					AND ri.intInventoryReceiptId = t.intTransactionId
					AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
			) receipt

			OUTER APPLY (
				SELECT 
					intContractDetailId = si.intLineNo 
					,intContractHeaderId = si.intOrderId 
				FROM 
					tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
						ON s.intInventoryShipmentId = si.intInventoryShipmentId
				WHERE
					t.strTransactionForm = 'Inventory Shipment'
					AND s.strShipmentNumber = t.strTransactionId
					AND si.intInventoryShipmentId = t.intTransactionId
					AND si.intInventoryShipmentItemId = t.intTransactionDetailId
			) shipment

			OUTER APPLY (
				SELECT 
					intContractDetailId = invD.intContractDetailId
					,intContractHeaderId = invD.intContractHeaderId
				FROM 
					tblARInvoice inv INNER JOIN tblARInvoiceDetail invD
						ON inv.intInvoiceId = invD.intInvoiceId
				WHERE
					t.strTransactionForm = 'Invoice'
					AND inv.strInvoiceNumber = t.strTransactionId
					AND inv.intInvoiceId = t.intTransactionId
					AND invD.intInvoiceDetailId = t.intTransactionDetailId
			) invoice

			OUTER APPLY (
				SELECT
					l.strLoadNumber
					,ld.intPContractDetailId
					,cd.intContractHeaderId
					,cd.intContractDetailId
				FROM 
					tblLGLoad l
					INNER JOIN tblLGLoadDetail ld
						ON l.intLoadId = ld.intLoadId
					INNER JOIN tblCTContractDetail cd
						ON cd.intContractDetailId = ld.intPContractDetailId
					INNER JOIN tblCTContractHeader ch
						ON ch.intContractHeaderId = cd.intContractHeaderId
				WHERE
					t.strTransactionForm = 'Inbound Shipments'
					AND l.strLoadNumber = t.strTransactionId
					AND l.intLoadId = t.intTransactionId
					AND ld.intLoadDetailId = t.intTransactionDetailId
			) logistics 

			OUTER APPLY (
				SELECT 
					cd.intPricingTypeId
					,cPricingType.strPricingType
				FROM 
					tblCTContractHeader ch INNER JOIN tblCTContractDetail cd
						ON ch.intContractHeaderId = cd.intContractHeaderId
					INNER JOIN tblCTPricingType cPricingType
						ON cPricingType.intPricingTypeId = cd.intPricingTypeId
				WHERE
					ch.intContractHeaderId = COALESCE(
						receipt.intContractHeaderId
						, shipment.intContractHeaderId
						, invoice.intContractHeaderId
						, logistics.intContractHeaderId
					)
					AND cd.intContractDetailId = COALESCE(
						receipt.intContractDetailId
						, shipment.intContractDetailId
						, invoice.intContractDetailId 
						, logistics.intContractHeaderId
					)
			) contractDetail

		WHERE t.dblQty <> 0 
			AND t.intInTransitSourceLocationId IS NOT NULL 
			AND v.strTransactionType NOT IN ('Storage Settlement', 'Transfer Storage')
	END

	EXEC uspRKLogRiskPosition @SummaryLogs, 0, 0

	COMMIT TRANSACTION 

	RETURN 0
END TRY
BEGIN CATCH 
	DECLARE @msg AS VARCHAR(MAX) = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@msg, 11, 1) 

	RETURN -1
END CATCH
