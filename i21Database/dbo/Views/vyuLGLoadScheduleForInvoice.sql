CREATE VIEW [dbo].[vyuLGLoadScheduleForInvoice]
AS
SELECT strTransactionType = 'Load Schedule' COLLATE Latin1_General_CI_AS
	,strTransactionNumber = L.strLoadNumber
	,strShippedItemId = 'lgis:' + CAST(L.intLoadId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	,intEntityCustomerId = LD.intCustomerEntityId
	,intCurrencyId = CASE WHEN L.intSourceType = 7 
						THEN LD.intPriceCurrencyId 
					 ELSE 
						CASE WHEN (CD.ysnUseFXPrice = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL) 
							THEN CD.intInvoiceCurrencyId 
						ELSE 
							CASE WHEN AD.ysnSeqSubCurrency = 1 THEN 
									(SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = intSeqCurrencyId )
								ELSE 
									AD.intSeqCurrencyId 
								END
							END
					 END
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
	,intLotId = NULL
	,strLoadNumber = L.strLoadNumber
	,intRecipeItemId = NULL
	,intContractHeaderId = CH.intContractHeaderId
	,intContractDetailId = ISNULL(CD.intContractDetailId, LD.intPContractDetailId)
	,intCompanyLocationId = LD.intSCompanyLocationId
	,intShipToLocationId = intCustomerEntityLocationId
	,intFreightTermId = CD.intFreightTermId
	,intItemId = LD.intItemId
	,strItemDescription = ICI.[strDescription]
	,intItemUOMId = LD.intWeightItemUOMId
	,intOrderUOMId = CD.intItemUOMId
	,intShipmentItemUOMId = LD.intWeightItemUOMId
	,intWeightUOMId = LD.intWeightItemUOMId
	,dblWeight = dbo.fnCalculateQtyBetweenUOM(ISNULL(CD.intItemUOMId, LD.intItemUOMId), LD.intWeightItemUOMId, 1.000000)
	,dblQtyShipped = ISNULL(LD.dblQuantity, 0)
	,dblQtyOrdered = ISNULL(LD.dblQuantity, 0)
	,dblShipmentQuantity = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId), ISNULL(LD.dblQuantity, CD.dblQuantity))
	,dblShipmentQtyShippedTotal = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId), ISNULL(LD.dblQuantity, CD.dblQuantity))
	,dblQtyRemaining = dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId), ISNULL(LD.dblQuantity, CD.dblQuantity))
	,dblDiscount = 0.0000000
	,dblPrice = CASE 
				WHEN L.intSourceType = 7
					THEN LD.dblUnitPrice
				ELSE dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
				END
    ,dblShipmentUnitPrice = CASE WHEN L.intSourceType = 7 THEN  (
                         LD.dblUnitPrice
                    ) * dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(LD.intPriceUOMId, LD.intItemUOMId), 1)
					 ELSE (
                    (
                        dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
                    ) * dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId), 1)
            ) 
			END
	,intPriceUOMId = ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId)
	,strPricing = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,strVFDDocumentNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,dblTotalTax = 0.000000
    ,dblTotal = CASE WHEN L.intSourceType = 7 THEN 
	            (
                    (
                        LD.dblUnitPrice
                    ) * dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(LD.intPriceUOMId, LD.intItemUOMId), 1)
	            ) * dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId), ISNULL(LD.dblNet, CD.dblNetWeight))
			 ELSE
				(
					(
                        dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
                    ) * dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(AD.intSeqPriceUOMId, LD.intPriceUOMId), 1)
				) * dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, CD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId), ISNULL(LD.dblNet, CD.dblNetWeight))
			END
	,intStorageLocationId = NULL
	,intTermId = NULL
	,intEntityShipViaId = NULL
	,intTicketId = NULL
	,intTaxGroupId = NULL
	,dblGrossWt = dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LD.dblGross)
	,dblTareWt = dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LD.dblTare)
	,dblNetWt = dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LD.dblNet)
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
		,intSourceType
	FROM dbo.tblLGLoad WITH (NOLOCK)
	WHERE ysnPosted = 1
		AND intShipmentStatus = 6
	) L
JOIN (
	SELECT intLoadId
		,intLoadDetailId
		,intCustomerEntityId
		,intCustomerEntityLocationId
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
		,dblUnitPrice
		,dblAmount
		,intPriceCurrencyId
		,intPriceUOMId
	FROM dbo.tblLGLoadDetail WITH (NOLOCK)
	) LD ON L.intLoadId = LD.intLoadId
INNER JOIN (
	SELECT [intItemId]
		,[strItemNo]
		,[strDescription]
	FROM tblICItem WITH (NOLOCK)
	) ICI ON LD.[intItemId] = ICI.[intItemId]
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
OUTER APPLY (
	SELECT intContractDetailId	= CTD.intContractDetailId
		 , ysnSeqSubCurrency	= CY.ysnSubCurrency
		 , dblPriceUOMQuantity	= ISNULL([dbo].[fnCalculateQtyBetweenUOM](CTD.intItemUOMId, ISNULL(ISNULL(CTD.intPriceItemUOMId, CTD.intAdjItemUOMId), CTD.intItemUOMId), 1.000000),ISNULL(CTD.dblQuantity, 0.000000))		 
		 , intSeqCurrencyId		= CASE WHEN CTD.ysnUseFXPrice = 1 AND CTD.intCurrencyExchangeRateId IS NOT NULL AND CTD.dblRate IS NOT NULL AND CTD.intFXPriceUOMId IS NOT NULL  
									   THEN ISNULL(CURTO.intFromCurrencyId, CURFROM.intToCurrencyId)
									   ELSE CTD.intCurrencyId
								  END
		 , intSeqPriceUOMId		= CASE WHEN CTD.ysnUseFXPrice = 1 AND CTD.intCurrencyExchangeRateId IS NOT NULL AND CTD.dblRate IS NOT NULL AND CTD.intFXPriceUOMId IS NOT NULL  
									   THEN CTD.intFXPriceUOMId
									   ELSE ISNULL(CTD.intPriceItemUOMId, CTD.intAdjItemUOMId)
								  END
	FROM tblCTContractDetail CTD WITH (NOLOCK)
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CTD.intCurrencyId
	OUTER APPLY (
		SELECT TOP 1 intFromCurrencyId
		FROM tblSMCurrencyExchangeRate 
		WHERE intCurrencyExchangeRateId = CTD.intCurrencyExchangeRateId 
			AND intToCurrencyId = CTD.intCurrencyId
	) CURTO
	OUTER APPLY (
		SELECT TOP 1 intToCurrencyId
		FROM tblSMCurrencyExchangeRate 
		WHERE intCurrencyExchangeRateId = CTD.intCurrencyExchangeRateId 
			AND intFromCurrencyId = CTD.intCurrencyId
	) CURFROM
	WHERE CTD.intContractDetailId = CD.intContractDetailId 
) AD
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = AD.intSeqCurrencyId