CREATE VIEW vyuQMCuppingSession
AS
SELECT intCuppingSessionId			= CS.intCuppingSessionId
	 , strCuppingSessionNumber		= CS.strCuppingSessionNumber
     , dtmCuppingDate               = CS.dtmCuppingDate + CAST(CS.dtmCuppingTime AS TIME)
     , dtmCuppingTime               = CS.dtmCuppingTime
FROM tblQMCuppingSession CS