﻿CREATE TABLE [dbo].[tblAPBill] (
    [intBillId]            INT             IDENTITY (1, 1) NOT NULL,
    [intBillBatchId]       INT             NULL ,
    [strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]           INT             NOT NULL DEFAULT 0,
    [intTaxId]				INT             NULL ,
    [dtmDate]              DATETIME        NOT NULL DEFAULT GETDATE(),
    [dtmDueDate]           DATETIME        NOT NULL DEFAULT GETDATE(),
    [intAccountId]         INT             NOT NULL DEFAULT 0,
    [strDescription]       NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]			NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]             DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblSubtotal]          DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [ysnPosted]            BIT             NOT NULL DEFAULT 0,
    [ysnPaid]              BIT             NOT NULL DEFAULT 0,
    [strBillId]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblAmountDue]         DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [dtmDatePaid]          DATETIME        NULL ,
    [dtmDiscountDate]      DATETIME        NULL,
    [intUserId]            INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmBillDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [intEntityId] INT NOT NULL , 
    [intVendorId] INT NOT NULL  , 
    [dblWithheld] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblBillTax] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPayment] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblInterest] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [intTransactionType] INT NOT NULL DEFAULT 0, 
    [intPurchaseOrderId] INT NULL, 
	[strPONumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strAddress] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strCity] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strState] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strZipCode] NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strCountry] NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
    [intShipFromId] INT NULL , 
	[intShipToId] INT NULL , 
	[intShipViaId] INT NULL , 
    [intStoreLocationId] INT NULL , 
    [intContactId] INT NULL , 
    [intOrderById] INT NULL , 
    [intCurrencyId] INT NOT NULL DEFAULT 0,
    [ysnOrigin] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([intBillId] ASC),
    CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatch] ([intBillBatchId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPVendor_intVendorId] FOREIGN KEY (intVendorId) REFERENCES tblAPVendor(intVendorId),
	CONSTRAINT [FK_dbo.tblAPBill_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId)
);
GO
CREATE NONCLUSTERED INDEX [IX_intBillBatchId]
    ON [dbo].[tblAPBill]([intBillBatchId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_strBillId]
    ON [dbo].[tblAPBill]([strBillId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_intVendorId]
    ON [dbo].[tblAPBill]([intVendorId] ASC)
	INCLUDE ([intBillId], [strVendorOrderNumber]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]