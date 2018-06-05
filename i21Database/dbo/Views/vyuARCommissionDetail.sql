CREATE VIEW [dbo].[vyuARCommissionDetail]
AS
SELECT C.*
	 , strComDetailEntityName	= E.strName
	 , intComDetailEntityId		= CD.intEntityId
	 , intCommissionDetailId	= CD.intCommissionDetailId
	 , dblLineItemAmount		= ISNULL(CD.dblAmount, 0.00)
	 , dtmSourceDate			= CD.dtmSourceDate
	 , strSourceType			= CD.strSourceType
	 , strDocumentNumber		= CASE WHEN CD.strSourceType = 'tblARInvoice'
											THEN INVOICE.strInvoiceNumber
									   WHEN CD.strSourceType = 'tblHDTicketHoursWorked'
											THEN HELPDESK.strTicketNumber
									   WHEN CD.strSourceType = 'tblGLDetail'
											THEN GL.strTransactionId
								  END	 
FROM vyuARCommission C
INNER JOIN tblARCommissionDetail CD WITH (NOLOCK) ON CD.intCommissionId = C.intCommissionId
LEFT JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON CD.intEntityId = E.intEntityId
OUTER APPLY (
	SELECT TOP 1intInvoiceId
			, strInvoiceNumber
	FROM dbo.tblARInvoice I WITH (NOLOCK) 
	WHERE I.intInvoiceId = CD.intSourceId
) INVOICE
OUTER APPLY (
	SELECT TOP 1 T.strTicketNumber 
	FROM dbo.tblHDTicketHoursWorked THW WITH (NOLOCK)
	INNER JOIN (
		SELECT intTicketId
			 , strTicketNumber
		FROM dbo.tblHDTicket WITH (NOLOCK)
	) T ON THW.intTicketId = T.intTicketId 
	   AND THW.intTicketHoursWorkedId = CD.intSourceId
) HELPDESK
OUTER APPLY (
	SELECT TOP 1 GL.strTransactionId 
	FROM tblGLDetail GL WITH (NOLOCK)
	WHERE GL.intGLDetailId = CD.intSourceId
) GL