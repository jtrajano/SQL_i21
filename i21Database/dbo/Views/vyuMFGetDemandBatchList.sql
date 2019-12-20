CREATE VIEW vyuMFGetDemandBatchList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strPlanNo
	,RM.strInvPlngReportName
	,RM.dtmPostDate
	,RM.intBookId
	,RM.intSubBookId
	,DATEDIFF(d, RM.dtmPostDate, GETDATE()) AS intDiff
	,B.strBook
	,SB.strSubBook
	,ISNULL(B.strBook, '') + ' - ' + ISNULL(SB.strSubBook, '') AS strDisplay
FROM tblCTInvPlngReportMaster RM
LEFT JOIN tblCTBook B ON B.intBookId = RM.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = RM.intSubBookId
WHERE IsNULL(ysnPost, 0) = 1
