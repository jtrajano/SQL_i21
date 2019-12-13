CREATE VIEW vyuMFDemandSummaryView
AS
SELECT PS.intInvPlngSummaryId
	,PS.strPlanName
	,PS.dtmDate
	,PS.intUnitMeasureId
	,PS.intBookId
	,PS.intSubBookId
	,PS.strComment
	,UOM.strUnitMeasure
	,B.strBook
	,SB.strSubBook
	,dbo.fnMFGetDemandBatches(PS.intInvPlngSummaryId) AS strDemandPlans
FROM tblMFInvPlngSummary PS
LEFT JOIN tblICUnitMeasure AS UOM ON UOM.intUnitMeasureId = PS.intUnitMeasureId
LEFT JOIN tblCTBook B ON B.intBookId = PS.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = PS.intSubBookId
