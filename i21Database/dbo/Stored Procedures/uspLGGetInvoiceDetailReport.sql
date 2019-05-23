CREATE PROCEDURE [dbo].[uspLGGetInvoiceDetailReport] 
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
	LEFT JOIN tblARInvoiceDetailLot InvDetLot ON InvDetLot.intInvoiceDetailId = InvDet.intInvoiceDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = InvDetLot.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
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
		CASE WHEN ISNULL(CD.strItemSpecification, '') <> ''
				THEN (InvDet.strItemDescription + ' - ' + CD.strItemSpecification)
			ELSE InvDet.strItemDescription
			END AS strItemDescription,
		InvDet.dblPrice,
		strPrice2Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,2) AS NUMERIC(18,2))),
		strPrice4Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,4) AS NUMERIC(18,4))),
	    dblQtyOrdered = CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN InvDetLot.dblQuantityShipped ELSE InvDet.dblQtyOrdered END,
		dblQtyShipped = CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN dbo.fnCalculateQtyBetweenUOM(InvDet.intOrderUOMId, InvDet.intPriceUOMId, InvDetLot.dblQuantityShipped) ELSE InvDet.dblQtyShipped END,
		dblShipmentGrossWt = CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN InvDetLot.dblGrossWeight ELSE InvDet.dblShipmentGrossWt END,
		dblShipmentTareWt = CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN InvDetLot.dblTareWeight ELSE InvDet.dblShipmentTareWt END,
		dblShipmentNetWt = CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN (InvDetLot.dblGrossWeight - InvDetLot.dblTareWeight) ELSE InvDet.dblShipmentNetWt END,
		dblTotal = CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN dbo.fnCalculateQtyBetweenUOM(InvDet.intOrderUOMId, InvDet.intPriceUOMId, InvDetLot.dblQuantityShipped) * InvDet.dblPrice 
						/ CASE WHEN (PriceCur.ysnSubCurrency = 1)  THEN PriceCur.intCent ELSE 1 END
					ELSE InvDet.dblTotal END,
		ISNULL(Inv.dblProvisionalAmount,0) AS dblProvisionalAmount,
		strInvoiceCurrency = InvCur.strCurrency,
		strPriceCurrency = PriceCur.strCurrency,
		strPriceUOM = PriceUOM.strUnitMeasure,
		strWeightUOM = WtUOM.strUnitMeasure,
		CH.strCustomerContract,
		CH.strContractNumber,
		CD.intContractSeq,
		CB.strContractBasis,
		CB.strDescription AS strContractBasisDescription,
		EM.strName AS strEntityName,
		CUS.strFLOId,
		Cont.strContainerNumber AS strContainerNumber,
		Cont.strMarks,
		Inv.dblInvoiceSubtotal,
		Inv.dblTax,
		Inv.dblInvoiceTotal,
		strTaxDescription = TaxG.strDescription,
		intLineCount = @intLineCount,
		ysnDisplayPIInfo = @ysnDisplayPIInfo,
		L.strBLNumber,
		strQtyShippedInfo = LTRIM(dbo.fnRemoveTrailingZeroes(CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN (InvDetLot.dblGrossWeight - InvDetLot.dblTareWeight) ELSE InvDet.dblShipmentNetWt END)) + ' ' + WtUOM.strUnitMeasure + CHAR(13) +
							LTRIM(dbo.fnRemoveTrailingZeroes(CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN InvDetLot.dblTareWeight ELSE InvDet.dblShipmentTareWt END)) + ' ' + WtUOM.strUnitMeasure + ' Tare' + CHAR(13) +
							LTRIM(dbo.fnRemoveTrailingZeroes(CASE WHEN (InvDetLot.intLotId IS NOT NULL) THEN dbo.fnCalculateQtyBetweenUOM(InvDet.intOrderUOMId, InvDet.intPriceUOMId, InvDetLot.dblQuantityShipped) ELSE InvDet.dblQtyShipped END)) + ' ' + OrWtUOM.strUnitMeasure + CHAR(13) 
	FROM tblARInvoice Inv
	JOIN vyuCTEntity EN ON EN.intEntityId = Inv.intEntityCustomerId AND strEntityType = 'Customer'
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblICItem Item ON Item.intItemId = InvDet.intItemId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	LEFT JOIN tblSMTaxGroup TaxG ON TaxG.intTaxGroupId = InvDet.intTaxGroupId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId 
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WtItemUOM ON WtItemUOM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WtUOM ON WtUOM.intUnitMeasureId = WtItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM OrWtItemUOM ON OrWtItemUOM.intItemUOMId = InvDet.intOrderUOMId
	LEFT JOIN tblICUnitMeasure OrWtUOM ON OrWtUOM.intUnitMeasureId = OrWtItemUOM.intUnitMeasureId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = InvDet.intLoadDetailId
		AND LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId	
	LEFT JOIN tblARInvoiceDetailLot InvDetLot ON InvDetLot.intInvoiceDetailId = InvDet.intInvoiceDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = InvDetLot.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = Lot.intLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = ReceiptItem.intContainerId
	LEFT JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	LEFT JOIN tblARCustomer CUS ON CUS.intEntityId = EM.intEntityId
	WHERE Inv.intInvoiceId = @intInvoiceId
		AND Item.strType <> CASE WHEN @ysnIncludeOtherChargeItems <> 1 THEN 'Other Charge' ELSE '' END
END