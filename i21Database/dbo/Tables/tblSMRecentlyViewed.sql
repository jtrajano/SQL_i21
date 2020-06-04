CREATE TABLE [dbo].[tblSMRecentlyViewed]
(
	[intRecentlyViewedId] INT IDENTITY (1, 1) NOT NULL, 
    [intLogId] INT NOT NULL, 
    --[intEntityId] INT NOT NULL, 
    [strTitle] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL, 
    --[strRoute] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    --[dtmDateEntered] DATETIME NOT NULL, 
    --[dtmDateModified] DATETIME NULL, 
	[strAction] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblSMRecentlyViewed] PRIMARY KEY Clustered ([intRecentlyViewedId] ASC), 
    --CONSTRAINT [FK_tblSMRecentlyViewed_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]) 
)
