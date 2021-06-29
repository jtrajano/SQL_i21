CREATE VIEW [dbo].[vyuTRImportAttachmentDetail]
   AS
SELECT IAD.intImportAttachmentDetailId
, IA.intImportAttachmentId
, IAD.strInvoiceId
, IAD.ysnDelete
, IAD.intConcurrencyId
, IAD.ysnValid
, IAD.strMessage
, IA.dtmImportDate
, IAD.intLoadHeaderId
, IAD.strFileName
, IA.strSource
FROM dbo.tblTRImportAttachmentDetail AS IAD INNER JOIN
dbo.tblTRImportAttachment AS IA ON IA.intImportAttachmentId = IAD.intImportAttachmentId INNER JOIN
dbo.tblEMEntity AS EM ON EM.intEntityId = IA.intUserId