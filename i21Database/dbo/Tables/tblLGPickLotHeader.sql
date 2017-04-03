CREATE TABLE [dbo].[tblLGPickLotHeader]
(
	[intPickLotHeaderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
    [strPickLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dtmPickDate] DATETIME NOT NULL,
	[intCustomerEntityId] INT NOT NULL,
    [intCompanyLocationId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
	[intSubLocationId] INT NOT NULL,
	[intWeightUnitMeasureId] INT NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
	[intDeliveryHeaderId] INT NULL,

    CONSTRAINT [PK_tblLGPickLotHeader_intPickLotHeaderId] PRIMARY KEY ([intPickLotHeaderId]), 
	CONSTRAINT [UK_tblLGPickLotHeader_intReferenceNumber] UNIQUE ([strPickLotNumber]),
	CONSTRAINT [FK_tblLGPickLotHeader_tblEMEntity_intCustomerEntityId_intEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES tblEMEntity([intEntityId]),
    CONSTRAINT [FK_tblLGPickLotHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblLGPickLotHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblLGPickLotHeader_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGPickLotHeader_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGPickLotHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)
