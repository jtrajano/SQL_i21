CREATE VIEW [dbo].[vyuCTScheduledSequence]

AS

WITH Invoice AS (
	SELECT ivd.intContractHeaderId
		, ivd.intContractDetailId
		, ivd.intInvoiceId
		, ivd.intInvoiceDetailId
		, ivd.intTicketId
		, l.intLoadId
	FROM tblARInvoiceDetail ivd
	, tblLGLoad l
	WHERE l.intTicketId = ivd.intTicketId
		AND ivd.intContractDetailId IS NOT NULL
)

SELECT ROW_NUMBER() OVER(ORDER BY CD.intContractDetailId DESC) intUniqueId
	, t.*
	, CD.intContractSeq
	, CD.intContractHeaderId
FROM (
	SELECT 'Inventory Receipt' COLLATE Latin1_General_CI_AS AS strScreenName
		, RI.intLineNo AS intContractDetailId
		, IR.strReceiptNumber AS strNumber
		, IR.intInventoryReceiptId AS intExternalHeaderId
		, 'intInventoryReceiptId' COLLATE Latin1_General_CI_AS AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblICInventoryReceiptItem RI
	JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = RI.intInventoryReceiptId
	WHERE IR.strReceiptType = 'Purchase Contract'
		AND IR.intSourceType = 0
		AND ISNULL(IR.ysnPosted, 0) = 0
	
	UNION ALL SELECT 'Inventory Shipment' strScreenName
		, RI.intLineNo AS intContractDetailId
		, IR.strShipmentNumber AS strNumber
		, IR.intInventoryShipmentId AS intExternalHeaderId
		, 'intInventoryShipmentId' AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblICInventoryShipmentItem RI
	JOIN tblICInventoryShipment IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId
	WHERE IR.intOrderType = 1
		AND IR.intSourceType = 0
		AND ISNULL(IR.ysnPosted, 0) = 0
	
	UNION ALL SELECT 'Load Schedule' strScreenName
		, LD.intPContractDetailId AS intContractDetailId
		, LO.strLoadNumber AS strNumber
		, LO.intLoadId AS intExternalHeaderId
		, 'intLoadId' AS strHeaderIdColumn
		, intInvoiceId = ISNULL(Invoice.intInvoiceId, 0)
	FROM tblLGLoadDetail LD
	JOIN tblLGLoad LO ON LO.intLoadId = LD.intLoadId
	LEFT JOIN Invoice ON Invoice.intContractDetailId = LD.intPContractDetailId
		AND Invoice.intLoadId = LO.intLoadId
	WHERE NOT(LO.intPurchaseSale = 1 AND LO.intShipmentStatus IN(4, 11, 7))
		AND LD.intPContractDetailId IS NOT NULL
		AND ISNULL(LO.ysnCancelled, CONVERT(BIT, 0)) = CONVERT(BIT, 0)
		AND LO.intShipmentType = 1
	
	UNION ALL SELECT 'Load Schedule' strScreenName
		, LD.intSContractDetailId AS intContractDetailId
		, LO.strLoadNumber AS strNumber
		, LO.intLoadId AS intExternalHeaderId
		, 'intLoadId' AS strHeaderIdColumn
		, intInvoiceId = ISNULL(Invoice.intInvoiceId, 0)
	FROM tblLGLoadDetail LD
	JOIN tblLGLoad LO ON LO.intLoadId = LD.intLoadId
	LEFT JOIN Invoice ON Invoice.intContractDetailId = LD.intSContractDetailId
		AND Invoice.intLoadId = LO.intLoadId
	WHERE NOT(LO.intPurchaseSale = 2
		AND LO.intShipmentStatus IN(6, 11, 7))
		AND LD.intSContractDetailId IS NOT NULL
		AND ISNULL(LO.ysnCancelled, CONVERT(BIT, 0)) = CONVERT(BIT, 0)
		AND LO.intShipmentType = 1
	
	UNION ALL SELECT 'Scale' strScreenName
		, intContractId AS intContractDetailId
		, strTicketNumber AS strNumber
		, intTicketId AS intExternalHeaderId
		, 'intTicketId' AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblSCTicket
	WHERE ISNULL(intInventoryReceiptId, 0) = 0
		AND ISNULL(intInventoryShipmentId, 0) = 0
		AND intContractId IS NOT NULL
		AND intLoadId IS NULL
		AND intLoadDetailId IS NULL
	
	UNION ALL SELECT 'Purchase Order' strScreenName
		, PD.intContractDetailId
		, PO.strPurchaseOrderNumber AS strNumber
		, PO.intPurchaseId AS intExternalHeaderId
		, 'intPurchaseId' AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblPOPurchaseDetail PD
	JOIN tblPOPurchase PO ON PO.intPurchaseId = PD.intPurchaseId
	LEFT JOIN tblICInventoryReceiptItem RI ON RI.intLineNo = PD.intPurchaseDetailId
	LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = RI.intInventoryReceiptId
	WHERE ISNULL(IR.strReceiptType, 'Purchase Order') = 'Purchase Order'
		AND PD.intContractDetailId IS NOT NULL
		AND ISNULL(IR.ysnPosted, 0) = 0
	
	UNION ALL SELECT 'Transport' strScreenName
		, LR.intContractDetailId
		, LH.strTransaction AS strNumber
		, LH.intLoadHeaderId AS intExternalHeaderId
		, 'intLoadHeaderId' AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblTRLoadReceipt LR
	JOIN tblTRLoadHeader LH ON LR.intLoadHeaderId = LH.intLoadHeaderId
	WHERE LR.intContractDetailId IS NOT NULL
		AND ISNULL(LH.ysnPosted, 0) = 0
	
	UNION ALL SELECT 'Transport' strScreenName
		, DD.intContractDetailId
		, LH.strTransaction AS strNumber
		, LH.intLoadHeaderId AS intExternalHeaderId
		, 'intLoadHeaderId' AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblTRLoadDistributionDetail DD
	JOIN tblTRLoadDistributionHeader DH ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
	JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = DH.intLoadHeaderId
	WHERE DD.intContractDetailId IS NOT NULL
		AND ISNULL(LH.ysnPosted, 0) = 0
	
	UNION ALL SELECT 'Invoice' strScreenName
		, DL.intContractDetailId
		, HR.strInvoiceNumber AS strNumber
		, HR.intInvoiceId AS intExternalHeaderId
		, 'intInvoiceId' AS strHeaderIdColumn
		, intInvoiceId = ISNULL(HR.intInvoiceId, 0)
	FROM tblARInvoiceDetail DL
	JOIN tblARInvoice HR ON HR.intInvoiceId = DL.intInvoiceId
	WHERE DL.intContractDetailId IS NOT NULL
		AND DL.intInventoryShipmentChargeId IS NULL
		AND ISNULL(HR.ysnPosted, 0) = 0
	
	UNION ALL SELECT 'Sales Order' strScreenName
		, PD.intContractDetailId
		, PO.strSalesOrderNumber AS strNumber
		, PO.intSalesOrderId AS intExternalHeaderId
		, 'intSalesOrderId' AS strHeaderIdColumn
		, intInvoiceId = 0
	FROM tblSOSalesOrderDetail PD
	JOIN tblSOSalesOrder PO ON PO.intSalesOrderId = PD.intSalesOrderId
	LEFT JOIN tblICInventoryShipmentItem RI ON RI.intLineNo = PD.intSalesOrderDetailId
	LEFT JOIN tblICInventoryShipment IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId
	WHERE PD.intContractDetailId IS NOT NULL
		AND ISNULL(IR.intOrderType, 2) = 2
		AND ISNULL(IR.ysnPosted, 0) = 0
) t
JOIN tblCTContractDetail CD ON CD.intContractDetailId = t.intContractDetailId;