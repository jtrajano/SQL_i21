CREATE PROCEDURE uspIPProcessSAPAcknowledgement_HE @strXml NVARCHAR(MAX)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strMessage NVARCHAR(MAX)
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
	DECLARE @intContractHeaderId INT
	DECLARE @intMinRowNo INT
	DECLARE @intLoadId INT
	DECLARE @intReceiptId INT
	DECLARE @strContractSeq NVARCHAR(50)
	DECLARE @intLoadStgId INT

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
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)

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
		)
	SELECT MESTYP_LNG
		,[STATUS]
		,STACOD
		,STATXT
		,STATYP
		,STAPA2_LNG
		,STAPA1_LNG
		,REFERENCE
		,TRACKINGNO
		,ITEM
	FROM OPENXML(@idoc, 'IDOC/ALEAUD', 2) WITH (
			MESTYP_LNG NVARCHAR(50)
			,[STATUS] NVARCHAR(50)
			,STACOD NVARCHAR(50)
			,STATXT NVARCHAR(50)
			,STATYP NVARCHAR(50)
			,STAPA2_LNG NVARCHAR(50)
			,STAPA1_LNG NVARCHAR(50)
			,REFERENCE NVARCHAR(50)
			,TRACKINGNO NVARCHAR(50)
			,ITEM NVARCHAR(50)
			)

	--delete records if tracking no is not a number
	--Delete From @tblAcknowledgement Where ISNUMERIC(strTrackingNo)=0 AND strMesssageType IN ('PURCONTRACT_CREATE01','PURCONTRACT_CHANGE01')
	SELECT @intMinRowNo = MIN(intRowNo)
	FROM @tblAcknowledgement

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@strContractSeq = ''
			,@strMessage = ''

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
		FROM @tblAcknowledgement
		WHERE intRowNo = @intMinRowNo

		--PO Create
		IF @strMesssageType = 'PURCONTRACT_CREATE01'
		BEGIN
			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE strContractNumber = @strRefNo
				AND intContractTypeId = 1

			SELECT @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			FROM tblCTContractDetail
			WHERE intContractDetailId = @strTrackingNo

			IF @strStatus IN (53) --Success
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
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractDetailId = @strTrackingNo
					AND ISNULL(strFeedStatus, '') = ''

				--update po details in shipping instruction/advice staging table
				UPDATE sld
				SET sld.strExternalPONumber = @strParam
					,sld.strExternalPOItemNumber = @strPOItemNo
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

			IF @strStatus NOT IN (53) --Error
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
		IF @strMesssageType = 'PURCONTRACT_CHANGE01'
		BEGIN
			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE strContractNumber = @strRefNo
				AND intContractTypeId = 1

			SELECT @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			FROM tblCTContractDetail
			WHERE intContractDetailId = @strTrackingNo

			IF @strStatus IN (53) --Success
			BEGIN
				IF (
						SELECT ISNULL(strERPPONumber, '')
						FROM tblCTContractDetail
						WHERE intContractDetailId = @strTrackingNo
						) <> @strParam
					UPDATE tblCTContractDetail
					SET strERPPONumber = @strParam
						,strERPItemNumber = @strPOItemNo
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

			IF @strStatus NOT IN (53) --Error
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

		--Profit & Loss
		IF @strMesssageType = 'FIDCCP02'
		BEGIN
			IF @strStatus IN (53) --Success
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

			IF @strStatus NOT IN (53) --Error
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

		SELECT @intMinRowNo = MIN(intRowNo)
		FROM @tblAcknowledgement
		WHERE intRowNo > @intMinRowNo
	END

	SELECT strMessageType
		,strMessage
		,ISNULL(strInfo1, '') AS strInfo1
		,ISNULL(strInfo2, '') AS strInfo2
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
