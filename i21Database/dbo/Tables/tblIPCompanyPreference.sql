CREATE TABLE [dbo].[tblIPCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[strCommonDataFolderPath] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	strCustomerCode nvarchar(50),
	ysnReplicationEnabled BIT CONSTRAINT [DF_ttblIPCompanyPreference_ysnReplicationEnabled] DEFAULT 1, 
	intThirdPartyContractWaitingPeriod int,
	ysnDestinationPortMandatoryInPOExport BIT,
	strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strDefaultCurrency NVARCHAR(40) COLLATE Latin1_General_CI_AS,
	strVendorInvoiceFilePath NVARCHAR(500) COLLATE Latin1_General_CI_AS,
	intFinancingCostItemId int,
	intFreightCostItemId int,
	intMiscItemId int,
	intWeightAdjItemId int,
	CONSTRAINT [PK_tblIPCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]) 
)
