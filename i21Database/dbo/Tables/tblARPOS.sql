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
	[strComment]	       NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NULL,
	[ysnTaxExempt]		   BIT			   NULL,
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

BEGIN
	SET NOCOUNT ON;
	Exec uspARGetReceiptNumber @strReceiptNumber = @ReceiptNumber output    
	UPDATE tblARPOS      
	SET strReceiptNumber = @ReceiptNumber      
	WHERE ISNULL(strReceiptNumber,'') = ''

END
GO
