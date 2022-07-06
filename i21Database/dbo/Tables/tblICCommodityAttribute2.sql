CREATE TABLE [dbo].[tblICCommodityAttribute2]
(
	[intCommodityAttributeId2] INT NOT NULL IDENTITY,
	[intCommodityId] INT NOT NULL , 
	[strAttribute2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	CONSTRAINT [PK_tblICCommodityAttribute2] PRIMARY KEY ([intCommodityAttributeId2]), 
)
