CREATE VIEW [dbo].[vyuARCommissionDetail]
AS
SELECT strComDetailEntityName	= E.strName
	 , intComDetailEntityId		= CD.intEntityId
	 , dblLineItemAmount		= CD.dblAmount
	 , CD.dtmSourceDate
	 , strDocumentNumber		= CASE WHEN CD.strSourceType = 'tblARInvoiceDetail'
											THEN (SELECT TOP 1 I.strInvoiceNumber FROM tblARInvoiceDetail ID INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND ID.intInvoiceDetailId = CD.intSourceId)
									   WHEN CD.strSourceType = 'tblHDTicketHoursWorked'
											THEN (SELECT TOP 1 T.strTicketNumber FROM tblHDTicketHoursWorked THW INNER JOIN tblHDTicket T ON THW.intTicketId = T.intTicketId AND THW.intTicketHoursWorkedId = CD.intSourceId)
									   WHEN CD.strSourceType = 'tblGLDetail'
											THEN (SELECT TOP 1 GL.strTransactionId FROM tblGLDetail GL WHERE GL.intGLDetailId = CD.intSourceId)
								  END

	 , C.*
FROM vyuARCommission C
	INNER JOIN tblARCommissionDetail CD ON C.intCommissionId = CD.intCommissionId
	LEFT JOIN tblEMEntity E ON CD.intEntityId = E.intEntityId
WHERE C.ysnConditional = 0 OR (C.ysnConditional = 1 AND C.ysnApproved = 1)
