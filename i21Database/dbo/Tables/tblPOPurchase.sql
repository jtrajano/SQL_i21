CREATE TABLE [dbo].[tblPOPurchase]
(
	[intPurchaseId] INT NOT NULL PRIMARY KEY, 
    [intVendorId] INT NOT NULL, 
    [intAccountId] INT NOT NULL, 
    [intFreightId] INT NOT NULL, 
    [intCurrencyId] INT NOT NULL, 
    [intTermId] INT NOT NULL, 
    [intOrderById] INT NOT NULL, 
    [intApprovedById] INT NOT NULL, 
    [intShipViaId] INT NOT NULL, 
    [intShipFromId] INT NOT NULL, 
    [intShipToId] INT NOT NULL, 
    [intStoreId] INT NULL, 
    [strOrderNumber] NVARCHAR(100) NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT GETDATE(), 
    [dtmExpectedDate] DATETIME NOT NULL DEFAULT GETDATE()
)
