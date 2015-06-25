CREATE TABLE [dbo].[tblRKElectronicPricingValue] 
(
	 [intElectronicPricingValueId] INT NOT NULL IDENTITY
	,[dblHigh] NUMERIC(18, 6) NULL
	,[dblLow]  NUMERIC(18, 6) NULL
	,[dblOpen] NUMERIC(18, 6) NULL
	,[dblLast] NUMERIC(18, 6) NULL
	,[strURL] NVARCHAR(Max) COLLATE Latin1_General_CI_AS NULL 
	,CONSTRAINT [PK_tblRKElectronicPricingValue_intElectronicPricingValueId] PRIMARY KEY ([intElectronicPricingValueId])
)