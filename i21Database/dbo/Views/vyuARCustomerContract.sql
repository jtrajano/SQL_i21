CREATE VIEW [dbo].[vyuARCustomerContract]
AS
SELECT
	 [intContractHeaderId]				= CTCD.[intContractHeaderId]
	,[intContractDetailId]				= CTCD.[intContractDetailId]
	,[strContractNumber]				= CTCH.[strContractNumber]
	,[intContractSeq]					= CTCD.[intContractSeq]
	,[strContractType]					= CTCT.[strContractType]
	,[dtmStartDate]						= CTCD.[dtmStartDate]
	,[dtmEndDate]						= CTCD.[dtmEndDate]
	,[strContractStatus]				= CTCS.[strContractStatus]
	,[intEntityCustomerId]				= CTCH.[intEntityId]
	,[intCurrencyId]					= ISNULL((SELECT [intMainCurrencyId] FROM tblSMCurrency WHERE intCurrencyID = CTCD.[intCurrencyId]), CTCD.[intCurrencyId])
	,[strCurrency]						= ISNULL((SELECT [strCurrency] FROM tblSMCurrency WHERE intCurrencyID = CTCD.[intCurrencyId]), SMC.[strCurrency])
	,[intCompanyLocationId]				= CTCD.[intCompanyLocationId]	
	,[intItemId]						= CTCD.[intItemId]
	,[strItemNo]						= ICI.[strItemNo]
	,[strItemDescription]				= ICI.[strDescription]
	,[intOrderUOMId]					= CTCD.[intItemUOMId]
	,[strOrderUnitMeasure]				= ICUMO.[strUnitMeasure]
	,[intItemUOMId]						= CTCD.[intPriceItemUOMId]
	,[strUnitMeasure]					= ISNULL(ICUMO.[strUnitMeasure], ICUMP.[strUnitMeasure])
	,[intPricingTypeId]					= CTPT.[intPricingTypeId]
	,[strPricingType]					= CTPT.[strPricingType]
	,[dblOrderPrice]					= CTCD.[dblCashPrice] / (CASE WHEN CTCD.[intItemUOMId] <> CTCD.[intPriceItemUOMId] THEN ISNULL(ICIUP.dblUnitQty,1) ELSE 1 END)
	,[dblCashPrice]						= CTCD.[dblCashPrice]
	,[intCurrencyExchangeRateTypeId]	= CTCD.[intRateTypeId] 
	,[strCurrencyExchangeRateType]		= SMCRT.[strCurrencyExchangeRateType]
	,[intCurrencyExchangeRateId]		= CTCD.[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]			= CTCD.[dblRate]
	,[intSubCurrencyId]					= CTCD.[intCurrencyId]
	,[dblSubCurrencyRate]				= CONVERT(NUMERIC(18,6),ISNULL((SELECT intCent FROM tblSMCurrency WHERE intCurrencyID = CTCD.[intCurrencyId]), 1.000000))
	,[strSubCurrency]					= SMC.[strCurrency]
	,[intPriceItemUOMId]				= CTCD.[intPriceItemUOMId]	
	,[dblBalance]						= CTCD.[dblBalance]
	,[dblScheduleQty]					= CTCD.[dblScheduleQty]
	,[dblAvailableQty]					= dbo.fnCalculateQtyBetweenUOM(CTCD.[intItemUOMId], CTCD.[intPriceItemUOMId], (ISNULL(CTCD.dblBalance,0) - ISNULL(CTCD.dblScheduleQty,0)))
	,[dblDetailQuantity]				= CTCD.[dblQuantity] 
	,[dblOrderQuantity]					= CTCD.[dblQuantity] 
	,[dblShipQuantity]					= dbo.fnCalculateQtyBetweenUOM(CTCD.[intItemUOMId], CTCD.[intPriceItemUOMId], CTCD.[dblQuantity] )
	,[ysnUnlimitedQuantity]				= CAST(ISNULL(CTCH.[ysnUnlimitedQuantity],0) AS BIT)
	,[ysnLoad]							= CAST(ISNULL(CTCH.[ysnLoad],0) AS BIT)
	,[ysnAllowedToShow]					= CAST(CASE WHEN CTCD.[intContractStatusId] IN (1,4) THEN 1 ELSE 0 END AS BIT)
	,[intFreightTermId]					= CTCD.[intFreightTermId]
	,[intTermId]						= CTCH.[intTermId]
	,[intShipViaId]						= CTCD.[intShipViaId]
	,[intDestinationGradeId]			= CTCH.[intGradeId]
	,[strDestinationGrade]				= CTCH.[strDestinationGrade]
	,[intDestinationWeightId]			= CTCH.[intWeightId]
	,[strDestinationWeight]				= CTCH.[strDestinationWeight]
	FROM
		(SELECT [intContractHeaderId],
				[intContractDetailId],
				[intContractSeq],
				[dtmStartDate],
				[dtmEndDate],
				[intCurrencyId],
				[intCompanyLocationId],
				[intItemId],
				[intItemUOMId],
				[intPriceItemUOMId],
				[dblCashPrice],
				[dblBalance],
				[dblScheduleQty],
				[dblQuantity],
				[intContractStatusId],
				[intFreightTermId],
				[intShipViaId],
				[intPricingTypeId],
				[intRateTypeId] = NULL, -- temp until CT has committed their changes on tblCTContractDetail,
				[intCurrencyExchangeRateId],
				[dblRate]
		 FROM 
			tblCTContractDetail) CTCD 
	INNER JOIN
		(SELECT	CH.[intContractHeaderId],
				CH.[strContractNumber],
				CH.[intEntityId],
				CH.[ysnUnlimitedQuantity],
				CH.[ysnLoad], 
				CH.[intTermId],
				CH.[intContractTypeId],
				CH.[intGradeId],
				CTDG.[strDestinationGrade],
				CH.[intWeightId],
				CTDW.[strDestinationWeight]
		 FROM
			tblCTContractHeader CH
		LEFT OUTER JOIN
			(
				SELECT
					[intWeightGradeId]		= [intWeightGradeId]
					,[strDestinationGrade]	= [strWeightGradeDesc]
				FROM
					tblCTWeightGrade
			) CTDG
				ON CH.[intGradeId] = CTDG.[intWeightGradeId]
		LEFT OUTER JOIN
			(
				SELECT
					[intWeightGradeId]		= [intWeightGradeId]
					,[strDestinationWeight]	= [strWeightGradeDesc]
				FROM
					tblCTWeightGrade
			) CTDW
				ON CH.[intWeightId] = CTDW.[intWeightGradeId]
		) CTCH ON CTCD.[intContractHeaderId] = CTCH.[intContractHeaderId]
	LEFT OUTER JOIN
		(SELECT [intItemId],
				[strItemNo],
				[strDescription]
		 FROM
			tblICItem) ICI ON CTCD.[intItemId] = ICI.[intItemId] 
	LEFT OUTER JOIN
		(SELECT [intPricingTypeId],
				[strPricingType]
		 FROM 
			tblCTPricingType) CTPT ON CTCD.[intPricingTypeId] = CTPT.[intPricingTypeId]
	LEFT OUTER JOIN
		(SELECT [intContractStatusId],
				[strContractStatus]
		 FROM 
			tblCTContractStatus) CTCS ON CTCD.[intContractStatusId] = CTCS.[intContractStatusId]
	LEFT OUTER JOIN
		(SELECT [intContractTypeId],
				[strContractType]
		 FROM 
			tblCTContractType) CTCT ON CTCH.[intContractTypeId] = CTCT.[intContractTypeId]
	LEFT OUTER JOIN
		(SELECT [intItemUOMId],
				[intUnitMeasureId],
				[intItemId],
				dblUnitQty
		 FROM 
			tblICItemUOM) ICIUP ON CTCD.[intPriceItemUOMId] = ICIUP.[intItemUOMId] AND CTCD.[intItemId] = ICIUP.[intItemId]
	LEFT OUTER JOIN
		(SELECT [intUnitMeasureId],
				[strUnitMeasure]
		 FROM 
			tblICUnitMeasure) ICUMP ON ICIUP.[intUnitMeasureId] = ICUMP.[intUnitMeasureId]
	LEFT OUTER JOIN
		(SELECT [intItemUOMId],
				[intItemId],
				[intUnitMeasureId]
		 FROM 
			tblICItemUOM) ICIUO ON CTCD.[intItemUOMId] = ICIUO.[intItemUOMId] AND CTCD.[intItemId] = ICIUO.[intItemId]
	LEFT OUTER JOIN
		(SELECT [intUnitMeasureId],
				[strUnitMeasure]
		 FROM 
			tblICUnitMeasure) ICUMO ON ICIUO.[intUnitMeasureId] = ICUMO.[intUnitMeasureId]					
	LEFT OUTER JOIN
		(SELECT [intCurrencyID]
				,[strCurrency]
		 FROM 
			tblSMCurrency) SMC ON CTCD.[intCurrencyId] = SMC.[intCurrencyID]
	LEFT OUTER JOIN
		(SELECT	[intCurrencyExchangeRateTypeId]
				,[strCurrencyExchangeRateType]
		FROM
			tblSMCurrencyExchangeRateType) SMCRT ON CTCD.[intRateTypeId] = SMCRT.[intCurrencyExchangeRateTypeId]
	WHERE
		CTCT.[strContractType] = 'Sale'
		AND CTPT.[strPricingType] NOT IN ('Unit','Index')


