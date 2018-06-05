CREATE PROC uspRKCurrencyExposureSummary

AS
SELECT CONVERT(int,ROW_NUMBER() OVER(order by strSum)) as intRowNum,* FROM(
SELECT  '' strSum, null dblUSD,1 as intConcurrencyId)t