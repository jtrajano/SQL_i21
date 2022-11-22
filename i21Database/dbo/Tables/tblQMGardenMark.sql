CREATE TABLE [dbo].[tblQMGardenMark]
(
	[intGardenMarkId] 		    INT IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] 			INT NULL DEFAULT ((1)),
    [strGardenMark] 	        NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intOriginId]				INT NULL,
	[intCountryId]				INT NULL,
	[intProducerId]				INT NULL,
	[intProductLineId]			INT NULL,
    [dtmCertifiedDate] 			DATETIME NULL,
	[dtmExpiryDate] 			DATETIME NULL,
	CONSTRAINT [PK_tblQMGardenMark_intGardenMarkId] PRIMARY KEY CLUSTERED ([intGardenMarkId] ASC),
	CONSTRAINT [UK_tblQMGardenMark_strGardenMark] UNIQUE (strGardenMark),
	CONSTRAINT [FK_tblQMGardenMark_tblICCommodityAttribute_intOriginId] FOREIGN KEY ([intOriginId]) REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId]),
	CONSTRAINT [FK_tblQMGardenMark_tblSMCountry_intCountryId] FOREIGN KEY ([intCountryId]) REFERENCES [dbo].[tblSMCountry] ([intCountryID]),
	CONSTRAINT [FK_tblQMGardenMark_tblEMEntity_intProducerId] FOREIGN KEY ([intProducerId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblQMGardenMark_tblICCommodityProductLine_intProductLineId] FOREIGN KEY ([intProductLineId]) REFERENCES [dbo].[tblICCommodityProductLine] ([intCommodityProductLineId])
);