CREATE TABLE [dbo].[tblMBFuelPointReading]
(
	[intFuelPointReadingId] INT NOT NULL IDENTITY, 
    [intEntityCustomerId] INT NOT NULL, 
    [intEntityLocationId] INT NOT NULL, 
    [dtmDateFrom] DATETIME NULL DEFAULT (GETDATE()), 
    [dtmDateTo] DATETIME NULL DEFAULT (GETDATE()), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBFuelPointReading] PRIMARY KEY ([intFuelPointReadingId]), 
    CONSTRAINT [FK_tblMBFuelPointReading_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]), 
    CONSTRAINT [FK_tblMBFuelPointReading_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]) 
)
