

				CREATE VIEW [dbo].[vyuCFInvoiceGroupByDeptOdometer]
				AS
				select 
					 t1.strDepartment
					,t1.intAccountId
					,t1.strUserId
					,t1.strStatementType
					,MIN(t1.dtmTransactionDate) as dtmMinDate

					,ISNULL((select top 1 intOdometerAging 
					from tblCFInvoiceStagingTable as t5 
					--where strUserId = 'irelyadmin'
					where t5.strDepartment = t1.strDepartment 
					and min(t1.dtmTransactionDate) = t5.dtmTransactionDate
					order by t5.dtmTransactionDate desc),0) as intLastOdometer


				from tblCFInvoiceStagingTable as t1 
				group by t1.strDepartment , t1.intAccountId, t1.strUserId, t1.strStatementType