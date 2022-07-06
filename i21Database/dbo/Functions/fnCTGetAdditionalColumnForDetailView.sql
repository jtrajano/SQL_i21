﻿CREATE FUNCTION [dbo].[fnCTGetAdditionalColumnForDetailView]
(
	@intContractDetailId	INT
)

RETURNS @returntable TABLE  
(  
 intSeqCurrencyId    INT,  
 ysnSeqSubCurrency    BIT,  
 intSeqPriceUOMId    INT,  
 dblSeqPrice      NUMERIC(18,6),  
 dblSeqPartialPrice      NUMERIC(18,6), 
 strSeqCurrency     NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
 strSeqPriceUOM     NVARCHAR(100) COLLATE Latin1_General_CI_AS,  
 dblQtyToPriceUOMConvFactor  NUMERIC(18,6),  
 dblNetWtToPriceUOMConvFactor NUMERIC(18,6),  
 dblCostUnitQty     NUMERIC(38, 20),  
 dblSeqBasis      NUMERIC(18,6),  
 intSeqBasisCurrencyId   INT,  
 intSeqBasisUOMId    INT,  
 ysnValidFX      BIT,  
 dblSeqFutures     NUMERIC(18,6)  
)  
  
AS  
BEGIN  
  
 DECLARE
	@dblPartialCashPrice  NUMERIC(18,6),
	@dblCashPrice  NUMERIC(18,6),  
    @intCurrencyId  INT,  
    @intPriceItemUOMId INT,  
    @dblRate   NUMERIC(38,20),  
    @intFXPriceUOMId INT,  
    @intExchangeRateId INT,  
    @intSeqCurrencyId INT,  
    @strSeqCurrency  NVARCHAR(100),  
    @intItemUOMId  INT,  
    @ysnSubCurrency  BIT,  
    @dblMainCashPrice NUMERIC(18,6),  
	@dblMainPartialCashPrice NUMERIC(18,6),  
    @strCurrency  NVARCHAR(100),  
    @strPriceUOM  NVARCHAR(100),  
    @strFXPriceUOM  NVARCHAR(100),  
    @intMainCurrencyId INT,  
    @ysnUseFXPrice  BIT,  
    @intNetWeightUOMId INT,  
    @dblCostUnitQty  NUMERIC(38, 20),  
    @dblFXCostUnitQty NUMERIC(38, 20),  
    @dblBasis   NUMERIC(18,6),  
    @dblMainBasis  NUMERIC(18,6),  
    @intBasisCurrencyId INT,  
    @intBasisUOMId  INT,  
    @dblFutures   INT,  
    @dblMainFutures  INT;
  
 WITH PF as
 (
		select
			dblCashPrice = avg(PFD.dblCashPrice)
			,PF.intContractDetailId
		from
			tblCTPriceFixation PF
		inner join tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
		group by
			PF.intContractDetailId
 )
 SELECT
	@dblCashPrice  = CD.dblCashPrice,  
	@dblPartialCashPrice  = (case when CD.intPricingTypeId = 2 then PF.dblCashPrice else CD.dblCashPrice end), -- CT-3677/CT-3681 get the average cash price from fixation details if the contract is partially priced.
    @dblMainCashPrice = CD.dblCashPrice / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END,  
    @dblMainPartialCashPrice = (case when CD.intPricingTypeId = 2 then PF.dblCashPrice else CD.dblCashPrice end) / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END,  
    @intCurrencyId  = CD.intCurrencyId,  
    @intMainCurrencyId = ISNULL(CY.intMainCurrencyId,CD.intCurrencyId),  
    @ysnSubCurrency  = CY.ysnSubCurrency,  
    @intPriceItemUOMId = ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),  
    @dblRate   = CD.dblRate,  
    @intFXPriceUOMId = CD.intFXPriceUOMId,  
    @intExchangeRateId = CD.intCurrencyExchangeRateId,  
    @intItemUOMId  = CD.intItemUOMId,  
    @strCurrency  = CY.strCurrency,  
    @strPriceUOM  = UM.strUnitMeasure,  
    @strFXPriceUOM  = FM.strUnitMeasure,  
    @ysnUseFXPrice  = ysnUseFXPrice,  
    @intNetWeightUOMId = CD.intNetWeightUOMId,  
    @dblCostUnitQty  = ISNULL(IU.dblUnitQty,1),  
    @dblFXCostUnitQty = ISNULL(FU.dblUnitQty,1),  
    @dblBasis   = CD.dblBasis,  
    @dblMainBasis  = CD.dblBasis / CASE WHEN AY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(AY.intCent,0) = 0 THEN 1 ELSE AY.intCent END ELSE 1 END,  
    @intBasisCurrencyId = CD.intBasisCurrencyId,  
    @intBasisUOMId  = CD.intBasisUOMId,  
    @dblFutures   = CD.dblFutures,  
    @dblMainFutures  = CD.dblFutures / CASE WHEN CY.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(CY.intCent,0) = 0 THEN 1 ELSE CY.intCent END ELSE 1 END  
  
 FROM  tblCTContractDetail CD  
 LEFT JOIN tblSMCurrency  CY ON CY.intCurrencyID = CD.intCurrencyId  
 LEFT JOIN tblICItemUOM  IU ON IU.intItemUOMId  = CD.intPriceItemUOMId  
 LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId  
 LEFT JOIN tblICItemUOM  FU ON FU.intItemUOMId  = CD.intFXPriceUOMId  
 LEFT JOIN tblICUnitMeasure FM ON FM.intUnitMeasureId = FU.intUnitMeasureId  
 LEFT JOIN tblSMCurrency  AY ON AY.intCurrencyID = CD.intBasisCurrencyId  
 LEFT JOIN PF on PF.intContractDetailId = CD.intContractDetailId
 WHERE  CD.intContractDetailId = @intContractDetailId  
  
  
 IF ISNULL(@ysnUseFXPrice,0) = 1 AND @intExchangeRateId IS NOT NULL AND @dblRate IS NOT NULL AND @intFXPriceUOMId IS NOT NULL  
 BEGIN  
  IF EXISTS(SELECT * FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intToCurrencyId = @intMainCurrencyId)  
  BEGIN  
   SELECT @intSeqCurrencyId = intFromCurrencyId FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intToCurrencyId = @intMainCurrencyId  
   SELECT @dblRate = 1 / CASE WHEN ISNULL(@dblRate,0) = 0 THEN 1 ELSE @dblRate END  
  END  
  ELSE  
  BEGIN  
   SELECT @intSeqCurrencyId = intToCurrencyId FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intFromCurrencyId = @intMainCurrencyId  
  END  
  
  SELECT @strSeqCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intSeqCurrencyId  
  
  INSERT INTO @returntable  
  SELECT @intSeqCurrencyId,  
    0,  
    @intFXPriceUOMId,  
    CASE WHEN @ysnUseFXPrice = 1 THEN @dblMainCashPrice * @dblRate ELSE dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId,@intPriceItemUOMId,@dblMainCashPrice) * @dblRate END,   --CT-7022 DETAIL CASH PRICE MULTIPLY BY FX RATE
    CASE WHEN @ysnUseFXPrice = 1 THEN @dblMainCashPrice * @dblRate ELSE dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId,@intPriceItemUOMId,@dblMainPartialCashPrice) * @dblRate END,   --CT-7022 DETAIL CASH PRICE MULTIPLY BY FX RATE
    @strSeqCurrency,  
    @strFXPriceUOM,  
    dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intFXPriceUOMId,1),  
    dbo.fnCTConvertQtyToTargetItemUOM(@intNetWeightUOMId,@intFXPriceUOMId,1),  
    @dblFXCostUnitQty,  
    dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId,@intBasisUOMId,@dblMainBasis) * @dblRate,  
    @intSeqCurrencyId,  
    @intFXPriceUOMId,  
    1,  
    dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId,@intPriceItemUOMId,@dblMainFutures) * @dblRate  
 END  
 ELSE  
 BEGIN  
  INSERT INTO @returntable  
  SELECT @intCurrencyId,  
    @ysnSubCurrency,  
    @intPriceItemUOMId,  
    @dblCashPrice, 
	@dblPartialCashPrice, 
    @strCurrency,  
    @strPriceUOM,  
    dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intPriceItemUOMId,1),  
    dbo.fnCTConvertQtyToTargetItemUOM(@intNetWeightUOMId,@intPriceItemUOMId,1),  
    @dblCostUnitQty,  
    @dblBasis,  
    @intBasisCurrencyId,  
    @intBasisUOMId,  
    0,  
    @dblFutures  
 END  
  
 RETURN;  
END