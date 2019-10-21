CREATE TABLE [dbo].[tblLGDeliveryHeader]
(
	[intDeliveryHeaderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
    [intReferenceNumber] INT NOT NULL, 
	[dtmDeliveryOrderDate] DATETIME NOT NULL,
	[dtmDeliveryDate] DATETIME NOT NULL,
	[intCustomerEntityId] INT NOT NULL,
    [intCompanyLocationId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
	[intSubLocationId] INT NOT NULL,
	[dtmFreeTime] DATETIME NULL,
	[dtmDeliveredDate] DATETIME NULL,
	[intTruckerEntityId] INT NULL,
	[intWeightUnitMeasureId] INT NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	
    CONSTRAINT [PK_tblLGDeliveryHeader_intDeliveryHeaderId] PRIMARY KEY ([intDeliveryHeaderId]), 
	CONSTRAINT [UK_tblLGDeliveryHeader_intReferenceNumber] UNIQUE ([intReferenceNumber]),
	CONSTRAINT [FK_tblLGDeliveryHeader_tblEMEntity_intCustomerEntityId_intEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES tblEMEntity([intEntityId]),
    CONSTRAINT [FK_tblLGDeliveryHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblLGDeliveryHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblLGDeliveryHeader_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGDeliveryHeader_tblEMEntity_intTruckerEntityId] FOREIGN KEY ([intTruckerEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGDeliveryHeader_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGDeliveryHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)
