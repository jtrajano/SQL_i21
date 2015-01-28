CREATE TABLE [dbo].[tblSMCompanyLocationSubLocation]
(
	[intCompanyLocationSubLocationId] INT NOT NULL IDENTITY , 
	[intCompanyLocationId] INT NOT NULL, 
    [strSubLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubLocationDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strClassification] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intNewLotBin] INT NULL, 
    [intAuditBin] INT NULL, 
    [strAddressKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMCompanyLocationSubLocation] PRIMARY KEY ([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblSMCompanyLocationSubLocation_tblSMCompanyLocation] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMCompanyLocationSubLocation_tblICStorageLocation_new] FOREIGN KEY (intNewLotBin) REFERENCES tblICStorageLocation(intStorageLocationId),
	CONSTRAINT [FK_tblSMCompanyLocationSubLocation_tblICStorageLocation_audit] FOREIGN KEY (intAuditBin) REFERENCES tblICStorageLocation(intStorageLocationId)
)
