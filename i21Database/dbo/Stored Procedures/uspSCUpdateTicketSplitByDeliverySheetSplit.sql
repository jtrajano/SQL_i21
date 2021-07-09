CREATE PROCEDURE [dbo].[uspSCUpdateTicketSplitByDeliverySheetSplit]
	@intDeliverySheetId INT
    , @intTicketId  INT = NULL
AS
BEGIN

	IF(@intTicketId IS NULL)
	BEGIN
		--REset All Non-distributed Ticket Splits
		DELETE FROM tblSCTicketSplit 
		WHERE intTicketId IN (	SELECT intTicketId 
								FROM tblSCTicket 
								WHERE intDeliverySheetId = @intDeliverySheetId
									AND (strTicketStatus = 'O' OR strTicketStatus = 'R')
								)

		
		-- Insert Ticket Split base on DS split
		INSERT INTO tblSCTicketSplit(
			[intTicketId]					
			,intCustomerId					
			,[dblSplitPercent]				
			,[intStorageScheduleTypeId]		
			,[strDistributionOption]		
			,[intStorageScheduleId]			
			,[intConcurrencyId]		
		)

		SELECT  
			[intTicketId]					= SC.intTicketId
			,intCustomerId					= SDS.intEntityId
			,[dblSplitPercent]				= SDS.dblSplitPercent
			,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
			,[strDistributionOption]		= SDS.strDistributionOption
			,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
			,[intConcurrencyId]				= 1
		FROM tblSCDeliverySheetSplit SDS
		INNER JOIN tblSCTicket SC
			ON SDS.intDeliverySheetId = SC.intDeliverySheetId
		WHERE SDS.intDeliverySheetId = @intDeliverySheetId 
			AND (SC.strTicketStatus = 'O' OR SC.strTicketStatus = 'R')
	END
	ELSE
	BEGIN
		--REset Ticket Splits
		DELETE FROM tblSCTicketSplit 
		WHERE intTicketId IN (	SELECT intTicketId 
								FROM tblSCTicket 
								WHERE intDeliverySheetId = @intDeliverySheetId
									AND intTicketId = @intTicketId
								)

		
		-- Insert Ticket Split base on DS split
		INSERT INTO tblSCTicketSplit(
			[intTicketId]					
			,intCustomerId					
			,[dblSplitPercent]				
			,[intStorageScheduleTypeId]		
			,[strDistributionOption]		
			,[intStorageScheduleId]			
			,[intConcurrencyId]		
		)

		SELECT  
			[intTicketId]					= SC.intTicketId
			,intCustomerId					= SDS.intEntityId
			,[dblSplitPercent]				= SDS.dblSplitPercent
			,[intStorageScheduleTypeId]		= SDS.intStorageScheduleTypeId
			,[strDistributionOption]		= SDS.strDistributionOption
			,[intStorageScheduleId]			= SDS.intStorageScheduleRuleId
			,[intConcurrencyId]				= 1
		FROM tblSCDeliverySheetSplit SDS
		INNER JOIN tblSCTicket SC
			ON SDS.intDeliverySheetId = SC.intDeliverySheetId
		WHERE SDS.intDeliverySheetId = @intDeliverySheetId 
			AND intTicketId = @intTicketId
	END


END