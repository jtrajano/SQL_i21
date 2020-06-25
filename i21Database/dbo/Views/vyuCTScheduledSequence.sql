CREATE VIEW [dbo].[vyuCTScheduledSequence]

AS
	with Invoice as
	(
		select
			ivd.intContractHeaderId
			,ivd.intContractDetailId
			,ivd.intInvoiceId
			,ivd.intInvoiceDetailId
			,ivd.intTicketId
			,l.intLoadId
		from
			tblARInvoiceDetail ivd
			,tblLGLoad l
		where
			l.intTicketId = ivd.intTicketId
			and ivd.intContractDetailId is not null
	),
	schedule_raw as
	(
		select intId = row_number() over(partition by c.intContractDetailId order by a.intLoadDetailId asc)
			,c.intContractDetailId
			,a.intLoadDetailId
			,dblScheduledQty = case when b.intLoadDetailId is not null then 0 else a.dblQuantity end
			,dblOverageQty = case when b.intLoadDetailId is not null and b.dblNetUnits > a.dblQuantity then b.dblNetUnits - a.dblQuantity else 0 end
		from
		tblCTContractDetail c 
		join tblLGLoadDetail a
			on a.intPContractDetailId = c.intContractDetailId
			or a.intSContractDetailId = c.intContractDetailId
		join tblICItemUOM d
			on d.intItemId = c.intItemId
			and d.intItemUOMId = c.intItemUOMId
		left join tblSCTicket b
			on b.intLoadDetailId = a.intLoadDetailId and b.strTicketStatus <> 'O'
	),
	schedule as (
		select intContractDetailId
			,intLoadDetailId
			,dblScheduledQty = case when dblScheduledQty < 0 then 0 else dblScheduledQty end
		from
		(
			select a.intContractDetailId
			,a.intLoadDetailId
			,dblScheduledQty = (a.dblScheduledQty - (a.dblOverageQty - sum(b.dblOverageQty)) *-1)
			from schedule_raw a
			inner join schedule_raw b on a.intId >= b.intId and a.intContractDetailId = b.intContractDetailId
			group by a.intId,a.intContractDetailId,a.intLoadDetailId,a.dblScheduledQty,a.dblOverageQty
		) tbl
	)

    SELECT ROW_NUMBER() OVER(ORDER BY CD.intContractDetailId DESC) intUniqueId,t.*,CD.intContractSeq,CD.intContractHeaderId FROM
    (
		SELECT  'Inventory Receipt' COLLATE Latin1_General_CI_AS AS strScreenName,RI.intLineNo AS intContractDetailId, IR.strReceiptNumber AS strNumber,IR.intInventoryReceiptId AS intExternalHeaderId,'intInventoryReceiptId'  COLLATE Latin1_General_CI_AS AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null
		FROM	tblICInventoryReceiptItem	 RI
		JOIN	tblICInventoryReceipt		 IR ON IR.intInventoryReceiptId = RI.intInventoryReceiptId
		WHERE	IR.strReceiptType = 'Purchase Contract' 
		AND	IR.intSourceType = 0 
		AND	ISNULL(IR.ysnPosted,0) = 0

		UNION ALL

		SELECT  'Inventory Shipment' strScreenName, RI.intLineNo AS intContractDetailId, IR.strShipmentNumber AS strNumber,IR.intInventoryShipmentId AS intExternalHeaderId,'intInventoryShipmentId' AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null 
		FROM	tblICInventoryShipmentItem	 RI
		JOIN	tblICInventoryShipment	 IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId
		WHERE   IR.intOrderType = 1
		AND	IR.intSourceType = 0 
		AND	ISNULL(IR.ysnPosted,0) = 0

		UNION ALL

		SELECT	'Load Schedule' strScreenName,LD.intPContractDetailId AS intContractDetailId,LO.strLoadNumber AS strNumber,LO.intLoadId AS intExternalHeaderId,'intLoadId' AS strHeaderIdColumn, intInvoiceId = ISNULL(Invoice.intInvoiceId,0), dblScheduledQty = isnull(schedule.dblScheduledQty,0)
		FROM	tblLGLoadDetail		   LD
		JOIN	tblLGLoad			   LO  ON  LO.intLoadId			    =   LD.intLoadId
		left join Invoice on Invoice.intContractDetailId = LD.intPContractDetailId and Invoice.intLoadId = LO.intLoadId
		left join schedule on schedule.intContractDetailId = LD.intPContractDetailId and LD.intLoadDetailId = schedule.intLoadDetailId
		WHERE   NOT (LO.intPurchaseSale	    =   1 AND LO.intShipmentStatus    IN(4,11,7))
		AND	LD.intPContractDetailId IS NOT NULL
		AND isnull(LO.ysnCancelled,convert(bit,0)) = convert(bit,0)
		AND LO.intShipmentType = 1

		UNION ALL

		SELECT	'Load Schedule' strScreenName,LD.intSContractDetailId AS intContractDetailId,LO.strLoadNumber AS strNumber,LO.intLoadId AS intExternalHeaderId,'intLoadId' AS strHeaderIdColumn, intInvoiceId = ISNULL(Invoice.intInvoiceId,0), dblScheduledQty = isnull(schedule.dblScheduledQty,0)
		FROM	tblLGLoadDetail			LD
		JOIN	tblLGLoad				LO  ON  LO.intLoadId			    =   LD.intLoadId
		left join Invoice on Invoice.intContractDetailId = LD.intSContractDetailId and Invoice.intLoadId = LO.intLoadId
		left join schedule on schedule.intContractDetailId = LD.intSContractDetailId and LD.intLoadDetailId = schedule.intLoadDetailId
		WHERE   NOT (LO.intPurchaseSale	    =   2 AND LO.intShipmentStatus    IN(6,11,7))
		AND	LD.intSContractDetailId IS NOT NULL
		AND isnull(LO.ysnCancelled,convert(bit,0)) = convert(bit,0)
		AND LO.intShipmentType = 1

		UNION ALL

		SELECT	'Scale' strScreenName,intContractId AS intContractDetailId,strTicketNumber AS strNumber,intTicketId AS intExternalHeaderId,'intTicketId' AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null
		FROM	tblSCTicket
		WHERE	ISNULL(intInventoryReceiptId,0) = 0
		AND	ISNULL(intInventoryShipmentId,0) = 0
		AND	intContractId IS NOT NULL
		AND intLoadId IS NULL
		AND intLoadDetailId IS NULL

		UNION ALL

		SELECT  'Purchase Order' strScreenName,PD.intContractDetailId, PO.strPurchaseOrderNumber AS strNumber,PO.intPurchaseId AS intExternalHeaderId,'intPurchaseId' AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null
		FROM	tblPOPurchaseDetail			PD
		JOIN	tblPOPurchase			    PO  ON  PO.intPurchaseId			=	PD.intPurchaseId
   LEFT JOIN	tblICInventoryReceiptItem	RI  ON  RI.intLineNo				=	PD.intPurchaseDetailId
   LEFT JOIN	tblICInventoryReceipt	    IR  ON  IR.intInventoryReceiptId	=	RI.intInventoryReceiptId
		WHERE	ISNULL(IR.strReceiptType,'Purchase Order') = 'Purchase Order' 
		AND		PD.intContractDetailId IS NOT NULL
		AND		ISNULL(IR.ysnPosted,0) = 0

		UNION ALL

		SELECT	'Transport'  strScreenName,LR.intContractDetailId, LH.strTransaction  AS strNumber,LH.intLoadHeaderId AS intExternalHeaderId,'intLoadHeaderId' AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null
		FROM	tblTRLoadReceipt	LR
		JOIN	tblTRLoadHeader		LH  ON  LR.intLoadHeaderId  =	  LH.intLoadHeaderId
		WHERE	LR.intContractDetailId  IS NOT NULL
		AND		ISNULL(LH.ysnPosted,0) = 0

		UNION ALL

		SELECT	'Transport'  strScreenName,DD.intContractDetailId, LH.strTransaction  AS strNumber,LH.intLoadHeaderId AS intExternalHeaderId,'intLoadHeaderId' AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null
		FROM	tblTRLoadDistributionDetail DD
		JOIN	tblTRLoadDistributionHeader DH  ON	 DH.intLoadDistributionHeaderId  =	  DD.intLoadDistributionHeaderId
		JOIN	tblTRLoadHeader				LH  ON  LH.intLoadHeaderId  =	  DH.intLoadHeaderId
		WHERE	DD.intContractDetailId  IS NOT NULL
		AND		ISNULL(LH.ysnPosted,0) = 0

		UNION ALL

		SELECT	'Invoice'  strScreenName,DL.intContractDetailId, HR.strInvoiceNumber  AS strNumber,HR.intInvoiceId AS intExternalHeaderId,'intInvoiceId' AS strHeaderIdColumn, intInvoiceId = ISNULL(HR.intInvoiceId,0), dblScheduledQty = null
		FROM	tblARInvoiceDetail		DL
		JOIN	tblARInvoice			HR	ON	HR.intInvoiceId	=	DL.intInvoiceId 
		WHERE	DL.intContractDetailId IS NOT NULL
		AND		DL.intInventoryShipmentChargeId IS NULL
		AND		ISNULL(HR.ysnPosted,0) = 0

		UNION ALL

		SELECT  'Sales Order' strScreenName, PD.intContractDetailId, PO.strSalesOrderNumber AS strNumber,PO.intSalesOrderId AS intExternalHeaderId,'intSalesOrderId' AS strHeaderIdColumn, intInvoiceId = 0, dblScheduledQty = null
		FROM	tblSOSalesOrderDetail		PD
		JOIN	tblSOSalesOrder				PO ON PO.intSalesOrderId			=	PD.intSalesOrderId
   LEFT JOIN	tblICInventoryShipmentItem	RI ON RI.intLineNo				=	PD.intSalesOrderDetailId
   LEFT JOIN	tblICInventoryShipment		IR ON IR.intInventoryShipmentId	=	RI.intInventoryShipmentId
		WHERE   PD.intContractDetailId IS NOT NULL
		AND		ISNULL(IR.intOrderType,2) = 2
		AND		ISNULL(IR.ysnPosted,0) = 0
    )t
    JOIN	  tblCTContractDetail CD ON CD.intContractDetailId = t.intContractDetailId
