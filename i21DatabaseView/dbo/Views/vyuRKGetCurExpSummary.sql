CREATE VIEW vyuRKGetCurExpSummary
AS
SELECT intCurrencyExposureId,
	strTotalSum strSum,
	dblUSD,
	1 as intConcurrencyId 
FROM tblRKCurExpSummary 