﻿CREATE TABLE [dbo].[tblAPVendor] (
    [intEntityId]               INT            NOT NULL,
	--[intEntityVendorId]				INT				IDENTITY (1, 1) NOT NULL, 
    [intDefaultLocationId]       INT            NULL,
    [intDefaultContactId]        INT            NULL,
    [intCurrencyId]             INT            NULL,
    [strVendorPayToId]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPaymentMethodId]        INT            NULL,
    [intTaxCodeId]              INT            NULL,
    [intGLAccountExpenseId]     INT            NULL ,
    [intVendorType]             INT            NOT NULL,
    [strVendorId]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strVendorAccountNum]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPymtCtrlActive]         BIT            DEFAULT 1 NOT NULL,
    [ysnPymtCtrlAlwaysDiscount] BIT            DEFAULT 0 NOT NULL,
    [ysnPymtCtrlEFTActive]      BIT            DEFAULT 0 NOT NULL,
    [ysnPymtCtrlHold]           BIT            DEFAULT 0 NOT NULL,
    [ysnWithholding]            BIT            NOT NULL,
	[ysnCreateVoucher]           BIT            DEFAULT 1 NOT NULL,
	[ysnPostVoucher] 	         BIT            DEFAULT 0 NOT NULL,
	[intCompanyId]				INT             NULL ,
    [dblCreditLimit]            DECIMAL(18, 6)     NOT NULL,
    [intCreatedUserId]          INT            NULL,
    [intLastModifiedUserId]     INT            NULL,
    [dtmLastModified]           DATETIME       NULL,
    [dtmCreated]                DATETIME       NULL,
    [strTaxState]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[ysnTransportTerminal]		BIT				NULL	DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [strTaxNumber] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [intBillToId] INT NULL, 
    [intShipFromId] INT NULL, 
	[ysnDeleted] BIT NULL DEFAULT 0,
	[dtmDateDeleted] DATETIME NULL,
	[ysnOneBillPerPayment]	BIT NULL DEFAULT 0,
	[strFLOId]						  NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,	
	[intApprovalListId] INT NULL,
	[intTermsId] INT NULL,
	--risk
	[intRiskVendorPriceFixationLimitId] INT NULL, --
	[dblRiskTotalBusinessVolume] DECIMAL(18, 6) NULL,
	[intRiskUnitOfMeasureId] INT NULL,--
	--risk
	--store
	[strStoreFTPPath] NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
	[strStoreFTPUsername] NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
	[strStoreFTPPassword] NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
	[intStoreStoreId] INT NULL,--
	[intProtocolNumber] INT NULL,--
	[intPortNumber] INT NULL,--
	[intChainAccountNumber] INT NULL,--
	[intCsvFormat] INT NULL

	--store
    CONSTRAINT [PK_dbo.tblAPVendor] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
    --CONSTRAINT [UK_strVendorId] UNIQUE NONCLUSTERED ([strVendorId] ASC),
	--CONSTRAINT [UK_intVendorId] UNIQUE NONCLUSTERED ([intEntityVendorId] ASC),
	--CONSTRAINT [FK_tblAPVendor_tblEMEntity] FOREIGN KEY ([intDefaultContactId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblAPVendor_tblEMEntityLocation] FOREIGN KEY ([intDefaultLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblAPVendor_tblGLAccount] FOREIGN KEY ([intGLAccountExpenseId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblAPVendor_tblSMApprovalList] FOREIGN KEY ([intApprovalListId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),	
	CONSTRAINT [FK_tblAPVendor_tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),

	CONSTRAINT [FK_tblAPVendor_tblRKVendorPriceFixationLimit_intRiskVendorPriceFixationLimitId] FOREIGN KEY ([intRiskVendorPriceFixationLimitId]) REFERENCES [dbo].[tblRKVendorPriceFixationLimit] ([intVendorPriceFixationLimitId]),
	CONSTRAINT [FK_tblAPVendor_tblICUnitMeasure_intRiskUnitOfMeasureId] FOREIGN KEY ([intRiskUnitOfMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
	CONSTRAINT [FK_tblAPVendor_tblSTStore] FOREIGN KEY ([intStoreStoreId]) REFERENCES [dbo].[tblSTStore] ([intStoreId]),
	CONSTRAINT [FK_tblAPVendor_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES tblSMCurrency([intCurrencyID]),
	CONSTRAINT [FK_tblAPVendor_intPaymentMethodId] FOREIGN KEY ([intPaymentMethodId]) REFERENCES tblSMPaymentMethod([intPaymentMethodID]),
	CONSTRAINT [FK_tblAPVendor_intBillToId] FOREIGN KEY ([intBillToId]) REFERENCES tblEMEntityLocation([intEntityLocationId]),
	CONSTRAINT [FK_tblAPVendor_intShipFromId] FOREIGN KEY ([intShipFromId]) REFERENCES tblEMEntityLocation([intEntityLocationId]),

	--CONSTRAINT [FK_tblAPVendor_tblAPVendorToContact] FOREIGN KEY ([intDefaultContactId]) REFERENCES [tblAPVendorToContact]([intVendorToContactId])
);


GO
ALTER TABLE [dbo].[tblAPVendor] CHECK CONSTRAINT [FK_dbo.tblAPVendor_dbo.tblEntities_intEntityId];
GO
CREATE NONCLUSTERED INDEX [IX_intVendorId]
    ON [dbo].[tblAPVendor]([intEntityId] ASC, [strVendorId] ASC)
	WITH (  IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF)

GO
CREATE NONCLUSTERED INDEX [IX_rptAging_1] ON [dbo].[tblAPVendor]
(
	[intEntityId] ASC
)
INCLUDE ( 	[strVendorId]) WITH (  DROP_EXISTING = OFF, ONLINE = OFF)
