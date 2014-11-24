﻿CREATE TABLE [dbo].[tblPOPurchase]
(
	[intPurchaseId] INT NOT NULL PRIMARY KEY, 
    [intVendorId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
    [intFreightId] INT NULL, 
    [intCurrencyId] INT NOT NULL, 
    [intTermId] INT NOT NULL, 
    [intOrderById] INT NOT NULL, 
    [intApprovedById] INT NULL, 
    [intShipViaId] INT NULL, 
    [intShipFromId] INT NULL, 
    [intShipToId] INT NULL, 
    [intStoreId] INT NULL, 
	[intOrderStatusId] INT NOT NULL, 
    [strPurchaseOrderNumber] NVARCHAR(100) NULL, 
	[strVendorOrderNumber] NVARCHAR(100) NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [dtmExpectedDate] DATETIME NOT NULL DEFAULT GETDATE(),
	CONSTRAINT [UK_dbo.tblPOPurchase_strPurchaseOrderNumber] UNIQUE (strPurchaseOrderNumber),
	CONSTRAINT [FK_dbo.tblPOPurchase_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
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
