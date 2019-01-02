CREATE VIEW [dbo].[vyuCFInvoiceGroupByVehicleOdometer]
AS
select 
 t1.strVehicleNumber
,t1.intAccountId
,t1.strUserId
,t1.strStatementType
,MIN(t1.dtmTransactionDate) as dtmMinDate
,ISNULL((select top 1 intOdometerAging 
	from tblCFInvoiceStagingTable as t5 
	--where strUserId = 'irelyadmin'
	where ISNULL(t5.strVehicleNumber,0) = ISNULL(t1.strVehicleNumber ,0)
	and MIN(t1.dtmTransactionDate) = t5.dtmTransactionDate
	and t5.intAccountId = t1.intAccountId
	order by t5.dtmTransactionDate desc),0) as intLastOdometer
from tblCFInvoiceStagingTable as t1 
--where strUserId = 'irelyadmin'
group by t1.strVehicleNumber , t1.intAccountId , t1.strUserId, t1.strStatementType