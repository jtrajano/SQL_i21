CREATE VIEW [dbo].[vyuLGLoadScheduleForInvoice]
AS
SELECT strTransactionType = 'Load Schedule'
	,strTransactionNumber = L.strLoadNumber
	,strShippedItemId = 'lgis:' + CAST(L.intLoadId AS NVARCHAR(250))
	,intEntityCustomerId = LD.intCustomerEntityId
	,intCurrencyId = AD.intSeqCurrencyId
	,intSalesOrderId = NULL
	,intSalesOrderDetailId = NULL
	,strSalesOrderNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,dtmProcessDate = L.dtmScheduledDate
	,intInventoryShipmentId = NULL
	,intInventoryShipmentItemId = NULL
	,intInventoryShipmentChargeId = NULL
	,strInventoryShipmentNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,intShipmentId = NULL
	,strShipmentNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,intLoadId = L.intLoadId
	,intLoadDetailId = LD.intLoadDetailId
	,intLotId = LDL.intLotId
	,strLoadNumber = L.strLoadNumber
	,intRecipeItemId = NULL
	,intContractHeaderId = CH.intContractHeaderId
	,intContractDetailId = ISNULL(CD.intContractDetailId, LD.intPContractDetailId)
	,intCompanyLocationId = LD.intSCompanyLocationId
	,intShipToLocationId = NULL
	,intFreightTermId = CD.intFreightTermId
	,intItemId = LD.intItemId
	,strItemDescription = ICI.[strDescription]
	,intItemUOMId = ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId)
	,intOrderUOMId = CD.intItemUOMId
	,intShipmentItemUOMId = ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId)
	,intWeightUOMId = LD.intWeightItemUOMId
	,dblWeight = dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(CD.intItemUOMId, LD.intItemUOMId), 1.000000)
	,dblQtyShipped = dbo.fnCalculateQtyBetweenUOM(ISNULL(CD.intItemUOMId, LD.intWeightItemUOMId), ISNULL(CD.intItemUOMId, LD.intItemUOMId), LD.dblQuantity)
	,dblQtyOrdered = ISNULL(LD.dblQuantity, 0)
	,dblShipmentQuantity = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId), ISNULL(LD.dblQuantity, CD.dblQuantity))
	,dblShipmentQtyShippedTotal = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId), ISNULL(LD.dblQuantity, CD.dblQuantity))
	,dblQtyRemaining = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId), ISNULL(LD.dblQuantity, CD.dblQuantity))
	,dblDiscount = 0.0000000
	,dblPrice = dbo.fnCTGetSequencePrice(CD.intContractDetailId)
	,dblShipmentUnitPrice = (
			(
				dbo.fnCTGetSequencePrice(CD.intContractDetailId)
			) / dbo.fnCalculateQtyBetweenUOM(ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), 1)
		)
	,strPricing = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,strVFDDocumentNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,dblTotalTax = 0.000000
	,dblTotal = (
			(
				dbo.fnCTGetSequencePrice(CD.intContractDetailId)
			) / dbo.fnCalculateQtyBetweenUOM(ISNULL(AD.intSeqPriceUOMId, LD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), 1)
		) * dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblNet, LD.dblNet))
	,intStorageLocationId = NULL
	,intTermId = NULL
	,intEntityShipViaId = NULL
	,intTicketId = NULL
	,intTaxGroupId = NULL
	,dblGrossWt = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblGross, LD.dblGross))
	,dblTareWt = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblTare, LD.dblTare))
	,dblNetWt = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblNet, LD.dblNet))
	,strPONumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,strBOLNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,intSplitId = NULL
	,intEntitySalespersonId = NULL
	,ysnBlended = CAST(0 AS BIT)
	,intRecipeId = NULL
	,intSubLocationId = NULL
	,intCostTypeId = NULL
	,intMarginById = NULL
	,intCommentTypeId = NULL
	,dblMargin = NULL
	,dblRecipeQuantity = NULL
	,intStorageScheduleTypeId = NULL
	,intDestinationGradeId = CH.intGradeId
	,intDestinationWeightId = CH.intWeightId
	,intCurrencyExchangeRateTypeId = CD.intRateTypeId
	,intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId
	,dblCurrencyExchangeRate = CD.dblRate
	,intSubCurrencyId = AD.intSeqCurrencyId
	,dblSubCurrencyRate = CASE 
		WHEN AD.ysnSeqSubCurrency = 1
			THEN CU.intCent
		ELSE 1.000000
		END
	, intBookId	= CH.intBookId
	, intSubBookId = CH.intSubBookId
FROM (
	SELECT intLoadId
		,strLoadNumber
		,dtmScheduledDate
	FROM dbo.tblLGLoad WITH (NOLOCK)
	WHERE ysnPosted = 1
		AND intShipmentStatus = 6
	) L
JOIN (
	SELECT intLoadId
		,intLoadDetailId
		,intCustomerEntityId
		,intItemId
		,intSContractDetailId
		,intItemUOMId
		,intWeightItemUOMId
		,intSCompanyLocationId
		,intPContractDetailId
		,dblQuantity
		,dblGross
		,dblTare
		,dblNet
	FROM dbo.tblLGLoadDetail WITH (NOLOCK)
	) LD ON L.intLoadId = LD.intLoadId
LEFT JOIN (
	SELECT intLoadDetailId
		,intWeightUOMId
		,intLotId
		,dblGross = SUM(dblGross)
		,dblTare = SUM(dblTare)
		,dblNet = SUM(dblNet)
	FROM dbo.tblLGLoadDetailLot WITH (NOLOCK)
	GROUP BY intLoadDetailId
		,intLotId, intWeightUOMId
	) LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
INNER JOIN (
	SELECT [intItemId]
		,[strItemNo]
		,[strDescription]
	FROM tblICItem WITH (NOLOCK)
	) ICI ON LD.[intItemId] = ICI.[intItemId]
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
OUTER APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = AD.intSeqCurrencyId