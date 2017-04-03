CREATE TABLE [dbo].[tblLGAllocationHeader]
(
	[intAllocationHeaderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
    [strAllocationNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dtmTransDate] DATETIME NOT NULL,
    [intCompanyLocationId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
    [intUserSecurityId] INT NOT NULL, 	
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	[intWeightUnitMeasureId] INT NULL,

    CONSTRAINT [PK_tblLGAllocationHeader_intAllocationHeaderId] PRIMARY KEY ([intAllocationHeaderId]), 
	CONSTRAINT [UK_tblLGAllocationHeader_intReferenceNumber] UNIQUE ([strAllocationNumber]),
    CONSTRAINT [FK_tblLGAllocationHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblLGAllocationHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
    CONSTRAINT [FK_tblLGAllocationHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
	CONSTRAINT [FK_tblLGAllocationHeader_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)
