CREATE VIEW [dbo].[vyuApiAttachment]
AS

SELECT
      a.intAttachmentId
    , a.dtmDateModified
    , a.intSize
    , a.strScreen
    , a.strFileType
    , a.strName
    , a.strComment
    , CAST(a.strRecordNo AS INT) intTransactionId
    , a.intEntityId
    , e.strName strEntityName
FROM tblSMAttachment a
LEFT JOIN tblEMEntity e ON e.intEntityId = a.intEntityId