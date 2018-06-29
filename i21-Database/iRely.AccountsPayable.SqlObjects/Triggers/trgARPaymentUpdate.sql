CREATE TRIGGER trgARPaymentUpdate
ON dbo.tblARPayment
INSTEAD OF UPDATE
AS
BEGIN
	--SELECT ysnPosted FROM inserted WHERE ysnPosted = 1
	DECLARE @ysnPosted AS VARCHAR(MAX) 
	DECLARE @ysnPostedNew as VARCHAR(MAX)
	SELECT @ysnPosted = ysnPosted FROM deleted WHERE intCurrentStatus <> 5
	SELECT @ysnPostedNew = ysnPosted FROM inserted
			
	IF(@ysnPosted = 1 and @ysnPostedNew = 0)
		RAISERROR('Cannot update posted payment',16,1)
	ELSE
		UPDATE p
		SET  p.intEntityCustomerId            = i.intEntityCustomerId           
			,p.intCurrencyId                  = i.intCurrencyId                 
			,p.dtmDatePaid                    = i.dtmDatePaid                   
			,p.intAccountId                   = i.intAccountId                  
			,p.intBankAccountId               = i.intBankAccountId              
			,p.intPaymentMethodId             = i.intPaymentMethodId            
			,p.intLocationId                  = i.intLocationId                 
			,p.dblAmountPaid                  = i.dblAmountPaid                 
			,p.dblBaseAmountPaid              = i.dblBaseAmountPaid             
			,p.dblUnappliedAmount             = i.dblUnappliedAmount            
			,p.dblBaseUnappliedAmount         = i.dblBaseUnappliedAmount        
			,p.dblOverpayment                 = i.dblOverpayment                
			,p.dblBaseOverpayment             = i.dblBaseOverpayment            
			,p.dblBalance                     = i.dblBalance                    
			,p.dblExchangeRate                = i.dblExchangeRate               
			,p.strReceivePaymentType          = i.strReceivePaymentType         
			,p.strRecordNumber                = i.strRecordNumber               
			,p.strPaymentInfo                 = i.strPaymentInfo                
			,p.strNotes                       = i.strNotes                      
			,p.ysnApplytoBudget               = i.ysnApplytoBudget              
			,p.ysnApplyOnAccount              = i.ysnApplyOnAccount             
			,p.ysnPosted                      = i.ysnPosted                     
			,p.ysnInvoicePrepayment           = i.ysnInvoicePrepayment          
			,p.ysnImportedFromOrigin          = i.ysnImportedFromOrigin         
			,p.ysnImportedAsPosted            = i.ysnImportedAsPosted           
			,p.intEntityId                    = i.intEntityId                   
			,p.intWriteOffAccountId           = i.intWriteOffAccountId          
			,p.intCurrencyExchangeRateTypeId  = i.intCurrencyExchangeRateTypeId 
			,p.strPaymentMethod               = i.strPaymentMethod              
			,p.intEntityCardInfoId            = i.intEntityCardInfoId           
			,p.ysnProcessCreditCard           = i.ysnProcessCreditCard          
			,p.ysnProcessedToNSF              = i.ysnProcessedToNSF             
			,p.dblTotalAR                     = i.dblTotalAR                    
			,p.strBatchId                     = i.strBatchId                    
			,p.dtmBatchDate                   = i.dtmBatchDate                  
			,p.intPostedById                  = i.intPostedById                 
			,p.intConcurrencyId               = i.intConcurrencyId   
		FROM tblARPayment p
		INNER JOIN inserted i
			ON i.intPaymentId = p.intPaymentId
END