﻿CREATE TABLE [dbo].[tblAPBill] (
    [intBillId]            INT             IDENTITY (1, 1) NOT NULL,
    [intBillBatchId]       INT             NULL ,
    [strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]           INT             NOT NULL DEFAULT 0,
    [intTransactionReversed]				INT             NULL ,
	[intBankInfoId]				INT             NULL ,
    [dtmDate]              DATETIME        NOT NULL DEFAULT GETDATE(),
    [dtmDueDate]           DATETIME        NOT NULL DEFAULT GETDATE(),
    [intAccountId]         INT             NULL ,
    [strReference]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strApprovalNotes]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strRemarks]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]             DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dbl1099]             DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblSubtotal]          DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [ysnPosted]            BIT             NOT NULL DEFAULT 0,
    [ysnPaid]              BIT             NOT NULL DEFAULT 0,
    [strBillId]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblAmountDue]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dtmDatePaid]          DATETIME        NULL ,
	[dtmApprovalDate]       DATETIME        NULL ,
    [dtmDiscountDate]      DATETIME        NULL,
    [intUserId]            INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmBillDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [intEntityId] INT NOT NULL , 
    [intEntityVendorId] INT NOT NULL  , 
    [dblWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblTax] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPayment] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblInterest] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
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
	[intPayToAddressId] INT NULL,
	[intVoucherDifference] INT NULL,
	[intShipToId] INT NULL , 
	[intShipViaId] INT NULL , 
    [intStoreLocationId] INT NULL , 
    [intContactId] INT NULL , 
    [intOrderById] INT NULL , 
    [intCurrencyId] INT NOT NULL,
	[intSubCurrencyCents] INT NOT NULL DEFAULT 0,
	[ysnApproved] BIT NOT NULL DEFAULT 0,
	[ysnForApproval] BIT NOT NULL DEFAULT 0,
    [ysnOrigin] BIT NOT NULL DEFAULT 0,
	[ysnDeleted] BIT NULL DEFAULT 0 ,
	[ysnReadyForPayment] BIT NULL DEFAULT 0 ,
	[ysnRecurring] BIT NULL DEFAULT 0 ,
	[ysnExported] BIT NULL DEFAULT 0 ,
	[ysnForApprovalSubmitted] BIT NOT NULL DEFAULT 0 ,
	[dtmDateDeleted] DATETIME NULL,
	[dtmExportedDate] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL DEFAULT GETDATE(), 
    CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([intBillId] ASC),
    CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatch] ([intBillBatchId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo_tblEMEntity_intContactId] FOREIGN KEY (intContactId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPVendor_intVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES tblAPVendor([intEntityId]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMCompanyLocation_intShipToId] FOREIGN KEY (intShipToId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEMEntityLocation_intShipFromId] FOREIGN KEY (intShipFromId) REFERENCES [tblEMEntityLocation](intEntityLocationId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMShipVia_intShipViaId] FOREIGN KEY (intShipViaId) REFERENCES tblSMShipVia([intEntityId]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMCurrency_intCurrencyID] FOREIGN KEY (intCurrencyId) REFERENCES tblSMCurrency(intCurrencyID),
	--CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEMEntityContact_intContactId] FOREIGN KEY (intContactId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId)
);
GO
CREATE NONCLUSTERED INDEX [IX_intBillBatchId]
    ON [dbo].[tblAPBill]([intBillBatchId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_strBillId]
    ON [dbo].[tblAPBill]([strBillId] ASC)
	INCLUDE (intBillId, intEntityVendorId);
GO
CREATE NONCLUSTERED INDEX [IX_intVendorId]
    ON [dbo].[tblAPBill]([intEntityVendorId] ASC)
	INCLUDE ([intBillId], [strVendorOrderNumber], [intAccountId]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
