CREATE TABLE [dbo].[tblARBundle]
(
	[intBundleId]			INT NOT NULL  IDENTITY,
	[strBundleName]         NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intProductTypeId]		INT NULL, 
    [ysnSeparate]			BIT NULL, 
    [intConcurrencyId]		INT NULL, 
	CONSTRAINT [PK_tblARBundle_intBundleId] PRIMARY KEY CLUSTERED ([intBundleId] ASC),
    CONSTRAINT [FK_tblARBundle_tblARProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblARProductType]([intProductTypeId])
)
