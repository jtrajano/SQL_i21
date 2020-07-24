CREATE PROCEDURE uspRKDPRCompareSummary
	@intDPRRun1 INT 
	,@intDPRRun2 INT
AS

BEGIN

select 
 strType
 ,dblTotal = sum(isnull(dblTotal,0)) 
 into #temp1
from tblRKDPRRunLogDetail LD
inner join tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
where intRunNumber = @intDPRRun1
group by strType

select 
 strType
 ,dblTotal = sum(isnull(dblTotal,0)) 
 into #temp2
from tblRKDPRRunLogDetail LD
inner join tblRKDPRRunLog L ON L.intDPRRunLogId = LD.intDPRRunLogId
where intRunNumber = @intDPRRun2
group by strType


SELECT
	intRowNumber  = CONVERT(INT, row_number() OVER(ORDER BY intOrderId , strBucketType))
	,*
FROM (
	select
		intOrderId = (
			CASE WHEN isnull(a.strType,b.strType) = 'Purchase Priced' THEN 1
				 WHEN isnull(a.strType,b.strType) = 'Sale Priced' THEN 2
				 WHEN isnull(a.strType,b.strType) = 'Purchase HTA' THEN 3
				 WHEN isnull(a.strType,b.strType) = 'Sale HTA' THEN 4
				 WHEN isnull(a.strType,b.strType) = 'Purchase Basis Deliveries' THEN 5
				 WHEN isnull(a.strType,b.strType) = 'Sales Basis Deliveries' THEN 6
				 WHEN isnull(a.strType,b.strType) = 'Delayed Pricing' THEN 7
				 WHEN isnull(a.strType,b.strType) = 'Company Titled' THEN 8
				 WHEN isnull(a.strType,b.strType) = 'Net Physical Position' THEN 9
				 WHEN isnull(a.strType,b.strType) = '' THEN 10
				 WHEN isnull(a.strType,b.strType) = '' THEN 11
				 WHEN isnull(a.strType,b.strType) = 'Net Futures' THEN 12
				 WHEN isnull(a.strType,b.strType) = '' THEN 13
				 WHEN isnull(a.strType,b.strType) = 'Crush' THEN 14
				 WHEN isnull(a.strType,b.strType) = 'Delta Adjusted Options' THEN 15
				 WHEN isnull(a.strType,b.strType) = 'Net Hedge' THEN 16
				 WHEN isnull(a.strType,b.strType) = 'Purchase DP (Priced Later)' THEN 17
				 WHEN isnull(a.strType,b.strType) = 'Sale DP (Priced Later)' THEN 18
				 WHEN isnull(a.strType,b.strType) = 'Purchase Basis' THEN 19
				 WHEN isnull(a.strType,b.strType) = 'Sale Basis' THEN 20
				 WHEN isnull(a.strType,b.strType) = 'Sale Unit' THEN 21
				 WHEN isnull(a.strType,b.strType) = 'Purchase Unit' THEN 22
				 WHEN isnull(a.strType,b.strType) = 'Net Unpriced Position' THEN 23
				 WHEN isnull(a.strType,b.strType) = '' THEN 24
				 WHEN isnull(a.strType,b.strType) = 'Basis Risk' THEN 25
				 WHEN isnull(a.strType,b.strType) = 'Price Risk' THEN 26
			END
		)
		,strBucketType =  isnull(a.strType,b.strType)
		,dblDPRRun1 = isnull(a.dblTotal,0)
		,dblDPRRun2 = isnull(b.dblTotal,0)
		,dblDifference =  isnull(b.dblTotal,0) - isnull(a.dblTotal,0)
	from #temp1 a
	right join #temp2 b on b.strType = a.strType
) t



drop table  #temp1
drop table  #temp2

END
