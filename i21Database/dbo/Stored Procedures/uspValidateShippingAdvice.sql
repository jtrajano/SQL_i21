CREATE PROCEDURE uspValidateShippingAdvice 
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

	INSERT INTO @tblContractSampleDetail
	SELECT C.intContractDetailId
		,C.strContractNumber
		,C.intContractSeq
		,C.strContractNumber + '/' + CONVERT(NVARCHAR, C.intContractSeq) AS strContractSeq
		,LD.dblQuantity AS dblLoadQty
		,dblContainerQty
		,strSampleNumber
		,strSampleStatus
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN vyuLGLoadOpenContracts C ON LD.intPContractDetailId = C.intContractDetailId
	WHERE L.intLoadId = @intLoadId
		AND ISNULL(C.ysnSampleRequired, 0) = 1
		AND C.intShipmentType = 1

	INSERT INTO @tblContractSampleQuantityDetail
	SELECT C.intContractDetailId
		,C.strContractNumber
		,C.strContractNumber + '/' + CONVERT(NVARCHAR, C.intContractSeq) AS strContractSeq
		,LD.dblQuantity AS dblLoadQty
		,(
			SELECT ISNULL(SUM(SA.dblRepresentingQty), 0)
			FROM tblQMSample SA
			WHERE SA.intContractDetailId = C.intContractDetailId
				AND SA.intSampleStatusId = 3
			) dblSampleQty
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN vyuLGLoadOpenContracts C ON LD.intPContractDetailId = C.intContractDetailId
	LEFT JOIN tblQMSample S ON S.intContractDetailId = C.intContractDetailId
	WHERE L.intLoadId = @intLoadId
		AND ISNULL(C.ysnSampleRequired, 0) = 1
		AND C.intShipmentType = 1
		AND S.intProductTypeId = 8
		AND S.intSampleStatusId <> 4
	GROUP BY C.intContractDetailId
		,C.strContractNumber
		,C.intContractSeq
		,C.intContractSeq
		,LD.dblQuantity
		,intSampleStatusId

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
			AND NOT EXISTS (
				SELECT TOP 1 1
				FROM tblQMSample S
				JOIN tblQMSampleStatus SS ON S.intSampleStatusId = SS.intSampleStatusId
				WHERE S.intContractDetailId = 14641
					AND SS.strStatus = 'Approved'
				)
		BEGIN
			SET @strErrorMessage = 'Sample(s) were rejected for the contract ' + @strContractSeq + '.'
		END

		IF (ISNULL(@strMessage, '') = '')
		BEGIN
			SET @strMessage = @strErrorMessage
		END
		ELSE
		BEGIN
			SET @strMessage = @strMessage + '<br>' + @strErrorMessage
		END

		SELECT @intMinRecordId = MIN(intRecordId)
		FROM @tblContractSampleDetail
		WHERE intRecordId > @intMinRecordId
	END

	SELECT @intMinQuantityRecordId = MIN(intRecordId)
	FROM @tblContractSampleQuantityDetail

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
			SET @strMessage = @strMessage + '<br>' + @strErrorMessage
		END

		SELECT @intMinQuantityRecordId = MIN(intRecordId)
		FROM @tblContractSampleQuantityDetail
		WHERE intRecordId > @intMinQuantityRecordId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH