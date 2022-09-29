CREATE PROCEDURE uspCTHedgeContractPrice
	@intFutOptTransactionId int
	,@intUserId int
AS

declare
	@ErrorMsg nvarchar(max)
	,@intContractDetailId int
	,@ysnHedge bit
	,@dblHedgePrice numeric(38,20)
	,@intHedgeFutureMonthId int
	,@intBrokerId int
	,@intBrokerageAccountId int
	,@dblHedgeNoOfLots numeric(38,20)
	,@dblCurrentlHedgedLots numeric(38,20)
	,@dblPricedLots numeric(38,20)
	,@intPriceFixationDetailId int
	;

declare @Pricing as table (
	intPriceFixationDetailId int
	,dblNoOfLots numeric(38,20)
)

begin try

	select
		@intContractDetailId = s.intContractDetailId
		,@ysnHedge = s.ysnIsHedged
		,@dblHedgePrice = t.dblPrice
		,@intHedgeFutureMonthId = t.intFutureMonthId
		,@intBrokerId = t.intTraderId
		,@intBrokerageAccountId = t.intBrokerageAccountId
		,@dblHedgeNoOfLots = s.dblHedgedLots
	from
		tblRKFutOptTransaction t
		join tblRKAssignFuturesToContractSummary s on s.intFutOptTransactionId = t.intFutOptTransactionId
	where
		t.intFutOptTransactionId = @intFutOptTransactionId;

	insert into @Pricing
	select
		intPriceFixationDetailId = fd.intPriceFixationDetailId
		,dblNoOfLots = fd.dblNoOfLots
	from
		tblCTPriceFixation pf
		join tblCTPriceFixationDetail fd on fd.intPriceFixationId = pf.intPriceFixationId
	where
		pf.intContractDetailId = @intContractDetailId
		and isnull(fd.ysnHedge,0) = 0
	order by
		fd.intNumber

	while (exists (select top 1 1 from @Pricing) and isnull(@dblHedgeNoOfLots,0) > 0)
	begin
		select top 1
			@dblCurrentlHedgedLots = @dblHedgeNoOfLots
			,@intPriceFixationDetailId = intPriceFixationDetailId
			,@dblPricedLots = dblNoOfLots
		from
			@Pricing;

		if (@dblHedgeNoOfLots <= @dblPricedLots)
		begin
			delete @Pricing;
		end
		else
		begin
			select @dblCurrentlHedgedLots = @dblPricedLots;
			select @dblHedgeNoOfLots -= @dblCurrentlHedgedLots;
			delete @Pricing where intPriceFixationDetailId = @intPriceFixationDetailId;
		end

		update
			tblCTPriceFixationDetail
		set
			ysnHedge = @ysnHedge
			,dblHedgePrice = @dblHedgePrice
			,intHedgeFutureMonthId = @intHedgeFutureMonthId
			,intBrokerId = @intBrokerId
			,intBrokerageAccountId = @intBrokerageAccountId
			,intFutOptTransactionId = @intFutOptTransactionId
			,dblHedgeNoOfLots = @dblCurrentlHedgedLots
		where
			intPriceFixationDetailId = @intPriceFixationDetailId;

	end

end try
begin catch
	SET @ErrorMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
end catch