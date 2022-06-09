﻿CREATE PROCEDURE [dbo].[uspCTGetFreightTermCost]
	@intContractTypeId INT
	, @intCommodityId INT
	, @intItemId INT
	, @intFromPortId INT
	, @intToPortId INT
	, @intFromTermId INT
	, @intToTermId INT
	, @dtmDate DATETIME
	, @intMarketZoneId INT
	, @intInvoiceCurrencyId INT
	, @intRateTypeId INT
	, @ysnWarningMessage BIT = 1
	, @intSequenceCurrencyId INT

AS
	
BEGIN TRY
	DECLARE @ErrMsg	NVARCHAR(MAX)
		, @ysnFreightTermCost BIT
		, @ysnAutoCalc BIT
		, @intFreightRateMatrixId INT
		, @intCostItemId INT
		, @strCostItem NVARCHAR(100)
		, @intTermCostDetailId INT
		, @intCurrencyId INT
		, @strCurrency NVARCHAR(100)
		, @intItemUOMId INT
		, @strUnitMeasure NVARCHAR(100)
		, @dblValue NUMERIC(18, 6)
		, @strCostMethod NVARCHAR(50)
		, @intFreightItemId INT
		, @intInsuranceItemId INT
		, @ysnFreight BIT
		, @ysnInsurance BIT
		, @intOriginCountryId INT

	DECLARE @CostItems AS TABLE (intCostItemId INT
		, strCostItem NVARCHAR(100)
		, intEntityId INT
		, strEntityName NVARCHAR(100)
		, intCurrencyId INT
		, strCurrency NVARCHAR(100)
		, intItemUOMId INT
		, strUnitMeasure NVARCHAR(100)
		, strCostMethod NVARCHAR(50)
		, dblRate NUMERIC(18, 6)
		, dblAmount NUMERIC(18, 6)
		, dblFX NUMERIC(18, 6))

	SELECT TOP 1 @ysnFreightTermCost = ISNULL(ysnFreightTermCost, 0)
		, @ysnAutoCalc = ISNULL(ysnAutoCalculateFreightTermCost, 0)
		, @intFreightItemId = intDefaultFreightItemId
		, @intInsuranceItemId = intDefaultInsuranceItemId
	FROM vyuCTCompanyPreference

	SELECT @intOriginCountryId = intCountryId FROM tblSMCity
	WHERE intCityId = @intFromPortId
	
	IF (@ysnFreightTermCost = 0)
	BEGIN
		RETURN
	END

	SELECT * INTO #tmpCosts
	FROM vyuCTGetTermCostDetail
	WHERE intLoadingPortId = @intFromPortId
		AND intDestinationPortId = @intToPortId
		AND intLoadingTermId = @intFromTermId
		AND intDestinationTermId = @intToTermId
		AND intMarketZoneId = @intMarketZoneId

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCosts)
	BEGIN
		SELECT TOP 1 @intTermCostDetailId = intTermCostDetailId
			, @intCostItemId = intCostId
			, @strCostItem = strCostItem
			, @intCurrencyId = intCurrencyId
			, @strCurrency = strCurrency
			, @intItemUOMId = intItemUOMId
			, @strUnitMeasure = strUnitMeasure
			, @dblValue = dblValue
			, @strCostMethod = strCostMethod
			, @ysnFreight = ysnFreight
			, @ysnInsurance = ysnInsurance
		FROM #tmpCosts

		IF (@intCostItemId = @intFreightItemId) OR (@ysnFreight = 1)
		BEGIN			
			SELECT TOP 1 @intFreightRateMatrixId = FRM.intFreightRateMatrixId
			FROM tblLGFreightRateMatrix FRM
			JOIN tblSMCity LP ON LP.strCity = FRM.strOriginPort
			JOIN tblSMCity DP ON DP.strCity = FRM.strDestinationCity
			WHERE LP.intCityId = @intFromPortId
				AND DP.intCityId = @intToPortId
				AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) >= FRM.dtmValidFrom
				AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) <= FRM.dtmValidTo
				AND ISNULL(FRM.ysnDefault, 0) = 1

			IF ISNULL(@intFreightRateMatrixId, 0) = 0
			BEGIN
				SELECT TOP 1 @intFreightRateMatrixId = FRM.intFreightRateMatrixId
				FROM tblLGFreightRateMatrix FRM
				JOIN tblSMCity LP ON LP.strCity = FRM.strOriginPort
				JOIN tblSMCity DP ON DP.strCity = FRM.strDestinationCity
				WHERE LP.intCityId = @intFromPortId
					AND DP.intCityId = @intToPortId
					AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) >= FRM.dtmValidFrom
					AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) <= FRM.dtmValidTo
					AND FRM.dblTotalCostPerContainer = (SELECT MIN(dblTotalCostPerContainer)
														FROM tblLGFreightRateMatrix FRM
														JOIN tblSMCity LP ON LP.strCity = FRM.strOriginPort
														JOIN tblSMCity DP ON DP.strCity = FRM.strDestinationCity
														WHERE LP.intCityId = @intFromPortId
															AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) >= FRM.dtmValidFrom
															AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) <= FRM.dtmValidTo
															AND DP.intCityId = @intToPortId)
			END

			IF ISNULL(@intFreightRateMatrixId, 0) <> 0 AND ISNULL(@intCostItemId, 0) <> 0
			BEGIN
				INSERT INTO @CostItems
				SELECT TOP 1 @intCostItemId
					, @strCostItem
					, frm.intEntityId
					, strVendor = em.strName
					, frm.intCurrencyId
					, cur.strCurrency
					, iUOM.intItemUOMId
					, UOM.strUnitMeasure
					, 'Per Unit'
					, dblRate = CASE WHEN ISNULL(ctq.dblWeight, 0) = 0 THEN 0 ELSE (frm.dblTotalCostPerContainer / ctq.dblWeight) END
					, dblAmount = CASE WHEN ISNULL(ctq.dblWeight, 0) = 0 THEN 0 ELSE (frm.dblTotalCostPerContainer / ctq.dblWeight) END
					, dblFX = NULL
				FROM tblLGFreightRateMatrix frm
				JOIN tblEMEntity em ON em.intEntityId = frm.intEntityId
				JOIN tblLGContainerType cnt ON cnt.intContainerTypeId = frm.intContainerTypeId
				JOIN tblLGContainerTypeCommodityQty ctq ON ctq.intContainerTypeId = cnt.intContainerTypeId
				LEFT JOIN tblICItemUOM iUOM ON iUOM.intItemId = @intCostItemId AND iUOM.intUnitMeasureId = ctq.intUnitMeasureId
				LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = iUOM.intUnitMeasureId
				JOIN tblICCommodityAttribute cat ON cat.intCommodityAttributeId = ctq.intCommodityAttributeId
				JOIN tblSMCurrency cur ON cur.intCurrencyID = frm.intCurrencyId
				WHERE ctq.intCommodityId = @intCommodityId
					AND cat.intCountryID = @intOriginCountryId
					AND frm.intFreightRateMatrixId = @intFreightRateMatrixId
			END
			ELSE
			BEGIN
				INSERT INTO @CostItems
				SELECT @intCostItemId
					, @strCostItem
					, NULL
					, NULL
					, NULL
					, NULL
					, NULL
					, NULL
					, 'Per Unit'
					, dblRate = 0
					, dblAmount = 0
					, dblFX = NULL
			END
		END
		ELSE IF (@intCostItemId = @intInsuranceItemId) OR (@ysnInsurance = 1)
		BEGIN
			DECLARE @intGeographicalZoneId INT
			SELECT TOP 1 @intGeographicalZoneId = intGeographicalZoneId FROM tblSMCity
			WHERE intCityId = @intFromPortId


			INSERT INTO @CostItems		
			SELECT @intCostItemId
				, @strCostItem
				, ipf.intEntityId
				, strVendor = em.strName
				, NULL
				, NULL
				, NULL
				, NULL
				, 'Amount'
				, dblRate = ((CASE WHEN @intContractTypeId = 1 THEN pFactor.dblInsurancePercent ELSE sFactor.dblInsurancePercent END) / 100) * (detail.dblInsurancePremiumFactor / 100)
				, dblAmount = ((CASE WHEN @intContractTypeId = 1 THEN pFactor.dblInsurancePercent ELSE sFactor.dblInsurancePercent END) / 100) * (detail.dblInsurancePremiumFactor / 100)
				, dblFX = NULL
			FROM tblLGInsurancePremiumFactor ipf
			JOIN tblLGInsurancePremiumFactorDetail detail ON detail.intInsurancePremiumFactorId = ipf.intInsurancePremiumFactorId
			JOIN tblEMEntity em ON em.intEntityId = ipf.intEntityId
			LEFT JOIN tblLGInsurancePremiumFactorPurchase pFactor ON pFactor.intInsurancePremiumFactorId = ipf.intInsurancePremiumFactorId AND @intContractTypeId = 1 AND pFactor.intFreightTermId = @intFromTermId
			LEFT JOIN tblLGInsurancePremiumFactorSale sFactor ON sFactor.intInsurancePremiumFactorId = ipf.intInsurancePremiumFactorId AND @intContractTypeId = 2 AND sFactor.intFreightTermId = @intToTermId
			JOIN tblICItem item ON item.intItemId = @intItemId AND item.intProductTypeId = ipf.intCommodityAttributeId
			WHERE detail.intLoadingPortId = @intFromPortId
				AND detail.intDestinationPortId = @intToPortId
				AND ISNULL(@intMarketZoneId, 0) = (CASE WHEN @intContractTypeId = 1 THEN ISNULL(@intMarketZoneId, 0) ELSE detail.intDestinationZoneId END)
				AND ISNULL(detail.intProcurementZoneId, 0) = (CASE WHEN @intContractTypeId = 1 THEN ISNULL(@intGeographicalZoneId, 0) ELSE ISNULL(detail.intProcurementZoneId, 0) END)
				AND ipf.intCommodityId = @intCommodityId
				
		END
		ELSE
		BEGIN
			INSERT INTO @CostItems
			SELECT @intCostItemId
				, @strCostItem
				, NULL
				, NULL
				, @intCurrencyId
				, @strCurrency
				, @intItemUOMId
				, @strUnitMeasure
				, @strCostMethod
				, dblRate = @dblValue
				, dblAmount = @dblValue
				, dblFX = NULL
		END

		DELETE FROM #tmpCosts WHERE intTermCostDetailId = @intTermCostDetailId
	END

	DROP TABLE #tmpCosts

	IF EXISTS (SELECT TOP 1 1 FROM @CostItems WHERE ISNULL(dblRate, 0) <> 0)
	BEGIN
		IF @ysnWarningMessage = 1 AND @ysnAutoCalc = 0
		BEGIN
			RAISERROR ('Cost Term detected. Do you want to populate the Costs tab?', 16, 1)
		END
		ELSE
		BEGIN
			SELECT ci.intCostItemId
				, ci.strCostItem
				, ci.intEntityId
				, ci.strEntityName
				, ci.intCurrencyId
				, ci.strCurrency
				, ci.intItemUOMId
				, ci.strUnitMeasure
				, ci.strCostMethod
				, ci.dblRate
				, ci.dblAmount
				, dblFX = ISNULL(CASE WHEN (@intSequenceCurrencyId = ci.intCurrencyId or ci.intCurrencyId = seqCurrency.intMainCurrencyId) THEN 1 ELSE tbl.dblRate END, NULL)
			FROM @CostItems ci
			LEFT JOIN (
				SELECT intRowId = ROW_NUMBER() OVER (PARTITION BY cerd.intCurrencyExchangeRateId ORDER BY cerd.dtmValidFromDate DESC)
					, cerd.dblRate
					, cer.intFromCurrencyId
					, cer.intToCurrencyId
				FROM tblSMCurrencyExchangeRate cer 
				LEFT JOIN tblSMCurrencyExchangeRateDetail cerd ON cerd.intCurrencyExchangeRateId = cer.intCurrencyExchangeRateId AND cerd.intRateTypeId = @intRateTypeId
				left join tblSMCurrency cu on cu.intCurrencyID = @intSequenceCurrencyId
				WHERE (cer.intFromCurrencyId = @intSequenceCurrencyId or cer.intFromCurrencyId = cu.intMainCurrencyId)
					AND CAST(FLOOR(CAST(cerd.dtmValidFromDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME)
			) tbl ON tbl.intToCurrencyId = ci.intCurrencyId AND intRowId = 1
			cross apply (select * from tblSMCurrency where intCurrencyID = @intSequenceCurrencyId) seqCurrency
		END
	END

END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH