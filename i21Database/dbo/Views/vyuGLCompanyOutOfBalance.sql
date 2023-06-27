
CREATE VIEW vyuGLCompanyOutOfBalance
AS
with cte as(
	select 
		min(A.intTransactionId)intTransactionId,
		min(A.strModuleName) strModuleName,
		min(A.strTransactionForm)strTransactionForm,
		C.strCode strCompanySegment, strTransactionId, 
		sum(isnull(dblDebit,0) - isnull(dblCredit,0))dblTotal
	from tblGLDetail A 
	join tblGLAccount B on A.intAccountId = B.intAccountId
	join tblGLAccountSegment C on C.intAccountSegmentId = B.intCompanySegmentId
	join tblGLAccountStructure S on C.intAccountStructureId = C.intAccountStructureId
	where ysnIsUnposted = 0  and intStructureType = 6
	group by C.strCode, strTransactionId having sum(isnull(dblDebit,0) - isnull(dblCredit,0)) <> 0
)
select 
intTransactionId,
strModuleName,
strTransactionForm,
strTransactionId, strCompanySegment, dblTotal 
from cte