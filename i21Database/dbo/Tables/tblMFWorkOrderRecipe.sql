﻿CREATE TABLE [dbo].[tblMFWorkOrderRecipe]
(
	[intWorkOrderId] int,
	[intRecipeId] INT NOT NULL, 
	[intItemId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intUOMId] INT NOT NULL, 
    [intManufacturingCellId] INT NOT NULL,
	[intLocationId] INT NOT NULL,  
    [intVersionNo] INT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_intVersionNo] DEFAULT 1, 
	[intRecipeTypeId] INT,
    [intCostDistributionMethodId] INT NOT NULL , 
	[intManufacturingProcessId] INT NOT NULL,
    [ysnActive] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_ysnActive] DEFAULT 0, 
    [ysnImportOverride] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_ysnImportOverride] DEFAULT 0,
	[ysnAutoBlend] BIT NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_ysnAutoBlend] DEFAULT 0,
	[intCustomerId] INT,
	[intFarmId] INT,
	[intFieldId] INT,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderRecipe_intConcurrencyId] DEFAULT 0, 
    CONSTRAINT [PK_tblMFWorkOrderRecipe_intRecipeId] PRIMARY KEY ([intRecipeId],[intWorkOrderId]), 
    CONSTRAINT [FK_tblMFWorkOrderRecipe_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblICUnitMeasure_intUnitMeasureId_intUOMId] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblMFCostDistributionMethod_intCostDistributionMethodId] FOREIGN KEY ([intCostDistributionMethodId]) REFERENCES [tblMFCostDistributionMethod]([intCostDistributionMethodId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblMFManufacturingProcess_intManufacturingProcessId] FOREIGN KEY ([intManufacturingProcessId]) REFERENCES [tblMFManufacturingProcess]([intManufacturingProcessId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblARCustomerFarm_intFarmFieldId_intFarmId] FOREIGN KEY ([intFarmId]) REFERENCES [tblARCustomerFarm]([intFarmFieldId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblARCustomerFarm_intFarmFieldId_intFieldId] FOREIGN KEY ([intFieldId]) REFERENCES [tblARCustomerFarm]([intFarmFieldId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipe_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblMFWorkOrderRecipe_intItemId] ON [dbo].[tblMFRecipe] ([intItemId])
