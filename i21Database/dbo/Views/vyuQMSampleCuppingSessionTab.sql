CREATE VIEW vyuQMSampleCuppingSessionTab
AS
SELECT intSampleId				= S.intSampleId
	 , intCuppingSessionId		= CS.intCuppingSessionId
	 , strCuppingSessionNumber	= CS.strCuppingSessionNumber
	 , intSampleStatusId		= S.intSampleStatusId
	 , strStatus				= SS.strStatus
	 , dtmCuppingDate			= CS.dtmCuppingDate
	 , strCuppingTime			= CONVERT(VARCHAR(8), CS.dtmCuppingTime, 8)
FROM tblQMSample S
INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intSampleId = S.intSampleId
INNER JOIN tblQMCuppingSession CS ON CS.intCuppingSessionId = CSD.intCuppingSessionId
INNER JOIN tblQMSample CHILDSAMPLE ON S.intSampleId = CHILDSAMPLE.intParentSampleId
INNER JOIN tblQMSampleStatus SS ON CHILDSAMPLE.intSampleStatusId = SS.intSampleStatusId
