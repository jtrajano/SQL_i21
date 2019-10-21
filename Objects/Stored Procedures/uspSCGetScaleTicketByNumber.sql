CREATE PROCEDURE [dbo].[uspSCGetScaleTicketByNumber]
	@strTicketNumber VARCHAR(150),
	@ysnRaiseIfError BIT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
BEGIN
	DECLARE @ysnBlank BIT = 0;
	DECLARE @strBlankMessage VARCHAR(100) = 'Scale Ticket Number ' + @strTicketNumber + ' does not exist';
	WITH ScaleTicket (intTicketId,strTicketNumber,strTicketStatus,strTicketStatusDescription,strName,intEntityId)
	AS (SELECT intTicketId,strTicketNumber,strTicketStatus,strTicketStatusDescription,ISNULL(strName,'') strName,intEntityId FROM vyuSCTicketView WHERE strTicketNumber = @strTicketNumber) --and strTicketStatus NOT IN('C','V'))
	SELECT * INTO #ScaleTickets FROM ScaleTicket;

	SELECT @ysnBlank = CASE WHEN COUNT(1) > 0 THEN 0 ELSE 1 END FROM #ScaleTickets

	IF(@ysnBlank = 1)
		BEGIN
			IF(@ysnRaiseIfError = 1)
				BEGIN
					RAISERROR(@strBlankMessage,11,1)
				END
			ELSE
				BEGIN
					SELECT NULL intTicketId,NULL strTicketNumber,@strBlankMessage strTicketStatus,NULL intEntityId, NULL strName
				END
		END
	ELSE
		BEGIN
			SELECT TOP 1 intTicketId,strTicketNumber,strTicketStatus,intEntityId,strName FROM #ScaleTickets
		END
END