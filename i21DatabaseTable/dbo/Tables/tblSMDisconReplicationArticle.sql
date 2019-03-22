CREATE TABLE [dbo].[tblSMDisconReplicationArticle]
(
	[intReplicationArticleId] INT IDENTITY (1, 1) PRIMARY KEY NOT NULL, 
    [strTableName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT DEFAULT (1) NOT NULL

)
