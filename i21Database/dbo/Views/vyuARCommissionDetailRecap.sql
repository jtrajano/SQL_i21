CREATE VIEW [dbo].[vyuARCommissionDetailRecap]
AS
SELECT CRD.*
     , strEntityName	= EM.strName
	 , strDocumentNumber = CASE WHEN CRD.strSourceType IN ('tblARInvoiceDetail', 'tblARInvoice')
									THEN I.strInvoiceNumber
								WHEN CRD.strSourceType = 'tblGLDetail'
									THEN GL.strTransactionId
								WHEN CRD.strSourceType = 'tblHDTicketHoursWorked'
									THEN T.strTicketNumber
							END
FROM tblARCommissionRecapDetail CRD
	LEFT JOIN tblEMEntity EM ON CRD.intEntityId = EM.intEntityId
	LEFT JOIN tblARInvoice I ON CRD.intSourceId = I.intInvoiceId
	LEFT JOIN tblHDTicketHoursWorked THW ON CRD.intSourceId = THW.intTicketHoursWorkedId AND CRD.strSourceType = 'tblHDTicketHoursWorked'
	LEFT JOIN tblHDTicket T ON THW.intTicketId = T.intTicketId
	LEFT JOIN tblGLDetail GL ON CRD.intSourceId = GL.intGLDetailId
