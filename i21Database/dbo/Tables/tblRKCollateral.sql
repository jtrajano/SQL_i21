CREATE TABLE [dbo].[tblRKCollateral]
(
	[intCollateralId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL, 
    [intReceiptNo]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmOpenDate] DATETIME  NOT NULL, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCommodityId] INT NOT NULL, 
	[intLocationId] INT NOT NULL, 
	[strCustomer] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dblOriginalQuantity] numeric(18,6) NOT NULL,
	[dblRemainingQuantity] numeric(18,6) NOT NULL,
	[intUnitMeasureId] INT NOT NULL,
	[intContractHeaderId] INT NULL, 
    [intTransNo] INT NOT NULL,
	[strComments] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL 

    CONSTRAINT [PK_tblRKCollateral_intCollateralId] PRIMARY KEY ([intCollateralId]),
    CONSTRAINT [FK_tblRKCollateral_tblCTContractHeader_intContractHeaderId] FOREIGN KEY([intContractHeaderId])REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblRKCollateral_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblRKCollateral_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblRKCollateral_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY([intUnitMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
)
