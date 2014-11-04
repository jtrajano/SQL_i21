CREATE TABLE [dbo].[tblSTSubcategoryClass]
(
	[intClassId] INT NOT NULL , 
    [intConcurrencyID] INT NOT NULL, 
    [strClassId] NCHAR(8) NOT NULL, 
    [strClassDesc] NCHAR(30) NULL, 
    [strClassComment] NCHAR(90) NULL, 
    CONSTRAINT [PK_tblSTSubcategoryClass] PRIMARY KEY CLUSTERED ([intClassId] ASC),
    CONSTRAINT [AK_tblSTSubcategoryClass_strClassId] UNIQUE NONCLUSTERED ([strClassId] ASC),
);
