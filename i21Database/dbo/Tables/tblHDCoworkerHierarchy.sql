CREATE TABLE [dbo].[tblHDCoworkerHierarchy] (
    [intCoworkerHierarchyId]		INT            IDENTITY (1, 1) NOT NULL,
    [strCoworkerHierarchyName]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblHDCoworkerHierarchy] PRIMARY KEY CLUSTERED ([intCoworkerHierarchyId] ASC)
)
GO