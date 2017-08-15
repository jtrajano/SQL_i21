CREATE VIEW [dbo].[vyuARCustomerContract]
AS
SELECT intContractHeaderId				= CTCD.intContractHeaderId
	 , intContractDetailId				= CTCD.intContractDetailId
	 , strContractNumber				= CTCH.strContractNumber
	 , intContractSeq					= CTCD.intContractSeq
	 , strContractType					= CTCT.strContractType
	 , dtmStartDate						= CTCD.dtmStartDate
	 , dtmEndDate						= CTCD.dtmEndDate
	 , strContractStatus				= CTCS.strContractStatus
	 , intEntityCustomerId				= CTCH.intEntityId
	 , intCurrencyId					= CASE WHEN CTCD.ysnUseFXPrice = 1 THEN CTCD.intInvoiceCurrencyId ELSE ISNULL(SMC.intMainCurrencyId, CTCD.intCurrencyId) END
	 , strCurrency						= SMC.strCurrency
	 , intCompanyLocationId				= CTCD.intCompanyLocationId	
	 , intItemId						= CTCD.intItemId
	 , strItemNo						= ICI.strItemNo
	 , strItemDescription				= ICI.strDescription
	 , intOrderUOMId					= CTCD.intItemUOMId
	 , strOrderUnitMeasure				= ICUMO.strUnitMeasure
	 , intItemUOMId						= CTCD.intItemUOMId
	 , strUnitMeasure					= ISNULL(ICUMP.strUnitMeasure, ICUMO.strUnitMeasure)
	 , intPricingTypeId					= CTPT.intPricingTypeId
	 , strPricingType					= CTPT.strPricingType
	 , dblOrderPrice					= CASE WHEN CTCD.ysnUseFXPrice = 1 THEN CTCD.dblCashPrice * CTCD.dblRate ELSE CTCD.dblCashPrice END / (CASE WHEN CTCD.intItemUOMId <> CTCD.intPriceItemUOMId THEN ISNULL(ICIUP.dblUnitQty,1) ELSE 1 END)
	 , dblCashPrice						= CASE WHEN CTCD.ysnUseFXPrice = 1 
											   THEN CTCD.dblCashPrice * CTCD.dblRate 
											   ELSE CTCD.dblCashPrice 
										  END
	 , intCurrencyExchangeRateTypeId	= CTCD.intRateTypeId
	 , strCurrencyExchangeRateType		= SMCRT.strCurrencyExchangeRateType
	 , intCurrencyExchangeRateId		= CTCD.intCurrencyExchangeRateId
	 , dblCurrencyExchangeRate			= CTCD.dblRate
	 , intSubCurrencyId					= CTCD.intCurrencyId
	 , dblSubCurrencyRate				= CONVERT(NUMERIC(18,6),ISNULL(SMC.intCent, 1.000000))
	 , strSubCurrency					= SMC.strCurrency
	 , intPriceItemUOMId				= CTCD.intPriceItemUOMId
	 , dblBalance						= CTCD.dblBalance
	 , dblScheduleQty					= CTCD.dblScheduleQty
	 , dblAvailableQty					= dbo.fnCalculateQtyBetweenUOM(CTCD.intItemUOMId, CTCD.intPriceItemUOMId, (ISNULL(CTCD.dblBalance,0) - ISNULL(CTCD.dblScheduleQty,0)))
	 , dblDetailQuantity				= CTCD.dblQuantity 
	 , dblOrderQuantity					= CTCD.dblQuantity
	 , dblShipQuantity					= dbo.fnCalculateQtyBetweenUOM(CTCD.intItemUOMId, CTCD.intPriceItemUOMId, CTCD.dblQuantity)
	 , ysnUnlimitedQuantity				= CAST(ISNULL(CTCH.ysnUnlimitedQuantity,0) AS BIT)
	 , ysnLoad							= CAST(ISNULL(CTCH.ysnLoad,0) AS BIT)
	 , ysnAllowedToShow					= CAST(CASE WHEN CTCD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT)
	 , intFreightTermId					= CTCD.intFreightTermId
	 , intTermId						= CTCH.intTermId
	 , intShipViaId						= CTCD.intShipViaId
	 , intDestinationGradeId			= CTCH.intGradeId
	 , strDestinationGrade				= CTCH.strDestinationGrade
	 , intDestinationWeightId			= CTCH.intWeightId
	 , strDestinationWeight				= CTCH.strDestinationWeight
	 , intItemWeightUOMId				= CTCH.intCommodityUOMId
	 , strWeightUnitMeasure				= ICUMW.strUnitMeasure	 
FROM (
	SELECT intContractHeaderId
		 , intContractDetailId
		 , intContractSeq
		 , dtmStartDate
		 , dtmEndDate
		 , intCurrencyId
		 , intCompanyLocationId
		 , intItemId
		 , intItemUOMId
		 , intPriceItemUOMId
		 , dblCashPrice
		 , dblBalance
		 , dblScheduleQty
		 , dblQuantity
		 , intContractStatusId
		 , intFreightTermId
		 , intShipViaId
		 , intPricingTypeId
		 , intRateTypeId
		 , intCurrencyExchangeRateId
		 , dblRate
		 , intNetWeightUOMId
		 , intInvoiceCurrencyId
		 , ysnUseFXPrice
	FROM dbo.tblCTContractDetail WITH (NOLOCK)
) CTCD 
INNER JOIN (
	SELECT CH.intContractHeaderId
		 , CH.strContractNumber
		 , CH.intEntityId
		 , CH.ysnUnlimitedQuantity
		 , CH.ysnLoad
		 , CH.intTermId
		 , CH.intContractTypeId
		 , CH.intGradeId
		 , CTDG.strDestinationGrade
		 , CH.intWeightId
		 , CH.intCommodityUOMId
		 , CTDW.strDestinationWeight
	FROM dbo.tblCTContractHeader CH WITH (NOLOCK)
		LEFT OUTER JOIN (
			SELECT intWeightGradeId		= intWeightGradeId
				 , strDestinationGrade	= strWeightGradeDesc
			FROM dbo.tblCTWeightGrade WITH (NOLOCK)
		) CTDG ON CH.intGradeId = CTDG.intWeightGradeId
		LEFT OUTER JOIN (
			SELECT intWeightGradeId		= intWeightGradeId
				 , strDestinationWeight	= strWeightGradeDesc
			FROM dbo.tblCTWeightGrade WITH (NOLOCK)
		) CTDW ON CH.intWeightId = CTDW.intWeightGradeId
) CTCH ON CTCD.intContractHeaderId = CTCH.intContractHeaderId
LEFT OUTER JOIN (
	SELECT intItemId
		 , strItemNo
		 , strDescription
	FROM dbo.tblICItem WITH (NOLOCK)
) ICI ON CTCD.intItemId = ICI.intItemId
LEFT OUTER JOIN (
	SELECT intPricingTypeId
		 , strPricingType
	FROM dbo.tblCTPricingType WITH (NOLOCK)
) CTPT ON CTCD.intPricingTypeId = CTPT.intPricingTypeId
LEFT OUTER JOIN (
	SELECT intContractStatusId
		 , strContractStatus
	FROM dbo.tblCTContractStatus WITH (NOLOCK)
) CTCS ON CTCD.intContractStatusId = CTCS.intContractStatusId
LEFT OUTER JOIN (
	SELECT intContractTypeId
		 , strContractType
	FROM dbo.tblCTContractType WITH (NOLOCK)
) CTCT ON CTCH.intContractTypeId = CTCT.intContractTypeId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intUnitMeasureId
		 , intItemId
		 , dblUnitQty
	FROM  dbo.tblICItemUOM WITH (NOLOCK)
) ICIUP ON CTCD.intPriceItemUOMId = ICIUP.intItemUOMId 
	   AND CTCD.intItemId = ICIUP.intItemId
LEFT OUTER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) ICUMP ON ICIUP.intUnitMeasureId = ICUMP.intUnitMeasureId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , intUnitMeasureId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICIUO ON CTCD.intItemUOMId = ICIUO.intItemUOMId 
       AND CTCD.intItemId = ICIUO.intItemId
LEFT OUTER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) ICUMO ON ICIUO.intUnitMeasureId = ICUMO.intUnitMeasureId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , intUnitMeasureId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICIUW ON CTCD.intNetWeightUOMId = ICIUW.intItemUOMId
	   AND CTCD.intItemId = ICIUW.intItemId
LEFT OUTER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) ICUMW ON ICIUW.intUnitMeasureId = ICUMW.intUnitMeasureId
LEFT OUTER JOIN (
	SELECT intCurrencyID		 
		 , intCent
		 , intMainCurrencyId
		 , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) SMC ON CTCD.intCurrencyId = SMC.intCurrencyID
LEFT OUTER JOIN (
	SELECT intCurrencyExchangeRateTypeId
		 , strCurrencyExchangeRateType
	FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
) SMCRT ON CTCD.intRateTypeId = SMCRT.intCurrencyExchangeRateTypeId
LEFT OUTER JOIN (
	SELECT intCurrencyExchangeRateId
		 , intFromCurrencyId
		 , intToCurrencyId
	FROM dbo.tblSMCurrencyExchangeRate WITH (NOLOCK)
) SMCER ON CTCD.intCurrencyExchangeRateId = SMCER.intCurrencyExchangeRateId
OUTER APPLY (
	SELECT TOP 1 intContractDetailId
			   , intItemId
	FROM tblARInvoiceDetail WITH (NOLOCK)
	WHERE CTCD.intContractDetailId = intContractDetailId
	 AND CTCD.intItemId = intItemId
) ID 
WHERE CTCT.strContractType = 'Sale'
 AND (
	(ID.intContractDetailId IS NULL AND CTPT.strPricingType NOT IN ('Unit','Index')) 
	OR (ID.intContractDetailId IS NOT NULL)
 )