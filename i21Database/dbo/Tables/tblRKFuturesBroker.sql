﻿CREATE TABLE [dbo].[tblRKFuturesBroker]
(
	[intEntityId] INT NOT NULL PRIMARY KEY, 
    [intVendorNumber] INT NOT NULL,
	[strShortName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblRKFuturesBroker_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblRKFuturesBroker_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [UQ_tblRKFuturesBroker_intVendorNumber] UNIQUE NONCLUSTERED ([intVendorNumber] ASC)
	
)
