CREATE TABLE [tblICRetailValuation]
(
	[intId] INT NOT NULL IDENTITY, 
	[intCategoryId] INT NOT NULL,
	[intCategoryLocationId] INT NULL,
	[intLocationId] INT NULL,
	[intRegisterDepartmentId] INT NULL,
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 	
	[strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strCategoryDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblBeginningRetail] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblReceipts] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblSales] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblMarkUpsDowns] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblWriteOffs] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblEndingRetail] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblGrossMarginPct] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblTargetGrossMarginPct] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dblEndingCost] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[dtmDateFrom] DATETIME NULL, 
	[dtmDateTo] DATETIME NULL,
	[dtmCreated] DATETIME NULL,
	CONSTRAINT [PK_tblICRetailValuation] PRIMARY KEY ([intId]),
	CONSTRAINT [FK_tblICRetailValuation_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblICRetailValuation_tblICCategoryLocation] FOREIGN KEY ([intCategoryLocationId]) REFERENCES [tblICCategoryLocation]([intCategoryLocationId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICRetailValuation_intCategoryId]
	ON [tblICRetailValuation]([intCategoryId] ASC, [strCategoryCode] ASC)
	INCLUDE (intCategoryLocationId, strLocationName) 
GO 

