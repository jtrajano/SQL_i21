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
		   ,@intOldContractSeq INT
		   ,@intNewContractSeq INT
		   ,@strOldContractNumber NVARCHAR(50)
		   ,@strNewContractNumber NVARCHAR(50)

	IF EXISTS(SELECT 1
			  FROM tblLGLoad L
			  JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			  WHERE (LD.intPContractDetailId = 420 OR LD.intSContractDetailId = 420)
			  AND L.ysnPosted = 1)
	BEGIN
		SET @ErrMsg  = 'There is a load available for this sequence, which has been posted. Cannot continue.'
		Raiserror(@ErrMsg,16,1)
	END	

	IF EXISTS(SELECT 1
			  FROM tblLGLoad L
			  JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			  JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			  JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId AND LC.ysnRejected = 1
			  WHERE (LD.intPContractDetailId = 420 OR LD.intSContractDetailId = 420)
			  AND L.ysnPosted = 1)
	BEGIN
		SET @ErrMsg  = 'Container for the selected contract sequence has been rejected. Cannot continue.'
		Raiserror(@ErrMsg,16,1)
	END	

	IF EXISTS(SELECT 1
			  FROM tblLGLoad L
			  JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			  JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			  JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId AND LC.ysnRejected = 1
			  WHERE (LD.intPContractDetailId = 420 OR LD.intSContractDetailId = 420)
			  AND L.ysnPosted = 1)
	BEGIN
		SET @ErrMsg  = 'Container for the selected contract sequence has been rejected. Cannot continue.'
		Raiserror(@ErrMsg,16,1)
	END	



	SELECT 'uspLGTransferContractLoads'

	--IF (LEN(@intLoadDetailId) > 0)
	--BEGIN
	--	DECLARE @strDetails NVARCHAR(MAX)

	--	SET @strDetails = '{"change":"strContractNumber","iconCls":"small-gear","from":"' + @strOldContractNumber + '","to":"' + @strNewContractNumber + '","leaf":true}'
	--	SET @strDetails += ',{"change":"intContractSeq","iconCls":"small-gear","from":"' + LTRIM(@intOldContractSeq) + '","to":"' + LTRIM(@intNewContractSeq) + '","leaf":true}'
	--	SET @strDetails += ',{"change":"intContractDetailId","iconCls":"small-gear","from":"' + LTRIM(@intOldContractDetailId) + '","to":"' + LTRIM(@intNewContractDetailId) + '","leaf":true}'

	--	EXEC uspSMAuditLog @keyValue = @intLoadDetailId
	--		,@screenName = 'Quality.view.QualitySample'
	--		,@entityId = @intUserId
	--		,@actionType = 'Updated'
	--		,@actionIcon = 'small-tree-modified'
	--		,@details = @strDetails
	--END
END TRY

BEGIN CATCH
	
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH