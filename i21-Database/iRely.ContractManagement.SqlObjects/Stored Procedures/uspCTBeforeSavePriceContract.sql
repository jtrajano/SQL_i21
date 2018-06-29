CREATE PROCEDURE [dbo].[uspCTBeforeSavePriceContract]
		
	@intPriceContractId INT,
	@strXML				NVARCHAR(MAX)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@idoc						INT,
			@intUniqueId				INT,
			@intPriceFixationId			INT,
			@intContractHeaderId		INT,
			@intContractDetailId		INT,
			@intUserId					INT,
			@strRowState				NVARCHAR(50),
			@Condition					NVARCHAR(MAX),
			@intPriceFixationDetailId	INT,
			@intFutOptTransactionId		INT,
			@strAction					NVARCHAR(50) = ''


	IF @strXML = 'Delete'
	BEGIN
		SET	@strAction = @strXML
		SET @Condition = 'intPriceContractId = ' + LTRIM(@intPriceContractId)
		EXEC [dbo].[uspCTGetTableDataInXML] 'tblCTPriceFixation', @Condition, @strXML OUTPUT,null,'intPriceFixationId,intContractHeaderId,intContractDetailId,''Delete'' AS strRowState'
	END

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
		strRowState			NVARCHAR(50)
	)      

	IF OBJECT_ID('tempdb..#ProcessFixationDetail') IS NOT NULL  	
		DROP TABLE #ProcessFixationDetail

	SELECT  ROW_NUMBER() OVER(ORDER BY strRowState) intUniqueId,
			* 
	INTO	#ProcessFixationDetail
	FROM OPENXML(@idoc,'tblCTPriceFixationDetails/tblCTPriceFixationDetail',2)          
	WITH
	(
		intPriceFixationDetailId	INT,
		strRowState					NVARCHAR(50)
	)      

	SELECT @intUserId = ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract WHERE intPriceContractId = @intPriceContractId

	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId		=	NULL,
				@strRowState			=	NULL,
				@intPriceFixationDetailId = NULL

		SELECT	@intPriceFixationId		=	intPriceFixationId,
				@strRowState			=	strRowState
		FROM	#ProcessFixation 
		WHERE	intUniqueId				=	 @intUniqueId
		
		SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId
		
		WHILE	ISNULL(@intPriceFixationDetailId,0) > 0
		BEGIN
		
			SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId	
			FROM	tblCTPriceFixationDetail	FD
			WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId

			IF @strRowState = 'Delete' AND ISNULL(@intFutOptTransactionId,0) > 0
			BEGIN
				UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = NULL WHERE intPriceFixationDetailId = @intPriceFixationDetailId
				EXEC uspRKDeleteAutoHedge @intFutOptTransactionId
			END
			 
			SELECT	@intPriceFixationDetailId = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailId
		END
		
		EXEC uspCTPriceFixationSave @intPriceFixationId,@strRowState,@intUserId

		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixation WHERE intUniqueId > @intUniqueId
	END

	SELECT @intUniqueId = NULL
	SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixationDetail

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intPriceFixationId		=	NULL,
				@strRowState			=	NULL,
				@intPriceFixationDetailId = NULL,
				@intFutOptTransactionId	=	NULL

		SELECT	@intPriceFixationDetailId	=	intPriceFixationDetailId,
				@strRowState				=	strRowState
		FROM	#ProcessFixationDetail 
		WHERE	intUniqueId				=	 @intUniqueId
		
		SELECT	@intFutOptTransactionId	=	FD.intFutOptTransactionId	
		FROM	tblCTPriceFixationDetail	FD
		WHERE	FD.intPriceFixationDetailId	=	@intPriceFixationDetailId
		
		IF @strRowState = 'Delete' AND ISNULL(@intFutOptTransactionId,0) > 0
		BEGIN
			UPDATE tblCTPriceFixationDetail SET intFutOptTransactionId = NULL WHERE intPriceFixationDetailId = @intPriceFixationDetailId
			EXEC uspRKDeleteAutoHedge @intFutOptTransactionId
		END
		
		SELECT @intUniqueId = MIN(intUniqueId) FROM #ProcessFixationDetail WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH