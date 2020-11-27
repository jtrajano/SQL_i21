CREATE PROCEDURE [dbo].[uspCFInvoiceReportValidation](
	 @UserId NVARCHAR(MAX),
	 @StatementType NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	
	INSERT INTO tblCFInvoiceReportTotalValidation
	(
		 intTransactionId			    
		,intInvoiceId					
		,strTransactionId				
		,strTransactionType				
		,dblQuantity					
		,dblCFTotal					
		,dblARTotal						
		,dblDiff						
		,dtmTransactionDate				
		,dtmInvoiceDate					
		,dtmPostedDate					
		,strUserId		
		,intEntityCustomerId
		,strCustomerNumber
		,strCustomerName
		,strErrorType				
		,strStatementType
	)
	
select 
	     T.intTransactionId			    
		,T.intInvoiceId					
		,T.strTransactionId				
		,T.strTransactionType				
		,T.dblQuantity					
		,dblCFTTotal = (case when T.ysnExpensed=1 then 0 else T.dblCalculatedTotalPrice end)
		,dblARTotal = (case when I.strTransactionType='Credit Memo' then I.dblInvoiceTotal  * -1 else I.dblInvoiceTotal end )			
		,dblDiff = (case when T.ysnExpensed=1 then 0 else T.dblCalculatedTotalPrice end  -  case when I.strTransactionType='Credit Memo' then I.dblInvoiceTotal  * -1 else I.dblInvoiceTotal end)					
		,T.dtmTransactionDate				
		,T.dtmInvoiceDate					
		,T.dtmPostedDate					
		,@UserId		
		,vyuCFAccountCustomer.intCustomerId
		,vyuCFAccountCustomer.strCustomerNumber
		,vyuCFAccountCustomer.strName
		,'Tran <> AR'
		,@StatementType
	from tblCFTransaction T
	inner join tblARInvoice I on I.intTransactionId=T.intTransactionId
	inner join vyuCFAccountCustomer on T.intCustomerId = vyuCFAccountCustomer.intCustomerId
	where 
		case when T.ysnExpensed=1 
				then 0 
				else T.dblCalculatedTotalPrice 
			end <>  
		case when I.strTransactionType='Credit Memo' 
				then I.dblInvoiceTotal  * -1 
				else I.dblInvoiceTotal 
		end
	and isnull(T.ysnInvoiced,0)=0 
	AND T.intTransactionId IN (SELECT intTransactionId FROM tblCFInvoiceReportTempTable where LOWER(strUserId) = LOWER(@UserId) AND LOWER(strStatementType) = LOWER(@StatementType) )
	order by abs(T.dblCalculatedTotalPrice - case when I.strTransactionType='Credit Memo' then I.dblInvoiceTotal  * -1 else I.dblInvoiceTotal end)

END
