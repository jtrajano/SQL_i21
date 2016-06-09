CREATE TABLE [dbo].[tblMFMarginBy]
(
	[intMarginById] INT NOT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblMFMarginBy_intMarginById] PRIMARY KEY ([intMarginById]), 
    CONSTRAINT [UQ_tblMFMarginBy_strName] UNIQUE ([strName]) 
)
