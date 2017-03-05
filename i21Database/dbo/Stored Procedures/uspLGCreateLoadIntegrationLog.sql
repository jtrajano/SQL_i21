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
	DECLARE @dtmMaxETAPOD DATETIME
	DECLARE @dtmCurrentETSPOL DATETIME
	DECLARE @dtmMaxETSPOL DATETIME

	SELECT @dtmCurrentETAPOD = dtmETAPOD,
		   @dtmCurrentETSPOL = dtmETSPOL
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF EXISTS(SELECT 1 FROM tblLGLoadStg WHERE ISNULL(strFeedStatus,'') = '' AND intLoadId = @intLoadId AND strRowState = 'Added')
	BEGIN
		DELETE FROM tblLGLoadStg WHERE intLoadId = @intLoadId AND strRowState = 'Added'
		SET @strRowState = 'Added'
	END

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
		LEFT JOIN tblAPVendor V ON V.intEntityVendorId = E.intEntityId
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

		IF (@intShipmentType = 1)
		BEGIN
			INSERT INTO tblLGLoadContainerStg
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
				,@strRowState
				,GETDATE()
			FROM vyuLGLoadContainerView LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			WHERE LC.intLoadId = @intLoadId
		END
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
		LEFT JOIN tblAPVendor V ON V.intEntityVendorId = E.intEntityId
		WHERE intLoadId = @intLoadId

		SELECT @intLoadStgId = SCOPE_IDENTITY()

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

		IF (@intShipmentType = 1)
		BEGIN
			INSERT INTO tblLGLoadContainerLog
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
				,L.strExternalLoadNumber
				,ROW_NUMBER() OVER (
					PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
					) AS Seq
				,LC.dblQuantity
				,LC.strItemUOM
				,LC.dblNetWt
				,LC.dblGrossWt
				,LC.strWeightUnitMeasure
				,@strRowState
			FROM vyuLGLoadContainerView LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			WHERE LC.intLoadId = @intLoadId
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
				,dtmModifiedOn
				,intConcurrencyId
				)
			SELECT @intLoadId
				,'ETA POD'
				,@dtmCurrentETAPOD
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
					,dtmModifiedOn
					,intConcurrencyId
					)
				SELECT @intLoadId
					,'ETA POD'
					,@dtmCurrentETAPOD
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
				,dtmModifiedOn
				,intConcurrencyId
				)
			SELECT @intLoadId
				,'ETS POL'
				,@dtmCurrentETSPOL
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
					,dtmModifiedOn
					,intConcurrencyId
					)
				SELECT @intLoadId
					,'ETS POL'
					,@dtmCurrentETSPOL
					,GETDATE()
					,1
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