﻿CREATE TABLE [dbo].[tblPOPurchase]
(
	[intPurchaseId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intEntityVendorId] INT NOT NULL, 
    [intAccountId] INT NULL, 
    [intFreightTermId] INT NULL, 
    [intCurrencyId] INT NOT NULL, 
	[intContactId] INT NULL, 
    [intOrderById] INT NOT NULL, 
    [intApprovedById] INT NULL, 
    [intShipViaId] INT NULL, 
    [intShipFromId] INT NULL, 
    [intShipToId] INT NULL, 
	[intLocationId] INT NULL, 
    [intStoreId] INT NULL, 
	[intEntityId] INT NOT NULL,
	[intTermsId] INT NOT NULL,
	[intContractHeaderId] INT NULL,
	[intTransactionType] INT NOT NULL DEFAULT 5,
	[dblTotal] NUMERIC(18, 6) NOT NULL DEFAULT 0,
	[dblSubtotal] NUMERIC(18, 6) NOT NULL DEFAULT 0,
	[dblShipping] NUMERIC(18, 6) NOT NULL DEFAULT 0,
	[dblTax] NUMERIC(18, 6) NOT NULL DEFAULT 0,
	[dblExchangeRate] NUMERIC(18, 6) NOT NULL DEFAULT 0,
	[intOrderStatusId] INT NOT NULL, 
	[strApprovalNotes]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [strPurchaseOrderNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strVendorOrderNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strAdditionalInfo] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
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
	[strReference] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [dtmExpectedDate] DATETIME NOT NULL DEFAULT GETDATE(),
	[dtmApprovalDate]       DATETIME        NULL ,
	[ysnPrepaid] BIT NOT NULL DEFAULT 0,
	[ysnApproved] BIT NOT NULL DEFAULT 0,
	[ysnForApproval] BIT NOT NULL DEFAULT 0,
	[ysnForApprovalSubmitted] BIT NOT NULL DEFAULT 0 ,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dtmDateCreated] DATETIME NULL DEFAULT GETDATE(), 
    CONSTRAINT [UK_dbo.tblPOPurchase_strPurchaseOrderNumber] UNIQUE (strPurchaseOrderNumber),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblPOOrderStatus_intOrderStatusId] FOREIGN KEY (intOrderStatusId) REFERENCES tblPOOrderStatus(intOrderStatusId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblSMCompanyLocation_intShipToId] FOREIGN KEY (intShipToId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblEMEntityLocation_intShipFromId] FOREIGN KEY (intShipFromId) REFERENCES [tblEMEntityLocation](intEntityLocationId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblSMShipVia_intShipViaId] FOREIGN KEY (intShipViaId) REFERENCES tblSMShipVia(intEntityShipViaId),
	--CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblEMEntityContact_intContactId] FOREIGN KEY (intContactId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblAPVendor_intVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES tblAPVendor (intEntityVendorId)
);
GO
CREATE NONCLUSTERED INDEX [IX_tblPOPurchase_intPurchaseId]
    ON [dbo].[tblPOPurchase]([intPurchaseId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblPOPurchase_strPurchaseOrderNumber]
    ON [dbo].[tblPOPurchase]([strPurchaseOrderNumber] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblPOPurchase_intVendorId]
    ON [dbo].[tblPOPurchase]([intEntityVendorId] ASC)
	INCLUDE ([intPurchaseId],[strVendorOrderNumber]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
