﻿CREATE TABLE [dbo].[tblSMCompanyLocationSubLocation]
(
	[intCompanyLocationSubLocationId] INT NOT NULL IDENTITY , 
	[intCompanyLocationId] INT NOT NULL, 
    [strSubLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubLocationDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strClassification] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnExternal] BIT NULL DEFAULT (0),
	[intNewLotBin] INT NULL, 
    [intAuditBin] INT NULL, 
    --[strAddressKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strAddress] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblLatitude] NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLongitude] NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMCompanyLocationSubLocation] PRIMARY KEY ([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblSMCompanyLocationSubLocation_tblSMCompanyLocation] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId) ON DELETE CASCADE 
)