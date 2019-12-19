CREATE VIEW vyuMFGetDemandBatchList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strPlanNo
	,RM.strInvPlngReportName
	,RM.dtmPostDate
	,RM.intBookId
	,RM.intSubBookId
	,DATEDIFF(d, RM.dtmPostDate, GETDATE()) AS intDiff
FROM tblCTInvPlngReportMaster RM
WHERE IsNULL(ysnPost, 0) = 1
