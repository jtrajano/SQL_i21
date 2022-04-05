﻿CREATE PROCEDURE [dbo].[uspCTGetFreightTermCost]
	@intContractTypeId INT
	, @intCommodityId INT
	, @intFromPortId INT
	, @intToPortId INT
	, @intFromTermId INT
	, @intToTermId INT
	, @dtmDate DATETIME
	, @intMarketZoneId INT
	, @ysnWarningMessage BIT = 1

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
		, @intUnitMeasureId INT
		, @strUnitMeasure NVARCHAR(100)
		, @dblValue NUMERIC(18, 6)
		, @strCostMethod NVARCHAR(50)
		, @intFreightItemId INT
		, @intInsuranceItemId INT
		, @ysnFreight BIT
		, @ysnInsurance BIT

	DECLARE @CostItems AS TABLE (intCostItemId INT
		, strCostItem NVARCHAR(100)
		, intEntityId INT
		, strEntityName NVARCHAR(100)
		, intCurrencyId INT
		, strCurrency NVARCHAR(100)
		, intUnitMeasureId INT
		, strUnitMeasure NVARCHAR(100)
		, strCostMethod NVARCHAR(50)
		, dblRate NUMERIC(18, 6)
		, dblAmount NUMERIC(18, 6))

	SELECT TOP 1 @ysnFreightTermCost = ISNULL(ysnFreightTermCost, 0)
		, @ysnAutoCalc = ISNULL(ysnAutoCalculateFreightTermCost, 0)
		, @intFreightItemId = intDefaultFreightItemId
		, @intInsuranceItemId = intDefaultInsuranceItemId
	FROM vyuCTCompanyPreference
	
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
			, @intUnitMeasureId = intUnitMeasureId
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
				AND ISNULL(FRM.ysnDefault, 0) = 1

			IF ISNULL(@intFreightRateMatrixId, 0) = 0
			BEGIN
				SELECT TOP 1 @intFreightRateMatrixId = FRM.intFreightRateMatrixId
				FROM tblLGFreightRateMatrix FRM
				JOIN tblSMCity LP ON LP.strCity = FRM.strOriginPort
				JOIN tblSMCity DP ON DP.strCity = FRM.strDestinationCity
				WHERE LP.intCityId = @intFromPortId
					AND DP.intCityId = @intToPortId
					AND FRM.dblTotalCostPerContainer = (SELECT MAX(dblTotalCostPerContainer)
														FROM tblLGFreightRateMatrix FRM
														JOIN tblSMCity LP ON LP.strCity = FRM.strOriginPort
														JOIN tblSMCity DP ON DP.strCity = FRM.strDestinationCity
														WHERE LP.intCityId = @intFromPortId
															AND DP.intCityId = @intToPortId)
			END

			IF ISNULL(@intFreightRateMatrixId, 0) <> 0 AND ISNULL(@intCostItemId, 0) <> 0
			BEGIN
				INSERT INTO @CostItems
				SELECT @intCostItemId
					, @strCostItem
					, frm.intEntityId
					, strVendor = em.strName
					, @intCurrencyId
					, @strCurrency
					, @intUnitMeasureId
					, @strUnitMeasure
					, @strCostMethod
					, dblRate = CASE WHEN ISNULL(ctq.dblWeight, 0) = 0 THEN 0 ELSE (frm.dblTotalCostPerContainer / ctq.dblWeight) END
					, dblAmount = CASE WHEN ISNULL(ctq.dblWeight, 0) = 0 THEN 0 ELSE (frm.dblTotalCostPerContainer / ctq.dblWeight) END
				FROM tblLGFreightRateMatrix frm
				JOIN tblEMEntity em ON em.intEntityId = frm.intEntityId
				JOIN tblLGContainerType cnt ON cnt.intContainerTypeId = frm.intContainerTypeId
				JOIN tblLGContainerTypeCommodityQty ctq ON ctq.intContainerTypeId = cnt.intContainerTypeId
				JOIN tblICCommodityAttribute cat ON cat.intCommodityAttributeId = ctq.intCommodityAttributeId
				WHERE ctq.intCommodityId = @intCommodityId
					AND frm.intFreightRateMatrixId = @intFreightRateMatrixId
			END
		END
		ELSE IF (@intCostItemId = @intInsuranceItemId) OR (@ysnInsurance = 1)
		BEGIN
			INSERT INTO @CostItems		
			SELECT @intCostItemId
				, @strCostItem
				, ipf.intEntityId
				, strVendor = em.strName
				, @intCurrencyId
				, @strCurrency
				, @intUnitMeasureId
				, @strUnitMeasure
				, @strCostMethod
				, dblRate = detail.dblInsurancePremiumFactor
				, dblAmount = detail.dblInsurancePremiumFactor
			FROM tblLGInsurancePremiumFactor ipf
			JOIN tblLGInsurancePremiumFactorDetail detail ON detail.intInsurancePremiumFactorId = ipf.intInsurancePremiumFactorId
			JOIN tblEMEntity em ON em.intEntityId = ipf.intEntityId
			WHERE detail.intLoadingPortId = @intFromPortId
				AND detail.intDestinationPortId = @intToPortId
				AND @intMarketZoneId = (CASE WHEN @intContractTypeId = 1 THEN detail.intLoadingZoneId ELSE detail.intDestinationZoneId END)
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
				, @intUnitMeasureId
				, @strUnitMeasure
				, @strCostMethod
				, dblRate = CASE WHEN @strCostMethod = 'Amount' THEN 0 ELSE @dblValue END
				, dblAmount = CASE WHEN @strCostMethod = 'Amount' THEN @dblValue ELSE 0 END
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
			SELECT * FROM @CostItems
		END
	END

END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH