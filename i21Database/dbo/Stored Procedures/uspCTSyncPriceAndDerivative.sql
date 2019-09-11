CREATE PROCEDURE [dbo].[uspCTSyncPriceAndDerivative]
	@intFutOptTransactionId INT, --> tblRKFutOptTransaction.intFutOptTransactionId
	@strAction nvarchar(10) --> Transaction type - accept Update and Delete case sensitive
AS

BEGIN TRY
	
	DECLARE	@ErrMsg	NVARCHAR(MAX),
			@dblPrice numeric(18,6),
			@dblNoOfContract numeric(18,6),
			@intFutureMonthId int,
			@intBrokerageAccountId int,
			@dblNoOfLots numeric(18,6);

	if (@strAction = 'Update')
	begin
		--set  @dblPrice = (select dblPrice from tblRKFutOptTransaction where intFutOptTransactionId = @intFutOptTransactionId);
		select
			@dblPrice = dblPrice
			,@dblNoOfContract = dblNoOfContract
			,@intFutureMonthId = intFutureMonthId
			,@intBrokerageAccountId = intBrokerageAccountId
		from
			tblRKFutOptTransaction
		where
			intFutOptTransactionId = @intFutOptTransactionId;

		set @dblNoOfLots = (select dblNoOfLots from tblCTPriceFixationDetail where intFutOptTransactionId = @intFutOptTransactionId);

		if (@dblNoOfContract > @dblNoOfLots)
		begin
			SET @ErrMsg = 'No. of Contract should not more than No. of priced Lots in Contract Pricing.';
			RAISERROR (@ErrMsg,18,1,'WITH NOWAIT');
		end
		else
		begin
			update
				tblCTPriceFixationDetail
			set
				dblHedgePrice = @dblPrice
				,dblHedgeNoOfLots = @dblNoOfContract
				,intHedgeFutureMonthId = @intFutureMonthId
				,intBrokerageAccountId = @intBrokerageAccountId
			where
				intFutOptTransactionId = @intFutOptTransactionId;
		end
	end
	if (@strAction = 'Delete')
	begin
		update tblCTPriceFixationDetail set dblHedgePrice = null, intFutOptTransactionId = null, ysnHedge = convert(bit,0) where intFutOptTransactionId = @intFutOptTransactionId;
	end	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH