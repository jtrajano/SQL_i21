CREATE VIEW vyuMFGetDemandBatchList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strPlanNo
	,RM.strInvPlngReportName
	,RM.dtmDate
	,RM.dtmPostDate
	,RM.intBookId
	,RM.intSubBookId
	,DATEDIFF(d, RM.dtmDate, GETDATE()) AS intDiff
	,B.strBook
	,SB.strSubBook
	,ISNULL(B.strBook, '') + ' - ' + ISNULL(SB.strSubBook, '') AS strDisplay
	,RM.ysnPost
	,RM.ysnTest
FROM tblCTInvPlngReportMaster RM
LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
--WHERE IsNULL(ysnPost, 0) = 1
