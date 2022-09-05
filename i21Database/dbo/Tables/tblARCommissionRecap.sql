﻿CREATE TABLE [dbo].[tblARCommissionRecap]
(
	[intCommissionRecapId]		INT NOT NULL IDENTITY,
	[intCommissionScheduleId]	INT NOT NULL,
	[intCommissionPlanId]		INT NULL,
	[intEntityId]				INT NULL,
	[intApproverEntityId]		INT NULL,
	[dtmStartDate]				DATETIME NULL,
	[dtmEndDate]				DATETIME NULL,
	[ysnConditional]			BIT NULL,
	[ysnApproved]				BIT NULL DEFAULT ((0)),
	[ysnRejected]				BIT NULL DEFAULT ((0)),
	[ysnPayroll]				BIT NULL DEFAULT ((0)),
	[ysnPayables]				BIT NULL DEFAULT ((0)),
	[ysnJournal]				BIT NULL DEFAULT ((0)),
	[dblTotalAmount]			NUMERIC(18,6) NULL DEFAULT ((0)),
	[strBatchId]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[strReason]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblARCommissionRecap] PRIMARY KEY CLUSTERED ([intCommissionRecapId] ASC)
)
