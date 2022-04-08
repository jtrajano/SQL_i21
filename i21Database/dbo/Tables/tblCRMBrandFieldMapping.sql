CREATE TABLE [dbo].[tblCRMBrandFieldMapping]
(
	[intBrandFieldMappingId]	 INT IDENTITY(1,1) NOT NULL,
	[intBrandId]				 INT			   NOT NULL,
	[strBrandFieldName]			 NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strI21FieldName]			 NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strComment]				 NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int]	 NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMBrandFieldMapping_intBrandFieldMappingId] PRIMARY KEY CLUSTERED ([intBrandFieldMappingId] ASC),
	CONSTRAINT [UQ_tblCRMBrandFieldMapping_intBrandId_strBrandFieldName] UNIQUE ([intBrandId], [strBrandFieldName]),
    CONSTRAINT [FK_tblCRMBrandFieldMapping_tblCRMBrand_intBrandId] FOREIGN KEY ([intBrandId]) REFERENCES [dbo].[tblCRMBrand] ([intBrandId]) ON DELETE CASCADE
)
