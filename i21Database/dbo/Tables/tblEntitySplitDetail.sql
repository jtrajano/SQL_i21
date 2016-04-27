CREATE TABLE [dbo].[tblEntitySplitDetail]
(
	[intSplitDetailId]					INT             IDENTITY (1, 1) NOT NULL,
    [intSplitId]						INT             NOT NULL,
    [intEntityId]						INT             NULL,
    [dblSplitPercent]					NUMERIC (18, 6) NULL,
    [strOption]							NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[intStorageScheduleTypeId]			INT		NULL ,
    [intConcurrencyId]					INT             NOT NULL,
    CONSTRAINT [PK_tblEntitySplitDetail] PRIMARY KEY CLUSTERED ([intSplitDetailId] ASC),	
	CONSTRAINT [FK_tblEntitySplitDetail_tblEntity] FOREIGN KEY([intEntityId]) REFERENCES [dbo].[tblEntity]([intEntityId]), 
	CONSTRAINT [FK_tblEntitySplitDetail_tblEntitySplit] FOREIGN KEY([intSplitId]) REFERENCES [dbo].[tblEntitySplit]([intSplitId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEntitySplitDetail_tblGRStorageType] FOREIGN KEY([intStorageScheduleTypeId]) REFERENCES [dbo].[tblGRStorageType]([intStorageScheduleTypeId]), 
)
