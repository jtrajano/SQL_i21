CREATE TABLE [dbo].[tblMFWorkOrderRecipeComputation]
(
	[intWorkOrderRecipeComputationId] INT IDENTITY NOT NULL , 
    [intWorkOrderId] INT NOT NULL,
	[intPropertyId] INT NOT NULL, 
	[intTestId] INT NOT NULL, 
    [dblMinValue] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeComputation_MinValue] DEFAULT 0, 
    [dblMaxValue] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeComputation_MaxValue] DEFAULT 0, 
    [dblComputedValue] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeComputation_ComputedValue] DEFAULT 0, 
    [intMethodId] INT NOT NULL,
	[intTypeId] INT NOT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrderRecipeComputation_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFWorkOrderRecipeComputation_intWorkOrderRecipeComputationId] PRIMARY KEY ([intWorkOrderRecipeComputationId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeComputation_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMFWorkOrderRecipeComputation_tblQMProperty_intPropertyId] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeComputation_tblQMTest_intTestId] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeComputation_tblMFWorkOrderRecipeComputationMethod_intMethodId] FOREIGN KEY ([intMethodId]) REFERENCES [tblMFWorkOrderRecipeComputationMethod]([intMethodId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeComputation_tblMFWorkOrderRecipeComputationType_intTypeId] FOREIGN KEY ([intTypeId]) REFERENCES [tblMFWorkOrderRecipeComputationType]([intTypeId]),
)
