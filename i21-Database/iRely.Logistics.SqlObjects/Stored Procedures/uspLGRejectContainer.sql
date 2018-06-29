CREATE PROCEDURE uspLGRejectContainer
				@intLoadContainerId INT,
				@intContractDetailId INT,
				@ysnRejectContainer BIT = 1,
				@intEntityUserId INT,
				@strScreenName NVARCHAR(100) = 'Load/Shipment Schedule'
AS

BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadContainerNumber NVARCHAR(100)
	DECLARE @intLoadDetailContainerLinkId INT
	DECLARE @dblContainerLinkQty NUMERIC(18,6)
	DECLARE @intLoadDetailId INT
	DECLARE @intLoadDetailItemUOMId INT
	DECLARE @strContractType NVARCHAR(100)
	DECLARE @intRecordId INT
	DECLARE @strReceiptNumber NVARCHAR(100)
	DECLARE @tblLoadContract TABLE 
			(intRecordId INT Identity(1, 1)
			,intContractDetailId INT
			,intLoadDetailId INT
			,intLoadDetailItemUOMId INT
			,dblLinkQty NUMERIC(18, 6))

	SELECT @intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
		  ,@strLoadContainerNumber = LC.strContainerNumber
	FROM tblLGLoadContainer LC
	JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE LDCL.intLoadContainerId = @intLoadContainerId
		AND LD.intPContractDetailId = @intContractDetailId

	SELECT @strContractType = strContractType
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	WHERE CD.intContractDetailId = @intContractDetailId
	
	IF EXISTS (SELECT 1 FROM tblLGLoadContainer WHERE intLoadContainerId = @intLoadContainerId AND ISNULL(ysnRejected,0) = 1 AND @ysnRejectContainer = 1)
	BEGIN
		RETURN;
	END	

	IF EXISTS (SELECT 1 FROM tblLGLoadContainer WHERE intLoadContainerId = @intLoadContainerId AND ISNULL(ysnRejected,0) = 0 AND @ysnRejectContainer = 0) 
	BEGIN
		RETURN;
	END	

	BEGIN TRANSACTION

		UPDATE LC
			SET LC.ysnRejected = @ysnRejectContainer
		FROM tblLGLoadContainer LC
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
		WHERE LDCL.intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId

		IF (@strContractType = 'Purchase')
			BEGIN
				INSERT INTO @tblLoadContract
				SELECT CD.intContractDetailId
						,LD.intLoadDetailId
						,LD.intItemUOMId
						,LDCL.dblQuantity
				FROM tblLGLoadContainer LC
				JOIN tblLGLoadDetailContainerLink LDCL ON LC.intLoadContainerId = LDCL.intLoadContainerId
				JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
				JOIN tblCTContractDetail CD ON LD.intPContractDetailId = CD.intContractDetailId
				WHERE LC.intLoadContainerId = @intLoadContainerId
			END
		ELSE IF (@strContractType = 'Sale')
			BEGIN
				INSERT INTO @tblLoadContract
				SELECT CD.intContractDetailId
						,LD.intLoadDetailId
						,LD.intItemUOMId
						,LDCL.dblQuantity
				FROM tblLGLoadContainer LC
				JOIN tblLGLoadDetailContainerLink LDCL ON LC.intLoadContainerId = LDCL.intLoadContainerId
				JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
				JOIN tblCTContractDetail CD ON LD.intSContractDetailId = CD.intContractDetailId
				WHERE LC.intLoadContainerId = @intLoadContainerId
			END

		SELECT @intRecordId = MIN(intRecordId) FROM @tblLoadContract
			
		WHILE (@intRecordId IS NOT NULL)

		BEGIN

			SET @intContractDetailId	= NULL
			SET @dblContainerLinkQty	= NULL
			SET @intLoadDetailId		= NULL
			SET @intLoadDetailItemUOMId	= NULL
				
			SELECT @intContractDetailId = intContractDetailId
					,@intLoadDetailId = intLoadDetailId
					,@dblContainerLinkQty = CASE WHEN @ysnRejectContainer = 1 THEN -1 * dblLinkQty ELSE  dblLinkQty END 
					,@intLoadDetailItemUOMId = intLoadDetailItemUOMId
			FROM @tblLoadContract WHERE intRecordId = @intRecordId

			EXEC uspCTUpdateScheduleQuantityUsingUOM
							@intContractDetailId	= @intContractDetailId,
							@dblQuantityToUpdate	= @dblContainerLinkQty,
							@intUserId				= @intEntityUserId,
							@intExternalId			= @intLoadDetailId,
							@strScreenName			= @strScreenName,
							@intSourceItemUOMId		= @intLoadDetailItemUOMId
				
			SELECT @intRecordId = MIN(intRecordId) FROM @tblLoadContract WHERE intRecordId > @intRecordId

		END

	COMMIT TRANSACTION

END TRY

BEGIN CATCH
		IF XACT_STATE() != 0
			AND @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		SET @strErrMsg = ERROR_MESSAGE()  
		RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH