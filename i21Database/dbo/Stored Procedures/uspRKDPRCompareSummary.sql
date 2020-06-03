CREATE PROCEDURE uspRKDPRCompareSummary
	@intDPRRun1 INT 
	,@intDPRRun2 INT
AS

BEGIN
select 

 strType
 ,dblTotal = sum(dblTotal) 
 into #temp1
from tblRKTempDPRDetailLog
where intRunNumber = @intDPRRun1
group by strType

select 
 strType
 ,dblTotal = sum(dblTotal) 
 into #temp2
  from tblRKTempDPRDetailLog
where intRunNumber = @intDPRRun2
group by strType


SELECT
	intRowNumber  = row_number() OVER(ORDER BY intOrderId , strBucketType)
	,*
FROM (
	select
		intOrderId = (
			CASE WHEN a.strType = 'Purchase Priced' THEN 1
				 WHEN a.strType = 'Sale Priced' THEN 2
				 WHEN a.strType = 'Purchase HTA' THEN 3
				 WHEN a.strType = 'Sale HTA' THEN 4
				 WHEN a.strType = 'Purchase Basis Deliveries' THEN 5
				 WHEN a.strType = 'Sales Basis Deliveries' THEN 6
				 WHEN a.strType = 'Delayed Pricing' THEN 7
				 WHEN a.strType = 'Company Titled' THEN 8
				 WHEN a.strType = 'Net Physical Position' THEN 9
				 WHEN a.strType = '' THEN 10
				 WHEN a.strType = '' THEN 11
				 WHEN a.strType = 'Net Futures' THEN 12
				 WHEN a.strType = '' THEN 13
				 WHEN a.strType = 'Crush' THEN 14
				 WHEN a.strType = 'Delta Adjusted Options' THEN 15
				 WHEN a.strType = 'Net Hedge' THEN 16
				 WHEN a.strType = 'Purchase DP (Priced Later)' THEN 17
				 WHEN a.strType = 'Sale DP (Priced Later)' THEN 18
				 WHEN a.strType = 'Purchase Basis' THEN 19
				 WHEN a.strType = 'Sale Basis' THEN 20
				 WHEN a.strType = 'Sale Unit' THEN 21
				 WHEN a.strType = 'Purchase Unit' THEN 22
				 WHEN a.strType = 'Net Unpriced Position' THEN 23
				 WHEN a.strType = '' THEN 24
				 WHEN a.strType = 'Basis Risk' THEN 25
				 WHEN a.strType = 'Price Risk' THEN 26
			END
		)
		,strBucketType =  a.strType
		,dblDPRRun1 = a.dblTotal
		,dblDPRRun2 = b.dblTotal
		,dblDifference =  b.dblTotal - a.dblTotal
	from #temp1 a
	inner join #temp2 b on b.strType = a.strType
) t



drop table  #temp1
drop table  #temp2

END
