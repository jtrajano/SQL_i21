CREATE TABLE [dbo].[tblCTDiscount]
(
	[Value] INT NOT NULL, 
    [Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTDiscount_Value] PRIMARY KEY ([Value]) 
)
