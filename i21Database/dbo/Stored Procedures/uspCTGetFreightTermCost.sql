CREATE PROCEDURE [dbo].[uspCTGetFreightTermCost]
	@intContractTypeId INT
	, @intCommodityId INT
	, @intItemContractId INT = NULL
	, @intFromPortId INT
	, @intToPortId INT
	, @intFromTermId INT
	, @intToTermId INT
	, @dtmDate DATETIME

AS
	
BEGIN TRY
	DECLARE @ErrMsg	NVARCHAR(MAX)
		, @ysnFreightTermCost BIT
		, @intDefaultFreightId INT
		, @intDefaultInsuranceId INT
		, @@intDefaultTHCId INT
		, @intDefaultStorageId INT
		, @intFreightRateMatrixId INT


	SELECT TOP 1 @ysnFreightTermCost = ysnFreightTermCost
		, @intDefaultFreightId = intDefaultFreightId
		, @intDefaultInsuranceId = intDefaultInsuranceId
		, @@intDefaultTHCId = intDefaultTHCId
		, @intDefaultStorageId = intDefaultStorageId
	FROM tblCTCompanyPreference

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
		--AND ISNULL(FRM.ysnDefault, 0) = 1

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


	IF ISNULL(@intFreightRateMatrixId, 0) = 0
	BEGIN
		SELECT frm.intEntityId
			, strVendor = em.strName
			, cat.strDescription
			, *
		FROM tblLGFreightRateMatrix frm
		JOIN tblEMEntity em ON em.intEntityId = frm.intEntityId
		JOIN tblLGContainerType ct ON ct.intContainerTypeId = frm.intContainerTypeId
		JOIN tblLGContainerTypeCommodityQty ctq ON ctq.intContainerTypeId = ct.intContainerTypeId
		JOIN tblICCommodityAttribute cat ON cat.intCommodityAttributeId = ctq.intCommodityAttributeId
		WHERE ctq.intCommodityId = @intCommodityId
			--cat.intCountryID
		
		
		--IF @intItemContractId IS NOT NULL
		--BEGIN
		--	SELECT  @strDisplayField = strCountry 
		--	FROM    tblICItemContract	IC
		--	JOIN    tblSMCountry		RY	ON	RY.intCountryID	=	IC.intCountryId
		--	WHERE   IC.intItemContractId = @intItemContractId
		--END
		--ELSE IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodityAttribute WHERE strType	=	'Origin')
		--BEGIN
		--	SELECT @strDisplayField = NULL
		--END
		--ELSE
		--BEGIN
		--	SELECT @intCountryId = intOriginId  FROM tblICItem WHERE intItemId = @intItemId
				
		--	IF @intCountryId IS NOT NULL
		--		SELECT	@strDisplayField = strCountry 
		--		FROM	tblICCommodityAttribute			CA																		
		--		JOIN	tblSMCountry		OG	ON	OG.intCountryID	=	CA.intCountryID
		--		WHERE   CA.intCommodityAttributeId			=		@intCountryId	
		--		AND		CA.strType							=		'Origin'
		--END
	END





END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH