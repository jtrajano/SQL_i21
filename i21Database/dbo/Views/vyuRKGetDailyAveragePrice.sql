CREATE VIEW [dbo].[vyuRKGetDailyAveragePrice]

AS

SELECT Header.intDailyAveragePriceId
	, Header.strAverageNo
	, Header.dtmDate
	, Header.intBookId
	, Book.strBook
	, Header.intSubBookId
	, SubBook.strSubBook
	, ysnPosted = ISNULL(Header.ysnPosted, 0)
	, Header.intConcurrencyId
FROM tblRKDailyAveragePrice Header
LEFT JOIN tblCTBook Book ON Book.intBookId = Header.intBookId
LEFT JOIN tblCTSubBook SubBook ON SubBook.intSubBookId = Header.intSubBookId