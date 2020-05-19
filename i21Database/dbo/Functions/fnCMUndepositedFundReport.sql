-- =============================================
-- Author:		Jeffrey Trajano
-- Create date: 13-05-2020
-- Description:	Triaggered by uspCMUndepositedFundReport
-- =============================================
CREATE FUNCTION fnCMUndepositedFundReport
(	
	@asOfDate DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
select
@asOfDate 'As Of',
a.dtmDate as 'Payment Date',
a.strName 'Name',
a.strSourceTransactionId 'Record No',
a.strPaymentMethod 'Payment Method',
a.strSourceSystem 'Payment Source',
d.strEODNumber 'EOD Number',
d.strEODDrawer 'EOD Drawer',
d.ysnEODComplete 'EOD Complete',
a.strCardType 'Card Type',
a.strLocationName 'Location',
a.strUserName 'Entered By',
c.strTransactionId 'Bank Transaction',
ysnPosted 'Bank Transaction Posted',
c.dtmDate 'Bank Transaction Date',
a.dblAmount 'Amount'
from vyuCMUndepositedFund a
inner join tblCMUndepositedFund d on d.intUndepositedFundId = a.intUndepositedFundId
left outer join tblCMBankTransactionDetail b on a.intUndepositedFundId = b.intUndepositedFundId
left outer join tblCMBankTransaction c on c.intTransactionId = b.intTransactionId
where a.dtmDate <= @asOfDate --- Sales Payment Date
and c.dtmDate is Null

union

---All undeposited Funds that have been imported into bank transation BUT NOT POSTED
select
@asOfDate 'As Of',
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
from vyuCMUndepositedFund a
inner join tblCMUndepositedFund d on d.intUndepositedFundId = a.intUndepositedFundId
left outer join tblCMBankTransactionDetail b on a.intUndepositedFundId = b.intUndepositedFundId
left outer join tblCMBankTransaction c on c.intTransactionId = b.intTransactionId
where a.dtmDate <= @asOfDate
--- Sales Payment Date
and ysnPosted = 0


union

---All undeposited funds that have been imported into bank transactions AND POSTED BUT AFTER as of date
select
@asOfDate 'As Of',
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
(case when c.strTransactionId like 'BWD%' and c.dtmDate >= DATEADD( DAY, 1, @asOfDate)
--DATEADD(DAY,1, a.dtmDate) 
then a.dblAmount*0
else a.dblAmount end) as total
from vyuCMUndepositedFund a
inner join tblCMUndepositedFund d on d.intUndepositedFundId = a.intUndepositedFundId
left outer join tblCMBankTransactionDetail b on a.intUndepositedFundId = b.intUndepositedFundId
left outer join tblCMBankTransaction c on c.intTransactionId = b.intTransactionId
where a.dtmDate <= @asOfDate ---Sales Payment Date
and ysnPosted = 1 --- bank dep
and c.dtmDate >=   DATEADD( DAY, 1, @asOfDate) ---bank Post Date
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
c.dtmDate >= DATEADD( DAY, 1, @asOfDate)
then a.dblAmount*0
else a.dblAmount end) <>0
)
GO
