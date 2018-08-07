CREATE TABLE [dbo].[tblARPOSPayment] (
    [intPOSPaymentId]	INT             IDENTITY (1, 1) NOT NULL,
    [intPOSId]			INT             NOT NULL,
    [intPaymentId]		INT             NULL,
    [strPaymentMethod]	NVARCHAR (35)   COLLATE Latin1_General_CI_AS NULL,
    [strReferenceNo]	NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]			NUMERIC (18, 6) NOT NULL,
	[dblAmountTendered]	NUMERIC (18, 6) NOT NULL DEFAULT 0,
    [intConcurrencyId]	INT             NOT NULL,
    CONSTRAINT [PK_tblARPOSPayment] PRIMARY KEY CLUSTERED ([intPOSPaymentId] ASC),
    CONSTRAINT [FK_tblARPOSPayment] FOREIGN KEY ([intPOSId]) REFERENCES [dbo].[tblARPOS] ([intPOSId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARPOSPayment_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId])
);

