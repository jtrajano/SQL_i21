CREATE PROCEDURE [dbo].[uspCTGetContractStatus]
	@intContractDetailId	INT
AS

BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblAppliedQty			NUMERIC(18,6),
			@intContractStatusId	INT,
			@dblScheduleQty			NUMERIC(18,6),
			@dblBalance				NUMERIC(18,6)

	SELECT	@dblQuantity			=	ISNULL(dblQuantity,0),
			@dblAppliedQty			=	ISNULL(dblAppliedQty,0),
			@intContractStatusId	=	ISNULL(intContractStatusId,0),
			@dblScheduleQty			=	ISNULL(dblScheduleQty,0),
			@dblBalance				=	ISNULL(dblBalance,0)
	FROM	vyuCTGridContractDetail
	WHERE	intContractDetailId		=	@intContractDetailId

	IF	@intContractStatusId	=	1 --Open
	BEGIN
		IF	@dblAppliedQty > 0 
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,6)
		ELSE IF @dblScheduleQty > 0
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,3)
		ELSE
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,2,3)
	END
	ELSE IF	@intContractStatusId	=	2 --Unconfirmed
	BEGIN
		IF	@dblAppliedQty > 0 
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,1,6)
		ELSE
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,1,3)
	END
	ELSE IF	@intContractStatusId	=	3 --Cancelled
	BEGIN
		SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId, 4)
	END
	ELSE IF	@intContractStatusId	=	4 --Re-Open
	BEGIN
		IF	@dblBalance = 0 
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,5)
		ELSE IF @dblAppliedQty > 0
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,6)
		ELSE
			SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId,3)
	END
	ELSE IF	@intContractStatusId	=	5 --Complete
	BEGIN
		SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId, 4)
	END
	ELSE IF	@intContractStatusId	=	6 --Short Close
	BEGIN
		SELECT * FROM tblCTContractStatus WHERE intContractStatusId IN (@intContractStatusId, 4)
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH