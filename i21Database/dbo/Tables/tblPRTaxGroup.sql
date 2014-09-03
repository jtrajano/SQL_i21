CREATE TABLE [dbo].[tblPRTaxGroup](
	[intTaxGroupId] [int] IdENTITY(1,1) NOT NULL,
	[strTaxGroup] [nvarchar](15) NOT NULL,
	[strDescription] [nvarchar](50) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTaxGroup] PRIMARY KEY ([strTaxGroup])
) ON [PRIMARY]
GO