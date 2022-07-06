CREATE FUNCTION [dbo].[fnLGCalculateOptionalityPremium](
	@intContractDetailId AS INT,		/* Contract Detail Id */
	@intLoadDetailId AS INT,			/* Load Detail Id */
	@intPriceUOMId AS INT = NULL,		/* Optionality Premium rate converted to this UOM */
	@intPriceCurrencyId AS INT = NULL)	/* Optionality Premium rate converted to this Currency */
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @dblOptionalityPremium NUMERIC(18, 6) = NULL
			,@dblCropYearPremium NUMERIC(18, 6) = NULL
			,@dblLoadingPortPremium NUMERIC(18, 6) = NULL
			,@dblDestinationPortPremium NUMERIC(18, 6) = NULL
			,@intLoadId INT

	/* Parameter validation and sanitation */
	IF (@intContractDetailId IS NULL OR NOT EXISTS(SELECT 1 FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId))
		OR (@intLoadDetailId IS NULL OR NOT EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId))
		RETURN NULL;

	/* If Item UOM is not specified, use Contract price item UOM */
	IF (@intPriceUOMId IS NULL)
		SELECT @intPriceUOMId = intPriceItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

	/* If Price Currency is not specified, use Contract price basis currency */
	IF (@intPriceCurrencyId IS NULL)
		SELECT @intPriceCurrencyId = intBasisCurrencyId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

	/* Calculate Loading Port Optionality Premium */
	SELECT TOP 1 @dblLoadingPortPremium = dbo.fnCalculateCostBetweenUOM(OptUOM.intItemUOMId, @intPriceUOMId, CO.dblPremiumDiscount)
	FROM tblCTContractOptionality CO
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CO.intContractDetailId
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = @intLoadDetailId
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblSMCity LP ON LP.intCityId = CD.intLoadingPortId
	OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM 
					WHERE intItemId = LD.intItemId AND intUnitMeasureId = CO.intUnitMeasureId) OptUOM
	WHERE CO.intContractDetailId = @intContractDetailId
		AND L.strOriginPort <> LP.strCity
		AND CO.intOptionId = 1 /* Loading Port */
		AND CO.strValue = L.strOriginPort

	/* Calculate Destination Port Optionality Premium */
	SELECT TOP 1 @dblDestinationPortPremium = dbo.fnCalculateCostBetweenUOM(OptUOM.intItemUOMId, @intPriceUOMId, CO.dblPremiumDiscount)
	FROM tblCTContractOptionality CO
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CO.intContractDetailId
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = @intLoadDetailId
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblSMCity LP ON LP.intCityId = CD.intDestinationPortId
	OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM 
					WHERE intItemId = LD.intItemId AND intUnitMeasureId = CO.intUnitMeasureId) OptUOM
	WHERE CO.intContractDetailId = @intContractDetailId
		AND L.strDestinationPort <> LP.strCity
		AND CO.intOptionId = 2 /* Destination Port */
		AND CO.strValue = L.strDestinationPort

	/* Calculate Crop Year Optionality Premium */
	SELECT TOP 1 @dblCropYearPremium = dbo.fnCalculateCostBetweenUOM(OptUOM.intItemUOMId, @intPriceUOMId, CO.dblPremiumDiscount)
	FROM tblCTContractOptionality CO
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CO.intContractDetailId
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = @intLoadDetailId
	INNER JOIN tblCTCropYear CY ON CY.intCropYearId = LD.intCropYearId
	OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM 
					WHERE intItemId = LD.intItemId AND intUnitMeasureId = CO.intUnitMeasureId) OptUOM
	WHERE CO.intContractDetailId = @intContractDetailId
		AND LD.intCropYearId <> CH.intCropYearId
		AND CO.intOptionId = 3 /* Crop Year */
		AND CO.strValue = CY.strCropYear

	/* Optionality Premium = crop year + loading port + destination port */
	SET @dblOptionalityPremium = ISNULL(@dblLoadingPortPremium, 0) + ISNULL(@dblDestinationPortPremium, 0) + ISNULL(@dblCropYearPremium, 0)

	RETURN @dblOptionalityPremium;

END

