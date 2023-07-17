CREATE VIEW [dbo].[vyuRKGetSequenceMonth]
AS
SELECT *
FROM (
	SELECT intDeliveryMonthId = n.n 
		, strDeliveryMonth = RIGHT(CONVERT(VARCHAR(11),DATEADD(dd, -1, DATEADD(MONTH, n.n + DATEDIFF(MONTH, 0, GETDATE()), 0)), 6), 6)
	FROM (
		SELECT n FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) t (n)
	) n
)t
