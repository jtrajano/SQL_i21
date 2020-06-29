CREATE TABLE [dbo].[tblAPBill] (
    [intBillId]            INT             IDENTITY (1, 1) NOT NULL,
    [intBillBatchId]       INT             NULL ,
    [strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]           INT             NOT NULL DEFAULT 0,
    [intTransactionReversed]				INT             NULL ,
	[intCommodityId]				INT             NULL ,
	[intInvoiceRefId]				INT             NULL ,
	[intCompanyId]				INT             NULL ,
	[intBankInfoId]				INT             NULL ,
	[intBookId]	INT NULL,
	[intSubBookId] INT NULL,
	[ysnPrepayHasPayment]				BIT             NOT NULL DEFAULT 0,
    [dtmDate]              DATETIME        NOT NULL DEFAULT GETDATE(),
    [dtmDueDate]           DATETIME        NOT NULL DEFAULT GETDATE(),
    [intAccountId]         INT             NULL ,
    [strReference]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strTempPaymentInfo]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strApprovalNotes]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strRemarks]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]             DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblTotalController]   DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dbl1099]             DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblSubtotal]          DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [ysnPosted]            BIT             NOT NULL DEFAULT 0,
    [ysnPaid]              BIT             NOT NULL DEFAULT 0,
    [strBillId]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblAmountDue]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dtmDatePaid]          DATETIME        NULL ,
	[dtmApprovalDate]       DATETIME        NULL ,
    [dtmDiscountDate]      DATETIME        NULL,
	[dtmInterestDate]      DATETIME        NULL,
	[dtmDeferredInterestDate]      DATETIME        NULL,
	[dtmInterestAccruedThru]      DATETIME        NULL,
    [intUserId]            INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmBillDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [intEntityId] INT NOT NULL , 
    [intEntityVendorId] INT NOT NULL  , 
	[intShipFromEntityId] INT NOT NULL  , 
    [dblWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTempWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTempDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTax] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPayment] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTempPayment] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblInterest] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTempInterest] DECIMAL(18, 6) NOT NULL DEFAULT 0,
    [intTransactionType] INT NOT NULL DEFAULT 0, 
    [intPurchaseOrderId] INT NULL, 
	[strPONumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAttention] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAddress] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCity] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToState] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToZipCode] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCountry] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToPhone] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAttention] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAddress] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCity] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromState] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromZipCode] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCountry] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromPhone] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [intShipFromId] INT NULL , 
	[intDeferredVoucherId] INT NULL , 
	[intPayToAddressId] INT NULL,
	[intVoucherDifference] INT NULL,
	[intShipToId] INT NULL , 
	[intShipViaId] INT NULL , 
    [intStoreLocationId] INT NULL , 
    [intContactId] INT NULL , 
    [intOrderById] INT NULL , 
    [intCurrencyId] INT NOT NULL,
	[intSubCurrencyCents] INT NOT NULL DEFAULT 1,
	[ysnApproved] BIT NOT NULL DEFAULT 0,
	[ysnForApproval] BIT NOT NULL DEFAULT 0,
    [ysnOrigin] BIT NOT NULL DEFAULT 0,
	[ysnDeleted] BIT NULL DEFAULT 0 ,
	[ysnIsPaymentScheduled] BIT NOT NULL DEFAULT 0 ,
	[ysnDiscountOverride] BIT NOT NULL DEFAULT 0,
	[ysnReadyForPayment] BIT NULL DEFAULT 0 ,
	[ysnRecurring] BIT NULL DEFAULT 0 ,
	[ysnExported] BIT NULL,
	[ysnForApprovalSubmitted] BIT NOT NULL DEFAULT 0 ,
	[ysnOldPrepayment] BIT NOT NULL DEFAULT 0 ,
	[dtmDateDeleted] DATETIME NULL,
	[dtmExportedDate] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL DEFAULT GETDATE(), 
    CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([intBillId] ASC),
    -- CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatch] ([intBillBatchId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo_tblEMEntity_intContactId] FOREIGN KEY (intContactId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPVendor_intVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES tblAPVendor([intEntityId]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPVendor_intShipFromEntityId] FOREIGN KEY ([intShipFromEntityId]) REFERENCES tblAPVendor([intEntityId]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMCompanyLocation_intShipToId] FOREIGN KEY (intShipToId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEMEntityLocation_intShipFromId] FOREIGN KEY (intShipFromId) REFERENCES [tblEMEntityLocation](intEntityLocationId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMShipVia_intShipViaId] FOREIGN KEY (intShipViaId) REFERENCES tblSMShipVia([intEntityId]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyId) REFERENCES tblSMCurrency(intCurrencyID),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEMEntityContact_intContactId] FOREIGN KEY (intContactId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId),

	CONSTRAINT [FK_tblAPBill_intBankInfoId] FOREIGN KEY ([intBankInfoId]) REFERENCES tblCMBankAccount([intBankAccountId]),
	CONSTRAINT [FK_tblAPBill_intPurchaseOrderId] FOREIGN KEY ([intPurchaseOrderId]) REFERENCES tblPOPurchase([intPurchaseId]),
	CONSTRAINT [FK_tblAPBill_intPayToAddressId] FOREIGN KEY ([intPayToAddressId]) REFERENCES tblEMEntityLocation([intEntityLocationId]),
	CONSTRAINT [FK_tblAPBill_intStoreLocationId] FOREIGN KEY ([intStoreLocationId]) REFERENCES tblSMCompanyLocation([intCompanyLocationId]),
	CONSTRAINT [FK_tblAPBill_intDeferredVoucherId] FOREIGN KEY ([intDeferredVoucherId]) REFERENCES tblAPBill([intBillId]),
	CONSTRAINT [FK_tblAPBill_intBookId] FOREIGN KEY ([intBookId]) REFERENCES tblCTBook([intBookId]),
	CONSTRAINT [FK_tblAPBill_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES tblCTSubBook([intSubBookId])
);
GO
CREATE NONCLUSTERED INDEX [IX_intBillBatchId]
    ON [dbo].[tblAPBill]([intBillBatchId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_strBillId]
    ON [dbo].[tblAPBill]([strBillId] ASC)
	INCLUDE (intBillId, intEntityVendorId, dtmBillDate, ysnPosted, [strVendorOrderNumber], [intAccountId]);
GO
CREATE NONCLUSTERED INDEX [IX_intBillId]
    ON [dbo].[tblAPBill]([intBillId] ASC)
	INCLUDE (strBillId, intEntityVendorId, dtmBillDate, ysnPosted, [strVendorOrderNumber], [intAccountId]);
GO
CREATE NONCLUSTERED INDEX [IX_intVendorId]
    ON [dbo].[tblAPBill]([intEntityVendorId] ASC)
	INCLUDE ([intBillId], dtmBillDate, ysnPosted, [strVendorOrderNumber], [intAccountId]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rptAging_1] ON [dbo].[tblAPBill]
(
	[intBillId] ASC,
	[ysnPosted] ASC,
	[intTransactionType] ASC,
	[ysnPaid] ASC,
	[strBillId] ASC,
	[dtmDueDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rptAging_2] ON [dbo].[tblAPBill]
(
	[intBillId] ASC,
	[ysnPosted] ASC,
	[intTransactionType] ASC,
	[ysnPaid] ASC,
	[strBillId] ASC,
	[dtmDueDate] ASC,
	[intEntityVendorId] ASC,
	[dtmDate] ASC,
	[intAccountId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rptAging_3] ON [dbo].[tblAPBill]
(
	[ysnPosted] ASC,
	[intBillId] ASC,
	[intEntityVendorId] ASC,
	[dtmDate] ASC,
	[strBillId] ASC,
	[dtmDueDate] ASC,
	[intAccountId] ASC,
	[ysnPaid] ASC,
	[intTransactionType] ASC
)
INCLUDE ( 	[dblTotal],[dblAmountDue]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rptAging_4] ON [dbo].[tblAPBill]
(
	[ysnOrigin] ASC,
	[intBillId] ASC,
	[ysnPosted] ASC,
	[intTransactionType] ASC,
	[intEntityVendorId] ASC,
	[ysnPaid] ASC,
	[dtmDate] ASC,
	[strBillId] ASC,
	[dtmDueDate] ASC,
	[intAccountId] ASC
)
INCLUDE ( 	[dblTotal],
	[dblAmountDue],
	[dblTax]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rptAging_5] ON [dbo].[tblAPBill]
(
	[intTransactionType] ASC,
	[ysnOrigin] ASC,
	[ysnPosted] ASC,
	[dtmDate] ASC,
	[intBillId] ASC,
	[strBillId] ASC,
	[dtmDueDate] ASC,
	[ysnPaid] ASC,
	[intAccountId] ASC
)
INCLUDE ( 	[dblTotal],
	[dblAmountDue],
	[intEntityVendorId],
	[dblTax]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rptAging_6] ON [dbo].[tblAPBill]
(
	[intEntityVendorId] ASC,
	[intTransactionType] ASC,
	[ysnOrigin] ASC,
	[ysnPosted] ASC,
	[ysnPaid] ASC,
	[intBillId] ASC,
	[dtmDate] ASC,
	[strBillId] ASC,
	[dtmDueDate] ASC,
	[intAccountId] ASC
)
INCLUDE ( 	[dblTotal],
	[dblAmountDue],
	[dblTax]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE STATISTICS [ST_rptAging_1] ON [dbo].[tblAPBill]([intEntityVendorId], [intTransactionType], [ysnPosted], [ysnPaid], [intBillId], [ysnOrigin], [dtmDate], [strBillId], [dtmDueDate], [intAccountId])
GO
CREATE STATISTICS [ST_rptAging_2] ON [dbo].[tblAPBill]([intTransactionType], [ysnPosted], [intBillId], [strBillId], [dtmDueDate])
GO
CREATE STATISTICS [ST_rptAging_3] ON [dbo].[tblAPBill]([intEntityVendorId], [ysnPosted], [intBillId], [intTransactionType])
GO
CREATE STATISTICS [ST_rptAging_4] ON [dbo].[tblAPBill]([ysnPosted], [intTransactionType], [ysnPaid], [intBillId], [strBillId], [dtmDueDate], [intEntityVendorId])
GO
CREATE STATISTICS [ST_rptAging_5] ON [dbo].[tblAPBill]([ysnPosted], [dtmDate], [intBillId], [strBillId])
GO
CREATE STATISTICS [ST_rptAging_6] ON [dbo].[tblAPBill]([dtmDate], [intBillId], [strBillId], [dtmDueDate], [ysnPosted], [intAccountId])
GO
CREATE STATISTICS [ST_rptAging_7] ON [dbo].[tblAPBill]([dtmDate], [intBillId], [strBillId], [dtmDueDate], [ysnPosted], [ysnPaid], [intAccountId], [intTransactionType])
GO
CREATE STATISTICS [ST_rptAging_8] ON [dbo].[tblAPBill]([intTransactionType], [ysnOrigin], [ysnPosted], [ysnPaid], [intEntityVendorId])
GO
CREATE STATISTICS [ST_rptAging_9] ON [dbo].[tblAPBill]([intTransactionType], [ysnPosted], [ysnPaid])
GO
CREATE STATISTICS [ST_rptAging_10] ON [dbo].[tblAPBill]([intTransactionType], [ysnPosted], [dtmDate], [intBillId], [strBillId], [dtmDueDate], [ysnPaid])
GO
CREATE STATISTICS [ST_rptAging_11] ON [dbo].[tblAPBill]([intBillId], [intTransactionType], [ysnOrigin]) 
GO
CREATE STATISTICS [ST_rptAging_12] ON [dbo].[tblAPBill]([intBillId], [ysnPaid], [ysnPosted], [intTransactionType], [ysnOrigin])
GO
CREATE STATISTICS [ST_rptAging_13] ON [dbo].[tblAPBill]([intBillId], [strBillId], [dtmDueDate], [ysnPosted], [ysnPaid])
GO
CREATE STATISTICS [ST_rptAging_14] ON [dbo].[tblAPBill]([intBillId], [intEntityVendorId], [ysnPosted], [intTransactionType], [ysnPaid], [dtmDate], [strBillId], [dtmDueDate], [intAccountId])
GO
CREATE STATISTICS [ST_rptAging_15] ON [dbo].[tblAPBill]([intBillId], [intEntityVendorId], [ysnPosted], [dtmDate], [strBillId], [dtmDueDate], [intAccountId], [ysnPaid])
GO
GO
CREATE TRIGGER trg_tblAPBill
ON dbo.tblAPBill
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @billRecord NVARCHAR(50);
	DECLARE @billId INT;
	DECLARE @intTransactionReversed INT;
	DECLARE @error NVARCHAR(500);
	SELECT TOP 1 @billRecord = del.strBillId, @billId = del.intBillId, @intTransactionReversed = del.intTransactionReversed FROM tblGLDetail glDetail
					INNER JOIN DELETED del ON glDetail.strTransactionId = del.strBillId AND glDetail.intTransactionId = del.intBillId
				WHERE glDetail.ysnIsUnposted = 0
				AND glDetail.strCode <> 'ICA'

	IF @billId > 0
	BEGIN
		SET @error = 'You cannot delete posted voucher (' + @billRecord + ')';
		RAISERROR(@error, 16, 1);
	END
	ELSE IF @intTransactionReversed > 0
	BEGIN
		SET @error = 'You cannot delete reversal transaction (' + @billRecord + ')';
		RAISERROR(@error, 16, 1);
	END
	ELSE
	BEGIN
		DELETE A
		FROM tblAPBill A
		INNER JOIN DELETED B ON A.intBillId = B.intBillId
	END
END
GO