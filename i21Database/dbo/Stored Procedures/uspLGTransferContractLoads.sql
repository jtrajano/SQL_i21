CREATE PROCEDURE uspLGTransferContractLoads
     @intOldContractDetailId INT
	,@intNewContractDetailId INT
	,@intUserId INT

AS 
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(Max)
		   ,@intLoadDetailId INT
		   ,@intLoadId INT
		   ,@intNewLoadId INT
		   ,@strLoadNumber NVARCHAR(100)
		   ,@strNewLoadNumber NVARCHAR(100)
		   ,@intNewItemId INT
		   ,@intOldItemId INT
		   ,@intNewItemUOMId INT
		   ,@intOldItemUOMId INT
		   ,@intNewWeightItemUOMId INT
		   ,@intOldWeightItemUOMId INT
		   ,@intLoadUnitMeasureId INT
		   ,@strNewContractNumber NVARCHAR(100)
		   ,@strOldContractNumber NVARCHAR(100)
		   ,@intOldContractSeq INT
		   ,@intNewContractSeq INT
		   ,@dblOldContractDetailQty NUMERIC(18,6)
		   ,@dblNewContractDetailQty NUMERIC(18,6)

	DECLARE @intRecordId INT
	DECLARE @dblLoadDetailQuantity NUMERIC(18,6)
	DECLARE @dblSourceLoadDetailQuantity NUMERIC(18,6)
	DECLARE @dblDestLoadDetailQuantity NUMERIC(18,6)
	DECLARE @tblLoadDetail TABLE 
	(intRecordId INT Identity(1, 1),
	intLoadDetailId INT,
	dblQuantity NUMERIC(18, 6)
	)

	SELECT @intLoadId = LD.intLoadId,
		   @strLoadNumber = L.strLoadNumber,
		   @intLoadUnitMeasureId = L.intWeightUnitMeasureId,
		   @intLoadDetailId = LD.intLoadDetailId,
		   @dblNewContractDetailQty = LD.dblQuantity
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	WHERE (intPContractDetailId = @intOldContractDetailId
		   OR intSContractDetailId = @intOldContractDetailId)
	
	SET @dblOldContractDetailQty = - @dblNewContractDetailQty

	SELECT @intNewLoadId = LD.intLoadId,
		   @strNewLoadNumber = L.strLoadNumber
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	WHERE (intPContractDetailId = @intNewContractDetailId
		   OR intSContractDetailId = @intNewContractDetailId)

	IF(ISNULL(@intLoadId,0) = 0)
	BEGIN
		RETURN;
	END	

	SELECT @intOldItemId = D.intItemId,
		   @intOldItemUOMId = D.intItemUOMId,
		   @strOldContractNumber = H.strContractNumber,
		   @intOldContractSeq = D.intContractSeq
	FROM tblCTContractHeader H
	JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
	WHERE D.intContractDetailId = @intOldContractDetailId

	SELECT @intNewItemId = D.intItemId,
		   @intNewItemUOMId = D.intItemUOMId,
		   @strNewContractNumber = H.strContractNumber,
		   @intNewContractSeq = D.intContractSeq
	FROM tblCTContractHeader H
	JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
	WHERE D.intContractDetailId = @intNewContractDetailId

	SELECT @intNewWeightItemUOMId = intItemUOMId
	FROM tblICItemUOM
	WHERE intItemId = @intNewItemId
		AND intUnitMeasureId = @intLoadUnitMeasureId
	
	IF EXISTS(SELECT 1
			  FROM tblLGLoad L
			  JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			  WHERE (LD.intPContractDetailId = @intOldContractDetailId OR LD.intSContractDetailId = @intOldContractDetailId)
			  AND L.ysnPosted = 1)
	BEGIN
		SET @ErrMsg  = 'Load/Shipment is already posted. Please unpost the transaction ('+ @strLoadNumber +') and try to transfer again.'
		Raiserror(@ErrMsg,16,1)
	END	

	IF EXISTS(SELECT 1
			  FROM tblLGLoad L
			  JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			  WHERE (LD.intPContractDetailId = @intNewContractDetailId OR LD.intSContractDetailId = @intNewContractDetailId))
	BEGIN
		SET @ErrMsg  = 'Load/Shipment ('+ @strNewLoadNumber +') is already available for contract ' + LTRIM(@strNewContractNumber) + '/'+ LTRIM(@intNewContractSeq) +' .'
		Raiserror(@ErrMsg,16,1)
	END	

	IF EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intPContractDetailId = @intOldContractDetailId)
	BEGIN
		INSERT INTO @tblLoadDetail 
		SELECT intLoadDetailId,dblQuantity 
		FROM tblLGLoadDetail 
		WHERE intPContractDetailId = @intOldContractDetailId

		SELECT @intRecordId = MIN(intRecordId) FROM @tblLoadDetail

		WHILE (@intRecordId IS NOT NULL)
		BEGIN
			SET @intLoadDetailId = NULL
			SET @dblSourceLoadDetailQuantity = NULL
			SET @dblDestLoadDetailQuantity = NULL

			SELECT @intLoadDetailId = intLoadDetailId, 
				   @dblDestLoadDetailQuantity = dblQuantity,
				   @dblSourceLoadDetailQuantity = -dblQuantity
			FROM @tblLoadDetail WHERE intRecordId = @intRecordId

			UPDATE tblLGLoadDetail
			SET intItemId = @intNewItemId,
				intPContractDetailId = @intNewContractDetailId,
				intItemUOMId = @intNewItemUOMId,
				intWeightItemUOMId = @intNewWeightItemUOMId
			WHERE intLoadDetailId = @intLoadDetailId
		
			EXEC [uspCTUpdateScheduleQuantity] @intContractDetailId = @intNewContractDetailId, 
											   @dblQuantityToUpdate = @dblDestLoadDetailQuantity, 
											   @intUserId = @intUserId, 
											   @intExternalId = @intLoadDetailId, 
											   @strScreenName = 'Load Schedule'

			EXEC [uspCTUpdateScheduleQuantity] @intContractDetailId = @intOldContractDetailId, 
											   @dblQuantityToUpdate = @dblSourceLoadDetailQuantity, 
											   @intUserId = @intUserId, 
											   @intExternalId = @intLoadDetailId, 
											   @strScreenName = 'Load Schedule'

			SELECT @intRecordId = MIN(intRecordId) FROM @tblLoadDetail WHERE intRecordId > @intRecordId			
		END
	END
	ELSE IF EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intSContractDetailId = @intOldContractDetailId)
	BEGIN
		INSERT INTO @tblLoadDetail 
		SELECT intLoadDetailId,dblQuantity 
		FROM tblLGLoadDetail 
		WHERE intSContractDetailId = @intOldContractDetailId

		SELECT @intRecordId = MIN(intRecordId) FROM @tblLoadDetail

		WHILE (@intRecordId IS NOT NULL)
		BEGIN
			SET @intLoadDetailId = NULL
			SET @dblSourceLoadDetailQuantity = NULL
			SET @dblDestLoadDetailQuantity = NULL

			SELECT @intLoadDetailId = intLoadDetailId, 
				   @dblDestLoadDetailQuantity = dblQuantity,
				   @dblSourceLoadDetailQuantity = -dblQuantity
			FROM @tblLoadDetail WHERE intRecordId = @intRecordId


			UPDATE tblLGLoadDetail
			SET intItemId = @intNewItemId,
				intSContractDetailId = @intNewContractDetailId,
				intItemUOMId = @intNewItemUOMId,
				intWeightItemUOMId = @intNewWeightItemUOMId
			WHERE intLoadDetailId = @intLoadDetailId
		
			EXEC [uspCTUpdateScheduleQuantity] @intContractDetailId = @intNewContractDetailId, 
											   @dblQuantityToUpdate = @dblDestLoadDetailQuantity, 
											   @intUserId = @intUserId, 
											   @intExternalId = @intLoadDetailId, 
											   @strScreenName = 'Load Schedule'

			EXEC [uspCTUpdateScheduleQuantity] @intContractDetailId = @intOldContractDetailId, 
											   @dblQuantityToUpdate = @dblSourceLoadDetailQuantity, 
											   @intUserId = @intUserId, 
											   @intExternalId = @intLoadDetailId, 
											   @strScreenName = 'Load Schedule'

			SELECT @intRecordId = MIN(intRecordId) FROM @tblLoadDetail WHERE intRecordId > @intRecordId			
		END
	END

	IF (LEN(@intLoadId) > 0)
	BEGIN
		DECLARE @strDetails NVARCHAR(MAX)

		SET @strDetails = '{"change":"strContractNumber","iconCls":"small-gear","from":"' + @strOldContractNumber + '","to":"' + @strNewContractNumber + '","leaf":true}'
		SET @strDetails += ',{"change":"intContractSeq","iconCls":"small-gear","from":"' + LTRIM(@intOldContractSeq) + '","to":"' + LTRIM(@intNewContractSeq) + '","leaf":true}'
		SET @strDetails += ',{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intOldContractDetailId) + '","to":"' + LTRIM(@intNewContractDetailId) + '","leaf":true}'

		EXEC uspSMAuditLog @keyValue = @intLoadId
			,@screenName = 'Logistics.view.ShipmentSchedule'
			,@entityId = @intUserId
			,@actionType = 'Updated'
			,@actionIcon = 'small-tree-modified'
			,@details = @strDetails
	END
END TRY

BEGIN CATCH
	
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH