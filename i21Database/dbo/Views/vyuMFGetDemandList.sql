CREATE VIEW vyuMFGetDemandList
AS
SELECT DH.intDemandHeaderId
	,DH.strDemandNo
	,DH.strDemandName
	,DH.dtmDate
	,B.strBook
	,SB.strSubBook
	,DH.ysnImported
FROM tblMFDemandHeader DH
LEFT JOIN tblCTBook B ON B.intBookId = DH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = DH.intSubBookId
