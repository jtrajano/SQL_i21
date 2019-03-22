CREATE PROCEDURE [dbo].[uspSCUpdateTicketContractUsed]
	@intTicketId INT,
	@intContractDetailId INT,
	@dblScheduleQty DECIMAL(38,20),
	@intEntityId int,
	@ysnStorage int = null
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY
	IF NOT EXISTS(SELECT intContractDetailId FROM tblSCTicketContractUsed WHERE intTicketId = @intTicketId AND intContractDetailId = @intContractDetailId)
	BEGIN
		INSERT INTO tblSCTicketContractUsed (intTicketId,intContractDetailId,dblScheduleQty,intEntityId)
		VALUES(@intTicketId,@intContractDetailId,@dblScheduleQty,@intEntityId)
	END
	IF(ISNULL(@ysnStorage,0) = 0)
		BEGIN
			IF EXISTS(SELECT TOP 1 intContractId FROM tblSCTicket WHERE intTicketId = @intTicketId AND ISNULL(intContractId,0) = 0 AND strDistributionOption != 'SPL')
			BEGIN
				UPDATE tblSCTicket SET 
				intContractId = CT.intContractDetailId
				, strContractNumber = CT.strContractNumber
				, intContractSequence = CT.intContractSeq
				, strContractLocation = CT.strLocationName
				, dblScheduleQty = CASE WHEN ISNULL(CT.intContractDetailId,0) > 0 THEN @dblScheduleQty ELSE 0 END
				, dblUnitPrice = CT.dblFutures
				, dblUnitBasis = CT.dblBasis
				, dblFreightRate = ISNULL(CT.dblRate,SC.dblFreightRate)
                , intHaulerId = ISNULL(CT.intVendorId,SC.intHaulerId)
                , ysnFarmerPaysFreight = ISNULL(CT.ysnPrice,SC.ysnFarmerPaysFreight)
				FROM tblSCTicket SC 
				INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
				OUTER APPLY(
					SELECT 
					CTD.intContractHeaderId
					,CTD.intContractDetailId
					,CTH.strContractNumber 
					,SM.strLocationName 
					,CTD.intContractSeq 
					,CTD.dblFutures 
					,CTD.dblBasis 
					,CTCost.dblRate
					,CTCost.intVendorId
					,CTCost.ysnPrice
					FROM tblCTContractDetail CTD 
					INNER JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
					INNER JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = CTD.intCompanyLocationId
					LEFT JOIN tblCTContractCost CTCost ON CTCost.intContractDetailId = CTD.intContractDetailId AND CTCost.intItemId = SCS.intFreightItemId
					WHERE CTD.intContractDetailId = @intContractDetailId
				) CT
				WHERE intTicketId = @intTicketId AND SC.strDistributionOption != 'SPL'
			END
			ELSE
			BEGIN 
				UPDATE tblSCTicket SET dblScheduleQty = @dblScheduleQty  WHERE intTicketId = @intTicketId AND ISNULL(intContractId,0) = @intContractDetailId AND strDistributionOption != 'SPL'
			END
		END
	ELSE
	BEGIN
		UPDATE tblSCTicket SET 
		intContractId = CT.intContractDetailId
		, strContractNumber = CT.strContractNumber
		, intContractSequence = CT.intContractSeq
		, strContractLocation = CT.strLocationName
		FROM tblSCTicket SC 
			OUTER APPLY(
				SELECT 
				CTD.intContractHeaderId
				,CTD.intContractDetailId
				,CTH.strContractNumber 
				,SM.strLocationName 
				,CTD.intContractSeq 
				,CTD.dblFutures 
				,CTD.dblBasis 
				FROM tblCTContractDetail CTD 
				INNER JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = CTD.intContractHeaderId
				INNER JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = CTD.intCompanyLocationId
				WHERE CTD.intContractDetailId = @intContractDetailId
			) CT
		WHERE intTicketId = @intTicketId AND ISNULL(intContractId,0) = 0
	END
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