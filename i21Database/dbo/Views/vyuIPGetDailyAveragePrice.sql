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
FROM tblRKDailyAveragePrice D WITH (NOLOCK)
LEFT JOIN tblCTBook B WITH (NOLOCK) ON B.intBookId = D.intBookId
LEFT JOIN tblCTSubBook SB WITH (NOLOCK) ON SB.intSubBookId = D.intSubBookId
