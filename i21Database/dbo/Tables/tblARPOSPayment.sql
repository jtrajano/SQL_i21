CREATE TABLE [dbo].[tblARPOSPayment] (
    [intPOSPaymentId]  INT             IDENTITY (1, 1) NOT NULL,
    [intPOSId]         INT             NOT NULL,
    [strPaymentMethod] NVARCHAR (35)   COLLATE Latin1_General_CI_AS NULL,
    [strReferenceNo]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]        NUMERIC (18, 6) NOT NULL,
    [intConcurrencyId] INT             NOT NULL,
    CONSTRAINT [PK_tblARPOSPayment] PRIMARY KEY CLUSTERED ([intPOSPaymentId] ASC),
    CONSTRAINT [FK_tblARPOSPayment] FOREIGN KEY ([intPOSId]) REFERENCES [dbo].[tblARPOS] ([intPOSId]) ON DELETE CASCADE
);

