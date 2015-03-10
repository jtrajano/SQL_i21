CREATE TABLE [dbo].[tblMFRecipe]
(
	[intRecipeId] INT NOT NULL  IDENTITY(1,1),
	[intItemId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intUOMId] INT NOT NULL, 
    [intManufacturingCellId] INT NOT NULL,
	[intLocationId] INT NOT NULL,  
    [intVersionNo] INT NOT NULL CONSTRAINT [DF_tblMFRecipe_intVersionNo] DEFAULT 1, 
    [intCostDistributionMethodId] INT NOT NULL , 
	[intManufacturingProcessId] INT NOT NULL,
    [ysnActive] BIT NOT NULL CONSTRAINT [DF_tblMFRecipe_ysnActive] DEFAULT 0, 
    [ysnImportOverride] BIT NOT NULL CONSTRAINT [DF_tblMFRecipe_ysnImportOverride] DEFAULT 0,
	[ysnAutoBlend] BIT NOT NULL CONSTRAINT [DF_tblMFRecipe_ysnAutoBlend] DEFAULT 0,
	[intCustomerId] INT,
	[intFarmId] INT,
	[intFieldId] INT,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFRecipe_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFRecipe_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFRecipe_intConcurrencyId] DEFAULT 0, 
    CONSTRAINT [PK_tblMFRecipe_intRecipeId] PRIMARY KEY ([intRecipeId]), 
    CONSTRAINT [FK_tblMFRecipe_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFRecipe_tblICUnitMeasure_intUnitMeasureId_intUOMId] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblMFRecipe_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblMFRecipe_tblMFCostDistributionMethod_intCostDistributionMethodId] FOREIGN KEY ([intCostDistributionMethodId]) REFERENCES [tblMFCostDistributionMethod]([intCostDistributionMethodId]),
	CONSTRAINT [FK_tblMFRecipe_tblMFManufacturingProcess_intManufacturingProcessId] FOREIGN KEY ([intManufacturingProcessId]) REFERENCES [tblMFManufacturingProcess]([intManufacturingProcessId]),
	CONSTRAINT [FK_tblMFRecipe_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]),
	CONSTRAINT [FK_tblMFRecipe_tblARCustomerFarm_intFarmFieldId_intFarmId] FOREIGN KEY ([intFarmId]) REFERENCES [tblARCustomerFarm]([intFarmFieldId]),
	CONSTRAINT [FK_tblMFRecipe_tblARCustomerFarm_intFarmFieldId_intFieldId] FOREIGN KEY ([intFieldId]) REFERENCES [tblARCustomerFarm]([intFarmFieldId])
)

GO

CREATE INDEX [IX_tblMFRecipe_intItemId] ON [dbo].[tblMFRecipe] ([intItemId])
