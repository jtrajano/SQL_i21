CREATE TABLE [dbo].[tblICCommodityAttribute3]
(
	[intCommodityAttributeId3] INT NOT NULL IDENTITY,
	[intCommodityId] INT NOT NULL , 
	[strAttribute3] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	CONSTRAINT [PK_tblICCommodityAttribute3] PRIMARY KEY ([intCommodityAttributeId3]), 
)
