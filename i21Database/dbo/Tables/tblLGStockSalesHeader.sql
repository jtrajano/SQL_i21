CREATE TABLE [dbo].[tblLGStockSalesHeader]
(
	[intStockSalesHeaderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
    [intReferenceNumber] INT NOT NULL, 
	[dtmTransDate] DATETIME NOT NULL,
	[intCustomerEntityId] INT NOT NULL,
    [intCompanyLocationId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
	[intSubLocationId] INT NULL,
	[intWeightUnitMeasureId] INT NOT NULL,
	[dtmCreatedDate] DATETIME NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
	[intContractHeaderId] INT NULL,
	[intAllocationHeaderId] INT NULL,
	[intPickLotHeaderId] INT NULL,

    CONSTRAINT [PK_tblLGStockSalesHeader_intStockSalesHeaderId] PRIMARY KEY ([intStockSalesHeaderId]), 
	CONSTRAINT [UK_tblLGStockSalesHeader_intReferenceNumber] UNIQUE ([intReferenceNumber]),
	CONSTRAINT [FK_tblLGStockSalesHeader_tblEntity_intCustomerEntityId_intEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES [tblEntity]([intEntityId]),
    CONSTRAINT [FK_tblLGStockSalesHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblLGStockSalesHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblLGStockSalesHeader_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGStockSalesHeader_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblLGStockSalesHeader_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]),
	CONSTRAINT [FK_tblLGStockSalesHeader_tblLGAllocationHeader_intAllocationHeaderId] FOREIGN KEY ([intAllocationHeaderId]) REFERENCES [tblLGAllocationHeader]([intAllocationHeaderId]),
	CONSTRAINT [FK_tblLGStockSalesHeader_tblLGPickLotHeader_intPickLotHeaderId] FOREIGN KEY ([intPickLotHeaderId]) REFERENCES [tblLGPickLotHeader]([intPickLotHeaderId]),
    CONSTRAINT [FK_tblLGStockSalesHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID])
)
