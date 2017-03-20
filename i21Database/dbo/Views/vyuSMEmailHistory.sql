CREATE VIEW [dbo].[vyuSMEmailHistory]
AS 
SELECT Activity.intActivityId, Activity.strSubject, Activity.strDetails, strRecipient = dbo.fnSMConcatRecipients(Activity.intActivityId)
FROM tblSMActivity Activity
INNER JOIN tblSMEmailRecipient Recipient on Activity.intActivityId = Recipient.intEmailId
LEFT JOIN tblEMEntity Entity on Recipient.intEntityContactId = Entity.intEntityId
WHERE strType = 'Email'
GROUP BY intActivityId, strSubject, strDetails