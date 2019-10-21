CREATE TABLE [dbo].[tblPREmployeeLocationDistribution]
(
	[intEmployeeLocationDistributionId] INT NOT NULL IDENTITY,
    [intEntityEmployeeId]     INT NOT NULL,
	[intProfitCenter]		  INT NULL,
    [dblPercentage]           NUMERIC(18,6) NULL,
    [intConcurrencyId]        INT NULL,
    CONSTRAINT [PK_tblPREmployeeLocationDistribution] PRIMARY KEY CLUSTERED ([intEmployeeLocationDistributionId] ASC),
	CONSTRAINT [FK_tblPREmployeeLocationDistribution_tblPREmployee] FOREIGN KEY ([intEntityEmployeeId]) REFERENCES [dbo].[tblPREmployee] ([intEntityId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPREmployeeLocationDistribution_tblGLAccountSegment] FOREIGN KEY ([intProfitCenter]) REFERENCES [tblGLAccountSegment]([intAccountSegmentId])
)