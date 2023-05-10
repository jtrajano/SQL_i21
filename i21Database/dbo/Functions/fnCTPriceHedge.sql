CREATE FUNCTION [dbo].[fnCTPriceHedge]
(
	@intPriceFixationId INT
	,@intContractDetailId INT
)
RETURNS @returnTable table (
	intPriceFixationDetailId int
	,ysnHedge bit
	,dblHedgePrice numeric(18,6)
	,intHedgeFutureMonthId int
	,intBrokerId int
	,intBrokerageAccountId int
	,intFutOptTransactionId int
	,dblHedgeNoOfLots numeric(18,6)
	,strHedgeMonth nvarchar(max) COLLATE Latin1_General_CI_AS
	,strBroker nvarchar(max) COLLATE Latin1_General_CI_AS
	,strAccount nvarchar(max) COLLATE Latin1_General_CI_AS
	,strFutOptTransactionId  nvarchar(max) COLLATE Latin1_General_CI_AS
	,strInternalTradeNo nvarchar(max) COLLATE Latin1_General_CI_AS
	,dtmMatchDate datetime
)
AS
BEGIN

	if exists (select top 1 1 from tblCTCompanyPreference where ysnEnableHedgingInAssignDerivatives = 0)
	begin
		return;
	end
	
	declare
		@intPriceFixationDetailId int
		,@dblNoOfLots numeric(18,6)
		,@intFutOptTransactionId int
		,@strInternalTradeNo nvarchar(20)
		,@ysnIsHedged bit
		,@dblPrice numeric(18,6)
		,@intFutureMonthId int
		,@intTraderId int
		,@intBrokerageAccountId int
		,@dblHedgedLots numeric(18,6)
		,@strHedgeMonth nvarchar(100)
		,@strBroker nvarchar(100)
		,@strAccount nvarchar(100)
		,@dtmMatchDate datetime
		;

	declare @pricingLots as table (
		intPriceFixationDetailId int
		,dblNoOfLots int
	);

	declare @hedgeLots as table (
		intFutOptTransactionId int
		,strInternalTradeNo nvarchar(20)COLLATE Latin1_General_CI_AS
		,ysnIsHedged bit
		,dblPrice numeric(18,6)
		,intFutureMonthId int
		,intTraderId int
		,intBrokerageAccountId int
		,dblHedgedLots numeric(18,6)
		,strHedgeMonth nvarchar(100)COLLATE Latin1_General_CI_AS
		,strBroker nvarchar(100)COLLATE Latin1_General_CI_AS
		,strAccount nvarchar(100)COLLATE Latin1_General_CI_AS
		,dtmMatchDate datetime
	);

	declare @tableTemp as table (
		intPriceFixationDetailId int
		,ysnHedge bit
		,dblHedgePrice numeric(18,6)
		,intHedgeFutureMonthId int
		,intBrokerId int
		,intBrokerageAccountId int
		,intFutOptTransactionId int
		,dblHedgeNoOfLots numeric(18,6)
		,strHedgeMonth nvarchar(max)COLLATE Latin1_General_CI_AS
		,strBroker nvarchar(max)COLLATE Latin1_General_CI_AS
		,strAccount nvarchar(max)COLLATE Latin1_General_CI_AS
		,strFutOptTransactionId  nvarchar(max)COLLATE Latin1_General_CI_AS
		,strInternalTradeNo nvarchar(max)COLLATE Latin1_General_CI_AS
		,dtmMatchDate datetime
	);

	declare @tableTempDetail as table (
		intPriceFixationDetailId int
		,strHedgeMonth nvarchar(20) COLLATE Latin1_General_CI_AS
		,strBroker nvarchar(20) COLLATE Latin1_General_CI_AS
		,strAccount nvarchar(20) COLLATE Latin1_General_CI_AS
		,strFutOptTransactionId  nvarchar(20) COLLATE Latin1_General_CI_AS
		,strInternalTradeNo nvarchar(20) COLLATE Latin1_General_CI_AS
		,dtmMatchDate datetime
	);

	if (isnull(@intContractDetailId,0) = 0)
	begin
		select @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
	end

	insert into @pricingLots
	select
		fd.intPriceFixationDetailId
		,fd.dblNoOfLots
	from
		tblCTPriceFixation pf
		join tblCTPriceFixationDetail fd on fd.intPriceFixationId = pf.intPriceFixationId
	where
		pf.intContractDetailId = @intContractDetailId
		and isnull(fd.ysnHedge,0) = 0
	order by
		fd.intNumber

	insert into @hedgeLots
	select
		t.intFutOptTransactionId
		,t.strInternalTradeNo
		,s.ysnIsHedged
		,t.dblPrice
		,t.intFutureMonthId
		,t.intTraderId
		,t.intBrokerageAccountId
		,dblHedgedLots   = CASE WHEN s.ysnIsHedged = 1 then s.dblHedgedLots ELSE s.dblAssignedLots END
		,strHedgeMonth = REPLACE(fm.strFutureMonth,' ','('+fm.strSymbol+') ') COLLATE Latin1_General_CI_AS
		,strBroker = e.strName
		,strAccount = a.strAccountNumber
		,dtmMatchDate = s.dtmMatchDate
	from 
		tblRKFutOptTransaction t
		join tblRKAssignFuturesToContractSummary s on s.intFutOptTransactionId = t.intFutOptTransactionId
		left join tblRKFuturesMonth fm on fm.intFutureMonthId = t.intFutureMonthId
		left join tblRKBrokerageAccount a on a.intBrokerageAccountId = t.intBrokerageAccountId
		left join tblEMEntity e on e.intEntityId = t.intEntityId
	where
		s.intContractDetailId = @intContractDetailId
	order by
		s.intAssignFuturesToContractSummaryId

	if exists (select top 1 1 from @hedgeLots)
	begin

		if exists (select top 1 1 from @pricingLots)
		begin

			while exists (select top 1 1 from @pricingLots)
			begin

				while exists (select top 1 1 from @hedgeLots)
				begin
					select top 1
						@intPriceFixationDetailId = intPriceFixationDetailId
						,@dblNoOfLots = dblNoOfLots
					from
						@pricingLots;

					select top 1
						@intFutOptTransactionId = intFutOptTransactionId
						,@strInternalTradeNo = strInternalTradeNo
						,@ysnIsHedged = ysnIsHedged
						,@dblPrice = dblPrice
						,@intFutureMonthId = intFutureMonthId
						,@intTraderId = intTraderId
						,@intBrokerageAccountId = intBrokerageAccountId
						,@dblHedgedLots = dblHedgedLots
						,@strHedgeMonth = strHedgeMonth
						,@strBroker = strBroker
						,@strAccount = strAccount
						,@dtmMatchDate = dtmMatchDate
					from
						@hedgeLots;

					if (@dblNoOfLots = @dblHedgedLots)
					begin
						insert into @tableTemp
							select
								intPriceFixationDetailId  = @intPriceFixationDetailId
								,ysnHedge  = 1
								,dblHedgePrice  = @dblPrice
								,intHedgeFutureMonthId = @intFutureMonthId
								,intBrokerId = @intTraderId
								,intBrokerageAccountId  = @intBrokerageAccountId
								,intFutOptTransactionId = @intFutOptTransactionId
								,dblHedgeNoOfLots = @dblHedgedLots
								,strHedgeMonth = @strHedgeMonth
								,strBroker = @strBroker
								,strAccount = @strAccount
								,intFutOptTransactionId = @intFutOptTransactionId
								,strInternalTradeNo = @strInternalTradeNo
								,dtmMatchDate = @dtmMatchDate

						delete from @hedgeLots where intFutOptTransactionId = @intFutOptTransactionId;
						delete from @pricingLots where intPriceFixationDetailId = @intPriceFixationDetailId;

						if not exists (select top 1 1 from @hedgeLots) or not exists (select top 1 1 from @pricingLots)
						begin
							delete @hedgeLots;
							delete @pricingLots;
						end
					end
					else if (@dblNoOfLots > @dblHedgedLots)
					begin
						insert into @tableTemp
							select
								intPriceFixationDetailId  = @intPriceFixationDetailId
								,ysnHedge  = 1
								,dblHedgePrice  = @dblPrice
								,intHedgeFutureMonthId = @intFutureMonthId
								,intBrokerId = @intTraderId
								,intBrokerageAccountId  = @intBrokerageAccountId
								,intFutOptTransactionId = @intFutOptTransactionId
								,dblHedgeNoOfLots = @dblHedgedLots
								,strHedgeMonth = @strHedgeMonth
								,strBroker = @strBroker
								,strAccount = @strAccount
								,intFutOptTransactionId = @intFutOptTransactionId
								,strInternalTradeNo = @strInternalTradeNo
								,dtmMatchDate = @dtmMatchDate

						delete from @hedgeLots where intFutOptTransactionId = @intFutOptTransactionId;
						update @pricingLots set dblNoOfLots -= @dblHedgedLots where intPriceFixationDetailId = @intPriceFixationDetailId;

						if not exists (select top 1 1 from @hedgeLots)
						begin
							delete @pricingLots;
						end
					end
					else if (@dblNoOfLots < @dblHedgedLots)
					begin
						insert into @tableTemp
							select
								intPriceFixationDetailId  = @intPriceFixationDetailId
								,ysnHedge  = 1
								,dblHedgePrice  = @dblPrice
								,intHedgeFutureMonthId = @intFutureMonthId
								,intBrokerId = @intTraderId
								,intBrokerageAccountId  = @intBrokerageAccountId
								,intFutOptTransactionId = @intFutOptTransactionId
								,dblHedgeNoOfLots = @dblNoOfLots
								,strHedgeMonth = @strHedgeMonth
								,strBroker = @strBroker
								,strAccount = @strAccount
								,intFutOptTransactionId = @intFutOptTransactionId
								,strInternalTradeNo = @strInternalTradeNo
								,dtmMatchDate = @dtmMatchDate

						delete from @pricingLots where intPriceFixationDetailId = @intPriceFixationDetailId;
						update @hedgeLots set dblHedgedLots -= @dblNoOfLots where intFutOptTransactionId = @intFutOptTransactionId;

						if not exists (select top 1 1 from @pricingLots)
						begin
							delete @hedgeLots;
						end
					end
				
				end

			end

		end
		else
		begin
			
			if exists (select top 1 1 from tblCTContractDetail cd join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId where cd.intContractDetailId = @intContractDetailId and ch.intPricingTypeId = 1)
			begin

				select @dblNoOfLots = cd.dblNoOfLots from tblCTContractDetail cd where cd.intContractDetailId = @intContractDetailId;

				while (exists (select top 1 1 from @hedgeLots) and isnull(@dblNoOfLots,0) > 0)
				begin
					select top 1
						@intFutOptTransactionId = intFutOptTransactionId
						,@strInternalTradeNo = strInternalTradeNo
						,@ysnIsHedged = ysnIsHedged
						,@dblPrice = dblPrice
						,@intFutureMonthId = intFutureMonthId
						,@intTraderId = intTraderId
						,@intBrokerageAccountId = intBrokerageAccountId
						,@dblHedgedLots = dblHedgedLots
						,@strHedgeMonth = strHedgeMonth
						,@strBroker = strBroker
						,@strAccount = strAccount
						,@dtmMatchDate = dtmMatchDate
					from
						@hedgeLots;

					if (@dblNoOfLots = @dblHedgedLots)
					begin

						insert into @tableTemp
							select
								intPriceFixationDetailId  = @intContractDetailId
								,ysnHedge  = 1
								,dblHedgePrice  = @dblPrice
								,intHedgeFutureMonthId = @intFutureMonthId
								,intBrokerId = @intTraderId
								,intBrokerageAccountId  = @intBrokerageAccountId
								,intFutOptTransactionId = @intFutOptTransactionId
								,dblHedgeNoOfLots = @dblNoOfLots
								,strHedgeMonth = @strHedgeMonth
								,strBroker = @strBroker
								,strAccount = @strAccount
								,intFutOptTransactionId = @intFutOptTransactionId
								,strInternalTradeNo = @strInternalTradeNo
								,dtmMatchDate = @dtmMatchDate

						select @dblNoOfLots = 0;
						delete @hedgeLots where intFutOptTransactionId = @intFutOptTransactionId;
					end
					else if (@dblNoOfLots < @dblHedgedLots)
					begin
						insert into @tableTemp
							select
								intPriceFixationDetailId  = @intContractDetailId
								,ysnHedge  = 1
								,dblHedgePrice  = @dblPrice
								,intHedgeFutureMonthId = @intFutureMonthId
								,intBrokerId = @intTraderId
								,intBrokerageAccountId  = @intBrokerageAccountId
								,intFutOptTransactionId = @intFutOptTransactionId
								,dblHedgeNoOfLots = @dblNoOfLots
								,strHedgeMonth = @strHedgeMonth
								,strBroker = @strBroker
								,strAccount = @strAccount
								,intFutOptTransactionId = @intFutOptTransactionId
								,strInternalTradeNo = @strInternalTradeNo
								,dtmMatchDate = @dtmMatchDate

						select @dblNoOfLots = 0;
						update @hedgeLots set dblHedgedLots -= @dblNoOfLots where intFutOptTransactionId = @intFutOptTransactionId;
					end
					else if (@dblNoOfLots > @dblHedgedLots)
					begin
						insert into @tableTemp
							select
								intPriceFixationDetailId  = @intContractDetailId
								,ysnHedge  = 1
								,dblHedgePrice  = @dblPrice
								,intHedgeFutureMonthId = @intFutureMonthId
								,intBrokerId = @intTraderId
								,intBrokerageAccountId  = @intBrokerageAccountId
								,intFutOptTransactionId = @intFutOptTransactionId
								,dblHedgeNoOfLots = @dblHedgedLots
								,strHedgeMonth = @strHedgeMonth
								,strBroker = @strBroker
								,strAccount = @strAccount
								,intFutOptTransactionId = @intFutOptTransactionId
								,strInternalTradeNo = @strInternalTradeNo
								,dtmMatchDate = @dtmMatchDate

						select @dblNoOfLots -= @dblHedgedLots;
						delete @hedgeLots where intFutOptTransactionId = @intFutOptTransactionId;
					end

				end
			end

		end

	end

	insert into @tableTempDetail
	select distinct
		intPriceFixationDetailId = intPriceFixationDetailId
		,strHedgeMonth = strHedgeMonth
		,strBroker = strBroker
		,strAccount = strAccount
		,strFutOptTransactionId = convert(nvarchar(20), intFutOptTransactionId) COLLATE Latin1_General_CI_AS
		,strInternalTradeNo = strInternalTradeNo
		,dtmMatchDate = dtmMatchDate
	from @tableTemp

	insert into @returnTable (
		intPriceFixationDetailId
		,dblHedgeNoOfLots
		,dblHedgePrice
		,ysnHedge
	)
	select
		intPriceFixationDetailId
		,dblHedgeNoOfLots = sum(dblHedgeNoOfLots)
		,dblHedgePrice = avg(dblHedgePrice)
		,ysnHedge = 1
	from
		@tableTemp
	group by
		intPriceFixationDetailId;

	update rt
	set
		rt.strHedgeMonth = substring((
			select distinct ',' + b.strHedgeMonth from @tableTempDetail b where b.intPriceFixationDetailId = rt.intPriceFixationDetailId for xml path('')
		),2,4000) COLLATE Latin1_General_CI_AS
		,rt.strBroker = substring((
			select distinct ',' + b.strBroker from @tableTempDetail b where b.intPriceFixationDetailId = rt.intPriceFixationDetailId for xml path('')
		),2,4000) COLLATE Latin1_General_CI_AS
		,rt.strAccount = substring((
			select distinct ',' + b.strAccount from @tableTempDetail b where b.intPriceFixationDetailId = rt.intPriceFixationDetailId for xml path('')
		),2,4000) COLLATE Latin1_General_CI_AS
		,rt.strFutOptTransactionId = substring((
			select distinct ',' + b.strFutOptTransactionId from @tableTempDetail b where b.intPriceFixationDetailId = rt.intPriceFixationDetailId for xml path('')
		),2,4000) COLLATE Latin1_General_CI_AS
		,rt.strInternalTradeNo = substring((
			select distinct ',' + b.strInternalTradeNo from @tableTempDetail b where b.intPriceFixationDetailId = rt.intPriceFixationDetailId for xml path('')
		),2,4000) COLLATE Latin1_General_CI_AS
		,rt.dtmMatchDate = (select min(dtmMatchDate) from @tableTempDetail b where b.intPriceFixationDetailId = rt.intPriceFixationDetailId)
	from @returnTable rt

	RETURN
END
