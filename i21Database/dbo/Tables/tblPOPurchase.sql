CREATE TABLE [dbo].[tblPOPurchase]
(
	[intPurchaseId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intVendorId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
    [intFreightId] INT NULL, 
    [intCurrencyId] INT NOT NULL, 
    [intOrderById] INT NOT NULL, 
    [intApprovedById] INT NULL, 
    [intShipViaId] INT NULL, 
    [intShipFromId] INT NULL, 
    [intShipToId] INT NULL, 
	[intLocationId] INT NULL, 
    [intStoreId] INT NULL, 
	[intEntityId] INT NOT NULL,
	[intTermsId] INT NOT NULL,
	[intTransactionType] INT NOT NULL DEFAULT 5,
	[dblTotal] DECIMAL NOT NULL DEFAULT 0,
	[dblSubtotal] DECIMAL NOT NULL DEFAULT 0,
	[dblShipping] DECIMAL NOT NULL DEFAULT 0,
	[dblTax] DECIMAL NOT NULL DEFAULT 0,
	[dblExchangeRate] DECIMAL NOT NULL DEFAULT 0,
	[intOrderStatusId] INT NOT NULL, 
    [strPurchaseOrderNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strVendorOrderNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAttention] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToAddress] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCity] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToState] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToZipCode] NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToCountry] NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipToPhone] NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL,
	[strShipFromAttention] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromAddress] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCity] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromState] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromZipCode] NVARCHAR (12) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromCountry] NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strShipFromPhone] NVARCHAR (25) COLLATE Latin1_General_CI_AS NULL, 
	[strReference] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [dtmExpectedDate] DATETIME NOT NULL DEFAULT GETDATE(),
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [UK_dbo.tblPOPurchase_strPurchaseOrderNumber] UNIQUE (strPurchaseOrderNumber),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblPOOrderStatus_intOrderStatusId] FOREIGN KEY (intOrderStatusId) REFERENCES tblPOOrderStatus(intOrderStatusId),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES tblEntity(intEntityId)
);
GO
CREATE NONCLUSTERED INDEX [IX_tblPOPurchase_intPurchaseId]
    ON [dbo].[tblPOPurchase]([intPurchaseId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblPOPurchase_strPurchaseOrderNumber]
    ON [dbo].[tblPOPurchase]([strPurchaseOrderNumber] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblPOPurchase_intVendorId]
    ON [dbo].[tblPOPurchase]([intVendorId] ASC)
	INCLUDE ([intPurchaseId],[strVendorOrderNumber]) WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
