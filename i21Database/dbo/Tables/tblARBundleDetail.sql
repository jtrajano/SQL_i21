CREATE TABLE [dbo].[tblARBundleDetail]
(
	[intBundleDetailId]		INT NOT NULL  IDENTITY,
	[intBundleId]			INT NOT NULL, 
    [intItemId]				INT NULL, 
    [intConcurrencyId]		INT NOT NULL, 
    CONSTRAINT [PK_tblARBundleDetail_intBundleDetailId] PRIMARY KEY CLUSTERED ([intBundleDetailId] ASC),
	CONSTRAINT [FK_tblARBundleDetail_tblARBundle] FOREIGN KEY ([intBundleId]) REFERENCES [dbo].[tblARBundle]([intBundleId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARBundleDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem]([intItemId])
)
