CREATE PROCEDURE [dbo].[uspIPProcessFinalSAPAcknowledgement] @strXml NVARCHAR(max)
	,@strMessageType NVARCHAR(50) OUTPUT
	,@strMessage NVARCHAR(MAX) OUTPUT
	,@strInfo1 NVARCHAR(50) OUTPUT
	,@strInfo2 NVARCHAR(50) OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(max)
	--DECLARE @strMessage NVARCHAR(MAX)
	DECLARE @strMesssageType NVARCHAR(50)
	DECLARE @strStatus NVARCHAR(50)
	DECLARE @strStatusCode NVARCHAR(MAX)
	DECLARE @strStatusDesc NVARCHAR(MAX)
	DECLARE @strStatusType NVARCHAR(MAX)
	DECLARE @strParam NVARCHAR(MAX)
	DECLARE @strParam1 NVARCHAR(MAX)
	DECLARE @strRefNo NVARCHAR(50)
	DECLARE @strTrackingNo NVARCHAR(50)
	DECLARE @strPOItemNo NVARCHAR(50)
	DECLARE @strLineItemBatchNo NVARCHAR(50)
	DECLARE @strDeliveryItemNo NVARCHAR(50)
	DECLARE @intContractHeaderId INT
	DECLARE @intMinRowNo INT
	DECLARE @intLoadId INT
	DECLARE @intReceiptId INT
	DECLARE @strDeliveryType NVARCHAR(50)
	DECLARE @strPartnerNo NVARCHAR(100)
	DECLARE @strContractSeq NVARCHAR(50)
	DECLARE @intLoadStgId INT
	DECLARE @strOldExternalShipmentNumber NVARCHAR(MAX)

	SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strMesssageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStatusCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strStatusDesc NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strStatusType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strParam NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strParam1 NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTrackingNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strPOItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLineItemBatchNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDeliveryItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDeliveryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)

	SELECT @strPartnerNo = RCVPRN
	FROM OPENXML(@idoc, 'ZALEAUD01/IDOC/EDI_DC40', 2) WITH (RCVPRN NVARCHAR(100))

	INSERT INTO @tblAcknowledgement (
		strMesssageType
		,strStatus
		,strStatusCode
		,strStatusDesc
		,strStatusType
		,strParam
		,strParam1
		,strRefNo
		,strTrackingNo
		,strPOItemNo
		,strLineItemBatchNo
		,strDeliveryItemNo
		,strDeliveryType
		)
	SELECT MESTYP_LNG
		,[STATUS]
		,STACOD
		,STATXT
		,STATYP
		,STAPA2_LNG
		,STAPA1_LNG
		,REF_1
		,TRACKINGNO
		,PO_ITEM
		,CHARG
		,DEL_ITEM
		,Z1PA1
	FROM OPENXML(@idoc, 'ZALEAUD01/IDOC/E1ADHDR/E1STATE/E1PRTOB/Z1PRTOB', 2) WITH (
			MESTYP_LNG NVARCHAR(50) '../../../MESTYP_LNG'
			,[STATUS] NVARCHAR(50) '../../STATUS'
			,STACOD NVARCHAR(50) '../../STACOD'
			,STATXT NVARCHAR(50) '../../STATXT'
			,STATYP NVARCHAR(50) '../../STATYP'
			,STAPA2_LNG NVARCHAR(50) '../../STAPA2_LNG'
			,STAPA1_LNG NVARCHAR(50) '../../STAPA1_LNG'
			,REF_1 NVARCHAR(50)
			,TRACKINGNO NVARCHAR(50)
			,PO_ITEM NVARCHAR(50)
			,CHARG NVARCHAR(50)
			,DEL_ITEM NVARCHAR(50)
			,Z1PA1 NVARCHAR(50)
			)

	--delete records if tracking no is not a number
	DELETE
	FROM @tblAcknowledgement
	WHERE ISNUMERIC(strTrackingNo) = 0
		AND strMesssageType IN (
			'PORDCR1'
			,'PORDCH'
			,'DESADV'
			)

	SELECT @intMinRowNo = MIN(intRowNo)
	FROM @tblAcknowledgement

	WHILE (@intMinRowNo IS NOT NULL) --Loop Start
	BEGIN
		SET @strDeliveryType = ''
		SET @strOldExternalShipmentNumber = ''

		SELECT @strMesssageType = strMesssageType
			,@strStatus = strStatus
			,@strStatusCode = ISNULL(strStatusCode, '')
			,@strStatusDesc = ISNULL(strStatusDesc, '')
			,@strStatusType = ISNULL(strStatusType, '')
			,@strParam = strParam
			,@strParam1 = strParam1
			,@strRefNo = strRefNo
			,@strTrackingNo = strTrackingNo
			,@strPOItemNo = strPOItemNo
			,@strLineItemBatchNo = strLineItemBatchNo
			,@strDeliveryItemNo = strDeliveryItemNo
			,@strDeliveryType = strDeliveryType
		FROM @tblAcknowledgement
		WHERE intRowNo = @intMinRowNo

		--PO Create
		IF @strMesssageType = 'PORDCR1'
		BEGIN
			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE strContractNumber = @strRefNo
				AND intContractTypeId = 1

			SELECT @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			FROM tblCTContractDetail
			WHERE intContractDetailId = @strTrackingNo

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				IF (
						SELECT ISNULL(strERPPONumber, '')
						FROM tblCTContractDetail
						WHERE intContractDetailId = @strTrackingNo
						) <> @strParam
				BEGIN
					UPDATE tblCTContractDetail
					SET strERPPONumber = @strParam
						,strERPItemNumber = @strPOItemNo
						,strERPBatchNumber = @strLineItemBatchNo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intContractHeaderId = @intContractHeaderId
						AND intContractDetailId = @strTrackingNo

					UPDATE tblCTContractHeader
					SET intConcurrencyId = intConcurrencyId + 1
					WHERE intContractHeaderId = @intContractHeaderId
				END

				--For Added Contract
				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = 'Success'
					,strERPPONumber = @strParam
					,strERPItemNumber = @strPOItemNo
					,strERPBatchNumber = @strLineItemBatchNo
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @strTrackingNo
					AND ISNULL(strFeedStatus, '') IN (
						'Awt Ack'
						,'Ack Rcvd'
						)

				--update the PO Details in modified sequences
				UPDATE tblCTContractFeed
				SET strERPPONumber = @strParam
					,strERPItemNumber = @strPOItemNo
					,strERPBatchNumber = @strLineItemBatchNo
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @strTrackingNo
					AND ISNULL(strFeedStatus, '') = ''

				--update po details in shipping instruction/advice staging table
				UPDATE sld
				SET sld.strExternalPONumber = @strParam
					,sld.strExternalPOItemNumber = @strPOItemNo
					,sld.strExternalPOBatchNumber = @strLineItemBatchNo
				FROM tblLGLoadDetailStg sld
				JOIN tblLGLoadDetail ld ON sld.intLoadDetailId = ld.intLoadDetailId
				WHERE ld.intPContractDetailId = @strTrackingNo

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo + ' / ' + ISNULL(@strContractSeq, '')
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @strTrackingNo
					AND ISNULL(strFeedStatus, '') = 'Awt Ack'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo + ' / ' + ISNULL(@strContractSeq, '')
					,@strParam
					)
			END
		END

		--PO Update
		IF @strMesssageType = 'PORDCH'
		BEGIN
			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE strContractNumber = @strRefNo
				AND intContractTypeId = 1

			SELECT @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			FROM tblCTContractDetail
			WHERE intContractDetailId = @strTrackingNo

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				IF (
						SELECT ISNULL(strERPPONumber, '')
						FROM tblCTContractDetail
						WHERE intContractDetailId = @strTrackingNo
						) <> @strParam
					UPDATE tblCTContractDetail
					SET strERPPONumber = @strParam
						,strERPItemNumber = @strPOItemNo
						,strERPBatchNumber = @strLineItemBatchNo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intContractHeaderId = @intContractHeaderId
						AND intContractDetailId = @strTrackingNo

				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = 'Success'
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @strTrackingNo
					AND strFeedStatus IN (
						'Awt Ack'
						,'Ack Rcvd'
						)

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo + ' / ' + ISNULL(@strContractSeq, '')
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @strTrackingNo
					AND strFeedStatus = 'Awt Ack'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo + ' / ' + ISNULL(@strContractSeq, '')
					,@strParam
					)
			END
		END

		--Shipment Create
		IF @strMesssageType = 'DESADV'
		BEGIN
			SELECT @intLoadId = intLoadId
				,@strOldExternalShipmentNumber = strExternalShipmentNumber
			FROM tblLGLoad
			WHERE strLoadNumber = @strRefNo

			--Get Last sent StgId
			SELECT TOP 1 @intLoadStgId = intLoadStgId
			FROM tblLGLoadStg
			WHERE intLoadId = @intLoadId
				AND strFeedStatus = 'Awt Ack'
			ORDER BY intLoadStgId DESC

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				IF (
						SELECT ISNULL(strExternalShipmentNumber, '')
						FROM tblLGLoad
						WHERE intLoadId = @intLoadId
						) <> @strParam
				BEGIN
					UPDATE tblLGLoadContainer
					SET ysnNewContainer = 0
					WHERE intLoadId = @intLoadId
						AND EXISTS (
							SELECT 1
							FROM tblLGLoadContainerStg
							WHERE intLoadStgId = @intLoadStgId
							)

					UPDATE tblLGLoad
					SET strExternalShipmentNumber = @strParam
					WHERE intLoadId = @intLoadId

					UPDATE tblLGLoadDetail
					SET strExternalShipmentItemNumber = @strDeliveryItemNo
					WHERE intLoadDetailId = @strTrackingNo
						AND intLoadId = @intLoadId
				END

				UPDATE tblLGLoadStg
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = 'Success'
					,strExternalShipmentNumber = @strParam
				WHERE intLoadId = @intLoadId
					AND ISNULL(strFeedStatus, '') IN (
						'Awt Ack'
						,'Ack Rcvd'
						)

				--Mail notify for getting different shipment no from SAP
				UPDATE tblLGLoadStg
				SET strMessage = 'Received different Shipment Number from SAP. Old No: ' + @strOldExternalShipmentNumber
				WHERE intLoadId = @intLoadId
					AND ISNULL(strFeedStatus, '') IN (
						'Awt Ack'
						,'Ack Rcvd'
						)
					AND ISNULL(@strOldExternalShipmentNumber, '') <> ''
					AND @strOldExternalShipmentNumber <> @strParam

				UPDATE tblLGLoadDetailStg
				SET strExternalShipmentItemNumber = @strDeliveryItemNo
				WHERE intLoadDetailId = @strTrackingNo
					AND intLoadId = @intLoadId

				--update the delivery Details in modified loads both instruction and advice
				UPDATE tblLGLoadStg
				SET strExternalShipmentNumber = @strParam
				WHERE intLoadId = @intLoadId
					AND ISNULL(strFeedStatus, '') = ''

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblLGLoadStg
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intLoadId = @intLoadId
					AND ISNULL(strFeedStatus, '') = 'Awt Ack'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo
					,@strParam
					)
			END
		END

		--Shipment Delete
		IF @strMesssageType = 'WHSCON'
			AND ISNULL(@strDeliveryType, '') = ''
		BEGIN
			IF @strRefNo LIKE 'LSI-%'
				OR @strRefNo LIKE 'LS-%'
				SET @strDeliveryType = 'U'
		END

		--Shipment Update
		IF @strMesssageType = 'WHSCON'
			AND ISNULL(@strDeliveryType, '') = 'U'
		BEGIN
			IF @strRefNo LIKE 'IR-%'
			BEGIN
				SET @strDeliveryType = 'P'

				GOTO RECEIPT
			END

			SET @strMesssageType = 'DESADV'

			SELECT @intLoadId = intLoadId
			FROM tblLGLoad
			WHERE strLoadNumber = @strRefNo

			--Check for Delete
			IF ISNULL(@intLoadId, 0) = 0
				SELECT @intLoadId = intLoadId
				FROM tblLGLoadStg
				WHERE strLoadNumber = @strRefNo

			--Get Last sent StgId
			SELECT TOP 1 @intLoadStgId = intLoadStgId
			FROM tblLGLoadStg
			WHERE intLoadId = @intLoadId
				AND strFeedStatus = 'Awt Ack'
			ORDER BY intLoadStgId DESC

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				UPDATE tblLGLoadContainer
				SET ysnNewContainer = 0
				WHERE intLoadId = @intLoadId
					AND EXISTS (
						SELECT 1
						FROM tblLGLoadContainerStg
						WHERE intLoadStgId = @intLoadStgId
						)
					AND ysnNewContainer = 1

				UPDATE tblLGLoadStg
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = 'Success'
				WHERE intLoadId = @intLoadId
					AND ISNULL(strFeedStatus, '') IN (
						'Awt Ack'
						,'Ack Rcvd'
						)

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo
					,@strParam1
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblLGLoadStg
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intLoadId = @intLoadId
					AND ISNULL(strFeedStatus, '') = 'Awt Ack'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo
					,@strParam
					)
			END
		END

		--Receipt
		RECEIPT:

		IF @strMesssageType = 'WHSCON'
			AND ISNULL(@strDeliveryType, '') = 'P'
		BEGIN
			SELECT @intReceiptId = r.intInventoryReceiptId
			FROM tblICInventoryReceipt r
			WHERE r.strReceiptNumber = @strRefNo

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				UPDATE tblICInventoryReceiptItem
				SET ysnExported = 1
				WHERE intInventoryReceiptId = @intReceiptId

				UPDATE tblIPReceiptError
				SET strErrorMessage = 'Success'
				WHERE strExternalRefNo = @strRefNo
					AND strPartnerNo = 'i212SAP'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				--Log for sending mails
				IF EXISTS (
						SELECT 1
						FROM tblIPReceiptError
						WHERE strExternalRefNo = @strRefNo
							AND strPartnerNo = 'i212SAP'
						)
					UPDATE tblIPReceiptError
					SET strErrorMessage = @strMessage
					WHERE strExternalRefNo = @strRefNo
						AND strPartnerNo = 'i212SAP'
				ELSE
					INSERT INTO tblIPReceiptError (
						strExternalRefNo
						,strErrorMessage
						,strPartnerNo
						,strImportStatus
						)
					VALUES (
						@strRefNo
						,@strMessage
						,'i212SAP'
						,'Ack Sent'
						)

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo
					,@strParam
					)
			END
		END

		--Receipt WMMBXY
		IF @strMesssageType = 'WMMBXY'
		BEGIN
			SET @strMesssageType = 'WHSCON'

			SELECT @intReceiptId = r.intInventoryReceiptId
			FROM tblICInventoryReceipt r
			WHERE r.strReceiptNumber = @strRefNo

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				UPDATE tblICInventoryReceiptItem
				SET ysnExported = 1
				WHERE intInventoryReceiptId = @intReceiptId

				UPDATE tblIPReceiptError
				SET strErrorMessage = 'Success'
				WHERE strExternalRefNo = @strRefNo
					AND strPartnerNo = 'i212SAP'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo
					,''
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				--Log for sending mails
				IF EXISTS (
						SELECT 1
						FROM tblIPReceiptError
						WHERE strExternalRefNo = @strRefNo
							AND strPartnerNo = 'i212SAP'
						)
					UPDATE tblIPReceiptError
					SET strErrorMessage = @strMessage
					WHERE strExternalRefNo = @strRefNo
						AND strPartnerNo = 'i212SAP'
				ELSE
					INSERT INTO tblIPReceiptError (
						strExternalRefNo
						,strErrorMessage
						,strPartnerNo
						,strImportStatus
						)
					VALUES (
						@strRefNo
						,@strMessage
						,'i212SAP'
						,'Ack Sent'
						)

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo
					,''
					)
			END
		END

		--Profit & Loss
		IF @strMesssageType = 'ACC_DOCUMENT'
		BEGIN
			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
				UPDATE tblRKStgMatchPnS
				SET strStatus = 'Ack Rcvd'
					,strMessage = 'Success'
				WHERE intMatchNo = @strParam
					AND ISNULL(strStatus, '') = 'Awt Ack'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					52
					,53
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblRKStgMatchPnS
				SET strStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intMatchNo = @strParam
					AND ISNULL(strStatus, '') = 'Awt Ack'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo
					,@strParam
					)
			END
		END

		--LSP Shipment
		IF @strMesssageType = 'SHPMNT'
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM tblIPLSPPartner
					WHERE strPartnerNo = @strPartnerNo
					)
			BEGIN
				SELECT @intLoadId = intLoadId
				FROM tblLGLoad
				WHERE strLoadNumber = @strRefNo

				IF @strStatus IN (
						52
						,53
						) --Success
				BEGIN
					UPDATE tblLGLoadLSPStg
					SET strFeedStatus = 'Ack Rcvd'
						,strMessage = 'Success'
					WHERE intLoadId = @intLoadId
						AND ISNULL(strFeedStatus, '') = 'Awt Ack'

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						@strMesssageType
						,'Success'
						,@strRefNo
						,@strParam
						)
				END

				IF @strStatus NOT IN (
						52
						,53
						) --Error
				BEGIN
					SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

					UPDATE tblLGLoadLSPStg
					SET strFeedStatus = 'Ack Rcvd'
						,strMessage = @strMessage
					WHERE intLoadId = @intLoadId
						AND ISNULL(strFeedStatus, '') = 'Awt Ack'

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						@strMesssageType
						,@strMessage
						,@strRefNo
						,@strParam
						)
				END
			END
			ELSE
			BEGIN
				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					)
				VALUES (
					@strMesssageType
					,'Invalid LSP Partner'
					)
			END
		END

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblAcknowledgement
		WHERE intRowNo > @intMinRowNo
	END --Loop End

	SELECT @strMessageType = strMessageType
		,@strMessage = strMessage
		,@strInfo1 = ISNULL(strInfo1, '')
		,@strInfo2 = ISNULL(strInfo2, '')
	FROM @tblMessage
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
