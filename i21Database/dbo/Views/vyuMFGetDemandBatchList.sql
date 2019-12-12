CREATE VIEW vyuMFGetDemandBatchList
AS
SELECT RM.intInvPlngReportMasterID
	,RM.strPlanNo
	,RM.strInvPlngReportName
	,RM.dtmPostDate
	,DATEDIFF(d, RM.dtmPostDate, GETDATE()) AS intDiff
FROM tblCTInvPlngReportMaster RM
