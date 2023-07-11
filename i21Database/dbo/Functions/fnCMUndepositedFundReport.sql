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
	A.dtmDate,
	A.strName,
	C.strSourceTransactionId,
	A.strPaymentMethod,
	A.strSourceSystem,
	C.strEODNumber,
	C.strEODDrawer ,
	C.ysnEODComplete ,
	A.strCardType,
	A.strLocationName strLocationName,
	A.strUserName,
	B.strTransactionId,
	ysnPosted,
	B.dtmDate dtmCMDate,
	A.dblAmount,
	A.strCompanySegment,
	A.strAccountId
	from vyuCMUndepositedFund  A join 
	tblCMUndepositedFund C on C.intUndepositedFundId = A.intUndepositedFundId
	left join
	(
		select intUndepositedFundId, BT.dtmDate, strTransactionId, ysnPosted from tblCMBankTransactionDetail BTD 
		join tblCMBankTransaction BT on BT.intTransactionId = BTD.intTransactionId 
	) B on
	A.intUndepositedFundId = B.intUndepositedFundId 
	where 
	B.dtmDate BETWEEN @dtmDateFrom AND @dtmDateTo AND ysnPosted =0 --UNPOSTED BANK DEPOSIT
	OR B.intUndepositedFundId is null -- NOT PICKED UP BY BANK DEPOSIT
)
select ROW_NUMBER() OVER( ORDER BY dtmDate) rowId, * from mainTable
where ISNULL(strPaymentMethod,'') <> 'CF Invoice'
)
