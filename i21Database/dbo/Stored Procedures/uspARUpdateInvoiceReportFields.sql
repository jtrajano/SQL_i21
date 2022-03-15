CREATE PROCEDURE dbo.uspARUpdateInvoiceReportFields
	  @InvoiceIds	InvoiceId	READONLY
	, @ysnRebuild	BIT = 0
AS

DECLARE @FinalInvoiceIds InvoiceId 

IF @ysnRebuild = 1
	BEGIN
		INSERT INTO @FinalInvoiceIds (intHeaderId)
		SELECT DISTINCT I.intInvoiceId 
		FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		WHERE I.strTicketNumbers IS NULL
		  AND ID.intTicketId IS NOT NULL
	END
ELSE
	BEGIN
		INSERT INTO @FinalInvoiceIds (intHeaderId)
		SELECT DISTINCT intHeaderId 
		FROM @InvoiceIds
	END

UPDATE I
SET strTicketNumbers		= SCALETICKETS.strTicketNumbers  
FROM tblARInvoice I
INNER JOIN @FinalInvoiceIds FI ON I.intInvoiceId = FI.intHeaderId
CROSS APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
		FROM (
			SELECT DISTINCT intTicketId
				          , intInvoiceId 
			FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
			INNER JOIN @FinalInvoiceIds FI ON ID.intInvoiceId = FI.intHeaderId
			WHERE intTicketId IS NOT NULL
		) ID 		
		INNER JOIN (
			SELECT intTicketId
				 , strTicketNumber 
			FROM dbo.tblSCTicket WITH(NOLOCK)
		) T ON ID.intTicketId = T.intTicketId
		WHERE ID.intInvoiceId = I.intInvoiceId 
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS

UPDATE I
SET strCustomerReferences	= CUSTOMERREFERENCES.strCustomerReferences
FROM tblARInvoice I
INNER JOIN @FinalInvoiceIds FI ON I.intInvoiceId = FI.intHeaderId
CROSS APPLY (
	SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strCustomerReference AS VARCHAR(200))  + ', '
		FROM (
			SELECT DISTINCT intTicketId
				          , intInvoiceId 
			FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
			INNER JOIN @FinalInvoiceIds FI ON ID.intInvoiceId = FI.intHeaderId
			WHERE intTicketId IS NOT NULL
		) ID 		
		INNER JOIN (
			SELECT intTicketId
				 , strCustomerReference 
			FROM dbo.tblSCTicket WITH(NOLOCK)
			WHERE ISNULL(strCustomerReference, '') <> ''
		) T ON ID.intTicketId = T.intTicketId 
		WHERE ID.intInvoiceId = I.intInvoiceId
		GROUP BY ID.intInvoiceId, ID.intTicketId, T.strCustomerReference
		FOR XML PATH ('')
	) INV (strCustomerReference)
) CUSTOMERREFERENCES