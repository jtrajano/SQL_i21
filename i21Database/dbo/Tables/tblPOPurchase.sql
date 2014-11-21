CREATE TABLE [dbo].[tblPOPurchase]
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
    [strPONumber] NVARCHAR(100) NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [dtmExpectedDate] DATETIME NOT NULL DEFAULT GETDATE()
)
