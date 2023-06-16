
CREATE VIEW vyuGLCompanyOutOfBalance
AS
with cte as(
	select C.strCode, strTransactionId, sum(isnull(dblDebit,0) - isnull(dblCredit,0))dblTotal from tblGLDetail A 
	join tblGLAccount B on A.intAccountId = B.intAccountId
	join tblGLAccountSegment C on C.intAccountSegmentId = B.intCompanySegmentId
	join tblGLAccountStructure S on C.intAccountStructureId = C.intAccountStructureId
	where ysnIsUnposted = 0  and intStructureType = 6
	group by C.strCode, strTransactionId having sum(isnull(dblDebit,0) - isnull(dblCredit,0)) <> 0
),
cteOrder as(
	select *,
	row_number() over(partition by strTransactionId order by strCode) rowId
	from cte 
),
cteFirst as(
	select strTransactionId, a.dblTotal from cteOrder a 
	where rowId = 1
),
cteSecond as(
	select strTransactionId, a.dblTotal from cteOrder a 
	where rowId = 2
),
cteUnbalanced as(
	select a.strTransactionId from 
	cteFirst a left join cteSecond b on a.strTransactionId = b.strTransactionId
	where (a.dblTotal + b.dblTotal) <> 0
)
select 
ROW_NUMBER() OVER(ORDER BY B.strTransactionId, A.strCode) rowId,
B.strTransactionId, A.strCode, dblTotal from cte A join cteUnbalanced B on A.strTransactionId = B.strTransactionId


