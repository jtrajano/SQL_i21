CREATE PROCEDURE uspIPSetReceiptLotStatus @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@strError NVARCHAR(MAX) = ''
	DECLARE @tblIPInvPostedReceipt TABLE (intPostedReceiptId INT)
	DECLARE @intPostedReceiptId INT
		,@intInventoryReceiptId INT
		,@intUserId INT
		,@ysnPosted BIT
		,@strReceiptType NVARCHAR(50)
	DECLARE @tblICInventoryReceiptItem TABLE (intInventoryReceiptItemId INT)
	DECLARE @intInventoryReceiptItemId INT
		,@strContractNumber NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strCommodityCode NVARCHAR(50)
		,@intContainerId INT
		,@intSampleStatusId INT
	DECLARE @LotData TABLE (
		intSeqNo INT IDENTITY(1, 1)
		,intLotId INT
		,strLotNumber NVARCHAR(50)
		,intItemId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
		,intLotStatusId INT
		)
	DECLARE @intSeqNo INT
		,@intLotId INT
		,@strLotNumber NVARCHAR(50)
		,@intItemId INT
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intCurrentLotStatusId INT
		,@intLotStatusId INT

	DELETE
	FROM @tblIPInvPostedReceipt

	INSERT INTO @tblIPInvPostedReceipt (intPostedReceiptId)
	SELECT intPostedReceiptId
	FROM tblIPInvPostedReceipt
	WHERE intStatusId IS NULL

	IF NOT EXISTS (
			SELECT 1
			FROM @tblIPInvPostedReceipt
			)
	BEGIN
		RETURN
	END

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + LTRIM(ISNULL(intPostedReceiptId, '')) + ', '
	FROM @tblIPInvPostedReceipt

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @intPostedReceiptId = MIN(intPostedReceiptId)
	FROM @tblIPInvPostedReceipt

	WHILE (@intPostedReceiptId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intInventoryReceiptId = NULL
				,@intUserId = NULL
				,@ysnPosted = NULL

			SELECT @intInventoryReceiptId = intInventoryReceiptId
				,@intUserId = intUserId
			FROM dbo.tblIPInvPostedReceipt
			WHERE intPostedReceiptId = @intPostedReceiptId

			SELECT @strReceiptType = R.strReceiptType
				,@ysnPosted = ysnPosted
			FROM dbo.tblICInventoryReceipt R
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF @strReceiptType <> 'Purchase Contract'
			BEGIN
				RAISERROR (
						'Invalid Receipt Type. '
						,16
						,1
						)
			END

			IF ISNULL(@ysnPosted, 0) = 0
			BEGIN
				RAISERROR (
						'Receipt is not Posted. '
						,16
						,1
						)
			END

			DELETE
			FROM @tblICInventoryReceiptItem

			INSERT INTO @tblICInventoryReceiptItem (intInventoryReceiptItemId)
			SELECT RI.intInventoryReceiptItemId
			FROM tblICInventoryReceiptItem RI
			WHERE RI.intInventoryReceiptId = @intInventoryReceiptId

			SELECT @intInventoryReceiptItemId = MIN(intInventoryReceiptItemId)
			FROM @tblICInventoryReceiptItem

			WHILE @intInventoryReceiptItemId IS NOT NULL
			BEGIN
				SELECT @strContractNumber = NULL
					,@strContainerNumber = NULL
					,@strCommodityCode = NULL
					,@intContainerId = NULL
					,@intSampleStatusId = NULL
					,@strError = ''
					,@intSeqNo = NULL
					,@intLotStatusId = NULL

				SELECT @strContractNumber = ISNULL(CH.strContractNumber, '')
					,@strContainerNumber = ISNULL(LC.strContainerNumber, '')
					,@strCommodityCode = C.strCommodityCode
					,@intContainerId = RI.intContainerId
				FROM tblICInventoryReceiptItem RI
				JOIN tblICItem I ON I.intItemId = RI.intItemId
				LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intContractDetailId
					AND RI.intInventoryReceiptItemId = @intInventoryReceiptItemId
				LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				LEFT JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
				LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = RI.intContainerId
				WHERE RI.intInventoryReceiptItemId = @intInventoryReceiptItemId

				IF ISNULL(@strContractNumber, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Contract is not available. '
				END

				IF UPPER(@strCommodityCode) <> 'COFFEE'
				BEGIN
					SELECT @strError = @strError + 'Commodity is not Coffee. '
				END

				IF ISNULL(@strContainerNumber, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Container is not available. '
				END

				IF @strError <> ''
				BEGIN
					UPDATE tblIPInvPostedReceipt
					SET intStatusId = 1
						,strMessage = @strError
					WHERE intPostedReceiptId = @intPostedReceiptId

					GOTO NextItemRec
				END

				SELECT TOP 1 @intSampleStatusId = S.intSampleStatusId
					,@intLotStatusId = ISNULL(ST.intApprovalLotStatusId, 1)
				FROM tblQMSample S
				JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				WHERE S.strContainerNumber = @strContainerNumber
				ORDER BY S.intSampleId DESC

				--SELECT TOP 1 @intSampleStatusId = S.intSampleStatusId
				--,@intLotStatusId = ISNULL(ST.intApprovalLotStatusId, 1)
				--FROM tblQMSample S
				--JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				--WHERE S.intLoadContainerId = @intContainerId
				--ORDER BY S.intSampleId DESC

				IF @intSampleStatusId <> 3
				BEGIN
					SELECT @strError = 'Approved Sample is not available for receipt container "' + @strContainerNumber + '". '

					UPDATE tblIPInvPostedReceipt
					SET intStatusId = 1
						,strMessage = @strError
					WHERE intPostedReceiptId = @intPostedReceiptId

					GOTO NextItemRec
				END

				DELETE
				FROM @LotData

				INSERT INTO @LotData (
					intLotId
					,strLotNumber
					,intItemId
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,intLotStatusId
					)
				SELECT L.intLotId
					,L.strLotNumber
					,L.intItemId
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.intLotStatusId
				FROM tblICLot L
				JOIN tblICInventoryReceiptItemLot RIL ON RIL.intLotId = L.intLotId
					AND RIL.intInventoryReceiptItemId = @intInventoryReceiptItemId

				SELECT @intSeqNo = MIN(intSeqNo)
				FROM @LotData

				WHILE (@intSeqNo > 0)
				BEGIN
					SELECT @intLotId = NULL
						,@strLotNumber = NULL
						,@intItemId = NULL
						,@intLocationId = NULL
						,@intSubLocationId = NULL
						,@intStorageLocationId = NULL
						,@intCurrentLotStatusId = NULL

					SELECT @intLotId = intLotId
						,@strLotNumber = strLotNumber
						,@intItemId = intItemId
						,@intLocationId = intLocationId
						,@intSubLocationId = intSubLocationId
						,@intStorageLocationId = intStorageLocationId
						,@intCurrentLotStatusId = intLotStatusId
					FROM @LotData
					WHERE intSeqNo = @intSeqNo

					IF @intCurrentLotStatusId <> @intLotStatusId
						AND ISNULL(@intLotStatusId, 0) <> 0
					BEGIN
						EXEC uspMFSetLotStatus @intLotId = @intLotId
							,@intNewLotStatusId = @intLotStatusId
							,@intUserId = @intUserId
					END

					SELECT @intSeqNo = MIN(intSeqNo)
					FROM @LotData
					WHERE intSeqNo > @intSeqNo
				END

				UPDATE tblIPInvPostedReceipt
				SET intStatusId = 2
					,strMessage = 'Success'
				WHERE intPostedReceiptId = @intPostedReceiptId

				NextItemRec:

				SELECT @intInventoryReceiptItemId = MIN(intInventoryReceiptItemId)
				FROM @tblICInventoryReceiptItem
				WHERE intInventoryReceiptItemId > @intInventoryReceiptItemId
			END
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			UPDATE tblIPInvPostedReceipt
			SET intStatusId = 1
				,strMessage = @ErrMsg
			WHERE intPostedReceiptId = @intPostedReceiptId
		END CATCH

		SELECT @intPostedReceiptId = MIN(intPostedReceiptId)
		FROM @tblIPInvPostedReceipt
		WHERE intPostedReceiptId > @intPostedReceiptId
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
