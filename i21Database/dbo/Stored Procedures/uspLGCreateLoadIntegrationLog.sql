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

	SELECT @dtmCurrentETAPOD = dtmETAPOD
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF (@strRowState = 'Added')
	BEGIN
		INSERT INTO tblLGLoadStg (
			intLoadId
			,strTransactionType
			,strLoadNumber
			,strContractBasis
			,strContractBasisDesc
			,strBillOfLading
			,strShippingLine
			,strExternalDeliveryNumber
			,strDateQualifier
			,dtmScheduledDate
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
			,L.strExternalShipmentNumber
			,'015' AS strDateQualifier
			,L.dtmScheduledDate
			,@strRowState
			,GETDATE()
		FROM vyuLGLoadView L
		WHERE intLoadId = @intLoadId

		SELECT @intLoadStgId = SCOPE_IDENTITY()

		INSERT INTO tblLGLoadDetailStg
		SELECT @intLoadStgId
			,@intLoadId
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
			,Row_NUMBER() OVER (
				PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
				)
			,'C' AS strDocumentCategory
			,'001' AS strRefDataInfo
			,LD.strExternalLoadNumber
			,0 AS strSeq
			,LD.strLoadNumber
			,'QUA' AS strChangeType
			,@strRowState AS strRowState
			,GETDATE()
		FROM vyuLGLoadDetailView LD
		WHERE intLoadId = @intLoadId

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
				,@strRowState
				,GETDATE()
			FROM vyuLGLoadContainerView LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			WHERE LC.intLoadId = @intLoadId
		END
	END
	ELSE 
	BEGIN
		INSERT INTO tblLGLoadLog (
			intLoadId
			,strTransactionType
			,strLoadNumber
			,strContractBasis
			,strContractBasisDesc
			,strBillOfLading
			,strShippingLine
			,strExternalDeliveryNumber
			,strDateQualifier
			,dtmScheduledDate
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
			,L.strExternalShipmentNumber
			,'015' AS strDateQualifier
			,L.dtmScheduledDate
			,@strRowState
		FROM vyuLGLoadView L
		WHERE intLoadId = @intLoadId

		SELECT @intLoadStgId = SCOPE_IDENTITY()

		INSERT INTO tblLGLoadDetailLog
		SELECT @intLoadStgId
			,@intLoadId
			,LD.intLoadDetailId
			,Row_NUMBER() OVER (PARTITION BY LD.intLoadId ORDER BY LD.intLoadId) AS intRowNumber
			,strItemNo
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
			,Row_NUMBER() OVER (PARTITION BY LD.intLoadId ORDER BY LD.intLoadId)
			,'C' AS strDocumentCategory
			,'001' AS strRefDataInfo
			,LD.strExternalLoadNumber
			,0 AS strSeq
			,LD.strLoadNumber
			,'QUA' AS strChangeType
			,@strRowState AS strRowState
		FROM vyuLGLoadDetailView LD
		WHERE intLoadId = @intLoadId

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
				,L.strExternalShipmentNumber
				,ROW_NUMBER() OVER (
					PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
					) AS Seq
				,LC.dblQuantity
				,LC.strItemUOM
				,@strRowState
			FROM vyuLGLoadContainerView LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			WHERE LC.intLoadId = @intLoadId
		END
	END

	IF (@intShipmentType = 1 AND @dtmCurrentETAPOD IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM tblLGETATracking WHERE intLoadId = @intLoadId)
		BEGIN
			INSERT INTO tblLGETATracking (
				intLoadId
				,dtmETAPOD
				,dtmModifiedOn
				,intConcurrencyId
				)
			SELECT @intLoadId
				,@dtmCurrentETAPOD
				,GETDATE()
				,1
		END
		ELSE
		BEGIN
			SELECT TOP 1 @dtmMaxETAPOD = dtmETAPOD
			FROM tblLGETATracking
			WHERE intLoadId = @intLoadId
			ORDER BY 1 DESC

			IF (@dtmMaxETAPOD <> @dtmCurrentETAPOD)
			BEGIN
				INSERT INTO tblLGETATracking (
					intLoadId
					,dtmETAPOD
					,dtmModifiedOn
					,intConcurrencyId
					)
				SELECT @intLoadId
					,@dtmCurrentETAPOD
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