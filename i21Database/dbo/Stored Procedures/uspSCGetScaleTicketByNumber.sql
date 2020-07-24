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
	
	SELECT 
		intTicketId
		,strTicketNumber
		,strTicketStatus
		,strTicketStatusDescription = (CASE
										WHEN A.strTicketStatus = 'O' THEN 'OPEN'
										WHEN A.strTicketStatus = 'A' THEN 'PRINTED'
										WHEN A.strTicketStatus = 'C' THEN 'COMPLETED'
										WHEN A.strTicketStatus = 'V' THEN 'VOID'
										WHEN A.strTicketStatus = 'R' THEN 'REOPENED'
										WHEN A.strTicketStatus = 'S' THEN 'STARTED' 
										WHEN A.strTicketStatus = 'I' THEN 'IN TRANSIT'
										WHEN A.strTicketStatus = 'D' THEN 'DELIVERED'  
										WHEN A.strTicketStatus = 'H'  THEN 'HOLD'
										END) COLLATE Latin1_General_CI_AS 
		,strName
		,B.intEntityId
		,strScaleStation = D.strStationShortDescription
		,C.strTicketType
	INTO #ScaleTickets 
	FROM tblSCTicket A
	LEFT JOIN tblEMEntity B
		ON ISNULL(A.intEntityId,0) = ISNULL(B.intEntityId,0)
	LEFT JOIN tblSCListTicketTypes C
		ON ISNULL(A.intTicketTypeId,0) = ISNULL(C.intTicketTypeId,0)
	LEFT JOIN tblSCScaleSetup D
		ON A.intScaleSetupId = D.intScaleSetupId
	WHERE A.strTicketNumber = @strTicketNumber


	SELECT @ysnBlank = CASE WHEN COUNT(1) > 0 THEN 0 ELSE 1 END FROM #ScaleTickets

	IF(@ysnBlank = 1)
		BEGIN
			IF(@ysnRaiseIfError = 1)
				BEGIN
					RAISERROR(@strBlankMessage,11,1)
				END
			ELSE
				BEGIN
					SELECT 
						intTicketId = NULL
						,strTicketNumber = NULL
						,strTicketStatus = @strBlankMessage 
						,intEntityId = NULL 
						,strName = NULL
						,strScaleStation = NULL
						,strTicketType = NULL
				END
		END
	ELSE
		BEGIN
			SELECT 
				intTicketId
				,strTicketNumber
				,strTicketStatus
				,intEntityId
				,strName 
				,strScaleStation
				,strTicketType
			FROM #ScaleTickets
		END
END