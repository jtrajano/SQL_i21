﻿CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceDetailReport]
		@xmlParam NVARCHAR(MAX) = NULL,
		@ysnIncludeOtherChargeItems BIT = 1 
AS
BEGIN
	DECLARE @intInvoiceId INT
	DECLARE @intLineCount INT
	DECLARE @strDocumentNumber NVARCHAR(100)
	DECLARE @ysnDisplayPIInfo BIT = 0
	SET @intInvoiceId = @xmlParam

	SELECT @strDocumentNumber = strDocumentNumber
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @intInvoiceId

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblARInvoice Inv
			JOIN tblARInvoiceDetail InvDet ON Inv.intInvoiceId = InvDet.intInvoiceId
			WHERE Inv.strType = 'Provisional'
				AND Inv.strInvoiceNumber = @strDocumentNumber
			)
	BEGIN
		SET @ysnDisplayPIInfo = 1
	END

	SELECT @intLineCount = COUNT(*)
	FROM tblARInvoice Inv
	JOIN vyuCTEntity EN ON EN.intEntityId = Inv.intEntityCustomerId
		AND EN.strEntityType = 'Customer'
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblICItem Item ON Item.intItemId = InvDet.intItemId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	LEFT JOIN tblSMTaxGroup TaxG ON TaxG.intTaxGroupId = InvDet.intTaxGroupId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WtItemUOM ON WtItemUOM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WtUOM ON WtUOM.intUnitMeasureId = WtItemUOM.intUnitMeasureId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = InvDet.intLoadDetailId
		AND LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = Lot.intLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadDetailContainerLink LDCLink ON LDCLink.intLoadDetailId = ReceiptItem.intSourceId
		AND LDCLink.intLoadContainerId = ReceiptItem.intContainerId
	LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = LDCLink.intLoadContainerId
	WHERE Inv.intInvoiceId = @intInvoiceId
		AND Item.strType <> CASE 
			WHEN @ysnIncludeOtherChargeItems <> 1
				THEN 'Other Charge'
			ELSE ''
			END

    SELECT 
		intInvoiceId = Inv.intInvoiceId,
		intSerialNo = ROW_NUMBER() OVER (ORDER BY InvDet.intInvoiceDetailId),
		Inv.strInvoiceNumber,
		strCustomer = EN.strEntityName,
		strBillToAddress = Inv.strBillToAddress,
		strBillToCity = Inv.strBillToCity,
		strBillToState = Inv.strBillToState,
		strBillToZipCode = Inv.strBillToZipCode,
		strBillToCountry = Inv.strBillToCountry,
		strComments = Inv.strComments,
		strFooterComments = Inv.strFooterComments,
		strTransactionType = Inv.strTransactionType,
		strType = Inv.strType,
		strItemDescription = CASE WHEN ISNULL(CD.strItemSpecification, '') <> ''
				THEN (InvDet.strItemDescription + ' - ' + CD.strItemSpecification)
			ELSE InvDet.strItemDescription
			END,
		dblPrice = InvDet.dblPrice,
		strPrice2Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,2) AS NUMERIC(18,2))),
		strPrice4Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,4) AS NUMERIC(18,4))),
		dblQtyOrdered = InvDet.dblQtyOrdered,
		dblQtyShipped = InvDet.dblQtyShipped,
		dblShipmentGrossWt = InvDet.dblShipmentGrossWt,
		dblShipmentTareWt = InvDet.dblShipmentTareWt,
		dblShipmentNetWt = InvDet.dblShipmentNetWt,
		dblTotal = InvDet.dblTotal,
		dblProvisionalAmount = ISNULL(Inv.dblProvisionalAmount,0),
		strInvoiceCurrency = InvCur.strCurrency,
		strPriceCurrency = PriceCur.strCurrency,
		strPriceUOM = PriceUOM.strUnitMeasure,
		strWeightUOM = WtUOM.strUnitMeasure,
		strCustomerContract = CH.strCustomerContract,
		strContractNumber = CH.strContractNumber,
		intContractSeq = CD.intContractSeq,
		strContainerNumber = Cont.strContainerNumber,
		strMarks = ISNULL(ReceiptLot.strMarkings, Cont.strMarks),
		strLotNumber = ReceiptLot.strLotNumber,
		strParentLotNumber = ReceiptLot.strParentLotNumber,
		dblInvoiceSubtotal = Inv.dblInvoiceSubtotal,
		dblTax = Inv.dblTax,
		dblInvoiceTotal = Inv.dblInvoiceTotal,
		strTaxDescription = TaxG.strDescription,
		intLineCount = @intLineCount,
		ysnDisplayPIInfo = @ysnDisplayPIInfo   
	FROM tblARInvoice Inv
	JOIN vyuCTEntity EN ON EN.intEntityId = Inv.intEntityCustomerId AND strEntityType = 'Customer'
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblICItem Item ON Item.intItemId = InvDet.intItemId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	LEFT JOIN tblSMTaxGroup TaxG ON TaxG.intTaxGroupId = InvDet.intTaxGroupId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId 
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
	LEFT JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WtItemUOM ON WtItemUOM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WtUOM ON WtUOM.intUnitMeasureId = WtItemUOM.intUnitMeasureId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = InvDet.intLoadDetailId
		AND LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId	
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = Lot.intLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = ReceiptItem.intContainerId
	WHERE Inv.intInvoiceId = @intInvoiceId
		AND Item.strType <> CASE WHEN @ysnIncludeOtherChargeItems <> 1 THEN 'Other Charge' ELSE '' END
END