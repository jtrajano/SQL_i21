CREATE PROCEDURE [dbo].[uspCTProcessSummaryLogOnPriceUpdate]
	@intPriceFixationDetailId INT,
	@dblTransactionQuantity NUMERIC(18,6),
	@intUserId INT
AS

BEGIN TRY

	declare
		@ErrMsg nvarchar(max)
		,@contractDetails AS ContractDetailTable
		,@intContractHeaderId int
		,@intContractDetailId int
		,@ysnDWG bit
		;

	select
		@intContractHeaderId = pf.intContractHeaderId
		,@intContractDetailId = pf.intContractDetailId
		,@ysnDWG = (case when isnull(w.intWeightGradeId,0) > 0 or isnull(g.intWeightGradeId,0) > 0 then 1 else 0 end) 
	from
		tblCTPriceFixationDetail pfd
		join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
		join tblCTContractHeader ch on ch.intContractHeaderId = pf.intContractHeaderId
		left join tblCTWeightGrade w on w.intWeightGradeId = ch.intWeightId and w.strWhereFinalized = 'Destination'
		left join tblCTWeightGrade g on g.intWeightGradeId = ch.intGradeId and g.strWhereFinalized = 'Destination'
	where
		ch.intContractTypeId = 2
		and pfd.intPriceFixationDetailId = @intPriceFixationDetailId;

	update tblCTPriceFixationDetail set dblPreviousQty = dblQuantity where intPriceFixationDetailId = @intPriceFixationDetailId;

	IF (@ysnDWG = 1)
	BEGIN
		EXEC uspCTLogSummary
			@intContractHeaderId 	= 	@intContractHeaderId,
			@intContractDetailId 	= 	@intContractDetailId,
			@strSource			 	= 	'Pricing',
			@strProcess		 		= 	'Price Update',
			@contractDetail 		= 	@contractDetails,
			@intUserId				= 	@intUserId,
			@intTransactionId 		=	@intPriceFixationDetailId,
			@dblTransactionQty		=	@dblTransactionQuantity
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 
END CATCH
