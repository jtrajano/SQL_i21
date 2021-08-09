CREATE PROCEDURE [dbo].[uspCTSequencePriceChanged]
		
	@intContractDetailId	INT,
	@intUserId				INT = NULL,
	@ScreenName				NVARCHAR(50),
	@ysnDelete				BIT = NULL,
	@dtmLocalDate			DATETIME = NULL
	
AS

BEGIN TRY
	
	DECLARE
		@ErrMsg							NVARCHAR(MAX)	
		,@ysnOnceApproved				BIT
		,@intContractHeaderId			INT	
		,@ysnApprovalExist				BIT
		,@ysnEnablePriceContractApproval BIT
		,@intLastModifiedById			INT
		;


	SELECT	@intLastModifiedById	=	ISNULL(intLastModifiedById,intCreatedById)
			,@intContractHeaderId	=	intContractHeaderId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId

	SELECT  @intUserId = ISNULL(@intUserId,@intLastModifiedById)

	SELECT @ysnEnablePriceContractApproval = ISNULL(ysnEnablePriceContractApproval,0) FROM tblCTCompanyPreference

	IF @ScreenName = 'Price Contract'
	BEGIN
		SELECT
			@ysnOnceApproved = TR.ysnOnceApproved
		FROM
			tblSMTransaction TR
			JOIN tblSMScreen SC ON SC.intScreenId = TR.intScreenId
		WHERE
			SC.strNamespace IN( 'ContractManagement.view.Contract', 'ContractManagement.view.Amendments')
			AND TR.intRecordId = @intContractHeaderId
		
		SELECT	@ysnApprovalExist = dbo.fnCTContractApprovalExist(@intUserId,'ContractManagement.view.Amendments')

		IF ISNULL(@ysnOnceApproved,0) = 1 AND	((@ysnEnablePriceContractApproval = 1 AND ISNULL(@ysnApprovalExist,0) = 0) 
													OR @ysnEnablePriceContractApproval = 0
												)
		BEGIN
			EXEC [uspCTContractApproved] @intContractHeaderId,@intUserId,@intContractDetailId,0,1
		END
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
GO
