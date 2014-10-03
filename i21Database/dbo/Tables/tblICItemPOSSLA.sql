CREATE TABLE [dbo].[tblICItemPOSSLA]
(
	[intItemPOSSLAId] INT NOT NULL IDENTITY , 
    [intItemId] INT NOT NULL, 
    [strSLAContract] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [dblContractPrice] NUMERIC(18, 6) NULL, 
    [ysnServiceWarranty] BIT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemPOSSLA] PRIMARY KEY ([intItemPOSSLAId]), 
    CONSTRAINT [FK_tblICItemPOSSLA_tblICItemPOS] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
