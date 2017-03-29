CREATE TABLE [dbo].[tblAPPayment] (
    [intPaymentId]        INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]        INT             NOT NULL,
    [intBankAccountId]    INT             NOT NULL,
    [intPaymentMethodId]    INT             NOT NULL,
    [intCurrencyId]       INT             NOT NULL,
    [strPaymentInfo]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDatePaid]         DATETIME        NOT NULL,
    [dblAmountPaid]       DECIMAL (18, 6) NOT NULL,
    [dblUnapplied]  DECIMAL (18, 6) NOT NULL,
    [ysnPosted]           BIT             NOT NULL,
    [strPaymentRecordNum] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblWithheld]   DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intUserId]           INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intEntityId] INT NOT NULL DEFAULT 0,
    [intEntityVendorId] INT NULL,
	[intBatchId] INT NULL,
    [ysnOrigin] BIT NOT NULL DEFAULT 0,
    [ysnVoid] BIT NOT NULL DEFAULT 0, 
    [ysnPrinted] BIT NOT NULL DEFAULT 0, 
	[ysnPrepay] BIT NOT NULL DEFAULT 0, 
	[ysnDeleted] BIT NULL DEFAULT 0,
	[dtmDateDeleted] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL DEFAULT GETDATE(), 
    CONSTRAINT [PK_dbo.tblAPPayments] PRIMARY KEY CLUSTERED ([intPaymentId] ASC), 
    CONSTRAINT [FK_tblAPPayment_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	CONSTRAINT [FK_tblAPPayment_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_dbo.tblAPPayment_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPPayment_tblSMCurrency_intCurrencyId] FOREIGN KEY (intCurrencyId) REFERENCES tblSMCurrency(intCurrencyID),
	CONSTRAINT [FK_dbo.tblAPPayment_tblSMPaymentMethod_intPaymentMethodId] FOREIGN KEY (intPaymentMethodId) REFERENCES tblSMPaymentMethod(intPaymentMethodID),
	CONSTRAINT [FK_tblAPPayment_tblCMBankAccount] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId]),
	CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum)
);
GO

CREATE NONCLUSTERED INDEX [IX_tblAPPayment_intVendorId_intPaymentId] ON [dbo].[tblAPPayment] 
(
	[intEntityVendorId] ASC,
	[intPaymentId] ASC,
	[intAccountId] ASC,
	[dtmDatePaid] ASC
)
WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]