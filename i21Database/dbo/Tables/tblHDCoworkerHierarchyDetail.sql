CREATE TABLE [dbo].[tblHDCoworkerHierarchyDetail] (
    [intCoworkerHierarchyDetailId]      INT             IDENTITY (1, 1) NOT NULL,
	[intCoworkerHierarchyId]			INT				NULL,
    [strLevel]							NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strFilterString]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intParentGroupId]					INT             NULL,
    [intSort]							INT             NULL,
    [intConcurrencyId]					INT             DEFAULT 1 NOT NULL,
    [strDescription]					NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblHDCoworkerHierarchyDetail_intCoworkerHierarchyDetailId] PRIMARY KEY CLUSTERED ([intCoworkerHierarchyDetailId] ASC), 
    CONSTRAINT [FK_tblHDCoworkerHierarchyDetail_tblHDCoworkerHierarchy] FOREIGN KEY([intCoworkerHierarchyId])	REFERENCES [dbo].[tblHDCoworkerHierarchy] ([intCoworkerHierarchyId]) ON DELETE CASCADE

)
GO