CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceItemDetailReport]
		@xmlParam NVARCHAR(MAX) = NULL,
		@ysnIncludeOtherChargeItems BIT = 1 
AS
BEGIN
	DECLARE @intInvoiceId INT
	DECLARE @intLineCount INT
	DECLARE @strDocumentNumber NVARCHAR(100)
	DECLARE @ysnDisplayPIInfo BIT = 0
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
		CASE WHEN (SELECT COUNT(1)  FROM tblCTContractCertification WHERE intContractDetailId = CD.intContractDetailId) > 0
		THEN 
			STUFF((
			SELECT DISTINCT ',' + CER.strCertificationName
			FROM tblCTContractCertification CC 
			JOIN tblICCertification CER ON CER.intCertificationId = CC.intCertificationId
			WHERE intContractDetailId = 20
			FOR XML PATH('')
				,TYPE
			).value('.', 'NVARCHAR(MAX)'), 1, 1, '') + ' ' + Item.strDescription + ' ' + CD.strItemSpecification
			ELSE
				CASE WHEN ISNULL(CD.strItemSpecification, '') <> ''
						THEN (InvDet.strItemDescription + ' - ' + CD.strItemSpecification)
					ELSE InvDet.strItemDescription
					END 
		END
		AS strItemDescription,
		InvDet.dblPrice,
		strPrice2Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,2) AS NUMERIC(18,2))),
		strPrice4Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice,4) AS NUMERIC(18,4))),
		InvDet.dblQtyShipped,
		InvDet.dblShipmentGrossWt,
		InvDet.dblShipmentTareWt,
		InvDet.dblShipmentNetWt,
		InvDet.dblTotal,
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
		VEN.strFLOId,
		Cont.strContainerNumber,
		Cont.strMarks,
		Inv.dblInvoiceSubtotal,
		Inv.dblTax,
		Inv.dblInvoiceTotal,
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
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
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
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = ReceiptItem.intContainerId
	LEFT JOIN tblEMEntity EM ON EM.intEntityId = ISNULL(CD.intProducerId,CH.intProducerId)
	LEFT JOIN tblAPVendor VEN ON VEN.intEntityId = EM.intEntityId
	WHERE Inv.intInvoiceId = @intInvoiceId
		AND Item.strType <> CASE WHEN @ysnIncludeOtherChargeItems <> 1 THEN 'Other Charge' ELSE '' END
END