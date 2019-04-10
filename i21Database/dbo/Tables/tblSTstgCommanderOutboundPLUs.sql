CREATE TABLE [dbo].[tblSTstgCommanderOutboundPLUs]
(
	[intCommanderOutboundPLUsId] INT NOT NULL IDENTITY, 
	[strSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strUpc] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strUpcModifier] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strDepartment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strFee] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblPrice] DECIMAL(18, 6) NULL,
	[intFlagSysid] INT NULL, 
	[intTaxRateSysid] INT NULL, 
	[dblSellUnit] DECIMAL(18, 6) NULL
 );