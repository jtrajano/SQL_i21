CREATE VIEW [dbo].[vyuGRSettleStorageBillDetail]
AS
SELECT 
	SS.intSettleStorageId
	,SS.intParentSettleStorageId
	,SS.strStorageTicket
	,AP.intBillId
	,AP.strBillId
	,CH.intContractHeaderId
	,CH.strContractNumber
	,CD.intContractDetailId
	,CD.intContractSeq
	,APD.intItemId
	,C.strItemNo
	,strItemDescription = C.strDescription
	,APD.strMiscDescription
	,APD.dblQtyOrdered
	,APD.dblQtyReceived
	,APD.dblCost
	,dblSubtotal = APD.dblTotal + APD.dblTax
	,APD.dblTotal
	,APD.dblTax
	,strUOM = CASE WHEN (APD.intWeightUOMId > 0) THEN weightUOM.strUnitMeasure ELSE uom.strUnitMeasure END
	,GLA.strAccountId
	,strAccountDescription = GLA.strDescription
	,ISNULL(VPI.ysnPaid,0) AS ysnPaid
	,AP.ysnPosted
	,strTaxGroup = CASE WHEN E.intTaxGroupId IS NOT NULL THEN E.strTaxGroup ELSE F.strTaxGroup END
FROM tblGRSettleStorage SS
INNER JOIN tblGRSettleStorageBillDetail SBD
	ON SBD.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblAPBill AP	
	ON AP.intBillId = SBD.intBillId
INNER JOIN tblAPBillDetail APD
	ON APD.intBillId = AP.intBillId
LEFT JOIN dbo.vyuAPVouchersPaymentInfo VPI
	ON VPI.intBillId = AP.intBillId
LEFT JOIN dbo.tblCTContractHeader CH
	ON CH.intContractHeaderId = APD.intContractHeaderId
LEFT JOIN dbo.tblGLAccount GLA 
	ON APD.intAccountId = GLA.intAccountId
LEFT JOIN dbo.tblICItem C 
	ON APD.intItemId = C.intItemId
LEFT JOIN dbo.tblSMTaxGroup E 
	ON APD.intTaxGroupId = E.intTaxGroupId
LEFT JOIN dbo.tblSMTaxGroup F 
	ON APD.intTaxGroupId = F.intTaxGroupId
INNER JOIN dbo.tblSMCurrency CUR 
	ON CUR.intCurrencyID = AP.intCurrencyId
LEFT JOIN dbo.tblCTContractDetail CD
	ON CD.intContractHeaderId = CH.intContractHeaderId
	AND CD.intContractDetailId = APD.intContractDetailId
LEFT JOIN dbo.tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = AP.intShipToId
LEFT JOIN (dbo.tblICItemUOM weightItemUOM INNER JOIN dbo.tblICUnitMeasure weightUOM ON weightItemUOM.intUnitMeasureId = weightUOM.intUnitMeasureId)
	ON APD.intWeightUOMId = weightItemUOM.intItemUOMId
LEFT JOIN (dbo.tblICItemUOM itemUOM INNER JOIN dbo.tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId)
	ON APD.intUnitOfMeasureId = itemUOM.intItemUOMId
LEFT JOIN (dbo.tblICItemUOM costUOM INNER JOIN dbo.tblICUnitMeasure um ON costUOM.intUnitMeasureId = um.intUnitMeasureId)
	ON APD.intCostUOMId = costUOM.intItemUOMId
LEFT JOIN dbo.tblICStorageLocation SL
	ON SL.intStorageLocationId = APD.intStorageLocationId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation subLoc
	ON APD.intSubLocationId = subLoc.intCompanyLocationSubLocationId