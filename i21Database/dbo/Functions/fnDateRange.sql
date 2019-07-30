/*
Max 100 million observations -- Date Parts YY QQ MM WK DD HH MI SS

Syntax:
	Select * from [dbo].[fnDateRange]('2019-10-01','2019-10-31','DD',1) 
	Select * from [dbo].[fnDateRange]('2016-01-01','2017-01-01','MM',1) 
*/
CREATE FUNCTION [dbo].[fnDateRange] (
	@R1 datetime
	,@R2 datetime
	,@Part varchar(10)
	,@Incr int
)
RETURNS TABLE
RETURN (
	WITH cte0(M)   AS (SELECT 1 + CASE @Part WHEN 'YY' THEN DATEDIFF(YY,@R1,@R2)/@Incr WHEN 'QQ' THEN DATEDIFF(QQ,@R1,@R2)/@Incr WHEN 'MM' THEN DATEDIFF(MM,@R1,@R2)/@Incr When 'WK' then DateDiff(WK,@R1,@R2)/@Incr When 'DD' then DateDiff(DD,@R1,@R2)/@Incr WHEN 'HH' THEN DATEDIFF(HH,@R1,@R2)/@Incr WHEN 'MI' THEN DATEDIFF(MI,@R1,@R2)/@Incr WHEN 'SS' THEN DATEDIFF(SS,@R1,@R2)/@Incr END),
         cte1(N)   AS (SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1),(1),(1),(1),(1)) N(N)),
         cte2(N)   AS (SELECT TOP (SELECT M FROM cte0) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM cte1 a, cte1 b, cte1 c, cte1 d, cte1 e, cte1 f, cte1 g, cte1 h ),
         cte3(N,D) AS (SELECT 0 ,@R1 UNION ALL SELECT N,CASE @Part WHEN 'YY' THEN DATEADD(YY, N*@Incr, @R1) WHEN 'QQ' THEN DATEADD(QQ, N*@Incr, @R1) When 'MM' then DateAdd(MM, N*@Incr, @R1) When 'WK' then DateAdd(WK, N*@Incr, @R1) When 'DD' then DateAdd(DD, N*@Incr, @R1) When 'HH' then DateAdd(HH, N*@Incr, @R1) WHEN 'MI' THEN DATEADD(MI, N*@Incr, @R1) WHEN 'SS' THEN DATEADD(SS, N*@Incr, @R1) END FROM cte2 )

	SELECT 
		intSequence = N+1
		,dtmDate = D 
	FROM  
		cte3
		,cte0 
	WHERE 
		D <= @R2
)