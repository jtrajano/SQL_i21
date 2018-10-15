PRINT '********************** BEGIN SC Triggers **********************'
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblSCTicket]'))
DROP TRIGGER [dbo].[trg_tblSCTicket]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trg_tblSCTicket] ON [dbo].[tblSCTicket]
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @strTicketStatus NVARCHAR(4);
	DECLARE @strTicketNumber NVARCHAR(MAX);
	DECLARE @error NVARCHAR(500);
	DECLARE @ysnHasGeneratedTicketNumber BIT;

	SELECT @strTicketNumber = strTicketNumber, @strTicketStatus = strTicketStatus, @ysnHasGeneratedTicketNumber = ysnHasGeneratedTicketNumber FROM deleted

	IF ISNULL(@ysnHasGeneratedTicketNumber, 0) = 1
		BEGIN
			SET @error = 'You cannot delete Scale Ticket (' + @strTicketNumber + ') already had valid ticket number';
			RAISERROR(@error, 16, 1);
		END
	ELSE
		BEGIN
			DELETE A
			FROM [tblSCTicket] A
			INNER JOIN DELETED B ON A.intTicketId = B.intTicketId
		END
END
GO

PRINT '********************** END SC Triggers **********************'
GO