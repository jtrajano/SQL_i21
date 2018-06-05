CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceStorageCostReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intInvoiceId INT

	SET @intInvoiceId = @xmlParam
    SELECT 
		LDL.dblNet,
		CH.strContractNumber,
		CD.intContractSeq,
		CH.strCustomerContract,
		strItemDescription = Item.strDescription,
		SC.dblPrice,
		strPrice2Decimals = LTRIM(CAST(ROUND(SC.dblPrice,2) AS NUMERIC(18,2))),
		strPrice4Decimals = LTRIM(CAST(ROUND(SC.dblPrice,4) AS NUMERIC(18,4))),
		SC.dblAmount,
		InvCur.strCurrency,
		strPriceCurrency = PriceCur.strCurrency,
		strPriceUOM = PriceUOM.strUnitMeasure
	FROM tblARInvoice Inv
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = InvDet.intLoadDetailId
	JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblLGLoadStorageCost SC ON SC.intLoadDetailLotId = LDL.intLoadDetailLotId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId	
	JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = SC.intPriceCurrencyId
	JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = SC.intPriceUOMId
	JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
	LEFT JOIN tblICItem Item ON Item.intItemId = SC.intCostType
	WHERE Inv.intInvoiceId = @intInvoiceId AND IsNull(Item.strDescription, '') <> ''
END