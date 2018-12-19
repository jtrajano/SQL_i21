﻿CREATE VIEW [dbo].[vyuSMEmailHistory]
AS 
SELECT 
	Activity.intActivityId, 
	Activity.dtmModified, 
	Activity.strSubject, 
	strDetails = Replace(Replace(dbo.fnStripHtml(Activity.strDetails), CHAR(10), ''), CHAR(13), '') COLLATE Latin1_General_CI_AS, 
	strRecipient = dbo.fnSMConcatRecipients(Activity.intActivityId) COLLATE Latin1_General_CI_AS
FROM tblSMActivity Activity
INNER JOIN tblSMEmailRecipient Recipient on Activity.intActivityId = Recipient.intEmailId
LEFT JOIN tblEMEntity Entity on Recipient.intEntityContactId = Entity.intEntityId
WHERE strType = 'Email'
GROUP BY intActivityId, dtmModified, strSubject, strDetails