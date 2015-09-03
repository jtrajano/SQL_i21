CREATE TABLE [dbo].[tblEntitySplit]
(
	[intSplitId]          INT           IDENTITY (1, 1) NOT NULL,
    [intEntityId] INT           NOT NULL,
    [strSplitNumber]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,    
    [strDescription]      NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [dblAcres]            NUMERIC(18, 6),
	[intCategoryId]			INT			NULL,
    [intConcurrencyId]    INT           NOT NULL,
    CONSTRAINT [PK_tblEntitySplit] PRIMARY KEY CLUSTERED ([intSplitId] ASC),
	CONSTRAINT [FK_tblEntitySplit_tblARCustomer] FOREIGN KEY([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [UK_tblEntitySplit_strSplitNumber] UNIQUE NONCLUSTERED ([strSplitNumber] ASC),
	CONSTRAINT [FK_dbo_tblEntitySplit_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])

)