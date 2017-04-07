CREATE PROCEDURE uspLGLoadContractSlice 
	@intContractHeaderId INT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(MAX)
	DECLARE @intLoadId INT 
	DECLARE @intParentContractDetailId INT
	DECLARE @dblOrgContractDetailQty NUMERIC(18,6)
	DECLARE @intOrgContractDetailQtyUOM INT
	DECLARE @intOrgLoadId INT
	DECLARE @intOrgLoadIDetaild INT
	DECLARE @dblOrgLoadDetailQty NUMERIC(18,6)
	DECLARE @intOrgLoadDetailItemUOM INT
	DECLARE @intOrgLoadDetailWeightUOM INT
	DECLARE @intMinLoadRecordId INT
	DECLARE @intCRowNo INT
	DECLARE @intCContractDetailId INT
	DECLARE @intCParentDetailId INT
	DECLARE @dblCQuantity NUMERIC(18, 6)
	DECLARE @intCItemUOMId INT
	DECLARE @intUserId INT
	DECLARE @intLoadStgId INT
	DECLARE @strRowState NVARCHAR(100)
	DECLARE @ContractSliceDetail TABLE (
		 intCRowNo INT IDENTITY(1, 1)
		,intCContractDetailId INT
		,intCParentDetailId INT
		,dblCQuantity NUMERIC(18, 6)
		,intCItemUOMId INT
		)
	DECLARE @ParentLoad TABLE (
		intLoadRecordId INT IDENTITY(1,1)
	   ,intLoadId INT
	   ,strLoadNumber NVARCHAR(100)
	   ,intLoadDetailId INT
	   ,dblLoadDetailQty NUMERIC(18,6)
	   ,intItemUOMId INT
	   ,intWeightUOMId INT)

	-- Only sliced. ie., new contract sequence records only
	INSERT INTO @ContractSliceDetail
	SELECT intContractDetailId
		  ,intParentDetailId
		  ,dblQuantity
		  ,intItemUOMId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
		AND ysnSlice = 1

	IF OBJECT_ID('tempdb.dbo.#ContractToUpdateContainerCount') IS NOT NULL
		DROP TABLE #ContractToUpdateContainerCount

	SELECT * INTO #ContractToUpdateContainerCount FROM @ContractSliceDetail

	IF ((SELECT COUNT(1) FROM @ContractSliceDetail) < 1)
		RETURN;

	-- Parent contract sequence. ie., from which sequence it sliced
	SELECT TOP 1 @intParentContractDetailId = intCParentDetailId FROM @ContractSliceDetail

	IF EXISTS (SELECT 1
			   FROM tblLGLoad L
			   JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			   WHERE LD.intPContractDetailId = @intParentContractDetailId
					AND L.intShipmentType = 1)
	BEGIN
		RAISERROR ('Shipment exists for the contract sequence. Cannot proceed.',16,1)
	END

	SELECT @strRowState = 'Modified'
	SELECT @intUserId = intLastModifiedById
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intParentContractDetailId

	-- Parent contract sequence Load
	INSERT INTO @ParentLoad 
	SELECT L.intLoadId
		,L.strLoadNumber
		,LD.intLoadDetailId
		,LD.dblQuantity
		,LD.intItemUOMId
		,LD.intWeightItemUOMId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE CASE 
			WHEN L.intPurchaseSale = 1
				THEN LD.intPContractDetailId
			ELSE LD.intSContractDetailId
			END = @intParentContractDetailId AND intShipmentType = 2


	SELECT @intMinLoadRecordId = MIN(intLoadRecordId) FROM @ParentLoad 

	WHILE (@intMinLoadRecordId > 0)
	BEGIN
		SET @intOrgLoadId = NULL
		SET @intOrgLoadIDetaild = NULL
		SET @dblOrgLoadDetailQty = NULL
		SET @dblOrgContractDetailQty = NULL
		SET @intOrgContractDetailQtyUOM = NULL

		SELECT @intOrgLoadId = intLoadId
			  ,@intOrgLoadIDetaild= intLoadDetailId
			  ,@dblOrgLoadDetailQty = dblLoadDetailQty
			  ,@intOrgLoadDetailItemUOM = intItemUOMId
			  ,@intOrgLoadDetailWeightUOM = intWeightUOMId
		FROM @ParentLoad
		WHERE intLoadRecordId = @intMinLoadRecordId

		SELECT @dblOrgContractDetailQty = dblQuantity
			  ,@intOrgContractDetailQtyUOM = intUnitMeasureId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intParentContractDetailId

		IF (@dblOrgLoadDetailQty > @dblOrgContractDetailQty)
		BEGIN
			UPDATE tblLGLoadDetail 
			SET dblQuantity = @dblOrgContractDetailQty
			   ,dblNet = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intWeightItemUOMId,@dblOrgContractDetailQty)
			   ,dblGross = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intWeightItemUOMId,@dblOrgContractDetailQty)
			WHERE intLoadDetailId = @intOrgLoadIDetaild

			UPDATE L
			SET intNumberOfContainers = CEILING(LD.dblNet / ISNULL(CTCQ.dblBulkQuantity,LD.dblNet))
			FROM tblCTContractDetail CD
			JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			JOIN tblICItem I ON I.intItemId = CD.intItemId
			LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
			LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CA.intCommodityAttributeId = CTCQ.intCommodityAttributeId
				AND CTCQ.intContainerTypeId = CT.intContainerTypeId
			WHERE LD.intLoadDetailId = @intOrgLoadIDetaild

			IF EXISTS(SELECT 1 FROM tblLGLoadStg WHERE ISNULL(strFeedStatus,'') = '' AND intLoadId = @intOrgLoadId AND strRowState = 'Added')
			BEGIN
				DELETE FROM tblLGLoadStg WHERE intLoadId = @intOrgLoadId AND strRowState = 'Added'
				SET @strRowState = 'Added'
			END

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
			WHERE intLoadId = @intOrgLoadId

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
				,@intOrgLoadId
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
			WHERE LD.intLoadId = @intOrgLoadId

			SET @dblOrgLoadDetailQty = (@dblOrgLoadDetailQty - @dblOrgContractDetailQty)
			
			-- Create contract sequence samples for the remaining representing qty
			SELECT @intCRowNo = MIN(intCRowNo)
			FROM @ContractSliceDetail

			WHILE (@intCRowNo > 0 AND @dblOrgLoadDetailQty > 0)
			BEGIN
				DECLARE @dblNewLoadDetailQty NUMERIC(18,6)

				SELECT @intCRowNo = intCRowNo
					,@intCContractDetailId = intCContractDetailId
					,@dblCQuantity = dblCQuantity
					,@intCItemUOMId = intCItemUOMId
				FROM @ContractSliceDetail
				WHERE intCRowNo = @intCRowNo

				IF (@dblOrgLoadDetailQty > @dblCQuantity)
					SET @dblNewLoadDetailQty = @dblCQuantity
				ELSE
					SET @dblNewLoadDetailQty = @dblOrgLoadDetailQty

				-- Create new sample for seq @intCContractDetailId, @dblNewRepresentingQty, @intNewRepresentingUOMId. Take other values from existing sample @intSSampleId
				EXEC uspLGLoadContractCopy @intOldLoadDetailId = @intOrgLoadIDetaild
										  ,@intNewContractDetailId = @intCContractDetailId
										  ,@dblNewLoadDetailQuantity = @dblNewLoadDetailQty
										  ,@intNewLoadDetailItemUOMId = @intOrgLoadDetailItemUOM
										  ,@intUserId = @intUserId

				SET @dblOrgLoadDetailQty = (@dblOrgLoadDetailQty - @dblNewLoadDetailQty)

				UPDATE L
				SET intNumberOfContainers = CEILING(LD.dblNet / ISNULL(CTCQ.dblBulkQuantity,LD.dblNet))
				FROM tblCTContractDetail CD
				JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
				JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
				JOIN tblICItem I ON I.intItemId = CD.intItemId
				LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
				LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CA.intCommodityAttributeId = CTCQ.intCommodityAttributeId
					AND CTCQ.intContainerTypeId = CT.intContainerTypeId
				WHERE CD.intContractDetailId = @intCContractDetailId
							
				SELECT @intCRowNo = MIN(intCRowNo)
				FROM @ContractSliceDetail
				WHERE intCRowNo > @intCRowNo
			END
		END

		SELECT @intMinLoadRecordId = MIN(intLoadRecordId)
		FROM @ParentLoad
		WHERE intLoadRecordId > @intMinLoadRecordId

	END

	UPDATE L
	SET intNumberOfContainers = CEILING(LD.dblNet / ISNULL(CTCQ.dblBulkQuantity, LD.dblNet))
	FROM tblCTContractDetail CD
	LEFT JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
	LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CA.intCommodityAttributeId = CTCQ.intCommodityAttributeId
		AND CTCQ.intContainerTypeId = CT.intContainerTypeId
	WHERE CD.intContractHeaderId = @intContractHeaderId

	UPDATE CD
	SET intNumberOfContainers = CEILING(LD.dblNet / ISNULL(CTCQ.dblBulkQuantity, LD.dblNet))
	FROM tblCTContractDetail CD
	LEFT JOIN tblLGLoadDetail LD ON CD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
	LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CA.intCommodityAttributeId = CTCQ.intCommodityAttributeId
		AND CTCQ.intContainerTypeId = CT.intContainerTypeId
	WHERE CD.intContractHeaderId = @intContractHeaderId

END TRY
	
BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH