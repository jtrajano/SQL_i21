﻿CREATE TABLE [dbo].[tblAPBillArchive] (
    [intBillId]            INT             NOT NULL,
    [intBillBatchId]       INT             NULL ,
    [strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]           INT             NOT NULL DEFAULT 0,
    [intTransactionReversed]				INT             NULL ,
	[intCommodityId]				INT             NULL ,
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
	[dblAverageExchangeRate] DECIMAL (18, 6) NULL,
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
	[dtmOrigDateDeleted] DATETIME NULL,
	[ysnOverrideCashFlow] BIT NULL DEFAULT 0,
	[dtmCashFlowDate] DATETIME NULL,
	[dblAverageExchangeRate] DECIMAL (18, 6) NULL
    CONSTRAINT [PK_dbo.tblAPBillArchive] PRIMARY KEY CLUSTERED ([intBillId] ASC),
	CONSTRAINT [UK_dbo.tblAPBillArchive_strBillId] UNIQUE (strBillId)
);
GO
CREATE NONCLUSTERED INDEX [tblAPBillArchive_intBillBatchId]
    ON [dbo].[tblAPBillArchive]([intBillBatchId] ASC);
GO
CREATE NONCLUSTERED INDEX [tblAPBillArchive_strBillId]
    ON [dbo].[tblAPBillArchive]([strBillId] ASC)
	INCLUDE (intBillId, intEntityVendorId, dtmBillDate, ysnPosted, [strVendorOrderNumber], [intAccountId]);
GO
CREATE NONCLUSTERED INDEX [tblAPBillArchive_intBillId]
    ON [dbo].[tblAPBillArchive]([intBillId] ASC)
	INCLUDE (strBillId, intEntityVendorId, dtmBillDate, ysnPosted, [strVendorOrderNumber], [intAccountId]);
GO
CREATE NONCLUSTERED INDEX [tblAPBillArchive_intVendorId]
    ON [dbo].[tblAPBillArchive]([intEntityVendorId] ASC)
	INCLUDE ([intBillId], dtmBillDate, ysnPosted, [strVendorOrderNumber], [intAccountId]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO