CREATE VIEW [dbo].[vyuARShippedItemDetail]
AS

SELECT
	 [strShippedItemId]				= 'lgis:' + CAST(L.[intLoadId] AS NVARCHAR(250))
	,[strShippedItemDetailId]		= 'lgis:' + CAST(LD.[intLoadDetailId] AS NVARCHAR(250))
	,[intShipmentId]				= L.[intLoadId]
	,[intShipmentPurchaseSalesContractId] = NULL 
	,[intLoadDetailId]				= LD.[intLoadDetailId] 
	,[intCurrencyId]				= ISNULL(ARCC.[intCurrencyId], (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference WHERE intDefaultCurrencyId IS NOT NULL AND intDefaultCurrencyId <> 0))
	,[intSalesOrderDetailId]		= NULL
	,[intInventoryShipmentId]		= NULL	
	,[intInventoryShipmentItemId]	= NULL	
	,[intContractHeaderId]			= ARCC.[intContractHeaderId]
	,[strContractNumber]			= ARCC.[strContractNumber] 
	,[intContractDetailId]			= ARCC.[intContractDetailId] 
	,[intContractSeq]				= ARCC.[intContractSeq] 
	,[intItemId]					= LD.[intItemId]
	,[strItemNo]					= ICI.[strItemNo]
	,[strItemDescription]			= ICI.[strDescription]
	,[intItemUOMId]					= ARCC.intOrderUOMId
	,[strUnitMeasure]				= UOM.[strUnitMeasure]
	,[intShipmentItemUOMId]			= ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId)
	,[strShipmentUnitMeasure]		= SUOM.[strUnitMeasure]
	,[dblQtyShipped]				= dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intOrderUOMId, LD.intWeightItemUOMId), ISNULL(ARCC.intItemUOMId, LD.intItemUOMId), LD.dblQuantity)
	,[dblQtyOrdered]				= ISNULL(LD.dblQuantity, 0)
	,[dblShipmentQuantity]			= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, ARCC.intItemUOMId), ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.dblQuantity, ARCC.dblShipQuantity))
	,[dblShipmentQtyShippedTotal]	= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, ARCC.intItemUOMId), ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.dblQuantity, ARCC.dblShipQuantity))
	,[dblQtyRemaining]				= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, ARCC.intItemUOMId), ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.dblQuantity, ARCC.dblShipQuantity))
	,[dblDiscount]					= 0.00
	,[dblPrice]						= ARCC.dblOrderPrice
	,[dblShipmentUnitPrice]			= (ARCC.dblOrderPrice / dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), 1))
	,[strPricing]					= ''
	,[dblTotalTax]					= 0.00
	,[dblTotal]						= ((ARCC.dblOrderPrice * ISNULL(ARCC.dblSubCurrencyRate, 1.000000)) * dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), 1))
									* dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LDL.dblNet)
	,[intLotId]						= NULL
	,[intAccountId]					= ARIA.[intAccountId]
	,[intCOGSAccountId]				= ARIA.[intCOGSAccountId]
	,[intSalesAccountId]			= ARIA.[intSalesAccountId]
	,[intInventoryAccountId]		= ARIA.[intInventoryAccountId]
	,[intStorageLocationId]			= NULL
	,[strStorageLocationName]		= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS	
	,[intTaxGroupId]				= NULL
	,[strTaxGroup]					= NULL
	,[dblWeight]					= dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(ARCC.intItemUOMId, LD.intItemUOMId), 1.000000)
	,[intWeightUOMId]				= LD.intWeightItemUOMId
	,[strWeightUnitMeasure]			= ARCC.strUnitMeasure
	,[dblGrossWt]					= dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LDL.dblGross)
	,[dblTareWt]					= dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LDL.dblTare)
	,[dblNetWt]						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), LDL.dblNet)
	,[intCurrencyExchangeRateTypeId]= ARCC.[intCurrencyExchangeRateTypeId]
	,[strCurrencyExchangeRateType]	= ARCC.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]	= ARCC.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]		= ARCC.[dblCurrencyExchangeRate]
	,[intSubCurrencyId]				= ARCC.[intSubCurrencyId]
	,[dblSubCurrencyRate]			= ARCC.[dblSubCurrencyRate]
	,[strSubCurrency]				= ARCC.[strSubCurrency]
	,[intDestinationGradeId]		= ARCC.[intDestinationGradeId]
	,[strDestinationGrade]			= ARCC.[strDestinationGrade]
	,[intDestinationWeightId]		= ARCC.[intDestinationWeightId]
	,[strDestinationWeight]			= ARCC.[strDestinationWeight]
FROM
	(
		SELECT intLoadId
			 , strLoadNumber
			 , dtmScheduledDate
		FROM dbo.tblLGLoad WITH (NOLOCK)
		WHERE ysnPosted = 1
	) L
INNER JOIN (
		SELECT intLoadId
			 , intLoadDetailId
			 , intCustomerEntityId
			 , intItemId
			 , intSContractDetailId
			 , intItemUOMId
			 , intWeightItemUOMId
			 , intSCompanyLocationId
			 , intPContractDetailId
			 , dblQuantity			 
		FROM 
			dbo.tblLGLoadDetail WITH (NOLOCK)		

	) LD ON L.intLoadId  = LD.intLoadId
	LEFT JOIN (
		SELECT intLoadDetailId
			 , intWeightUOMId
			 , dblGross	= SUM(dblGross)
			 , dblTare	= SUM(dblTare)
			 , dblNet	= SUM(dblNet)
		FROM dbo.tblLGLoadDetailLot WITH (NOLOCK) 
		GROUP BY
			 intLoadDetailId
			,intWeightUOMId
	) LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
LEFT OUTER JOIN (
	SELECT intContractHeaderId
		 , intContractDetailId
		 , strContractNumber
		 , intContractSeq
		 , intDestinationGradeId
		 , strDestinationGrade
		 , intDestinationWeightId
		 , strDestinationWeight
		 , intSubCurrencyId
		 , intCurrencyId
		 , strUnitMeasure
		 , intOrderUOMId
		 , intPriceItemUOMId
		 , intItemUOMId
		 , strOrderUnitMeasure
		 , intItemWeightUOMId	 
		 , dblCashPrice
		 , dblOrderPrice
		 , dblDetailQuantity
		 , intFreightTermId			 
		 , dblShipQuantity
		 , dblOrderQuantity
		 , dblSubCurrencyRate
		 , strSubCurrency
		 , intCurrencyExchangeRateTypeId
		 , strCurrencyExchangeRateType
		 , intCurrencyExchangeRateId
		 , dblCurrencyExchangeRate
		 , intCompanyLocationId
		 , intTermId
		 , intShipViaId
	 FROM dbo.vyuARCustomerContract WITH (NOLOCK)
	) ARCC ON LD.intSContractDetailId = ARCC.intContractDetailId
INNER JOIN
	(SELECT [intItemId], [strItemNo], [strDescription] FROM tblICItem WITH(NOLOCK)) ICI
		ON LD.[intItemId] = ICI.[intItemId]
LEFT JOIN(
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId) UOM
		ON ARCC.intOrderUOMId = UOM.intItemUOMId
LEFT JOIN(
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId) SUOM
		ON ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId) = SUOM.intItemUOMId							
LEFT OUTER JOIN
	(SELECT [intItemId], [intAccountId], [intLocationId], [intCOGSAccountId], [intSalesAccountId], [intInventoryAccountId] FROM vyuARGetItemAccount) ARIA
		ON LD.[intItemId] = ARIA.[intItemId]
		AND ARCC.[intCompanyLocationId] = ARIA.[intLocationId]
LEFT OUTER JOIN(
	SELECT intTermID
		 , strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)) SMT
		ON ARCC.[intTermId] = SMT.[intTermID]	
LEFT OUTER JOIN(
	SELECT intEntityId
		 , strShipVia
	FROM dbo.tblSMShipVia WITH (NOLOCK)) SMSV
		ON ARCC.[intShipViaId] = SMSV.[intEntityId]
