CREATE PROCEDURE [dbo].[uspCTPriceContractSave]
	
	@intPriceContractId INT,
	@strXML				NVARCHAR(MAX)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT,
			@intUniqueId			INT,
			@intPriceFixationId		INT,
			@intContractHeaderId	INT,
			@intContractDetailId	INT,
			@intUserId				INT,
			@strRowState			NVARCHAR(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML      

	IF OBJECT_ID('tempdb..#ProcessFixation') IS NOT NULL  	
		DROP TABLE #ProcessFixation	

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,
			* 
	INTO	#ProcessFixation
	FROM OPENXML(@idoc,'tblCTPriceFixations/tblCTPriceFixation',2)          
	WITH
	(
		intPriceFixationId	INT,
		intContractHeaderId	INT,
		intContractDetailId INT,
		strRowState			NVARCHAR(50)
	)      

	SELECT @intUserId = ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract WHERE intPriceContractId = @intPriceContractId

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId		=	NULL,
				@intContractHeaderId	=	NULL,
				@intContractDetailId	=	NULL,
				@strRowState			=	NULL

		SELECT	@intPriceFixationId		=	intPriceFixationId,
				@intContractHeaderId	=	intContractHeaderId,
				@intContractDetailId	=	intContractDetailId,
				@strRowState			=	strRowState
		FROM	#ProcessFixation 
		WHERE	intUniqueId				=	 @intUniqueId
		
		IF @strRowState = 'Added'
		BEGIN
			SELECT @intPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intPriceContractId = @intPriceContractId AND intContractDetailId = @intContractDetailId
		END
		
		EXEC uspCTPriceFixationSave @intPriceFixationId,@strRowState,@intUserId

		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation WHERE intUniqueId > @intUniqueId
	END
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH