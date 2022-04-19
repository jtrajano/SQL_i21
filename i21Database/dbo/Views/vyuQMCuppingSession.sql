CREATE VIEW vyuQMCuppingSession
AS
SELECT intCuppingSessionId			= CS.intCuppingSessionId
	 , strCuppingSessionNumber		= CS.strCuppingSessionNumber
     , dtmCuppingDate               =  cast(CS.dtmCuppingDate as datetime) + cast(CAST(CS.dtmCuppingTime AS TIME) as datetime) --  CS.dtmCuppingDate + CAST(CS.dtmCuppingTime AS TIME)
     , dtmCuppingTime               = CS.dtmCuppingTime
FROM tblQMCuppingSession CS