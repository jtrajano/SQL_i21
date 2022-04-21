CREATE VIEW vyuQMSampleCuppingSessionTab
AS
SELECT S.intSampleId
	 , CS.intCuppingSessionId
	 , CS.strCuppingSessionNumber
	 , S.intSampleStatusId
	 , SS.strStatus
	 , dtmCuppingDate = dtmCuppingTime
	 , CS.dtmCuppingTime
FROM tblQMSample S
INNER JOIN tblQMCuppingSessionDetail CSD ON CSD.intSampleId = S.intSampleId
INNER JOIN tblQMCuppingSession CS ON CS.intCuppingSessionId = CSD.intCuppingSessionId
INNER JOIN tblQMSample CHILDSAMPLE ON S.intSampleId = CHILDSAMPLE.intRelatedSampleId
INNER JOIN tblQMSampleStatus SS ON CHILDSAMPLE.intSampleStatusId = SS.intSampleStatusId
