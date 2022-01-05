CREATE PROCEDURE uspCTDeletePrice
	@intContractDetailId int
	,@intAssignFuturesToContractSummaryId int
	,@intUserId int
AS

declare
	@ErrorMsg nvarchar(max)
	,@intPriceContractId int
	,@intPriceFixationId int
	,@intPriceFixationDetailId int
	,@intFixationDetailCount int = 0
	,@intFixationCount int = 0
	,@strXML nvarchar(max)
	,@dblQuantity numeric(18,6)
	,@dblFutures numeric(18,6)
	;

begin try

	if not exists (select top 1 1 from tblCTPriceFixationDetail where intAssignFuturesToContractSummaryId = isnull(@intAssignFuturesToContractSummaryId,0))
	begin
		goto _exit;
	end

	select
		@intFixationDetailCount = count(distinct pfd2.intPriceFixationDetailId)
	from
		tblCTPriceFixationDetail pfd
		left join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
		left join tblCTPriceFixationDetail pfd2 on pfd2.intPriceFixationId = pf.intPriceFixationId
	where
		pfd.intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId

	if (@intFixationDetailCount = 1)
	begin
		select
			@intFixationCount = count(distinct pf2.intPriceFixationId)
		from
			tblCTPriceFixationDetail pfd
			left join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
			left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
			left join tblCTPriceFixation pf2 on pf2.intPriceContractId = pc.intPriceContractId
		where
			pfd.intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
	end

	select
		top 1 @intPriceContractId = pf.intPriceContractId
		,@intPriceFixationId = pf.intPriceFixationId
		,@intPriceFixationDetailId = pfd.intPriceFixationDetailId
		,@dblQuantity = pfd.dblQuantity
		,@dblFutures = pfd.dblFutures
	from
		tblCTPriceFixationDetail pfd
		left join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
	where
		pfd.intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId


	set @strXML = '';


	if (@intFixationCount = 1)
	begin   
        set @strXML = @strXML + '<PreProcessXML>';
        set @strXML = @strXML + '<intPriceContractId>' + convert(nvarchar(20),@intPriceContractId) + '</intPriceContractId>';
        set @strXML = @strXML + '<strPriceContractState>Deleted</strPriceContractState>';
        set @strXML = @strXML + '<intPriceFixationId>0</intPriceFixationId>';
        set @strXML = @strXML + '<strPriceFixationState>None</strPriceFixationState>';
        set @strXML = @strXML + '<intPriceFixationDetailId>0</intPriceFixationDetailId>';
        set @strXML = @strXML + '<strPriceFixationDetailState>None</strPriceFixationDetailState>';
        set @strXML = @strXML + '<dblTransactionQuantity>0</dblTransactionQuantity>';
        set @strXML = @strXML + '<dblFuturePrice>0</dblFuturePrice>';
        set @strXML = @strXML + '</PreProcessXML>';
	end
	else
	begin
		if (@intFixationDetailCount = 1)
		begin
        	set @strXML = @strXML + '<PreProcessXML>';
	        set @strXML = @strXML + '<intPriceContractId>0</intPriceContractId>';
	        set @strXML = @strXML + '<strPriceContractState>Modified</strPriceContractState>';
	        set @strXML = @strXML + '<intPriceFixationId>' + convert(nvarchar(20),@intPriceFixationId) + '</intPriceFixationId>';
	        set @strXML = @strXML + '<strPriceFixationState>Deleted</strPriceFixationState>';
	        set @strXML = @strXML + '<intPriceFixationDetailId>0</intPriceFixationDetailId>';
	        set @strXML = @strXML + '<strPriceFixationDetailState>None</strPriceFixationDetailState>';
	        set @strXML = @strXML + '<dblTransactionQuantity>0</dblTransactionQuantity>';
	        set @strXML = @strXML + '<dblFuturePrice>0</dblFuturePrice>';
        	set @strXML = @strXML + '</PreProcessXML>';
		end
		else
		begin
        	set @strXML = @strXML + '<PreProcessXML>';
	        set @strXML = @strXML + '<intPriceContractId>0</intPriceContractId>';
	        set @strXML = @strXML + '<strPriceContractState>Modified</strPriceContractState>';
	        set @strXML = @strXML + '<intPriceFixationId>0</intPriceFixationId>';
	        set @strXML = @strXML + '<strPriceFixationState>Modified</strPriceFixationState>';
	        set @strXML = @strXML + '<intPriceFixationDetailId>' + convert(nvarchar(20),@intPriceFixationDetailId) + '</intPriceFixationDetailId>';
	        set @strXML = @strXML + '<strPriceFixationDetailState>Deleted</strPriceFixationDetailState>';
	        set @strXML = @strXML + '<dblTransactionQuantity>' + convert(nvarchar(20),@dblQuantity) + '</dblTransactionQuantity>';
	        set @strXML = @strXML + '<dblFuturePrice>' + convert(nvarchar(20),@dblFutures) + '</dblFuturePrice>';
        	set @strXML = @strXML + '</PreProcessXML>';
		end
	end

	set @strXML = '<PreProcessXMLs>' + @strXML + '</PreProcessXMLs>'

	EXEC uspCTPreProcessPriceContract @strXML = @strXML, @intUserId = @intUserId;

	if (@intFixationCount = 1)
	begin		
		delete
			pc
		from
			tblCTPriceFixationDetail pfd
			left join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
			left join tblCTPriceContract pc on pc.intPriceContractId = pf.intPriceContractId
		where
			pfd.intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId

	end
	else
	begin
		if (@intFixationDetailCount = 1)
		begin		
			delete
				pf
			from
				tblCTPriceFixationDetail pfd
				left join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
			where
				pfd.intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId

		end
		else
		begin

			update pf
			set
				pf.dblLotsFixed = pf.dblLotsFixed - pfd.dblNoOfLots
			from
				tblCTPriceFixationDetail pfd
				join tblCTPriceFixation pf on pf.intPriceFixationId = pfd.intPriceFixationId
			where
				pfd.intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId;
				
			delete tblCTPriceFixationDetail
			where
				intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
		end
	end

	EXEC uspCTPostProcessPriceContract @intPriceContractId = @intPriceContractId, @intUserId = @intUserId, @dtmLocalDate = default;

	_exit:


end try
begin catch
	SET @ErrorMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrorMsg,18,1,'WITH NOWAIT')
end catch