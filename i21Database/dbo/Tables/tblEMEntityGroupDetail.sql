CREATE TABLE [dbo].[tblEMEntityGroupDetail]
(
	[intEntityGroupDetailId]        INT				IDENTITY (1, 1) NOT NULL,
	[intEntityGroupId]				INT             NOT NULL,
    [intEntityId]					INT             NULL,        
	[intConcurrencyId]				INT             CONSTRAINT [DF__tmp_tblEntityGroupDetail__intEntityGroupDetailId__5132705A] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityGroupDetail] PRIMARY KEY CLUSTERED ([intEntityGroupDetailId] ASC),	
	CONSTRAINT [FK_tblEntityGroupDetail_tblEntity] FOREIGN KEY([intEntityId]) REFERENCES [dbo].tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblEntityGroupDetail_tblEntitySplit] FOREIGN KEY([intEntityGroupId]) REFERENCES [dbo].[tblEMEntityGroup]([intEntityGroupId]) ON DELETE CASCADE
)
