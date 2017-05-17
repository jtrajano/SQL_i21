

CREATE VIEW [dbo].[vyuCFTransactionMargin]
AS
SELECT       ROW_NUMBER() OVER (ORDER BY intTransactionId) AS intTransactionMarginId, intTransactionId,
dblMargin = ISNULL((SELECT TOP 1 dblMargin FROM dbo.fnCFGetTransactionMargin(intTransactionId,0,0,0,0,0,0,strPriceBasis)),0),
dblCost = ISNULL((SELECT TOP 1 dblCost FROM dbo.fnCFGetTransactionMargin(intTransactionId,0,0,0,0,0,0,strPriceBasis)),0)
FROM            dbo.tblCFTransaction


