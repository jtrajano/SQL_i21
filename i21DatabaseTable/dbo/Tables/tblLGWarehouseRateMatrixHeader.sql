CREATE TABLE [dbo].[tblLGWarehouseRateMatrixHeader]
(
	[intWarehouseRateMatrixHeaderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
    [strServiceContractNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dtmContractDate] DATETIME NOT NULL,
    [intCompanyLocationId] INT NOT NULL, 
	[intCommodityId] INT NOT NULL, 
	[intCompanyLocationSubLocationId] INT NOT NULL,
	[intVendorEntityId] INT NULL,
	[dtmValidityFrom] DATETIME NOT NULL,
	[dtmValidityTo] DATETIME NOT NULL,
	[ysnActive] [bit] NOT NULL,
	[intCurrencyId] INT NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 

    CONSTRAINT [PK_tblLGWarehouseRateMatrixHeader_intWarehouseRateMatrixHeaderId] PRIMARY KEY ([intWarehouseRateMatrixHeaderId]), 
	CONSTRAINT [UK_tblLGWarehouseRateMatrixHeader_strServiceContractNo] UNIQUE ([strServiceContractNo]),
    CONSTRAINT [FK_tblLGWarehouseRateMatrixHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblLGWarehouseRateMatrixHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblLGWarehouseRateMatrixHeader_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGWarehouseRateMatrixHeader_tblEMEntity_intVendorEntityId_intEntityId] FOREIGN KEY ([intVendorEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGWarehouseRateMatrixHeader_tblSMCurrency_intCurrencyID] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
    CONSTRAINT [FK_tblLGWarehouseRateMatrixHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)
