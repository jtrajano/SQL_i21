CREATE PROCEDURE uspLGCreateLoadIntegrationLog 
	 @intLoadId INT
	,@strRowState NVARCHAR(100)
	,@intShipmentType INT = 1
	,@intUserId INT = NULL
AS
BEGIN TRY
	DECLARE @intLoadStgId INT
	DECLARE @intLoadLogId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @dtmCurrentETAPOD DATETIME
	DECLARE @intLeadTime INT
	DECLARE @dtmCurrentPlannedAvailabilityDate DATETIME
	DECLARE @dtmCurrentUpdatedAvailabilityDate DATETIME
	DECLARE @dtmCalculatedUpdatedAvailabilityDate DATETIME
	DECLARE @dtmMaxETAPOD DATETIME
	DECLARE @dtmCurrentETSPOL DATETIME
	DECLARE @dtmMaxETSPOL DATETIME
	DECLARE @strETAPODReasonCode NVARCHAR(MAX)
	DECLARE @strETSPOLReasonCode NVARCHAR(MAX)
	DECLARE @ysnPOETAFeedToERP BIT
	DECLARE @ysnFeedETAToUpdatedAvailabilityDate BIT
	DECLARE @intMinLoadDetailRecordId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractSeq INT
	DECLARE @intContractHeaderId INT
	DECLARE @dtmPlannedAvailabilityDate DATETIME
	DECLARE @intApprovedById INT
	DECLARE @intShipmentStatus INT
	DECLARE @intPurchaseSale INT
	DECLARE @intSContractDetailId INT
	DECLARE @intSContractSeq INT
	DECLARE @intSContractHeaderId INT
	DECLARE @strAuditDescription NVARCHAR(MAX)

	DECLARE @tblLoadDetail TABLE
			(intDetailRecordId INT Identity(1, 1),
			 intLoadId INT, 
			 intLoadDetailId INT, 
			 intContractDetailId INT,
			 intContractHeaderId INT,
			 dtmPlannedAvailabilityDate DATETIME)

	SELECT @dtmCurrentETAPOD = dtmETAPOD,
		   @dtmCurrentETSPOL = dtmETSPOL,
		   @strETAPODReasonCode = PODRC.strReasonCodeDescription,
		   @strETSPOLReasonCode = POLRC.strReasonCodeDescription,
		   @intShipmentStatus = L.intShipmentStatus,
		   @intLeadTime = ISNULL(DPort.intLeadTime, 0),
		   @intPurchaseSale = L.intPurchaseSale
	FROM tblLGLoad L
	LEFT JOIN tblLGReasonCode PODRC ON PODRC.intReasonCodeId = L.intETAPOLReasonCodeId
	LEFT JOIN tblLGReasonCode POLRC ON POLRC.intReasonCodeId = L.intETSPOLReasonCodeId
	OUTER APPLY (SELECT TOP 1 intLeadTime FROM tblSMCity DPort 
				WHERE DPort.strCity = L.strDestinationPort AND DPort.ysnPort = 1) DPort
	WHERE intLoadId = @intLoadId

	IF(ISNULL(@intShipmentStatus,0) IN (4,10) AND @strRowState <> 'Delete')
	BEGIN
		RETURN;
	END	

	SELECT @ysnPOETAFeedToERP = ysnPOETAFeedToERP
		,@ysnFeedETAToUpdatedAvailabilityDate = ysnFeedETAToUpdatedAvailabilityDate
	FROM tblLGCompanyPreference
	
	INSERT INTO @tblLoadDetail (
		intLoadId
		,intLoadDetailId
		,intContractDetailId
		,intContractHeaderId
		,dtmPlannedAvailabilityDate)
	SELECT L.intLoadId
		,LD.intLoadDetailId
		,CD.intContractDetailId
		,CH.intContractHeaderId
		,CD.dtmPlannedAvailabilityDate
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE L.intLoadId = @intLoadId

	IF EXISTS(SELECT 1 FROM tblLGLoadStg WHERE ISNULL(strFeedStatus,'') = '' AND intLoadId = @intLoadId AND strRowState = 'Added')
	BEGIN
		DELETE FROM tblLGLoadStg WHERE intLoadId = @intLoadId AND strRowState = 'Added'
		SET @strRowState = 'Added'
	END

	/* Create Integration Log */
	IF (@intShipmentType = 1)
	BEGIN
		IF (@strRowState IN ('Added','Delete'))
		BEGIN
			INSERT INTO tblLGLoadStg (
				intLoadId
				,strTransactionType
				,strLoadNumber
				,strShippingInstructionNumber
				,strContractBasis
				,strContractBasisDesc
				,strBillOfLading
				,strShippingLine
				,strShippingLineAccountNo
				,strExternalShipmentNumber
				,strDateQualifier
				,dtmScheduledDate
				,strMVessel
				,strMVoyageNumber
				,strFVessel
				,strFVoyageNumber
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmBLDate
				,strRowState
				,dtmFeedCreated
				)
			SELECT L.intLoadId
				,strShipmentType = CASE L.intShipmentType
					WHEN 1
						THEN 'Shipment'
					WHEN 2
						THEN 'Shipping Instructions'
					WHEN 3
						THEN 'Vessel Nomination'
					ELSE ''
					END COLLATE Latin1_General_CI_AS
				,L.strLoadNumber
				,strShippingInstructionNumber = ISNULL(LSI.strLoadNumber, L.strLoadNumber)
				,strContractBasis = CB.strContractBasis
				,strContractBasisDesc = CB.strDescription
				,L.strBLNumber
				,strShippingLine = E.strName
				,V.strVendorAccountNum
				,L.strExternalShipmentNumber
				,strDateQualifier = '015'
				,L.dtmScheduledDate
				,L.strMVessel
				,L.strMVoyageNumber
				,L.strFVessel
				,L.strFVoyageNumber
				,L.dtmETAPOD
				,L.dtmETAPOL
				,L.dtmETSPOL
				,L.dtmBLDate
				,@strRowState
				,GETDATE()
			FROM tblLGLoad L
			LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
			OUTER APPLY (
					SELECT TOP 1 CB.strContractBasis, CB.strDescription
					FROM tblCTContractHeader CH
					JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
					JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
					WHERE LD.intLoadId = L.intLoadId
					) CB
			WHERE L.intLoadId = @intLoadId

			SELECT @intLoadStgId = SCOPE_IDENTITY()

			INSERT INTO tblLGLoadDetailStg(
				 intLoadStgId
				,intLoadId
				,intSIDetailId
				,intLoadDetailId
				,intRowNumber
				,strItemNo
				,strSubLocationName
				,strStorageLocationName
				,strBatchNumber
				,dblDeliveredQty
				,strUnitOfMeasure
				,dblNetWt
				,dblGrossWt
				,strWeightUOM
				,intHigherPositionRef
				,strDocumentCategory
				,strReferenceDataInfo
				,strSeq
				,strLoadNumber
				,strExternalPONumber
				,strExternalPOItemNumber
				,strExternalPOBatchNumber
				,strExternalShipmentItemNumber
				,strExternalBatchNo
				,strChangeType
				,strRowState
				,dtmFeedCreated
				,strCommodityCode)
			SELECT intLoadStgId = @intLoadStgId
				,intLoadId = @intLoadId
				,intSIDetailId = ISNULL(LSID.intLoadDetailId, LD.intLoadDetailId)
				,LD.intLoadDetailId
				,intRowNumber = Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,I.strItemNo
				,strSubLocationName = CLSL.strSubLocationName
				,strStorageLocationName = SL.strName
				,strBatchNumber = L.strLoadNumber
				,dblDeliveredQty = LD.dblQuantity
				,strItemUOM = IU.strUnitMeasure
				,LD.dblGross
				,LD.dblNet
				,strWeightItemUOM = WU.strUnitMeasure
				,intHigherPositionRef = Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,strDocumentCategory = 'C'
				,strRefDataInfo = '001'
				,strSeq = 0
				,L.strLoadNumber
				,strExternalPONumber = CD.strERPPONumber
				,strExternalPOItemNumber = CD.strERPItemNumber
				,strExternalPOBatchNumber = CD.strERPBatchNumber
				,strExternalShipmentItemNumber = LD.strExternalShipmentItemNumber
				,strExternalBatchNo = LD.strExternalBatchNo
				,strChangeType = 'QUA'
				,strRowState = @strRowState
				,dtmFeedCreated = GETDATE()
				,C.strCommodityCode
			FROM tblLGLoadDetail LD
			LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
			LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
			LEFT JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
			LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
			LEFT JOIN tblICUnitMeasure IU ON IU.intUnitMeasureId = IUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = LD.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WU ON WU.intUnitMeasureId = WUOM.intUnitMeasureId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId AND LD.intPContractDetailId = LSID.intPContractDetailId
			WHERE LD.intLoadId = @intLoadId

			INSERT INTO tblLGLoadContainerStg(
				 intLoadStgId
				,intLoadId
				,intLoadContainerId
				,strContainerNo
				,strContainerSizeCode
				,strPackagingMaterialType
				,strExternalPONumber
				,strSeq
				,dblContainerQty
				,strContainerUOM
				,dblNetWt
				,dblGrossWt
				,strWeightUOM
				,strExternalContainerId
				,strSubLocation
				,strStorageLocation
				,strRowState
				,dtmFeedCreated)
			SELECT @intLoadStgId
				,@intLoadId
				,LC.intLoadContainerId
				,LC.strContainerNumber
				,CASE 
					WHEN CT.strContainerType LIKE '%20%'
						THEN '000000000010003243'
					WHEN CT.strContainerType LIKE '%40%'
						THEN '000000000010003244'
					ELSE CT.strContainerType
					END
				,'0002'
				,L.strExternalShipmentNumber
				,ROW_NUMBER() OVER (
					PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
					) AS Seq
				,LC.dblQuantity
				,LC.strItemUOM
				,LC.dblNetWt
				,LC.dblGrossWt
				,LC.strWeightUnitMeasure
				,LDCL.strExternalContainerId
				,CASE 
					WHEN ISNULL(CLSL.strSubLocationName, '') = ''
						THEN LDCLSL.strSubLocationName
					ELSE CLSL.strSubLocationName
					END
				,CASE 
					WHEN ISNULL(SL.strName, '') = ''
						THEN (
								SELECT SL.strName AS strStorageLocationName
								FROM tblCTContractDetail CD
								JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
								WHERE CD.intContractDetailId = LD.intPContractDetailId
								)
					ELSE SL.strName
					END
				,'Addded'
				,GETDATE()
			FROM vyuLGLoadContainerView LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
			LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
			LEFT JOIN tblSMCompanyLocationSubLocation LDCLSL ON LDCLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
			WHERE LC.intLoadId = @intLoadId
			ORDER BY LC.intSort
		END
		ELSE 
		BEGIN
			INSERT INTO tblLGLoadLog (
				intLoadId
				,strTransactionType
				,strLoadNumber
				,strShippingInstructionNumber
				,strContractBasis
				,strContractBasisDesc
				,strBillOfLading
				,strShippingLine
				,strShippingLineAccountNo
				,strExternalShipmentNumber
				,strDateQualifier
				,dtmScheduledDate
				,strMVessel
				,strMVoyageNumber
				,strFVessel
				,strFVoyageNumber
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmBLDate
				,strRowState
				)
			SELECT intLoadId
				,strShipmentType = CASE L.intShipmentType
					WHEN 1
						THEN 'Shipment'
					WHEN 2
						THEN 'Shipping Instructions'
					WHEN 3
						THEN 'Vessel Nomination'
					ELSE ''
					END COLLATE Latin1_General_CI_AS
				,strLoadNumber
				,CASE 
					WHEN ISNULL(L.strShippingInstructionNumber, '') = ''
						THEN L.strLoadNumber
					ELSE L.strShippingInstructionNumber
					END
				,strContractBasis = (
					SELECT TOP 1 CB.strContractBasis
					FROM tblCTContractHeader CH
					JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CH.intContractHeaderId
					WHERE LD.intLoadId = L.intLoadId
					)
				,strContractBasisDesc = (
					SELECT TOP 1 CB.strDescription
					FROM tblCTContractHeader CH
					JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CH.intContractHeaderId
					WHERE LD.intLoadId = L.intLoadId
					)
				,L.strBLNumber
				,L.strShippingLine
				,V.strVendorAccountNum
				,L.strExternalShipmentNumber
				,'015' AS strDateQualifier
				,L.dtmScheduledDate
				,L.strMVessel
				,L.strMVoyageNumber
				,L.strFVessel
				,L.strFVoyageNumber
				,L.dtmETAPOD
				,L.dtmETAPOL
				,L.dtmETSPOL
				,L.dtmBLDate
				,@strRowState
			FROM vyuLGLoadView L
			LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
			LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
			WHERE intLoadId = @intLoadId

			SELECT @intLoadLogId = SCOPE_IDENTITY()

			INSERT INTO tblLGLoadDetailLog(
				 intLoadLogId
				,intLoadId
				,intSIDetailId
				,intLoadDetailId
				,intRowNumber
				,strItemNo
				,strSubLocationName
				,strStorageLocationName
				,strBatchNumber
				,dblDeliveredQty
				,strUnitOfMeasure
				,dblNetWt
				,dblGrossWt
				,strWeightUOM
				,intHigherPositionRef
				,strDocumentCategory
				,strReferenceDataInfo
				,strSeq
				,strLoadNumber
				,strExternalPONumber
				,strExternalPOItemNumber
				,strExternalPOBatchNumber
				,strExternalShipmentItemNumber
				,strExternalBatchNo
				,strChangeType
				,strRowState
				,strCommodityCode)
			SELECT intLoadLogId = @intLoadLogId
				,intLoadId = @intLoadId
				,intSIDetailId = ISNULL(LSID.intLoadDetailId, LD.intLoadDetailId)
				,LD.intLoadDetailId
				,intRowNumber = Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,I.strItemNo
				,strSubLocationName = CLSL.strSubLocationName
				,strStorageLocationName = SL.strName
				,strBatchNumber = L.strLoadNumber
				,dblDeliveredQty = LD.dblQuantity
				,strItemUOM = IU.strUnitMeasure
				,LD.dblNet
				,LD.dblGross
				,strWeightItemUOM = WU.strUnitMeasure
				,intHigherPositionRef = Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,strDocumentCategory = 'C'
				,strRefDataInfo = '001'
				,strSeq = 0
				,L.strLoadNumber
				,strExternalPONumber = CD.strERPPONumber
				,strExternalPOItemNumber = CD.strERPItemNumber
				,strExternalPOBatchNumber = CD.strERPBatchNumber
				,strExternalShipmentItemNumber = LD.strExternalShipmentItemNumber
				,strExternalBatchNo = LD.strExternalBatchNo
				,strChangeType = 'QUA'
				,strRowState = @strRowState
				,C.strCommodityCode
			FROM tblLGLoadDetail LD
			LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
			LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
			LEFT JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
			LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
			LEFT JOIN tblICUnitMeasure IU ON IU.intUnitMeasureId = IUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = LD.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WU ON WU.intUnitMeasureId = WUOM.intUnitMeasureId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId AND LD.intPContractDetailId = LSID.intPContractDetailId
			WHERE LD.intLoadId = @intLoadId

			INSERT INTO tblLGLoadContainerLog(
				 intLoadLogId
				,intLoadId
				,intLoadContainerId
				,strContainerNo
				,strContainerSizeCode
				,strPackagingMaterialType
				,strExternalPONumber
				,strSeq
				,dblContainerQty
				,strContainerUOM
				,dblNetWt
				,dblGrossWt
				,strWeightUOM
				,strExternalContainerId
				,strSubLocation
				,strStorageLocation
				,strRowState)
			SELECT @intLoadLogId
				,@intLoadId
				,LC.intLoadContainerId
				,LC.strContainerNumber
				,CASE 
					WHEN CT.strContainerType LIKE '%20%'
						THEN '000000000010003243'
					WHEN CT.strContainerType LIKE '%40%'
						THEN '000000000010003244'
					ELSE CT.strContainerType
					END
				,'0002'
				,L.strExternalLoadNumber
				,ROW_NUMBER() OVER (
					PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
					) AS Seq
				,LC.dblQuantity
				,UM.strUnitMeasure strItemUOM
				,LC.dblNetWt
				,LC.dblGrossWt
				,LUM.strUnitMeasure strWeightUnitMeasure
				,LDCL.strExternalContainerId
				,CASE 
					WHEN ISNULL(CLSL.strSubLocationName, '') = ''
						THEN LDCLSL.strSubLocationName
					ELSE CLSL.strSubLocationName
					END
				,CASE 
					WHEN ISNULL(SL.strName, '') = ''
						THEN (
								SELECT SL.strName AS strStorageLocationName
								FROM tblCTContractDetail CD
								JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
								WHERE CD.intContractDetailId = LD.intPContractDetailId
								)
					ELSE SL.strName
					END strStorageLocationName
				,''
			FROM tblLGLoadContainer LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = LC.intUnitMeasureId
			JOIN tblICUnitMeasure LUM ON LUM.intUnitMeasureId = L.intWeightUnitMeasureId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
			LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
			LEFT JOIN tblSMCompanyLocationSubLocation LDCLSL ON LDCLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
			WHERE LC.intLoadId = @intLoadId
			ORDER BY LC.intSort
		END
	END

	/* Update ETA POD Tracking */
	IF (@intShipmentType = 1 AND @dtmCurrentETAPOD IS NOT NULL AND @strRowState <> 'Delete')
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblLGETATracking WHERE intLoadId = @intLoadId AND strTrackingType = 'ETA POD')
		BEGIN
			INSERT INTO tblLGETATracking (intLoadId, strTrackingType, dtmETAPOD, strETAPODReasonCode, dtmModifiedOn, intConcurrencyId)
			SELECT @intLoadId, 'ETA POD', @dtmCurrentETAPOD, @strETAPODReasonCode, GETDATE(), 1
		END
		ELSE
		BEGIN
			SELECT TOP 1 @dtmMaxETAPOD = dtmETAPOD FROM tblLGETATracking 
			WHERE intLoadId = @intLoadId AND strTrackingType = 'ETA POD' ORDER BY intETATrackingId DESC

			IF (@dtmMaxETAPOD <> @dtmCurrentETAPOD)
			BEGIN
				INSERT INTO tblLGETATracking (intLoadId, strTrackingType, dtmETAPOD, strETAPODReasonCode, dtmModifiedOn, intConcurrencyId)
				SELECT @intLoadId, 'ETA POD', @dtmCurrentETAPOD, @strETAPODReasonCode, GETDATE(), 1
			END
		END
	END

	/* Update ETS POL Tracking */
	IF (@intShipmentType = 1 AND @dtmCurrentETSPOL IS NOT NULL AND @strRowState <> 'Delete')
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblLGETATracking WHERE intLoadId = @intLoadId AND strTrackingType = 'ETS POL')
		BEGIN
			INSERT INTO tblLGETATracking (intLoadId, strTrackingType, dtmETSPOL, strETSPOLReasonCode, dtmModifiedOn, intConcurrencyId)
			SELECT @intLoadId, 'ETS POL', @dtmCurrentETSPOL, @strETSPOLReasonCode, GETDATE(), 1
		END
		ELSE
		BEGIN
			SELECT TOP 1 @dtmMaxETSPOL = dtmETSPOL FROM tblLGETATracking 
			WHERE intLoadId = @intLoadId AND strTrackingType = 'ETS POL' ORDER BY intETATrackingId DESC

			IF (@dtmMaxETSPOL <> @dtmCurrentETSPOL)
			BEGIN
				INSERT INTO tblLGETATracking (intLoadId, strTrackingType, dtmETSPOL, strETSPOLReasonCode, dtmModifiedOn, intConcurrencyId)
				SELECT @intLoadId, 'ETS POL', @dtmCurrentETSPOL, @strETSPOLReasonCode, GETDATE(), 1
			END
		END
	END

	/* Feed ETA to Contract */
	IF ((ISNULL(@ysnPOETAFeedToERP,0) = 1 OR ISNULL(@ysnFeedETAToUpdatedAvailabilityDate,0) = 1) AND (@dtmCurrentETAPOD IS NOT NULL AND @strRowState <> 'Delete'))
	BEGIN
		SELECT @intMinLoadDetailRecordId = MIN(intDetailRecordId) FROM @tblLoadDetail

		WHILE (ISNULL(@intMinLoadDetailRecordId,0)>0)
		BEGIN
			SELECT @intLoadDetailId = NULL
				,@intContractDetailId = NULL
				,@intContractHeaderId = NULL
				,@dtmPlannedAvailabilityDate = NULL
				,@intApprovedById = NULL

			SELECT @intLoadDetailId = intLoadDetailId
				,@intContractDetailId = intContractDetailId
				,@intContractHeaderId = intContractHeaderId
				,@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate
			FROM @tblLoadDetail WHERE intDetailRecordId = @intMinLoadDetailRecordId

			SELECT 
				@intContractSeq = intContractSeq
				,@dtmCurrentPlannedAvailabilityDate = dtmPlannedAvailabilityDate
				,@dtmCurrentUpdatedAvailabilityDate = dtmUpdatedAvailabilityDate
				,@dtmCalculatedUpdatedAvailabilityDate = DATEADD(DD, @intLeadTime, @dtmCurrentETAPOD)
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intContractDetailId

			DECLARE @ysnIsETAUpdated BIT = 0

			IF NOT EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadShippingInstructionId = @intLoadId AND intShipmentStatus <> 10)
			BEGIN
				IF ((@dtmCurrentETAPOD IS NOT NULL))
				BEGIN
					IF (ISNULL(@ysnPOETAFeedToERP,0) = 1 AND ISNULL(@dtmCurrentETAPOD,'') <> ISNULL(@dtmCurrentPlannedAvailabilityDate,''))
					BEGIN
						UPDATE tblCTContractDetail 
						SET dtmPlannedAvailabilityDate = @dtmCurrentETAPOD
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intContractDetailId = @intContractDetailId 

						SELECT @ysnIsETAUpdated = 1
						SET @strAuditDescription = 'Sequence - ' + CAST(@intContractSeq AS VARCHAR(20)) + ', Planned Availability Date'
							
						EXEC dbo.uspSMAuditLog @keyValue = @intContractHeaderId 
							,@screenName = 'ContractManagement.view.Contract'
							,@entityId = @intUserId
							,@actionType = 'Updated (from Feed)'
							,@actionIcon = 'small-tree-modified'
							,@changeDescription = @strAuditDescription
							,@fromValue = @dtmCurrentPlannedAvailabilityDate
							,@toValue = @dtmCurrentETAPOD
					END

					IF (ISNULL(@ysnFeedETAToUpdatedAvailabilityDate,0) = 1 AND @intShipmentType = 1 AND ISNULL(@dtmCalculatedUpdatedAvailabilityDate, '') <> ISNULL(@dtmCurrentUpdatedAvailabilityDate,''))
					BEGIN
						UPDATE tblCTContractDetail 
						SET dtmUpdatedAvailabilityDate = @dtmCalculatedUpdatedAvailabilityDate
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intContractDetailId = @intContractDetailId 
							OR (@intPurchaseSale = 3 AND intContractDetailId = (SELECT TOP 1 intSContractDetailId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId))

						SET @strAuditDescription = 'Sequence - ' + CAST(@intContractSeq AS VARCHAR(20)) + ', Updated Availability Date'	
						EXEC dbo.uspSMAuditLog @keyValue = @intContractHeaderId 
							,@screenName = 'ContractManagement.view.Contract'
							,@entityId = @intUserId
							,@actionType = 'Updated (from Feed)'
							,@actionIcon = 'small-tree-modified'
							,@changeDescription = @strAuditDescription
							,@fromValue = @dtmCurrentUpdatedAvailabilityDate
							,@toValue = @dtmCalculatedUpdatedAvailabilityDate

						IF (@intPurchaseSale = 3)
						BEGIN
							SELECT 
								@intSContractSeq = intContractSeq
								,@intSContractDetailId = intContractDetailId
								,@intSContractHeaderId = intContractHeaderId
							FROM tblCTContractDetail
							WHERE intContractDetailId = (SELECT TOP 1 intSContractDetailId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId)
							
							UPDATE tblCTContractDetail 
							SET dtmUpdatedAvailabilityDate = @dtmCalculatedUpdatedAvailabilityDate
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intContractDetailId = (SELECT TOP 1 intSContractDetailId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId)

							SET @strAuditDescription = 'Sequence - ' + CAST(@intSContractSeq AS VARCHAR(20)) + ', Updated Availability Date'
							EXEC dbo.uspSMAuditLog @keyValue = @intSContractHeaderId 
								,@screenName = 'ContractManagement.view.Contract'
								,@entityId = @intUserId
								,@actionType = 'Updated (from Feed)'
								,@actionIcon = 'small-tree-modified'
								,@changeDescription = @strAuditDescription
								,@fromValue = @dtmCurrentUpdatedAvailabilityDate
								,@toValue = @dtmCalculatedUpdatedAvailabilityDate
						END

						SELECT @ysnIsETAUpdated = 1
					END
						
					IF (@ysnIsETAUpdated = 1) 
					BEGIN
						SELECT TOP 1 @intApprovedById = intApprovedById
						FROM tblCTApprovedContract
						WHERE intContractDetailId = @intContractDetailId
						ORDER BY intApprovedContractId DESC
				
						EXEC uspCTContractApproved @intContractHeaderId = @intContractHeaderId,
							@intApprovedById =  @intApprovedById, 
							@intContractDetailId = @intContractDetailId
					END
				END
			END

			SELECT @intMinLoadDetailRecordId = MIN(intDetailRecordId)
			FROM @tblLoadDetail
			WHERE intDetailRecordId > @intMinLoadDetailRecordId
		END
	END

END TRY
BEGIN CATCH

	SET @strErrMsg = ERROR_MESSAGE()
	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg
		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END

END CATCH