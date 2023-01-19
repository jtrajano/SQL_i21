﻿CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOIDOC_CA] (
	@ysnCancel BIT = 0
	,@ysnDebug BIT = 0
	)
AS
BEGIN
	DECLARE @strVendorAccountNum NVARCHAR(100)
		,@strERPPONumber NVARCHAR(100)
		,@strItemNo NVARCHAR(100)
		,@strContractItemNo NVARCHAR(100)
		,@strLoadingPoint NVARCHAR(100)
		,@dblQuantity NUMERIC(18, 6)
		,@dblNetWeight NUMERIC(18, 6)
		,@dtmPlannedAvailabilityDate DATETIME
		,@intContractHeaderId INT
		,@strVendorName NVARCHAR(100)
		,@intEntityId INT
		,@intContractFeedId INT
		,@strVendorRefNo NVARCHAR(50)
		,@strXML NVARCHAR(MAX)
		,@strContractNo NVARCHAR(100)
		,@strRowState NVARCHAR(50)
		,@intShipperId INT
		,@strShipperName NVARCHAR(100)
		,@intDestinationCityId INT
		,@strDestinationPoint NVARCHAR(100)
		,@intDestinationPortId INT
		,@intRecordId INT
		,@intThirdPartyContractWaitingPeriod INT
		,@strError NVARCHAR(MAX) = ''
		,@dtmFeedCreated DATETIME
		,@strShipperVendorAccountNum NVARCHAR(100)
		,@intContractDetailId INT
		,@strSeq NVARCHAR(50)
		,@dtmCurrentDate DATETIME
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME
		,@intNumberOfContainers INT
		,@strThirdPartyFeedStatus nvarchar(50)
	DECLARE @tblCTContractFeed TABLE (intContractFeedId INT)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strContractFeedIds NVARCHAR(MAX)
		,strRowState NVARCHAR(50)
		,strXml NVARCHAR(MAX)
		,strContractNo NVARCHAR(100)
		,strPONo NVARCHAR(100)
		)

	SELECT @dtmCurrentDate = GetDATE()

	SELECT @intThirdPartyContractWaitingPeriod = IsNULL(intThirdPartyContractWaitingPeriod, 60)
	FROM dbo.tblIPCompanyPreference

	IF @ysnCancel = 1
	BEGIN
		INSERT INTO dbo.tblIPThirdPartyContractFeed (
			intContractFeedId
			,strERPPONumber
			,strRowState
			)
		SELECT CF.intContractFeedId
			,CF.strERPPONumber
			,CF.strRowState
		FROM dbo.tblCTContractFeed CF WITH (NOLOCK)
		WHERE CF.strERPPONumber <> ''
			AND CF.dtmStartDate - @dtmCurrentDate <= @intThirdPartyContractWaitingPeriod
			AND CF.strCommodityCode = 'Coffee'
			AND CF.strRowState = 'Delete'
			AND CF.strContractBasis = 'FOB'
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblIPThirdPartyContractFeed TPCF WITH (NOLOCK)
				WHERE TPCF.intContractFeedId = CF.intContractFeedId
				)
			AND NOT EXISTS (
					SELECT 1
					FROM tblCTContractDetail CD
					WHERE CD.intContractDetailId = CF.intContractDetailId
					)
		ORDER BY CF.intContractFeedId ASC

		INSERT INTO dbo.tblIPThirdPartyContractFeed (
			intContractFeedId
			,strERPPONumber
			,strRowState
			)
		SELECT CF.intContractFeedId
			,CF.strERPPONumber
			,CF.strRowState
		FROM dbo.tblCTContractFeed CF WITH (NOLOCK)
		WHERE CF.strERPPONumber <> ''
			AND CF.dtmStartDate - @dtmCurrentDate <= @intThirdPartyContractWaitingPeriod
			AND CF.strCommodityCode = 'Coffee'
			AND CF.strRowState = 'Delete'
			AND CF.strContractBasis = 'FOB'
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblIPThirdPartyContractFeed TPCF WITH (NOLOCK)
				WHERE TPCF.intContractFeedId = CF.intContractFeedId
				)
			AND EXISTS (
					SELECT 1
					FROM tblCTContractDetail CD
					WHERE CD.intContractDetailId = CF.intContractDetailId
					AND CD.intContractStatusId=3
					)
		ORDER BY CF.intContractFeedId ASC

		INSERT INTO @tblCTContractFeed (intContractFeedId)
		SELECT intContractFeedId
		FROM dbo.tblIPThirdPartyContractFeed WITH (NOLOCK)
		WHERE strThirdPartyFeedStatus IS NULL
			AND strRowState = 'Delete'
	END
	ELSE
	BEGIN
		INSERT INTO tblIPThirdPartyContractFeed (
			intContractFeedId
			,strERPPONumber
			,strRowState
			)
		SELECT CF.intContractFeedId
			,CF.strERPPONumber
			,CF.strRowState
		FROM dbo.tblCTContractFeed CF WITH (NOLOCK)
		WHERE CF.strERPPONumber <> ''
			AND CF.dtmStartDate - @dtmCurrentDate <= @intThirdPartyContractWaitingPeriod
			AND CF.strCommodityCode = 'Coffee'
			AND CF.strRowState <> 'Delete'
			AND CF.strContractBasis = 'FOB'
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblIPThirdPartyContractFeed TPCF WITH (NOLOCK)
				WHERE TPCF.intContractFeedId = CF.intContractFeedId
				)
		ORDER BY CF.intContractFeedId ASC

		INSERT INTO @tblCTContractFeed (intContractFeedId)
		SELECT intContractFeedId
		FROM dbo.tblIPThirdPartyContractFeed WITH (NOLOCK)
		WHERE strThirdPartyFeedStatus IS NULL
			AND strRowState <> 'Delete'
	END

	SELECT @intContractFeedId = MIN(intContractFeedId)
	FROM @tblCTContractFeed

	WHILE @intContractFeedId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@intContractDetailId = NULL

		SELECT @strVendorAccountNum = NULL
			,@strERPPONumber = NULL
			,@strItemNo = NULL
			,@strContractItemNo = NULL
			,@strLoadingPoint = NULL
			,@dblQuantity = NULL
			,@dblNetWeight = NULL
			,@dtmPlannedAvailabilityDate = NULL
			,@strRowState = NULL
			,@intEntityId = NULL
			,@strContractNo = NULL
			,@dtmFeedCreated = NULL
			,@strShipperVendorAccountNum = NULL
			,@strSeq = NULL
			,@dtmStartDate = NULL
			,@dtmEndDate = NULL
			,@intNumberOfContainers = NULL

		SELECT @strError = ''

		SELECT @strVendorAccountNum = strVendorAccountNum
			,@strERPPONumber = strERPPONumber
			,@strItemNo = strItemNo
			,@strContractItemNo = strContractItemName
			,@strLoadingPoint = strLoadingPoint
			,@dblQuantity = dblQuantity
			,@dblNetWeight = dblNetWeight
			,@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate
			,@intContractHeaderId = intContractHeaderId
			,@strRowState = strRowState
			,@dtmFeedCreated = dtmFeedCreated
			,@intContractDetailId = intContractDetailId
			,@strSeq = intContractSeq
			,@dtmStartDate = dtmStartDate
			,@dtmEndDate = dtmEndDate
		FROM dbo.tblCTContractFeed WITH (NOLOCK)
		WHERE intContractFeedId = @intContractFeedId

		SELECT @dtmEndDate = Convert(DATETIME, Convert(NVARCHAR, @dtmEndDate, 101))

		SELECT @intEntityId = intEntityId
			,@strVendorRefNo = strCustomerContract
			,@strContractNo = strContractNumber
		FROM dbo.tblCTContractHeader WITH (NOLOCK)
		WHERE intContractHeaderId = @intContractHeaderId

		SELECT @intShipperId = intShipperId
			,@intDestinationCityId = intDestinationCityId
			,@intDestinationPortId = intDestinationPortId
			,@intNumberOfContainers = intNumberOfContainers
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strVendorName = strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
		WHERE intEntityId = @intEntityId

		SELECT @strShipperName = strName
		FROM dbo.tblEMEntity WITH (NOLOCK)
		WHERE intEntityId = @intShipperId

		SELECT @strShipperVendorAccountNum = strVendorAccountNum
		FROM dbo.tblAPVendor WITH (NOLOCK)
		WHERE intEntityId = @intShipperId

		IF @strShipperVendorAccountNum IS NULL
			OR @strShipperVendorAccountNum = ''
		BEGIN
			SELECT @strShipperVendorAccountNum = @strShipperName
		END

		SELECT @strDestinationPoint = strCity
		FROM dbo.tblSMCity WITH (NOLOCK)
		WHERE intCityId = IsNULl(@intDestinationCityId, @intDestinationPortId)

		IF @strRowState <> 'Delete'
		BEGIN
			IF @strVendorAccountNum IS NULL
				OR @strVendorAccountNum = ''
			BEGIN
				SELECT @strError = @strError + 'Vendor Account Number cannot be blank. '
			END

			IF @strLoadingPoint IS NULL
				OR @strLoadingPoint = ''
			BEGIN
				SELECT @strError = @strError + 'Loading Point cannot be blank. '
			END

			IF @strDestinationPoint IS NULL
				OR @strDestinationPoint = ''
			BEGIN
				SELECT @strError = @strError + 'Destination Point cannot be blank. '
			END

			IF @dtmPlannedAvailabilityDate IS NULL
			BEGIN
				SELECT @strError = @strError + 'Planned Availability date cannot be blank. '
			END

			IF @strContractItemNo IS NULL
				OR @strContractItemNo = ''
			BEGIN
				SELECT @strError = @strError + 'Contract Item cannot be blank. '
			END
		END
		SELECT @strThirdPartyFeedStatus = NULL
		SELECT TOP 1 @strThirdPartyFeedStatus = strThirdPartyFeedStatus
		FROM dbo.tblIPThirdPartyContractFeed
		WHERE intContractFeedId = @intContractFeedId
		ORDER BY intThirdPartyContractFeedId

		IF @strThirdPartyFeedStatus IS NOT NULL
		BEGIN
			SELECT @strError = @strError + 'Duplicate Entry. '
		END

		IF NOT EXISTS(SELECT *FROM tblCTContractFeed WHERE intContractFeedId = @intContractFeedId)
		BEGIN
			SELECT @strError = @strError + 'Data is missing in the Contract Feed table. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE dbo.tblIPThirdPartyContractFeed
			SET strThirdPartyMessage = @strError
				,strThirdPartyFeedStatus = 'Failed'
			WHERE intContractFeedId = @intContractFeedId
				AND strThirdPartyFeedStatus IS NULL

			GOTO X
		END

		IF @strRowState = 'Delete'
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM tblIPThirdPartyContractFeed
					WHERE strERPPONumber = @strERPPONumber
						AND strThirdPartyFeedStatus <> 'Failed'
						 AND intContractFeedId <> @intContractFeedId
					)
			BEGIN
				UPDATE dbo.tblIPThirdPartyContractFeed
				SET strThirdPartyMessage = 'Added is not sent to Cargoo.'
					,strThirdPartyFeedStatus = 'Failed'
				WHERE intContractFeedId = @intContractFeedId

				GOTO X
			END

			SELECT @strXML = '<Shipment>'

			SELECT @strXML = @strXML + '<Reference>' + @strERPPONumber + '</Reference>'

			SELECT @strXML = @strXML + '<Status>800</Status>'

			SELECT @strXML = @strXML + '<Timestamp>' + CONVERT(VARCHAR(30), @dtmFeedCreated, 126) + '</Timestamp>'

			SELECT @strXML = @strXML + '</Shipment>'
		END
		ELSE
		BEGIN
			SELECT @strXML = '<Shipment>'

			SELECT @strXML = @strXML + '<Incoterm>FOB</Incoterm>'

			SELECT @strXML = @strXML + '<Parties>'

			SELECT @strXML = @strXML + '<Party>'

			SELECT @strXML = @strXML + '<Alias>JDE</Alias>'

			SELECT @strXML = @strXML + '<Name>JDE</Name>'

			SELECT @strXML = @strXML + '<Type>BUY</Type>'

			SELECT @strXML = @strXML + '<Reference>' + @strERPPONumber + '</Reference>'

			SELECT @strXML = @strXML + '</Party>'

			SELECT @strXML = @strXML + '<Party>'

			SELECT @strXML = @strXML + '<Alias>' + IsNULL(@strVendorAccountNum, '') + '</Alias>'

			SELECT @strXML = @strXML + '<Name>' + dbo.fnEscapeXML(@strVendorName) + '</Name>'

			SELECT @strXML = @strXML + '<Type>SUP</Type>'

			SELECT @strXML = @strXML + '<Reference>' + dbo.fnEscapeXML(IsNULL(@strVendorRefNo, '')) + '</Reference>'

			SELECT @strXML = @strXML + '</Party>'

			IF IsNULL(@strShipperName, '') <> ''
			BEGIN
				SELECT @strXML = @strXML + '<Party>'

				SELECT @strXML = @strXML + '<Alias>' + IsNULL(@strShipperVendorAccountNum, '') + '</Alias>'

				SELECT @strXML = @strXML + '<Name>' + dbo.fnEscapeXML(IsNULL(@strShipperName, '')) + '</Name>'

				SELECT @strXML = @strXML + '<Type>CZ</Type>'

				SELECT @strXML = @strXML + '</Party>'
			END

			SELECT @strXML = @strXML + '</Parties>'

			SELECT @strXML = @strXML + '<Pol>' + dbo.fnEscapeXML(IsNULL(@strLoadingPoint, '')) + '</Pol>'

			SELECT @strXML = @strXML + '<Pod>' + dbo.fnEscapeXML(IsNULL(@strDestinationPoint, '')) + '</Pod>'

			SELECT @strXML = @strXML + '<Eta>' + CONVERT(VARCHAR(30), @dtmPlannedAvailabilityDate, 126) + '</Eta>'

			SELECT @strXML = @strXML + '<StartDate>' + CONVERT(VARCHAR(30), @dtmStartDate, 126) + '</StartDate>'

			SELECT @strXML = @strXML + '<EndDate>' + CONVERT(VARCHAR(30), @dtmEndDate, 126) + '</EndDate>'

			SELECT @strXML = @strXML + '<ContainerCount>' + IsNULL(Ltrim(@intNumberOfContainers),'') + '</ContainerCount>'

			SELECT @strXML = @strXML + '<CommodityItems>'

			SELECT @strXML = @strXML + '<CommodityItem>'

			SELECT @strXML = @strXML + '<ArticleCode>' + @strItemNo + '</ArticleCode>'

			SELECT @strXML = @strXML + '<ArticleDescription>' + dbo.fnEscapeXML(IsNULL(@strContractItemNo, '')) + '</ArticleDescription>'

			SELECT @strXML = @strXML + '<CommodityCode>Coffee</CommodityCode>'

			SELECT @strXML = @strXML + '<GrossWeight>' + Ltrim(Convert(NUMERIC(18, 0), @dblNetWeight)) + '</GrossWeight>'

			SELECT @strXML = @strXML + '<Packages>' + ltrim(Convert(NUMERIC(18, 0), @dblQuantity)) + '</Packages>'

			SELECT @strXML = @strXML + '</CommodityItem>'

			SELECT @strXML = @strXML + '</CommodityItems>'

			SELECT @strXML = @strXML + '</Shipment>'
		END

		IF @strXML IS NOT NULL
		BEGIN
			INSERT INTO @tblOutput (
				strContractFeedIds
				,strRowState
				,strXml
				,strContractNo
				,strPONo
				)
			VALUES (
				@intContractFeedId
				,@strRowState
				,@strXML
				,ISNULL(@strContractNo, '') + ' / ' + ISNULL(@strSeq, '')
				,ISNULL(@strERPPONumber, '')
				)

			IF @ysnDebug = 0
			BEGIN
				DELETE
				FROM dbo.tblIPContractFeedLog
				WHERE intContractDetailId = @intContractDetailId

				INSERT INTO dbo.tblIPContractFeedLog (
					intContractHeaderId
					,intContractDetailId
					--,intEntityId
					,strCustomerContract
					,intShipperId
					,intDestinationCityId
					,intDestinationPortId
					,intNumberOfContainers
					)
				SELECT @intContractHeaderId
					,@intContractDetailId
					--,@intEntityId
					,@strVendorRefNo
					,@intShipperId
					,@intDestinationCityId
					,@intDestinationPortId
					,@intNumberOfContainers

				IF EXISTS (
						SELECT 1
						FROM dbo.tblIPThirdPartyContractFeed
						WHERE intContractFeedId = @intContractFeedId
							AND strThirdPartyFeedStatus IS NULL
						)
				BEGIN
					UPDATE dbo.tblIPThirdPartyContractFeed
					SET strThirdPartyFeedStatus = 'Awt Ack'
						,ysnThirdPartyMailSent = 0
						,strThirdPartyMessage = NULL
					WHERE intContractFeedId = @intContractFeedId
				END
				ELSE
				BEGIN
					DELETE
					FROM @tblOutput
				END
			END
		END

		IF EXISTS (
				SELECT *
				FROM @tblOutput
				)
		BEGIN
			BREAK
		END

		X:

		SELECT @intContractFeedId = MIN(intContractFeedId)
		FROM @tblCTContractFeed
		WHERE intContractFeedId > @intContractFeedId
	END

	SELECT IsNULL(strContractFeedIds, '0') AS id
		,IsNULL(strXml, '') AS strXml
		,IsNULL(strContractNo, '') AS strInfo1
		,IsNULL(strPONo, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
END
