CREATE TABLE [dbo].[tblMBMeterReading]
(
	[intMeterReadingId] INT NOT NULL IDENTITY, 
    [strTransactionId] NVARCHAR(50) NOT NULL, 
    [intEntityCustomerId] INT NOT NULL, 
    [intEntityLocationId] INT NOT NULL, 
    [dtmTransaction] DATETIME NOT NULL DEFAULT (GETDATE()), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterReading] PRIMARY KEY ([intMeterReadingId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]), 
    CONSTRAINT [AK_tblMBMeterReading_strTransactionId] UNIQUE ([strTransactionId]) 
)
