CREATE TABLE [dbo].[tblSMTermPullPoint] (
    [intTermPullPointId]		INT             IDENTITY (1, 1) NOT NULL,
    [intCategoryId]			    INT             NULL,
    [intItemId]					INT             NULL,
    [intTermId]                 INT             NOT NULL,
    [strPullPoint]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Terminal',
    [intConcurrencyId]			INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMTermPullPoint] PRIMARY KEY CLUSTERED ([intTermPullPointId] ASC),
    CONSTRAINT [FK_tblSMTermPullPoint_tblICCategory_intTermItemCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]),
    CONSTRAINT [FK_tblSMTermPullPoint_tblICItem_intTermItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
    CONSTRAINT [FK_tblSMTermPullPoint_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES [dbo].[tblSMTerm] ([intTermID])
);