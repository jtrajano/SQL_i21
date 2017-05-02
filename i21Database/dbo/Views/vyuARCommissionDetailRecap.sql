CREATE VIEW [dbo].[vyuARCommissionDetailRecap]
AS
SELECT CRD.*
     , strEntityName	= EM.strName
	 , strDocumentNumber = CASE WHEN CRD.strSourceType = 'tblARInvoiceDetail'
									THEN I.strInvoiceNumber
								WHEN CRD.strSourceType = 'tblGLDetail'
									THEN GL.strTransactionId
								WHEN CRD.strSourceType = 'tblHDTicketHoursWorked'
									THEN T.strTicketNumber
							END
FROM tblARCommissionRecapDetail CRD
	LEFT JOIN tblEMEntity EM ON CRD.intEntityId = EM.intEntityId
	LEFT JOIN tblARInvoiceDetail ID ON CRD.intSourceId = ID.intInvoiceDetailId
	LEFT JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	LEFT JOIN tblHDTicketHoursWorked THW ON CRD.intSourceId = THW.intTicketHoursWorkedId
	LEFT JOIN tblHDTicket T ON T.intTicketId = THW.intTicketId
	LEFT JOIN tblGLDetail GL ON CRD.intSourceId = GL.intGLDetailId
