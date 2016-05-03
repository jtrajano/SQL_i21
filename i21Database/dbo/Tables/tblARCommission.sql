CREATE TABLE [dbo].[tblARCommission]
(
	[intCommissionId]			INT NOT NULL IDENTITY,
	[intCommissionScheduleId]	INT NOT NULL,
	[intCommissionPlanId]		INT NULL,
	[intEntityId]				INT NULL,
	[dtmStartDate]				DATETIME NULL,
	[dtmEndDate]				DATETIME NULL,
	[ysnConditional]			BIT NULL,
	[ysnApproved]				BIT NULL DEFAULT ((0)),
	[ysnRejected]				BIT NULL DEFAULT ((0)),
	[ysnPayroll]				BIT NULL DEFAULT ((0)),
	[ysnPayables]				BIT NULL DEFAULT ((0)),
	[dblTotalAmount]			NUMERIC(18,6) NULL DEFAULT(0),
	[dblCalculationAmount]		NUMERIC(18,6) NULL DEFAULT(0),
	[strBasis]					NVARCHAR(MAX) NULL,
	[strCalculationType]		NVARCHAR(MAX) NULL,
	[strReason]					NVARCHAR(MAX) NULL,
	[intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARCommission_intCommissionId] PRIMARY KEY CLUSTERED ([intCommissionId] ASC)
)
