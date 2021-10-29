CREATE PROCEDURE uspIPGenerateSAPPOIDOC_ST
AS
BEGIN
	DECLARE @intRecipeStageId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strTransactionType NVARCHAR(50)
		,@strXml NVARCHAR(MAX)
		,@strRecipeName NVARCHAR(250)
		,@strItemNo NVARCHAR(50)
		,@strSessionId NVARCHAR(50)
		,@strRowState NVARCHAR(50)
		,@strERPPONumber NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
		,@intSubBookId INT
		,@strContractNumber NVARCHAR(50)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strContractFeedIds NVARCHAR(MAX)
		,strRowState NVARCHAR(50)
		,strXml NVARCHAR(MAX)
		,strContractNo NVARCHAR(100)
		,strPONo NVARCHAR(100)
		)
	DECLARE @tblCTContractFeed TABLE (
		intRecordId INT identity(1, 1)
		,intContractHeaderId INT
		,strRowState NVARCHAR(50)
		,strERPPONumber NVARCHAR(50)
		,strContractNumber NVARCHAR(50)
		)
	DECLARE @tblCTContractRowState TABLE (
		intContractFeedId INT
		,strOrgRowState NVARCHAR(50)
		)
	DECLARE @tblCTContractCertification TABLE (
		intContractDetailId INT
		,strCertification NVARCHAR(MAX)
		)
	DECLARE @intRecordId INT
		,@intContractHeaderId INT
		,@ysnDestinationPortMandatoryInPOExport BIT
	DECLARE @intContractDetailId INT
		,@strCertificationName NVARCHAR(MAX)
		,@intPriceContractId INT
	DECLARE @tblCTContractDetail TABLE (intContractDetailId INT)

	SELECT @ysnDestinationPortMandatoryInPOExport = IsNULL(ysnDestinationPortMandatoryInPOExport, 0)
	FROM tblIPCompanyPreference

	IF @ysnDestinationPortMandatoryInPOExport = 1
	BEGIN
		UPDATE CF
		SET CF.strMessage = 'Destination Port is empty.'
			,CF.strFeedStatus = 'IGNORE'
			,ysnMailSent =0
		FROM dbo.tblCTContractFeed CF
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
		WHERE IsNULL(CF.strFeedStatus, '') = ''
			AND CD.intDestinationPortId IS NULL
	END

	INSERT INTO @tblCTContractFeed (
		intContractHeaderId
		,strRowState
		,strERPPONumber
		,strContractNumber
		)
	SELECT DISTINCT intContractHeaderId
		,strRowState
		,strERPPONumber
		,strContractNumber
	FROM dbo.tblCTContractFeed
	WHERE ISNULL(strFeedStatus, '') = ''

	IF NOT EXISTS (
			SELECT *
			FROM @tblCTContractFeed
			)
	BEGIN
		RETURN
	END

	INSERT INTO @tblCTContractRowState (
		intContractFeedId
		,strOrgRowState
		)
	SELECT intContractFeedId
		,strRowState
	FROM dbo.tblCTContractFeed
	WHERE ISNULL(strFeedStatus, '') = ''

	IF EXISTS (
			SELECT *
			FROM @tblCTContractFeed
			WHERE strRowState = 'Added'
			)
	BEGIN
		UPDATE CF
		SET strERPPONumber = (
				CASE 
					WHEN EXISTS (
							SELECT *
							FROM @tblCTContractFeed CF1
							WHERE CF1.intContractHeaderId = CF.intContractHeaderId
								AND CF1.strRowState = 'Modified'
								AND CF1.strERPPONumber <> ''
							)
						THEN (
								SELECT TOP 1 CF2.strERPPONumber
								FROM @tblCTContractFeed CF2
								WHERE CF2.intContractHeaderId = CF.intContractHeaderId
									AND CF2.strRowState = 'Modified'
									AND CF2.strERPPONumber <> ''
								)
					ELSE strERPPONumber
					END
				)
			,strRowState = (
				CASE 
					WHEN EXISTS (
							SELECT *
							FROM @tblCTContractFeed CF1
							WHERE CF1.intContractHeaderId = CF.intContractHeaderId
								AND strRowState = 'Modified'
								AND strERPPONumber <> ''
							)
						THEN 'Modified'
					ELSE strRowState
					END
				)
		FROM @tblCTContractFeed CF
		WHERE strRowState = 'Added'
	END

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblCTContractFeed

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@strDetailXML = ''
			,@strRowState = NULL
			,@strERPPONumber = NULL
			,@intSubBookId = NULL
			,@strSubBook = NULL
			,@strContractNumber = NULL

		SELECT @intContractHeaderId = intContractHeaderId
			,@strRowState = strRowState
			,@strERPPONumber = strERPPONumber
			,@strContractNumber = strContractNumber
		FROM @tblCTContractFeed
		WHERE intRecordId = @intRecordId

		IF @strRowState = 'Modified'
			AND EXISTS (
				SELECT *
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND strRowState = 'Added'
					AND ISNULL(strFeedStatus, '') = ''
				)
		BEGIN
			UPDATE tblCTContractFeed
			SET strERPPONumber = @strERPPONumber
				,strRowState = 'Modified'
			WHERE intContractHeaderId = @intContractHeaderId
				AND strRowState = 'Added'
				AND ISNULL(strFeedStatus, '') = ''
		END

		SELECT @intSubBookId = intSubBookId
		FROM tblCTContractHeader
		WHERE intContractHeaderId = @intContractHeaderId

		SELECT @strSubBook = strSubBook
		FROM tblCTSubBook
		WHERE intSubBookId = @intSubBookId

		IF IsNULL(@strSubBook, '') IN (
				'Ngon'
				,'Vayhan'
				)
		BEGIN
			UPDATE tblCTContractFeed
			SET strFeedStatus = 'IGNORE'
			WHERE intContractHeaderId = @intContractHeaderId
				AND IsNULL(strFeedStatus, '') = ''
				AND strRowState = @strRowState

			GOTO NextPO
		END

		IF NOT EXISTS (
				SELECT TOP 1 1
				FROM tblSMTransaction
				WHERE strApprovalStatus IN ('Approved', 'Approved with Modifications')
					AND intRecordId = @intContractHeaderId
					AND intScreenId = 15
				)
		BEGIN
			--UPDATE tblCTContractFeed
			--SET strMessage = 'Contract Waiting for Approval'
			--WHERE intContractHeaderId = @intContractHeaderId
			--	AND IsNULL(strFeedStatus, '') = ''
			--	AND strRowState = @strRowState
			GOTO NextPO
		END

		SELECT @intPriceContractId = NULL

		SELECT @intPriceContractId = intPriceContractId
		FROM dbo.tblCTPriceFixation
		WHERE intContractHeaderId = @intContractHeaderId

		--AND intContractDetailId = @intContractDetailId
		IF @intPriceContractId IS NOT NULL
		BEGIN
			IF NOT EXISTS (
					SELECT TOP 1 1
					FROM tblSMTransaction
					WHERE strApprovalStatus IN ('Approved', 'Approved with Modifications')
						AND intRecordId = @intPriceContractId
						AND intScreenId = 123
					)
			BEGIN
				--UPDATE tblCTContractFeed
				--SET strMessage = 'Price Contract Waiting for Approval'
				--WHERE intContractHeaderId = @intContractHeaderId
				--	AND IsNULL(strFeedStatus, '') = ''
				--	AND strRowState = @strRowState
				GOTO NextPO
			END
		END

		IF @strRowState IN (
				'Modified'
				,'Delete'
				)
			AND IsNULL(@strERPPONumber, '') = ''
		BEGIN
			GOTO NextPO
		END;

		WITH CTE
		AS (
			SELECT strFeedStatus
				,strMessage
				,RN = ROW_NUMBER() OVER (
					PARTITION BY intContractDetailId ORDER BY intContractFeedId DESC
					)
					,ysnMailSent
			FROM dbo.tblCTContractFeed CF
			WHERE CF.intContractHeaderId = @intContractHeaderId
				AND IsNULL(CF.strFeedStatus, '') = ''
				AND CF.strRowState = @strRowState
			)
		UPDATE CTE
		SET strFeedStatus = 'IGNORE'
			,strMessage = 'Duplicate Entry.'
			,ysnMailSent=1
		WHERE RN > 1

		DELETE
		FROM @tblCTContractDetail

		INSERT INTO @tblCTContractDetail (intContractDetailId)
		SELECT intContractDetailId
		FROM tblCTContractDetail
		WHERE intContractHeaderId = @intContractHeaderId

		DELETE
		FROM @tblCTContractCertification

		SELECT @intContractDetailId = min(intContractDetailId)
		FROM @tblCTContractDetail

		WHILE @intContractDetailId IS NOT NULL
		BEGIN
			SELECT @strCertificationName = '<CERTIFICATE>'

			SELECT @strCertificationName = @strCertificationName + '<CERTIFICATE_CODE>' + strCertificationName + '</CERTIFICATE_CODE>'
			FROM tblCTContractDetail CD
			JOIN tblCTContractCertification CC ON CC.intContractDetailId = CD.intContractDetailId
			JOIN tblICCertification C ON C.intCertificationId = CC.intCertificationId
			WHERE CD.intContractHeaderId = @intContractHeaderId

			SELECT @strCertificationName = @strCertificationName + '</CERTIFICATE>'

			INSERT INTO @tblCTContractCertification (
				intContractDetailId
				,strCertification
				)
			SELECT @intContractDetailId
				,@strCertificationName

			SELECT @intContractDetailId = min(intContractDetailId)
			FROM @tblCTContractDetail
			WHERE intContractDetailId > @intContractDetailId
		END

		SELECT @strHeaderXML = '<ROOT_PO><CTRL_POINT>' + '<DOC_NO>' + Ltrim(IsNULL(CF.intContractFeedId, '')) + '</DOC_NO>' + '<MSG_TYPE>' + CASE 
				WHEN UPPER(CF.strRowState) = 'ADDED'
					THEN 'PO_CREATE'
				ELSE 'PO_UPDATE'
				END + '</MSG_TYPE>' + '<SENDER>i21</SENDER>' + '<RECEIVER>ERP</RECEIVER>' + '</CTRL_POINT>' + '<HEADER>' + '<COMP_CODE>' + IsNULL('', '') + '</COMP_CODE>' + '<CONTRACT_NO>' + IsNULL(CF.strContractNumber, '') + '</CONTRACT_NO>' + '<PO_NUMBER>' + IsNULL(CF.strERPPONumber, '') + '</PO_NUMBER>' + '<VENDOR>' + IsNULL(strVendorAccountNum, '') + '</VENDOR>' + '<PAYMENT_TERM>' + IsNULL(CF.strTerm, '') + '</PAYMENT_TERM>' + '<INCO_TERM>' + IsNULL(CF.strContractBasis, '') + '</INCO_TERM>' + '<POSITION>' + IsNULL(strPosition, '') + '</POSITION>' + '<WEIGHT_TERM>' + IsNULL(W.strWeightGradeDesc, '') + '</WEIGHT_TERM>' + '<APPROVAL_BASIS>' + IsNULL(G.strWeightGradeDesc, '') + '</APPROVAL_BASIS>' + '<CREATE_DATE>' + IsNULL(Convert(NVARCHAR, CH.dtmCreated, 112), '') + '</CREATE_DATE>' + '<CREATED_BY>' + IsNULL(CF.strCreatedBy, '') + '</CREATED_BY>' + '<TRACKING_NO>' + Ltrim(IsNULL(CF.intContractFeedId, '')) + '</TRACKING_NO>' + '</HEADER>'
		FROM tblCTContractFeed CF
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		JOIN tblCTPosition P ON P.intPositionId = CH.intPositionId
		JOIN tblCTWeightGrade W ON W.intWeightGradeId = CH.intWeightId
		JOIN tblCTWeightGrade G ON G.intWeightGradeId = CH.intGradeId
		WHERE CF.intContractHeaderId = @intContractHeaderId
			AND IsNULL(CF.strFeedStatus, '') = ''
			AND CF.strRowState = @strRowState

		SELECT @strDetailXML = @strDetailXML + '<LINE_ITEM><SEQUENCE_NO>' + Ltrim(IsNULL(CF.intContractSeq, '')) + '</SEQUENCE_NO>' + '<PO_LINE_ITEM_NO>' + CASE 
				WHEN UPPER(RS.strOrgRowState) = 'MODIFIED'
					THEN IsNULL(CF.strERPItemNumber, '')
				ELSE ''
				END + '</PO_LINE_ITEM_NO>' + '<ITEM_NO>' + IsNull(I.strItemNo, '') + '</ITEM_NO>' + '<SUB_LOCATION>' + dbo.fnEscapeXML(IsNULL(CF.strSubLocation, '')) + '</SUB_LOCATION>' + '<STORAGE_LOCATION>' + dbo.fnEscapeXML(IsNULL(CF.strStorageLocation, '')) + '</STORAGE_LOCATION>' + '<QUANTITY>' + IsNULL(Convert(NVARCHAR(50), Convert(NUMERIC(18, 2), CF.dblQuantity)), '') + '</QUANTITY>' + '<QUANTITY_UOM>' + IsNULL(CF.strQuantityUOM, '') + '</QUANTITY_UOM>' + '<NET_WEIGHT>' + IsNULL(Convert(NVARCHAR(50), Convert(NUMERIC(18, 2), CF.dblNetWeight)), '') + '</NET_WEIGHT>' + '<NET_WEIGHT_UOM>' + IsNULL(strNetWeightUOM, '') + '</NET_WEIGHT_UOM>' + '<PRICE_TYPE>' + IsNULL(PT.strPricingType, 0) + '</PRICE_TYPE>' + '<PRICE_MARKET>' + IsNULL(FM.strFutMarketName, 0) + '</PRICE_MARKET>' + '<PRICE_MONTH>' + IsNULL(Left(Convert(NVARCHAR, Convert(DATETIME, '01 ' + FMon.strFutureMonth), 112), 6), '') + '</PRICE_MONTH>' + '<PRICE>' + IsNULL(Convert(NVARCHAR(50), Convert(NUMERIC(18, 2), CD.dblCashPrice)), '') + '</PRICE>' + '<PRICE_UOM>' + IsNULL(PUM.strUnitMeasure, '') + '</PRICE_UOM>' + '<PRICE_CURRENCY>' + IsNULL(C2.strDescription, 
				'') + '</PRICE_CURRENCY>' + '<BASIS>' + IsNULL(Convert(NVARCHAR(50), Convert(NUMERIC(18, 2), CD.dblBasis)), '') + '</BASIS>' + '<BASIS_UOM>' + IsNULL(UM.strUnitMeasure, '') + '</BASIS_UOM>' + '<BASIS_CURRENCY>' + IsNULL(C.strDescription, '') + '</BASIS_CURRENCY>' + '<FIXATION_DATE>' + rtrim(ltrim(IsNULL(Convert(CHAR, (
								CASE 
									WHEN CH.intPricingTypeId = 1
										THEN CH.dtmContractDate
									ELSE (
											SELECT TOP 1 PFD.dtmFixationDate
											FROM dbo.tblCTPriceFixationDetail PFD
											WHERE PFD.intPriceFixationId = PF.intPriceFixationId
											)
									END
								), 112), ''))) + '</FIXATION_DATE>' + '<START_DATE>' + IsNULL(Convert(NVARCHAR, CF.dtmStartDate, 112), '') + '</START_DATE>' + '<END_DATE>' + IsNULL(Convert(NVARCHAR, CF.dtmEndDate, 112), '') + '</END_DATE>' + '<PLANNED_AVL_DATE>' + IsNULL(Convert(NVARCHAR, CD.dtmUpdatedAvailabilityDate, 112), '') + '</PLANNED_AVL_DATE>' + '<CONTRACT_ITEM_NO>' + IsNULL(BIN.strItemNo, '') + '</CONTRACT_ITEM_NO>' + '<ORIGIN>' + IsNULL(CF.strOrigin, '') + '</ORIGIN>' + '<PURCH_GROUP>' + IsNULL(CF.strPurchasingGroup, '') + '</PURCH_GROUP>' + '<VENDOR_LOT_NO>' + IsNULL('', '') + '</VENDOR_LOT_NO>' + '<PACK_DESC>' + IsNULL(CF.strPackingDescription, '') + '</PACK_DESC>' + '<LOADING_PORT>' + IsNULL(CF.strLoadingPoint, '') + '</LOADING_PORT>' + '<DEST_PORT>' + IsNULL(City.strCity, '') + '</DEST_PORT>' + '<SHIPPING_LINE>' + IsNULL(E.strName, '') + '</SHIPPING_LINE>' + IsNULL(CC.strCertification, '') + '<ROW_STATE>' + CASE 
				WHEN UPPER(RS.strOrgRowState) = 'ADDED'
					THEN 'C'
				WHEN UPPER(RS.strOrgRowState) = 'MODIFIED'
					THEN 'U'
				ELSE 'D'
				END + '</ROW_STATE>' + '<TRACKING_NO>' + Ltrim(IsNULL(CF.intContractFeedId, '')) + '</TRACKING_NO>' + '</LINE_ITEM>'
		FROM dbo.tblCTContractFeed CF
		JOIN @tblCTContractRowState RS ON RS.intContractFeedId = CF.intContractFeedId
		LEFT JOIN dbo.tblICItem I ON I.intItemId = CF.intItemId
		LEFT JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
		LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		LEFT JOIN dbo.tblSMCurrency C2 ON C2.intCurrencyID = CD.intCurrencyId
		LEFT JOIN dbo.tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		LEFT JOIN dbo.tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
		LEFT JOIN dbo.tblRKFuturesMonth FMon ON FMon.intFutureMonthId = CD.intFutureMonthId
		LEFT JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = CD.intBasisUOMId
		LEFT JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = CD.intBasisCurrencyId
		LEFT JOIN dbo.tblCTPriceFixation PF ON PF.intContractHeaderId = CD.intContractHeaderId
			AND PF.intContractDetailId = CD.intContractDetailId
		--LEFT JOIN tblCTPriceFixationDetail PFD ON PFD.intPriceFixationId = PF.intPriceFixationId
		LEFT JOIN dbo.tblSMCity City ON City.intCityId = CD.intDestinationPortId
		LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = CD.intShippingLineId
		LEFT JOIN @tblCTContractCertification CC ON CC.intContractDetailId = CD.intContractDetailId
		LEFT JOIN dbo.tblICItem BIN ON BIN.intItemId = CD.intItemBundleId
		LEFT JOIN dbo.tblICItemUOM PIU ON PIU.intItemUOMId = CD.intPriceItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PIU.intUnitMeasureId
		WHERE CF.intContractHeaderId = @intContractHeaderId
			AND IsNULL(CF.strFeedStatus, '') = ''
			AND CF.strRowState = @strRowState

		SELECT @strXml = @strHeaderXML + @strDetailXML + '</ROOT_PO>'

		IF @strXml IS NOT NULL
		BEGIN
			INSERT INTO @tblOutput (
				strContractFeedIds
				,strRowState
				,strXml
				,strContractNo
				,strPONo
				)
			VALUES (
				@intRecipeStageId
				,@strTransactionType
				,@strXml
				,ISNULL(@strContractNumber, '')
				,ISNULL(@strERPPONumber, '')
				)

			UPDATE tblCTContractFeed
			SET strFeedStatus = 'Awt Ack'
				,strMessage = NULL
				,ysnMailSent = 0
				,dtmProcessedDate = GETDATE()
			WHERE intContractHeaderId = @intContractHeaderId
				AND IsNULL(strFeedStatus, '') = ''
				AND strRowState = @strRowState

			Update tblCTContractHeader 
			Set ysnExported =1, dtmExported =GETDATE()
			Where intContractHeaderId = @intContractHeaderId
		END

		IF EXISTS (
				SELECT *
				FROM @tblOutput
				)
		BEGIN
			BREAK
		END

		NextPO:

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblCTContractFeed
		WHERE intRecordId > @intRecordId
	END

	SELECT IsNULL(strContractFeedIds, '0') AS id
		,IsNULL(strXml, '') AS strXml
		,IsNULL(strContractNo, '') AS strInfo1
		,IsNULL(strPONo, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
END
