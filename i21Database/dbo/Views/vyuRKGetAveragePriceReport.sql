CREATE VIEW [dbo].[vyuRKGetAveragePriceReport]

AS

SELECT * FROM dbo.fnRKGetAveragePriceReport(GETDATE())