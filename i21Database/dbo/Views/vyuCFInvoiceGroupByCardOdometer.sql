﻿
CREATE VIEW [dbo].[vyuCFInvoiceGroupByCardOdometer]
				AS
				select 
					 t1.intCardId
					,t1.intAccountId
					,t1.strUserId
					,MIN(t1.dtmTransactionDate) as dtmMinDate
					,ISNULL((select top 1 intOdometerAging 
					from tblCFInvoiceStagingTable as t5 
					--where strUserId = 'irelyadmin'
					where t5.intCardId = t1.intCardId 
					and min(t1.dtmTransactionDate) = t5.dtmTransactionDate
					and t5.intAccountId = t1.intAccountId
					order by t5.dtmTransactionDate desc),0) as intLastOdometer
				from tblCFInvoiceStagingTable as t1 
				group by t1.intCardId , t1.intAccountId , t1.strUserId