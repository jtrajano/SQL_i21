﻿CREATE PROCEDURE uspValidateShippingAdvice 
	 @intLoadId INT
	,@strMessage NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN TRY
	DECLARE @intMinRecordId INT
	DECLARE @intMinRejectedRecordId INT
	DECLARE @intMinQuantityRecordId INT
	DECLARE @intContractDetailId INT
	DECLARE @strContractNumber NVARCHAR(100)
	DECLARE @intContractSeq INT
	DECLARE @strContractSeq NVARCHAR(100)
	DECLARE @dblLoadQty NUMERIC(18, 6)
	DECLARE @dblContainerQty NUMERIC(18, 6)
	DECLARE @dblApprovedSampleQty NUMERIC(18, 6)
	DECLARE @strSampleNumber NVARCHAR(100)
	DECLARE @strSampleStatus NVARCHAR(100)
	DECLARE @strErrorMessage NVARCHAR(MAX)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @tblContractSampleDetail TABLE (
		intRecordId INT Identity(1, 1)
		,intContractDetailId INT
		,strContractNumber NVARCHAR(100)
		,intContractSeq INT
		,strContractSeq NVARCHAR(100)
		,dblLoadQty NUMERIC(18, 6)
		,dblContainerQty NUMERIC(18, 6)
		,strSampleNumber NVARCHAR(100)
		,strSampleStatus NVARCHAR(100)
		)
	DECLARE @tblContractSampleQuantityDetail TABLE (
		intRecordId INT Identity(1, 1)
		,intContractDetailId INT
		,strContractNumber NVARCHAR(100)
		,strContractSeq NVARCHAR(100)
		,dblLoadQty NUMERIC(18, 6)
		,dblSampleQty NUMERIC(18, 6)
		)

	IF OBJECT_ID('tempdb..#tempContractSampleQuantityDetail') IS NOT NULL
		DROP TABLE #tempContractSampleQuantityDetail

	IF OBJECT_ID('tempdb..#tempContractSampleDetail') IS NOT NULL
		DROP TABLE #tempContractSampleDetail

	SELECT C.intContractDetailId
		,C.strContractNumber
		,C.intContractSeq
		,C.strContractNumber + '/' + CONVERT(NVARCHAR, C.intContractSeq) AS strContractSeq
		,dblLoadQty = LD.dblQuantity
		,dblContainerQty = S.dblRepresentingQty
		,strSampleNumber
		,strSampleStatus
		,C.ysnSampleRequired
	INTO #tempContractSampleDetail
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN vyuLGLoadOpenContracts C ON LD.intPContractDetailId = C.intContractDetailId
	OUTER APPLY (
		SELECT TOP 1 
			dblRepresentingQty = ISNULL(dbo.fnCalculateQtyBetweenUOM(S.intRepresentingUOMId, CD.intItemUOMId, S.dblRepresentingQty), 0)
		FROM tblQMSample S 
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
		WHERE S.intContractDetailId = C.intContractDetailId
		ORDER BY S.dtmTestingEndDate DESC, S.intSampleId DESC) S 
	WHERE L.intLoadId = @intLoadId
		AND C.intShipmentType = 1

	SELECT C.intContractDetailId
		,C.strContractNumber
		,C.strContractNumber + '/' + CONVERT(NVARCHAR, C.intContractSeq) AS strContractSeq
		,dblLoadQty = LD.dblQuantity 
		,C.ysnSampleRequired
		,dblSampleQty = S.dblSampleQty
	INTO #tempContractSampleQuantityDetail
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN vyuLGLoadOpenContracts C ON LD.intPContractDetailId = C.intContractDetailId
	OUTER APPLY (
		SELECT dblSampleQty = ISNULL(SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM(s.intRepresentingUOMId, cd.intItemUOMId, s.dblRepresentingQty), 0)), 0)
		 FROM tblQMSample s 
		 INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = s.intContractDetailId
		WHERE s.intContractDetailId = C.intContractDetailId AND s.intProductTypeId = 8 AND s.intSampleStatusId <> 4) S
	WHERE L.intLoadId = @intLoadId
		AND C.intShipmentType = 1

	INSERT INTO @tblContractSampleDetail
	SELECT intContractDetailId
		,strContractNumber
		,intContractSeq
		,strContractSeq
		,dblLoadQty
		,dblContainerQty
		,strSampleNumber
		,strSampleStatus
	FROM #tempContractSampleDetail WHERE ISNULL(ysnSampleRequired, 0) = 1

	INSERT INTO @tblContractSampleQuantityDetail
	SELECT intContractDetailId
		,strContractNumber
		,strContractSeq
		,dblLoadQty
		,dblSampleQty
	FROM #tempContractSampleQuantityDetail WHERE ISNULL(ysnSampleRequired, 0) = 1

	SELECT @intMinRecordId = MIN(intRecordId)
	FROM @tblContractSampleDetail

	WHILE (@intMinRecordId IS NOT NULL)
	BEGIN
		SET @intContractDetailId = NULL
		SET @strContractNumber = NULL
		SET @intContractSeq = NULL
		SET @strContractSeq = NULL
		SET @dblLoadQty = NULL
		SET @dblContainerQty = NULL
		SET @strSampleNumber = NULL
		SET @strSampleStatus = NULL

		SELECT @intContractDetailId = intContractDetailId
			,@strContractNumber = strContractNumber
			,@intContractSeq = intContractSeq
			,@strContractSeq = strContractSeq
			,@dblLoadQty = dblLoadQty
			,@dblContainerQty = dblContainerQty
			,@strSampleNumber = strSampleNumber
			,@strSampleStatus = strSampleStatus
		FROM @tblContractSampleDetail
		WHERE intRecordId = @intMinRecordId

		IF (ISNULL(@strSampleNumber, '') = '')
		BEGIN
			SET @strErrorMessage = 'Sample(s) have not been received for the contract ' + @strContractSeq + '.'
		END
		ELSE IF (ISNULL(@strSampleStatus, '') = 'Rejected')
		BEGIN
			SET @strErrorMessage = 'Sample(s) were rejected for the contract ' + @strContractSeq + '.'
		END

		IF (ISNULL(@strMessage, '') = '')
		BEGIN
			SET @strMessage = @strErrorMessage
		END
		ELSE
		BEGIN
			SET @strMessage = @strMessage + CASE WHEN (ISNULL(@strErrorMessage, '') <> '') THEN '<br>' + @strErrorMessage ELSE '' END
		END

		SELECT @intMinRecordId = MIN(intRecordId)
		FROM @tblContractSampleDetail
		WHERE intRecordId > @intMinRecordId
	END

	IF (ISNULL(@strMessage, '') = '')
	BEGIN
		SELECT @intMinQuantityRecordId = MIN(intRecordId)
		FROM @tblContractSampleQuantityDetail

		SET @strErrorMessage = NULL
		WHILE (@intMinQuantityRecordId IS NOT NULL)
		BEGIN
			SET @intContractDetailId = NULL
			SET @strContractNumber = NULL
			SET @intContractSeq = NULL
			SET @strContractSeq = NULL
			SET @dblLoadQty = NULL
			SET @dblContainerQty = NULL
			SET @strSampleNumber = NULL
			SET @strSampleStatus = NULL

			SELECT @intContractDetailId = intContractDetailId
				,@strContractNumber = strContractNumber
				,@strContractSeq = strContractSeq
				,@dblLoadQty = dblLoadQty
				,@dblApprovedSampleQty = dblSampleQty
			FROM @tblContractSampleQuantityDetail
			WHERE intRecordId = @intMinQuantityRecordId

			IF (ISNULL(@dblLoadQty, 0) > ISNULL(@dblApprovedSampleQty, 0))
			BEGIN
				SET @strErrorMessage = 'Shipment qty is more than the approved sample qty for the contract ' + @strContractSeq + '.'
			END

			IF (ISNULL(@strMessage, '') = '')
			BEGIN
				SET @strMessage = @strErrorMessage
			END
			ELSE
			BEGIN
				SET @strMessage = @strMessage + CASE WHEN (ISNULL(@strErrorMessage, '') <> '') THEN '<br>' + @strErrorMessage ELSE '' END
			END

			SELECT @intMinQuantityRecordId = MIN(intRecordId)
			FROM @tblContractSampleQuantityDetail
			WHERE intRecordId > @intMinQuantityRecordId
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH