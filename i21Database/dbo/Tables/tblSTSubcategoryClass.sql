CREATE TABLE [dbo].[tblSTSubcategoryClass]
(
	[intClassId] INT NOT NULL IDENTITY,
    [strClassId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strClassDesc] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strClassComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubcategoryClass] PRIMARY KEY CLUSTERED ([intClassId] ASC),
    CONSTRAINT [AK_tblSTSubcategoryClass_strClassId] UNIQUE NONCLUSTERED ([strClassId] ASC),
);
