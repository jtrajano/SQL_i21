CREATE PROCEDURE [dbo].[uspSCAutoScaleLogResetSchdule]
	@TICKET_ID INT,
	@USER_ID INT
AS
BEGIN
	DECLARE @CURRENT_ID INT
	

	
	DECLARE @UNIT NUMERIC(18,6)
	DECLARE @CONTRACT_ID INT
	

	SELECT @CURRENT_ID = MIN(intTicketAutoScaleLogId) 
	FROM tblSCTicketAutoScaleLog
		WHERE intTicketId = @TICKET_ID
			AND ysnHeader = 0
		
	WHILE @CURRENT_ID IS NOT NULL
	BEGIN
		
		SELECT @UNIT = dblUnit * -1
			,@CONTRACT_ID = intContractDetailId
		FROM tblSCTicketAutoScaleLog 
		WHERE intTicketAutoScaleLogId = @CURRENT_ID
			AND ysnHeader = 0

		PRINT 'CREATING A SCHEDULE FOR ' + LTRIM(@CONTRACT_ID) + ' FOR TICKET' + LTRIM(@TICKET_ID) + ' BY ' + LTRIM(@UNIT)
		EXEC	uspCTUpdateScheduleQuantity 
			@intContractDetailId	=	@CONTRACT_ID,
			@dblQuantityToUpdate	=	@UNIT ,
			@intUserId				=	@USER_ID,
			@intExternalId			=	@TICKET_ID,
			@strScreenName			=	'Auto - Scale'


		SELECT @CURRENT_ID = MIN(intTicketAutoScaleLogId) 
		FROM tblSCTicketAutoScaleLog		
			WHERE intTicketId = @TICKET_ID
			AND intTicketAutoScaleLogId > @CURRENT_ID			
			AND ysnHeader = 0
	END
	
	DELETE FROM tblSCTicketAutoScaleLog WHERE intTicketId = @TICKET_ID
END
