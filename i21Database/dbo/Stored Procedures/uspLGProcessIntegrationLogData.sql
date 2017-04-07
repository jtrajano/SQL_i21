CREATE PROCEDURE uspLGProcessIntegrationLogData
AS
BEGIN TRY
	DECLARE @intLoadId INT
	DECLARE @intMinLoadId INT
	DECLARE @intMinLoadLogId INT
	DECLARE @intMaxLoadLogId INT
	DECLARE @intMinLoadRecordId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intMinLoadDetailId INT
	DECLARE @intMinLoadDetailLogId INT
	DECLARE @intMaxLoadDetailLogId INT
	DECLARE @intMinLoadDetailRecordId INT
	DECLARE @intLoadContainerId INT
	DECLARE @intMinLoadContainerId INT
	DECLARE @intMinLoadContainerLogId INT
	DECLARE @intMaxLoadContainerLogId INT
	DECLARE @intMinLoadContainerRecordId INT
	DECLARE @intLoadStdId INT
	DECLARE @strShipmentType NVARCHAR(MAX)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intLastFeedId INT
	DECLARE @strRowState NVARCHAR(MAX)
	DECLARE @strModifiedColumns NVARCHAR(MAX)
	DECLARE @strModifiedDetailColumns NVARCHAR(MAX)
	DECLARE @strModifiedContainerColumns NVARCHAR(MAX)
	DECLARE @ysnContainerAddedAlready BIT = 0
	DECLARE @ysnPosted BIT = 0
	DECLARE @intShipmentStatus INT

	DECLARE @tblLoadContainerRecord TABLE (
		intLoadContainerRecordId INT Identity(1, 1)
		,intLoadContainerLogId INT
		,intLoadContainerId INT
		)
	DECLARE @tblLoadDetailRecord TABLE (
		intLoadDetailRecordId INT Identity(1, 1)
		,intLoadDetailLogId INT
		,intLoadDetailId INT
		)
	DECLARE @tblLoadRecord TABLE (
		intLoadRecordId INT Identity(1, 1)
		,intLoadLogId INT
		,intLoadId INT
		)

	INSERT INTO @tblLoadContainerRecord
	SELECT intLoadContainerLogId
		,intLoadContainerId
	FROM tblLGLoadContainerLog
	ORDER BY intLoadContainerId DESC
		,intLoadContainerLogId

	INSERT INTO @tblLoadDetailRecord
	SELECT intLGLoadDetailLogId
		,intLoadDetailId
	FROM tblLGLoadDetailLog
	ORDER BY intLoadDetailId DESC
		,intLGLoadDetailLogId

	INSERT INTO @tblLoadRecord
	SELECT intLoadLogId
		,intLoadId
	FROM tblLGLoadLog

	SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
	FROM @tblLoadRecord

	WHILE ISNULL(@intMinLoadRecordId, 0) <> 0
	BEGIN
		SELECT @intLoadId = intLoadId
		FROM @tblLoadRecord
		WHERE intLoadRecordId = @intMinLoadRecordId

		SELECT @ysnPosted = ysnPosted,
			   @intShipmentStatus = intShipmentStatus
		FROM tblLGLoad
		WHERE intLoadId = @intLoadId

		IF (ISNULL(@intShipmentStatus,0) = 4)
		BEGIN
			DELETE FROM tblLGLoadContainerLog
			DELETE FROM tblLGLoadDetailLog
			DELETE FROM tblLGLoadLog

			RETURN;
		END

		SELECT @intMinLoadLogId = MIN(intLoadLogId)
		FROM @tblLoadRecord
		WHERE intLoadId = @intLoadId

		SELECT @intMaxLoadLogId = MAX(intLoadLogId)
		FROM @tblLoadRecord
		WHERE intLoadId = @intLoadId

		SELECT TOP 1 @intLastFeedId = intLoadStgId
		FROM tblLGLoadStg
		WHERE intLoadId = ISNULL(@intLoadId, 0)
		ORDER BY intLoadStgId DESC

		EXEC uspCTCompareRecords @strTblName = 'tblLGLoadLog'
			,@intCompareWith = @intMinLoadLogId
			,@intCompareTo = @intMaxLoadLogId
			,@strColumnsToIgnore = NULL
			,@strModifiedColumns = @strModifiedColumns OUTPUT

		SELECT @strShipmentType = CASE L.intShipmentType
				WHEN 1
					THEN 'Shipment'
				WHEN 2
					THEN 'Shipping Instructions'
				WHEN 3
					THEN 'Vessel Nomination'
				ELSE ''
				END COLLATE Latin1_General_CI_AS
		FROM tblLGLoad L
		WHERE intLoadId = @intLoadId

		IF EXISTS (
				SELECT 1
				FROM tblLGLoadStg
				WHERE intLoadStgId = @intLastFeedId
					AND strRowState = 'Modified'
					AND ISNULL(strFeedStatus, '') IN ('')
				)
		BEGIN
			DELETE
			FROM tblLGLoadStg
			WHERE intLoadStgId = @intLastFeedId

			SELECT TOP 1 @intLastFeedId = intLoadStgId
			FROM tblLGLoadStg
			WHERE intLoadId = ISNULL(@intLoadId, 0)
			ORDER BY intLoadStgId DESC
		END

		SELECT @strRowState = 'Modified'

		IF EXISTS (
				SELECT 1
				FROM tblLGLoadStg
				WHERE intLoadStgId = @intLastFeedId
					AND strRowState = 'Added'
					AND ISNULL(strMessage, 'Success') <> 'Success'
				)
		BEGIN
			SELECT @strRowState = 'Added'
		END

		DELETE
		FROM @tblLoadRecord
		WHERE intLoadId = @intLoadId

		SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
		FROM @tblLoadRecord
		WHERE intLoadRecordId > @intMinLoadRecordId
	END

	SELECT @intMinLoadDetailRecordId = MIN(intLoadDetailRecordId)
	FROM @tblLoadDetailRecord

	WHILE ISNULL(@intMinLoadDetailRecordId, 0) <> 0
	BEGIN
		SELECT @intLoadDetailId = intLoadDetailId
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailRecordId = @intMinLoadDetailRecordId

		SELECT @intMinLoadDetailLogId = MIN(intLoadDetailLogId)
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intMaxLoadDetailLogId = MAX(intLoadDetailLogId)
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intLoadStdId = MAX(LS.intLoadStgId)
		FROM tblLGLoadStg LS
		JOIN tblLGLoadDetail LD ON LD.intLoadId = LS.intLoadId
		JOIN @tblLoadDetailRecord LDR ON LDR.intLoadDetailId = LD.intLoadDetailId
			AND LDR.intLoadDetailId = @intLoadDetailId

		EXEC uspCTCompareRecords @strTblName = 'tblLGLoadLog'
			,@intCompareWith = @intMinLoadDetailLogId
			,@intCompareTo = @intMaxLoadDetailLogId
			,@strColumnsToIgnore = 'intLoadLogId,strRowState,intRowNumber'
			,@strModifiedColumns = @strModifiedDetailColumns OUTPUT

		DELETE
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailId = @intLoadDetailId

		SELECT @intMinLoadDetailRecordId = MIN(intLoadDetailRecordId)
		FROM @tblLoadDetailRecord
		WHERE intLoadDetailRecordId > @intMinLoadDetailRecordId
	END

	SELECT @intMinLoadContainerRecordId = MIN(intLoadContainerRecordId)
	FROM @tblLoadContainerRecord

	WHILE ISNULL(@intMinLoadContainerRecordId, 0) <> 0
	BEGIN
		SELECT @intLoadContainerId = intLoadContainerId
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerRecordId = @intMinLoadContainerRecordId

		SELECT @intMinLoadContainerLogId = MIN(intLoadContainerLogId)
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerId = @intLoadContainerId

		SELECT @intMaxLoadContainerLogId = MAX(intLoadContainerLogId)
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerId = @intLoadContainerId

		SELECT @intLoadStdId = MAX(LS.intLoadStgId)
		FROM tblLGLoadStg LS
		JOIN tblLGLoadContainer LC ON LC.intLoadId = LS.intLoadId
		JOIN @tblLoadContainerRecord LCR ON LCR.intLoadContainerId = LC.intLoadContainerId
			AND LCR.intLoadContainerId = @intLoadContainerId

		EXEC uspCTCompareRecords @strTblName = 'tblLGLoadContainerLog'
			,@intCompareWith = @intMinLoadContainerLogId
			,@intCompareTo = @intMaxLoadContainerLogId
			,@strColumnsToIgnore = 'intLoadLogId,strRowState'
			,@strModifiedColumns = @strModifiedContainerColumns OUTPUT

		IF (@intMaxLoadContainerLogId = @intMinLoadContainerLogId) AND NOT EXISTS(SELECT 1 FROM tblLGLoadContainerStg WHERE intLoadId = @intLoadId)
		BEGIN
			GOTO INSERTDATE
		END

		DELETE
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerId = @intLoadContainerId

        IF ISNULL(@strModifiedContainerColumns,'')<> ''
                BREAK;

		SELECT @intMinLoadContainerRecordId = MIN(intLoadContainerRecordId)
		FROM @tblLoadContainerRecord
		WHERE intLoadContainerRecordId > @intMinLoadContainerRecordId
	END

	IF (
			LTRIM(RTRIM(ISNULL(@strModifiedColumns, ''))) <> ''
			OR LTRIM(RTRIM(ISNULL(@strModifiedDetailColumns, ''))) <> ''
			OR LTRIM(RTRIM(ISNULL(@strModifiedContainerColumns, ''))) <> ''
			)
INSERTDATE:
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
		LEFT JOIN tblAPVendor V ON V.intEntityVendorId = E.intEntityId
		WHERE intLoadId = @intLoadId

		SELECT @intLoadStdId = SCOPE_IDENTITY()

		INSERT INTO tblLGLoadDetailStg (
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
			,strCommodityCode
			)
		SELECT @intLoadStdId
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
			,'Modified' AS strRowState
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
		LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId
			AND D.intPContractDetailId = LSID.intPContractDetailId
		WHERE D.intLoadId = @intLoadId

		IF (@strShipmentType = 'Shipment' AND ISNULL(@ysnContainerAddedAlready,0) = 0)
		BEGIN
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
			SELECT *
			FROM (
				SELECT @intLoadStdId intLoadStdId
					,@intLoadId intLoadId
					,LC.intLoadContainerId
					,LC.strContainerNumber
					,CASE 
						WHEN CT.strContainerType LIKE '%20%'
							THEN '000000000010003243'
						WHEN CT.strContainerType LIKE '%40%'
							THEN '000000000010003244'
						ELSE CT.strContainerType
						END strContainerSizeCode
					,'0002' strPackagingMaterialType
					,L.strExternalShipmentNumber
					,ROW_NUMBER() OVER (
						PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
						) AS Seq
					,LC.dblQuantity
					,UM.strUnitMeasure strItemUOM
					,LC.dblNetWt
					,LC.dblGrossWt
					,LUM.strUnitMeasure strWeightUnitMeasure
					,NULL strExternalContainerId
					,CASE 
						WHEN ISNULL(CLSL.strSubLocationName, '') = ''
							THEN LDCLSL.strSubLocationName
						ELSE CLSL.strSubLocationName
						END strSubLocationName
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
					,'Modified' strRowState
					,GETDATE() dtmFeedCreated
				FROM tblLGLoadContainer LC
				JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = LC.intUnitMeasureId
				JOIN tblICUnitMeasure LUM ON LUM.intUnitMeasureId = L.intWeightUnitMeasureId
				LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
				LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
				LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
				LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
				LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
				LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
				LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
				LEFT JOIN tblSMCompanyLocationSubLocation LDCLSL ON LDCLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
				--LEFT JOIN tblLGLoadContainerLog LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId AND LDCL.intLoadLogId = (SELECT MIN(intLoadLogId) FROM tblLGLoadLog)
				WHERE LC.intLoadId = @intLoadId
	
				UNION
	
				SELECT @intLoadStdId
					,@intLoadId
					,intLoadContainerId
					,strContainerNo COLLATE Latin1_General_CI_AS
					,strContainerSizeCode COLLATE Latin1_General_CI_AS
					,'0002' COLLATE Latin1_General_CI_AS
					,strExternalPONumber COLLATE Latin1_General_CI_AS
					,strSeq COLLATE Latin1_General_CI_AS
					,dblContainerQty
					,strContainerUOM COLLATE Latin1_General_CI_AS
					,dblNetWt
					,dblGrossWt
					,strWeightUOM
					,strExternalContainerId
					,strSubLocation
					,strStorageLocation
					,'Delete' Collate Latin1_General_CI_AS
					,GETDATE()
				FROM tblLGLoadContainerLog
				WHERE intLoadId = @intLoadId
					AND intLoadContainerId NOT IN (
						SELECT LC.intLoadContainerId
						FROM tblLGLoadContainer LC
						JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
						JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = LC.intUnitMeasureId
						JOIN tblICUnitMeasure LUM ON LUM.intUnitMeasureId = L.intWeightUnitMeasureId
						LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
						LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
						WHERE LC.intLoadId = @intLoadId
						)
				) tbl
			ORDER BY intLoadContainerId
		END
	END
		
	UPDATE LDCL
	SET strExternalContainerId = LO.strExternalContainerId
	FROM tblLGLoadDetailContainerLink LDCL
	JOIN tblLGLoadContainerLog LO ON LDCL.intLoadContainerId = LO.intLoadContainerId
	WHERE ISNULL(LO.strExternalContainerId,'') <> ''

	UPDATE LDCL
	SET strExternalContainerId = LO.strExternalContainerId
	FROM tblLGLoadContainerStg LDCL
	JOIN tblLGLoadContainerLog LO ON LDCL.intLoadContainerId = LO.intLoadContainerId
	WHERE ISNULL(LO.strExternalContainerId,'') <> '' AND LDCL.intLoadStgId=@intLoadStdId

	DELETE FROM tblLGLoadContainerLog
	DELETE FROM tblLGLoadDetailLog
	DELETE FROM tblLGLoadLog

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg
		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH