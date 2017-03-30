CREATE TABLE tblPREmployeeW2 (
	[intEmployeeW2Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityEmployeeId] INT NULL , 
	[intYear] INT NULL,
	[strControlNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dblAdjustedGross] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFIT] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblTaxableSS] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblTaxableMed] NUMERIC(18, 6) NULL DEFAULT ((0)),
    [dblTaxableSSTips] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblSSTax] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblMedTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblAllocatedTips] NUMERIC(18, 6) NULL DEFAULT ((0)),
    [dblDependentCare] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblNonqualifiedPlans] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[strOther] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strBox12a] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[strBox12b] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[strBox12c] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[strBox12d] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[dblBox12a] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblBox12b] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblBox12c] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblBox12d] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[strState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[strLocality] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strStateTaxID] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblTaxableState] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblStateTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblTaxableLocal] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblLocalTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
    [intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPREmployeeW2_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEntityId]) ON DELETE CASCADE,
)
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeW2Id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'intEntityEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Year',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'intYear'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Control Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strControlNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Adjusted Gross',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblAdjustedGross'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Federal Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblFIT'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable SS Wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableSS'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable Medicare',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableMed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable SS Tips',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableSSTips'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Social Security Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblSSTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medicare Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblMedTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allocated Tips',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblAllocatedTips'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dependent Care Benefits',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblDependentCare'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nonqualified Plans',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblNonqualifiedPlans'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Other',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strOther'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12a Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strBox12a'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12b Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strBox12b'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12c Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strBox12c'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12d Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strBox12d'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12a Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblBox12a'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12b Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblBox12b'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12c Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblBox12c'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Box 12d Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblBox12d'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Locality',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strLocality'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employer State ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'strStateTaxID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable State Wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Taxable Local Wages',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblTaxableLocal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblStateTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Local Tax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'dblLocalTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeW2',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'