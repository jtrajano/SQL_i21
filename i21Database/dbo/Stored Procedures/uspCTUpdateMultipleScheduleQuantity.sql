CREATE PROCEDURE [dbo].[uspCTUpdateMultipleScheduleQuantity]
	
	@XML NVARCHAR(MAX)
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT,
			@intUniqueId			INT,
			@intToItemUOMId			INT,
			@intContractDetailId	INT, 
			@dblQuantity			NUMERIC(18,6),
			@dblConvertedQty		NUMERIC(18,6),
			@intFromItemUOMId		INT,
			@intUserId				INT,
			@intExternalId			INT,
			@strScreenName			NVARCHAR(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML
	
	DECLARE @contractDetail TABLE
	(
		intUniqueId			INT IDENTITY(1,1),
		intContractDetailId	INT, 
		dblQuantity			NUMERIC(18,6),
		intItemUOMId		INT,
		intUserId			INT,
		intExternalId		INT,
		strScreenName		NVARCHAR(50)
	)
	INSERT	INTO	@contractDetail	(intContractDetailId,dblQuantity,intItemUOMId,intUserId,intExternalId,strScreenName)
	SELECT	intContractDetailId,dblQuantity,intItemUOMId,intUserId,intExternalId,strScreenName
	FROM	OPENXML(@idoc, 'DocumentElement/contractDetail',2)
	WITH
	(
			intContractDetailId	INT, 
			dblQuantity			NUMERIC(18,6),
			intItemUOMId		INT,
			intUserId			INT,
			intExternalId		INT,
			strScreenName		NVARCHAR(50)

	)

	SELECT	@intUniqueId = MIN(intUniqueId) FROM @contractDetail
	
	WHILE	ISNULL(@intUniqueId,0) > 0
	BEGIN
	
		SELECT	@intContractDetailId	=	NULL, 
				@dblQuantity			=	NULL,
				@intFromItemUOMId		=	NULL,
				@intUserId				=	NULL,
				@intExternalId			=	NULL,
				@strScreenName			=	NULL,
				@intToItemUOMId			=	NULL,
				@dblConvertedQty		=	NULL
				
		SELECT	@intContractDetailId	=	intContractDetailId, 
				@dblQuantity			=	dblQuantity,
				@intFromItemUOMId		=	intItemUOMId,
				@intUserId				=	intUserId,
				@intExternalId			=	intExternalId,
				@strScreenName			=	strScreenName
		FROM	@contractDetail
		WHERE	intUniqueId = @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END
		
		SELECT	@intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		SELECT	@dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQuantity)
										
		IF ISNULL(@dblConvertedQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END
		
		EXEC	uspCTUpdateScheduleQuantity
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intExternalId,
				@strScreenName			=	@strScreenName
					
		SELECT	@intUniqueId = MIN(intUniqueId) FROM @contractDetail WHERE intUniqueId > @intUniqueId
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO