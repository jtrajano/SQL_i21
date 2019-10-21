CREATE TABLE [dbo].[tblEMEntitySplitDetail]
(
	[intSplitDetailId]					INT             IDENTITY (1, 1) NOT NULL,
    [intSplitId]						INT             NOT NULL,
    [intEntityId]						INT             NULL,
    [dblSplitPercent]					NUMERIC (18, 6) NULL,
    [strOption]							NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[intStorageScheduleTypeId]			INT		NULL ,
    [intConcurrencyId]					INT             NOT NULL,
    CONSTRAINT [PK_tblEMEntitySplitDetail] PRIMARY KEY CLUSTERED ([intSplitDetailId] ASC),	
	CONSTRAINT [FK_tblEMEntitySplitDetail_tblEMEntity] FOREIGN KEY([intEntityId]) REFERENCES [dbo].tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblEMEntitySplitDetail_tblEMEntitySplit] FOREIGN KEY([intSplitId]) REFERENCES [dbo].[tblEMEntitySplit]([intSplitId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMEntitySplitDetail_tblGRStorageType] FOREIGN KEY([intStorageScheduleTypeId]) REFERENCES [dbo].[tblGRStorageType]([intStorageScheduleTypeId]), 
)
