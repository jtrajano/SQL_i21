CREATE TABLE [dbo].[tblSMGlobalSearchTag]
(
	[intGSTagId] INT Identity(1,1) NOT NULL ,
	[intGSIndexId] INT NOT NULL,
	[strColumnField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strColumnData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblSMGlobalSearchTag] Primary key clustered (intGSTagId ASC),
	CONSTRAINT [FK_tblSMGlobalSearchTag_tblSMGlobalSearch_intGSIndexId] FOREIGN KEY ([intGSIndexId]) REFERENCES [tblSMGlobalSearch]([intGSIndexId])
)
