CREATE TABLE [dbo].[tblAPPayment] (
    [intPaymentId]        INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]        INT             NOT NULL,
    [intBankAccountId]    INT             NOT NULL,
    [intPaymentMethodId]    INT             NOT NULL,
	[intPayToAddressId]  INT             NULL,
	[intUnitOfMeasureId]  INT             NULL,
	[intCompanyLocationId] INT			NULL,
	[intCompanyId]				INT             NULL ,
    [intCurrencyId]       INT             NOT NULL,
    [strPaymentInfo]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCheckMessage]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPayee]                 NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
	[strOverridePayee]         NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDatePaid]         DATETIME        NOT NULL,
    [dblAmountPaid]       DECIMAL (18, 6) NOT NULL,
	[dblUnapplied]       DECIMAL (18, 6) NOT NULL,
	[dblQuantity]       DECIMAL (18, 6) NOT NULL DEFAULT(0),
    [dblExchangeRate]  DECIMAL (18, 6) NOT NULL DEFAULT(1),
    [ysnPosted]           BIT             NOT NULL,
    [strPaymentRecordNum] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblWithheld]   DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intUserId]           INT             NULL,
	[intCurrencyExchangeRateTypeId]	INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intEntityId] INT NOT NULL DEFAULT 0,
    [intEntityVendorId] INT NULL,
	[intBatchId] INT NULL,
	[strBatchId] NVARCHAR(255) NULL,
    [ysnOrigin] BIT NOT NULL DEFAULT 0,
    --[ysnVoid] BIT NOT NULL DEFAULT 0, 
    [ysnPrinted] BIT NOT NULL DEFAULT 0, 
	[ysnPrepay] BIT NOT NULL DEFAULT 0, 
	[ysnHasImportedPaidVouchers] BIT NOT NULL DEFAULT 0, 
	[ysnLienExists] BIT NOT NULL DEFAULT 0, 
	[ysnOverrideCheckPayee] BIT NOT NULL DEFAULT 0, 
	[ysnOverrideSettlement] BIT NOT NULL DEFAULT 0, 
	[ysnOverridePayTo] BIT NOT NULL DEFAULT 0, 
	[ysnOverrideLien] BIT NOT NULL DEFAULT 0, 
	[ysnDeleted] BIT NULL DEFAULT 0,
	[dtmDateDeleted] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL DEFAULT GETDATE(), 
	[ysnNewFlag] BIT NOT NULL DEFAULT 0,
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
GO
CREATE NONCLUSTERED INDEX [IX_rptAging_1] ON [dbo].[tblAPPayment]
(
	[ysnPrepay] ASC,
	[ysnPosted] ASC,
	[intPaymentId] ASC,
	[strPaymentRecordNum] ASC,
	[intEntityVendorId] ASC,
	[dtmDatePaid] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE STATISTICS [ST_rptAging_1] ON [dbo].[tblAPPayment]([strPaymentRecordNum], [intEntityVendorId], [intPaymentId], [ysnPosted])
GO
CREATE STATISTICS [ST_rptAging_2] ON [dbo].[tblAPPayment]([ysnPrepay], [ysnPosted], [dtmDatePaid])
GO
CREATE STATISTICS [ST_rptAging_3] ON [dbo].[tblAPPayment]([intEntityVendorId], [ysnPrepay], [ysnPosted])
GO
CREATE STATISTICS [ST_rptAging_4] ON [dbo].[tblAPPayment]([ysnPosted], [ysnPrepay], [strPaymentRecordNum], [intEntityVendorId], [intPaymentId], [dtmDatePaid])
GO
CREATE STATISTICS [ST_rptAging_5] ON [dbo].[tblAPPayment]([intPaymentId], [ysnPrepay])
GO
CREATE STATISTICS [ST_rptAging_6] ON [dbo].[tblAPPayment]([ysnPosted], [strPaymentRecordNum], [intEntityVendorId])
GO
CREATE STATISTICS [ST_rptAging_7] ON [dbo].[tblAPPayment]([dtmDatePaid], [ysnPrepay])
GO
CREATE TRIGGER [dbo].[trg_tblAPPayment]
ON [dbo].[tblAPPayment]
INSTEAD OF DELETE 
AS

BEGIN
	DECLARE @paymentRecord NVARCHAR(50);
	DECLARE @paymentId INT;
	DECLARE @error NVARCHAR(500);
	SELECT TOP 1 @paymentRecord = del.strPaymentRecordNum, @paymentId = del.intPaymentId FROM tblGLDetail glDetail
					INNER JOIN DELETED del ON glDetail.strTransactionId = del.strPaymentRecordNum AND glDetail.intTransactionId = del.intPaymentId
				WHERE glDetail.ysnIsUnposted = 0

	IF @paymentId > 0
	BEGIN
		SET @error = 'You cannot delete posted Payment (' + @paymentRecord + ')';
		RAISERROR(@error, 16, 1);
	END
	ELSE
	BEGIN
		DELETE A
		FROM [tblAPPayment] A
		INNER JOIN DELETED B ON A.intPaymentId = B.intPaymentId
	END
END
GO