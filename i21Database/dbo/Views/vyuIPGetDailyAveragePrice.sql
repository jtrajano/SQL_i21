CREATE VIEW vyuIPGetDailyAveragePrice
AS
SELECT D.intDailyAveragePriceId
	,D.strAverageNo
	,D.dtmDate
	,D.intBookId
	,D.intSubBookId
	,D.ysnPosted
	,D.intDailyAveragePriceRefId
	,D.intConcurrencyId
	,B.strBook
	,SB.strSubBook
FROM tblRKDailyAveragePrice D
LEFT JOIN tblCTBook B ON B.intBookId = D.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = D.intSubBookId
