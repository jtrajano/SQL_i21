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

	SELECT TOP 1 @intContractDetailId = L.intContractDetailId
		,@intOldCompanyLocationId = L.intCompanyLocationId
	FROM tblIPContractFeedLog L
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = L.intContractHeaderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = L.intContractDetailId
		AND CD.intContractStatusId = 1
	WHERE IsNULL(L.intCompanyLocationId, 0) <> IsNULL(CD.intCompanyLocationId, 0)

	IF @intContractDetailId IS NOT NULL
	BEGIN
		IF ISNULL(@intOldCompanyLocationId, 0) > 0
		BEGIN
			SELECT @strOldLocationName = strLocationName
			FROM tblSMCompanyLocation
			WHERE intCompanyLocationId = @intOldCompanyLocationId

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
				,'DELETE'
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
				,'IGNORE'
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
			,@intCompanyLocationId = intCompanyLocationId
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
			)
		SELECT @intContractHeaderId
			,@intContractDetailId
			,@strVendorRefNo
			,@intShipperId
			,@intDestinationPortId
			,@intCompanyLocationId
			,@intBookId

		SELECT @strInfo1 = @strContractNumber + ' / ' + ISNULL(@strContractSeq, '')

		SELECT @strInfo2 = @strReference

		SELECT @intNoOfRowsAffected = 1
	END
END
