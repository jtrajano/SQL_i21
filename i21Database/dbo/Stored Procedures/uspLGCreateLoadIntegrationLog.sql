CREATE PROCEDURE uspLGCreateLoadIntegrationLog 
	 @intLoadId INT
	,@strRowState NVARCHAR(100)
	,@intShipmentType INT = 1
AS
BEGIN TRY
	DECLARE @intLoadStgId INT
	DECLARE @intLoadLogId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @dtmCurrentETAPOD DATETIME
	DECLARE @dtmCurrentPlannedAvailabilityDate DATETIME
	DECLARE @dtmMaxETAPOD DATETIME
	DECLARE @dtmCurrentETSPOL DATETIME
	DECLARE @dtmMaxETSPOL DATETIME
	DECLARE @strETAPODReasonCode NVARCHAR(MAX)
	DECLARE @strETSPOLReasonCode NVARCHAR(MAX)
	DECLARE @ysnPOETAFeedToERP BIT
	DECLARE @intMinLoadDetailRecordId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT
	DECLARE @dtmPlannedAvailabilityDate DATETIME
	DECLARE @intApprovedById INT

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
		   @strETSPOLReasonCode = POLRC.strReasonCodeDescription
	FROM tblLGLoad L
	LEFT JOIN tblLGReasonCode PODRC ON PODRC.intReasonCodeId = L.intETAPOLReasonCodeId
	LEFT JOIN tblLGReasonCode POLRC ON POLRC.intReasonCodeId = L.intETSPOLReasonCodeId
	WHERE intLoadId = @intLoadId
	
	SELECT @ysnPOETAFeedToERP = ysnPOETAFeedToERP
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
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmBLDate
				,strRowState
				,dtmFeedCreated
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
					JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
					JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
					WHERE LD.intLoadId = L.intLoadId
					)
				,strContractBasisDesc = (
					SELECT TOP 1 CB.strDescription
					FROM tblCTContractHeader CH
					JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
					JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
					WHERE LD.intLoadId = L.intLoadId
					)
				,L.strBLNumber
				,L.strShippingLine
				,V.strVendorAccountNum
				,L.strExternalShipmentNumber
				,'015' AS strDateQualifier
				,L.dtmScheduledDate
				,L.dtmETAPOD
				,L.dtmETAPOL
				,L.dtmETSPOL
				,L.dtmBLDate
				,@strRowState
				,GETDATE()
			FROM vyuLGLoadView L
			LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
			LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
			WHERE intLoadId = @intLoadId

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
			SELECT @intLoadStgId
				,@intLoadId
				,CASE 
					WHEN ISNULL(LSID.intLoadDetailId, 0) = 0
						THEN LD.intLoadDetailId
					ELSE LSID.intLoadDetailId
					END AS intSIDetailId
				,LD.intLoadDetailId
				,Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					) AS intRowNumber
				,LD.strItemNo
				,strSubLocationName = (
					SELECT CLSL.strSubLocationName AS strStorageLocationName
					FROM tblCTContractDetail CD
					JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
					WHERE CD.intContractDetailId = CASE 
							WHEN LD.intPurchaseSale = 1
								THEN LD.intPContractDetailId
							ELSE LD.intSContractDetailId
							END
					)
				,strStorageLocationName = (
					SELECT SL.strName AS strStorageLocationName
					FROM tblCTContractDetail CD
					JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
					WHERE CD.intContractDetailId = CASE 
							WHEN LD.intPurchaseSale = 1
								THEN LD.intPContractDetailId
							ELSE LD.intSContractDetailId
							END
					)
				,LD.strLoadNumber
				,LD.dblQuantity
				,LD.strItemUOM
				,LD.dblGross
				,LD.dblNet
				,LD.strWeightItemUOM
				,Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,'C' AS strDocumentCategory
				,'001' AS strRefDataInfo
				,0 AS strSeq
				,LD.strLoadNumber
				,CD.strERPPONumber
				,CD.strERPItemNumber
				,CD.strERPBatchNumber
				,D.strExternalShipmentItemNumber
				,D.strExternalBatchNo
				,'QUA' AS strChangeType
				,@strRowState AS strRowState
				,GETDATE()
				,C.strCommodityCode
			FROM vyuLGLoadDetailView LD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
					WHEN LD.intPurchaseSale = 1
						THEN LD.intPContractDetailId
					ELSE LD.intSContractDetailId
					END
			JOIN tblLGLoadDetail D ON D.intLoadDetailId = LD.intLoadDetailId
			JOIN tblICCommodity C ON C.intCommodityId = CASE 
					WHEN LD.intPurchaseSale = 1
						THEN LD.intPCommodityId
					ELSE LD.intSCommodityId
					END
			LEFT JOIN tblLGLoad L ON L.intLoadId = D.intLoadId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId AND D.intPContractDetailId = LSID.intPContractDetailId
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
			ORDER BY LC.intLoadContainerId
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
					JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CH.intContractHeaderId
					WHERE LD.intLoadId = L.intLoadId
					)
				,strContractBasisDesc = (
					SELECT TOP 1 CB.strContractBasis
					FROM tblCTContractHeader CH
					JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CH.intContractHeaderId
					WHERE LD.intLoadId = L.intLoadId
					)
				,L.strBLNumber
				,L.strShippingLine
				,V.strVendorAccountNum
				,L.strExternalShipmentNumber
				,'015' AS strDateQualifier
				,L.dtmScheduledDate
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
			SELECT @intLoadLogId
				,@intLoadId
				,CASE 
					WHEN ISNULL(LSID.intLoadDetailId, 0) = 0
						THEN LD.intLoadDetailId
					ELSE LSID.intLoadDetailId
					END AS intSIDetailId
				,LD.intLoadDetailId
				,Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					) AS intRowNumber
				,LD.strItemNo
				,strSubLocationName = (
					SELECT CLSL.strSubLocationName AS strStorageLocationName
					FROM tblCTContractDetail CD
					JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
					WHERE CD.intContractDetailId = CASE 
							WHEN LD.intPurchaseSale = 1
								THEN LD.intPContractDetailId
							ELSE LD.intSContractDetailId
							END
					)
				,strStorageLocationName = (
					SELECT SL.strName AS strStorageLocationName
					FROM tblCTContractDetail CD
					JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
					WHERE CD.intContractDetailId = CASE 
							WHEN LD.intPurchaseSale = 1
								THEN LD.intPContractDetailId
							ELSE LD.intSContractDetailId
							END
					)
				,LD.strLoadNumber
				,LD.dblQuantity
				,LD.strItemUOM
				,LD.dblGross
				,LD.dblNet
				,LD.strWeightItemUOM
				,Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,'C' AS strDocumentCategory
				,'001' AS strRefDataInfo
				,0 AS strSeq
				,LD.strLoadNumber
				,CD.strERPPONumber
				,CD.strERPItemNumber
				,CD.strERPBatchNumber
				,D.strExternalShipmentItemNumber
				,D.strExternalBatchNo
				,'QUA' AS strChangeType
				,@strRowState AS strRowState
				,C.strCommodityCode
			FROM vyuLGLoadDetailView LD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
					WHEN LD.intPurchaseSale = 1
						THEN LD.intPContractDetailId
					ELSE LD.intSContractDetailId
					END
			JOIN tblLGLoadDetail D ON D.intLoadDetailId = LD.intLoadDetailId
			JOIN tblICCommodity C ON C.intCommodityId = CASE 
					WHEN LD.intPurchaseSale = 1
						THEN LD.intPCommodityId
					ELSE LD.intSCommodityId
					END
			LEFT JOIN tblLGLoad L ON L.intLoadId = D.intLoadId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId AND D.intPContractDetailId = LSID.intPContractDetailId
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
			ORDER BY LC.intLoadContainerId
		END
	END

	IF (@intShipmentType = 1 AND @dtmCurrentETAPOD IS NOT NULL AND @strRowState <> 'Delete')
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblLGETATracking WHERE intLoadId = @intLoadId AND strTrackingType = 'ETA POD')
		BEGIN
			INSERT INTO tblLGETATracking (
				intLoadId
				,strTrackingType
				,dtmETAPOD
				,strETAPODReasonCode
				,dtmModifiedOn
				,intConcurrencyId
				)
			SELECT @intLoadId
				,'ETA POD'
				,@dtmCurrentETAPOD
				,@strETAPODReasonCode
				,GETDATE()
				,1
		END
		ELSE
		BEGIN
			SELECT TOP 1 @dtmMaxETAPOD = dtmETAPOD
			FROM tblLGETATracking
			WHERE intLoadId = @intLoadId AND strTrackingType = 'ETA POD'
			ORDER BY intETATrackingId DESC

			IF (@dtmMaxETAPOD <> @dtmCurrentETAPOD)
			BEGIN
				INSERT INTO tblLGETATracking (
					intLoadId
					,strTrackingType
					,dtmETAPOD
					,strETAPODReasonCode
					,dtmModifiedOn
					,intConcurrencyId
					)
				SELECT @intLoadId
					,'ETA POD'
					,@dtmCurrentETAPOD
					,@strETAPODReasonCode
					,GETDATE()
					,1
			END
		END
	END

	IF (@intShipmentType = 1 AND @dtmCurrentETSPOL IS NOT NULL AND @strRowState <> 'Delete')
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblLGETATracking WHERE intLoadId = @intLoadId AND strTrackingType = 'ETS POL')
		BEGIN
			INSERT INTO tblLGETATracking (
				 intLoadId
				,strTrackingType
				,dtmETSPOL
				,strETSPOLReasonCode
				,dtmModifiedOn
				,intConcurrencyId
				)
			SELECT @intLoadId
				,'ETS POL'
				,@dtmCurrentETSPOL
				,@strETSPOLReasonCode
				,GETDATE()
				,1
		END
		ELSE
		BEGIN
			SELECT TOP 1 @dtmMaxETSPOL = dtmETSPOL
			FROM tblLGETATracking
			WHERE intLoadId = @intLoadId AND strTrackingType = 'ETS POL'
			ORDER BY intETATrackingId DESC

			IF (@dtmMaxETSPOL <> @dtmCurrentETSPOL)
			BEGIN
				INSERT INTO tblLGETATracking (
					intLoadId
					,strTrackingType
					,dtmETSPOL
					,strETSPOLReasonCode
					,dtmModifiedOn
					,intConcurrencyId
					)
				SELECT @intLoadId
					,'ETS POL'
					,@dtmCurrentETSPOL
					,@strETSPOLReasonCode					
					,GETDATE()
					,1
			END
		END
	END


	IF (ISNULL(@ysnPOETAFeedToERP,0) = 1)
	BEGIN
		IF (@intShipmentType = 2 AND @dtmCurrentETAPOD IS NOT NULL AND @strRowState <> 'Delete')
		BEGIN
			SELECT @intMinLoadDetailRecordId  = MIN(intDetailRecordId) FROM @tblLoadDetail

			IF (ISNULL(@intMinLoadDetailRecordId,0)>0)
			BEGIN
				SET @intLoadDetailId = NULL
				SET @intContractDetailId = NULL
				SET @intContractHeaderId = NULL
				SET @dtmPlannedAvailabilityDate = NULL
				SET @intApprovedById = NULL

				SELECT @intLoadDetailId = intLoadDetailId,
						@intContractDetailId = intContractDetailId,
						@intContractHeaderId = intContractHeaderId,
						@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate
				FROM @tblLoadDetail WHERE intDetailRecordId = @intMinLoadDetailRecordId

				SELECT TOP 1 @intApprovedById = intApprovedById
				FROM tblCTApprovedContract
				WHERE intContractDetailId = @intContractDetailId
				ORDER BY 1 DESC

				SELECT @dtmCurrentPlannedAvailabilityDate = dtmPlannedAvailabilityDate
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intContractDetailId

				UPDATE tblLGLoad SET dtmPlannedAvailabilityDate = @dtmCurrentETAPOD WHERE intLoadId = @intLoadId

				IF NOT EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadShippingInstructionId = @intLoadId)
				BEGIN
					IF ((@dtmCurrentETAPOD IS NOT NULL) AND (ISNULL(@dtmCurrentETAPOD,'') <> ISNULL(@dtmCurrentPlannedAvailabilityDate,'')))
					BEGIN
						UPDATE tblCTContractDetail SET dtmPlannedAvailabilityDate = @dtmCurrentETAPOD  WHERE intContractDetailId = @intContractDetailId 

						EXEC uspCTContractApproved @intContractHeaderId = @intContractHeaderId,
													@intApprovedById =  @intApprovedById, 
													@intContractDetailId = @intContractDetailId
					END
				END

				SELECT @intMinLoadDetailRecordId = MIN(intDetailRecordId)
				FROM @tblLoadDetail
				WHERE intDetailRecordId > @intMinLoadDetailRecordId
			END
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