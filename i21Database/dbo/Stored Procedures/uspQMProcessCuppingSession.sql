CREATE PROCEDURE [dbo].[uspQMProcessCuppingSession]
      @intCuppingSessionId      INT
    , @intEntityUserId          INT
AS

DELETE S
FROM tblQMSample S
INNER JOIN tblQMCuppingSessionDetail CSD ON S.intCuppingSessionDetailId = CSD.intCuppingSessionDetailId
INNER JOIN tblQMCuppingSession CS ON CSD.intCuppingSessionId = CS.intCuppingSessionId
WHERE CS.intCuppingSessionId = @intCuppingSessionId

INSERT INTO tblQMSample (
	  intCompanyId
	, intSampleTypeId
	, strSampleNumber
	, intParentSampleId
	, strSampleRefNo
	, intProductTypeId
	, intProductValueId
	, intSampleStatusId
	, intPreviousSampleStatusId
	, intItemId
	, intItemContractId
	, intContractHeaderId
	, intContractDetailId
	, intShipmentBLContainerId
	, intShipmentBLContainerContractId
	, intShipmentId
	, intShipmentContractQtyId
	, intCountryID
	, ysnIsContractCompleted
	, intLotStatusId
	, intEntityId
	, intShipperEntityId
	, strShipmentNumber
	, strLotNumber
	, strSampleNote
	, dtmSampleReceivedDate
	, dtmTestedOn
	, intTestedById
	, dblSampleQty
	, intSampleUOMId
	, dblRepresentingQty
	, intRepresentingUOMId
	, strRefNo
	, dtmTestingStartDate
	, dtmTestingEndDate
	, dtmSamplingEndDate
	, strSamplingMethod
	, strContainerNumber
	, strMarks
	, intCompanyLocationSubLocationId
	, strCountry
	, intItemBundleId
	, intLoadContainerId
	, intLoadDetailContainerLinkId
	, intLoadId
	, intLoadDetailId
	, dtmBusinessDate
	, intShiftId
	, intLocationId
	, intInventoryReceiptId
	, intInventoryShipmentId
	, intWorkOrderId
	, strComment
	, ysnAdjustInventoryQtyBySampleQty
	, intStorageLocationId
	, intBookId
	, intSubBookId
	, strChildLotNumber
	, strCourier
	, strCourierRef
	, intForwardingAgentId
	, strForwardingAgentRef
	, strSentBy
	, intSentById
	, intSampleRefId
	, ysnParent
	, ysnIgnoreContract
	, ysnImpactPricing
	, dtmRequestedDate
	, dtmSampleSentDate
	, intSamplingCriteriaId
	, strSendSampleTo
	, strRepresentLotNumber
	, intRelatedSampleId
	, intTypeId
	, intCuppingSessionDetailId
	, intCreatedUserId
	, intLastModifiedUserId
)
SELECT intCompanyId						= S.intCompanyId
	, intSampleTypeId					= S.intSampleTypeId
	, strSampleNumber					= CS.strCuppingSessionNumber + '/' + S.strSampleNumber
	, intParentSampleId					= S.intParentSampleId
	, strSampleRefNo					= S.strSampleRefNo
	, intProductTypeId					= S.intProductTypeId
	, intProductValueId					= S.intProductValueId
	, intSampleStatusId					= S.intSampleStatusId
	, intPreviousSampleStatusId			= S.intPreviousSampleStatusId
	, intItemId							= S.intItemId
	, intItemContractId					= S.intItemContractId
	, intContractHeaderId				= S.intContractHeaderId
	, intContractDetailId				= S.intContractDetailId
	, intShipmentBLContainerId			= S.intShipmentBLContainerId
	, intShipmentBLContainerContractId	= S.intShipmentBLContainerContractId
	, intShipmentId						= S.intShipmentId
	, intShipmentContractQtyId			= S.intShipmentContractQtyId
	, intCountryID						= S.intCountryID
	, ysnIsContractCompleted			= S.ysnIsContractCompleted
	, intLotStatusId					= S.intLotStatusId
	, intEntityId						= S.intEntityId
	, intShipperEntityId				= S.intShipperEntityId
	, strShipmentNumber					= S.strShipmentNumber
	, strLotNumber						= S.strLotNumber
	, strSampleNote						= S.strSampleNote
	, dtmSampleReceivedDate				= S.dtmSampleReceivedDate
	, dtmTestedOn						= S.dtmTestedOn
	, intTestedById						= S.intTestedById
	, dblSampleQty						= S.dblSampleQty
	, intSampleUOMId					= S.intSampleUOMId
	, dblRepresentingQty				= S.dblRepresentingQty
	, intRepresentingUOMId				= S.intRepresentingUOMId
	, strRefNo							= S.strRefNo
	, dtmTestingStartDate				= S.dtmTestingStartDate
	, dtmTestingEndDate					= S.dtmTestingEndDate
	, dtmSamplingEndDate				= S.dtmSamplingEndDate
	, strSamplingMethod					= S.strSamplingMethod
	, strContainerNumber				= S.strContainerNumber
	, strMarks							= S.strMarks
	, intCompanyLocationSubLocationId	= S.intCompanyLocationSubLocationId
	, strCountry						= S.strCountry
	, intItemBundleId					= S.intItemBundleId
	, intLoadContainerId				= S.intLoadContainerId
	, intLoadDetailContainerLinkId		= S.intLoadDetailContainerLinkId
	, intLoadId							= S.intLoadId
	, intLoadDetailId					= S.intLoadDetailId
	, dtmBusinessDate					= S.dtmBusinessDate
	, intShiftId						= S.intShiftId
	, intLocationId						= S.intLocationId
	, intInventoryReceiptId				= S.intInventoryReceiptId
	, intInventoryShipmentId			= S.intInventoryShipmentId
	, intWorkOrderId					= S.intWorkOrderId
	, strComment						= S.strComment
	, ysnAdjustInventoryQtyBySampleQty	= S.ysnAdjustInventoryQtyBySampleQty
	, intStorageLocationId				= S.intStorageLocationId
	, intBookId							= S.intBookId
	, intSubBookId						= S.intSubBookId
	, strChildLotNumber					= S.strChildLotNumber
	, strCourier						= S.strCourier
	, strCourierRef						= S.strCourierRef
	, intForwardingAgentId				= S.intForwardingAgentId
	, strForwardingAgentRef				= S.strForwardingAgentRef
	, strSentBy							= S.strSentBy
	, intSentById						= S.intSentById
	, intSampleRefId					= S.intSampleRefId
	, ysnParent							= S.ysnParent
	, ysnIgnoreContract					= S.ysnIgnoreContract
	, ysnImpactPricing					= S.ysnImpactPricing
	, dtmRequestedDate					= S.dtmRequestedDate
	, dtmSampleSentDate					= S.dtmSampleSentDate
	, intSamplingCriteriaId				= S.intSamplingCriteriaId
	, strSendSampleTo					= S.strSendSampleTo
	, strRepresentLotNumber				= S.strRepresentLotNumber
	, intRelatedSampleId				= S.intSampleId
	, intTypeId							= 2
	, intCuppingSessionDetailId			= CSD.intCuppingSessionDetailId
	, intCreatedUserId					= @intEntityUserId
	, intLastModifiedUserId				= @intEntityUserId
FROM tblQMCuppingSession CS 
INNER JOIN tblQMCuppingSessionDetail CSD ON CS.intCuppingSessionId = CSD.intCuppingSessionId
INNER JOIN tblQMSample S ON CSD.intSampleId = S.intSampleId
WHERE CS.intCuppingSessionId = @intCuppingSessionId

INSERT INTO tblQMSampleDetail (
	  intSampleId
	, intAttributeId
	, strAttributeValue
	, intListItemId
	, ysnIsMandatory
	, intSampleDetailRefId
	, intCreatedUserId
	, intLastModifiedUserId
)
SELECT intSampleId				= NEWSAMPLE.intSampleId
	, intAttributeId			= SD.intAttributeId
	, strAttributeValue			= SD.strAttributeValue
	, intListItemId				= SD.intListItemId
	, ysnIsMandatory			= SD.ysnIsMandatory
	, intSampleDetailRefId		= SD.intSampleDetailRefId
	, intCreatedUserId			= @intEntityUserId
	, intLastModifiedUserId		= @intEntityUserId
FROM tblQMCuppingSession CS 
INNER JOIN tblQMCuppingSessionDetail CSD ON CS.intCuppingSessionId = CSD.intCuppingSessionId
INNER JOIN tblQMSample S ON CSD.intSampleId = S.intSampleId
INNER JOIN tblQMSampleDetail SD ON S.intSampleId = SD.intSampleId
INNER JOIN tblQMSample NEWSAMPLE ON S.intSampleId = NEWSAMPLE.intRelatedSampleId
WHERE CS.intCuppingSessionId = @intCuppingSessionId

