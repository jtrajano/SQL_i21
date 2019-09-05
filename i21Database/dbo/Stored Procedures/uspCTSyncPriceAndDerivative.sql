CREATE PROCEDURE [dbo].[uspCTSyncPriceAndDerivative]
	@intFutOptTransactionId INT, --> tblRKFutOptTransaction.intFutOptTransactionId
	@strAction nvarchar(10) --> Transaction type - accept Update and Delete case sensitive
AS

BEGIN TRY
	
	/*Test modification to see if it reflects to the next build*/

	DECLARE	@ErrMsg	NVARCHAR(MAX),
			@dblPrice numeric(18,6);

	if (@strAction = 'Update')
	begin
		set  @dblPrice = (select dblPrice from tblRKFutOptTransaction where intFutOptTransactionId = @intFutOptTransactionId);
		update tblCTPriceFixationDetail set dblHedgePrice = @dblPrice where intFutOptTransactionId = @intFutOptTransactionId;
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