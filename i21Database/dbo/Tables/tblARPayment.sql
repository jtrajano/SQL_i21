﻿CREATE TABLE [dbo].[tblARPayment] (
    [intPaymentId]			INT             IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]   INT             NOT NULL,
    [intCurrencyId]			INT             NOT NULL,
    [dtmDatePaid]			DATETIME        NULL,
    [dtmAccountingPeriod]   DATETIME        NULL,
	[intPeriodId]			INT				NULL,
    [intAccountId]			INT             NULL,
	[intBankAccountId]		INT             NULL,
    [intPaymentMethodId]	INT             NOT NULL,
    [intLocationId]			INT             NULL,
    [dblAmountPaid]			NUMERIC (18, 6) NULL,
	[dblBaseAmountPaid]		NUMERIC (18, 6) NULL,
    [dblUnappliedAmount]	NUMERIC (18, 6) NULL,
	[dblBaseUnappliedAmount]	NUMERIC (18, 6) NULL,
    [dblOverpayment]		NUMERIC (18, 6) NULL,
	[dblBaseOverpayment]	NUMERIC (18, 6) NULL,
    [dblBalance]			NUMERIC (18, 6) NULL,
	[dblExchangeRate]		NUMERIC (18, 6) NULL,
	[strReceivePaymentType]	NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strRecordNumber]		NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [strPaymentInfo]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strNotes]				NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
	[ysnApplytoBudget]		BIT				NULL,
	[ysnApplyOnAccount]		BIT				CONSTRAINT [DF_tblARPayment_ysnApplyOnAccount] DEFAULT ((0)) NULL,
    [ysnPosted]				BIT             CONSTRAINT [DF_tblARPayment_ysnPosted] DEFAULT ((0)) NOT NULL,
	[ysnInvoicePrepayment]	BIT             CONSTRAINT [DF_tblARPayment_ysnInvoicePrepayment] DEFAULT ((0)) NOT NULL,
	[ysnImportedFromOrigin]	BIT				CONSTRAINT [DF_tblARPayment_ysnImportedFromOrigin] DEFAULT ((0)) NOT NULL,
	[ysnImportedAsPosted]	BIT				CONSTRAINT [DF_tblARPayment_ysnImportedAsPosted] DEFAULT ((0)) NOT NULL,		
	[intEntityId]			INT				NULL DEFAULT ((0)),
	[intWriteOffAccountId]	INT				NULL,
	[intCurrencyExchangeRateTypeId]	INT		NULL,
	[strPaymentMethod]		NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[intEntityCardInfoId]	INT				NULL,
	[ysnProcessCreditCard]	BIT				CONSTRAINT [DF_tblARPayment_ysnProcessCreditCard] DEFAULT ((0)) NULL,
	[ysnProcessedToNSF]		BIT				CONSTRAINT [DF_tblARPayment_ysnProcessedToNSF] DEFAULT ((0)) NULL,
	[dblTotalAR]			NUMERIC (18, 6) NULL,
	[strBatchId]			NVARCHAR (20)	COLLATE Latin1_General_CI_AS NULL,	
	[dtmBatchDate]			DATETIME		NULL,
	[intPostedById]			INT				NULL,
	[intCurrentStatus]		INT				NULL,
	[ysnShowAPTransaction]	BIT				CONSTRAINT [DF_tblARPayment_ysnShowAPTransaction] DEFAULT ((0)) NULL,
    [intConcurrencyId]		INT             CONSTRAINT [DF_tblARPayment_intConcurrencyId] DEFAULT ((0)) NOT NULL,    
    CONSTRAINT [PK_tblARPayment_intPaymentId] PRIMARY KEY CLUSTERED ([intPaymentId] ASC),
    CONSTRAINT [FK_tblARPayment_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblARPayment_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARPayment_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
	CONSTRAINT [FK_tblARPayment_tblEMEntityCardInformation_intEntityCardInfoId] FOREIGN KEY ([intEntityCardInfoId]) REFERENCES [dbo].[tblEMEntityCardInformation] ([intEntityCardInfoId]),
	CONSTRAINT [FK_tblARPayment_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId])
);
--INDEXES
GO
CREATE NONCLUSTERED INDEX [NC_Index_tblARPayment]
	ON [dbo].[tblARPayment]([intEntityCustomerId], [ysnPosted], [ysnProcessedToNSF]) 
INCLUDE ([dtmDatePaid], [dblAmountPaid], [strRecordNumber], [ysnInvoicePrepayment]);
GO
CREATE NONCLUSTERED INDEX [IDX_tblARPayment_strRecordNumber] 
	ON [dbo].[tblARPayment] ([strRecordNumber])
	
--TRIGGERS INSERT
GO
CREATE TRIGGER trgReceivePaymentRecordNumber
ON tblARPayment
AFTER INSERT
AS

DECLARE @inserted TABLE(intPaymentId INT, intCompanyLocationId INT, strRecordNumber NVARCHAR(25) COLLATE Latin1_General_CI_AS)
DECLARE @count INT = 0
DECLARE @intPaymentId INT
DECLARE @intCompanyLocationId INT
DECLARE @PaymentId NVARCHAR(50)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intPaymentId, intLocationId, strRecordNumber FROM INSERTED ORDER BY intPaymentId

WHILE((SELECT TOP 1 1 FROM @inserted WHERE RTRIM(LTRIM(ISNULL(strRecordNumber,''))) = '') IS NOT NULL)
BEGIN	
	SELECT TOP 1 @intPaymentId = intPaymentId, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	EXEC uspSMGetStartingNumber 17, @PaymentId OUT, @intCompanyLocationId
	
	IF(@PaymentId IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARPayment WHERE strRecordNumber = @PaymentId)
			BEGIN
				SET @PaymentId = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strRecordNumber, 5, 10))) FROM tblARPayment
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 17
				EXEC uspSMGetStartingNumber 17, @PaymentId OUT, @intCompanyLocationId		
			END
		
		UPDATE tblARPayment
			SET tblARPayment.strRecordNumber = @PaymentId
		FROM tblARPayment A
		WHERE A.intPaymentId = @intPaymentId
	END

	DELETE FROM @inserted
	WHERE intPaymentId = @intPaymentId

END
GO

--TRIGGERS BEFORE DELETE
CREATE TRIGGER trg_tblARPaymentDelete
ON dbo.tblARPayment
INSTEAD OF DELETE 
AS
BEGIN
	--Apply changes to i21Database\Scripts\Post-Deployment\AR\DefaultData\99_ReCreateTriggers.sql

	DECLARE @strRecordNumber 	NVARCHAR(50) = NULL
		  , @strError 			NVARCHAR(500) = NULL
		  , @strPaidInvoice 	NVARCHAR(MAX) = NULL
		  , @intPaymentId 		INT = NULL
		  , @ysnPosted			BIT = 0		  

	SELECT @intPaymentId 	= intPaymentId
		 , @strRecordNumber = strRecordNumber 
		 , @ysnPosted		= ysnPosted 
	FROM DELETED 

	SELECT @strPaidInvoice = COALESCE(@strPaidInvoice + ', ' + I.strInvoiceNumber, I.strInvoiceNumber)
	FROM tblARPaymentDetail PD
	INNER JOIN DELETED D ON PD.intPaymentId = D.intPaymentId
	INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
	WHERE D.ysnPosted = 0
	  AND I.ysnPaid = 1
	GROUP BY I.strInvoiceNumber

	IF EXISTS (SELECT TOP 1 NULL FROM tblGLDetail WHERE ysnIsUnposted = 0 AND strCode = 'AR' AND intTransactionId = @intPaymentId AND strTransactionId = @strRecordNumber)
		SET @strError = 'You cannot delete payment ' + @strRecordNumber + '. It has existing posted GL entries.';

	IF @ysnPosted = 1
		SET @strError = 'You cannot delete posted payment (' + @strRecordNumber + ')';

	IF @strPaidInvoice <> ''
		SET @strError = 'Invoice (' + @strPaidInvoice + ') has been fully paid. This payment may not be deleted.';

	IF ISNULL(@strError, '') <> ''
		RAISERROR(@strError, 16, 1);
	ELSE
		DELETE A
		FROM tblARPayment A
		INNER JOIN DELETED B ON A.intPaymentId = B.intPaymentId
END
GO

--TRIGGERS BEFORE UPDATE
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
	IF((@ysnPosted = 1 and @ysnPostedNew = 0 and @currentStatus = 5) OR (@ysnPosted = 0 and @ysnPostedNew = 0) OR (@ysnPosted = 0 and @ysnPostedNew = 1) OR UPDATE(intCurrentStatus) OR UPDATE(intPeriodId) OR @currentStatus = 5)
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
		FROM tblARPayment p
		INNER JOIN inserted i
			ON i.intPaymentId = p.intPaymentId
	END
	ELSE
		RAISERROR('Cannot update posted payment',16,1)		
END

--TRIGGERS AFTER DELETE
GO
CREATE TRIGGER trgForDeleteARPayment
    ON dbo.tblARPayment
    FOR DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM DELETED)
		BEGIN
			--iNSERT
		   INSERT INTO  tblARAuditLog
		   SELECT 'Deleted','Payment',strRecordNumber,GETDATE(),NULL,0 FROM DELETED

		END
END

--TRIGGERS AFTER UPDATE
GO
CREATE TRIGGER trgForUpdatePayment 
	ON dbo.tblARPayment
	FOR UPDATE 
AS
BEGIN
		DECLARE @strRecordNumber NVARCHAR (50) 
		SELECT @strRecordNumber=i.strRecordNumber from deleted i; IF UPDATE(strRecordNumber)

		IF @strRecordNumber IS NOT  NULL
		BEGIN
		IF UPDATE (strRecordNumber)
		INSERT INTO  tblARAuditLog
		   SELECT 'Updated','Payment',strRecordNumber,GETDATE(),NULL,0 FROM deleted

		END
END