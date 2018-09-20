﻿CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOIDOC_HE] @ysnUpdateFeedStatusOnRead BIT = 0
	,@strRowState NVARCHAR(50)
AS
DECLARE @intMinSeq INT
	,@intContractFeedId INT
	,@intContractHeaderId INT
	,@intContractDetailId INT
	,@strContractBasis NVARCHAR(100)
	,@strContractBasisDesc NVARCHAR(500)
	,@strSubLocation NVARCHAR(50)
	,@strEntityNo NVARCHAR(100)
	,@strTerm NVARCHAR(100)
	,@strPurchasingGroup NVARCHAR(150)
	,@strContractNumber NVARCHAR(100)
	,@strERPPONumber NVARCHAR(100)
	,@intContractSeq INT
	,@strItemNo NVARCHAR(100)
	,@strStorageLocation NVARCHAR(50)
	,@dblQuantity NUMERIC(18, 6)
	,@strQuantityUOM NVARCHAR(50)
	,@dblCashPrice NUMERIC(18, 6)
	,@dblUnitCashPrice NUMERIC(18, 6)
	,@dtmPlannedAvailabilityDate DATETIME
	,@dtmContractDate DATETIME
	,@dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@dblBasis NUMERIC(18, 6)
	,@strCurrency NVARCHAR(50)
	,@strPriceUOM NVARCHAR(50)
	,@strFeedStatus NVARCHAR(50)
	,@strXml NVARCHAR(MAX)
	,@strDocType NVARCHAR(50)
	,@strPOCreateIDOCHeader NVARCHAR(MAX)
	,@strPOUpdateIDOCHeader NVARCHAR(MAX)
	,@strCompCode NVARCHAR(100)
	,@intMinRowNo INT
	,@strXmlHeaderStart NVARCHAR(MAX)
	,@strXmlHeaderEnd NVARCHAR(MAX)
	,@strContractFeedIds NVARCHAR(MAX)
	,@strERPPONumber1 NVARCHAR(100)
	,@strOrigin NVARCHAR(100)
	,@strContractItemNo NVARCHAR(500)
	,@strItemXml NVARCHAR(MAX)
	,@strItemXXml NVARCHAR(MAX)
	,@strTextXml NVARCHAR(MAX)
	,@strSeq NVARCHAR(MAX)
	,@str12Zeros NVARCHAR(50) = '000000000000'
	,@strLoadingPoint NVARCHAR(200)
	,@ysnMaxPrice BIT
	,@strPrintableRemarks NVARCHAR(MAX)
	,@strSalesPerson NVARCHAR(100)
	,@intLocationId INT
	,@strLocationName NVARCHAR(50)
	,@strSAPLocation NVARCHAR(50)
	,@strERPItemNumber NVARCHAR(100)
	,@strTblRowState NVARCHAR(50)
	,@strMessageCode NVARCHAR(50)
DECLARE @tblOutput AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,strContractFeedIds NVARCHAR(MAX)
	,strRowState NVARCHAR(50)
	,strXml NVARCHAR(MAX)
	,strContractNo NVARCHAR(100)
	,strPONo NVARCHAR(100)
	)
DECLARE @tblHeader AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intContractHeaderId INT
	,strCommodityCode NVARCHAR(50)
	,intContractFeedId INT
	,strSubLocation NVARCHAR(50)
	,ysnMaxPrice BIT
	,strPrintableRemarks NVARCHAR(MAX)
	,strSalesPerson NVARCHAR(100)
	,strItemNo NVARCHAR(50)
	)
DECLARE @tblCTContractFeed TABLE (
	intContractFeedId INT
	,intContractHeaderId INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intContractSeq INT
	)
DECLARE @tblCTFinalContractFeed TABLE (
	intContractHeaderId INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
DECLARE @tblCTContractFeed2 TABLE (
	intRecordId INT identity(1, 1)
	,intContractHeaderId INT
	,intContractSeq INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
DECLARE @tblCTContractFeedHistory TABLE (
	intRecordId INT identity(1, 1)
	,intContractHeaderId INT
	,intContractSeq INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intContractFeedId INT
	)
DECLARE @tblIPOutput TABLE (
	intContractHeaderId INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
DECLARE @tblHoldContract TABLE (
	intContractHeaderId INT
	,intContractSeq INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
DECLARE @tblRollUpContract TABLE (
	intContractHeaderId INT
	,ysnMaxPrice INT
	)
DECLARE @tblRollUpFinalContract TABLE (
	intContractHeaderId INT
	,ysnMaxPrice INT
	)

SELECT @strPOCreateIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PO CREATE')

SELECT @strPOUpdateIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PO UPDATE')

SELECT @strMessageCode = dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL', 'MESCOD')

UPDATE tblCTContractFeed
SET strFeedStatus = ''
WHERE strFeedStatus = 'Hold'

UPDATE CF
SET ysnMaxPrice = (
		SELECT TOP 1 CF1.ysnMaxPrice
		FROM tblCTContractFeed CF1
		WHERE CF1.intContractHeaderId = CF.intContractHeaderId
		ORDER BY intContractFeedId ASC
		)
	,strPurchasingGroup = (
		SELECT TOP 1 CF1.strPurchasingGroup
		FROM tblCTContractFeed CF1
		WHERE CF1.intContractHeaderId = CF.intContractHeaderId
			AND CF1.strItemNo = CF.strItemNo
			AND IsNULL(CF1.strPurchasingGroup, '') <> ''
		ORDER BY intContractFeedId ASC
		)
OUTPUT inserted.intContractHeaderId
	,inserted.ysnMaxPrice
INTO @tblRollUpContract
FROM tblCTContractFeed CF
WHERE ISNULL(strFeedStatus, '') = ''

INSERT INTO @tblRollUpFinalContract
SELECT DISTINCT intContractHeaderId
	,ysnMaxPrice
FROM @tblRollUpContract

IF EXISTS (
		SELECT *
		FROM tblCTContractFeed CF
		WHERE ISNULL(strFeedStatus, '') = ''
			AND IsNULL(CF.ysnMaxPrice, 0) = 1
			AND UPPER(strRowState) IN (
				'MODIFIED'
				,'DELETE'
				)
			AND IsNULL(ysnPopulatedByIntegration, 0) = 0
		)
BEGIN
	INSERT INTO @tblCTContractFeed (
		intContractFeedId
		,intContractHeaderId
		,strItemNo
		,intContractSeq
		)
	SELECT CF.intContractFeedId
		,CF.intContractHeaderId
		,CF.strItemNo
		,CF.intContractSeq
	FROM tblCTContractFeed CF
	WHERE ISNULL(strFeedStatus, '') = ''
		AND IsNULL(CF.ysnMaxPrice, 0) = 1
		AND UPPER(strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)
		AND IsNULL(strMessage, '') <> 'System'
		AND IsNULL(ysnPopulatedByIntegration, 0) = 0
		AND EXISTS (
			SELECT *
			FROM tblCTContractDetail CD
			WHERE CD.intContractHeaderId = CF.intContractHeaderId
			)

	INSERT INTO @tblCTFinalContractFeed (
		intContractHeaderId
		,strItemNo
		)
	SELECT DISTINCT intContractHeaderId
		,strItemNo
	FROM @tblCTContractFeed

	DELETE CF
	FROM tblCTContractFeed CF
	JOIN @tblCTContractFeed CF1 ON CF1.intContractFeedId = CF.intContractFeedId

	INSERT INTO tblCTContractFeed (
		intContractHeaderId
		,intContractDetailId
		,strCommodityCode
		,strCommodityDesc
		,strContractBasis
		,strContractBasisDesc
		,strSubLocation
		,strCreatedBy
		,strCreatedByNo
		,strEntityNo
		,strTerm
		,strPurchasingGroup
		,strContractNumber
		,strERPPONumber
		,intContractSeq
		,strItemNo
		,strStorageLocation
		,dblQuantity
		,dblCashPrice
		,strQuantityUOM
		,dtmPlannedAvailabilityDate
		,dblBasis
		,strCurrency
		,dblUnitCashPrice
		,strPriceUOM
		,strRowState
		,dtmContractDate
		,dtmStartDate
		,dtmEndDate
		,dtmFeedCreated
		,strSubmittedBy
		,strSubmittedByNo
		,strOrigin
		,dblNetWeight
		,strNetWeightUOM
		,strVendorAccountNum
		,strTermCode
		,strContractItemNo
		,strContractItemName
		,strERPItemNumber
		,strERPBatchNumber
		,strLoadingPoint
		,strPackingDescription
		,strLocationName
		,ysnPopulatedByIntegration
		,ysnMaxPrice
		)
	SELECT CF.intContractHeaderId
		,intContractDetailId
		,strCommodityCode
		,strCommodityDesc
		,strContractBasis
		,strContractBasisDesc
		,strSubLocation
		,strCreatedBy
		,strCreatedByNo
		,strEntityNo
		,strTerm
		,strPurchasingGroup
		,strContractNumber
		,strERPPONumber
		,intContractSeq
		,CF.strItemNo
		,strStorageLocation
		,dblQuantity
		,dblCashPrice
		,strQuantityUOM
		,dtmPlannedAvailabilityDate
		,dblBasis
		,strCurrency
		,dblUnitCashPrice
		,strPriceUOM
		,CASE 
			WHEN intContractStatusId = 3
				THEN 'DELETE'
			ELSE 'MODIFIED'
			END
		,dtmContractDate
		,dtmStartDate
		,dtmEndDate
		,GETDATE()
		,strSubmittedBy
		,strSubmittedByNo
		,strOrigin
		,dblNetWeight
		,strNetWeightUOM
		,strVendorAccountNum
		,strTermCode
		,strContractItemNo
		,strContractItemName
		,strERPItemNumber
		,strERPBatchNumber
		,strLoadingPoint
		,strPackingDescription
		,strLocationName
		,1
		,RC.ysnMaxPrice
	FROM vyuCTContractFeed CF
	JOIN @tblCTFinalContractFeed CF1 ON CF1.intContractHeaderId = CF.intContractHeaderId
		AND CF1.strItemNo = CF.strItemNo
	LEFT JOIN @tblRollUpFinalContract RC ON RC.intContractHeaderId = CF.intContractHeaderId

	---********************************************************
	--- Item Change
	---********************************************************
	IF @strRowState = 'Added'
	BEGIN
		INSERT INTO @tblCTContractFeed2 (
			intContractHeaderId
			,intContractSeq
			,strItemNo
			)
		SELECT CF.intContractHeaderId
			,CF.intContractSeq
			,CF.strItemNo
		FROM tblCTContractFeed CF
		WHERE ISNULL(strFeedStatus, '') = ''
			AND IsNULL(CF.ysnMaxPrice, 0) = 1
			AND UPPER(strRowState) = 'MODIFIED'

		INSERT INTO @tblCTContractFeedHistory (
			intContractHeaderId
			,intContractSeq
			,strItemNo
			,intContractFeedId
			)
		SELECT CF2.intContractHeaderId
			,CF2.intContractSeq
			,(
				SELECT TOP 1 CF.strItemNo
				FROM tblCTContractFeed CF
				WHERE CF2.intContractHeaderId = CF.intContractHeaderId
					AND CF2.intContractSeq = CF.intContractSeq
					AND IsNULL(CF.strFeedStatus, '') <> ''
					AND CF.strRowState <> 'DELETE'
				ORDER BY intContractFeedId DESC
				)
			,(
				SELECT TOP 1 CF.intContractFeedId
				FROM tblCTContractFeed CF
				WHERE CF2.intContractHeaderId = CF.intContractHeaderId
					AND CF2.intContractSeq = CF.intContractSeq
					AND IsNULL(CF.strFeedStatus, '') <> ''
					AND CF.strRowState <> 'DELETE'
				ORDER BY intContractFeedId DESC
				)
		FROM @tblCTContractFeed2 CF2

		DELETE CF2
		OUTPUT deleted.intContractHeaderId
			,deleted.intContractSeq
			,deleted.strItemNo
		INTO @tblHoldContract
		FROM @tblCTContractFeed2 CF2
		JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF2.intContractHeaderId
			AND CFH.intContractSeq = CF2.intContractSeq
			AND CFH.strItemNo <> CF2.strItemNo
			AND EXISTS (
				SELECT *
				FROM tblCTContractFeed CF
				WHERE CF.intContractHeaderId = CF2.intContractHeaderId
					AND CF.intContractSeq = CF2.intContractSeq
					AND CF.strFeedStatus = 'Awt Ack'
				)

		UPDATE CF
		SET strFeedStatus = 'Hold'
		FROM tblCTContractFeed CF
		JOIN @tblHoldContract HC ON HC.intContractHeaderId = CF.intContractHeaderId
			AND HC.strItemNo = CF.strItemNo
		WHERE IsNULL(strFeedStatus, '') = ''

		IF EXISTS (
				SELECT *
				FROM @tblCTContractFeed2 CF2
				JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF2.intContractHeaderId
					AND CFH.intContractSeq = CF2.intContractSeq
					AND CFH.strItemNo <> CF2.strItemNo
					AND NOT EXISTS (
						SELECT *
						FROM @tblCTFinalContractFeed CF1
						WHERE CF1.intContractHeaderId = CF2.intContractHeaderId
							AND CF1.strItemNo = CFH.strItemNo
						)
				)
		BEGIN
			UPDATE CF
			SET strRowState = CASE 
					WHEN NOT EXISTS (
							SELECT *
							FROM @tblCTContractFeedHistory CFH
							WHERE CFH.intContractHeaderId = CF.intContractHeaderId
								AND CFH.strItemNo = CF.strItemNo
							)
						THEN 'Added'
					ELSE strRowState
					END
				,strERPPONumber = CASE 
					WHEN NOT EXISTS (
							SELECT *
							FROM @tblCTContractFeedHistory CFH
							WHERE CFH.intContractHeaderId = CF.intContractHeaderId
								AND CFH.strItemNo = CF.strItemNo
							)
						THEN ''
					ELSE IsNULL((
								SELECT TOP 1 strERPPONumber
								FROM tblCTContractDetail CD
								JOIN tblICItem I ON CD.intItemId = I.intItemId
								WHERE CD.intContractHeaderId = CF.intContractHeaderId
									AND I.strItemNo = CF.strItemNo
									AND CD.intContractSeq <> CF.intContractSeq
								), strERPPONumber)
					END
			FROM tblCTContractFeed CF
			JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF.intContractHeaderId
				AND CFH.intContractSeq = CF.intContractSeq
				AND CFH.strItemNo <> CF.strItemNo
			WHERE IsNULL(strFeedStatus, '') = ''

			DELETE
			FROM @tblCTFinalContractFeed

			INSERT INTO @tblCTFinalContractFeed (
				intContractHeaderId
				,strItemNo
				)
			SELECT DISTINCT CF2.intContractHeaderId
				,CFH.strItemNo
			FROM @tblCTContractFeed2 CF2
			JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF2.intContractHeaderId
				AND CFH.intContractSeq = CF2.intContractSeq
				AND CFH.strItemNo <> CF2.strItemNo
				AND NOT EXISTS (
					SELECT *
					FROM @tblCTFinalContractFeed CF1
					WHERE CF1.intContractHeaderId = CF2.intContractHeaderId
						AND CF1.strItemNo = CFH.strItemNo
					)

			INSERT INTO tblCTContractFeed (
				intContractHeaderId
				,intContractDetailId
				,strCommodityCode
				,strCommodityDesc
				,strContractBasis
				,strContractBasisDesc
				,strSubLocation
				,strCreatedBy
				,strCreatedByNo
				,strEntityNo
				,strTerm
				,strPurchasingGroup
				,strContractNumber
				,strERPPONumber
				,intContractSeq
				,strItemNo
				,strStorageLocation
				,dblQuantity
				,dblCashPrice
				,strQuantityUOM
				,dtmPlannedAvailabilityDate
				,dblBasis
				,strCurrency
				,dblUnitCashPrice
				,strPriceUOM
				,strRowState
				,dtmContractDate
				,dtmStartDate
				,dtmEndDate
				,dtmFeedCreated
				,strSubmittedBy
				,strSubmittedByNo
				,strOrigin
				,dblNetWeight
				,strNetWeightUOM
				,strVendorAccountNum
				,strTermCode
				,strContractItemNo
				,strContractItemName
				,strERPItemNumber
				,strERPBatchNumber
				,strLoadingPoint
				,strPackingDescription
				,strLocationName
				,ysnPopulatedByIntegration
				,ysnMaxPrice
				)
			OUTPUT inserted.intContractHeaderId
				,inserted.strItemNo
			INTO @tblIPOutput
			SELECT CF.intContractHeaderId
				,intContractDetailId
				,strCommodityCode
				,strCommodityDesc
				,strContractBasis
				,strContractBasisDesc
				,strSubLocation
				,strCreatedBy
				,strCreatedByNo
				,strEntityNo
				,strTerm
				,strPurchasingGroup
				,strContractNumber
				,strERPPONumber
				,intContractSeq
				,CF.strItemNo
				,strStorageLocation
				,dblQuantity
				,dblCashPrice
				,strQuantityUOM
				,dtmPlannedAvailabilityDate
				,dblBasis
				,strCurrency
				,dblUnitCashPrice
				,strPriceUOM
				,'MODIFIED'
				,dtmContractDate
				,dtmStartDate
				,dtmEndDate
				,GETDATE()
				,strSubmittedBy
				,strSubmittedByNo
				,strOrigin
				,dblNetWeight
				,strNetWeightUOM
				,strVendorAccountNum
				,strTermCode
				,strContractItemNo
				,strContractItemName
				,strERPItemNumber
				,strERPBatchNumber
				,strLoadingPoint
				,strPackingDescription
				,strLocationName
				,1
				,RC.ysnMaxPrice
			FROM vyuCTContractFeed CF
			JOIN @tblCTFinalContractFeed CF1 ON CF1.intContractHeaderId = CF.intContractHeaderId
				AND CF1.strItemNo = CF.strItemNo
			LEFT JOIN @tblRollUpFinalContract RC ON RC.intContractHeaderId = CF.intContractHeaderId
				AND NOT EXISTS (
					SELECT *
					FROM tblCTContractFeed CF2
					WHERE CF2.intContractDetailId = CF.intContractDetailId
						AND CF2.intContractHeaderId = CF.intContractHeaderId
						AND CF2.strRowState = 'Modified'
						AND (
							IsNULL(CF2.strFeedStatus, '') = ''
							OR IsNULL(CF2.strFeedStatus, '') = 'Awt Ack'
							)
					)

			DELETE CF1
			FROM @tblIPOutput OP
			JOIN @tblCTFinalContractFeed CF1 ON CF1.intContractHeaderId = OP.intContractHeaderId
				AND CF1.strItemNo = OP.strItemNo

			INSERT INTO tblCTContractFeed (
				intContractHeaderId
				,intContractDetailId
				,strCommodityCode
				,strCommodityDesc
				,strContractBasis
				,strContractBasisDesc
				,strSubLocation
				,strCreatedBy
				,strCreatedByNo
				,strEntityNo
				,strTerm
				,strPurchasingGroup
				,strContractNumber
				,strERPPONumber
				,intContractSeq
				,strItemNo
				,strStorageLocation
				,dblQuantity
				,dblCashPrice
				,strQuantityUOM
				,dtmPlannedAvailabilityDate
				,dblBasis
				,strCurrency
				,dblUnitCashPrice
				,strPriceUOM
				,strRowState
				,dtmContractDate
				,dtmStartDate
				,dtmEndDate
				,dtmFeedCreated
				,strSubmittedBy
				,strSubmittedByNo
				,strOrigin
				,dblNetWeight
				,strNetWeightUOM
				,strVendorAccountNum
				,strTermCode
				,strContractItemNo
				,strContractItemName
				,strERPItemNumber
				,strERPBatchNumber
				,strLoadingPoint
				,strPackingDescription
				,strLocationName
				,strMessage
				,ysnPopulatedByIntegration
				,ysnMaxPrice
				)
			SELECT CF2.intContractHeaderId
				,intContractDetailId
				,strCommodityCode
				,strCommodityDesc
				,strContractBasis
				,strContractBasisDesc
				,strSubLocation
				,strCreatedBy
				,strCreatedByNo
				,strEntityNo
				,strTerm
				,strPurchasingGroup
				,strContractNumber
				,strERPPONumber
				,CF2.intContractSeq
				,CF2.strItemNo
				,strStorageLocation
				,dblQuantity
				,dblCashPrice
				,strQuantityUOM
				,dtmPlannedAvailabilityDate
				,dblBasis
				,strCurrency
				,dblUnitCashPrice
				,strPriceUOM
				,'DELETE'
				,dtmContractDate
				,dtmStartDate
				,dtmEndDate
				,dtmFeedCreated
				,strSubmittedBy
				,strSubmittedByNo
				,strOrigin
				,dblNetWeight
				,strNetWeightUOM
				,strVendorAccountNum
				,strTermCode
				,strContractItemNo
				,strContractItemName
				,strERPItemNumber
				,strERPBatchNumber
				,strLoadingPoint
				,strPackingDescription
				,strLocationName
				,'System'
				,1
				,RC.ysnMaxPrice
			FROM tblCTContractFeed CF2
			JOIN @tblCTFinalContractFeed CF1 ON CF1.intContractHeaderId = CF2.intContractHeaderId
				AND CF1.strItemNo = CF2.strItemNo
			LEFT JOIN @tblRollUpFinalContract RC ON RC.intContractHeaderId = CF2.intContractHeaderId
			WHERE EXISTS (
					SELECT *
					FROM @tblCTContractFeedHistory CFH
					WHERE CF2.intContractFeedId = CFH.intContractFeedId
					)
				AND NOT EXISTS (
					SELECT *
					FROM tblCTContractFeed CF3
					WHERE CF3.intContractDetailId = CF2.intContractDetailId
						AND CF3.intContractHeaderId = CF2.intContractHeaderId
						AND CF3.strRowState = 'Delete'
						AND IsNULL(CF3.strFeedStatus, '') = ''
					)
		END
	END
END

IF EXISTS (
		SELECT *
		FROM tblCTContractFeed CF
		WHERE ISNULL(strFeedStatus, '') = ''
			AND IsNULL(CF.ysnMaxPrice, 0) = 0
			AND UPPER(strRowState) = 'MODIFIED'
		)
BEGIN
	---********************************************************
	--- Item Change
	---********************************************************
	DELETE
	FROM @tblCTContractFeed2

	INSERT INTO @tblCTContractFeed2 (
		intContractHeaderId
		,intContractSeq
		,strItemNo
		)
	SELECT CF.intContractHeaderId
		,CF.intContractSeq
		,CF.strItemNo
	FROM tblCTContractFeed CF
	WHERE ISNULL(strFeedStatus, '') = ''
		AND IsNULL(CF.ysnMaxPrice, 0) = 0
		AND UPPER(strRowState) = 'MODIFIED'

	DELETE
	FROM @tblCTContractFeedHistory

	INSERT INTO @tblCTContractFeedHistory (
		intContractHeaderId
		,intContractSeq
		,strItemNo
		,intContractFeedId
		)
	SELECT CF2.intContractHeaderId
		,CF2.intContractSeq
		,(
			SELECT TOP 1 CF.strItemNo
			FROM tblCTContractFeed CF
			WHERE CF2.intContractHeaderId = CF.intContractHeaderId
				AND CF2.intContractSeq = CF.intContractSeq
				AND IsNULL(CF.strFeedStatus, '') <> ''
				AND CF.strRowState <> 'DELETE'
			ORDER BY intContractFeedId DESC
			)
		,(
			SELECT TOP 1 CF.intContractFeedId
			FROM tblCTContractFeed CF
			WHERE CF2.intContractHeaderId = CF.intContractHeaderId
				AND CF2.intContractSeq = CF.intContractSeq
				AND IsNULL(CF.strFeedStatus, '') <> ''
				AND CF.strRowState <> 'DELETE'
			ORDER BY intContractFeedId DESC
			)
	FROM @tblCTContractFeed2 CF2

	DELETE CF2
	OUTPUT deleted.intContractHeaderId
		,deleted.intContractSeq
		,deleted.strItemNo
	INTO @tblHoldContract
	FROM @tblCTContractFeed2 CF2
	JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF2.intContractHeaderId
		AND CFH.intContractSeq = CF2.intContractSeq
		AND CFH.strItemNo <> CF2.strItemNo
		AND EXISTS (
			SELECT *
			FROM tblCTContractFeed CF
			WHERE CF.intContractHeaderId = CF2.intContractHeaderId
				AND CF.intContractSeq = CF2.intContractSeq
				AND CF.strFeedStatus = 'Awt Ack'
			)

	UPDATE CF
	SET strFeedStatus = 'Hold'
	FROM tblCTContractFeed CF
	JOIN @tblHoldContract HC ON HC.intContractHeaderId = CF.intContractHeaderId
		AND HC.intContractSeq = CF.intContractSeq
	WHERE IsNULL(strFeedStatus, '') = ''

	IF EXISTS (
			SELECT *
			FROM @tblCTContractFeed2 CF2
			JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF2.intContractHeaderId
				AND CFH.intContractSeq = CF2.intContractSeq
				AND CFH.strItemNo <> CF2.strItemNo
			)
	BEGIN
		UPDATE CF
		SET strRowState = 'Added'
			,strERPPONumber = ''
		FROM tblCTContractFeed CF
		JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF.intContractHeaderId
			AND CFH.intContractSeq = CF.intContractSeq
			AND CFH.strItemNo <> CF.strItemNo
		WHERE IsNULL(strFeedStatus, '') = ''

		DELETE
		FROM @tblCTFinalContractFeed

		INSERT INTO @tblCTFinalContractFeed (
			intContractHeaderId
			,strItemNo
			)
		SELECT DISTINCT CF2.intContractHeaderId
			,CFH.strItemNo
		FROM @tblCTContractFeed2 CF2
		JOIN @tblCTContractFeedHistory CFH ON CFH.intContractHeaderId = CF2.intContractHeaderId
			AND CFH.intContractSeq = CF2.intContractSeq
			AND CFH.strItemNo <> CF2.strItemNo

		INSERT INTO tblCTContractFeed (
			intContractHeaderId
			,intContractDetailId
			,strCommodityCode
			,strCommodityDesc
			,strContractBasis
			,strContractBasisDesc
			,strSubLocation
			,strCreatedBy
			,strCreatedByNo
			,strEntityNo
			,strTerm
			,strPurchasingGroup
			,strContractNumber
			,strERPPONumber
			,intContractSeq
			,strItemNo
			,strStorageLocation
			,dblQuantity
			,dblCashPrice
			,strQuantityUOM
			,dtmPlannedAvailabilityDate
			,dblBasis
			,strCurrency
			,dblUnitCashPrice
			,strPriceUOM
			,strRowState
			,dtmContractDate
			,dtmStartDate
			,dtmEndDate
			,dtmFeedCreated
			,strSubmittedBy
			,strSubmittedByNo
			,strOrigin
			,dblNetWeight
			,strNetWeightUOM
			,strVendorAccountNum
			,strTermCode
			,strContractItemNo
			,strContractItemName
			,strERPItemNumber
			,strERPBatchNumber
			,strLoadingPoint
			,strPackingDescription
			,strLocationName
			,ysnPopulatedByIntegration
			,ysnMaxPrice
			)
		SELECT CF2.intContractHeaderId
			,intContractDetailId
			,strCommodityCode
			,strCommodityDesc
			,strContractBasis
			,strContractBasisDesc
			,strSubLocation
			,strCreatedBy
			,strCreatedByNo
			,strEntityNo
			,strTerm
			,strPurchasingGroup
			,strContractNumber
			,strERPPONumber
			,CF2.intContractSeq
			,CF2.strItemNo
			,strStorageLocation
			,dblQuantity
			,dblCashPrice
			,strQuantityUOM
			,dtmPlannedAvailabilityDate
			,dblBasis
			,strCurrency
			,dblUnitCashPrice
			,strPriceUOM
			,'DELETE'
			,dtmContractDate
			,dtmStartDate
			,dtmEndDate
			,dtmFeedCreated
			,strSubmittedBy
			,strSubmittedByNo
			,strOrigin
			,dblNetWeight
			,strNetWeightUOM
			,strVendorAccountNum
			,strTermCode
			,strContractItemNo
			,strContractItemName
			,strERPItemNumber
			,strERPBatchNumber
			,strLoadingPoint
			,strPackingDescription
			,strLocationName
			,1
			,RC.ysnMaxPrice
		FROM tblCTContractFeed CF2
		JOIN @tblCTFinalContractFeed CF1 ON CF1.intContractHeaderId = CF2.intContractHeaderId
			AND CF1.strItemNo = CF2.strItemNo
		LEFT JOIN @tblRollUpFinalContract RC ON RC.intContractHeaderId = CF2.intContractHeaderId
		WHERE EXISTS (
				SELECT *
				FROM @tblCTContractFeedHistory CFH
				WHERE CF2.intContractFeedId = CFH.intContractFeedId
				)
	END
END

UPDATE CF
SET strFeedStatus = 'IGNORE'
FROM tblCTContractFeed CF
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
WHERE IsNULL(CH.ysnSubstituteItem, 0) = 0
	AND ISNULL(strFeedStatus, '') = ''

UPDATE CF
SET strFeedStatus = ''
FROM tblCTContractFeed CF
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
WHERE IsNULL(CH.ysnSubstituteItem, 0) = 1
	AND ISNULL(strFeedStatus, '') = 'IGNORE'

UPDATE tblCTContractFeed
SET strFeedStatus = 'IGNORE'
WHERE EXISTS (
		SELECT *
		FROM tblIPSAPLocation L
		WHERE L.stri21Location = tblCTContractFeed.strLocationName
			AND IsNULL(L.ysnEnabledERPFeed, 1) = 0
		)
	AND ISNULL(strFeedStatus, '') = ''

UPDATE CF
SET strERPPONumber = CD.strERPPONumber
	,strRowState = 'MODIFIED'
	,strERPItemNumber = CD.strERPItemNumber
FROM tblCTContractFeed CF
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CF.intContractHeaderId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = CD.intSubLocationId
WHERE CF.intContractHeaderId = @intContractHeaderId
	AND ISNULL(CF.strSubLocation, '') = ISNULL(SL.strSubLocationName, '')
	AND ISNULL(strFeedStatus, '') = ''
	AND IsNULL(CF.strERPPONumber, '') = ''
	AND CD.strERPPONumber <> ''
	AND UPPER(strRowState) = 'ADDED'

--Get the Headers
IF UPPER(@strRowState) = 'ADDED'
BEGIN
	INSERT INTO @tblHeader (
		intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,ysnMaxPrice
		,strPrintableRemarks
		,strSalesPerson
		,strItemNo
		)
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,MAX(intContractFeedId) AS intContractFeedId
		,strSubLocation
		,IsNULL(CF.ysnMaxPrice, 0)
		,CH.strPrintableRemarks
		,E.strExternalERPId
		,CF.strItemNo
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND IsNULL(CF.ysnMaxPrice, 0) = 1
		AND Upper(strRowState) = 'ADDED'
	GROUP BY CF.intContractHeaderId
		,strCommodityCode
		,strSubLocation
		,IsNULL(CF.ysnMaxPrice, 0)
		,CH.strPrintableRemarks
		,E.strExternalERPId
		,CF.strItemNo
	
	UNION
	
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,IsNULL(CF.ysnMaxPrice, 0)
		,CH.strPrintableRemarks
		,E.strExternalERPId
		,''
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND IsNULL(CF.ysnMaxPrice, 0) = 0
		AND Upper(strRowState) = 'ADDED'
	ORDER BY CF.intContractHeaderId
END
ELSE
BEGIN
	INSERT INTO @tblHeader (
		intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,ysnMaxPrice
		,strPrintableRemarks
		,strSalesPerson
		,strItemNo
		)
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,MAX(intContractFeedId) AS intContractFeedId
		,strSubLocation
		,IsNULL(CF.ysnMaxPrice, 0)
		,CH.strPrintableRemarks
		,E.strExternalERPId
		,CF.strItemNo
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND IsNULL(CF.ysnMaxPrice, 0) = 1
		AND UPPER(strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)
	GROUP BY CF.intContractHeaderId
		,strCommodityCode
		,strSubLocation
		,IsNULL(CF.ysnMaxPrice, 0)
		,CH.strPrintableRemarks
		,E.strExternalERPId
		,CF.strItemNo
	
	UNION
	
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,IsNULL(CF.ysnMaxPrice, 0)
		,CH.strPrintableRemarks
		,E.strExternalERPId
		,''
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND IsNULL(CF.ysnMaxPrice, 0) = 0
		AND UPPER(strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)
	ORDER BY CF.intContractHeaderId
END

SELECT @intMinRowNo = Min(intRowNo)
FROM @tblHeader

WHILE (@intMinRowNo IS NOT NULL) --Header Loop
BEGIN
	SET @strXml = ''
	SET @strXmlHeaderStart = ''
	SET @strXmlHeaderEnd = ''
	SET @strContractFeedIds = NULL

	SELECT @strPrintableRemarks = ''

	SELECT @strSalesPerson = ''

	SELECT @ysnMaxPrice = 0

	SELECT @strContractItemNo = NULL

	SELECT @strTblRowState = ''

	SELECT @intContractHeaderId = intContractHeaderId
		,@strSubLocation = strSubLocation
		,@intContractFeedId = intContractFeedId
		,@ysnMaxPrice = ysnMaxPrice
		,@strPrintableRemarks = strPrintableRemarks
		,@strSalesPerson = strSalesPerson
		,@strContractItemNo = strItemNo
	FROM @tblHeader
	WHERE intRowNo = @intMinRowNo

	IF @ysnMaxPrice = 1
	BEGIN
		SELECT @strContractFeedIds = ''

		SELECT @strContractFeedIds = @strContractFeedIds + CONVERT(VARCHAR, intContractFeedId) + ','
		FROM tblCTContractFeed
		WHERE intContractHeaderId = @intContractHeaderId
			AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
			AND ISNULL(strFeedStatus, '') = ''
			AND strItemNo = @strContractItemNo

		IF Len(@strContractFeedIds) > 0
			SELECT @strContractFeedIds = Left(@strContractFeedIds, Len(@strContractFeedIds) - 1)

		--Donot generate Modified Idoc if PO No is not there
		IF UPPER(@strRowState) IN (
				'MODIFIED'
				,'DELETE'
				)
			AND (
				SELECT TOP 1 ISNULL(strERPPONumber, '')
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
					AND ISNULL(strFeedStatus, '') = ''
					AND strItemNo = @strContractItemNo
				) = ''
			GOTO NEXT_PO
	END
	ELSE
	BEGIN
		SELECT @intMinSeq = @intContractFeedId

		SELECT @strContractFeedIds = @intContractFeedId

		--Donot generate Modified Idoc if PO No is not there
		IF UPPER(@strRowState) IN (
				'MODIFIED'
				,'DELETE'
				)
			AND (
				SELECT ISNULL(strERPPONumber, '')
				FROM tblCTContractFeed
				WHERE intContractFeedId = @intMinSeq
				) = ''
			GOTO NEXT_PO
	END

	SET @strItemXml = ''
	SET @strItemXXml = ''
	SET @strTextXml = ''
	SET @strSeq = ''

	IF @ysnMaxPrice = 0
	BEGIN
		SELECT @intContractFeedId = intContractFeedId
			,@intContractHeaderId = intContractHeaderId
			,@intContractDetailId = intContractDetailId
			,@strContractBasis = strContractBasis
			,@strSubLocation = strSubLocation
			,@strEntityNo = strVendorAccountNum
			,@strPurchasingGroup = strPurchasingGroup
			,@strContractNumber = strContractNumber
			,@strERPPONumber = strERPPONumber
			,@strERPItemNumber = strERPItemNumber
			,@intContractSeq = intContractSeq
			,@strItemNo = strItemNo
			,@strStorageLocation = strStorageLocation
			,@dblQuantity = dblNetWeight
			,@strQuantityUOM = (
				SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = strNetWeightUOM
				)
			,@dblCashPrice = dblCashPrice
			,@dblUnitCashPrice = dblUnitCashPrice * 100
			,@dtmContractDate = dtmContractDate
			,@dtmStartDate = dtmStartDate
			,@dtmEndDate = dtmEndDate
			,@strCurrency = strCurrency
			,@strPriceUOM = (
				SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = strPriceUOM
				)
			,@strLocationName = strLocationName
			,@strTblRowState = strRowState
		FROM tblCTContractFeed
		WHERE intContractFeedId = @intMinSeq
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND strItemNo = @strContractItemNo
					AND IsNULL(strFeedStatus, '') = ''
					AND UPPer(strRowState) = 'MODIFIED'
				)
		BEGIN
			SELECT @intContractFeedId = MAX(intContractFeedId)
				,@intContractDetailId = MAX(intContractDetailId)
				,@strContractBasis = strContractBasis
				,@strSubLocation = strSubLocation
				,@strEntityNo = strVendorAccountNum
				,@strPurchasingGroup = strPurchasingGroup
				,@strContractNumber = strContractNumber
				,@strERPPONumber = strERPPONumber
				,@strERPItemNumber = strERPItemNumber
				,@intContractSeq = Min(intContractSeq)
				,@strItemNo = strItemNo
				,@strStorageLocation = strStorageLocation
				,@dblQuantity = SUM(dblNetWeight)
				,@strQuantityUOM = (
					SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = strNetWeightUOM
					)
				,@dblCashPrice = SUM(dblCashPrice * dblNetWeight) / SUM(dblNetWeight)
				,@dblUnitCashPrice = SUM(dblUnitCashPrice * 100 * dblNetWeight) / SUM(dblNetWeight)
				,@dtmContractDate = dtmContractDate
				,@dtmStartDate = Min(dtmStartDate)
				,@dtmEndDate = MAX(dtmEndDate)
				,@strCurrency = strCurrency
				,@strPriceUOM = (
					SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = strPriceUOM
					)
				,@strLocationName = strLocationName
				,@strTblRowState = strRowState
			FROM tblCTContractFeed
			WHERE intContractHeaderId = @intContractHeaderId
				AND strItemNo = @strContractItemNo
				AND IsNULL(strFeedStatus, '') = ''
				AND UPPER(strRowState) <> 'DELETE'
			GROUP BY strContractBasis
				,strSubLocation
				,strVendorAccountNum
				,strPurchasingGroup
				,strContractNumber
				,strERPPONumber
				,strERPItemNumber
				,strItemNo
				,strStorageLocation
				,strNetWeightUOM
				,dtmContractDate
				,strCurrency
				,strPriceUOM
				,strLocationName
				,strRowState
		END
		ELSE
		BEGIN
			SELECT @intContractFeedId = MAX(intContractFeedId)
				,@intContractDetailId = MAX(intContractDetailId)
				,@strContractBasis = strContractBasis
				,@strSubLocation = strSubLocation
				,@strEntityNo = strVendorAccountNum
				,@strPurchasingGroup = strPurchasingGroup
				,@strContractNumber = strContractNumber
				,@strERPPONumber = strERPPONumber
				,@strERPItemNumber = strERPItemNumber
				,@intContractSeq = Min(intContractSeq)
				,@strItemNo = strItemNo
				,@strStorageLocation = strStorageLocation
				,@dblQuantity = SUM(dblNetWeight)
				,@strQuantityUOM = (
					SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = strNetWeightUOM
					)
				,@dblCashPrice = SUM(dblCashPrice * dblNetWeight) / SUM(dblNetWeight)
				,@dblUnitCashPrice = SUM(dblUnitCashPrice * 100 * dblNetWeight) / SUM(dblNetWeight)
				,@dtmContractDate = dtmContractDate
				,@dtmStartDate = Min(dtmStartDate)
				,@dtmEndDate = MAX(dtmEndDate)
				,@strCurrency = strCurrency
				,@strPriceUOM = (
					SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = strPriceUOM
					)
				,@strLocationName = strLocationName
				,@strTblRowState = strRowState
			FROM tblCTContractFeed
			WHERE intContractHeaderId = @intContractHeaderId
				AND strItemNo = @strContractItemNo
				AND IsNULL(strFeedStatus, '') = ''
			GROUP BY strContractBasis
				,strSubLocation
				,strVendorAccountNum
				,strPurchasingGroup
				,strContractNumber
				,strERPPONumber
				,strERPItemNumber
				,strItemNo
				,strStorageLocation
				,strNetWeightUOM
				,dtmContractDate
				,strCurrency
				,strPriceUOM
				,strLocationName
				,strRowState
		END
	END

	SELECT @strSAPLocation = strSAPLocation
	FROM tblIPSAPLocation
	WHERE stri21Location = @strLocationName

	IF IsNULL(@strSAPLocation, '') = ''
	BEGIN
		IF @ysnMaxPrice = 0
		BEGIN
			UPDATE tblCTContractFeed
			SET strMessage = 'SAP Location is not configured in i21.'
			WHERE intContractFeedId = @intContractFeedId
				AND ISNULL(strFeedStatus, '') = ''
		END
		ELSE
		BEGIN
			UPDATE tblCTContractFeed
			SET strMessage = 'SAP Location is not configured in i21.'
			WHERE intContractHeaderId = @intContractHeaderId
				AND ISNULL(strFeedStatus, '') = ''
				AND strItemNo = @strContractItemNo
		END

		GOTO NEXT_PO
	END

	--Send Create Feed only Once
	IF UPPER(@strRowState) = 'ADDED'
		AND (
			SELECT TOP 1 UPPER(strRowState)
			FROM tblCTContractFeed
			WHERE intContractDetailId = @intContractDetailId
				AND ISNULL(strFeedStatus, '') = ''
				AND intContractFeedId < @intContractFeedId
			ORDER BY intContractFeedId
			) = 'ADDED'
		AND @ysnMaxPrice = 0
		GOTO NEXT_PO

	SET @strSeq = ISNULL(@strSeq, '') + CONVERT(VARCHAR, @intContractSeq) + ','

	--Convert price USC to USD
	IF UPPER(@strCurrency) = 'USC'
	BEGIN
		SET @strCurrency = 'USD'
		SET @dblBasis = ISNULL(@dblBasis, 0) / 100
		SET @dblCashPrice = ISNULL(@dblCashPrice, 0) / 100
		SET @dblUnitCashPrice = ISNULL(@dblUnitCashPrice, 0) / 100
	END

	--Header Start Xml
	IF ISNULL(@strXmlHeaderStart, '') = ''
	BEGIN
		IF UPPER(@strRowState) = 'ADDED'
		BEGIN
			SET @strXmlHeaderStart = '<PURCONTRACT_CREATE01>'
			SET @strXmlHeaderStart += '<IDOC>'
			--IDOC Header
			SET @strXmlHeaderStart += '<EDI_DC40>'
			SET @strXmlHeaderStart += @strPOCreateIDOCHeader
			SET @strXmlHeaderStart += '<MESCOD>' + ISNULL(@strMessageCode, '') + '</MESCOD>'
			SET @strXmlHeaderStart += '</EDI_DC40>'
			SET @strXmlHeaderStart += '<E1PURCONTRACT_CREATE>'
			--Header
			SET @strXmlHeaderStart += '<E1BPMEOUTHEADER>'
			SET @strXmlHeaderStart += '<COMP_CODE>' + ISNULL(@strPurchasingGroup, '') + '</COMP_CODE>'
			SET @strXmlHeaderStart += '<DOC_TYPE>' + ISNULL('MK', '') + '</DOC_TYPE>'
			SET @strXmlHeaderStart += '<CREAT_DATE>' + ISNULL(CONVERT(VARCHAR(10), @dtmContractDate, 112), '') + '</CREAT_DATE>'
			SET @strXmlHeaderStart += '<VENDOR>' + ISNULL(@strEntityNo, '') + '</VENDOR>'
			SET @strXmlHeaderStart += '<PURCH_ORG>' + ISNULL(@strSAPLocation, '') + '</PURCH_ORG>'
			SET @strXmlHeaderStart += '<PUR_GROUP>' + ISNULL(@strSalesPerson, '') + '</PUR_GROUP>'
			SET @strXmlHeaderStart += '<VPER_START>' + ISNULL(CONVERT(VARCHAR(10), @dtmStartDate, 112), '') + '</VPER_START>'
			SET @strXmlHeaderStart += '<VPER_END>' + ISNULL(CONVERT(VARCHAR(10), @dtmEndDate, 112), '') + '</VPER_END>'
			SET @strXmlHeaderStart += '<REF_1>' + ISNULL(RIGHT(@str12Zeros + @strContractNumber, 12), '') + '</REF_1>'
			SET @strXmlHeaderStart += '<INCOTERMS1>' + dbo.fnEscapeXML(ISNULL(@strContractBasis, '')) + '</INCOTERMS1>'
			SET @strXmlHeaderStart += '<INCOTERMS2>' + dbo.fnEscapeXML(ISNULL('', '')) + '</INCOTERMS2>'
			SET @strXmlHeaderStart += '</E1BPMEOUTHEADER>'
		END
	END

	--Item
	IF UPPER(@strRowState) = 'ADDED'
	BEGIN
		SET @strItemXml += '<E1BPMEOUTITEM>'
		SET @strItemXml += '<MATERIAL>' + dbo.fnEscapeXML(ISNULL(Replace(@strItemNo, '-', ''), '')) + '</MATERIAL>'
		SET @strItemXml += '<PLANT>' + ISNULL(@strSubLocation, '') + '</PLANT>'
		SET @strItemXml += '<TRACKINGNO>' + ISNULL(RIGHT('000' + CONVERT(VARCHAR, @intContractSeq), 3), '') + '</TRACKINGNO>'
		SET @strItemXml += '<TARGET_QTY>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblQuantity)), '') + '</TARGET_QTY>'
		SET @strItemXml += '<PO_UNIT>' + ISNULL(@strQuantityUOM, '') + '</PO_UNIT>'
		SET @strItemXml += '<ORDERPR_UN>' + ISNULL(@strPriceUOM, '') + '</ORDERPR_UN>'
		SET @strItemXml += '<NET_PRICE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblUnitCashPrice)), '0.00') + '</NET_PRICE>'
		SET @strItemXml += '<PRICE_UNIT>' + '1' + '</PRICE_UNIT>'
		SET @strItemXml += '<TAX_CODE>' + 'S0' + '</TAX_CODE>'
		SET @strItemXml += '</E1BPMEOUTITEM>'
	END

	IF ISNULL(@strXmlHeaderStart, '') = ''
	BEGIN
		IF UPPER(@strRowState) <> 'ADDED'
		BEGIN
			SET @strXmlHeaderStart = '<PURCONTRACT_CHANGE01>'
			SET @strXmlHeaderStart += '<IDOC>'
			--IDOC Header
			SET @strXmlHeaderStart += '<EDI_DC40>'
			SET @strXmlHeaderStart += @strPOUpdateIDOCHeader
			SET @strXmlHeaderStart += '<MESCOD>' + ISNULL(@strMessageCode, '') + '</MESCOD>'
			SET @strXmlHeaderStart += '</EDI_DC40>'
			SET @strXmlHeaderStart += '<E1PURCONTRACT_CHANGE>'
			SET @strXmlHeaderStart += '<PURCHASINGDOCUMENT>' + ISNULL(@strERPPONumber, '') + '</PURCHASINGDOCUMENT>'
			SET @strXmlHeaderStart += '<E1BPMEOUTHEADER>'
			SET @strXmlHeaderStart += '<NUMBER>' + ISNULL(@strERPPONumber, '') + '</NUMBER>'
			SET @strXmlHeaderStart += '<COMP_CODE>' + ISNULL(@strPurchasingGroup, '') + '</COMP_CODE>'
			SET @strXmlHeaderStart += '<VPER_START>' + ISNULL(CONVERT(VARCHAR(10), @dtmStartDate, 112), '') + '</VPER_START>'
			SET @strXmlHeaderStart += '<VPER_END>' + ISNULL(CONVERT(VARCHAR(10), @dtmEndDate, 112), '') + '</VPER_END>'
			SET @strXmlHeaderStart += '<INCOTERMS1>' + dbo.fnEscapeXML(ISNULL(@strContractBasis, '')) + '</INCOTERMS1>'
			SET @strXmlHeaderStart += '<INCOTERMS2>' + dbo.fnEscapeXML(ISNULL('', '')) + '</INCOTERMS2>'
			SET @strXmlHeaderStart += '</E1BPMEOUTHEADER>'
		END
	END

	IF UPPER(@strRowState) <> 'ADDED'
	BEGIN
		SET @strItemXml += '<E1BPMEOUTITEM>'
		SET @strItemXml += '<ITEM_NO>' + dbo.fnEscapeXML(ISNULL(@strERPItemNumber, '')) + '</ITEM_NO>'

		IF NOT EXISTS (
				SELECT *
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND strItemNo = @strContractItemNo
					AND IsNULL(strFeedStatus, '') = ''
					AND UPPER(strRowState) = 'MODIFIED'
				)
			AND @ysnMaxPrice = 1
		BEGIN
			SET @strItemXml += '<DELETE_IND>' + 'L' + '</DELETE_IND>'
		END

		IF @ysnMaxPrice = 0
		BEGIN
			IF UPPER(@strTblRowState) = 'DELETE'
			BEGIN
				SET @strItemXml += '<DELETE_IND>' + 'L' + '</DELETE_IND>'
			END
		END

		SET @strItemXml += '<TARGET_QTY>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblQuantity)), '') + '</TARGET_QTY>'
		--SET @strItemXml += '<NET_PRICE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblUnitCashPrice)), '0.00') + '</NET_PRICE>'
		SET @strItemXml += '<TAX_CODE>' + 'S0' + '</TAX_CODE>'
		SET @strItemXml += '</E1BPMEOUTITEM>'
		SET @strItemXml += '<E1BPMEOUTITEMX>'
		SET @strItemXml += '<ITEM_NO>' + dbo.fnEscapeXML(ISNULL(@strERPItemNumber, '')) + '</ITEM_NO>'
		SET @strItemXml += '</E1BPMEOUTITEMX>'
		SET @strItemXml += '<E1BPMEOUTVALIDITY>'
		SET @strItemXml += '<ITEM_NO>' + '00010' + '</ITEM_NO>'
		SET @strItemXml += '<VALID_FROM>' + ISNULL(CONVERT(VARCHAR(10), GETDATE(), 112), '') + '</VALID_FROM>'
		SET @strItemXml += '<VALID_TO>' + '99991231' + '</VALID_TO>'
		SET @strItemXml += '</E1BPMEOUTVALIDITY>'
		SET @strItemXml += '<E1BPMEOUTVALIDITYX>'
		SET @strItemXml += '<ITEM_NO>' + '00010' + '</ITEM_NO>'
		SET @strItemXml += '<VALID_FROM>' + 'X' + '</VALID_FROM>'
		SET @strItemXml += '<VALID_TO>' + 'X' + '</VALID_TO>'
		SET @strItemXml += '</E1BPMEOUTVALIDITYX>'
		SET @strItemXml += '<E1BPMEOUTCONDITION>'
		SET @strItemXml += '<ITEM_NO>' + '00010' + '</ITEM_NO>'
		SET @strItemXml += '<COND_COUNT>' + '01' + '</COND_COUNT>'
		SET @strItemXml += '<COND_TYPE>' + 'PB00' + '</COND_TYPE>'
		SET @strItemXml += '<COND_VALUE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblUnitCashPrice)), '0.00') + '</COND_VALUE>'
		SET @strItemXml += '<CURRENCY>' + ISNULL(@strCurrency, '') + '</CURRENCY>'
		SET @strItemXml += '<COND_P_UNT>' + '1' + '</COND_P_UNT>'
		SET @strItemXml += '<COND_UNIT>' + ISNULL(@strPriceUOM, '') + '</COND_UNIT>'
		SET @strItemXml += '<CHANGE_ID>' + 'U' + '</CHANGE_ID>'
		SET @strItemXml += '</E1BPMEOUTCONDITION>'
		SET @strItemXml += '<E1BPMEOUTCONDITIONX>'
		SET @strItemXml += '<ITEM_NO>' + '00010' + '</ITEM_NO>'
		SET @strItemXml += '<COND_COUNT>' + '01' + '</COND_COUNT>'
		SET @strItemXml += '<ITEM_NOX>' + 'X' + '</ITEM_NOX>'
		SET @strItemXml += '<COND_TYPE>' + 'X' + '</COND_TYPE>'
		SET @strItemXml += '<COND_VALUE>' + 'X' + '</COND_VALUE>'
		SET @strItemXml += '<CURRENCY>' + 'X' + '</CURRENCY>'
		SET @strItemXml += '<COND_P_UNT>' + 'X' + '</COND_P_UNT>'
		SET @strItemXml += '<COND_UNIT>' + 'X' + '</COND_UNIT>'
		SET @strItemXml += '</E1BPMEOUTCONDITIONX>'
	END

	--Header End Xml
	IF ISNULL(@strXmlHeaderEnd, '') = ''
	BEGIN
		SET @strTextXml += '<E1BPMEOUTTEXT>'
		SET @strTextXml += '<TEXT_LINE>' + ISNULL(@strPrintableRemarks, '') + '</TEXT_LINE>'
		SET @strTextXml += '</E1BPMEOUTTEXT>'

		IF UPPER(@strRowState) = 'ADDED'
		BEGIN
			SET @strXmlHeaderEnd += '</E1PURCONTRACT_CREATE>'
			SET @strXmlHeaderEnd += '</IDOC>'
			SET @strXmlHeaderEnd += '</PURCONTRACT_CREATE01>'
		END

		IF UPPER(@strRowState) <> 'ADDED'
		BEGIN
			SET @strXmlHeaderEnd += '</E1PURCONTRACT_CHANGE>'
			SET @strXmlHeaderEnd += '</IDOC>'
			SET @strXmlHeaderEnd += '</PURCONTRACT_CHANGE01>'
		END
	END

	--Final Xml
	SET @strXml = @strXmlHeaderStart + @strItemXml + @strTextXml + @strXmlHeaderEnd

	IF @ysnUpdateFeedStatusOnRead = 1
	BEGIN
		DECLARE @strSql NVARCHAR(max) = 'Update tblCTContractFeed Set strFeedStatus=''Awt Ack'' Where intContractFeedId IN (' + @strContractFeedIds + ')'

		EXEC sp_executesql @strSql
	END

	SET @strSeq = LTRIM(RTRIM(LEFT(@strSeq, LEN(@strSeq) - 1)))

	INSERT INTO @tblOutput (
		strContractFeedIds
		,strRowState
		,strXml
		,strContractNo
		,strPONo
		)
	VALUES (
		@strContractFeedIds
		,CASE 
			WHEN UPPER(@strRowState) = 'ADDED'
				THEN 'CREATE'
			ELSE 'UPDATE'
			END
		,@strXml
		,ISNULL(@strContractNumber, '') + ' / ' + ISNULL(@strSeq, '')
		,ISNULL(@strERPPONumber, '')
		)

	NEXT_PO:

	SELECT @intMinRowNo = Min(intRowNo)
	FROM @tblHeader
	WHERE intRowNo > @intMinRowNo
END --End Header Loop

SELECT IsNULL(strContractFeedIds, '0') AS id
	,IsNULL(strXml, '') AS strXml
	,IsNULL(strContractNo, '') AS strInfo1
	,IsNULL(strPONo, '') AS strInfo2
	,'' AS strOnFailureCallbackSql
FROM @tblOutput
ORDER BY intRowNo
