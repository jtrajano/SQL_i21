CREATE TABLE [dbo].[tblRKVendorPriceFixationLimit]
(
	[intVendorPriceFixationLimitId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[strRiskIndicator] nvarchar(20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dblCompanyExposurePercentage] NUMERIC(18, 6) NOT NULL, 
	[dblSupplierSalesPercentage] NUMERIC(18, 6) NOT NULL,  
	[strPriceFixationLimit] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL,

   	CONSTRAINT [PK_tblRKVendorPriceFixationLimit_intVendorPriceFixationLimitId] PRIMARY KEY ([intVendorPriceFixationLimitId]), 
)

