CREATE TABLE [dbo].[tblSMPurchasingGroup]
(
	[intPurchasingGroupId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strName] NVARCHAR(150) NOT NULL, 
    [strDescription] NVARCHAR(150) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [AK_tblSMPurchasingGroup_strName] UNIQUE ([strName])
)
