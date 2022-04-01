CREATE TABLE [dbo].[tblQMPriorityGroupDetail]
(
	[intPriorityGroupDetailId]	INT NOT NULL IDENTITY,
	[intPriorityGroupId]		INT NOT NULL,
	[intProductTypeId]			INT NULL,
	[intOriginId]				INT NULL,
	[intExtensionId]			INT NULL,
	[intItemId]					INT NULL,
	[intSortId]					INT NOT NULL,
	[intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblQMPriorityGroupDetail_intPriorityGroupDetailId] PRIMARY KEY CLUSTERED ([intPriorityGroupDetailId] ASC),
	CONSTRAINT [FK_tblQMPriorityGroupDetail_tblQMPriorityGroup] FOREIGN KEY ([intPriorityGroupId]) REFERENCES [tblQMPriorityGroup] ([intPriorityGroupId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblQMPriorityGroupDetail_tblICCommodityAttribute_intProductTypeId] FOREIGN KEY ([intProductTypeId]) REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId]),
	CONSTRAINT [FK_tblQMPriorityGroupDetail_tblICCommodityAttribute_intOriginId] FOREIGN KEY ([intOriginId]) REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId]),
	CONSTRAINT [FK_tblQMPriorityGroupDetail_tblICCommodityAttribute_intExtensionId] FOREIGN KEY ([intExtensionId]) REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId]),
	CONSTRAINT [FK_tblQMPriorityGroupDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])
);