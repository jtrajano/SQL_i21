CREATE TABLE [dbo].[tblAPPayment] (
    [intPaymentId]       INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]       INT             NOT NULL,
    [intBankAccountId]   INT             NOT NULL,
    [intPaymentMethod]   INT             NOT NULL,
    [intCurrencyId]      INT             NOT NULL,
    [strVendorId]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strPaymentInfo]     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDatePaid]        DATETIME        NOT NULL,
    [dblCredit]          DECIMAL (18, 2) NOT NULL,
    [dblAmountPaid]      DECIMAL (18, 2) NOT NULL,
    [dblUnappliedAmount] DECIMAL (18, 2) NOT NULL,
    [ysnPosted]          BIT             NOT NULL,
    [strPaymentRecordNum] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_dbo.tblAPPayments] PRIMARY KEY CLUSTERED ([intPaymentId] ASC)
);

