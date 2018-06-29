CREATE TRIGGER trgARPaymentDetailUpdate
ON dbo.tblARPaymentDetail
INSTEAD OF UPDATE
AS
BEGIN
	--SELECT ysnPosted FROM inserted WHERE ysnPosted = 1
	DECLARE @ysnPosted AS VARCHAR(MAX) 
	DECLARE @ysnPostedNew as VARCHAR(MAX)
	SELECT @ysnPosted = P.ysnPosted FROM tblARPayment P inner join deleted d on d.intPaymentId = P.intPaymentId AND P.intCurrentStatus <> 5
	SELECT @ysnPostedNew = P.ysnPosted FROM tblARPayment P inner join deleted d on d.intPaymentId = P.intPaymentId
		
	IF(@ysnPosted = 1 and @ysnPostedNew != 0)
		RAISERROR('Cannot update detail of posted payment',16,1)
	ELSE
		UPDATE PD
		SET  PD.intInvoiceId                   =  i.intInvoiceId                 
			,PD.intBillId                      =  i.intBillId                    
			,PD.strTransactionNumber           =  i.strTransactionNumber         
			,PD.intTermId                      =  i.intTermId                    
			,PD.intAccountId                   =  i.intAccountId                 
			,PD.dblInvoiceTotal                =  i.dblInvoiceTotal              
			,PD.dblBaseInvoiceTotal            =  i.dblBaseInvoiceTotal          
			,PD.dblDiscount                    =  i.dblDiscount                  
			,PD.dblBaseDiscount                =  i.dblBaseDiscount              
			,PD.dblDiscountAvailable           =  i.dblDiscountAvailable         
			,PD.dblBaseDiscountAvailable       =  i.dblBaseDiscountAvailable     
			,PD.dblInterest                    =  i.dblInterest                  
			,PD.dblBaseInterest                =  i.dblBaseInterest              
			,PD.dblAmountDue                   =  i.dblAmountDue                 
			,PD.dblBaseAmountDue               =  i.dblBaseAmountDue             
			,PD.dblPayment                     =  i.dblPayment                   
			,PD.dblBasePayment                 =  i.dblBasePayment               
			,PD.strInvoiceReportNumber         =  i.strInvoiceReportNumber       
			,PD.intCurrencyExchangeRateTypeId  =  i.intCurrencyExchangeRateTypeId
			,PD.intCurrencyExchangeRateId      =  i.intCurrencyExchangeRateId    
			,PD.dblCurrencyExchangeRate        =  i.dblCurrencyExchangeRate      
			,PD.dtmDiscountDate                =  i.dtmDiscountDate              
			,PD.intConcurrencyId               =  i.intConcurrencyId             
		FROM tblARPaymentDetail PD
		INNER JOIN inserted i
			ON i.intPaymentId = PD.intPaymentId
END