CREATE TABLE [dbo].[tblICRecostFormulation]
(
	[intRecostFormulationId] INT NOT NULL PRIMARY KEY
	,[strRecostFormulationId] NVARCHAR(50) NOT NULL 
	,[dtmDate] DATETIME NOT NULL 
	,[intRounding] TINYINT NOT NULL DEFAULT(6)
	,[strDescription] NVARCHAR(500) NULL 
	,[intLocationFromId] INT NOT NULL
	,[intLocationToId] INT NULL 
	,[intCategoryFromId] INT NOT NULL 
	,[intCategoryToId] INT NULL
	,[ysnPosted] BIT NULL DEFAULT ((0))
    ,[intConcurrencyId] INT NULL DEFAULT ((1))
    ,[dtmDateCreated] DATETIME NULL
    ,[dtmDateModified] DATETIME NULL
    ,[intCreatedByUserId] INT NULL
    ,[intModifiedByUserId] INT NULL 
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblSMCompanyLocationFrom] FOREIGN KEY ([intLocationFromId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblSMCompanyLocationTo] FOREIGN KEY ([intLocationToId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblICCategoryFrom] FOREIGN KEY ([intCategoryFromId]) REFERENCES [tblICCategory]([intCategoryId])
	,CONSTRAINT [FK_tblICRecostFormulationDetail_tblICCategoryTo] FOREIGN KEY ([intCategoryToId]) REFERENCES [tblICCategory]([intCategoryId])
)
