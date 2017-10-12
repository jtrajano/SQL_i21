﻿CREATE TABLE [dbo].[tblSMCompanyLocationSubLocation]
(
	[intCompanyLocationSubLocationId] INT NOT NULL IDENTITY , 
	[intCompanyLocationId] INT NOT NULL, 
    [strSubLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubLocationDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intVendorId] INT NULL,
    [strClassification] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnExternal] BIT NULL DEFAULT (0),
	[ysnLicensed] BIT NOT NULL DEFAULT (0),
	[intNewLotBin] INT NULL, 
    [intAuditBin] INT NULL, 
    --[strAddressKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strAddress] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intCountryId] INT NULL,
	[dblLatitude] NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLongitude] NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMCompanyLocationSubLocation] PRIMARY KEY ([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblSMCompanyLocationSubLocation_tblSMCompanyLocation] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblSMCompanyLocationSubLocation_tblEMEntity] FOREIGN KEY ([intVendorId]) REFERENCES tblEMEntity([intEntityId])
)
GO 

	CREATE NONCLUSTERED INDEX [IX_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId]
	ON [dbo].[tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId] ASC)
	INCLUDE ([strSubLocationName], [intCompanyLocationId]); 

GO 