CREATE PROCEDURE [dbo].[uspQMCuppingSessionUpdateParentSample]
	 @intCuppingSampleId AS INT,
	 @intUserEntityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION
BEGIN TRY

	DECLARE
		@strLogJson NVARCHAR(MAX)
		,@strMainChildrenLog NVARCHAR(MAX)
		,@strTestResultChildrenLog NVARCHAR(MAX)
		,@intParentSampleId INT

	-- Generate Audit Log JSON string for the header changes
	SELECT
		@intParentSampleId = A.intSampleId
		,@strMainChildrenLog =

		CASE WHEN A.intSampleTypeId = B.intSampleTypeId OR (A.intSampleTypeId IS NULL AND B.intSampleTypeId IS NULL) THEN ''
			ELSE '{"change": "intSampleTypeId", "from": "'+CAST(ISNULL(A.intSampleTypeId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intSampleTypeId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strSampleRefNo, '') = ISNULL(B.strSampleRefNo, '') OR (A.strSampleRefNo IS NULL AND B.strSampleRefNo IS NULL) THEN ''
			ELSE '{"change": "strSampleRefNo", "from": "'+CAST(ISNULL(A.strSampleRefNo,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSampleRefNo,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sample Ref No"},' END +
			
		CASE WHEN A.intProductTypeId = B.intProductTypeId OR (A.intProductTypeId IS NULL AND B.intProductTypeId IS NULL) THEN ''
			ELSE '{"change": "intProductTypeId", "from": "'+CAST(ISNULL(A.intProductTypeId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intProductTypeId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intProductValueId = B.intProductValueId OR (A.intProductValueId IS NULL AND B.intProductValueId IS NULL) THEN ''
			ELSE '{"change": "intProductValueId", "from": "'+CAST(ISNULL(A.intProductValueId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intProductValueId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": tue},' END +
			
		CASE WHEN A.intItemId = B.intItemId OR (A.intItemId IS NULL AND B.intItemId IS NULL) THEN ''
			ELSE '{"change": "intItemId", "from": "'+CAST(ISNULL(A.intItemId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intItemId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intItemContractId = B.intItemContractId OR (A.intItemContractId IS NULL AND B.intItemContractId IS NULL) THEN ''
			ELSE '{"change": "intItemContractId", "from": "'+CAST(ISNULL(A.intItemContractId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intItemContractId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intContractHeaderId = B.intContractHeaderId OR (A.intContractHeaderId IS NULL AND B.intContractHeaderId IS NULL) THEN ''
			ELSE '{"change": "intContractHeaderId", "from": "'+CAST(ISNULL(A.intContractHeaderId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intContractHeaderId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intContractDetailId = B.intContractDetailId OR (A.intContractDetailId IS NULL AND B.intContractDetailId IS NULL) THEN ''
			ELSE '{"change": "intContractDetailId", "from": "'+CAST(ISNULL(A.intContractDetailId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intContractDetailId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLoadContainerId = B.intLoadContainerId OR (A.intLoadContainerId IS NULL AND B.intLoadContainerId IS NULL) THEN ''
			ELSE '{"change": "intLoadContainerId", "from": "'+CAST(ISNULL(A.intLoadContainerId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLoadContainerId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLoadDetailContainerLinkId = B.intLoadDetailContainerLinkId OR (A.intLoadDetailContainerLinkId IS NULL AND B.intLoadDetailContainerLinkId IS NULL) THEN ''
			ELSE '{"change": "intLoadDetailContainerLinkId", "from": "'+CAST(ISNULL(A.intLoadDetailContainerLinkId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLoadDetailContainerLinkId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLoadId = B.intLoadId OR (A.intLoadId IS NULL AND B.intLoadId IS NULL) THEN ''
			ELSE '{"change": "intLoadId", "from": "'+CAST(ISNULL(A.intLoadId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLoadId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLoadDetailId = B.intLoadDetailId OR (A.intLoadDetailId IS NULL AND B.intLoadDetailId IS NULL) THEN ''
			ELSE '{"change": "intLoadDetailId", "from": "'+CAST(ISNULL(A.intLoadDetailId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLoadDetailId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intCountryID = B.intCountryID OR (A.intCountryID IS NULL AND B.intCountryID IS NULL) THEN ''
			ELSE '{"change": "intCountryID", "from": "'+CAST(ISNULL(A.intCountryID,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intCountryID,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.ysnIsContractCompleted = B.ysnIsContractCompleted OR (A.ysnIsContractCompleted IS NULL AND B.ysnIsContractCompleted IS NULL) THEN ''
			ELSE '{"change": "ysnIsContractCompleted", "from": "'+CASE WHEN A.ysnIsContractCompleted = 1 THEN 'true' ELSE 'false' END+'", "to": "'+CASE WHEN B.ysnIsContractCompleted = 1 THEN 'true' ELSE 'false' END+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLotStatusId = B.intLotStatusId OR (A.intLotStatusId IS NULL AND B.intLotStatusId IS NULL) THEN ''
			ELSE '{"change": "intLotStatusId", "from": "'+CAST(ISNULL(A.intLotStatusId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLotStatusId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intEntityId = B.intEntityId OR (A.intEntityId IS NULL AND B.intEntityId IS NULL) THEN ''
			ELSE '{"change": "intEntityId", "from": "'+CAST(ISNULL(A.intEntityId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intEntityId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intShipperEntityId = B.intShipperEntityId OR (A.intShipperEntityId IS NULL AND B.intShipperEntityId IS NULL) THEN ''
			ELSE '{"change": "intShipperEntityId", "from": "'+CAST(ISNULL(A.intShipperEntityId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intShipperEntityId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strShipmentNumber, '') = ISNULL(B.strShipmentNumber, '') OR (A.strShipmentNumber IS NULL AND B.strShipmentNumber IS NULL) THEN ''
			ELSE '{"change": "strShipmentNumber", "from": "'+CAST(ISNULL(A.strShipmentNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strShipmentNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Inv Shipment No"},' END +
			
		CASE WHEN ISNULL(A.strLotNumber, '') = ISNULL(B.strLotNumber, '') OR (A.strLotNumber IS NULL AND B.strLotNumber IS NULL) THEN ''
			ELSE '{"change": "strLotNumber", "from": "'+CAST(ISNULL(A.strLotNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strLotNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Lot No"},' END +
			
		CASE WHEN ISNULL(A.strSampleNote, '') = ISNULL(B.strSampleNote, '') OR (A.strSampleNote IS NULL AND B.strSampleNote IS NULL) THEN ''
			ELSE '{"change": "strSampleNote", "from": "'+CAST(ISNULL(A.strSampleNote,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSampleNote,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sample Note"},' END +
			
		CASE WHEN A.dtmSampleReceivedDate = B.dtmSampleReceivedDate OR (A.dtmSampleReceivedDate IS NULL AND B.dtmSampleReceivedDate IS NULL) THEN ''
			ELSE '{"change": "dtmSampleReceivedDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmSampleReceivedDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmSampleReceivedDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Received Date"},' END +
			
		CASE WHEN A.dtmTestedOn = B.dtmTestedOn OR (A.dtmTestedOn IS NULL AND B.dtmTestedOn IS NULL) THEN ''
			ELSE '{"change": "dtmTestedOn", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmTestedOn, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmTestedOn, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intTestedById = B.intTestedById OR (A.intTestedById IS NULL AND B.intTestedById IS NULL) THEN ''
			ELSE '{"change": "intTestedById", "from": "'+CAST(ISNULL(A.intTestedById,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intTestedById,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.dblSampleQty = B.dblSampleQty OR (A.dblSampleQty IS NULL AND B.dblSampleQty IS NULL) THEN ''
			ELSE '{"change": "dblSampleQty", "from": "'+CAST(ISNULL(A.dblSampleQty,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.dblSampleQty,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sample Qty"},' END +
			
		CASE WHEN A.intSampleUOMId = B.intSampleUOMId OR (A.intSampleUOMId IS NULL AND B.intSampleUOMId IS NULL) THEN ''
			ELSE '{"change": "intSampleUOMId", "from": "'+CAST(ISNULL(A.intSampleUOMId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intSampleUOMId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.dblRepresentingQty = B.dblRepresentingQty OR (A.dblRepresentingQty IS NULL AND B.dblRepresentingQty IS NULL) THEN ''
			ELSE '{"change": "dblRepresentingQty", "from": "'+CAST(ISNULL(A.dblRepresentingQty,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.dblRepresentingQty,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Representing Qty"},' END +
			
		CASE WHEN A.intRepresentingUOMId = B.intRepresentingUOMId OR (A.intRepresentingUOMId IS NULL AND B.intRepresentingUOMId IS NULL) THEN ''
			ELSE '{"change": "intRepresentingUOMId", "from": "'+CAST(ISNULL(A.intRepresentingUOMId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intRepresentingUOMId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strRefNo, '') = ISNULL(B.strRefNo, '') OR (A.strRefNo IS NULL AND B.strRefNo IS NULL) THEN ''
			ELSE '{"change": "strRefNo", "from": "'+CAST(ISNULL(A.strRefNo,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strRefNo,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Reference No"},' END +
			
		CASE WHEN A.dtmTestingStartDate = B.dtmTestingStartDate OR (A.dtmTestingStartDate IS NULL AND B.dtmTestingStartDate IS NULL) THEN ''
			ELSE '{"change": "dtmTestingStartDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmTestingStartDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmTestingStartDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Testing Start Date"},' END +
			
		CASE WHEN A.dtmTestingEndDate = B.dtmTestingEndDate OR (A.dtmTestingEndDate IS NULL AND B.dtmTestingEndDate IS NULL) THEN ''
			ELSE '{"change": "dtmTestingEndDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmTestingEndDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmTestingEndDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Testing End Date"},' END +
			
		CASE WHEN A.dtmSamplingEndDate = B.dtmSamplingEndDate OR (A.dtmSamplingEndDate IS NULL AND B.dtmSamplingEndDate IS NULL) THEN ''
			ELSE '{"change": "dtmSamplingEndDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmSamplingEndDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmSamplingEndDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sampling End Date"},' END +
			
		CASE WHEN A.dtmRequestedDate = B.dtmRequestedDate OR (A.dtmRequestedDate IS NULL AND B.dtmRequestedDate IS NULL) THEN ''
			ELSE '{"change": "dtmRequestedDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmRequestedDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmRequestedDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Requested Date"},' END +
			
		CASE WHEN A.dtmSampleSentDate = B.dtmSampleSentDate OR (A.dtmSampleSentDate IS NULL AND B.dtmSampleSentDate IS NULL) THEN ''
			ELSE '{"change": "dtmSampleSentDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmSampleSentDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmSampleSentDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sample Sent Date"},' END +
			
		CASE WHEN ISNULL(A.strSamplingMethod, '') = ISNULL(B.strSamplingMethod, '') OR (A.strSamplingMethod IS NULL AND B.strSamplingMethod IS NULL) THEN ''
			ELSE '{"change": "strSamplingMethod", "from": "'+CAST(ISNULL(A.strSamplingMethod,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSamplingMethod,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sampling Method"},' END +
			
		CASE WHEN ISNULL(A.strContainerNumber, '') = ISNULL(B.strContainerNumber, '') OR (A.strContainerNumber IS NULL AND B.strContainerNumber IS NULL) THEN ''
			ELSE '{"change": "strContainerNumber", "from": "'+CAST(ISNULL(A.strContainerNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strContainerNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Container Number"},' END +
			
		CASE WHEN ISNULL(A.strMarks, '') = ISNULL(B.strMarks, '') OR (A.strMarks IS NULL AND B.strMarks IS NULL) THEN ''
			ELSE '{"change": "strMarks", "from": "'+CAST(ISNULL(A.strMarks,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strMarks,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Marks"},' END +
			
		CASE WHEN A.intCompanyLocationSubLocationId = B.intCompanyLocationSubLocationId OR (A.intCompanyLocationSubLocationId IS NULL AND B.intCompanyLocationSubLocationId IS NULL) THEN ''
			ELSE '{"change": "intCompanyLocationSubLocationId", "from": "'+CAST(ISNULL(A.intCompanyLocationSubLocationId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intCompanyLocationSubLocationId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strCountry, '') = ISNULL(B.strCountry, '') OR (A.strCountry IS NULL AND B.strCountry IS NULL) THEN ''
			ELSE '{"change": "strCountry", "from": "'+CAST(ISNULL(A.strCountry,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strCountry,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Origin"},' END +
			
		CASE WHEN A.intItemBundleId = B.intItemBundleId OR (A.intItemBundleId IS NULL AND B.intItemBundleId IS NULL) THEN ''
			ELSE '{"change": "intItemBundleId", "from": "'+CAST(ISNULL(A.intItemBundleId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intItemBundleId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.dtmBusinessDate = B.dtmBusinessDate OR (A.dtmBusinessDate IS NULL AND B.dtmBusinessDate IS NULL) THEN ''
			ELSE '{"change": "dtmBusinessDate", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmBusinessDate, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmBusinessDate, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intShiftId = B.intShiftId OR (A.intShiftId IS NULL AND B.intShiftId IS NULL) THEN ''
			ELSE '{"change": "intShiftId", "from": "'+CAST(ISNULL(A.intShiftId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intShiftId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLocationId = B.intLocationId OR (A.intLocationId IS NULL AND B.intLocationId IS NULL) THEN ''
			ELSE '{"change": "intLocationId", "from": "'+CAST(ISNULL(A.intLocationId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLocationId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intInventoryReceiptId = B.intInventoryReceiptId OR (A.intInventoryReceiptId IS NULL AND B.intInventoryReceiptId IS NULL) THEN ''
			ELSE '{"change": "intInventoryReceiptId", "from": "'+CAST(ISNULL(A.intInventoryReceiptId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intInventoryReceiptId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intInventoryShipmentId = B.intInventoryShipmentId OR (A.intInventoryShipmentId IS NULL AND B.intInventoryShipmentId IS NULL) THEN ''
			ELSE '{"change": "intInventoryShipmentId", "from": "'+CAST(ISNULL(A.intInventoryShipmentId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intInventoryShipmentId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intWorkOrderId = B.intWorkOrderId OR (A.intWorkOrderId IS NULL AND B.intWorkOrderId IS NULL) THEN ''
			ELSE '{"change": "intWorkOrderId", "from": "'+CAST(ISNULL(A.intWorkOrderId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intWorkOrderId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strComment, '') = ISNULL(B.strComment, '') OR (A.strComment IS NULL AND B.strComment IS NULL) THEN ''
			ELSE '{"change": "strComment", "from": "'+CAST(ISNULL(A.strComment,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strComment,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Comments"},' END +
			
		CASE WHEN A.intParentSampleId = B.intParentSampleId OR (A.intParentSampleId IS NULL AND B.intParentSampleId IS NULL) THEN ''
			ELSE '{"change": "intParentSampleId", "from": "'+CAST(ISNULL(A.intParentSampleId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intParentSampleId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.ysnAdjustInventoryQtyBySampleQty = B.ysnAdjustInventoryQtyBySampleQty OR (A.ysnAdjustInventoryQtyBySampleQty IS NULL AND B.ysnAdjustInventoryQtyBySampleQty IS NULL) THEN ''
			ELSE '{"change": "ysnAdjustInventoryQtyBySampleQty", "from": "'+CAST(ISNULL(A.ysnAdjustInventoryQtyBySampleQty,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.ysnAdjustInventoryQtyBySampleQty,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +

		CASE WHEN A.ysnIsContractCompleted = B.ysnIsContractCompleted OR (A.ysnIsContractCompleted IS NULL AND B.ysnIsContractCompleted IS NULL) THEN ''
			ELSE '{"change": "ysnIsContractCompleted", "from": "'+CAST(ISNULL(A.ysnIsContractCompleted,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.ysnIsContractCompleted,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intStorageLocationId = B.intStorageLocationId OR (A.intStorageLocationId IS NULL AND B.intStorageLocationId IS NULL) THEN ''
			ELSE '{"change": "intStorageLocationId", "from": "'+CAST(ISNULL(A.intStorageLocationId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intStorageLocationId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intBookId = B.intBookId OR (A.intBookId IS NULL AND B.intBookId IS NULL) THEN ''
			ELSE '{"change": "intBookId", "from": "'+CAST(ISNULL(A.intBookId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intBookId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intSubBookId = B.intSubBookId OR (A.intSubBookId IS NULL AND B.intSubBookId IS NULL) THEN ''
			ELSE '{"change": "intSubBookId", "from": "'+CAST(ISNULL(A.intSubBookId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intSubBookId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strChildLotNumber, '') = ISNULL(B.strChildLotNumber, '') OR (A.strChildLotNumber IS NULL AND B.strChildLotNumber IS NULL) THEN ''
			ELSE '{"change": "strChildLotNumber", "from": "'+CAST(ISNULL(A.strChildLotNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strChildLotNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Lot ID"},' END +
			
		CASE WHEN ISNULL(A.strCourier, '') = ISNULL(B.strCourier, '') OR (A.strCourier IS NULL AND B.strCourier IS NULL) THEN ''
			ELSE '{"change": "strCourier", "from": "'+CAST(ISNULL(A.strCourier,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strCourier,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Courier"},' END +
			
		CASE WHEN ISNULL(A.strCourierRef, '') = ISNULL(B.strCourierRef, '') OR (A.strCourierRef IS NULL AND B.strCourierRef IS NULL) THEN ''
			ELSE '{"change": "strCourierRef", "from": "'+CAST(ISNULL(A.strCourierRef,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strCourierRef,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Courier Ref"},' END +
			
		CASE WHEN A.intForwardingAgentId = B.intForwardingAgentId OR (A.intForwardingAgentId IS NULL AND B.intForwardingAgentId IS NULL) THEN ''
			ELSE '{"change": "intForwardingAgentId", "from": "'+CAST(ISNULL(A.intForwardingAgentId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intForwardingAgentId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strForwardingAgentRef, '') = ISNULL(B.strForwardingAgentRef, '') OR (A.strForwardingAgentRef IS NULL AND B.strForwardingAgentRef IS NULL) THEN ''
			ELSE '{"change": "strForwardingAgentRef", "from": "'+CAST(ISNULL(A.strForwardingAgentRef,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strForwardingAgentRef,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Fwd Agent Ref"},' END +
			
		CASE WHEN ISNULL(A.strSentBy, '') = ISNULL(B.strSentBy, '') OR (A.strSentBy IS NULL AND B.strSentBy IS NULL) THEN ''
			ELSE '{"change": "strSentBy", "from": "'+CAST(ISNULL(A.strSentBy,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSentBy,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sent By"},' END +
			
		CASE WHEN A.intSentById = B.intSentById OR (A.intSentById IS NULL AND B.intSentById IS NULL) THEN ''
			ELSE '{"change": "intSentById", "from": "'+CAST(ISNULL(A.intSentById,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intSentById,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.ysnImpactPricing = B.ysnImpactPricing OR (A.ysnImpactPricing IS NULL AND B.ysnImpactPricing IS NULL) THEN ''
			ELSE '{"change": "ysnImpactPricing", "from": "'+CAST(ISNULL(A.ysnImpactPricing,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.ysnImpactPricing,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Impact Pricing"},' END +
			
		CASE WHEN A.intCreatedUserId = B.intCreatedUserId OR (A.intCreatedUserId IS NULL AND B.intCreatedUserId IS NULL) THEN ''
			ELSE '{"change": "intCreatedUserId", "from": "'+CAST(ISNULL(A.intCreatedUserId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intCreatedUserId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		-- CASE WHEN A.dtmCreated = B.dtmCreated OR (A.dtmCreated IS NULL AND B.dtmCreated IS NULL) THEN ''
		--     ELSE '{"change": "dtmCreated", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmCreated, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmCreated, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Created"},' END +
			
		CASE WHEN A.intLastModifiedUserId = B.intLastModifiedUserId OR (A.intLastModifiedUserId IS NULL AND B.intLastModifiedUserId IS NULL) THEN ''
			ELSE '{"change": "intLastModifiedUserId", "from": "'+CAST(ISNULL(A.intLastModifiedUserId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLastModifiedUserId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		-- CASE WHEN A.dtmLastModified = B.dtmLastModified OR (A.dtmLastModified IS NULL AND B.dtmLastModified IS NULL) THEN ''
		--     ELSE '{"change": "dtmLastModified", "from": "'+ISNULL(CONVERT(NVARCHAR(MAX), A.dtmLastModified, 126),'')+'", "to": "'+ISNULL(CONVERT(NVARCHAR(MAX), B.dtmLastModified, 126),'')+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Last Modified"},' END +
			
		CASE WHEN A.dblHeaderQuantity = B.dblHeaderQuantity OR (A.dblHeaderQuantity IS NULL AND B.dblHeaderQuantity IS NULL) THEN ''
			ELSE '{"change": "dblHeaderQuantity", "from": "'+CAST(ISNULL(A.dblHeaderQuantity,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.dblHeaderQuantity,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strHeaderUnitMeasure, '') = ISNULL(B.strHeaderUnitMeasure, '') OR (A.strHeaderUnitMeasure IS NULL AND B.strHeaderUnitMeasure IS NULL) THEN ''
			ELSE '{"change": "strHeaderUnitMeasure", "from": "'+CAST(ISNULL(A.strHeaderUnitMeasure,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strHeaderUnitMeasure,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intLinkContractHeaderId = B.intLinkContractHeaderId OR (A.intLinkContractHeaderId IS NULL AND B.intLinkContractHeaderId IS NULL) THEN ''
			ELSE '{"change": "intLinkContractHeaderId", "from": "'+CAST(ISNULL(A.intLinkContractHeaderId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intLinkContractHeaderId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intControlPointId = B.intControlPointId OR (A.intControlPointId IS NULL AND B.intControlPointId IS NULL) THEN ''
			ELSE '{"change": "intControlPointId", "from": "'+CAST(ISNULL(A.intControlPointId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intControlPointId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strDescription, '') = ISNULL(B.strDescription, '') OR (A.strDescription IS NULL AND B.strDescription IS NULL) THEN ''
			ELSE '{"change": "strDescription", "from": "'+CAST(ISNULL(A.strDescription,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strDescription,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "strDescription"},' END +
			
		CASE WHEN ISNULL(A.strItemSpecification, '') = ISNULL(B.strItemSpecification, '') OR (A.strItemSpecification IS NULL AND B.strItemSpecification IS NULL) THEN ''
			ELSE '{"change": "strItemSpecification", "from": "'+CAST(ISNULL(A.strItemSpecification,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strItemSpecification,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Item Specification"},' END +
			
		CASE WHEN ISNULL(A.strReceiptNumber, '') = ISNULL(B.strReceiptNumber, '') OR (A.strReceiptNumber IS NULL AND B.strReceiptNumber IS NULL) THEN ''
			ELSE '{"change": "strReceiptNumber", "from": "'+CAST(ISNULL(A.strReceiptNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strReceiptNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Inv. Receipt No"},' END +
			
		CASE WHEN ISNULL(A.strInvShipmentNumber, '') = ISNULL(B.strInvShipmentNumber, '') OR (A.strInvShipmentNumber IS NULL AND B.strInvShipmentNumber IS NULL) THEN ''
			ELSE '{"change": "strInvShipmentNumber", "from": "'+CAST(ISNULL(A.strInvShipmentNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strInvShipmentNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Inv. Shipment No"},' END +
			
		CASE WHEN A.intContractTypeId = B.intContractTypeId OR (A.intContractTypeId IS NULL AND B.intContractTypeId IS NULL) THEN ''
			ELSE '{"change": "intContractTypeId", "from": "'+CAST(ISNULL(A.intContractTypeId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intContractTypeId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strSampleTypeName, '') = ISNULL(B.strSampleTypeName, '') OR (A.strSampleTypeName IS NULL AND B.strSampleTypeName IS NULL) THEN ''
			ELSE '{"change": "strSampleTypeName", "from": "'+CAST(ISNULL(A.strSampleTypeName,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSampleTypeName,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sample Type"},' END +
			
		CASE WHEN ISNULL(A.strSequenceNumber, '') = ISNULL(B.strSequenceNumber, '') OR (A.strSequenceNumber IS NULL AND B.strSequenceNumber IS NULL) THEN ''
			ELSE '{"change": "strSequenceNumber", "from": "'+CAST(ISNULL(A.strSequenceNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSequenceNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Contract Number"},' END +
			
		CASE WHEN ISNULL(A.strLoadNumber, '') = ISNULL(B.strLoadNumber, '') OR (A.strLoadNumber IS NULL AND B.strLoadNumber IS NULL) THEN ''
			ELSE '{"change": "strLoadNumber", "from": "'+CAST(ISNULL(A.strLoadNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strLoadNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Shipment Number"},' END +
			
		CASE WHEN ISNULL(A.strContractItemName, '') = ISNULL(B.strContractItemName, '') OR (A.strContractItemName IS NULL AND B.strContractItemName IS NULL) THEN ''
			ELSE '{"change": "strContractItemName", "from": "'+CAST(ISNULL(A.strContractItemName,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strContractItemName,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Contract Item"},' END +
			
		CASE WHEN ISNULL(A.strItemNo, '') = ISNULL(B.strItemNo, '') OR (A.strItemNo IS NULL AND B.strItemNo IS NULL) THEN ''
			ELSE '{"change": "strItemNo", "from": "'+CAST(ISNULL(A.strItemNo,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strItemNo,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Item No"},' END +
			
		CASE WHEN ISNULL(A.strBundleItemNo, '') = ISNULL(B.strBundleItemNo, '') OR (A.strBundleItemNo IS NULL AND B.strBundleItemNo IS NULL) THEN ''
			ELSE '{"change": "strBundleItemNo", "from": "'+CAST(ISNULL(A.strBundleItemNo,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strBundleItemNo,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Bundle Item No"},' END +
			
		CASE WHEN ISNULL(A.strPartyName, '') = ISNULL(B.strPartyName, '') OR (A.strPartyName IS NULL AND B.strPartyName IS NULL) THEN ''
			ELSE '{"change": "strPartyName", "from": "'+CAST(ISNULL(A.strPartyName,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strPartyName,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Party Name"},' END +
			
		CASE WHEN ISNULL(A.strWorkOrderNo, '') = ISNULL(B.strWorkOrderNo, '') OR (A.strWorkOrderNo IS NULL AND B.strWorkOrderNo IS NULL) THEN ''
			ELSE '{"change": "strWorkOrderNo", "from": "'+CAST(ISNULL(A.strWorkOrderNo,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strWorkOrderNo,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Work Order"},' END +
			
		CASE WHEN ISNULL(A.strLotStatus, '') = ISNULL(B.strLotStatus, '') OR (A.strLotStatus IS NULL AND B.strLotStatus IS NULL) THEN ''
			ELSE '{"change": "strLotStatus", "from": "'+CAST(ISNULL(A.strLotStatus,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strLotStatus,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Lot Status"},' END +
			
		CASE WHEN ISNULL(A.strSampleUOM, '') = ISNULL(B.strSampleUOM, '') OR (A.strSampleUOM IS NULL AND B.strSampleUOM IS NULL) THEN ''
			ELSE '{"change": "strSampleUOM", "from": "'+CAST(ISNULL(A.strSampleUOM,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSampleUOM,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sample UOM"},' END +
			
		CASE WHEN ISNULL(A.strRepresentingUOM, '') = ISNULL(B.strRepresentingUOM, '') OR (A.strRepresentingUOM IS NULL AND B.strRepresentingUOM IS NULL) THEN ''
			ELSE '{"change": "strRepresentingUOM", "from": "'+CAST(ISNULL(A.strRepresentingUOM,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strRepresentingUOM,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Representing UOM"},' END +
			
		CASE WHEN ISNULL(A.strSubLocationName, '') = ISNULL(B.strSubLocationName, '') OR (A.strSubLocationName IS NULL AND B.strSubLocationName IS NULL) THEN ''
			ELSE '{"change": "strSubLocationName", "from": "'+CAST(ISNULL(A.strSubLocationName,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSubLocationName,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Warehouse"},' END +
			
		CASE WHEN ISNULL(A.strStorageLocationName, '') = ISNULL(B.strStorageLocationName, '') OR (A.strStorageLocationName IS NULL AND B.strStorageLocationName IS NULL) THEN ''
			ELSE '{"change": "strStorageLocationName", "from": "'+CAST(ISNULL(A.strStorageLocationName,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strStorageLocationName,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Storage Unit"},' END +
			
		CASE WHEN ISNULL(A.strBook, '') = ISNULL(B.strBook, '') OR (A.strBook IS NULL AND B.strBook IS NULL) THEN ''
			ELSE '{"change": "strBook", "from": "'+CAST(ISNULL(A.strBook,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strBook,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Profit Centre"},' END +
			
		CASE WHEN ISNULL(A.strSubBook, '') = ISNULL(B.strSubBook, '') OR (A.strSubBook IS NULL AND B.strSubBook IS NULL) THEN ''
			ELSE '{"change": "strSubBook", "from": "'+CAST(ISNULL(A.strSubBook,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSubBook,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sub-book"},' END +
			
		CASE WHEN ISNULL(A.strForwardingAgentName, '') = ISNULL(B.strForwardingAgentName, '') OR (A.strForwardingAgentName IS NULL AND B.strForwardingAgentName IS NULL) THEN ''
			ELSE '{"change": "strForwardingAgentName", "from": "'+CAST(ISNULL(A.strForwardingAgentName,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strForwardingAgentName,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Forwarding Agent"},' END +
			
		CASE WHEN ISNULL(A.strSentByValue, '') = ISNULL(B.strSentByValue, '') OR (A.strSentByValue IS NULL AND B.strSentByValue IS NULL) THEN ''
			ELSE '{"change": "strSentByValue", "from": "'+CAST(ISNULL(A.strSentByValue,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSentByValue,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.ysnPartyMandatory = B.ysnPartyMandatory OR (A.ysnPartyMandatory IS NULL AND B.ysnPartyMandatory IS NULL) THEN ''
			ELSE '{"change": "ysnPartyMandatory", "from": "'+CAST(ISNULL(A.ysnPartyMandatory,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.ysnPartyMandatory,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.ysnMultipleContractSeq = B.ysnMultipleContractSeq OR (A.ysnMultipleContractSeq IS NULL AND B.ysnMultipleContractSeq IS NULL) THEN ''
			ELSE '{"change": "ysnMultipleContractSeq", "from": "'+CAST(ISNULL(A.ysnMultipleContractSeq,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.ysnMultipleContractSeq,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN A.intSamplingCriteriaId = B.intSamplingCriteriaId OR (A.intSamplingCriteriaId IS NULL AND B.intSamplingCriteriaId IS NULL) THEN ''
			ELSE '{"change": "intSamplingCriteriaId", "from": "'+CAST(ISNULL(A.intSamplingCriteriaId,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.intSamplingCriteriaId,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": true},' END +
			
		CASE WHEN ISNULL(A.strSamplingCriteria, '') = ISNULL(B.strSamplingCriteria, '') OR (A.strSamplingCriteria IS NULL AND B.strSamplingCriteria IS NULL) THEN ''
			ELSE '{"change": "strSamplingCriteria", "from": "'+CAST(ISNULL(A.strSamplingCriteria,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSamplingCriteria,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Sampling Criteria"},' END +
			
		CASE WHEN ISNULL(A.strSendSampleTo, '') = ISNULL(B.strSendSampleTo, '') OR (A.strSendSampleTo IS NULL AND B.strSendSampleTo IS NULL) THEN ''
			ELSE '{"change": "strSendSampleTo", "from": "'+CAST(ISNULL(A.strSendSampleTo,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strSendSampleTo,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Send Sample To"},' END +
			
		CASE WHEN ISNULL(A.strRepresentLotNumber, '') = ISNULL(B.strRepresentLotNumber, '') OR (A.strRepresentLotNumber IS NULL AND B.strRepresentLotNumber IS NULL) THEN ''
			ELSE '{"change": "strRepresentLotNumber", "from": "'+CAST(ISNULL(A.strRepresentLotNumber,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strRepresentLotNumber,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intSampleId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Represent Lot No"},' END

	FROM
		-- B = Cupping Session Sample
		(SELECT
			S.intSampleId
			,S.intCompanyId
			,S.intSampleTypeId
			,S.strSampleNumber
			,S.intParentSampleId
			,S.strSampleRefNo
			,S.intProductTypeId
			,S.intProductValueId
			,S.intSampleStatusId
			,S.intPreviousSampleStatusId
			,S.intItemId
			,S.intItemContractId
			,S.intContractHeaderId
			,S.intContractDetailId
			,S.intShipmentBLContainerId
			,S.intShipmentBLContainerContractId
			,S.intShipmentId
			,S.intShipmentContractQtyId
			,S.intCountryID
			,S.ysnIsContractCompleted
			,S.intLotStatusId
			,S.intEntityId
			,S.intShipperEntityId
			,S.strShipmentNumber
			,S.strLotNumber
			,S.strSampleNote
			,S.dtmSampleReceivedDate
			,S.dtmTestedOn
			,S.intTestedById
			,S.dblSampleQty
			,S.intSampleUOMId
			,S.dblRepresentingQty
			,S.intRepresentingUOMId
			,S.strRefNo
			,S.dtmTestingStartDate
			,S.dtmTestingEndDate
			,S.dtmSamplingEndDate
			,S.strSamplingMethod
			,S.strContainerNumber
			,S.strMarks
			,S.intCompanyLocationSubLocationId
			,S.strCountry
			,S.intItemBundleId
			,S.intLoadContainerId
			,S.intLoadDetailContainerLinkId
			,S.intLoadId
			,S.intLoadDetailId
			,S.dtmBusinessDate
			,S.intShiftId
			,S.intLocationId
			,S.intInventoryReceiptId
			,S.intInventoryShipmentId
			,S.intWorkOrderId
			,S.strComment
			,S.ysnAdjustInventoryQtyBySampleQty
			,S.intStorageLocationId
			,S.intBookId
			,S.intSubBookId
			,S.strChildLotNumber
			,S.strCourier
			,S.strCourierRef
			,S.intForwardingAgentId
			,S.strForwardingAgentRef
			,S.strSentBy
			,S.intSentById
			,S.intSampleRefId
			,S.ysnParent
			,S.ysnIgnoreContract
			,S.ysnImpactPricing
			,S.dtmRequestedDate
			,S.dtmSampleSentDate
			,S.intSamplingCriteriaId
			,S.strSendSampleTo
			,S.strRepresentLotNumber
			,S.intRelatedSampleId
			,S.intTypeId
			,S.intCuppingSessionDetailId
			,S.intCreatedUserId
			,S.dtmCreated
			,S.intLastModifiedUserId
			,S.dtmLastModified
			,V.intControlPointId
			,V.strDescription
			,V.strReceiptNumber
			,V.strShipmentNumber AS strInvShipmentNumber
			,V.intContractTypeId
			,V.intLinkContractHeaderId
			,V.strSampleTypeName
			,V.strSequenceNumber
			,V.strLoadNumber
			,V.strContractItemName
			,V.strItemNo
			,V.strBundleItemNo
			,V.intPartyName
			,V.strPartyName
			,V.intPartyContactId
			,V.strWorkOrderNo
			,V.strLotStatus
			,V.strSampleUOM
			,V.strRepresentingUOM
			,V.strSampleStatus
			,V.strPreviousSampleStatus
			,V.strSubLocationName
			,V.strParentSampleNo
			,V.strStorageLocationName
			,V.strItemSpecification
			,V.strBook
			,V.strSubBook
			,V.strForwardingAgentName
			,V.strSentByValue
			,V.ysnPartyMandatory
			,V.ysnMultipleContractSeq
			,V.dblHeaderQuantity
			,V.strHeaderUnitMeasure
			,V.strSamplingCriteria
			,V.strRelatedSampleNumber
			,V.strCuppingSessionNumber
			,V.intCuppingSessionId
			,V.dtmCuppingDateTime
			,V.intRank
		FROM tblQMSample S
		LEFT JOIN vyuQMSampleNotMapped V ON V.intSampleId = S.intSampleId
	) B
	INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = B.intCuppingSessionDetailId
	-- A = Parent Sample
	INNER JOIN 
	(
		SELECT
			S.intSampleId
			,S.intCompanyId
			,S.intSampleTypeId
			,S.strSampleNumber
			,S.intParentSampleId
			,S.strSampleRefNo
			,S.intProductTypeId
			,S.intProductValueId
			,S.intSampleStatusId
			,S.intPreviousSampleStatusId
			,S.intItemId
			,S.intItemContractId
			,S.intContractHeaderId
			,S.intContractDetailId
			,S.intShipmentBLContainerId
			,S.intShipmentBLContainerContractId
			,S.intShipmentId
			,S.intShipmentContractQtyId
			,S.intCountryID
			,S.ysnIsContractCompleted
			,S.intLotStatusId
			,S.intEntityId
			,S.intShipperEntityId
			,S.strShipmentNumber
			,S.strLotNumber
			,S.strSampleNote
			,S.dtmSampleReceivedDate
			,S.dtmTestedOn
			,S.intTestedById
			,S.dblSampleQty
			,S.intSampleUOMId
			,S.dblRepresentingQty
			,S.intRepresentingUOMId
			,S.strRefNo
			,S.dtmTestingStartDate
			,S.dtmTestingEndDate
			,S.dtmSamplingEndDate
			,S.strSamplingMethod
			,S.strContainerNumber
			,S.strMarks
			,S.intCompanyLocationSubLocationId
			,S.strCountry
			,S.intItemBundleId
			,S.intLoadContainerId
			,S.intLoadDetailContainerLinkId
			,S.intLoadId
			,S.intLoadDetailId
			,S.dtmBusinessDate
			,S.intShiftId
			,S.intLocationId
			,S.intInventoryReceiptId
			,S.intInventoryShipmentId
			,S.intWorkOrderId
			,S.strComment
			,S.ysnAdjustInventoryQtyBySampleQty
			,S.intStorageLocationId
			,S.intBookId
			,S.intSubBookId
			,S.strChildLotNumber
			,S.strCourier
			,S.strCourierRef
			,S.intForwardingAgentId
			,S.strForwardingAgentRef
			,S.strSentBy
			,S.intSentById
			,S.intSampleRefId
			,S.ysnParent
			,S.ysnIgnoreContract
			,S.ysnImpactPricing
			,S.dtmRequestedDate
			,S.dtmSampleSentDate
			,S.intSamplingCriteriaId
			,S.strSendSampleTo
			,S.strRepresentLotNumber
			,S.intRelatedSampleId
			,S.intTypeId
			,S.intCuppingSessionDetailId
			,S.intCreatedUserId
			,S.dtmCreated
			,S.intLastModifiedUserId
			,S.dtmLastModified
			,V.intControlPointId
			,V.strDescription
			,V.strReceiptNumber
			,V.strShipmentNumber AS strInvShipmentNumber
			,V.intContractTypeId
			,V.intLinkContractHeaderId
			,V.strSampleTypeName
			,V.strSequenceNumber
			,V.strLoadNumber
			,V.strContractItemName
			,V.strItemNo
			,V.strBundleItemNo
			,V.intPartyName
			,V.strPartyName
			,V.intPartyContactId
			,V.strWorkOrderNo
			,V.strLotStatus
			,V.strSampleUOM
			,V.strRepresentingUOM
			,V.strSampleStatus
			,V.strPreviousSampleStatus
			,V.strSubLocationName
			,V.strParentSampleNo
			,V.strStorageLocationName
			,V.strItemSpecification
			,V.strBook
			,V.strSubBook
			,V.strForwardingAgentName
			,V.strSentByValue
			,V.ysnPartyMandatory
			,V.ysnMultipleContractSeq
			,V.dblHeaderQuantity
			,V.strHeaderUnitMeasure
			,V.strSamplingCriteria
			,V.strRelatedSampleNumber
			,V.strCuppingSessionNumber
			,V.intCuppingSessionId
			,V.dtmCuppingDateTime
			,V.intRank
		FROM tblQMSample S
		LEFT JOIN vyuQMSampleNotMapped V ON V.intSampleId = S.intSampleId
	) A ON A.intSampleId = CSD.intParentSampleId
	WHERE B.intSampleId = @intCuppingSampleId

	-- Generate audit logs JSON string for the test result changes
	-- SELECT
	-- 	@strTestResultChildrenLog =
	-- 	CASE WHEN ISNULL(A.strPropertyValue, '') = ISNULL(B.strPropertyValue, '') OR (A.strPropertyValue IS NULL AND B.strPropertyValue IS NULL) THEN ''
	-- 		ELSE '{"change": "strPropertyValue", "from": "'+CAST(ISNULL(A.strPropertyValue,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strPropertyValue,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intTestResultId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Actual Value"},' END +
			
	-- 	CASE WHEN ISNULL(A.strComment, '') = ISNULL(B.strComment, '') OR (A.strComment IS NULL AND B.strComment IS NULL) THEN ''
	-- 		ELSE '{"change": "strComment", "from": "'+CAST(ISNULL(A.strComment,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strComment,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intTestResultId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Comment"},' END
	-- FROM tblQMSample S
	-- INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
	-- INNER JOIN tblQMSample T ON T.intSampleId = CSD.intParentSampleId
	-- -- A = Test Results From Parent Sample
	-- INNER JOIN tblQMTestResult A ON A.intSampleId = T.intSampleId
	-- -- B = Test Results From Cupping Sample
	-- INNER JOIN tblQMTestResult B
	-- 	ON B.intSampleId = S.intSampleId
	-- 	AND B.intTestId = A.intTestId
	-- 	AND B.intPropertyId = A.intPropertyId
	-- WHERE S.intSampleId = @intCuppingSampleId

	SELECT @strTestResultChildrenLog = SUBSTRING((
		SELECT
			'{"action": "Updated", "change": "Updated - Record: '+strTestName+' - '+strPropertyName+'", "keyValue": '+CAST(intKeyValue AS NVARCHAR)+',"iconCls": "small-tree-modified","children": ['
			-- Remove trailing comma for strJson
			+ REVERSE(STUFF(REVERSE(LTRIM(RTRIM(strJson))),1,CASE WHEN SUBSTRING((REVERSE(LTRIM(RTRIM(strJson)))), 1, 1) = ',' THEN 1 ELSE 0 END,''))
			+ ']},'
		FROM (
			SELECT
				[strJson] =
				CASE WHEN ISNULL(A.strPropertyValue, '') = ISNULL(B.strPropertyValue, '') OR (A.strPropertyValue IS NULL AND B.strPropertyValue IS NULL) THEN ''
					ELSE '{"change": "strPropertyValue", "from": "'+CAST(ISNULL(A.strPropertyValue,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strPropertyValue,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intTestResultId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Actual Value"},' END +
					
				CASE WHEN ISNULL(A.strComment, '') = ISNULL(B.strComment, '') OR (A.strComment IS NULL AND B.strComment IS NULL) THEN ''
					ELSE '{"change": "strComment", "from": "'+CAST(ISNULL(A.strComment,'') AS NVARCHAR(MAX))+'", "to": "'+CAST(ISNULL(B.strComment,'') AS NVARCHAR(MAX))+'", "leaf": true, "iconCls": "small-gear", "isField": true, "keyValue": "'+CAST(ISNULL(A.intTestResultId,'') AS NVARCHAR(50))+'", "hidden": false, "changeDescription": "Comment"},' END
				
				,[strTestName] = QT.strTestName
				,[strPropertyName] = QP.strPropertyName
				,[intKeyValue] = A.intTestResultId
			FROM tblQMSample S
			INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
			INNER JOIN tblQMSample T ON T.intSampleId = CSD.intParentSampleId
			-- A = Test Results From Parent Sample
			INNER JOIN tblQMTestResult A ON A.intSampleId = T.intSampleId
			INNER JOIN tblQMTest QT ON QT.intTestId = A.intTestId
			INNER JOIN tblQMProperty QP ON QP.intPropertyId = A.intPropertyId
			-- B = Test Results From Cupping Sample
			INNER JOIN tblQMTestResult B
				ON B.intSampleId = S.intSampleId
				AND B.intTestId = A.intTestId
				AND B.intPropertyId = A.intPropertyId
			WHERE S.intSampleId = @intCuppingSampleId
		) J
		FOR XML PATH('')
	),1,99999);

	-- Remove trailing comma
	SELECT @strTestResultChildrenLog = left(@strTestResultChildrenLog, len(@strTestResultChildrenLog) - 1)

	IF(@strTestResultChildrenLog IS NOT NULL AND @strTestResultChildrenLog <> '')
		SELECT @strTestResultChildrenLog = '{"change": "tblQMTestResults", "children": ['+@strTestResultChildrenLog+'], "iconCls": "small-tree-grid", "changeDescription": "Test Detail"}'

	SELECT @strMainChildrenLog = ISNULL(@strMainChildrenLog, '') + ISNULL(@strTestResultChildrenLog, '')


	-- Actual update for parent sample header
	UPDATE A
	SET
		intConcurrencyId = A.intConcurrencyId + 1
		,intCompanyId = B.intCompanyId
		,intSampleTypeId = B.intSampleTypeId
		-- ,strSampleNumber = B.strSampleNumber
		,intParentSampleId = B.intParentSampleId
		,strSampleRefNo = B.strSampleRefNo
		,intProductTypeId = B.intProductTypeId
		,intProductValueId = B.intProductValueId
		-- ,intSampleStatusId = B.intSampleStatusId
		-- ,intPreviousSampleStatusId = B.intPreviousSampleStatusId
		,intItemId = B.intItemId
		,intItemContractId = B.intItemContractId
		,intContractHeaderId = B.intContractHeaderId
		,intContractDetailId = B.intContractDetailId
		,intShipmentBLContainerId = B.intShipmentBLContainerId
		,intShipmentBLContainerContractId = B.intShipmentBLContainerContractId
		,intShipmentId = B.intShipmentId
		,intShipmentContractQtyId = B.intShipmentContractQtyId
		,intCountryID = B.intCountryID
		,ysnIsContractCompleted = B.ysnIsContractCompleted
		,intLotStatusId = B.intLotStatusId
		,intEntityId = B.intEntityId
		,intShipperEntityId = B.intShipperEntityId
		,strShipmentNumber = B.strShipmentNumber
		,strLotNumber = B.strLotNumber
		,strSampleNote = B.strSampleNote
		,dtmSampleReceivedDate = B.dtmSampleReceivedDate
		,dtmTestedOn = B.dtmTestedOn
		,intTestedById = B.intTestedById
		,dblSampleQty = B.dblSampleQty
		,intSampleUOMId = B.intSampleUOMId
		,dblRepresentingQty = B.dblRepresentingQty
		,intRepresentingUOMId = B.intRepresentingUOMId
		,strRefNo = B.strRefNo
		,dtmTestingStartDate = B.dtmTestingStartDate
		,dtmTestingEndDate = B.dtmTestingEndDate
		,dtmSamplingEndDate = B.dtmSamplingEndDate
		,strSamplingMethod = B.strSamplingMethod
		,strContainerNumber = B.strContainerNumber
		,strMarks = B.strMarks
		,intCompanyLocationSubLocationId = B.intCompanyLocationSubLocationId
		,strCountry = B.strCountry
		,intItemBundleId = B.intItemBundleId
		,intLoadContainerId = B.intLoadContainerId
		,intLoadDetailContainerLinkId = B.intLoadDetailContainerLinkId
		,intLoadId = B.intLoadId
		,intLoadDetailId = B.intLoadDetailId
		,dtmBusinessDate = B.dtmBusinessDate
		,intShiftId = B.intShiftId
		,intLocationId = B.intLocationId
		,intInventoryReceiptId = B.intInventoryReceiptId
		,intInventoryShipmentId = B.intInventoryShipmentId
		,intWorkOrderId = B.intWorkOrderId
		,strComment = B.strComment
		,ysnAdjustInventoryQtyBySampleQty = B.ysnAdjustInventoryQtyBySampleQty
		,intStorageLocationId = B.intStorageLocationId
		,intBookId = B.intBookId
		,intSubBookId = B.intSubBookId
		,strChildLotNumber = B.strChildLotNumber
		,strCourier = B.strCourier
		,strCourierRef = B.strCourierRef
		,intForwardingAgentId = B.intForwardingAgentId
		,strForwardingAgentRef = B.strForwardingAgentRef
		,strSentBy = B.strSentBy
		,intSentById = B.intSentById
		,intSampleRefId = B.intSampleRefId
		,ysnParent = B.ysnParent
		,ysnIgnoreContract = B.ysnIgnoreContract
		,ysnImpactPricing = B.ysnImpactPricing
		,dtmRequestedDate = B.dtmRequestedDate
		,dtmSampleSentDate = B.dtmSampleSentDate
		,intSamplingCriteriaId = B.intSamplingCriteriaId
		,strSendSampleTo = B.strSendSampleTo
		,strRepresentLotNumber = B.strRepresentLotNumber
		,intRelatedSampleId = B.intRelatedSampleId
		-- ,intTypeId = B.intTypeId
		-- ,intCuppingSessionDetailId = B.intCuppingSessionDetailId
		-- ,intCreatedUserId = B.intCreatedUserId
		-- ,dtmCreated = B.dtmCreated
		,intLastModifiedUserId = B.intLastModifiedUserId
		,dtmLastModified = B.dtmLastModified
	FROM tblQMSample A
	INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intParentSampleId = A.intSampleId
	INNER JOIN tblQMSample B ON B.intCuppingSessionDetailId = CSD.intCuppingSessionDetailId
	WHERE B.intSampleId = @intCuppingSampleId

	-- Actual update for parent sample test results
	UPDATE A
	SET
		strPropertyValue = B.strPropertyValue
		,strComment = B.strComment
		,intLastModifiedUserId = B.intLastModifiedUserId
		,dtmLastModified = B.dtmLastModified
	FROM tblQMSample S
	INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intCuppingSessionDetailId = S.intCuppingSessionDetailId
	INNER JOIN tblQMSample T ON T.intSampleId = CSD.intParentSampleId
	-- A = Test Results From Parent Sample
	INNER JOIN tblQMTestResult A ON A.intSampleId = T.intSampleId
	INNER JOIN tblQMTest QT ON QT.intTestId = A.intTestId
	INNER JOIN tblQMProperty QP ON QP.intPropertyId = A.intPropertyId
	-- B = Test Results From Cupping Sample
	INNER JOIN tblQMTestResult B
		ON B.intSampleId = S.intSampleId
		AND B.intTestId = A.intTestId
		AND B.intPropertyId = A.intPropertyId
	WHERE S.intSampleId = @intCuppingSampleId

	-- Post audit logs
	IF(@strTestResultChildrenLog IS NOT NULL AND @strTestResultChildrenLog <> '')
	BEGIN
		EXEC uspSMAuditLog
			@screenName = 'Quality.view.QualitySample',
			@entityId = @intUserEntityId,
			@actionType = "Updated",
			@actionIcon = 'small-tree-modified',
			@keyValue = @intParentSampleId,
			@details = @strMainChildrenLog
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @msg VARCHAR(MAX) = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@msg, 11, 1) 
END CATCH 
GO