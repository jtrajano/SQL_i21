CREATE PROCEDURE [dbo].[uspRKRebuildSummaryLog]
	@intCurrentUserId INT	
AS

BEGIN TRY
	DECLARE @RebuildLogId INT
	
	INSERT INTO tblRKRebuildSummaryLog(dtmRebuildDate, intUserId, ysnSuccess)
	VALUES (GETDATE(), @intCurrentUserId, 0)
	
	SET @RebuildLogId = SCOPE_IDENTITY()

	IF EXISTS (SELECT TOP 1 1 FROM tblRKCompanyPreference WHERE ysnAllowRebuildSummaryLog = 0)
	BEGIN
		RAISERROR('You are not allowed to rebuild the Summary Log!', 16, 1)
	END
		
	-- Truncate table
	TRUNCATE TABLE tblRKSummaryLog
	TRUNCATE TABLE tblCTContractBalanceLog
	--Update ysnAllowRebuildSummaryLog to FALSE
	UPDATE tblRKCompanyPreference SET ysnAllowRebuildSummaryLog = 0
	
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKSummaryLog')
	BEGIN
		DECLARE @ExistingHistory AS RKSummaryLog

		--=======================================
		--				CONTRACTS
		--=======================================
		PRINT 'Populate RK Summary Log - Contract'
		
		DECLARE @cbLog AS CTContractBalanceLog

		DECLARE @dtmEndDate DATE = dbo.fnRemoveTimeOnDate(GETDATE())

		select 
			  CD.dtmCreated
			, CD.dtmEndDate
			, dblQuantity = CASE WHEN CH.ysnLoad = 1 THEN CD.intNoOfLoad * CD.dblQuantityPerLoad ELSE CD.dblQuantity  END
			, CD.intNoOfLoad
			, CD.dblQuantityPerLoad
			, strType = 'Contract Sequence'
			, CH.intContractTypeId
			, CH.intContractHeaderId
			, CH.strContractNumber
			, CD.intContractDetailId
			, CD.intContractSeq
			, PT.strPricingType
			, SH.intContractStatusId
			, CH.intEntityId
			, CH.intCommodityId
			, intUserId = CD.intCreatedById
		into #tmpContract
		from tblCTContractHeader CH 
		inner join tblCTContractDetail CD on CD.intContractHeaderId = CH.intContractHeaderId
		inner join tblCTPricingType PT on PT.intPricingTypeId = CH.intPricingTypeId
		cross apply (
			select top 1 * from tblCTSequenceHistory 
			where intContractHeaderId = CH.intContractHeaderId
				and intContractDetailId = CD.intContractDetailId
			order by intSequenceHistoryId
		) SH 
		where SH.intContractStatusId NOT IN (3,5,6)


		SELECT 
			dtmDate
			,dtmEndDate
			,dblQuantity
			,intNoOfLoad
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId
			,intSourceId
			,strSourceId 
			,intSourceDetailId
			,intCommodityId	
			,ysnLoad
			,dblQuantityPerLoad
			,intEntityId
			,intUserId
		INTO #tmpContractUsage
		FROM (
			SELECT CH.intContractTypeId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, dtmDate = Shipment.dtmShipDate
				, dtmEndDate = @dtmEndDate
				, dblQuantity = CASE WHEN CH.ysnLoad = 1 THEN  
									1 * CH.dblQuantityPerLoad
								ELSE
									ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intItemUOMId,ShipmentItem.intPriceUOMId
											, CASE WHEN ISNULL(INV.ysnPosted, 0) = 1 AND ShipmentItem.dblDestinationNet IS NOT NULL THEN 
													MAX(CASE WHEN CM.intInventoryShipmentItemId IS NULL THEN 
																ShipmentItem.dblDestinationNet * 1 
														ELSE 0 END)
													ELSE SUM(CASE WHEN CM.intInventoryShipmentItemId IS NULL THEN 
																		ShipmentItem.dblQuantity
															ELSE 0 END) 
												END), 0)
								END
				, dblAllocatedQuantity = 0.0000
				, intNoOfLoad = COUNT(DISTINCT Shipment.intInventoryShipmentId)
				, intSourceId = Shipment.intInventoryShipmentId
				, strSourceId = Shipment.strShipmentNumber
				, intSourceDetailId = ShipmentItem.intInventoryShipmentItemId
				, strType = 'Inventory Shipment'
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, intUserId = Shipment.intEntityId
			FROM tblICInventoryShipment Shipment
			JOIN tblICInventoryShipmentItem ShipmentItem ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = ShipmentItem.intOrderId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = ShipmentItem.intLineNo AND CD.intContractHeaderId = CH.intContractHeaderId
			LEFT JOIN (
				SELECT DISTINCT ID.intInventoryShipmentItemId
					, IV.ysnPosted
				FROM tblARInvoice IV INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
			) INV ON INV.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
			LEFT JOIN (
				SELECT DISTINCT ID.intInventoryShipmentItemId
				FROM tblARInvoice IV
				INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
				WHERE IV.strTransactionType = 'Credit Memo'
					AND IV.ysnPosted = 1
			) CM ON CM.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId 
			WHERE Shipment.intOrderType = 1
				AND Shipment.ysnPosted = 1
				AND dbo.fnRemoveTimeOnDate(Shipment.dtmShipDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate  ELSE dbo.fnRemoveTimeOnDate(Shipment.dtmShipDate) END
				AND intContractTypeId = 2
			GROUP BY CH.intContractTypeId
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, Shipment.dtmShipDate
				, Shipment.intInventoryShipmentId
				, ShipmentItem.intInventoryShipmentItemId
				, Shipment.strShipmentNumber
				, INV.ysnPosted
				, ShipmentItem.dblDestinationNet
				, CD.intItemUOMId
				, ShipmentItem.intPriceUOMId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, Shipment.intEntityId

			UNION ALL
			SELECT CH.intContractTypeId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, InvTran.dtmDate
				, @dtmEndDate AS dtmEndDate
				, SUM(InvTran.dblQty * - 1) AS dblQuantity
				, 0
				, COUNT(DISTINCT Invoice.intInvoiceId)
				, Invoice.intInvoiceId
				, Invoice.strInvoiceNumber
				, InvoiceDetail.intInvoiceDetailId
				, 'Invoice'
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, intUserId = InvTran.intCreatedEntityId
			FROM tblICInventoryTransaction InvTran
			JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvTran.intTransactionId
			JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceId = InvTran.intTransactionId
				AND Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
				AND InvoiceDetail.intInvoiceDetailId = InvTran.intTransactionDetailId 
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = InvoiceDetail.intContractHeaderId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvoiceDetail.intContractDetailId
			LEFT JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderDetailId = InvoiceDetail.intSalesOrderDetailId
				AND CD.intContractHeaderId = CH.intContractHeaderId
			WHERE InvTran.strTransactionForm = 'Invoice'
				AND InvTran.ysnIsUnposted = 0
				AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
				AND intContractTypeId = 2
				AND InvTran.intInTransitSourceLocationId IS NULL
			GROUP BY CH.intContractTypeId
				, CH.intContractHeaderId
	 			, CD.intContractDetailId
				, InvTran.dtmDate
				, Invoice.intInvoiceId
				, InvoiceDetail.intInvoiceDetailId
				, Invoice.strInvoiceNumber
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, InvTran.intCreatedEntityId
	
			UNION ALL 
			SELECT CH.intContractTypeId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, InvTran.dtmDate
				, @dtmEndDate AS dtmEndDate
				--,MAX(LD.dblNet) dblQuantity--,SUM(InvTran.dblQty)*-1 dblQuantity
				,dblQuantity = CASE WHEN CH.ysnLoad = 1 THEN  
									1 * CH.dblQuantityPerLoad
								ELSE
									MAX(LD.dblNet) 
								END
				, 0
				, COUNT(DISTINCT LD.intLoadId)
				, LD.intLoadId
				, InvTran.strTransactionId
				, LD.intLoadDetailId
				, 'Outbound Shipment'
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, intUserId = InvTran.intCreatedEntityId
			FROM tblICInventoryTransaction InvTran
			JOIN tblLGLoadDetail LD ON LD.intLoadId = InvTran.intTransactionId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
			JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
				AND CD.intContractHeaderId = CH.intContractHeaderId
			WHERE ysnIsUnposted = 0
				AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
				AND InvTran.intTransactionTypeId = 46
				AND InvTran.intInTransitSourceLocationId IS NULL
			GROUP BY CH.intContractTypeId
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, InvTran.dtmDate
				, LD.intLoadId
				, LD.intLoadDetailId
				, InvTran.strTransactionId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, InvTran.intCreatedEntityId
	
			UNION ALL
			SELECT CH.intContractTypeId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, InvTran.dtmDate
				, @dtmEndDate AS dtmEndDate
				, dblQuantity = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intItemUOMId,ReceiptItem.intUnitMeasureId,MAX(ReceiptItem.dblOpenReceive)), 0)
				, 0
				, COUNT(DISTINCT Receipt.intInventoryReceiptId)
				, Receipt.intInventoryReceiptId
				, Receipt.strReceiptNumber
				, ReceiptItem.intInventoryReceiptItemId
				, 'Inventory Receipt'
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, intUserId = InvTran.intCreatedEntityId
			FROM tblICInventoryTransaction InvTran
			JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = InvTran.intTransactionId
				AND strReceiptType = 'Purchase Contract'
			JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = InvTran.intTransactionId
				AND ReceiptItem.intInventoryReceiptItemId = InvTran.intTransactionDetailId
				AND ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = ReceiptItem.intOrderId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = ReceiptItem.intLineNo
				AND CD.intContractHeaderId = CH.intContractHeaderId
			WHERE strTransactionForm = 'Inventory Receipt'
				AND ysnIsUnposted = 0
				AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	 			AND intContractTypeId = 1
	 			AND InvTran.intTransactionTypeId = 4
			GROUP BY CH.intContractTypeId
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, InvTran.dtmDate
				, Receipt.intInventoryReceiptId
				, ReceiptItem.intInventoryReceiptItemId
				, Receipt.strReceiptNumber
				, CD.intItemUOMId
				, ReceiptItem.intUnitMeasureId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, InvTran.intCreatedEntityId
	
			UNION ALL
			SELECT CH.intContractTypeId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, dbo.fnRemoveTimeOnDate(SS.dtmCreated)
				, @dtmEndDate AS dtmEndDate
				, SUM(SC.dblUnits) AS dblQuantity
				, 0
				, COUNT(DISTINCT SS.intSettleStorageId)
				, SS.intSettleStorageId
				, SS.strStorageTicket
				, SS.intSettleStorageId
				, 'Storage'
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, intUserId = SS.intCreatedUserId
			FROM tblGRSettleContract SC
			JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
			JOIN tblCTContractDetail CD ON SC.intContractDetailId = CD.intContractDetailId
			JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
				AND CD.intContractHeaderId = CH.intContractHeaderId
			WHERE SS.ysnPosted = 1
				AND SS.intParentSettleStorageId IS NULL
				AND dbo.fnRemoveTimeOnDate(SS.dtmCreated) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(SS.dtmCreated) END
			GROUP BY CH.intContractTypeId
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, SS.dtmCreated
				, SS.intSettleStorageId
				, SS.strStorageTicket
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, SS.intCreatedUserId
	
			UNION ALL
			SELECT CH.intContractTypeId
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, IB.dtmImported
				, @dtmEndDate AS dtmEndDate
				, SUM(IB.dblReceivedQty) dblQuantity
				, 0
				, COUNT(DISTINCT IB.intImportBalanceId)
				, IB.intImportBalanceId
				, IB.strContractNumber
				, IB.intImportBalanceId
				, 'Import Balance'
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, intUserdId = IB.intImportedById
			FROM tblCTImportBalance IB
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = IB.intContractHeaderId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = IB.intContractDetailId
			WHERE dbo.fnRemoveTimeOnDate(IB.dtmImported) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(IB.dtmImported) END
			GROUP BY CH.intContractTypeId
				, CH.intContractHeaderId
				, CD.intContractDetailId
				, IB.dtmImported
				, IB.intImportBalanceId
				, IB.strContractNumber
				, CH.strContractNumber
				, CD.intContractSeq
				, CH.intCommodityId
				, CH.ysnLoad
				, CH.dblQuantityPerLoad
				, CH.intEntityId
				, IB.intImportedById

		) tbl

		SELECT DISTINCT CH.intContractTypeId
			, CH.strContractNumber
			, CD.intContractSeq
			, PF.intContractHeaderId
			, PF.intContractDetailId
			, FD.dtmFixationDate
			, dblQuantity = FD.dblQuantity
			, FD.dblFutures
			, FD.dblBasis
			, FD.dblCashPrice
			, dblShippedQty = 0.0000
			, intNoOfLoad = FD.dblQuantity / CD.dblQuantityPerLoad
			, intShippedNoOfLoad = 0
			, FD.dblQuantityAppliedAndPriced
			, FD.intPriceFixationDetailId
			, strType = 'Price Fixation'
			, intSourceId = FD.intPriceFixationId
			, strSourceId = PC.strPriceContractNo
			, CH.intEntityId
			, CH.intCommodityId
			, intUserId = PC.intCreatedById
		INTO #tmpPriceFixation
		FROM tblCTPriceFixationDetail FD
		INNER JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = FD.intPriceFixationId
		INNER JOIN tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = PF.intContractHeaderId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
			AND dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) END

		--find the associated invoice
		select
			I.dtmPostDate
			,dblQtyShipped = CASE WHEN CU.ysnLoad = 1 THEN  
									1 * CU.dblQuantityPerLoad
								ELSE
									ID.dblQtyShipped
								END
			,strType = 'Invoice'
			,CU.intContractTypeId
			,CU.strContractNumber
			,CU.intContractSeq
			,CU.intContractHeaderId
			,CU.intContractDetailId
			,intSourceId = I.intInvoiceId
			,strSourceId = I.strInvoiceNumber
			,CU.intEntityId
			,CU.intCommodityId
			,intUserId = I.intEntityId
		into #tmpInvoice 
		from #tmpContractUsage CU
		inner join tblARInvoiceDetail ID on ID.intInventoryShipmentItemId = CU.intSourceDetailId and ID.intInventoryShipmentChargeId is null
		inner join tblARInvoice I on I.intInvoiceId = ID.intInvoiceId 
		where CU.strType = 'Inventory Shipment'
	

		select
			B.dtmDate
			,BD.dblQtyReceived
			,strType = 'Voucher'
			,CU.intContractTypeId
			,CU.strContractNumber
			,CU.intContractSeq
			,CU.intContractHeaderId
			,CU.intContractDetailId
			,intSourceId = B.intBillId
			,strSourceId = B.strBillId
			,CU.intEntityId
			,CU.intCommodityId
			,intUserId = B.intUserId
		into #tmpVoucher
		from #tmpContractUsage CU
		inner join tblAPBillDetail BD on BD.intInventoryReceiptItemId = CU.intSourceDetailId and BD.intInventoryReceiptChargeId is null
		inner join tblAPBill B on B.intBillId = BD.intBillId 
		where CU.strType = 'Inventory Receipt'

		declare @tblRawContractBalance as table (
			intId int identity(1,1)
			,dtmDate datetime
			,dblQuantity numeric(18,6)
			,strType nvarchar(50)
			,intContractTypeId int
			,strContractNumber nvarchar(50)
			,intContractSeq int
			,intContractHeaderId int
			,intContractDetailId int
			,intTransactionReferenceId int
			,strTransactionReferenceNo nvarchar(50)
			,intEntityId int
			,intCommodityId int
			,intOrderBy int
			,intUserId int
		)

		insert into @tblRawContractBalance(
			dtmDate
			,dblQuantity
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId
			,intTransactionReferenceId
			,strTransactionReferenceNo
			,intEntityId
			,intCommodityId
			,intOrderBy
			,intUserId
		)
		select 
			dtmDate
			,dblQuantity
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId
			,intTransactionReferenceId
			,strTransactionReferenceNo
			,intEntityId
			,intCommodityId
			,intOrderBy
			,intUserId
		 from (
		select 
			dtmDate = dtmCreated
			,dblQuantity
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId
			,intTransactionReferenceId = intContractHeaderId
			,strTransactionReferenceNo = strContractNumber + '-' + cast(intContractSeq as nvarchar(10))
			,intEntityId
			,intCommodityId
			,intOrderBy = 1
			,intUserId
		from #tmpContract C
	
		union all
		select
			dtmDate
			,dblQuantity
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId 
			,intTransactionReferenceId = intSourceId
			,strTransactionReferenceNo = strSourceId
			,intEntityId
			,intCommodityId
			,intOrderBy = 2
			,intUserId
		from #tmpContractUsage

		union all
		select
			dtmDate = dtmFixationDate
			,dblQuantity
			,strType 
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId 
			,intTransactionReferenceId = intSourceId
			,strTransactionReferenceNo = strSourceId
			,intEntityId
			,intCommodityId
			,intOrderBy = 2
			,intUserId
		from #tmpPriceFixation

		union all
		select
			dtmDate = dtmPostDate
			,dblQuantity =  dblQtyShipped
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId 
			,intTransactionReferenceId = intSourceId
			,strTransactionReferenceNo = strSourceId
			,intEntityId
			,intCommodityId
			,intOrderBy = 2
			,intUserId
		from #tmpInvoice

		union all
		select
			dtmDate = dtmDate
			,dblQuantity =  dblQtyReceived
			,strType
			,intContractTypeId
			,strContractNumber
			,intContractSeq
			,intContractHeaderId
			,intContractDetailId 
			,intTransactionReferenceId = intSourceId
			,strTransactionReferenceNo = strSourceId
			,intEntityId
			,intCommodityId
			,intOrderBy = 2
			,intUserId
		from #tmpVoucher


		) tbl
		ORDER BY intOrderBy, intContractDetailId, dtmDate
	
		declare @tblContractBalance as table (
			intId int identity(1,1)
			,dtmTransactionDate datetime
			,dtmCreatedDate datetime
			,strTransactionType nvarchar(50)
			,strTransactionReference nvarchar(50)
			,intTransactionReferenceId int
			,strTransactionReferenceNo nvarchar(50)
			,strContractNumber nvarchar(50)
			,intContractSeq int
			,intContractHeaderId int
			,intContractDetailId int
			,intContractTypeId int
			,intEntityId int
			,intCommodityId int
			,strCommodityCode nvarchar(50)
			,intItemId int
			,intLocationId int
			,intPricingTypeId int
			,strPricingType nvarchar(50)
			,intFutureMarketId int
			,intFutureMonthId int
			,dtmStartDate datetime
			,dtmEndDate datetime
			,dblQuantity numeric(18,6)
			,intQtyUOMId int
			,dblFutures numeric(18,6)
			,dblBasis numeric(18,6)
			,intBasisUOMId int
			,intBasisCurrencyId int
			,intPriceUOMId int
			,intContractStatusId int
			,intBookId int
			,intSubBookId int
			,strNotes nvarchar(50)
			,intUserId int
		)

		declare @intRawCBId as int
		WHILE EXISTS (SELECT TOP 1 1 FROM @tblRawContractBalance)
		BEGIN
			SELECT TOP 1 
				@intRawCBId = intId 
			FROM @tblRawContractBalance
			order by intId

			INSERT INTO @tblContractBalance(
				dtmTransactionDate
				,dtmCreatedDate
				,strTransactionType 
				,strTransactionReference 
				,intTransactionReferenceId
				,strTransactionReferenceNo
				,strContractNumber
				,intContractSeq
				,intContractHeaderId 
				,intContractDetailId 
				,intContractTypeId 
				,intEntityId 
				,intCommodityId 
				,strCommodityCode 
				,intItemId 
				,intLocationId 
				,intPricingTypeId 
				,strPricingType 
				,intFutureMarketId 
				,intFutureMonthId 
				,dtmStartDate 
				,dtmEndDate 
				,dblQuantity
				,intQtyUOMId 
				,dblFutures
				,dblBasis
				,intBasisUOMId 
				,intBasisCurrencyId 
				,intPriceUOMId 
				,intContractStatusId 
				,intBookId 
				,intSubBookId 
				,strNotes
				,intUserId
			)
			SELECT
				dtmTransactionDate = dtmDate
				,dtmCreatedDate = dtmDate
				,strTransactionType = 'Contract Balance'
				,strTransactionReference = strType
				,intTransactionReferenceId
				,strTransactionReferenceNo
				,strContractNumber
				,intContractSeq
				,intContractHeaderId 
				,intContractDetailId 
				,intContractTypeId
				,intEntityId 
				,intCommodityId
				,strCommodityCode = ''
				,intItemId
				,intLocationId
				,intPricingTypeId
				,strPricingType 
				,intFutureMarketId
				,intFutureMonthId 
				,dtmStartDate 
				,dtmEndDate 
				,dblQuantity = CASE WHEN strPricingType = 'Basis' THEN 
									dblBasis
								WHEN strPricingType = 'Priced' THEN
									dblPriced
								ELSE 
									dblBalance
							END 
				,intQtyUOMId = intUnitMeasureId
				,dblFutures
				,dblBasis = dblBasisPrice
				,intBasisUOMId 
				,intBasisCurrencyId 
				,intPriceUOMId  = intPriceItemUOMId
				,intContractStatusId 
				,intBookId 
				,intSubBookId 
				,strNotes = ''
				,intUserId
			FROM (
				SELECT 
					dtmDate
					,dblBalance = CASE WHEN strType = 'Contract Sequence' THEN CB.dblQuantity
									WHEN strType IN ('Inventory Shipment','Inventory Receipt','Outbound Shipment') THEN CB.dblQuantity * -1
									ELSE 0
								END
					,dblBasis = CASE WHEN CD.intPricingTypeId = 2 THEN
									CASE WHEN strType IN( 'Contract Sequence') THEN CB.dblQuantity
										WHEN strType IN ('Inventory Shipment', 'Inventory Receipt','Outbound Shipment') THEN CB.dblQuantity * -1
										ELSE 0
									END
								ELSE 0
								END
					,dblPriced = CASE WHEN CD.intPricingTypeId = 2 THEN
									CASE WHEN strType = 'Price Fixation' THEN CB.dblQuantity
										WHEN strType IN ('Invoice', 'Voucher') THEN CB.dblQuantity * -1
										ELSE 0
									END
								WHEN CD.intPricingTypeId = 1 THEN 
									CASE WHEN strType = 'Contract Sequence' THEN CB.dblQuantity
										WHEN strType IN ('Inventory Shipment', 'Inventory Receipt','Outbound Shipment') THEN 
											 CB.dblQuantity * -1
										ELSE 0
									END
								ELSE 0
								END
					,CD.intUnitMeasureId
					,CD.intPricingTypeId
					,PT.strPricingType 
					,strType
					,strContractNumber
					,CB.intContractSeq
					,CB.intContractHeaderId
					,CB.intContractDetailId
					,CB.intContractTypeId
					,CB.intEntityId 
					,CB.intCommodityId
					,C.strCommodityCode
					,CD.intItemId
					,intLocationId = CD.intCompanyLocationId
					,CB.intTransactionReferenceId
					,CB.strTransactionReferenceNo
					,CD.intFutureMarketId
					,CD.intFutureMonthId
					,CD.dtmStartDate
					,CD.dtmEndDate
					,CD.dblFutures
					,dblBasisPrice = CD.dblBasis
					,CD.intBasisUOMId
					,CD.intBasisCurrencyId 
					,CD.intPriceItemUOMId 
					,CD.intContractStatusId 
					,CD.intBookId 
					,CD.intSubBookId 
					,CB.intUserId
				FROM @tblRawContractBalance CB
				inner join tblCTContractDetail CD on CD.intContractDetailId = CB.intContractDetailId
				inner join tblCTPricingType PT on PT.intPricingTypeId = CD.intPricingTypeId
				inner join tblICCommodity C on C.intCommodityId = CB.intCommodityId
				WHERE intId = @intRawCBId
			) t

			delete from @tblRawContractBalance where intId = @intRawCBId
		END 

		;WITH CTE
		AS (
			select * from (
				select
					intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractHeaderId, intContractDetailId ORDER BY dtmHistoryCreated DESC)
					,dtmHistoryCreated
					,strContractNumber
					,intContractStatusId
					,dblBalance
					,intContractHeaderId
					,intContractDetailId
				from tblCTSequenceHistory
				where ysnStatusChange = 1
					and intContractDetailId  IN (
						select distinct intContractDetailId from @tblContractBalance
					)
			) tbl
			where intRowNum = 1 
				and intContractStatusId IN (3,5,6)
		)

		INSERT INTO @tblContractBalance(
			dtmTransactionDate
			,dtmCreatedDate
			,strTransactionType 
			,strTransactionReference 
			,intTransactionReferenceId
			,strTransactionReferenceNo
			,strContractNumber
			,intContractSeq
			,intContractHeaderId 
			,intContractDetailId 
			,intContractTypeId 
			,intEntityId 
			,intCommodityId 
			,strCommodityCode 
			,intItemId 
			,intLocationId 
			,intPricingTypeId 
			,strPricingType 
			,intFutureMarketId 
			,intFutureMonthId 
			,dtmStartDate 
			,dtmEndDate 
			,dblQuantity
			,intQtyUOMId 
			,dblFutures
			,dblBasis
			,intBasisUOMId 
			,intBasisCurrencyId 
			,intPriceUOMId 
			,intContractStatusId 
			,intBookId 
			,intSubBookId 
			,strNotes
			,intUserId
		)
		select 
			dtmTransactionDate = CTE.dtmHistoryCreated
			,dtmCreatedDate = CTE.dtmHistoryCreated
			,strTransactionType = 'Contract Balance'
			,strTransactionReference = 'Contract Sequence'
			,intTransactionReferenceId = CB.intContractHeaderId 
			,strTransactionReferenceNo = CB.strContractNumber
			,CB.strContractNumber
			,CB.intContractSeq
			,CB.intContractHeaderId 
			,CB.intContractDetailId 
			,CB.intContractTypeId
			,CB.intEntityId 
			,CB.intCommodityId 
			,CB.strCommodityCode 
			,CB.intItemId 
			,CB.intLocationId 
			,CB.intPricingTypeId 
			,CB.strPricingType 
			,CB.intFutureMarketId 
			,CB.intFutureMonthId 
			,CB.dtmStartDate 
			,CB.dtmEndDate  
			,dblQuantity = sum(CB.dblQuantity) * -1
			,CB.intQtyUOMId 
			,CB.dblFutures
			,CB.dblBasis
			,CB.intBasisUOMId 
			,CB.intBasisCurrencyId 
			,CB.intPriceUOMId 
			,CB.intContractStatusId 
			,CB.intBookId 
			,CB.intSubBookId 
			,strNotes = 'Manual status change'
			,CB.intUserId
		from @tblContractBalance CB
		inner join CTE ON CB.intContractDetailId = CTE.intContractDetailId
		group by
			CTE.dtmHistoryCreated
			,CB.strContractNumber
			,CB.intContractSeq
			,CB.intContractHeaderId 
			,CB.intContractDetailId 
			,CB.intContractTypeId
			,CB.intEntityId 
			,CB.intCommodityId 
			,CB.strCommodityCode 
			,CB.intItemId 
			,CB.intLocationId 
			,CB.intPricingTypeId 
			,CB.strPricingType 
			,CB.intFutureMarketId 
			,CB.intFutureMonthId 
			,CB.dtmStartDate 
			,CB.dtmEndDate  
			,CB.intQtyUOMId 
			,CB.dblFutures
			,CB.dblBasis
			,CB.intBasisUOMId 
			,CB.intBasisCurrencyId 
			,CB.intPriceUOMId 
			,CB.intContractStatusId 
			,CB.intBookId 
			,CB.intSubBookId 
			,CB.intUserId

		--clean up all quantity with zero quantity
		delete from @tblContractBalance where dblQuantity = 0

		drop table #tmpContract
		drop table #tmpContractUsage
		drop table #tmpPriceFixation
		drop table #tmpInvoice
		drop table #tmpVoucher

		INSERT INTO @cbLog (strBatchId
			, dtmTransactionDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intLocationId
			, intPricingTypeId
			, intFutureMarketId
			, intFutureMonthId
			, dblBasis
			, dblFutures
			, intQtyUOMId
			, intQtyCurrencyId
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, dtmStartDate
			, dtmEndDate
			, dblQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId)
		SELECT strBatchId = NULL
			, dtmTransactionDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intLocationId
			, intPricingTypeId
			, intFutureMarketId
			, intFutureMonthId
			, dblBasis
			, dblFutures
			, intQtyUOMId
			, intQtyCurrencyId = NULL
			, intBasisUOMId
			, intBasisCurrencyId
			, intPriceUOMId
			, dtmStartDate
			, dtmEndDate
			, dblQuantity
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes
			, intUserId
			, intActionId  = 1 --Rebuild 		
		FROM @tblContractBalance


		EXEC uspCTLogContractBalance @cbLog, 1

		PRINT 'End Populate RK Summary Log - Contract'
		DELETE FROM @cbLog

		--=======================================
		--				BASIS DELIVERIES
		--=======================================
		PRINT 'Populate RK Summary Log - Basis Deliveries'

		select  
			dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, sh.strContractNumber
			, sh.intContractSeq
			, sh.intEntityId
			, ch.intCommodityId
			, sh.intItemId
			, sh.intCompanyLocationId
			, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
							else suh.dblTransactionQuantity * si.dblQuantity end) * -1
			, intQtyUOMId = si.intItemUOMId
			, sh.intPricingTypeId
			, sh.strPricingType
			, strTransactionType = strScreenName
			, intTransactionId = suh.intExternalId
			, strTransactionId = suh.strNumber
			, sh.intContractStatusId
			, ch.intContractTypeId
			, sh.intFutureMarketId
			, sh.intFutureMonthId
			, intUserId = si.intCreatedByUserId
		into #tblBasisDeliveries
		from vyuCTSequenceUsageHistory suh
			inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
			inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			inner join tblICInventoryShipmentItem si ON si.intInventoryShipmentItemId = suh.intExternalId
		where strFieldName = 'Balance'
		and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
		and sh.strPricingType = 'Basis'
		and suh.strScreenName = 'Inventory Shipment'

		union all
		select  
			dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, sh.strContractNumber
			, sh.intContractSeq
			, sh.intEntityId
			, ch.intCommodityId
			, sh.intItemId
			, sh.intCompanyLocationId
			, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
							else suh.dblTransactionQuantity * ri.dblReceived end) * -1
			, intQtyUOMId = ri.intUnitMeasureId
			, sh.intPricingTypeId
			, sh.strPricingType
			, strTransactionType = strScreenName
			, intTransactionId = suh.intExternalId
			, strTransactionId = suh.strNumber
			, sh.intContractStatusId
			, ch.intContractTypeId
			, sh.intFutureMarketId
			, sh.intFutureMonthId
			, intUserId = ri.intCreatedByUserId
		from vyuCTSequenceUsageHistory suh
			inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
			inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			inner join tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = suh.intExternalId
		where strFieldName = 'Balance'
		and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
		and sh.strPricingType = 'Basis'
		and suh.strScreenName = 'Inventory Receipt'

		union all
		select  
			dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
			, sh.intContractHeaderId
			, sh.intContractDetailId
			, sh.strContractNumber
			, sh.intContractSeq
			, sh.intEntityId
			, ch.intCommodityId
			, sh.intItemId
			, sh.intCompanyLocationId
			, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
							else suh.dblTransactionQuantity * ld.dblQuantity end) * -1
			, intQtyUOMId = ch.intCommodityUOMId
			, sh.intPricingTypeId
			, sh.strPricingType
			, strTransactionType = strScreenName
			, intTransactionId = suh.intExternalId
			, strTransactionId = suh.strNumber
			, sh.intContractStatusId
			, ch.intContractTypeId
			, sh.intFutureMarketId
			, sh.intFutureMonthId
			, intUserId = sh.intUserId
		from vyuCTSequenceUsageHistory suh
			inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
			inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
			inner join tblLGLoadDetail ld ON ld.intLoadDetailId = suh.intExternalId
		where strFieldName = 'Balance'
		and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
		and sh.strPricingType = 'Basis'
		and suh.strScreenName = 'Load Schedule'

		SELECT * 
		INTO #tblFinalBasisDeliveries 
		FROM (

			select
				strTransactionType =  CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
				, dtmTransactionDate
				, intContractHeaderId
				, intContractDetailId
				, strContractNumber
				, intContractSeq
				, intContractTypeId
				, intContractStatusId
				, intCommodityId
				, intItemId
				, intEntityId
				, intCompanyLocationId
				, dblQty
				, intQtyUOMId
				, intPricingTypeId
				, strPricingType
				, strTransactionReference = strTransactionType
				, intTransactionReferenceId = intTransactionId
				, strTransactionReferenceNo = strTransactionId
				, intFutureMarketId
				, intFutureMonthId
				, intUserId
			from #tblBasisDeliveries

			union all
			select 
				 strType  = 'Purchase Basis Deliveries'
				, b.dtmBillDate
				, ba.intContractHeaderId
				, ba.intContractDetailId
				, ba.strContractNumber
				, ba.intContractSeq
				, ba.intContractTypeId
				, ba.intContractStatusId
				, ba.intCommodityId
				, ba.intItemId
				, ba.intEntityId
				, ba.intCompanyLocationId
				, dblQty =  bd.dblQtyReceived  * -1
				, intItemUOMId = bd.intUnitOfMeasureId
				, intPricingTypeId = 2
				, strPricingType = 'Basis'
				, strTransactionType = 'Voucher'
				, intTransactionId = b.intBillId
				, strTransactionId = b.strBillId
				, intFutureMarketId
				, intFutureMonthId
				, intUserId = b.intUserId
			from tblAPBillDetail bd
			inner join tblAPBill b ON b.intBillId = bd.intBillId
			inner join #tblBasisDeliveries ba ON ba.intTransactionId = bd.intInventoryReceiptItemId and ba.strTransactionType <> 'Load Schedule' and ba.intContractTypeId = 1
	
			union all
			select 
				 strType  = 'Purchase Basis Deliveries'
				, b.dtmBillDate
				, ba.intContractHeaderId
				, ba.intContractDetailId
				, ba.strContractNumber
				, ba.intContractSeq
				, ba.intContractTypeId
				, ba.intContractStatusId
				, ba.intCommodityId
				, ba.intItemId
				, ba.intEntityId
				, ba.intCompanyLocationId
				, dblQty =  bd.dblQtyReceived  * -1
				, intItemUOMId = bd.intUnitOfMeasureId
				, intPricingTypeId = 2
				, strPricingType = 'Basis'
				, strTransactionType = 'Voucher'
				, intTransactionId = b.intBillId
				, strTransactionId = b.strBillId
				, intFutureMarketId
				, intFutureMonthId
				, intUserId = b.intUserId
			from tblAPBillDetail bd
			inner join tblAPBill b ON b.intBillId = bd.intBillId
			inner join #tblBasisDeliveries ba ON ba.intTransactionId = bd.intLoadDetailId and ba.strTransactionType = 'Load Schedule' and ba.intContractTypeId = 1

			union all
			select 
				 strType  = 'Sales Basis Deliveries'
				, i.dtmDate
				, ba.intContractHeaderId
				, ba.intContractDetailId
				, ba.strContractNumber
				, ba.intContractSeq
				, ba.intContractTypeId
				, ba.intContractStatusId
				, ba.intCommodityId
				, ba.intItemId
				, ba.intEntityId
				, ba.intCompanyLocationId
				, dblQty =  id.dblQtyShipped  * -1
				, intItemUOMId = id.intItemUOMId
				, intPricingTypeId = 2
				, strPricingType = 'Basis'
				, strTransactionType = 'Invoice'
				, intTransactionId = i.intInvoiceId
				, strTransactionId = i.strInvoiceNumber
				, intFutureMarketId
				, intFutureMonthId
				, intUserId = i.intEntityId 
			from tblARInvoiceDetail id
			inner join tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
			inner join #tblBasisDeliveries ba ON ba.intTransactionId = id.intInventoryShipmentItemId and ba.strTransactionType <> 'Load Schedule' and ba.intContractTypeId = 2
	
			union all
			select 
				 strType  = 'Sales Basis Deliveries'
				, i.dtmDate
				, ba.intContractHeaderId
				, ba.intContractDetailId
				, ba.strContractNumber
				, ba.intContractSeq
				, ba.intContractTypeId
				, ba.intContractStatusId
				, ba.intCommodityId
				, ba.intItemId
				, ba.intEntityId
				, ba.intCompanyLocationId
				, dblQty =  id.dblQtyShipped  * -1
				, intItemUOMId = id.intItemUOMId
				, intPricingTypeId = 2
				, strPricingType = 'Basis'
				, strTransactionType = 'Invoice'
				, intTransactionId = i.intInvoiceId
				, strTransactionId = i.strInvoiceNumber
				, intFutureMarketId
				, intFutureMonthId
				, intUserId = i.intEntityId 
			from tblARInvoiceDetail id
			inner join tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
			inner join #tblBasisDeliveries ba ON ba.intTransactionId = id.intLoadDetailId and ba.strTransactionType = 'Load Schedule' and ba.intContractTypeId = 2

		) t

		INSERT INTO @cbLog (strBatchId
			, dtmTransactionDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intLocationId
			, dblQty
			, intQtyUOMId
			, intPricingTypeId
			, intContractStatusId
			, intFutureMarketId
			, intFutureMonthId
			, intUserId
			, intActionId
		)
		SELECT 
			strBatch = NULL
			, dtmTransactionDate
			, strTransactionType
			, strTransactionReference
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intContractDetailId
			, intContractHeaderId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intEntityId
			, intCommodityId
			, intItemId
			, intCompanyLocationId
			, dblQty
			, intQtyUOMId
			, intPricingTypeId
			, intContractStatusId
			, intFutureMarketId
			, intFutureMonthId
			, intUserId
			, intActionId  = 1 --Rebuild
		FROM #tblFinalBasisDeliveries 

		EXEC uspCTLogContractBalance @cbLog, 1

		PRINT 'End Populate RK Summary Log - Basis Deliveries'
		
		--=======================================
		--				DERIVATIVES
		--=======================================
		PRINT 'Populate RK Summary Log - Derivatives'
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intLocationId
			, intCommodityUOMId
			, strNotes
			, strMiscFields
			, intActionId)
		SELECT
			  strBucketType = 'Derivatives' 
			, strTransactionType = 'Derivative Entry'
			, intTransactionRecordId = der.intFutOptTransactionId
			, intTransactionRecordHeaderId = der.intFutOptTransactionHeaderId
			, strDistributionType = der.strNewBuySell
			, strTransactionNumber = der.strInternalTradeNo
			, dtmTransactionDate = der.dtmTransactionDate
			, intContractDetailId = der.intContractDetailId
			, intContractHeaderId = der.intContractHeaderId
			, intCommodityId = der.intCommodityId
			, intBookId = der.intBookId
			, intSubBookId = der.intSubBookId
			, der.intFutOptTransactionId
			, intFutureMarketId = der.intFutureMarketId
			, intFutureMonthId = der.intFutureMonthId
			, dblNoOfLots = der.dblNewNoOfLots
			, dblContractSize = m.dblContractSize
			, dblPrice = der.dblPrice
			, intEntityId = der.intEntityId
			, intUserId = der.intUserId
			, der.intLocationId
			, cUOM.intCommodityUnitMeasureId
			, strNotes = strNotes
			, strMiscFields = '{intOptionMonthId = "' + ISNULL(CAST(intOptionMonthId AS NVARCHAR), '') +'"}'
								+ ' {strOptionMonth = "' + ISNULL(strOptionMonth, '') +'"}'
								+ ' {dblStrike = "' + CAST(ISNULL(dblStrike,0) AS NVARCHAR) +'"}'
								+ ' {strOptionType = "' + ISNULL(strOptionType, '') +'"}'
								+ ' {strInstrumentType = "' + ISNULL(strInstrumentType, '') +'"}'
								+ ' {intBrokerageAccountId = "' + ISNULL(CAST(intBrokerId AS NVARCHAR), '') +'"}'
								+ ' {strBrokerAccount = "' + ISNULL(strBrokerAccount, '') +'"}'
								+ ' {strBroker = "' + ISNULL(strBroker, '') +'"}'
								+ ' {strBuySell = "' + ISNULL(strNewBuySell, '') +'"}'
								+ ' {ysnPreCrush = "' + CAST(ISNULL(ysnPreCrush,0) AS NVARCHAR) +'"}'
								+ ' {strBrokerTradeNo = "' + ISNULL(strBrokerTradeNo, '') +'"}'
			, intActionId  = 1 --Rebuild
		FROM vyuRKGetFutOptTransactionHistory der
		JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
		LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
		ORDER BY dtmTransactionDate

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		PRINT 'End Populate RK Summary Log - Derivatives'
		DELETE FROM @ExistingHistory

		--=======================================
		--			MATCH DERIVATIVES
		--=======================================
		PRINT 'Populate RK Summary Log - Match Derivatives'
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId)
		SELECT
			  strBucketType = 'Derivatives'
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId  = 1 --Rebuild
		FROM (
			SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = history.intLFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType  = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = history.intLFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'IN'
				, dblNoOfLots = history.dblMatchQty
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = e.intEntityId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, intMatchDerivativeHistoryId
				, strMiscFields =  '{ysnPreCrush = "' + CAST(ISNULL(ysnPreCrush,0) AS NVARCHAR) +'"}'
			FROM tblRKMatchDerivativesHistory history
			JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = history.intMatchFuturesPSHeaderId
			JOIN tblRKMatchFuturesPSDetail detail ON detail.intMatchFuturesPSDetailId = history.intMatchFuturesPSDetailId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = history.intLFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN (
				SELECT strUserName = e.strName
					, e.intEntityId
				FROM tblEMEntity e
				JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User'
			) e ON e.strUserName = history.strUserName

			UNION ALL SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = history.intSFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType  = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = history.intSFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'OUT'
				, dblNoOfLots = history.dblMatchQty * - 1
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = e.intEntityId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, intMatchDerivativeHistoryId
				, strMiscFields =  '{ysnPreCrush = "' + CAST(ISNULL(ysnPreCrush,0) AS NVARCHAR) +'"}'
			FROM tblRKMatchDerivativesHistory history
			JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = history.intMatchFuturesPSHeaderId
			JOIN tblRKMatchFuturesPSDetail detail ON detail.intMatchFuturesPSDetailId = history.intMatchFuturesPSDetailId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = history.intSFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN (
				SELECT strUserName = e.strName
					, e.intEntityId
				FROM tblEMEntity e
				JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User'
			) e ON e.strUserName = history.strUserName
		) tbl
		ORDER BY intMatchDerivativeHistoryId

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		PRINT 'End Populate RK Summary Log - Match Derivatives'
		DELETE FROM @ExistingHistory

		--=======================================
		--			Option Derivatives
		--=======================================
		PRINT 'Populate RK Summary Log - Option Derivatives'
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId)
		SELECT
			  strBucketType = 'Derivatives' 
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId  = 1 --Rebuild
		FROM (
			SELECT strTransactionType = 'Expired Options'
				, intTransactionRecordId = detail.intFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = detail.dtmExpiredDate
				, intContractDetailId = detail.intOptionsPnSExpiredId
				, intContractHeaderId = header.intOptionsMatchPnSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = detail.intFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = CASE WHEN de.strBuySell = 'Buy' THEN 'IN' ELSE 'OUT' END
				, dblNoOfLots = detail.dblLots * - 1
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intCurrentUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, strMiscFields =  '{ysnPreCrush = "' + CAST(ISNULL(ysnPreCrush,0) AS NVARCHAR) +'"}'
			FROM tblRKOptionsPnSExpired detail
			JOIN tblRKOptionsMatchPnSHeader header ON header.intOptionsMatchPnSHeaderId = detail.intOptionsMatchPnSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId

			UNION ALL SELECT strTransactionType = 'Excercised/Assigned Options'
				, intTransactionRecordId = detail.intFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = detail.dtmTranDate
				, intContractDetailId = detail.intOptionsPnSExercisedAssignedId
				, intContractHeaderId = header.intOptionsMatchPnSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = detail.intFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = CASE WHEN de.strBuySell = 'Buy' THEN 'IN' ELSE 'OUT' END
				, dblNoOfLots = detail.dblLots * - 1
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intCurrentUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, strMiscFields =  '{ysnPreCrush = "' + CAST(ISNULL(ysnPreCrush,0) AS NVARCHAR) +'"}'
			FROM tblRKOptionsPnSExercisedAssigned detail
			JOIN tblRKOptionsMatchPnSHeader header ON header.intOptionsMatchPnSHeaderId = detail.intOptionsMatchPnSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
		) tbl

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		PRINT 'End Populate RK Summary Log - Option Derivatives'
		DELETE FROM @ExistingHistory

		--=======================================
		--				COLLATERAL
		--=======================================
		PRINT 'Populate RK Summary Log - Collateral'
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractHeaderId
			, intCommodityId
			, intItemId
			, intCommodityUOMId
			, intLocationId
			, dblQty
			, intUserId
			, strNotes
			, intActionId)
		SELECT
			  strBucketType = 'Collateral' 
			, strTransactionType = 'Collateral'
			, intTransactionRecordId = intCollateralId
			, intTransactionRecordHeaderId = intCollateralId
			, strDistributionType = strType
			, strTransactionNumber = strReceiptNo
			, dtmTransactionDate = dtmOpenDate
			, intContractHeaderId = intContractHeaderId
			, intCommodityId = a.intCommodityId
			, intItemId
			, intOrigUOMId = CUM.intCommodityUnitMeasureId
			, intLocationId = intLocationId
			, dblQty = dblOriginalQuantity
			, intUserId = (SELECT TOP 1 e.intEntityId
							FROM (tblEMEntity e LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User')
							INNER JOIN tblRKCollateralHistory colhis ON colhis.strUserName = e.strName where colhis.intCollateralId = a.intCollateralId and colhis.strAction = 'ADD')
			, strNotes = strType + ' Collateral'
			, intActionId  = 1 --Rebuild
		FROM tblRKCollateral a
		LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = a.intUnitMeasureId AND CUM.intCommodityId = a.intCommodityId
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intItemId
			, intLocationId
			, dblQty
			, intCommodityUOMId
			, intUserId
			, strNotes
			, intActionId)
		SELECT
			  strBucketType = 'Collateral'  
			, strTransactionType = 'Collateral Adjustments'
			, intTransactionRecordId = CA.intCollateralAdjustmentId
			, intTransactionRecordHeaderId = C.intCollateralId
			, strDistributionType = C.strType
			, strTransactionNumber = strAdjustmentNo
			, dtmTransactionDate = dtmAdjustmentDate
			, intContractDetailId = CA.intCollateralAdjustmentId
			, intContractHeaderId = C.intContractHeaderId
			, intCommodityId = C.intCommodityId
			, intItemId
			, intLocationId = intLocationId
			, dblQty = CA.dblAdjustmentAmount
			, intOrigUOMId = CUM.intCommodityUnitMeasureId
			, intUserId = (SELECT TOP 1 e.intEntityId
							FROM (tblEMEntity e LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User')
							INNER JOIN tblRKCollateralHistory colhis ON colhis.strUserName = e.strName where colhis.intCollateralId = C.intCollateralId and colhis.strAction = 'ADD')
			, strNotes = strType + ' Collateral'
			, intActionId  = 1 --Rebuild
		FROM tblRKCollateralAdjustment CA
		JOIN tblRKCollateral C ON C.intCollateralId = CA.intCollateralId
		LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = C.intUnitMeasureId AND CUM.intCommodityId = C.intCommodityId
		WHERE intCollateralAdjustmentId NOT IN (SELECT DISTINCT adj.intCollateralAdjustmentId
				FROM tblRKCollateralAdjustment adj
				JOIN tblRKSummaryLog history ON history.intTransactionRecordId = adj.intCollateralId AND strTransactionType = 'Collateral Adjustments'
					AND adj.dtmAdjustmentDate = history.dtmTransactionDate
					AND adj.strAdjustmentNo = history.strTransactionNumber
					AND adj.dblAdjustmentAmount = history.dblOrigQty
				WHERE adj.intCollateralId = C.intCollateralId)
		
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		PRINT 'End Populate RK Summary Log - Collateral'
		DELETE FROM @ExistingHistory

		--=======================================
		--				INVENTORY
		--=======================================
		PRINT 'Populate RK Summary Log - Inventory'
		
		INSERT INTO @ExistingHistory (	
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordId 
			,intTransactionRecordHeaderId
			,strDistributionType
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
			,intActionId
		)
		SELECT
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordId 
			,intTransactionRecordHeaderId 
			,strDistributionType = ''
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
			,intActionId  = 1 --Rebuild
		FROM (
			SELECT 
				strBatchId = t.strBatchId
				,strBucketType = 'Company Owned'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = NULL
				,intContractHeaderId = NULL
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType NOT IN ('Inventory Receipt','Inventory Shipment', 'Storage Settlement')
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT 
				strBatchId = t.strBatchId
				,strBucketType = 'Company Owned'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = iri.intContractDetailId
				,intContractHeaderId = iri.intContractHeaderId
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
				INNER JOIN tblICInventoryReceiptItem iri 
					ON iri.intInventoryReceiptItemId = t.intTransactionDetailId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType = 'Inventory Receipt'
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,iri.intContractDetailId
				,iri.intContractHeaderId
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT 
				strBatchId = t.strBatchId
				,strBucketType = 'Company Owned'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = isi.intLineNo
				,intContractHeaderId = isi.intOrderId
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
				INNER JOIN tblICInventoryShipmentItem isi 
					ON isi.intInventoryShipmentItemId = t.intTransactionDetailId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType = 'Inventory Shipment'
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,isi.intLineNo
				,isi.intOrderId
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT strBatchId = t.strBatchId
				, strBucketType = 'Sales In-Transit'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN sd.intLineNo
											WHEN v.strTransactionType = 'Invoice' THEN id.intContractDetailId
											WHEN v.strTransactionType = 'Outbound Shipment' THEN ld.intSContractDetailId END
				, intContractHeaderId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN cd.intContractHeaderId
											WHEN v.strTransactionType = 'Invoice' THEN cd.intContractHeaderId
											WHEN v.strTransactionType = 'Outbound Shipment' THEN cd.intContractHeaderId END
				, intTicketId = v.intTicketId
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cum.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = cd.intFutureMarketId
				, intFutureMonthId = cd.intFutureMonthId
				, dblNoOfLots = NULL
				, dblQty = SUM(t.dblQty)
				, dblPrice = AVG(t.dblCost)
				, intEntityId = v.intEntityId
				, ysnDelete = 0
				, intUserId = t.intCreatedEntityId
				, strNotes = t.strDescription
				, intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM tblICInventoryTransaction t
			INNER JOIN vyuICGetInventoryValuation v ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICUnitMeasure u ON u.strUnitMeasure = v.strUOM
			INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
			LEFT JOIN (
				tblICInventoryShipmentItem sd
				LEFT JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = sd.intInventoryShipmentId
					AND s.intOrderType = 1 ) ON sd.intInventoryShipmentItemId = t.intTransactionDetailId AND v.strTransactionType = 'Inventory Shipment'
			LEFT JOIN tblARInvoiceDetail id ON id.intInvoiceDetailId = t.intTransactionDetailId AND v.strTransactionType = 'Invoice'
			LEFT JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = t.intTransactionDetailId AND v.strTransactionType = 'Outbound Shipment'
			LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN sd.intLineNo
																			WHEN v.strTransactionType = 'Invoice' THEN id.intContractDetailId
																			WHEN v.strTransactionType = 'Outbound Shipment' THEN ld.intSContractDetailId END
			WHERE t.dblQty <> 0 
				AND v.ysnInTransit = 1
				AND v.strTransactionType IN ('Inventory Shipment', 'Outbound Shipment', 'Invoice')
				AND ISNULL(t.ysnIsUnposted,0) = 0
			GROUP BY t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, v.intTicketId
				, v.intCommodityId
				, cum.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId
				, sd.intLineNo
				, id.intContractDetailId
				, id.intContractHeaderId
				, ld.intSContractDetailId
				, cd.intContractHeaderId
				, cd.intFutureMarketId
				, cd.intFutureMonthId

			UNION ALL
			SELECT strBatchId = t.strBatchId
				, strBucketType = 'Purchase In-Transit'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = ri.intContractDetailId
				, intContractHeaderId = ri.intContractHeaderId
				, intTicketId = v.intTicketId
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cum.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = cd.intFutureMarketId
				, intFutureMonthId = cd.intFutureMonthId
				, dblNoOfLots = NULL
				, dblQty = SUM(t.dblQty)
				, dblPrice = AVG(t.dblCost)
				, intEntityId = v.intEntityId
				, ysnDelete = 0
				, intUserId = t.intCreatedEntityId
				, strNotes = t.strDescription
				, intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM tblICInventoryTransaction t
			INNER JOIN vyuICGetInventoryValuation v ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICUnitMeasure u ON u.strUnitMeasure = v.strUOM
			INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
			LEFT JOIN tblICInventoryReceiptItem ri ON t.intTransactionDetailId = ri.intInventoryReceiptItemId AND v.strTransactionType = 'Inventory Receipt'
			LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intContractDetailId
			WHERE t.dblQty <> 0 
				AND v.ysnInTransit = 1
				AND v.strTransactionType IN ('Inventory Receipt','Inbound Shipments','Inventory Transfer with Shipment')
				AND ISNULL(t.ysnIsUnposted,0) = 0
			GROUP BY t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, v.intTicketId
				, v.intCommodityId
				, cum.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId
				, ri.intContractDetailId
				, ri.intContractHeaderId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
		) t
		ORDER BY intInventoryTransactionId
	
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
		PRINT 'End Populate RK Summary Log - Inventory'
		DELETE FROM @ExistingHistory

		--=======================================
		--				CUSTOMER OWNED
		--=======================================
		PRINT 'Populate RK Summary Log - Customer Owned'
		
		SELECT dtmDeliveryDate = (CASE WHEN sh.strType = 'Transfer' THEN  sh.dtmHistoryDate ELSE cs.dtmDeliveryDate END)
			, strBucketType = 'Customer Owned'
			, strTransactionType = CASE WHEN intTransactionTypeId IN (1, 5)
											THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
													 ELSE 'NONE' END
										WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
										WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
										WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' END
			, intTransactionRecordId = CASE WHEN intTransactionTypeId IN (1, 5)
												THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.intInventoryReceiptId
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.intInventoryShipmentId
														ELSE NULL END
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
											WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId END
			, strTransactioneNo = CASE WHEN intTransactionTypeId IN (1, 5)
											THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
													WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
													ELSE NULL END
									WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
									WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
									WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo END
			, intTransactionRecordHeaderId = sh.intCustomerStorageId
			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cum.intCommodityUnitMeasureId
			, sh.intCompanyLocationId
			, dblQty = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			, strInOut = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN 'OUT' ELSE CASE WHEN sh.dblUnits < 0 THEN 'OUT' ELSE 'IN' END END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
			, ysnReceiptedStorage
			, intTypeId = intTransactionTypeId
			, cs.strStorageType
			, cs.intDeliverySheetId
			, t.strTicketStatus
			, st.ysnDPOwnedType
			, st.strOwnedPhysicalStock
			, st.strStorageTypeDescription
			, st.ysnActive
			, sl.ysnExternal
			, sh.intUserId
		INTO #tmpCustomerOwned
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
			AND st.ysnDPOwnedType = 0
		JOIN tblICItemUOM iuom ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intUnitMeasureId = iuom.intUnitMeasureId and cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = t.intSubLocationId AND sl.intCompanyLocationId = t.intProcessingLocationId
	
		UNION ALL
		SELECT dtmDeliveryDate = (CASE WHEN sh.strType = 'Transfer' THEN  sh.dtmHistoryDate ELSE cs.dtmDeliveryDate END)
			, strBucketType = 'Delayed Pricing'
			, strTransactionType = CASE WHEN intTransactionTypeId IN (1, 5)
											THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
													 ELSE 'NONE' END
										WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
										WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
										WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' END
			, intTransactionRecordId = CASE WHEN intTransactionTypeId IN (1, 5)
												THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.intInventoryReceiptId
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.intInventoryShipmentId
														ELSE NULL END
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
											WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId END
			, strTransactioneNo = CASE WHEN intTransactionTypeId IN (1, 5)
											THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
													WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
													ELSE NULL END
									WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
									WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
									WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo END
			, intTransactionRecordHeaderId = sh.intCustomerStorageId
			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cum.intCommodityUnitMeasureId
			, sh.intCompanyLocationId
			, dblQty = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			, strInOut = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN 'OUT' ELSE CASE WHEN sh.dblUnits < 0 THEN 'OUT' ELSE 'IN' END END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
			, ysnReceiptedStorage
			, intTypeId = intTransactionTypeId
			, cs.strStorageType
			, cs.intDeliverySheetId
			, t.strTicketStatus
			, st.ysnDPOwnedType
			, st.strOwnedPhysicalStock
			, st.strStorageTypeDescription
			, st.ysnActive
			, sl.ysnExternal
			, sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
			and st.ysnDPOwnedType = 1	
		JOIN tblICItemUOM iuom ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intUnitMeasureId = iuom.intUnitMeasureId and cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = t.intSubLocationId AND sl.intCompanyLocationId = t.intProcessingLocationId
		
		UNION ALL
		SELECT dtmDeliveryDate = (CASE WHEN sh.strType = 'Transfer' THEN  sh.dtmHistoryDate ELSE cs.dtmDeliveryDate END)
			, strBucketType = 'Company Owned'
			, strTransactionType = CASE 
										WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
										WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
									END
			, intTransactionRecordId = CASE 
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
										END
			, strTransactionNo = CASE 
									WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
									WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
								END
			, intTransactionRecordHeaderId = sh.intCustomerStorageId
			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cum.intCommodityUnitMeasureId
			, sh.intCompanyLocationId
			, dblQty = CASE 
							WHEN intTransactionTypeId = 3 THEN (CASE WHEN sh.strType = 'Reverse Transfer' THEN - sh.dblUnits ELSE sh.dblUnits END)
							WHEN intTransactionTypeId = 4 THEN (CASE WHEN sh.strType = 'Reverse Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
						END
			, strInOut = (CASE WHEN sh.strType IN ('Reverse Settlement','Reverse Transfer' ) THEN 'OUT' ELSE 'IN' END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
			, ysnReceiptedStorage
			, intTypeId = intTransactionTypeId
			, cs.strStorageType
			, cs.intDeliverySheetId
			, t.strTicketStatus
			, st.ysnDPOwnedType
			, st.strOwnedPhysicalStock
			, st.strStorageTypeDescription
			, st.ysnActive
			, sl.ysnExternal
			, sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
			AND st.ysnDPOwnedType = 0
		JOIN tblICItemUOM iuom ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intUnitMeasureId = iuom.intUnitMeasureId and cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = t.intSubLocationId AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intTransactionTypeId IN(3,4)
		AND sh.strType IN ('Settlement', 'Reverse Settlement', 'From Transfer','Reverse Transfer')

		INSERT INTO @ExistingHistory (strBatchId
			, strBucketType
			, strTransactionType
			, intTransactionRecordId 
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractHeaderId 
			, intTicketId 
			, intCommodityId 
			, intCommodityUOMId 
			, intItemId 
			, intLocationId 
			, dblQty 
			, intEntityId 
			, intUserId 
			, strNotes
			, strMiscFields
			, intActionId)
		SELECT strBatchId = NULL
			, strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactioneNo
			, dtmDeliveryDate
			, intContractHeaderId
			, intTicketId
			, intCommodityId
			, intCommodityUnitMeasureId
			, intItemId
			, intCompanyLocationId
			, dblQty
			, intEntityId
			, intUserId
			, strNotes = (CASE WHEN intTransactionRecordId IS NULL THEN 'Actual transaction was deleted historically.' ELSE NULL END)
			, strMiscFields = CASE WHEN ISNULL(strStorageTypeCode, '') = '' THEN '' ELSE '{ strStorageTypeCode = "' + strStorageTypeCode + '" }' END
								+ CASE WHEN ISNULL(ysnReceiptedStorage, '') = '' THEN '' ELSE '{ ysnReceiptedStorage = "' + CAST(ysnReceiptedStorage AS NVARCHAR) + '" }' END
								+ CASE WHEN ISNULL(intTypeId, '') = '' THEN '' ELSE '{ intTypeId = "' + CAST(intTypeId AS NVARCHAR) + '" }' END
								+ CASE WHEN ISNULL(strStorageType, '') = '' THEN '' ELSE '{ strStorageType = "' + strStorageType + '" }' END
								+ CASE WHEN ISNULL(intDeliverySheetId, '') = '' THEN '' ELSE '{ intDeliverySheetId = "' + CAST(intDeliverySheetId AS NVARCHAR) + '" }' END
								+ CASE WHEN ISNULL(strTicketStatus, '') = '' THEN '' ELSE '{ strTicketStatus = "' + strTicketStatus + '" }' END
								+ CASE WHEN ISNULL(strOwnedPhysicalStock, '') = '' THEN '' ELSE '{ strOwnedPhysicalStock = "' + strOwnedPhysicalStock + '" }' END
								+ CASE WHEN ISNULL(strStorageTypeDescription, '') = '' THEN '' ELSE '{ strStorageTypeDescription = "' + strStorageTypeDescription + '" }' END
								+ CASE WHEN ISNULL(ysnActive, '') = '' THEN '' ELSE '{ ysnActive = "' + CAST(ysnActive AS NVARCHAR) + '" }' END
								+ CASE WHEN ISNULL(ysnExternal, '') = '' THEN '' ELSE '{ ysnExternal = "' + CAST(ysnExternal AS NVARCHAR) + '" }' END
			, intActionId  = 1 --Rebuild
		FROM #tmpCustomerOwned co
		ORDER BY dtmDeliveryDate, intStorageHistoryId
	
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
		PRINT 'End Populate RK Summary Log - Customer Owned'
		DELETE FROM @ExistingHistory

		
        --=======================================
        --                ON HOLD
        --=======================================
        PRINT 'Populate RK Summary Log - On Hold'

        INSERT INTO @ExistingHistory (    
            strBatchId
            ,strBucketType
            ,strTransactionType
            ,intTransactionRecordId 
            ,intTransactionRecordHeaderId
            ,strDistributionType
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
			,intActionId     
        )
         SELECT
            strBatchId = NULL
            ,strBucketType = 'On Hold'
            ,strTransactionType = 'Scale Ticket'
            ,intTransactionRecordId = intTicketId
            ,intTransactionRecordHeaderId = intTicketId
            ,strDistributionType = strStorageTypeDescription
            ,strTransactionNumber = strTicketNumber
            ,dtmTransactionDate  = dtmTicketDateTime
            ,intContractDetailId = intContractId
            ,intContractHeaderId = intContractSequence
            ,intTicketId  = intTicketId
            ,intCommodityId  = TV.intCommodityId
            ,intCommodityUOMId  = CUM.intCommodityUnitMeasureId
            ,intItemId = TV.intItemId
            ,intBookId = NULL
            ,intSubBookId = NULL
            ,intLocationId = intProcessingLocationId
            ,intFutureMarketId = NULL
            ,intFutureMonthId = NULL
            ,dblNoOfLots = 0
            ,dblQty = CASE WHEN strInOutFlag = 'I' THEN dblNetUnits ELSE dblNetUnits * -1 END 
            ,dblPrice = dblUnitPrice
            ,intEntityId 
            ,ysnDelete = 0
            ,intUserId = TV.intEntityScaleOperatorId
            ,strNotes = strTicketComment
			,intActionId  = 1 --Rebuild
        FROM tblSCTicket TV
        LEFT JOIN tblGRStorageType ST on ST.intStorageScheduleTypeId = TV.intStorageScheduleTypeId 
        LEFT JOIN tblICItemUOM IUM ON IUM.intItemUOMId = TV.intItemUOMIdTo
        LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = IUM.intUnitMeasureId AND CUM.intCommodityId = TV.intCommodityId
        WHERE ISNULL(strTicketStatus,'') = 'H'
		
        EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
        PRINT 'End Populate RK Summary Log - On Hold'
        DELETE FROM @ExistingHistory

		UPDATE tblRKRebuildSummaryLog
		SET ysnSuccess = 1
		WHERE intRebuildSummaryLogId = @RebuildLogId

	END
	RETURN;
	
END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE()
	
	UPDATE tblRKRebuildSummaryLog
	SET ysnSuccess = 0
		, strErrorMessage = @ErrMsg
	WHERE intRebuildSummaryLogId = @RebuildLogId

	IF (@ErrMsg != 'You are not allowed to rebuild the Summary Log!')
	BEGIN
		UPDATE tblRKCompanyPreference
		SET ysnAllowRebuildSummaryLog = 1
	END
	
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH