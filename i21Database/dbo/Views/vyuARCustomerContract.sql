CREATE VIEW [dbo].[vyuARCustomerContract]
	AS

SELECT
	 [intContractHeaderId]	= CTCD.[intContractHeaderId]
	,[intContractDetailId]	= CTCD.[intContractDetailId]
	,[strContractNumber]	= CTCH.[strContractNumber]
	,[intContractSeq]		= CTCD.[intContractSeq]
	,[strContractType]		= CTCT.[strContractType]
	,[dtmStartDate]			= CTCD.[dtmStartDate]
	,[dtmEndDate]			= CTCD.[dtmEndDate]
	,[strContractStatus]	= CTCS.[strContractStatus]
	,[intEntityCustomerId]	= CTCH.[intEntityId]
	,[intCurrencyId]		= ISNULL((SELECT [intMainCurrencyId] FROM tblSMCurrency WHERE intCurrencyID = CTCD.[intCurrencyId]), CTCD.[intCurrencyId])
	,[intCompanyLocationId]	= CTCD.[intCompanyLocationId]	
	,[intItemId]			= CTCD.[intItemId]
	,[strItemNo]			= ICI.[strItemNo]
	,[strItemDescription]	= ICI.[strDescription]
	,[intOrderUOMId]		= CTCD.[intItemUOMId]
	,[strOrderUnitMeasure]	= ICUMO.[strUnitMeasure]
	,[intItemUOMId]			= CTCD.[intPriceItemUOMId]
	,[strUnitMeasure]		= ICUMP.[strUnitMeasure]
	,[intPricingTypeId]		= CTPT.[intPricingTypeId]
	,[strPricingType]		= CTPT.[strPricingType]
	,[dblOrderPrice]		= CTCD.[dblCashPrice] / (CASE WHEN CTCD.[intItemUOMId] <> CTCD.[intPriceItemUOMId] THEN ISNULL(ICIUP.dblUnitQty,1) ELSE 1 END)
	,[dblCashPrice]			= CTCD.[dblCashPrice]
	,[intSubCurrencyId]		= CTCD.[intCurrencyId]
	,[dblSubCurrencyRate]	= CONVERT(NUMERIC(18,6),ISNULL((SELECT intCent FROM tblSMCurrency WHERE intCurrencyID = CTCD.[intCurrencyId]), 1.000000))
	,[strSubCurrency]		= SMC.[strCurrency]
	,[intPriceItemUOMId]	= CTCD.[intPriceItemUOMId]	
	,[dblBalance]			= CTCD.[dblBalance]
	,[dblScheduleQty]		= CTCD.[dblScheduleQty]
	,[dblAvailableQty]		= dbo.fnCalculateQtyBetweenUOM(CTCD.[intItemUOMId], CTCD.[intPriceItemUOMId], (ISNULL(CTCD.dblBalance,0) - ISNULL(CTCD.dblScheduleQty,0)))
	,[dblDetailQuantity]	= CTCD.[dblQuantity] 
	,[dblOrderQuantity]		= CTCD.[dblQuantity] 
	,[dblShipQuantity]		= dbo.fnCalculateQtyBetweenUOM(CTCD.[intItemUOMId], CTCD.[intPriceItemUOMId], CTCD.[dblQuantity] )
	,[ysnUnlimitedQuantity]	= CAST(ISNULL(CTCH.[ysnUnlimitedQuantity],0) AS BIT)
	,[ysnLoad]				= CAST(ISNULL(CTCH.[ysnLoad],0) AS BIT)
	,[ysnAllowedToShow]		= CAST(CASE WHEN CTCD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT)
	,[intFreightTermId]		= CTCD.[intFreightTermId]
	,[intTermId]			= CTCH.[intTermId]
	,[intShipViaId]			= CTCD.[intShipViaId] 
	FROM
		tblCTContractDetail CTCD
	INNER JOIN
		tblCTContractHeader CTCH
			ON CTCD.[intContractHeaderId] = CTCH.[intContractHeaderId]
	LEFT OUTER JOIN
		tblICItem ICI
			ON CTCD.[intItemId] = ICI.[intItemId] 
	LEFT OUTER JOIN
		tblCTPricingType CTPT
			ON CTCD.[intPricingTypeId] = CTPT.[intPricingTypeId]
	LEFT OUTER JOIN
		tblCTContractStatus CTCS
			ON CTCD.[intContractStatusId] = CTCS.[intContractStatusId]
	LEFT OUTER JOIN
		tblCTContractType CTCT
			ON CTCH.[intContractTypeId] = CTCT.[intContractTypeId]
	LEFT OUTER JOIN
		tblICItemUOM ICIUP
			ON CTCD.[intPriceItemUOMId] = ICIUP.[intItemUOMId]
			AND CTCD.[intItemId] = ICIUP.[intItemId]
	LEFT OUTER JOIN
		tblICUnitMeasure ICUMP
			ON ICIUP.[intUnitMeasureId] = ICUMP.[intUnitMeasureId]
	LEFT OUTER JOIN
		tblICItemUOM ICIUO
			ON CTCD.[intItemUOMId] = ICIUO.[intItemUOMId]
			AND CTCD.[intItemId] = ICIUO.[intItemId]
	LEFT OUTER JOIN
		tblICUnitMeasure ICUMO
			ON ICIUO.[intUnitMeasureId] = ICUMO.[intUnitMeasureId]					
	LEFT OUTER JOIN
		tblSMCurrency SMC
			ON CTCD.[intCurrencyId] = SMC.[intCurrencyID]					 
	WHERE
		CTCT.[strContractType] = 'Sale'
		AND CTPT.[strPricingType] NOT IN ('Unit','Index')