CREATE VIEW [dbo].[vyuTMLastLeakGasCheckTable]
AS 
				
SELECT 
	dtmLastGasCheck = (SELECT TOP 1 dtmDate 
			FROM tblTMEvent 
			WHERE intSiteID = A.intSiteID
				AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strEventType = 'Event-003')
			ORDER BY dtmDate DESC)

	,dtmLastLeakCheck = (SELECT TOP 1 dtmDate 
			FROM tblTMEvent 
			WHERE intSiteID = A.intSiteID
				AND intEventTypeID = (SELECT TOP 1 intEventTypeID FROM tblTMEventType WHERE strEventType = 'Event-004')
			ORDER BY dtmDate DESC) 
	,A.intSiteID
FROM tblTMSite A

GO