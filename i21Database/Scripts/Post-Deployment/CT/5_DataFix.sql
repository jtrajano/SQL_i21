GO
	print 'Begin fixing Price Contract Quantity/Load Applied and Priced.';
GO

	declare @queryResult cursor;
	declare @ysnLoad bit;
	declare @intPriceFixationId int;
	declare @intPriceFixationDetailId int;
	declare @dblQuantity numeric(18,6);
	declare @dblQuantityAppliedAndPriced numeric(18,6);
	declare @dblLoadPriced numeric(18,6);
	declare @dblLoadAppliedAndPriced numeric(18,6);
	declare @dblDetailQuantityApplied numeric(18,6);
	declare @dblDetailLoadApplied numeric(18,6);
	declare @dblRunningDetailQuantityApplied numeric(18,6) = 0.00;
	declare @dblComputedQuantity numeric(18,6) = 0.00;
	declare @intActivePriceFixationId int = 0;

	set @queryResult = cursor for
		select
			ysnLoad = isnull(z.ysnLoad,0)
			,b.intPriceFixationId
			,c.intPriceFixationDetailId
			,dblQuantity = isnull(c.dblQuantity, 0.00)
			,dblQuantityAppliedAndPriced = isnull(c.dblQuantityAppliedAndPriced,0.00)
			,dblLoadPriced = isnull(c.dblLoadPriced,0.00)
			,dblLoadAppliedAndPriced = isnull(c.dblLoadAppliedAndPriced,0.00)
			,dblDetailQuantityApplied = isnull(a.dblQuantity,0.00) - isnull(a.dblBalance,0.00)
			,dblDetailLoadApplied = (case when isnull(z.ysnLoad,0) = 1 then (isnull(a.dblQuantity,0.00) / isnull(a.dblQuantityPerLoad,0.00)) - isnull(a.dblBalanceLoad,0.00) else 0.00 end)
		from
			tblCTContractHeader z
			,tblCTContractDetail a
			,tblCTPriceFixation b
			,tblCTPriceFixationDetail c
		where
			a.intContractHeaderId = z.intContractHeaderId
			and b.intContractHeaderId = a.intContractHeaderId
			and b.intContractDetailId = a.intContractDetailId
			and c.intPriceFixationId = b.intPriceFixationId
			--and z.intContractHeaderId in (7463,7205)
		order by
			c.intPriceFixationId
			,c.intPriceFixationDetailId

	OPEN @queryResult
	fetch next
	from
		@queryResult
	into
		@ysnLoad
		,@intPriceFixationId
		,@intPriceFixationDetailId
		,@dblQuantity
		,@dblQuantityAppliedAndPriced
		,@dblLoadPriced
		,@dblLoadAppliedAndPriced
		,@dblDetailQuantityApplied
		,@dblDetailLoadApplied

	while @@FETCH_STATUS = 0
	begin
		if (@intActivePriceFixationId <> @intPriceFixationId)
		begin
			set @dblRunningDetailQuantityApplied = 0.00;
			set @dblComputedQuantity  = 0.00;
			set @intActivePriceFixationId = @intPriceFixationId
		end

		if (@dblDetailQuantityApplied > 0)
		begin

			if (@ysnLoad = 1)
			begin
				--print 'Load based';
				set @dblRunningDetailQuantityApplied = @dblRunningDetailQuantityApplied + @dblLoadPriced;
				if (@dblRunningDetailQuantityApplied <= @dblDetailLoadApplied)
				begin
					--print @dblLoadPriced;
					update tblCTPriceFixationDetail set dblLoadAppliedAndPriced = @dblLoadPriced where intPriceFixationDetailId = @intPriceFixationDetailId;
				end
				else
				begin
					set @dblComputedQuantity = @dblLoadPriced - (@dblRunningDetailQuantityApplied-@dblDetailQuantityApplied);
					--print @dblComputedQuantity;
					update tblCTPriceFixationDetail set dblLoadAppliedAndPriced = @dblComputedQuantity where intPriceFixationDetailId = @intPriceFixationDetailId;
				end
			end
			else
			begin
				--print 'Quantity based';
				set @dblRunningDetailQuantityApplied = @dblRunningDetailQuantityApplied + @dblQuantity;
				if (@dblRunningDetailQuantityApplied <= @dblDetailQuantityApplied)
				begin
					--print @dblQuantity;
					update tblCTPriceFixationDetail set dblQuantityAppliedAndPriced = @dblQuantity where intPriceFixationDetailId = @intPriceFixationDetailId;
				end
				else
				begin
					set @dblComputedQuantity = @dblQuantity - (@dblRunningDetailQuantityApplied-@dblDetailQuantityApplied);
					--print @dblComputedQuantity;
					update tblCTPriceFixationDetail set dblQuantityAppliedAndPriced = @dblComputedQuantity where intPriceFixationDetailId = @intPriceFixationDetailId;
				end
			end

		end

		fetch next
		from
			@queryResult
		into
			@ysnLoad
			,@intPriceFixationId
			,@intPriceFixationDetailId
			,@dblQuantity
			,@dblQuantityAppliedAndPriced
			,@dblLoadPriced
			,@dblLoadAppliedAndPriced
			,@dblDetailQuantityApplied
			,@dblDetailLoadApplied

	end

	close @queryResult
	deallocate @queryResult

GO
	print 'End fixing Price Contract Quantity/Load Applied and Priced.';
GO



GO
	print 'BEGIN - UPDATE INCO/Ship Term to Freight Term';
GO


	UPDATE tblSMGridLayout 
	SET strGridLayoutFields = REPLACE(strGridLayoutFields,
								'{"strFieldName":"strContractBasis","strDataType":"string","strDisplayName":"INCO/Ship Term","strControlType":"gridcolumn"',
								'{"strFieldName":"strFreightTerm","strDataType":"string","strDisplayName":"Freight Term","strControlType":"gridcolumn"')
	WHERE strScreen = 'ContractManagement.view.Contract' 
		AND strGridLayoutFields LIKE '%INCO/Ship Term%'


GO
	print 'END - UPDATE INCO/Ship Term to Freight Term';
GO

GO
	print 'Begin fixing Freight Basis';
GO

	update
		tblCTContractDetail
	set
		dblFreightBasisBase = dblBasis
		,intFreightBasisBaseUOMId = intBasisUOMId
	where
		dblFreightBasisBase is null
		and dblFreightBasis is null
		and dblBasis is not null

GO
	print 'End fixing Freight Basis';
	print 'Start updating empty Contract Condition Description.';
GO

	update
		b
	set
		b.strConditionDescription = c.strConditionDesc
	from
		tblCTContractHeader a
		,tblCTContractCondition b
		,tblCTCondition c
	where
		b.strConditionDescription is null
		and b.intContractHeaderId = a.intContractHeaderId
		and c.intConditionId = b.intConditionId

GO
	print 'End updating empty Contract Condition Description.';
	print 'Begin fixing SM Transaction records associated to wrong Pricing Screen ID';
GO

	IF EXISTS (SELECT TOP 1 1 FROM tblCTMiscellaneous WHERE ysnFixedSMTransactionWithWrongPricingScreenId = 0)
	BEGIN

		declare @strNameSpace nvarchar(100) = 'ContractManagement.view.PriceContracts';
		declare @intCorrectPriceContractScreenId int;
		declare @intLatestTransactionId int;

		declare @tblWrongTransactionId table (
			intTransactionId int
		)

		select @intLatestTransactionId = max(intTransactionId) from tblSMTransaction where intScreenId in (
			select intScreenId from tblSMScreen where strNamespace = @strNameSpace
		)

		select @intCorrectPriceContractScreenId = intScreenId from tblSMTransaction where intTransactionId = @intLatestTransactionId

		insert into @tblWrongTransactionId
		SELECT intTransactionId from tblSMTransaction where intScreenId in (
				select intScreenId from tblSMScreen where strNamespace = @strNameSpace
			) and intScreenId <> @intCorrectPriceContractScreenId

		update tblSMLog set tblSMLog.intTransactionId = OrigId
		from tblSMLog
		INNER JOIN
		(
		SELECT Orig.intTransactionId AS OrigId, Wrong.intTransactionId As WrongId FROM (
		SELECT A.intTransactionId, A.intRecordId, B.intScreenId FROM tblSMTransaction A INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId WHERE A.intScreenId = @intCorrectPriceContractScreenId
		) Orig
		INNER JOIN (
		SELECT A.intTransactionId, A.intRecordId, B.intScreenId FROM tblSMTransaction A INNER JOIN tblSMScreen B ON A.intScreenId = B.intScreenId WHERE A.intScreenId in (
																																											select intScreenId from tblSMScreen where strNamespace = @strNameSpace
																																										) and A.intScreenId <> @intCorrectPriceContractScreenId
		) Wrong
		ON Orig.intRecordId = Wrong.intRecordId
		) Map ON tblSMLog.intTransactionId = Map.WrongId

		WHERE tblSMLog.intTransactionId IN
		(
		SELECT intTransactionId from tblSMTransaction where intScreenId in (
				select intScreenId from tblSMScreen where strNamespace = @strNameSpace
			) and intScreenId <> @intCorrectPriceContractScreenId
		)

		delete from t
		from @tblWrongTransactionId wt
		join tblSMTransaction t on t.intTransactionId = wt.intTransactionId

		delete from tblSMScreen where intScreenId in (
				select intScreenId from tblSMScreen where strNamespace = @strNameSpace
			) and intScreenId <> @intCorrectPriceContractScreenId

		UPDATE tblCTMiscellaneous SET ysnFixedSMTransactionWithWrongPricingScreenId = 1
	END



GO
	print 'End fixing SM Transaction records associated to wrong Pricing Screen ID';
GO