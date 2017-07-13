CREATE VIEW [dbo].[vyuCFInvoiceGroupByCardOdometer]
				AS
				select 
					t1.intCardId
					,t1.intAccountId
					,MIN(t1.dtmTransactionDate) as dtmMinDate
					,ISNULL((select top 1 intOdometer 
					from tblCFTransaction as t5 
					inner join tblCFCard as crd 
					on crd.intCardId = t5.intCardId
					where 
					t5.ysnPosted = 1
					and t5.intCardId = t1.intCardId 
					and min(t1.dtmTransactionDate) > t5.dtmTransactionDate
					and crd.intAccountId = t1.intAccountId
					order by t5.dtmTransactionDate desc),0) as intLastOdometer
				from tblCFInvoiceStagingTable as t1 
				group by t1.intCardId , t1.intAccountId