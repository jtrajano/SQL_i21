-- =============================================
-- Author:		Jeffrey Trajano
-- Create date: 13-05-2020
-- Description:	Triaggered by uspCMUndepositedFundReport
-- =============================================
CREATE FUNCTION [dbo].[fnCMUndepositedFundReport]
(	
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
	@dtmCMDate DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
with mainTable as(	
select
a.dtmDate,
a.strName,
a.strSourceTransactionId,
a.strPaymentMethod,
a.strSourceSystem,
d.strEODNumber,
d.strEODDrawer ,
d.ysnEODComplete ,
a.strCardType,
a.strLocationName strLocationName,
a.strUserName,
c.strTransactionId,
ysnPosted,
c.dtmDate dtmCMDate,
a.dblAmount
from vyuCMUndepositedFund a
inner join tblCMUndepositedFund d on d.intUndepositedFundId = a.intUndepositedFundId
left outer join tblCMBankTransactionDetail b on a.intUndepositedFundId = b.intUndepositedFundId
left outer join tblCMBankTransaction c on c.intTransactionId = b.intTransactionId
where a.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo --- Sales Payment Date
and c.dtmDate is Null

union

--All undeposited Funds that have been imported into bank transation BUT NOT POSTED
select
a.dtmDate,
a.strName,
a.strSourceTransactionId,
a.strPaymentMethod,
a.strSourceSystem,
d.strEODNumber,
d.strEODDrawer ,
d.ysnEODComplete ,
a.strCardType,
a.strLocationName strLocationName,
a.strUserName,
c.strTransactionId,
ysnPosted,
c.dtmDate dtmCMDate,
a.dblAmount
from vyuCMUndepositedFund a
inner join tblCMUndepositedFund d on d.intUndepositedFundId = a.intUndepositedFundId
left outer join tblCMBankTransactionDetail b on a.intUndepositedFundId = b.intUndepositedFundId
left outer join tblCMBankTransaction c on c.intTransactionId = b.intTransactionId
where a.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo
--- Sales Payment Date
and ysnPosted = 0


union

---All undeposited funds that have been imported into bank transactions AND POSTED BUT AFTER as of date
select
a.dtmDate,
a.strName,
a.strSourceTransactionId,
a.strPaymentMethod,
a.strSourceSystem,
d.strEODNumber,
d.strEODDrawer ,
d.ysnEODComplete ,
a.strCardType,
a.strLocationName strLocationName,
a.strUserName,
c.strTransactionId,
ysnPosted,
c.dtmDate dtmCMDate,
(case when c.strTransactionId like 'BWD%' and c.dtmDate >= @dtmCMDate -- DATEADD( SECOND, 1, @dtmDateTo)
--DATEADD(DAY,1, a.dtmDate) 
then a.dblAmount*0
else a.dblAmount end) as dblAmount
from vyuCMUndepositedFund a
inner join tblCMUndepositedFund d on d.intUndepositedFundId = a.intUndepositedFundId
left outer join tblCMBankTransactionDetail b on a.intUndepositedFundId = b.intUndepositedFundId
left outer join tblCMBankTransaction c on c.intTransactionId = b.intTransactionId
where a.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo ---Sales Payment Date
and ysnPosted = 1 --- bank dep
and c.dtmDate >= @dtmCMDate --  DATEADD( SECOND, 1, @dtmDateTo)---bank Post Date
--DATEADD(DAY,1, a.dtmDate)
group by
a.dtmDate,
a.strName,
a.strSourceTransactionId,
a.strPaymentMethod,
a.strSourceSystem,
d.strEODNumber,
d.strEODDrawer,
d.ysnEODComplete,
a.strCardType,
a.strLocationName,
a.strUserName,
c.strTransactionId,
ysnPosted,
c.dtmDate,
a.dblAmount
having (case when c.strTransactionId like 'BWD%' or c.strTransactionId like 'BTRN%' and
c.dtmDate >= @dtmCMDate -- DATEADD( SECOND, 1, @dtmDateTo)
then a.dblAmount*0
else a.dblAmount end) <>0
)

select ROW_NUMBER() OVER( ORDER BY dtmDate) rowId, * from mainTable
)
