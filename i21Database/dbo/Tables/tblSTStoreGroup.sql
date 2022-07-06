CREATE TABLE [dbo].[tblSTStoreGroup]
(
	[intStoreGroupId] INT NOT NULL IDENTITY, 
    [strStoreGroupName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strStoreGroupDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_intStoreGroupId] PRIMARY KEY CLUSTERED ([intStoreGroupId] ASC),
    CONSTRAINT [AK_tblSTStoreGroup_strStoreGroupName] UNIQUE NONCLUSTERED ([strStoreGroupName] ASC)
);