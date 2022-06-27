CREATE VIEW vyuQMCuppingSession
AS
SELECT intCuppingSessionId			= CS.intCuppingSessionId
	 , strCuppingSessionNumber		= CS.strCuppingSessionNumber
     , dtmCuppingDate               = CS.dtmCuppingDate
     , strCuppingTime               = CONVERT(VARCHAR(8), CS.dtmCuppingTime, 8) COLLATE Latin1_General_CI_AS
FROM tblQMCuppingSession CS