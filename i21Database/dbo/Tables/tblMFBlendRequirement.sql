CREATE TABLE [dbo].[tblMFBlendRequirement]
(
	[intBlendRequirementId] INT NOT NULL  IDENTITY(1,1), 
    [strDemandNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intItemId] INT NOT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL, 
    [intUOMId] INT NOT NULL, 
    [dtmDueDate] DATETIME NOT NULL, 
	[intLocationId] INT NOT NULL,
	[intStatusId] INT NOT NULL CONSTRAINT [DF_tblMFBlendRequirement_intStatusId] DEFAULT 1, 
    [dblIssuedQty] NUMERIC(18, 6) NULL, 
    [intManufacturingCellId] INT NULL, 
    [dblBlenderSize] NUMERIC(18, 6) NULL, 
    [dblEstNoOfBlendSheet] NUMERIC(18, 6) NULL, 
    [intMachineId] INT NULL,
	[intCreatedUserId] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_tblMFBlendRequirement_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NOT NULL,
	[dtmLastModified] [datetime] NOT NULL CONSTRAINT [DF_tblMFBlendRequirement_dtmLastModified] DEFAULT GetDate(),	 
    [intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFBlendRequirement_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFBlendRequirement_intBlendRequirementId] PRIMARY KEY (intBlendRequirementId), 
	CONSTRAINT [FK_tblMFBlendRequirement_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblMFBlendRequirement_tblICUnitMeasure_intUnitMeasureId_intUOMId] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblMFBlendRequirement_tblSMCompanyLocation_intCompanyLocationId_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblMFBlendRequirement_tblMFBlendRequirementStatus_intStatusId] FOREIGN KEY ([intStatusId]) REFERENCES [tblMFBlendRequirementStatus]([intStatusId]),
	CONSTRAINT [UQ_tblMFBlendRequirement_strDemandNo_intLocationId] UNIQUE ([strDemandNo],[intLocationId])
)

GO

CREATE INDEX [IX_tblMFBlendRequirement_intItemId] ON [dbo].[tblMFBlendRequirement] (intItemId)
