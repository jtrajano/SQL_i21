CREATE PROCEDURE [dbo].[uspIPProcessSAPAcknowledgement] @strXml NVARCHAR(max)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(max)
		,@strMesssageType NVARCHAR(50)
		,@strStatus NVARCHAR(50)
		,@strStatusCode NVARCHAR(MAX)
		,@strStatusDesc NVARCHAR(MAX)
		,@strStatusType NVARCHAR(MAX)
		,@strParam NVARCHAR(MAX)
		,@strParam1 NVARCHAR(MAX)
		,@strRefNo NVARCHAR(50)
		,@strTrackingNo NVARCHAR(50)
		,@intContractHeaderId INT
		,@intMinRowNo INT
		,@strDeliveryType NVARCHAR(50)
		,@strPartnerNo NVARCHAR(100)
		,@strContractSeq NVARCHAR(50)
		,@strMessage NVARCHAR(MAX)

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

		SELECT @strMesssageType = strMesssageType
			,@strStatus = strStatus
			,@strStatusCode = ISNULL(strStatusCode, '')
			,@strStatusDesc = ISNULL(strStatusDesc, '')
			,@strStatusType = ISNULL(strStatusType, '')
			,@strParam = strParam
			,@strParam1 = strParam1
			,@strRefNo = strRefNo
			,@strTrackingNo = strTrackingNo
			,@strDeliveryType = strDeliveryType
		FROM @tblAcknowledgement
		WHERE intRowNo = @intMinRowNo

		--PO Create
		IF @strMesssageType = 'PORDCR1'
		BEGIN
			SELECT @intContractHeaderId = intContractHeaderId
			FROM tblCTContractHeader WITH (NOLOCK)
			WHERE strContractNumber = @strRefNo
				AND intContractTypeId = 1

			SELECT @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			FROM tblCTContractDetail WITH (NOLOCK)
			WHERE intContractDetailId = @strTrackingNo

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
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
			FROM tblCTContractHeader WITH (NOLOCK)
			WHERE strContractNumber = @strRefNo
				AND intContractTypeId = 1

			SELECT @strContractSeq = CONVERT(VARCHAR, intContractSeq)
			FROM tblCTContractDetail WITH (NOLOCK)
			WHERE intContractDetailId = @strTrackingNo

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
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

		INSERT INTO tblIPAcknowledgementStage (
			strXml
			,intDeadLock
			,strType
			,stri21ReferenceNo
			,strERPReferenceNo
			)
		SELECT @strXml
			,0
			,@strMesssageType
			,CASE 
				WHEN (
						@strMesssageType = 'PORDCH'
						OR @strMesssageType = 'PORDCR1'
						)
					THEN @strRefNo + ' / ' + ISNULL(@strContractSeq, '')
				ELSE @strRefNo
				END
			,@strParam

		--Shipment Create
		IF @strMesssageType = 'DESADV'
		BEGIN
			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
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

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
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
			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
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

			IF @strStatus IN (
					52
					,53
					) --Success
			BEGIN
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
				IF @strStatus IN (
						52
						,53
						) --Success
				BEGIN
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

	SELECT strMessageType
		,strMessage
		,ISNULL(strInfo1, '') strInfo1
		,ISNULL(strInfo2, '') strInfo2
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
