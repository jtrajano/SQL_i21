CREATE TABLE [dbo].[tblEMFuturesBroker]
(
	[intEntityId] INT NOT NULL PRIMARY KEY, 
    [intVendorNumber] INT NOT NULL,
	[strShortName] NVARCHAR(50) NOT NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblEMFuturesBroker_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblFuturesBroker_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]),
	CONSTRAINT [UQ_tblEMFuturesBroker_intVendorNumber] UNIQUE NONCLUSTERED ([intVendorNumber] ASC)
	
)
