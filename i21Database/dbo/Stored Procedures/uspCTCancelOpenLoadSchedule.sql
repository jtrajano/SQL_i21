CREATE PROCEDURE [dbo].[uspCTCancelOpenLoadSchedule]
	
	@intContractDetailId	INT
AS

BEGIN TRY
	
	DECLARE		@ErrMsg					NVARCHAR(MAX),
				@intLoadId				INT,
				@intUserId				INT,
				@intContractHeaderId	INT

	DECLARE @OpenLoad TABLE 
	(  
		intLoadId		INT
	)

	SELECT @intUserId = intLastModifiedById,@intContractHeaderId = intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId	=	@intContractDetailId

	INSERT  INTO @OpenLoad
	SELECT	LO.intLoadId
	FROM	tblLGLoad			LO
	JOIN	tblLGLoadDetail		LD	ON	LD.intLoadId			=	LO.intLoadId
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	ISNULL(LD.intSContractDetailId,LD.intPContractDetailId)
	WHERE	intTicketId IS NULL 
	AND		LO.intShipmentStatus <> 10
	AND		CD.intContractHeaderId	=	@intContractHeaderId

	SELECT @intLoadId = MIN(intLoadId) FROM @OpenLoad
	
	WHILE  ISNULL(@intLoadId,0) > 0
	BEGIN
		EXEC uspLGCancelLoadSchedule @intLoadId,1,@intUserId
		
		SELECT @intLoadId = MIN(intLoadId) FROM @OpenLoad WHERE intLoadId > @intLoadId
	END

END TRY

BEGIN CATCH
    SELECT @ErrMsg = ERROR_MESSAGE()
    RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
GO
