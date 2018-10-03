CREATE PROCEDURE [dbo].[uspSCProcessDeliverySheetSummaryToTicket]
	@intDeliverySheetId INT
	,@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX)


DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
		,@currencyDecimal			INT
		,@intTicketId				INT
		,@intEntityId				INT
		,@intCustomerStorageId		INT
		,@dblNetUnits				NUMERIC (38,20)
		,@dblCost					NUMERIC (38,20)
		,@strDistributionOption		NVARCHAR(3)
		,@intStorageScheduleId		INT
		,@intSplitEntityId			INT
		,@dblSplitPercent			NUMERIC (38,20)
		,@dblTempSplitQty			NUMERIC (38,20)
		,@dblFinalSplitQty			NUMERIC (38,20)
		,@intInventoryReceiptId		INT;

BEGIN TRY
	SELECT @currencyDecimal = intCurrencyDecimal from tblSMCompanyPreference
	DECLARE @splitTable TABLE(
		[intTicketId] INT NOT NULL, 
		[intEntityId] INT NOT NULL, 
		[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
		[intStorageScheduleTypeId] INT NULL,
		[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
		[intStorageScheduleId] INT NULL,
		[intConcurrencyId] INT NULL
	);
	DECLARE @processTicket TABLE(
		[intTicketId] INT
		,[intEntityId] INT
		,[dblNetUnits] NUMERIC(38,20)
	)
	INSERT INTO @processTicket(
		[intTicketId]
		,[intEntityId]
		,[dblNetUnits]
	)
	SELECT 
		[intTicketId]	= intTicketId
		,[intEntityId]	= intEntityId
		,[dblNetUnits]	= dblNetUnits
	FROM tblSCTicket 
	WHERE intDeliverySheetId = @intDeliverySheetId AND strTicketStatus = 'C'
	DECLARE ticketCursor CURSOR FOR SELECT intTicketId,intEntityId,dblNetUnits FROM @processTicket  
	OPEN ticketCursor;  
	FETCH NEXT FROM ticketCursor INTO @intTicketId, @intEntityId, @dblNetUnits;  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @dblTempSplitQty = @dblNetUnits;
		EXEC [dbo].[uspSCUndistributeTicket] @intTicketId, @intUserId, @intEntityId, 'I', 0, 0, 1
		UPDATE tblSCTicket SET strTicketStatus = 'R' WHERE intTicketId = @intTicketId
		DELETE FROM tblSCTicketSplit WHERE intTicketId = @intTicketId
		
		DELETE FROM @splitTable
		
		INSERT INTO @splitTable(
			[intTicketId]
			,[intEntityId]
			,[dblSplitPercent]
			,[intStorageScheduleTypeId]
			,[strDistributionOption]
			,[intStorageScheduleId]
			,[intConcurrencyId]
		)
		SELECT  
			[intTicketId]					= SC.intTicketId
			,[intEntityId]					= SDS.intEntityId
			,[dblSplitPercent]				= SDS.dblSplitPercent
			,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
			,[strDistributionOption]		= SDS.strDistributionOption
			,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
			,[intConcurrencyId]				= 1
		FROM tblSCDeliverySheetSplit SDS
		INNER JOIN tblSCTicket SC ON SC.intDeliverySheetId = SDS.intDeliverySheetId
		WHERE SDS.intDeliverySheetId = @intDeliverySheetId AND SC.intTicketId = @intTicketId

		INSERT INTO tblSCTicketSplit
		SELECT * FROM @splitTable

		DECLARE splitCursor CURSOR FOR SELECT intEntityId, dblSplitPercent, strDistributionOption, intStorageScheduleId FROM @splitTable
		OPEN splitCursor;  
		FETCH NEXT FROM splitCursor INTO @intSplitEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId;  
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @dblFinalSplitQty =  ROUND((@dblNetUnits * @dblSplitPercent) / 100, @currencyDecimal);
			IF @dblTempSplitQty > @dblFinalSplitQty
				SET @dblTempSplitQty = @dblTempSplitQty - @dblFinalSplitQty;
			ELSE
				SET @dblFinalSplitQty = @dblTempSplitQty

			EXEC [dbo].[uspSCProcessToItemReceipt] @intTicketId, @intUserId, @dblFinalSplitQty, 0, @intSplitEntityId, 0 , @strDistributionOption, @intStorageScheduleId, @intInventoryReceiptId OUTPUT
			
			FETCH NEXT FROM splitCursor INTO @intSplitEntityId, @dblSplitPercent, @strDistributionOption, @intStorageScheduleId;
		END
		CLOSE splitCursor;  
		DEALLOCATE splitCursor;
		UPDATE tblSCTicket SET strTicketStatus = 'C' WHERE intTicketId = @intTicketId
		FETCH NEXT FROM ticketCursor INTO @intTicketId, @intEntityId, @dblNetUnits;
	END
	CLOSE ticketCursor;  
	DEALLOCATE ticketCursor;
END TRY

BEGIN CATCH
BEGIN
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
	END
END CATCH
GO