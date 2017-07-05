﻿CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceDetailReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intInvoiceId INT

	SET @intInvoiceId = @xmlParam
    SELECT 
		Inv.intInvoiceId,
		intSerialNo = ROW_NUMBER() OVER (ORDER BY InvDet.intInvoiceDetailId),
		Inv.strInvoiceNumber,
		strCustomer = EN.strEntityName,
		Inv.strBillToAddress,
		Inv.strBillToCity,
		Inv.strBillToState,
		Inv.strBillToZipCode,
		Inv.strBillToCountry,
		Inv.strComments,
		Inv.strFooterComments,
		Inv.strTransactionType,
		Inv.strType,
		InvDet.strItemDescription,
		InvDet.dblPrice,
		strPrice2Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,2) AS NUMERIC(18,2))),
		strPrice4Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,4) AS NUMERIC(18,4))),
		InvDet.dblQtyShipped,
		InvDet.dblShipmentGrossWt,
		InvDet.dblShipmentTareWt,
		InvDet.dblShipmentNetWt,
		InvDet.dblTotal,
		strInvoiceCurrency = InvCur.strCurrency,
		strPriceCurrency = PriceCur.strCurrency,
		strPriceUOM = PriceUOM.strUnitMeasure,
		strWeightUOM = WtUOM.strUnitMeasure,
		CH.strCustomerContract,
		CH.strContractNumber,
		CD.intContractSeq,
		Cont.strContainerNumber,
		Cont.strMarks
	FROM tblARInvoice Inv
	JOIN vyuCTEntity EN ON EN.intEntityId = Inv.intEntityCustomerId
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId 
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
	LEFT JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WtItemUOM ON WtItemUOM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WtUOM ON WtUOM.intUnitMeasureId = WtItemUOM.intUnitMeasureId
	LEFT JOIN tblLGLoad L ON L.intLoadId = Inv.intLoadId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId AND LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadDetailContainerLink LDCLink ON LDCLink.intLoadDetailId = ReceiptItem.intSourceId AND LDCLink.intLoadContainerId = ReceiptItem.intContainerId
	LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = LDCLink.intLoadContainerId
	WHERE Inv.intInvoiceId = @intInvoiceId
END