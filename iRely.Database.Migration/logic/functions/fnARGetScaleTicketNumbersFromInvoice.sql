--liquibase formatted sql

-- changeset Von:fnARGetScaleTicketNumbersFromInvoice.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetScaleTicketNumbersFromInvoice]
(
	@intInvoiceId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strTicketNumbers NVARCHAR(MAX) = NULL

	SELECT @strTicketNumbers = COALESCE(@strTicketNumbers + ', ', '') + RTRIM(LTRIM(T.strTicketNumber))
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
		INNER JOIN (SELECT intTicketId
						 , strTicketNumber 
					FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
	GROUP BY intInvoiceId, ID.intTicketId, T.strTicketNumber
	HAVING ID.intInvoiceId = @intInvoiceId
	
	RETURN @strTicketNumbers
END



