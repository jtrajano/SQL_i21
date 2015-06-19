CREATE TABLE [dbo].[tblCTContractPlan]
(
	[intContractPlanId] INT IDENTITY(1,1) NOT NULL, 
    [strContractPlan] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [dtmStartDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [ysnMaxPrice] BIT NULL, 
    [intCategoryId] INT NULL, 
    [intItemId] INT NULL, 
    [dblPrice] NUMERIC(8, 4) NULL, 
    [intConcurrencyId] INT NOT NULL,

	CONSTRAINT [PK_tblCTContractPlan_intContractPlanId] PRIMARY KEY CLUSTERED ([intContractPlanId] ASC),
	CONSTRAINT [FK_tblCTContractPlan_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblCTContractPlan_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId])
)
