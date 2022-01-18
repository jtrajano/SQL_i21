CREATE PROCEDURE uspIPValidateERPOtherFieldsContractFeed (
	@strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
	)
AS
BEGIN
	DECLARE @intContractDetailId INT
		,@strContractNumber NVARCHAR(50)
		,@strContractSeq NVARCHAR(50)
		,@intContractHeaderId INT
		,@strReference NVARCHAR(50)
		,@intShipperId INT
		,@intDestinationCityId INT
		,@intDestinationPortId INT
		,@strVendorRefNo NVARCHAR(50)
		,@intCompanyLocationId INT
		,@intBookId INT
		,@intContractStatusId INT
		,@dtmUpdatedAvailabilityDate DATETIME
		,@intSubBookId INT
		,@intContractFeedId INT
	--,@intOrgContractFeedId INT
	DECLARE @tblCTContractDetail TABLE (
		intContractDetailId INT
		,intContractHeaderId INT
		)

	DELETE
	FROM @tblCTContractDetail

	INSERT INTO @tblCTContractDetail (
		intContractDetailId
		,intContractHeaderId
		)
	SELECT DISTINCT L.intContractDetailId
		,L.intContractHeaderId
	FROM tblIPContractFeedLog L
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = L.intContractHeaderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = L.intContractDetailId
		AND CH.intContractTypeId = 1
		AND CD.intContractStatusId <> 1
	WHERE ISNULL(L.intContractStatusId, 0) <> ISNULL(CD.intContractStatusId, 0)

	INSERT INTO @tblCTContractDetail (
		intContractDetailId
		,intContractHeaderId
		)
	SELECT DISTINCT L.intContractDetailId
		,L.intContractHeaderId
	FROM tblIPContractFeedLog L
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = L.intContractHeaderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = L.intContractDetailId
		AND CD.intContractStatusId = 1
	WHERE ISNULL(L.strCustomerContract, '') <> ISNULL(CH.strCustomerContract, '')
		OR ISNULL(L.dtmUpdatedAvailabilityDate, 0) <> ISNULL(CD.dtmUpdatedAvailabilityDate, 0)
		OR ISNULL(L.intSubBookId, 0) <> ISNULL(CH.intSubBookId, 0)

	SELECT @intContractDetailId = NULL

	SELECT @intContractDetailId = MIN(intContractDetailId)
	FROM @tblCTContractDetail

	IF @intContractDetailId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intContractDetailId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@intContractFeedId = NULL

		SELECT @strContractSeq = NULL
			,@strReference = NULL
			,@intShipperId = NULL
			,@intDestinationCityId = NULL
			,@intDestinationPortId = NULL
			,@intCompanyLocationId = NULL
			,@strContractNumber = NULL
			,@strVendorRefNo = NULL
			,@intBookId = NULL
			,@intContractStatusId = NULL
			,@dtmUpdatedAvailabilityDate = NULL
			,@intSubBookId = NULL

		SELECT @intContractHeaderId = intContractHeaderId
		FROM tblIPContractFeedLog
		WHERE intContractDetailId = @intContractDetailId

		--SELECT TOP 1 @intOrgContractFeedId = intContractFeedId
		--FROM dbo.tblCTContractFeed
		--WHERE intContractDetailId = @intContractDetailId
		--ORDER BY intContractFeedId DESC
		INSERT INTO tblCTContractFeed (
			intContractHeaderId
			,intContractDetailId
			,strCommodityCode
			,strCommodityDesc
			,strContractBasis
			,strContractBasisDesc
			,strSubLocation
			,strCreatedBy
			,strCreatedByNo
			,strEntityNo
			,strTerm
			,strPurchasingGroup
			,strContractNumber
			,strERPPONumber
			,intContractSeq
			,strItemNo
			,strStorageLocation
			,dblQuantity
			,dblCashPrice
			,strQuantityUOM
			,dtmPlannedAvailabilityDate
			,dblBasis
			,strCurrency
			,dblUnitCashPrice
			,strPriceUOM
			,strRowState
			,dtmContractDate
			,dtmStartDate
			,dtmEndDate
			,dtmFeedCreated
			,strSubmittedBy
			,strSubmittedByNo
			,strOrigin
			,dblNetWeight
			,strNetWeightUOM
			,strVendorAccountNum
			,strTermCode
			,strContractItemNo
			,strContractItemName
			,strERPItemNumber
			,strERPBatchNumber
			,strLoadingPoint
			,strPackingDescription
			,ysnMaxPrice
			,ysnSubstituteItem
			,strLocationName
			,strSalesperson
			,strSalespersonExternalERPId
			,strProducer
			,intItemId
			,strFeedStatus
			)
		SELECT intContractHeaderId
			,intContractDetailId
			,strCommodityCode
			,strCommodityDesc
			,strContractBasis
			,strContractBasisDesc
			,strSubLocation
			,strCreatedBy
			,strCreatedByNo
			,strEntityNo
			,strTerm
			,strPurchasingGroup
			,strContractNumber
			,strERPPONumber
			,intContractSeq
			,strItemNo
			,strStorageLocation
			,dblQuantity
			,dblCashPrice
			,strQuantityUOM
			,dtmPlannedAvailabilityDate
			,dblBasis
			,strCurrency
			,dblUnitCashPrice
			,strPriceUOM
			,'Modified'
			,dtmContractDate
			,dtmStartDate
			,dtmEndDate
			,GETDATE()
			,strSubmittedBy
			,strSubmittedByNo
			,strOrigin
			,dblNetWeight
			,strNetWeightUOM
			,strVendorAccountNum
			,strTermCode
			,strContractItemNo
			,strContractItemName
			,strERPItemNumber
			,strERPBatchNumber
			,strLoadingPoint
			,strPackingDescription
			,ysnMaxPrice
			,ysnSubstituteItem
			,strLocationName
			,strSalesperson
			,strSalespersonExternalERPId
			,strProducer
			,intItemId
			,'IGNORE'
		FROM vyuCTContractFeed
		WHERE intContractDetailId = @intContractDetailId

		SELECT TOP 1 @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			,@intContractHeaderId = intContractHeaderId
			,@strReference = strERPPONumber
			,@intShipperId = intShipperId
			,@intDestinationPortId = intDestinationPortId
			,@intDestinationCityId = intDestinationCityId
			,@intCompanyLocationId = intCompanyLocationId
			,@intContractStatusId = intContractStatusId
			,@dtmUpdatedAvailabilityDate = dtmUpdatedAvailabilityDate
		FROM tblCTContractDetail WITH (NOLOCK)
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strContractNumber = strContractNumber
			,@strVendorRefNo = strCustomerContract
			,@intBookId = intBookId
			,@intSubBookId = intSubBookId
		FROM tblCTContractHeader WITH (NOLOCK)
		WHERE intContractHeaderId = @intContractHeaderId

		DELETE
		FROM dbo.tblIPContractFeedLog
		WHERE intContractDetailId = @intContractDetailId

		INSERT INTO dbo.tblIPContractFeedLog (
			intContractHeaderId
			,intContractDetailId
			,strCustomerContract
			,intShipperId
			,intDestinationCityId
			,intDestinationPortId
			,intCompanyLocationId
			,intHeaderBookId
			,intContractStatusId
			,dtmUpdatedAvailabilityDate
			,intSubBookId
			)
		SELECT @intContractHeaderId
			,@intContractDetailId
			,@strVendorRefNo
			,@intShipperId
			,@intDestinationCityId
			,@intDestinationPortId
			,@intCompanyLocationId
			,@intBookId
			,@intContractStatusId
			,@dtmUpdatedAvailabilityDate
			,@intSubBookId

		SELECT @strInfo1 = @strContractNumber + ' / ' + ISNULL(@strContractSeq, '')

		SELECT @strInfo2 = @strReference

		SELECT @intNoOfRowsAffected = 1

		SELECT @intContractDetailId = MIN(intContractDetailId)
		FROM @tblCTContractDetail
		WHERE intContractDetailId > @intContractDetailId
	END
END
