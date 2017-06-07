CREATE TABLE [dbo].[tblSMTaxXRef](
	[intTaxXRefId] [int] IDENTITY(1,1) NOT NULL,
	[strOrgItemNo] [char](13) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOrgState] [char](2) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOrgLocal1] [char](3) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOrgLocal2] [char](3) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOrgTaxType] [char](3) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOrgCalcMethod] [char](1) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [decimal](9, 6) NULL,
	[intTaxGroupId] [int] NULL,
	[strOrgItemClass] [char](3) COLLATE Latin1_General_CI_AS NULL,
	[intCategoryId] [int] NULL,
	[strCategoryCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTaxClassId] [int] NULL,
	[strTaxClass] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intTaxCodeId] [int] NULL,
	[strTaxCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[intTaxXRefId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

