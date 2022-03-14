CREATE PROCEDURE [dbo].[uspCTGetFreightTermCost]
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
		, @intDefaultFreightId INT
		, @intDefaultInsuranceId INT
		, @intDefaultTHCId INT
		, @intDefaultStorageId INT
		, @intFreightRateMatrixId INT
		, @strFreightItem NVARCHAR(100)
		, @strInsuranceItem NVARCHAR(100)
		, @strTHCItem NVARCHAR(100)
		, @strStorageItem NVARCHAR(100)

	DECLARE @CostItems AS TABLE (intCostItemId INT
		, strCostItem NVARCHAR(100)
		, intEntityId INT
		, strEntityName NVARCHAR(100)
		, dblRate NUMERIC(18, 6)
		, dblAmount NUMERIC(18, 6))

	SELECT TOP 1 @ysnFreightTermCost = ISNULL(ysnFreightTermCost, 0)
		, @ysnAutoCalc = ISNULL(ysnAutoCalculateFreightTermCost, 0)
		, @intDefaultFreightId = intDefaultFreightId
		, @intDefaultInsuranceId = intDefaultInsuranceId
		, @intDefaultTHCId = intDefaultTHCId
		, @intDefaultStorageId = intDefaultStorageId
		, @strFreightItem = strFreightItem
		, @strInsuranceItem = strInsuranceItem
		, @strTHCItem = strTHCItem
		, @strStorageItem = strStorageItem
	FROM vyuCTCompanyPreference

	IF (@ysnFreightTermCost = 0)
	BEGIN
		RETURN
	END

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


	IF ISNULL(@intFreightRateMatrixId, 0) <> 0 AND ISNULL(@intDefaultFreightId, 0) <> 0
	BEGIN
		INSERT INTO @CostItems
		SELECT @intDefaultFreightId
			, @strFreightItem
			, frm.intEntityId
			, strVendor = em.strName
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

	IF ISNULL(@intDefaultInsuranceId, 0) <> 0
	BEGIN
		INSERT INTO @CostItems		
		SELECT @intDefaultInsuranceId
			, @strInsuranceItem
			, ipf.intEntityId
			, strVendor = em.strName
			, dblRate = detail.dblInsurancePremiumFactor
			, dblAmount = detail.dblInsurancePremiumFactor
		FROM tblLGInsurancePremiumFactor ipf
		JOIN tblLGInsurancePremiumFactorDetail detail ON detail.intInsurancePremiumFactorId = ipf.intInsurancePremiumFactorId
		JOIN tblEMEntity em ON em.intEntityId = ipf.intEntityId
		WHERE detail.intLoadingPortId = @intFromPortId
			AND detail.intDestinationPortId = @intToPortId
			AND @intMarketZoneId = (CASE WHEN @intContractTypeId = 1 THEN detail.intLoadingZoneId ELSE detail.intDestinationZoneId END)
	END

	IF (ISNULL(@intDefaultTHCId, 0) <> 0)
	BEGIN
		INSERT INTO @CostItems
		SELECT @intDefaultTHCId
			, @strTHCItem
			, NULL
			, NULL
			, dblRate = 0
			, dblAmount = 0
	END

	IF (ISNULL(@intDefaultStorageId, 0) <> 0)
	BEGIN
		INSERT INTO @CostItems
		SELECT @intDefaultStorageId
			, @strStorageItem
			, NULL
			, NULL
			, dblRate = 0
			, dblAmount = 0
	END


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