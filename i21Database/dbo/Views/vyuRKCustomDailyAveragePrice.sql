CREATE VIEW [dbo].[vyuRKCustomDailyAveragePrice]
AS
SELECT [DailyAveragePriceId] = t.intDailyAveragePriceId
	, [AverageNo] = t.strAverageNo
	, [Date] = t.dtmDate
	, [BookId] = t.intBookId
	, [Book] = t.strBook
	, [SubBookId] = t.intSubBookId
	, [SubBook] = t.strSubBook
	, [Posted] = t.ysnPosted
FROM vyuRKGetDailyAveragePrice t