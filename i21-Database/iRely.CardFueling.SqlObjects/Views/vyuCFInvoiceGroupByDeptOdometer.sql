
				CREATE VIEW [dbo].[vyuCFInvoiceGroupByDeptOdometer]
				AS
				select 
					 t1.strDepartment
					,t1.intAccountId
					,MIN(t1.dtmTransactionDate) as dtmMinDate
					,ISNULL((select top 1 intOdometer 
					from tblCFTransaction as t5 
					inner join tblCFCard as c
					on t5.intCardId = c.intCardId
					inner join tblCFDepartment as d
					on c.intDepartmentId = d.intDepartmentId
					where 
					t5.ysnPosted = 1
					and d.strDepartment = t1.strDepartment 
					and min(t1.dtmTransactionDate) > t5.dtmTransactionDate
					order by t5.dtmTransactionDate desc),0) as intLastOdometer
				from tblCFInvoiceStagingTable as t1 
				group by t1.strDepartment , t1.intAccountId