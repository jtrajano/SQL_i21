CREATE PROCEDURE uspIPProcessERPInitialAck
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@strMessage NVARCHAR(MAX)
		,@TrxSequenceNo BIGINT
		,@CompanyLocation NVARCHAR(6)
		,@CreatedDate DATETIME
		,@CreatedBy NVARCHAR(50)
		,@MessageTypeId INT
		,@ERPCONumber NVARCHAR(50)
		,@ERPReferenceNo NVARCHAR(50)
		,@ERPShopOrderNo NVARCHAR(50)
		,@ERPTransferOrderNo NVARCHAR(50)
		,@ERPVoucherNo NVARCHAR(50)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intWorkOrderId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@strContractNo NVARCHAR(50)
		,@intInventoryReceiptId INT
		,@strReceiptNo NVARCHAR(50)
		,@intBillId INT
		,@strVoucherNo NVARCHAR(50)
		,@intInventoryTransferId INT
		,@strTransferNo NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,TrxSequenceNo BIGINT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,MessageTypeId INT
		,ERPCONumber NVARCHAR(50)
		,ERPReferenceNo NVARCHAR(50)
		,ERPShopOrderNo NVARCHAR(50)
		,ERPTransferOrderNo NVARCHAR(50)
		,ERPVoucherNo NVARCHAR(50)
		,StatusId INT
		,StatusText NVARCHAR(2048)
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Initial Ack'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblAcknowledgement

			INSERT INTO @tblAcknowledgement (
				TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,MessageTypeId
				,ERPCONumber
				,ERPReferenceNo
				,ERPShopOrderNo
				,ERPTransferOrderNo
				,ERPVoucherNo
				,StatusId
				,StatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,MessageTypeId
				,ERPCONumber
				,ERPReferenceNo
				,ERPShopOrderNo
				,ERPTransferOrderNo
				,ERPVoucherNo
				,StatusId
				,StatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					,MessageTypeId INT
					,ERPCONumber NVARCHAR(50)
					,ERPReferenceNo NVARCHAR(50)
					,ERPShopOrderNo NVARCHAR(50)
					,ERPTransferOrderNo NVARCHAR(50)
					,ERPVoucherNo NVARCHAR(50)
					,StatusId INT
					,StatusText NVARCHAR(2048)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @TrxSequenceNo = NULL
					,@CompanyLocation = NULL
					,@CreatedDate = NULL
					,@CreatedBy = NULL
					,@MessageTypeId = NULL
					,@ERPCONumber = NULL
					,@ERPReferenceNo = NULL
					,@ERPShopOrderNo = NULL
					,@ERPTransferOrderNo = NULL
					,@ERPVoucherNo = NULL
					,@strWorkOrderNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL

				SELECT @intWorkOrderId = NULL
					,@intContractHeaderId = NULL
					,@intContractDetailId = NULL
					,@strContractNo = NULL
					,@intInventoryReceiptId = NULL
					,@strReceiptNo = NULL
					,@intBillId = NULL
					,@strVoucherNo = NULL
					,@intInventoryTransferId = NULL
					,@strTransferNo = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@MessageTypeId = MessageTypeId
					,@ERPCONumber = ERPCONumber
					,@ERPReferenceNo = ERPReferenceNo
					,@ERPShopOrderNo = ERPShopOrderNo
					,@ERPTransferOrderNo = ERPTransferOrderNo
					,@ERPVoucherNo = ERPVoucherNo
					,@StatusId = StatusId
					,@StatusText = StatusText
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				/*
    Not Processed: NULL  
    In-Progress: -1  
    Internal Error in i21: 1  
    Sent to AX: 2  
    AX 1st Level Failure: 3, AX 1st Level Success: 4  
    AX 2nd Level Failure: 5, AX 2nd Level Success: 6  
*/
				IF @MessageTypeId = 1 -- CO
				BEGIN
					SELECT @intContractDetailId = intContractDetailId
						,@intContractHeaderId = intContractHeaderId
						,@strContractNo = strContractNumber
					FROM tblCTContractFeed
					WHERE intContractFeedId = @TrxSequenceNo

					UPDATE tblCTContractFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
						,strFeedStatus = 'Ack Rcvd'
						,strERPPONumber = @ERPCONumber
					WHERE intContractFeedId = @TrxSequenceNo

					--Update the PO Details in modified sequences
					UPDATE tblCTContractFeed
					SET strERPPONumber = @ERPCONumber
					WHERE intContractDetailId = @intContractDetailId
						AND intStatusId IS NULL

					UPDATE tblCTContractDetail
					SET strERPPONumber = @ERPCONumber
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intContractDetailId = @intContractDetailId

					UPDATE tblCTContractHeader
					SET intConcurrencyId = intConcurrencyId + 1
					WHERE intContractHeaderId = @intContractHeaderId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Initial Ack'
						,'Success'
						,@strContractNo
						,@ERPCONumber
						)
				END
				ELSE IF @MessageTypeId = 2 -- PO
				BEGIN
					UPDATE tblCTContractFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
						,strFeedStatus = 'Ack Rcvd'
					WHERE intContractFeedId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 3 -- Goods Receipt
				BEGIN
					SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
						,@strReceiptNo = strReceiptNumber
					FROM tblIPInvReceiptFeed
					WHERE intReceiptFeedHeaderId = @TrxSequenceNo

					UPDATE tblIPInvReceiptFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
						,strERPTransferOrderNo = @ERPReferenceNo
					WHERE intReceiptFeedHeaderId = @TrxSequenceNo
						AND intStatusId = 2

					--UPDATE tblIPInvReceiptFeed
					--SET strERPTransferOrderNo = @ERPReferenceNo
					--WHERE intInventoryReceiptId = @intInventoryReceiptId
					--	AND ISNULL(intStatusId, 1) = 1
					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Initial Ack'
						,'Success'
						,@strReceiptNo
						,@ERPReferenceNo
						)
				END
				ELSE IF @MessageTypeId = 4 -- Voucher
				BEGIN
					SELECT @intBillId = intBillId
					FROM tblAPBillPreStage
					WHERE intBillPreStageId = @TrxSequenceNo

					SELECT @strVoucherNo = strBillId
					FROM tblAPBill
					WHERE intBillId = @intBillId

					UPDATE tblAPBillPreStage
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
						,strERPVoucherNo = @ERPVoucherNo
					WHERE intBillId = @intBillId
						AND intStatusId = 2

					--Update the ERP Voucher No in UnPost / Repost records
					UPDATE tblAPBillPreStage
					SET strERPVoucherNo = @ERPVoucherNo
					WHERE intBillId = @intBillId

					UPDATE tblAPBill
					SET intConcurrencyId = intConcurrencyId + 1
						,strComment = @ERPVoucherNo
					WHERE intBillId = @intBillId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Initial Ack'
						,'Success'
						,@strVoucherNo
						,@ERPVoucherNo
						)
				END
				ELSE IF @MessageTypeId = 5 -- Transfer Order
				BEGIN
					SELECT @intInventoryTransferId = intInventoryTransferId
						,@strTransferNo = strTransferNo
					FROM tblICInventoryTransfer
					WHERE intInventoryTransferId = @TrxSequenceNo

					UPDATE tblIPInvTransferFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
						,strERPTransferOrderNo = @ERPTransferOrderNo
					WHERE intInventoryTransferId = @intInventoryTransferId
						AND intStatusId = 2

					UPDATE tblIPInvTransferFeed
					SET strERPTransferOrderNo = @ERPTransferOrderNo
					WHERE intInventoryTransferId = @intInventoryTransferId
						AND ISNULL(intStatusId, 1) = 1

					UPDATE tblICInventoryTransfer
					SET intConcurrencyId = intConcurrencyId + 1
						,strERPTransferNo = @ERPTransferOrderNo
					WHERE intInventoryTransferId = @intInventoryTransferId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Initial Ack'
						,'Success'
						,@strTransferNo
						,@ERPTransferOrderNo
						)
				END
				ELSE IF @MessageTypeId = 6 --Production Order
				BEGIN
					SELECT @intWorkOrderId = intWorkOrderId
						,@strWorkOrderNo = strWorkOrderNo
					FROM tblMFWorkOrderPreStage
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					UPDATE tblMFWorkOrderPreStage
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					IF @ERPShopOrderNo IS NOT NULL
					BEGIN
						UPDATE tblMFWorkOrder
						SET strERPOrderNo = @ERPShopOrderNo
							,strReferenceNo = @ERPShopOrderNo
							,intConcurrencyId = intConcurrencyId + 1
						WHERE intWorkOrderId = @intWorkOrderId
					END

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Initial Ack'
						,'Success'
						,@strWorkOrderNo
						,@ERPShopOrderNo
						)
				END
				ELSE IF @MessageTypeId = 7 --Service PO
				BEGIN
					SELECT @intWorkOrderId = intWorkOrderId
						,@strWorkOrderNo = strWorkOrderNo
						,@ERPShopOrderNo = strERPOrderNo
					FROM tblMFWorkOrderPreStage
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					UPDATE tblMFWorkOrderPreStage
					SET intServiceOrderStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Initial Ack'
						,'Success'
						,@strWorkOrderNo
						,@ERPShopOrderNo
						)
				END
				ELSE IF @MessageTypeId = 8 --Production and Consumption
				BEGIN
					UPDATE tblMFProductionPreStage
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intProductionPreStageId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 10 --Lot Merge
				BEGIN
					UPDATE tblIPLotMergeFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intLotMergeFeedId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 11 --Lot Split
				BEGIN
					UPDATE tblIPLotSplitFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intLotSplitFeedId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 13 --Lot Property Adj
				BEGIN
					UPDATE tblIPLotPropertyFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intLotPropertyFeedId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 14 -- Commitment Pricing
				BEGIN
					UPDATE tblMFCommitmentPricingStage
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intCommitmentPricingStageId = @TrxSequenceNo
				END

				SELECT @intMinRowNo = MIN(intRowNo)
				FROM @tblAcknowledgement
				WHERE intRowNo > @intMinRowNo
			END

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,strFileName
				,strCompany
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
				,strCompany
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strFileName
				,strCompany
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
				,strCompany
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Initial Ack'
	END

	SELECT strMessageType
		,strMessage
		,ISNULL(strInfo1, '') AS strInfo1
		,ISNULL(strInfo2, '') AS strInfo2
	FROM @tblMessage
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
