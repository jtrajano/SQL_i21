CREATE TABLE [dbo].[tblMBFuelPointPriceChange]
(
	[intFuelPointPriceChangeId] INT NOT NULL IDENTITY, 
    [intEntityCustomerId] INT NOT NULL, 
    [intEntityLocationId] INT NOT NULL, 
    [dtmDate] DATETIME NULL DEFAULT (GETDATE()), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBFuelPointPriceChange] PRIMARY KEY ([intFuelPointPriceChangeId]), 
    CONSTRAINT [FK_tblMBFuelPointPriceChange_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityId]), 
    CONSTRAINT [FK_tblMBFuelPointPriceChange_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]) 
)
