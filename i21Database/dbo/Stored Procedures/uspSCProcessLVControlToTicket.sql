CREATE PROCEDURE [dbo].[uspSCProcessLVControlToTicket]
	@intTicketLVStagingId INT,
	@ysnPosted BIT,
	@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
--SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@intTicketId INT;

BEGIN TRY
		IF @ysnPosted = 1
			BEGIN
				if exists(select top 1 1 from tblSCTicket a 
					join tblSCTicketLVStaging b
						on a.intScaleSetupId = b.intScaleSetupId
						and a.strTicketNumber = b.strTicketNumber
						where b.intTicketLVStagingId = @intTicketLVStagingId)
				BEGIN
					RAISERROR('Unable to post. Duplicate Ticket', 16, 1);
				end
				INSERT INTO tblSCTicket(
					[strTicketNumber]
					,[intTicketType]
					,[intTicketTypeId]
					,[strInOutFlag]
					,[dtmTicketDateTime]
					,[strTicketStatus]
					,[intEntityId]
					,[intItemId]
					,[intCommodityId]
					,[intProcessingLocationId]
					,[intTicketLocationId]
					,[intDiscountLocationId]
					,[dblGrossWeight]
					,[dtmGrossDateTime]
					,[dblTareWeight]
					,[dtmTareDateTime]
					,[dblGrossUnits]
					,[dblShrink]
					,[dblNetUnits]
					,[dblUnitPrice]
					,[dblUnitBasis]
					,[strTicketComment]
					,[intDiscountId]
					,[intDiscountSchedule]
					,[dblFreightRate]
					,[intHaulerId]
					,[dblTicketFees]
					,[ysnFarmerPaysFreight]
					,[ysnCusVenPaysFees]
					,[intCurrencyId]
					,[intContractId]
					,[strContractNumber]
					,[intContractSequence]
					,[intEntityScaleOperatorId]
					,[strScaleOperatorUser]
					,[strTruckName]
					,[strDriverName]
					,[strCustomerReference]
					,[intAxleCount]
					,[ysnDriverOff]
					,[ysnGrossManual]
					,[ysnTareManual]
					,[intStorageScheduleTypeId]
					,[strDistributionOption]
					,[strPitNumber]
					,[intTicketPoolId]
					,[intScaleSetupId]
					,[intSplitId]
					,[strItemUOM]
					,[ysnSplitWeightTicket]
					,[intItemUOMIdFrom]
					,[intItemUOMIdTo]
					,[strCostMethod]
					,[strDiscountComment]
					,[dblConvertedUOMQty]
					,[ysnHasGeneratedTicketNumber]
					,[intDistributionMethod]
					,[intTicketLVStagingId]
					,[strSourceType]
					,[intConcurrencyId]

					,[intSubLocationId]
					,[intStorageLocationId]
					)
				SELECT 
					[strTicketNumber]
					,[intTicketType]
					,[intTicketTypeId]
					,[strInOutFlag]
					,[dtmTicketDateTime]
					,[strTicketStatus]
					,[intEntityId]
					,[intItemId]
					,[intCommodityId]
					,[intCompanyLocationId]
					,[intCompanyLocationId]
					,[intCompanyLocationId]
					,[dblGrossWeight]
					,[dtmGrossDateTime]
					,[dblTareWeight]
					,[dtmTareDateTime]
					,[dblGrossUnits]
					,[dblShrink]
					,[dblNetUnits]
					,[dblUnitPrice]
					,[dblUnitBasis]
					,[strTicketComment]
					,[intDiscountId]
					,[intDiscountScheduleId]
					,[dblFreightRate]
					,[intHaulerId]
					,[dblTicketFees]
					,[ysnFarmerPaysFreight]
					,[ysnCusVenPaysFees]
					,[intCurrencyId]
					,[intContractId]
					,[strContractNumber]
					,[intContractSequence]
					,[intEntityScaleOperatorId]
					,[strScaleOperatorUser]
					,[strTruckName]
					,[strDriverName]
					,[strCustomerReference]
					,[intAxleCount]
					,[ysnDriverOff]
					,[ysnGrossManual]
					,[ysnTareManual]
					,[intStorageScheduleTypeId]
					,[strDistributionOption]
					,[strPitNumber]
					,[intTicketPoolId]
					,TicketStaging.[intScaleSetupId]
					,[intSplitId]
					,[strItemUOM]
					,[ysnSplitWeightTicket]
					,[intItemUOMIdFrom]
					,[intItemUOMIdTo]
					,[strCostMethod]
					,[strDiscountComment]
					,[dblConvertedUOMQty]
					,1
					,1
					,[intTicketLVStagingId]
					,[strSourceType]
					,1
					,Setup.[intSubLocationId] 
					,Setup.[intStorageLocationId]
				FROM [dbo].[tblSCTicketLVStaging] TicketStaging
					left join ( select intScaleSetupId,intSubLocationId,intStorageLocationId  from tblSCScaleSetup) Setup
						on TicketStaging.intScaleSetupId = Setup.intScaleSetupId
					WHERE intTicketLVStagingId = @intTicketLVStagingId

				SELECT @intTicketId = SCOPE_IDENTITY()

				INSERT INTO tblQMTicketDiscount(
					[dblGradeReading]
					,[dblShrinkPercent]
					,[dblDiscountAmount]
					,[dblDiscountDue]
					,[dblDiscountPaid]
					,[dtmDiscountPaidDate]
					,[intDiscountScheduleCodeId]
					,[intTicketId]
					,[intTicketFileId]
					,[intSort]
					,[ysnGraderAutoEntry]
					,[strCalcMethod]
					,[strShrinkWhat]
					,[strSourceType]
					,[strDiscountChargeType]
					,[intConcurrencyId]
				)
				SELECT [dblGradeReading]
					,[dblShrinkPercent]
					,[dblDiscountAmount]
					,[dblDiscountDue]
					,[dblDiscountPaid]
					,[dtmDiscountPaidDate]
					,[intDiscountScheduleCodeId]
					,@intTicketId
					,[intTicketFileId]
					,[intSort]
					,[ysnGraderAutoEntry]
					,[strCalcMethod]
					,[strShrinkWhat]
					,[strSourceType]
					,[strDiscountChargeType]
					,1
				FROM [dbo].[tblSCTicketDiscountLVStaging] WHERE intTicketId = @intTicketLVStagingId and strSourceType = 'Scale'

					--Audit Log
				EXEC dbo.uspSMAuditLog 
					@keyValue			= @intTicketId					-- Primary Key Value of the Ticket. 
					,@screenName		= 'Grain.view.Scale'			-- Screen Namespace
					,@entityId			= @intUserId					-- Entity Id.
					,@actionType		= 'Updated'						-- Action Type
					,@changeDescription	= 'LV Control to Scale Ticket'	-- Description
					,@fromValue			= 'Unposted'					-- Previous Value
					,@toValue			= 'Posted'						-- New Value
					,@details			= '';
			END
		ELSE
			BEGIN 
				SELECT @intTicketId = intTicketId FROM tblSCTicket WHERE intTicketLVStagingId = @intTicketLVStagingId AND strTicketStatus = 'O'
				IF ISNULL(@intTicketId, 0) > 0
				BEGIN
					UPDATE tblSCTicket SET ysnHasGeneratedTicketNumber = 0 WHERE intTicketId = @intTicketId
					DELETE FROM tblQMTicketDiscount WHERE intTicketId = @intTicketId AND strSourceType = 'Scale'
					DELETE FROM tblSCTicket where intTicketLVStagingId = @intTicketLVStagingId

					--Audit Log
					EXEC dbo.uspSMAuditLog 
						@keyValue			= @intTicketLVStagingId				-- Primary Key Value of the Ticket. 
						,@screenName		= 'Grain.view.ScaleLVControl'		-- Screen Namespace
						,@entityId			= @intUserId						-- Entity Id.
						,@actionType		= 'Updated'							-- Action Type
						,@changeDescription	= 'LV Control to Scale Ticket'		-- Description
						,@fromValue			= 'Posted'							-- Previous Value
						,@toValue			= 'Unposted'						-- New Value
						,@details			= '';
				END
				ELSE
				BEGIN
					RAISERROR('Unable to unpost transaction Scale Ticket is already completed or already had previous transaction', 16, 1);
				END
				
			END
	_Exit:

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH