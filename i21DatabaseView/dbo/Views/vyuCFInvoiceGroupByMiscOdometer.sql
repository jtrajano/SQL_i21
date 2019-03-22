

CREATE VIEW [dbo].[vyuCFInvoiceGroupByMiscOdometer]
				AS
				select 
					 t1.strMiscellaneous
					,t1.intAccountId
					,t1.strUserId
					,MIN(t1.dtmTransactionDate) as dtmMinDate
					,t1.strStatementType

					--,ISNULL((select top 1 intOdometer 
					--from tblCFTransaction as t5 
					--where 
					--t5.ysnPosted = 1
					--and strMiscellaneous = t1.strMiscellaneous 
					--and min(t1.dtmTransactionDate) > t5.dtmTransactionDate
					--order by t5.dtmTransactionDate desc),0) as intLastOdometer

					,ISNULL((select top 1 intOdometerAging 
					from tblCFInvoiceStagingTable as t5 
					--where strUserId = 'irelyadmin'
					where strMiscellaneous = t1.strMiscellaneous 
					and min(t1.dtmTransactionDate) = t5.dtmTransactionDate
					order by t5.dtmTransactionDate desc),0) as intLastOdometer

				from tblCFInvoiceStagingTable as t1 
				group by t1.strMiscellaneous , t1.intAccountId, t1.strUserId, t1.strStatementType