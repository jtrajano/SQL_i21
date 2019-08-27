CREATE TABLE [dbo].[tblARPOS] (
    [intPOSId]             INT             IDENTITY (1, 1) NOT NULL,
    [strReceiptNumber]     NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intEntityCustomerId]  INT             NOT NULL,
    [intCompanyLocationId] INT             NOT NULL,
    [intGLAccountId]       INT             NOT NULL,
    [intCurrencyId]        INT             NOT NULL,
    [dtmDate]              DATETIME        NOT NULL,
    [intItemCount]         INT             NULL,
    [dblShipping]          NUMERIC (18, 6) CONSTRAINT [DF_tblARPOS_dblShipping] DEFAULT ((0)) NOT NULL,
    [dblDiscountPercent]   NUMERIC (18, 6) NULL,
    [dblDiscount]          NUMERIC (18, 6) NOT NULL,
    [dblTax]               NUMERIC (18, 6) NOT NULL,
    [dblSubTotal]          NUMERIC (18, 6) NOT NULL,
    [dblTotal]             NUMERIC (18, 6) NOT NULL,
    [intInvoiceId]         INT             NULL,
	[intCreditMemoId]	   INT			   NULL,
    [ysnHold]              BIT             CONSTRAINT [DF_tblARPOS_ysnHold] DEFAULT ((0)) NOT NULL,
    [intEntityUserId]      INT             NOT NULL,
	[intPOSLogId]		   INT             NOT NULL,
    [intConcurrencyId]     INT             NOT NULL,
	[ysnReturn]			   BIT             CONSTRAINT [DF_tblARPOS_ysnReturn] DEFAULT ((0)) NOT NULL,
	[strPONumber]		   NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceNumber]	   NVARCHAR(25)	   COLLATE Latin1_General_CI_AS	NULL,
	[strCreditMemoNumber]  NVARCHAR(25)	   COLLATE Latin1_General_CI_AS	NULL,
	[strComment]	       NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NULL,
	[ysnTaxExempt]		   BIT			   NULL,
	[ysnMixed]		   	   BIT			   CONSTRAINT [DF_tblARPOS_ysnMixed] DEFAULT ((0)) NOT NULL,
	[ysnPaid]			   BIT			   CONSTRAINT [DF_tblARPOS_ysnPaid] DEFAULT ((0)) NOT NULL,
    [intOriginalPOSTransactionId] INT NULL, 
    CONSTRAINT [PK_tblARPOS] PRIMARY KEY CLUSTERED ([intPOSId] ASC),
	CONSTRAINT [FK_tblARPOSLog] FOREIGN KEY ([intPOSLogId]) REFERENCES [dbo].[tblARPOSLog] ([intPOSLogId])
);


GO
CREATE TRIGGER [dbo].[trgReceiptNumber] 
   ON  [dbo].[tblARPOS]
   AFTER INSERT
AS 

DECLARE @ReceiptNumber NVARCHAR(25) = NULL    
DECLARE @intStartingNumberId INT = 0
DECLARE @inserted TABLE(intPOSId INT, strReceiptNumber NVARCHAR(30))
DECLARE @posId INT = 0

BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO @inserted
	SELECT intPOSId, strReceiptNumber FROM INSERTED WHERE ISNULL(RTRIM(LTRIM(strReceiptNumber)), '') = '' ORDER BY intPOSId
	
	WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
	BEGIN
		SELECT TOP 1 @posId = intPOSId FROM @inserted

		EXEC uspARGetReceiptNumber @strReceiptNumber = @ReceiptNumber OUTPUT

		UPDATE tblARPOS     
		SET strReceiptNumber = @ReceiptNumber
		WHERE intPOSId = @posId

		DELETE FROM @inserted where intPOSId = @posId
	END

END
GO

CREATE TRIGGER trgPOSInvoiceNumber
ON dbo.tblARPOS
AFTER INSERT
AS

DECLARE @INSERTED_INVOICENUMBER TABLE(intPOSId INT, intCompanyLocationId INT, ysnReturn BIT, ysnMixed BIT)
DECLARE @intPOSId 						INT = NULL
DECLARE @intCompanyLocationId 			INT = NULL
DECLARE @intInvoiceStartingNumberId 	INT = NULL
DECLARE @ysnReturn						BIT = NULL
DECLARE @ysnMixed						BIT = NULL
DECLARE @strInvoiceNumber 				NVARCHAR(50) = NULL
DECLARE @strCreditMemoNumber			NVARCHAR(50) = NULL

INSERT INTO @INSERTED_INVOICENUMBER
SELECT intPOSId
	 , intCompanyLocationId
	 , ysnReturn 
	 , ysnMixed
FROM INSERTED 
ORDER BY intPOSId

SELECT TOP 1 @intInvoiceStartingNumberId = intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Invoice' AND strModule = 'Accounts Receivable'

WHILE((SELECT TOP 1 1 FROM @INSERTED_INVOICENUMBER) IS NOT NULL)
BEGIN
	SET @strInvoiceNumber = NULL
	SET @strCreditMemoNumber = NULL

	SELECT TOP 1 @intPOSId = intPOSId
			   , @intCompanyLocationId = intCompanyLocationId
			   , @ysnReturn = ysnReturn
			   , @ysnMixed = ysnMixed 
	FROM @INSERTED_INVOICENUMBER
	
	IF @ysnReturn = 0	
		EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strInvoiceNumber OUT, @intCompanyLocationId

	IF @ysnReturn = 1 OR @ysnMixed = 1
		EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strCreditMemoNumber OUT, @intCompanyLocationId

	IF ISNULL(@strInvoiceNumber, '') <> ''
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @strInvoiceNumber) OR EXISTS(SELECT NULL FROM tblARPOS WHERE strInvoiceNumber = @strInvoiceNumber OR strCreditMemoNumber = @strInvoiceNumber)
			BEGIN
				SET @strInvoiceNumber = NULL
				
				EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strInvoiceNumber OUT, @intCompanyLocationId			
			END
	END

	IF ISNULL(@strCreditMemoNumber, '') <> ''
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @strCreditMemoNumber) OR EXISTS(SELECT NULL FROM tblARPOS WHERE strInvoiceNumber = @strCreditMemoNumber OR strCreditMemoNumber = @strCreditMemoNumber)
			BEGIN
				SET @strCreditMemoNumber = NULL
				
				EXEC uspSMGetStartingNumber @intInvoiceStartingNumberId, @strCreditMemoNumber OUT, @intCompanyLocationId			
			END
	END

	UPDATE tblARPOS
	SET strInvoiceNumber	= CASE WHEN @ysnReturn = 0 THEN @strInvoiceNumber ELSE NULL END
	  , strCreditMemoNumber	= CASE WHEN @ysnReturn = 1 OR @ysnMixed = 1 THEN @strCreditMemoNumber ELSE NULL END
	WHERE intPOSId = @intPOSId

	DELETE FROM @INSERTED_INVOICENUMBER
	WHERE intPOSId = @intPOSId
END
GO