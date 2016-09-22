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
	,[intItemUOMId]			= CTCD.[intItemUOMId]
	,[strPricingType]		= CTPT.[strPricingType]
	,[dblCashPrice]			= CTCD.[dblCashPrice]
	,[intSubCurrencyId]		= CTCD.[intCurrencyId]
	,[dblSubCurrencyRate]	= CONVERT(NUMERIC(18,6),ISNULL((SELECT intCent FROM tblSMCurrency WHERE intCurrencyID = CTCD.[intCurrencyId]), 1.000000))
	,[strSubCurrency]		= SMC.[strCurrency]
	,[intPriceItemUOMId]	= CTCD.[intPriceItemUOMId]
	,[strPriceUOM]			= ICUM.[strUnitMeasure]
	,[dblBalance]			= CTCD.[dblBalance]
	,[dblScheduleQty]		= CTCD.[dblScheduleQty]
	,[dblAvailableQty]		= (ISNULL(CTCD.dblBalance,0) - ISNULL(CTCD.dblScheduleQty,0))	
	,[ysnUnlimitedQuantity]	= CTCH.[ysnUnlimitedQuantity]	
	FROM
		tblCTContractDetail CTCD
	INNER JOIN
		tblCTContractHeader CTCH
			ON CTCD.[intContractHeaderId] = CTCH.[intContractHeaderId]
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
		tblICItemUOM ICIU
			ON CTCD.[intPriceItemUOMId] = ICIU.[intItemUOMId]
			AND CTCD.[intItemId] = ICIU.[intItemId]
	LEFT OUTER JOIN
		tblICUnitMeasure ICUM
			ON ICIU.[intUnitMeasureId] = ICUM.[intUnitMeasureId]
	LEFT OUTER JOIN
		tblSMCurrency SMC
			ON CTCD.[intCurrencyId] = SMC.[intCurrencyID]					 
	WHERE
		CTCT.[strContractType] = 'Sale'
		AND CTPT.[strPricingType] NOT IN ('Unit','Index')
