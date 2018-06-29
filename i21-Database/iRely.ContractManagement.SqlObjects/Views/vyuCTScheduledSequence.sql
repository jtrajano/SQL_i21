CREATE VIEW [dbo].[vyuCTScheduledSequence]

AS

    SELECT ROW_NUMBER() OVER(ORDER BY CD.intContractDetailId DESC) intUniqueId,t.*,CD.intContractSeq,CD.intContractHeaderId FROM
    (
		  SELECT  'Inventory Receipt' strScreenName,RI.intLineNo AS intContractDetailId, IR.strReceiptNumber AS strNumber,IR.intInventoryReceiptId AS intExternalHeaderId,'intInventoryReceiptId' AS strHeaderIdColumn
		  FROM	tblICInventoryReceiptItem	 RI
		  JOIN	tblICInventoryReceipt		 IR ON IR.intInventoryReceiptId = RI.intInventoryReceiptId
		  WHERE	IR.strReceiptType = 'Purchase Contract' 
		  AND	IR.intSourceType = 0 
		  AND	ISNULL(IR.ysnPosted,0) = 0

		  UNION ALL

		  SELECT  'Inventory Shipment' strScreenName, RI.intLineNo AS intContractDetailId, IR.strShipmentNumber AS strNumber,IR.intInventoryShipmentId AS intExternalHeaderId,'intInventoryShipmentId' AS strHeaderIdColumn 
		  FROM	tblICInventoryShipmentItem	 RI
		  JOIN	tblICInventoryShipment	 IR ON IR.intInventoryShipmentId = RI.intInventoryShipmentId
		  WHERE   IR.intOrderType = 1
		  AND	IR.intSourceType = 0 
		  AND	ISNULL(IR.ysnPosted,0) = 0

		  UNION ALL

		  SELECT	'Load Schedule' strScreenName,LD.intPContractDetailId AS intContractDetailId,LO.strLoadNumber AS strNumber,LO.intLoadId AS intExternalHeaderId,'intLoadId' AS strHeaderIdColumn
		  FROM	tblLGLoadDetail		   LD
		  JOIN	tblLGLoad				   LO  ON  LO.intLoadId			    =   LD.intLoadId
		  WHERE   NOT (LO.intPurchaseSale	    =   1 AND LO.intShipmentStatus    IN(4,11))
		  AND	LD.intPContractDetailId IS NOT NULL

		  UNION ALL

		  SELECT	'Load Schedule' strScreenName,LD.intSContractDetailId AS intContractDetailId,LO.strLoadNumber AS strNumber,LO.intLoadId AS intExternalHeaderId,'intLoadId' AS strHeaderIdColumn
		  FROM	tblLGLoadDetail		   LD
		  JOIN	tblLGLoad				   LO  ON  LO.intLoadId			    =   LD.intLoadId
		  WHERE   NOT (LO.intPurchaseSale	    =   2 AND LO.intShipmentStatus    IN(6,11))
		  AND	LD.intSContractDetailId IS NOT NULL

		  UNION ALL

		  SELECT	'Scale' strScreenName,intContractId AS intContractDetailId,strTicketNumber AS strNumber,intTicketId AS intExternalHeaderId,'intTicketId' AS strHeaderIdColumn
		  FROM	tblSCTicket
		  WHERE	ISNULL(intInventoryReceiptId,0) = 0
		  AND	ISNULL(intInventoryShipmentId,0) = 0
		  AND	intContractId IS NOT NULL

		  UNION ALL

		  SELECT  'Purchase Order' strScreenName,PD.intContractDetailId, PO.strPurchaseOrderNumber AS strNumber,PO.intPurchaseId AS intExternalHeaderId,'intPurchaseId' AS strHeaderIdColumn
		  FROM	 tblPOPurchaseDetail	    PD
		  JOIN	 tblPOPurchase			    PO  ON  PO.intPurchaseId		  =	PD.intPurchaseId
    LEFT	  JOIN	 tblICInventoryReceiptItem   RI  ON  RI.intLineNo			  =	PD.intPurchaseDetailId
    LEFT	  JOIN	 tblICInventoryReceipt	    IR  ON  IR.intInventoryReceiptId =	RI.intInventoryReceiptId
		  WHERE	 IR.strReceiptType = 'Purchase Order' 
		  AND	 PD.intContractDetailId IS NOT NULL
		  AND	 ISNULL(IR.ysnPosted,0) = 0

		  UNION ALL

		  SELECT	'Transport'  strScreenName,LR.intContractDetailId, LH.strTransaction  AS strNumber,LH.intLoadHeaderId AS intExternalHeaderId,'intLoadHeaderId' AS strHeaderIdColumn
		  FROM	tblTRLoadReceipt	LR
		  JOIN	tblTRLoadHeader	LH  ON  LR.intLoadHeaderId  =	  LH.intLoadHeaderId
		  WHERE	LR.intContractDetailId  IS NOT NULL
		  AND	ISNULL(LH.ysnPosted,0) = 0

		  UNION ALL

		  SELECT	'Transport'  strScreenName,DD.intContractDetailId, LH.strTransaction  AS strNumber,LH.intLoadHeaderId AS intExternalHeaderId,'intLoadHeaderId' AS strHeaderIdColumn
		  FROM	tblTRLoadDistributionDetail DD
		  JOIN	tblTRLoadDistributionHeader DH  ON	 DH.intLoadDistributionHeaderId  =	  DD.intLoadDistributionHeaderId
		  JOIN	tblTRLoadHeader		   LH  ON  LH.intLoadHeaderId  =	  DH.intLoadHeaderId
		  WHERE	DD.intContractDetailId  IS NOT NULL
		  AND	ISNULL(LH.ysnPosted,0) = 0

		  UNION ALL

		  SELECT	'Invoice'  strScreenName,DL.intContractDetailId, HR.strInvoiceNumber  AS strNumber,HR.intInvoiceId AS intExternalHeaderId,'intInvoiceId' AS strHeaderIdColumn
		  FROM	tblARInvoiceDetail		DL
		  JOIN	tblARInvoice			HR	ON	HR.intInvoiceId	=	DL.intInvoiceId 
		  WHERE	DL.intContractDetailId IS NOT NULL
		  AND	DL.intInventoryShipmentChargeId IS NULL
		  AND	ISNULL(HR.ysnPosted,0) = 0
    )t
    JOIN	  tblCTContractDetail CD ON CD.intContractDetailId = t.intContractDetailId