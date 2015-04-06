CREATE TABLE [dbo].[tblRKFuturesBroker]
(
	[intEntityId] INT NOT NULL PRIMARY KEY, 
    [intVendorNumber] INT NOT NULL,
	[strShortName] NVARCHAR(50) NOT NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblRKFuturesBroker_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblRKFuturesBroker_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]),
	CONSTRAINT [UQ_tblRKFuturesBroker_intVendorNumber] UNIQUE NONCLUSTERED ([intVendorNumber] ASC)
	
)
