﻿CREATE PROCEDURE [dbo].[uspCTUpdatePlannedAvailabilityDate]
	@intContractHeaderId int --> Contract Header ID
	,@intContractDetailId int --> Contract Sequence ID

as

	declare
		@ErrMsg nvarchar(max)
		,@dtmCurrentPlannedAvailabilityDate datetime
		,@dtmCalculatedPlannedAvailabilityDate datetime
		,@dtmSequenceStartDate datetime
		,@strAuditDescription nvarchar(500)
		,@intContractSeq int
		,@intApprovedById int
		,@intLoadingPortLeadTime int
		,@intDestinationPortLeadTime int
		,@intLeadTimeAtSource int
		,@intTotalLeadTime int
		,@intContractTypeId int
		,@ysnCalculatePlannedAvailabilityDateForSale bit = 0
		,@ysnCalculatePlannedAvailabilityDateForPurchase bit = 0
		,@intPositionId int
		,@intUserId int
		;

	begin try

		select
			@intContractTypeId = ch.intContractTypeId
			,@intPositionId = isnull(ch.intPositionId,0)
		from
			tblCTContractHeader ch
			join tblICCommodity co on co.intCommodityId = ch.intCommodityId
		where
			ch.intContractHeaderId = @intContractHeaderId
			and lower(ltrim(rtrim(co.strCommodityCode))) = 'coffee';
	
		select
			@ysnCalculatePlannedAvailabilityDateForPurchase = isnull(ysnCalculatePlannedAvailabilityPurchase,0)
			,@ysnCalculatePlannedAvailabilityDateForSale = isnull(ysnCalculatePlannedAvailabilitySale,0)
		from
			tblCTCompanyPreference

		if (@intContractTypeId is null or (@intContractTypeId = 1 and @ysnCalculatePlannedAvailabilityDateForPurchase = 0)) return;
		if (@intContractTypeId is null or (@intContractTypeId = 2 and @ysnCalculatePlannedAvailabilityDateForSale = 0)) return;

		select
			@dtmSequenceStartDate = cd.dtmStartDate
			,@intContractSeq = cd.intContractSeq
			,@dtmCurrentPlannedAvailabilityDate = cd.dtmPlannedAvailabilityDate
			,@intLoadingPortLeadTime = isnull(l.intLeadTime,0)
			,@intDestinationPortLeadTime = isnull(d.intLeadTime,0)
			,@intLeadTimeAtSource = isnull(l.intLeadTimeAtSource,0)
		from
			tblCTContractDetail cd
			left join tblSMCity l on l.intCityId = cd.intLoadingPortId
			left join tblSMCity d on d.intCityId = cd.intDestinationPortId
		where
			cd.intContractDetailId = @intContractDetailId;

		set @intTotalLeadTime = @intLoadingPortLeadTime + @intDestinationPortLeadTime + @intLeadTimeAtSource;

		if (@intTotalLeadTime = 0)
		begin
			select @intTotalLeadTime = isnull(intNoOfDays,0) from tblCTPosition where intPositionId = @intPositionId;
		end

		set @intTotalLeadTime = isnull(@intTotalLeadTime,0);

		set @dtmCalculatedPlannedAvailabilityDate = DATEADD(DD, @intTotalLeadTime, @dtmSequenceStartDate);

		if (@dtmCalculatedPlannedAvailabilityDate <> @dtmCurrentPlannedAvailabilityDate)
		begin
			
			select top 1 @intUserId = intEntityId from tblEMEntityCredential where lower(rtrim(ltrim(strUserName))) = 'irelyadmin';

			update
				tblCTContractDetail
			set
				dtmPlannedAvailabilityDate = @dtmCalculatedPlannedAvailabilityDate
				,intConcurrencyId = intConcurrencyId + 1
			where
				intContractDetailId = @intContractDetailId;

			SET @strAuditDescription = 'Sequence - ' + CAST(@intContractSeq AS VARCHAR(20)) + ', Planned Availability Date'

			EXEC dbo.uspSMAuditLog
				@keyValue = @intContractHeaderId 
				,@screenName = 'ContractManagement.view.Contract'
				,@entityId = @intUserId
				,@actionType = 'Updated (from Feed)'
				,@actionIcon = 'small-tree-modified'
				,@changeDescription = @strAuditDescription
				,@fromValue = @dtmCurrentPlannedAvailabilityDate
				,@toValue = @dtmCalculatedPlannedAvailabilityDate

			SELECT TOP 1
				@intApprovedById = intApprovedById
			FROM
				tblCTApprovedContract
			WHERE
				intContractDetailId = @intContractDetailId
			ORDER BY
				intApprovedContractId DESC
				
			EXEC uspCTContractApproved @intContractHeaderId = @intContractHeaderId,
				@intApprovedById =  @intApprovedById, 
				@intContractDetailId = @intContractDetailId
		end

	end try
	begin catch
		set @ErrMsg = ERROR_MESSAGE()  
		raiserror (@ErrMsg,18,1,'WITH NOWAIT')  
	end catch