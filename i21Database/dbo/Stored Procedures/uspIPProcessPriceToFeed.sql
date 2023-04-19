CREATE PROCEDURE uspIPProcessPriceToFeed @intEntityId INT
	,@intSourceId INT -- intContractDetailId / intSampleId
	,@strSource NVARCHAR(50) -- Contract / Sample
	,@strRowState NVARCHAR(50) = '' -- Added / Modified
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dtmCurrentDate DATETIME
		,@dblCashPrice NUMERIC(18, 6)
		,@ysnSendPriceFeed BIT = 0
		,@intContractDetailId INT
		,@intSampleId INT
		,@strPlant NVARCHAR(50)
		,@intPlantId INT
		,@strDestinationPort NVARCHAR(50)

	SELECT @dblCashPrice = NULL
		,@intContractDetailId = NULL
		,@intSampleId = NULL
		,@strPlant = NULL
		,@intPlantId = NULL
		,@strDestinationPort = NULL

	IF ISNULL(@strRowState, '') = ''
		SELECT @strRowState = 'Modified'

	SELECT TOP 1 @ysnSendPriceFeed = ysnSendPriceFeed
	FROM dbo.tblQMCompanyPreference WITH (NOLOCK)

	IF ISNULL(@ysnSendPriceFeed, 0) = 0
	BEGIN
		RETURN
	END

	SELECT @dtmCurrentDate = CONVERT(CHAR, GETDATE(), 101)

	IF ISNULL(@strSource, '') = 'Contract'
	BEGIN
		SELECT @intContractDetailId = @intSourceId

		DELETE
		FROM tblIPPriceFeed
		WHERE intContractDetailId = @intContractDetailId
			AND ISNULL(strFeedStatus, '') = ''
			AND ISNULL(intStatusId, 1) = 1

		SELECT @dblCashPrice = CD.dblCashPrice
		FROM dbo.tblCTContractDetail CD WITH (NOLOCK)
		WHERE CD.intContractDetailId = @intContractDetailId

		IF ISNULL(@dblCashPrice, 0) = 0
		BEGIN
			RETURN
		END

		SELECT TOP 1 @strPlant = CL.strOregonFacilityNumber
		FROM dbo.tblCTContractDetail CD WITH (NOLOCK)
		JOIN dbo.tblCTBook B WITH (NOLOCK) ON B.intBookId = CD.intBookId
			AND CD.intContractDetailId = @intContractDetailId
		JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLocationName = B.strBook

		INSERT INTO tblIPPriceFeed
		(
				intContractHeaderId,	intContractDetailId,		intSampleId,			intCompanyLocationId,
				intReferenceNo,			strPurchGroup,				strChannel,				strIncoTerms,
				strOrigin,				strAuctionCenter,			strSupplier,			strPlant,
				strStorageLocation,		strLoadingPort,				strDestinationPort,		dblCashPrice,
				strCurrency,			dblQuantity,				strContainerType,		strShippingLine,
				dtmPricingDate,			intEntityId,				strRowState
		)
		SELECT CD.intContractHeaderId,	CD.intContractDetailId,		NULL,					CD.intCompanyLocationId,
				NULL,					CL.strOregonFacilityNumber,	MZ.strMarketZoneCode,	FT.strFreightTerm,
				C.strISOCode,			CL.strLocationName,			VE.strVendorAccountNum,	@strPlant,
				CLSL.strSubLocationName,LP.strCity,					DP.strCity,				CD.dblCashPrice,
				CU.strCurrency,			CD.dblNetWeight,			CT.strContainerType,	SL.strName,
				@dtmCurrentDate,		@intEntityId,				@strRowState
		FROM dbo.tblCTContractDetail CD WITH (NOLOCK)
		JOIN dbo.tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
			AND CD.intContractDetailId = @intContractDetailId
		JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = CD.intCompanyLocationId
		JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = CD.intItemId
		JOIN dbo.tblAPVendor VE WITH (NOLOCK) ON VE.intEntityId = CH.intEntityId
		LEFT JOIN dbo.tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = CD.intMarketZoneId
		LEFT JOIN dbo.tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
		LEFT JOIN dbo.tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = I.intOriginId
		LEFT JOIN dbo.tblSMCountry C WITH (NOLOCK) ON C.intCountryID = CA.intCountryID
		LEFT JOIN dbo.tblSMCompanyLocationSubLocation CLSL WITH (NOLOCK) ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
		LEFT JOIN dbo.tblSMCity LP WITH (NOLOCK) ON LP.intCityId = CD.intLoadingPortId
		LEFT JOIN dbo.tblSMCity DP WITH (NOLOCK) ON DP.intCityId = CD.intDestinationPortId
		LEFT JOIN dbo.tblSMCurrency CU WITH (NOLOCK) ON CU.intCurrencyID = CD.intCurrencyId
		LEFT JOIN dbo.tblLGContainerType CT WITH (NOLOCK) ON CT.intContainerTypeId = CD.intContainerTypeId
		LEFT JOIN dbo.tblEMEntity SL WITH (NOLOCK) ON SL.intEntityId = CD.intShippingLineId
		WHERE CD.intContractDetailId = @intContractDetailId
	END
	ELSE IF ISNULL(@strSource, '') = 'Sample'
	BEGIN
		SELECT @intSampleId = @intSourceId

		DELETE
		FROM tblIPPriceFeed
		WHERE intSampleId = @intSampleId
			AND ISNULL(strFeedStatus, '') = ''
			AND ISNULL(intStatusId, 1) = 1

		SELECT @dblCashPrice = S.dblB1Price
		FROM dbo.tblQMSample S WITH (NOLOCK)
		WHERE S.intSampleId = @intSampleId

		IF ISNULL(@dblCashPrice, 0) = 0
		BEGIN
			RETURN
		END

		SELECT TOP 1 @strPlant = CL.strOregonFacilityNumber
			,@intPlantId = CL.intCompanyLocationId
		FROM dbo.tblQMSample S WITH (NOLOCK)
		JOIN dbo.tblCTBook B WITH (NOLOCK) ON B.intBookId = S.intBookId
			AND S.intSampleId = @intSampleId
		JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLocationName = B.strBook
		
		SELECT TOP 1 @strDestinationPort = ISNULL(DP.strCity, '')
		FROM dbo.tblQMSample S WITH (NOLOCK)
		JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = S.intItemId
			AND S.intSampleId = @intSampleId
		JOIN dbo.tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = I.intOriginId
		JOIN dbo.tblSMCompanyLocationSubLocation CLSL WITH (NOLOCK) ON CLSL.intCompanyLocationSubLocationId = S.intDestinationStorageLocationId
		JOIN dbo.tblMFLocationLeadTime LLT WITH (NOLOCK) ON LLT.intOriginId = CA.intCountryID
			AND LLT.intBuyingCenterId = S.intCompanyLocationId
			AND LLT.intReceivingPlantId = @intPlantId
			AND LLT.intChannelId = S.intMarketZoneId
			AND LLT.intPortOfDispatchId = S.intFromLocationCodeId
			AND LLT.strReceivingStorageLocation = CLSL.strSubLocationName
		JOIN dbo.tblSMCity DP WITH (NOLOCK) ON DP.intCityId = LLT.intPortOfArrivalId

		INSERT INTO tblIPPriceFeed
		(
				intContractHeaderId,	intContractDetailId,		intSampleId,			intCompanyLocationId,
				intReferenceNo,			strPurchGroup,				strChannel,				strIncoTerms,
				strOrigin,				strAuctionCenter,			strSupplier,			strPlant,
				strStorageLocation,		strLoadingPort,				strDestinationPort,		dblCashPrice,
				strCurrency,			dblQuantity,				strContainerType,		strShippingLine,
				dtmPricingDate,			intEntityId,				strRowState
		)
		SELECT	NULL,					NULL,						S.intSampleId,			S.intCompanyLocationId,
				NULL,					CL.strOregonFacilityNumber,	MZ.strMarketZoneCode,	'FOB',
				C.strISOCode,			CL.strLocationName,			VE.strVendorAccountNum,	@strPlant,
				CLSL.strSubLocationName,LP.strCity,					@strDestinationPort,	S.dblB1Price,
				CU.strCurrency,			S.dblSampleQty,				'40FT',					'CDFR',
				@dtmCurrentDate,		@intEntityId,				@strRowState
		FROM dbo.tblQMSample S WITH (NOLOCK)
		JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = S.intCompanyLocationId
			AND S.intSampleId = @intSampleId
		JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = S.intItemId
		LEFT JOIN dbo.tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = S.intMarketZoneId
		LEFT JOIN dbo.tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = I.intOriginId
		LEFT JOIN dbo.tblSMCountry C WITH (NOLOCK) ON C.intCountryID = CA.intCountryID
		LEFT JOIN dbo.tblAPVendor VE WITH (NOLOCK) ON VE.intEntityId = S.intEntityId
		LEFT JOIN dbo.tblSMCompanyLocationSubLocation CLSL WITH (NOLOCK) ON CLSL.intCompanyLocationSubLocationId = S.intDestinationStorageLocationId
		LEFT JOIN dbo.tblSMCity LP WITH (NOLOCK) ON LP.intCityId = S.intFromLocationCodeId
		LEFT JOIN dbo.tblSMCurrency CU WITH (NOLOCK) ON CU.intCurrencyID = S.intCurrencyId
		WHERE S.intSampleId = @intSampleId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
