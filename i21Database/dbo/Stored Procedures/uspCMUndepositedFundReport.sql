CREATE PROCEDURE uspCMUndepositedFundReport
    (@xmlParam NVARCHAR(MAX)= '')
AS

DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[datatype] NVARCHAR(50)
)
DECLARE @xmlDocumentId AS INT;

EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, [condition] nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

DECLARE @asOfDate DATETIME
IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@asOfDate =  [from] 
	FROM @temp_xml_table WHERE [fieldname] = 'As Of' AND condition ='Equal To'
END
select @asOfDate = isnull(@asOfDate,'01/01/2099')

select * from (
select
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
) a




