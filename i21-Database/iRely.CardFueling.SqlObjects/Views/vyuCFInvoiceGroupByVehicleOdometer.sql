CREATE VIEW [dbo].[vyuCFInvoiceGroupByVehicleOdometer]
				AS
				select 
					 t1.strVehicleNumber
					,t1.intAccountId
					,MIN(t1.dtmTransactionDate) as dtmMinDate
					,ISNULL((select top 1 intOdometer 
					from tblCFTransaction as t5 
					inner join tblCFVehicle as vhl 
					on vhl.intVehicleId = t5.intVehicleId
					where 
					t5.ysnPosted = 1
					and vhl.strVehicleNumber = t1.strVehicleNumber 
					and min(t1.dtmTransactionDate) > t5.dtmTransactionDate
					and vhl.intAccountId = t1.intAccountId
					order by t5.dtmTransactionDate desc),0) as intLastOdometer
				from tblCFInvoiceStagingTable as t1 
				group by t1.strVehicleNumber , t1.intAccountId