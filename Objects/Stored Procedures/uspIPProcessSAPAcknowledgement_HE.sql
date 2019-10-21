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
	DECLARE @strRefNo NVARCHAR(MAX)
	DECLARE @strTrackingNo NVARCHAR(50)
	DECLARE @strPOItemNo NVARCHAR(50)
	DECLARE @intContractHeaderId INT
	DECLARE @intMinRowNo INT
	DECLARE @intLoadId INT
	DECLARE @intReceiptId INT
	DECLARE @intLoadStgId INT
		,@ysnMaxPrice BIT
		,@intItemId INT
		,@strItemNo NVARCHAR(50)

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
		,strRefNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
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
	FROM OPENXML(@idoc, 'ZE1PRTOB/IDOC/E1ADHDR', 2) WITH (
			MESTYP_LNG NVARCHAR(50)
			,[STATUS] NVARCHAR(50) 'E1STATE/STATUS'
			,STACOD NVARCHAR(50) 'E1STATE/STACOD'
			,STATXT NVARCHAR(MAX) 'E1STATE/STATXT'
			,STATYP NVARCHAR(50) 'E1STATE/STATYP'
			,STAPA2_LNG NVARCHAR(50) 'E1STATE/STAPA2_LNG'
			,STAPA1_LNG NVARCHAR(50) 'E1STATE/STAPA1_LNG'
			,REFERENCE NVARCHAR(MAX) 'E1STATE/E1PRTOB/ZE1PRTGL/REFERENCE'
			,TRACKINGNO NVARCHAR(50) 'E1STATE/E1PRTOB/ZE1PRTGL/TRACKINGNO'
			,ITEM NVARCHAR(50) 'E1STATE/E1PRTOB/ZE1PRTGL/ITEM'
			)

	--delete records if tracking no is not a number
	--Delete From @tblAcknowledgement Where ISNUMERIC(strTrackingNo)=0 AND strMesssageType IN ('PURCONTRACT_CREATE01','PURCONTRACT_CHANGE01')
	SELECT @intMinRowNo = MIN(intRowNo)
	FROM @tblAcknowledgement

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		SELECT @intContractHeaderId = NULL
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
		IF @strMesssageType = 'PURCONTRACT_CREATE'
		BEGIN
			IF IsNumeric(@strTrackingNo) = 1
			BEGIN
				SELECT @strTrackingNo = dbo.fnRemoveTrailingZeroes(@strTrackingNo)
			END

			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE RIGHT('000000000000' + strContractNumber, 12) = @strRefNo
				AND intContractTypeId = 1

			SELECT TOP 1 @ysnMaxPrice = ysnMaxPrice
			FROM tblCTContractFeed
			WHERE intContractHeaderId = @intContractHeaderId

			SELECT @intItemId = intItemId
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId
				AND intContractSeq = @strTrackingNo

			SELECT @strItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intItemId

			IF @strStatus IN (53) --Success
			BEGIN
				IF (
						SELECT ISNULL(strERPPONumber, '')
						FROM tblCTContractDetail
						WHERE intContractHeaderId = @intContractHeaderId
							AND intContractSeq = @strTrackingNo
						) <> @strParam
				BEGIN
					UPDATE tblCTContractDetail
					SET strERPPONumber = @strParam
						,strERPItemNumber = @strPOItemNo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intContractHeaderId = @intContractHeaderId
						AND intContractSeq = (
							CASE 
								WHEN ISNULL(@ysnMaxPrice, 0) = 0
									THEN @strTrackingNo
								ELSE intContractSeq
								END
							)
						AND intItemId = @intItemId

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
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND strItemNo = @strItemNo
					AND ISNULL(strFeedStatus, '') IN (
						'Awt Ack'
						,'Ack Rcvd'
						)

				--update the PO Details in modified sequences
				UPDATE tblCTContractFeed
				SET strERPPONumber = @strParam
					,strERPItemNumber = @strPOItemNo
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND strItemNo = @strItemNo
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
					,@strRefNo + ' / ' + ISNULL(@strTrackingNo, '')
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					53
					,64
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND strItemNo = @strItemNo
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
					,@strRefNo + ' / ' + ISNULL(@strTrackingNo, '')
					,@strParam
					)
			END
		END

		--PO Update
		IF @strMesssageType = 'PURCONTRACT_CHANGE'
		BEGIN
			IF IsNumeric(@strTrackingNo) = 1
			BEGIN
				SELECT @strTrackingNo = dbo.fnRemoveTrailingZeroes(@strTrackingNo)
			END

			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader
			WHERE RIGHT('000000000000' + strContractNumber, 12) = RIGHT('000000000000' + @strRefNo, 12)
				AND intContractTypeId = 1

			SELECT TOP 1 @ysnMaxPrice = ysnMaxPrice
			FROM tblCTContractFeed
			WHERE intContractHeaderId = @intContractHeaderId

			SELECT @intItemId = intItemId
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId
				AND intContractSeq = @strTrackingNo

			SELECT @strItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intItemId

			IF @strStatus IN (53) --Success
			BEGIN
				UPDATE tblCTContractDetail
				SET strERPPONumber = @strParam
					,strERPItemNumber = @strPOItemNo
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND intItemId = @intItemId
					AND ISNULL(strERPPONumber, '') <> @strParam

				-- To update Item Change, Delete entries
				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = 'Success'
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND ISNULL(strFeedStatus, '') = 'Awt Ack'
					AND ISNULL(strERPPONumber, '') = @strParam

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,'Success'
					,@strRefNo + ' / ' + ISNULL(@strTrackingNo, '')
					,@strParam
					)
			END

			IF @strStatus NOT IN (
					53
					,64
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND strItemNo = @strItemNo
					AND ISNULL(strFeedStatus, '') = 'Awt Ack'

				-- To update Item Change, Delete entries
				UPDATE tblCTContractFeed
				SET strFeedStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractSeq = (
						CASE 
							WHEN ISNULL(@ysnMaxPrice, 0) = 0
								THEN @strTrackingNo
							ELSE intContractSeq
							END
						)
					AND ISNULL(strFeedStatus, '') = 'Awt Ack'
					AND ISNULL(strERPPONumber, '') = @strParam

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					@strMesssageType
					,@strMessage
					,@strRefNo + ' / ' + ISNULL(@strTrackingNo, '')
					,@strParam
					)
			END
		END

		--Profit & Loss
		IF @strMesssageType = 'FIDCC2'
		BEGIN
			IF @strStatus IN (53) --Success
			BEGIN
				UPDATE tblRKStgMatchPnS
				SET strStatus = 'Ack Rcvd'
					,strMessage = 'Success'
				WHERE strReferenceNo = @strRefNo
					AND ISNULL(strStatus, '') = 'Awt Ack'

				UPDATE tblRKStgOptionMatchPnS
				SET strStatus = 'Ack Rcvd'
					,strMessage = 'Success'
				WHERE strReferenceNo = @strRefNo
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
					53
					,64
					) --Error
			BEGIN
				SET @strMessage = @strStatus + ' - ' + @strStatusCode + ' : ' + @strStatusDesc

				UPDATE tblRKStgMatchPnS
				SET strStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE strReferenceNo = @strRefNo
					AND ISNULL(strStatus, '') = 'Awt Ack'

				UPDATE tblRKStgOptionMatchPnS
				SET strStatus = 'Ack Rcvd'
					,strMessage = @strMessage
				WHERE strReferenceNo = @strRefNo
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

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
