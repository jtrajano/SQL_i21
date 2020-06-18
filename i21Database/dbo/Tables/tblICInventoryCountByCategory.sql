CREATE TABLE [dbo].[tblICInventoryCountByCategory] (
    [intInventoryCountByCategoryId] INT           IDENTITY (1, 1) NOT NULL,
    [intLocationId]                 INT           NOT NULL,
    [dtmCountDate]                  DATETIME      NULL,
    [strCountNo]                    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]                     BIT           CONSTRAINT [DF__tblICInve__ysnPo__27586B36] DEFAULT ((0)) NOT NULL,
    [dtmPosted]                     DATETIME      NULL,
    [intCompanyId]                  INT           NULL,
    [intSort]                       INT           NULL,
    [intUserId]                     INT           NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF__tblICInve__intCo__284C8F6F] DEFAULT ((0)) NULL,
    [dtmDateCreated]                DATETIME      NULL,
    [dtmDateModified]               DATETIME      NULL,
    [intCreatedByUserId]            INT           NULL,
    [intModifiedByUserId]           INT           NULL,
    CONSTRAINT [PK_tblICInventoryCountByCategory] PRIMARY KEY CLUSTERED ([intInventoryCountByCategoryId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblICInventoryCountByCategory_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId])
);

