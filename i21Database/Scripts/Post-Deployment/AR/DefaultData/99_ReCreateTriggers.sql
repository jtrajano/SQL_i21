﻿PRINT '********************** BEGIN - ReCreate AR Triggers **********************'
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblARPaymentDelete]'))
DROP TRIGGER [dbo].[trg_tblARPaymentDelete]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblARPaymentUpdate]'))
DROP TRIGGER [dbo].[trg_tblARPaymentUpdate]
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trg_tblARPaymentDetailUpdate]'))
DROP TRIGGER [dbo].[trg_tblARPaymentDetailUpdate]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER trg_tblARPaymentDelete
ON dbo.tblARPayment
INSTEAD OF DELETE 
AS
BEGIN
	--Apply changes to i21Database\Scripts\Post-Deployment\AR\DefaultData\99_ReCreateTriggers.sql
	DECLARE @strRecordNumber 	NVARCHAR(50) = NULL
		  , @strError 			NVARCHAR(500) = NULL
		  , @intPaymentId 		INT = NULL
		  , @ysnPosted			BIT = 0		  

	SELECT @intPaymentId 	= intPaymentId
		 , @strRecordNumber = strRecordNumber 
		 , @ysnPosted		= ysnPosted 
	FROM DELETED 

	IF EXISTS (SELECT TOP 1 NULL FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strCode = 'AR' AND intTransactionId = @intPaymentId AND strTransactionId = @strRecordNumber)
		SET @strError = 'You cannot delete payment ' + @strRecordNumber + '. It has existing posted GL entries.';

	IF @ysnPosted = 1
		SET @strError = 'You cannot delete posted payment (' + @strRecordNumber + ')';

	IF ISNULL(@strError, '') <> ''
		RAISERROR(@strError, 16, 1);
	ELSE
		DELETE A
		FROM tblARPayment A
		INNER JOIN DELETED B ON A.intPaymentId = B.intPaymentId
END
GO


CREATE TRIGGER trg_tblARPaymentUpdate
ON dbo.tblARPayment
INSTEAD OF UPDATE
AS
BEGIN
	--Apply changes to i21Database\Scripts\Post-Deployment\AR\DefaultData\99_ReCreateTriggers.sql

	DECLARE @ysnPosted AS VARCHAR(MAX) 
	DECLARE @ysnPostedNew as VARCHAR(MAX)
	SELECT @ysnPosted = ysnPosted FROM deleted
	SELECT @ysnPostedNew = ysnPosted FROM inserted
	DECLARE @currentStatus AS VARCHAR(MAX)
	SELECT @currentStatus = ISNULL(intCurrentStatus, 0) FROM inserted

	SET @ysnPosted = ISNULL(@ysnPosted,0)
	SET @ysnPostedNew = ISNULL(@ysnPostedNew,0)
	IF((@ysnPosted = 1 and @ysnPostedNew = 0 and @currentStatus = 5) OR (@ysnPosted = 0 and @ysnPostedNew = 0) OR (@ysnPosted = 0 and @ysnPostedNew = 1) OR UPDATE(intCurrentStatus) OR @currentStatus = 5)
	BEGIN
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
			,p.intCurrentStatus				  = i.intCurrentStatus
			,p.intPeriodId                    = i.intPeriodId
			,p.dtmScheduledPayment			  = i.dtmScheduledPayment   
			,p.strCreditCardStatus			  = i.strCreditCardStatus
			,p.strCreditCardNote			  = i.strCreditCardNote
			,p.strInvoices					  = i.strInvoices
		FROM tblARPayment p
		INNER JOIN inserted i
			ON i.intPaymentId = p.intPaymentId
	END
	ELSE
		RAISERROR('Cannot update posted payment',16,1)		
END
GO

CREATE TRIGGER trg_tblARPaymentDetailUpdate
ON dbo.tblARPaymentDetail
INSTEAD OF UPDATE
AS
BEGIN
	--Apply changes to i21Database\Scripts\Post-Deployment\AR\DefaultData\99_ReCreateTriggers.sql

	--SELECT ysnPosted FROM inserted WHERE ysnPosted = 1
	DECLARE @ysnPosted AS VARCHAR(MAX) 
	DECLARE @ysnPostedNew as VARCHAR(MAX)
	SELECT @ysnPosted = P.ysnPosted FROM tblARPayment P inner join deleted d on d.intPaymentId = P.intPaymentId AND ISNULL(P.intCurrentStatus,0) <> 5
	SELECT @ysnPostedNew = P.ysnPosted FROM tblARPayment P inner join deleted d on d.intPaymentId = P.intPaymentId

	SET @ysnPosted = ISNULL(@ysnPosted,0)
	SET @ysnPostedNew = ISNULL(@ysnPostedNew,0)		
	IF(@ysnPosted = 1 and @ysnPostedNew != 0)
		RAISERROR('Cannot update detail of posted payment',16,1)
	ELSE
		UPDATE PD
		SET  PD.intInvoiceId                   =  i.intInvoiceId                 
			,PD.intBillId                      =  i.intBillId                    
			,PD.strTransactionNumber           =  i.strTransactionNumber         
			,PD.intTermId                      =  i.intTermId                    
			,PD.intAccountId                   =  i.intAccountId         
			,PD.intWriteOffAccountId		   =  i.intWriteOffAccountId
			,PD.dblInvoiceTotal                =  i.dblInvoiceTotal              
			,PD.dblBaseInvoiceTotal            =  i.dblBaseInvoiceTotal          
			,PD.dblDiscount                    =  i.dblDiscount                  
			,PD.dblBaseDiscount                =  i.dblBaseDiscount              
			,PD.dblDiscountAvailable           =  i.dblDiscountAvailable         
			,PD.dblBaseDiscountAvailable       =  i.dblBaseDiscountAvailable     
			,PD.dblWriteOffAmount			   =  i.dblWriteOffAmount
			,PD.dblBaseWriteOffAmount		   =  i.dblBaseWriteOffAmount
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
			ON i.intPaymentDetailId = PD.intPaymentDetailId
END
GO

PRINT ' ********************** END - ReCreate AR Triggers **********************'
GO