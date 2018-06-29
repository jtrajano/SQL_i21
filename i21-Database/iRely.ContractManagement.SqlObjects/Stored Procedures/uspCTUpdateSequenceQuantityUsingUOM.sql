CREATE PROCEDURE [dbo].[uspCTUpdateSequenceQuantityUsingUOM]

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(18,6),
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50),
	@intSourceItemUOMId		INT--Primary key of tblICItemUOM table where intItemId is equals to the item id of the tblCTContractdetail(Where intContractDetailId = @intContractDetailId)

AS

BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX),
			@intItemUOMId	INT

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	IF NOT EXISTS(SELECT * FROM tblICItemUOM UM
					JOIN tblCTContractDetail CD ON CD.intItemId = UM.intItemId AND UM.intItemUOMId = ISNULL(@intSourceItemUOMId,0))
	BEGIN
		RAISERROR('Invalid UOM detected.',16,1)
	END

	SELECT	@dblQuantityToUpdate = dbo.fnCTConvertQtyToTargetItemUOM(@intSourceItemUOMId,intItemUOMId,@dblQuantityToUpdate) 
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId = @intContractDetailId

	EXEC	uspCTUpdateSequenceQuantity
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblQuantityToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO