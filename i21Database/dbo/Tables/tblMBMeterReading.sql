CREATE TABLE [dbo].[tblMBMeterReading]
(
	[intMeterReadingId] INT NOT NULL IDENTITY, 
    [strTransactionId] NVARCHAR(50) NOT NULL, 
	[intMeterAccountId] INT NOT NULL,
    [dtmTransaction] DATETIME NOT NULL DEFAULT (GETDATE()), 
	[ysnPosted] BIT NULL DEFAULT((0)),
	[dtmPostedDate] DATETIME NULL,
	[intEntityId] INT NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterReading] PRIMARY KEY ([intMeterReadingId]), 
    CONSTRAINT [AK_tblMBMeterReading_strTransactionId] UNIQUE ([strTransactionId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblSMUserSecurity] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]), 
    CONSTRAINT [FK_tblMBMeterReading_tblMBMeterAccount] FOREIGN KEY ([intMeterAccountId]) REFERENCES [tblMBMeterAccount]([intMeterAccountId]) 
)
