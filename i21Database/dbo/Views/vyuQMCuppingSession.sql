CREATE VIEW vyuQMCuppingSession
AS
SELECT intCuppingSessionId			= CS.intCuppingSessionId
	 , strCuppingSessionNumber		= CS.strCuppingSessionNumber
     , dtmCuppingDate               = CAST(CS.dtmCuppingDate AS DATETIME) + CAST(CAST(CS.dtmCuppingTime AS TIME) AS DATETIME) --  CS.dtmCuppingDate + CAST(CS.dtmCuppingTime AS TIME)
     , dtmCuppingTime               = CS.dtmCuppingTime
FROM tblQMCuppingSession CS