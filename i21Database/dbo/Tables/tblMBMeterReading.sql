CREATE TABLE [dbo].[tblMBMeterReading]
(
	[intMeterReadingId] INT NOT NULL IDENTITY, 
    [strTransactionId] NVARCHAR(50) NOT NULL, 
    [intEntityCustomerId] INT NOT NULL, 
    [intEntityLocationId] INT NOT NULL, 
    [dtmTransaction] DATETIME NOT NULL DEFAULT (GETDATE()), 
	[ysnPosted] BIT NULL DEFAULT((0)),
	[dtmPostedDate] DATETIME NULL,
	[intEntityId] INT NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterReading] PRIMARY KEY ([intMeterReadingId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]), 
    CONSTRAINT [AK_tblMBMeterReading_strTransactionId] UNIQUE ([strTransactionId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblSMUserSecurity] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]) 
)
