CREATE TABLE [dbo].[tblARPayment] (
    [intPaymentId]       INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]        INT             NOT NULL,
    [intCurrencyId]      INT             NOT NULL,
    [dtmDatePaid]        DATETIME        NULL,
    [intAccountId]       INT             NOT NULL,
    [intPaymentMethodId] INT             NOT NULL,
    [intLocationId]      INT             NULL,
    [dblAmountPaid]      NUMERIC (18, 6) NULL,
    [dblUnappliedAmount] NUMERIC (18, 6) NULL,
    [dblOverpayment]     NUMERIC (18, 6) NULL,
    [dblBalance]         NUMERIC (18, 6) NULL,
    [strRecordNumber]    NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [strCheckNumber]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strNotes]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]          BIT             CONSTRAINT [DF_tblARPayment_ysnPosted] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]   INT             CONSTRAINT [DF_tblARPayment_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARPayment] PRIMARY KEY CLUSTERED ([intPaymentId] ASC),
    CONSTRAINT [FK_tblARPayment_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
);

