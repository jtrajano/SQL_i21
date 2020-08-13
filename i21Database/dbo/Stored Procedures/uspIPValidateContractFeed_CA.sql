CREATE PROCEDURE uspIPValidateContractFeed_CA (
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
		,@intNumberOfContainers int

	SELECT TOP 1 @intContractDetailId = L.intContractDetailId
	FROM tblIPContractFeedLog L
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = L.intContractHeaderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = L.intContractDetailId and CD.intContractStatusId=1
	WHERE L.strCustomerContract <> CH.strCustomerContract
		OR L.intShipperId <> CD.intShipperId
		OR L.intDestinationCityId <> CD.intDestinationCityId
		OR L.intDestinationPortId <> CD.intDestinationPortId
		OR L.intNumberOfContainers <> CD.intNumberOfContainers

	IF @intContractDetailId IS NOT NULL
	BEGIN
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
			,@intDestinationCityId = intDestinationCityId
			,@intDestinationPortId = intDestinationPortId
			,@intNumberOfContainers=intNumberOfContainers
		FROM tblCTContractDetail WITH (NOLOCK)
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strContractNumber = strContractNumber
			,@strVendorRefNo = strCustomerContract
		FROM tblCTContractHeader WITH (NOLOCK)
		WHERE intContractHeaderId = @intContractHeaderId

		DELETE
		FROM dbo.tblIPContractFeedLog
		WHERE intContractDetailId = @intContractDetailId

		INSERT INTO dbo.tblIPContractFeedLog (
			intContractHeaderId
			,intContractDetailId
			--,intEntityId
			,strCustomerContract
			,intShipperId
			,intDestinationCityId
			,intDestinationPortId
			,intNumberOfContainers
			)
		SELECT @intContractHeaderId
			,@intContractDetailId
			--,@intEntityId
			,@strVendorRefNo
			,@intShipperId
			,@intDestinationCityId
			,@intDestinationPortId
			,@intNumberOfContainers

		SELECT @strInfo1 = @strContractNumber + ' / ' + ISNULL(@strContractSeq, '')

		SELECT @strInfo2 = @strReference

		SELECT @intNoOfRowsAffected = 1
	END
END
