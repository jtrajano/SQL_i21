CREATE VIEW [dbo].[vyuSMEmailHistory]
AS 
SELECT 
	Activity.intActivityId, 
	Activity.dtmModified, 
	Activity.strSubject, 
	strDetails = Replace(Replace(dbo.fnStripHtml(Activity.strDetails), CHAR(10), ''), CHAR(13), ''), 
	strRecipient = dbo.fnSMConcatRecipients(Activity.intActivityId)
FROM tblSMActivity Activity
INNER JOIN tblSMEmailRecipient Recipient on Activity.intActivityId = Recipient.intEmailId
LEFT JOIN tblEMEntity Entity on Recipient.intEntityContactId = Entity.intEntityId
WHERE strType = 'Email'
GROUP BY intActivityId, dtmModified, strSubject, strDetails