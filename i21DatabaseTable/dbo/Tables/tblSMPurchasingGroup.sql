CREATE TABLE [dbo].[tblSMPurchasingGroup]
(
	[intPurchasingGroupId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [AK_tblSMPurchasingGroup_strName] UNIQUE ([strName])
)
