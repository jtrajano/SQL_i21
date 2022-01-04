CREATE PROCEDURE uspIPValidateERPContractFeed (
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
		,@intDestinationPortId INT
		,@strVendorRefNo NVARCHAR(50)
		,@intCompanyLocationId INT
		,@intBookId INT
		,@intOldCompanyLocationId INT
		,@strOldLocationName NVARCHAR(50)
		,@intOldBookId INT
		,@strOldBook NVARCHAR(100)
		,@intContractFeedLogId INT
		,@intContractFeedId INT
		,@intOrgContractFeedId INT
		,@strSubLocation NVARCHAR(50)
		,@dtmUpdatedAvailabilityDate DATETIME
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
		AND CD.intContractStatusId = 1
	WHERE IsNULL(L.intCompanyLocationId, 0) <> IsNULL(CD.intCompanyLocationId, 0)
		OR IsNULL(L.intHeaderBookId, 0) <> IsNULL(CH.intBookId, 0)

	SELECT @intContractDetailId = NULL
		,@intContractHeaderId = NULL

	SELECT @intContractDetailId = MIN(intContractDetailId)
	FROM @tblCTContractDetail

	IF @intContractDetailId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intContractDetailId IS NOT NULL
	BEGIN
		SELECT @intOldCompanyLocationId = NULL
			,@intOldBookId = NULL
			,@strOldLocationName = NULL
			,@strOldBook = NULL
			,@intContractFeedLogId = NULL
			,@intContractHeaderId = NULL
			,@intContractFeedId = NULL

		SELECT @strContractSeq = NULL
			,@strReference = NULL
			,@intShipperId = NULL
			,@intDestinationPortId = NULL
			,@intCompanyLocationId = NULL
			,@strContractNumber = NULL
			,@strVendorRefNo = NULL
			,@intBookId = NULL
			,@dtmUpdatedAvailabilityDate = NULL

		SELECT @intContractFeedLogId = intContractFeedLogId
			,@intContractHeaderId = intContractHeaderId
			,@intOldCompanyLocationId = intCompanyLocationId
			,@intOldBookId = intHeaderBookId
		FROM tblIPContractFeedLog
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strOldLocationName = strLocationName
		FROM dbo.tblSMCompanyLocation
		WHERE intCompanyLocationId = @intOldCompanyLocationId

		SELECT @strOldBook = strBook
		FROM dbo.tblCTBook
		WHERE intBookId = @intOldBookId

		SELECT TOP 1 @intOrgContractFeedId = intContractFeedId
		FROM dbo.tblCTContractFeed
		WHERE intContractDetailId = @intContractDetailId
		ORDER BY intContractFeedId DESC

		IF ISNULL(@intOldCompanyLocationId, 0) > 0
			OR ISNULL(@intOldBookId, 0) > 0
		BEGIN
			UPDATE tblCTContractFeed
			SET strFeedStatus = 'NOT SEND'
				,intStatusId = 6
			WHERE intContractFeedId = @intOrgContractFeedId

			SELECT @strSubLocation =NULL
			SELECT TOP 1 @strSubLocation = strSubLocation
			FROM dbo.tblCTContractFeed
			WHERE intContractDetailId = @intContractDetailId
			AND intContractFeedId < @intOrgContractFeedId
			ORDER BY intContractFeedId DESC

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
				,@strSubLocation
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
				,'Delete'
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
				,@strOldLocationName
				,strSalesperson
				,strSalespersonExternalERPId
				,strProducer
				,intItemId
				,'SEND'
			FROM vyuCTContractFeed
			WHERE intContractDetailId = @intContractDetailId

			SELECT @intContractFeedId = SCOPE_IDENTITY()

			IF NOT EXISTS (
					SELECT 1
					FROM tblIPThirdPartyContractFeed
					WHERE intContractFeedId = @intContractFeedId
					)
				INSERT INTO tblIPThirdPartyContractFeed (
					intContractFeedId
					,strERPPONumber
					,strRowState
					,strBook
					)
				SELECT @intContractFeedId
					,strERPPONumber
					,'Delete'
					,@strOldBook
				FROM vyuCTContractFeed
				WHERE intContractDetailId = @intContractDetailId
		END

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
			,NULL
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
			,'Added'
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
			,NULL
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
			,'SEND'
		FROM vyuCTContractFeed
		WHERE intContractDetailId = @intContractDetailId

		SELECT TOP 1 @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			,@intContractHeaderId = intContractHeaderId
			,@strReference = strERPPONumber
			,@intShipperId = intShipperId
			,@intDestinationPortId = intDestinationPortId
			,@intCompanyLocationId = intCompanyLocationId
			,@dtmUpdatedAvailabilityDate = dtmUpdatedAvailabilityDate
		FROM tblCTContractDetail WITH (NOLOCK)
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strContractNumber = strContractNumber
			,@strVendorRefNo = strCustomerContract
			,@intBookId = intBookId
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
			,intDestinationPortId
			,intCompanyLocationId
			,intHeaderBookId
			,dtmUpdatedAvailabilityDate
			)
		SELECT @intContractHeaderId
			,@intContractDetailId
			,@strVendorRefNo
			,@intShipperId
			,@intDestinationPortId
			,@intCompanyLocationId
			,@intBookId
			,@dtmUpdatedAvailabilityDate

		SELECT @strInfo1 = @strContractNumber + ' / ' + ISNULL(@strContractSeq, '')

		SELECT @strInfo2 = @strReference

		SELECT @intNoOfRowsAffected = 1

		SELECT @intContractDetailId = MIN(intContractDetailId)
		FROM @tblCTContractDetail
		WHERE intContractDetailId > @intContractDetailId
	END
END
