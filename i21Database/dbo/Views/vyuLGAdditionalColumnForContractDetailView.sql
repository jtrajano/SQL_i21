/* 
	This is the SQL View version of fnCTGetAdditionalColumnForDetailView 
	Any changes on that function should be apply to this view 
*/

CREATE VIEW [dbo].[vyuLGAdditionalColumnForContractDetailView]
AS
SELECT
    CD.intContractDetailId
    ,intSeqCurrencyId               =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN CASE WHEN ISNULL(CXR.ysnExists, 0) = 1
                                                THEN FC.intFromCurrencyId
                                                ELSE TC.intToCurrencyId
                                            END
                                            ELSE CD.intCurrencyId
                                        END
    ,ysnSeqSubCurrency              =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN convert(bit,0)
                                            ELSE CY.ysnSubCurrency
                                            END
    ,intSeqPriceUOMId               =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN CD.intFXPriceUOMId
                                            ELSE ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId)
                                        END
    ,dblSeqPrice                    =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intFXPriceUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),CD.dblCashPrice / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END) * CD.dblRate
                                            ELSE CD.dblCashPrice
                                        END
    ,dblSeqPartialPrice             =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intFXPriceUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),(case when CD.intPricingTypeId = 2 then PF.dblCashPrice else CD.dblCashPrice end) / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END) * CD.dblRate
                                            ELSE (case when CD.intPricingTypeId = 2 then PF.dblCashPrice else CD.dblCashPrice end) -- CT-3677/CT-3681 get the average cash price from fixation details if the contract is partially priced.
                                        END
    ,strSeqCurrency                 =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN CASE WHEN ISNULL(CXR.ysnExists, 0) = 1
                                                THEN (SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = FC.intFromCurrencyId)
                                                ELSE (SELECT TOP 1 strCurrency FROM tblSMCurrency WHERE intCurrencyID = TC.intToCurrencyId)
                                            END
                                            ELSE CY.strCurrency
                                        END
    ,strSeqPriceUOM                 =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN FM.strUnitMeasure
                                            ELSE UM.strUnitMeasure
                                        END
    ,dblQtyToPriceUOMConvFactor     =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intFXPriceUOMId,1)
                                            ELSE dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),1)
                                        END
    ,dblNetWtToPriceUOMConvFactor   =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intNetWeightUOMId,CD.intFXPriceUOMId,1)
                                            ELSE dbo.fnCTConvertQtyToTargetItemUOM(CD.intNetWeightUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),1)
                                        END
    ,dblCostUnitQty                 =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN ISNULL(FU.dblUnitQty,1)
                                            ELSE ISNULL(IU.dblUnitQty,1)
                                        END
    ,dblSeqBasis                    =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intFXPriceUOMId,CD.intBasisUOMId, CD.dblBasis / CASE WHEN AY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(AY.intCent,0) = 0 THEN 1 ELSE AY.intCent END ELSE 1 END) * CD.dblRate
                                            ELSE CD.dblBasis
                                        END
    ,intSeqBasisCurrencyId          =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN CASE WHEN ISNULL(CXR.ysnExists, 0) = 1
                                                THEN FC.intFromCurrencyId
                                                ELSE TC.intToCurrencyId
                                            END
                                            ELSE CD.intBasisCurrencyId
                                        END
    ,intSeqBasisUOMId               =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN CD.intFXPriceUOMId
                                            ELSE CD.intBasisUOMId
                                        END
    ,ysnValidFX                     =   CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN convert(bit,1)
                                            ELSE convert(bit,0)
                                        END
    ,dblSeqFutures                  =   CAST(CASE WHEN FX.ysnUseFXPrice = 1
                                            THEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intFXPriceUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId), CD.dblFutures / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END) * CD.dblRate
                                            ELSE CD.dblFutures
                                        END AS NUMERIC (18,6))
FROM  tblCTContractDetail CD  
LEFT JOIN tblSMCurrency  CY ON CY.intCurrencyID = CD.intCurrencyId  
LEFT JOIN tblICItemUOM  IU ON IU.intItemUOMId  = CD.intPriceItemUOMId  
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId  
LEFT JOIN tblICItemUOM  FU ON FU.intItemUOMId  = CD.intFXPriceUOMId  
LEFT JOIN tblICUnitMeasure FM ON FM.intUnitMeasureId = FU.intUnitMeasureId  
LEFT JOIN tblSMCurrency  AY ON AY.intCurrencyID = CD.intBasisCurrencyId  
LEFT JOIN (
    select
        dblCashPrice = avg(PFD.dblCashPrice)
        ,PF.intContractDetailId
    from
        tblCTPriceFixation PF
    inner join tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
    group by
        PF.intContractDetailId
) PF on PF.intContractDetailId = CD.intContractDetailId
OUTER APPLY (
    SELECT ysnUseFXPrice = CASE WHEN ISNULL(ysnUseFXPrice,0) = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL THEN 1 ELSE 0 END
) FX
OUTER APPLY (
    SELECT ysnExists = 1
    FROM tblSMCurrencyExchangeRate
    WHERE intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId
    AND intToCurrencyId = ISNULL(CY.intMainCurrencyId,CD.intCurrencyId)
) CXR
OUTER APPLY (
    SELECT TOP 1 intFromCurrencyId FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId AND intToCurrencyId = CD.intCurrencyId
) FC
OUTER APPLY (
    SELECT TOP 1 intToCurrencyId FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId AND intFromCurrencyId = ISNULL(CY.intMainCurrencyId,CD.intCurrencyId)
) TC

GO