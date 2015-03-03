CREATE TABLE [dbo].[tblEMFuturesBroker]
(
	[intEntityId] INT NOT NULL PRIMARY KEY, 
    [strVendorId] NVARCHAR(50) NOT NULL,
	[intContactId] INT NOT NULL, 
    CONSTRAINT [FK_tblEMFutureBroker_tblEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [tblEntityContact]([intContactId]),
	CONSTRAINT [UQ_tblEMFuturesBroker_strVendorId] UNIQUE NONCLUSTERED ([strVendorId] ASC)
	
)
