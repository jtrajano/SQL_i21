CREATE PROCEDURE uspLGReprocessToLoadStg 
	 @intLoadId INT
	,@strRowState NVARCHAR(100) = NULL
AS
BEGIN TRY
	DECLARE @intLoadStdId INT
	DECLARE @strErrMsg INT

	IF (ISNULL(@strRowState,'Added') = 'Added')
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM tblLGLoadStg WHERE intLoadId = @intLoadId)
		BEGIN
			DELETE
			FROM tblLGLoadStg
			WHERE intLoadId = @intLoadId
		END
	END

	BEGIN TRANSACTION

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
		,NULL --L.strExternalShipmentNumber
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
		,GETDATE()
	FROM vyuLGLoadView L
	LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
	LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
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
		,NULL --D.strExternalShipmentItemNumber
		,NULL --D.strExternalBatchNo
		,'QUA' AS strChangeType
		,@strRowState
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

	INSERT INTO tblLGLoadContainerStg (
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
		,dtmFeedCreated
		)
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
		,@strRowState
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
	WHERE LC.intLoadId = @intLoadId

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')  
END CATCH