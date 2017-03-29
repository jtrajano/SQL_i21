CREATE TABLE [dbo].[tblARCustomerProductVersion] (
    [intCustomerProductVersionId] INT IDENTITY (1, 1) NOT NULL,
    [intCustomerId]               INT NOT NULL,
    [intProductId]                INT NOT NULL,
    [intVersionId]                INT NOT NULL,
	[intModuleId]                 INT NULL,
	[strCompany]				  NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strName]					NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strOperatingSystem]		NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strAcuVersion]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strDatabase]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strServPak]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strApplyDt]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
	[strInfoPulled]				NVARCHAR(50)  COLLATE Latin1_General_CI_AS,
    [intConcurrencyId]            INT CONSTRAINT [DF_tblARCustomerProductVersion_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomerProductVersion] PRIMARY KEY CLUSTERED ([intCustomerProductVersionId] ASC),
	CONSTRAINT [FK_tblARCustomerProductVersion_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
);

