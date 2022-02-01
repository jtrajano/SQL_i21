CREATE VIEW [dbo].[vyuApiAttachment]
AS

SELECT
      a.intAttachmentId
    , a.dtmDateModified
    , a.intSize
    , a.strScreen
    , a.strFileType
    , a.strName
    , CAST(a.strRecordNo AS INT) intTransactionId
FROM tblSMAttachment a