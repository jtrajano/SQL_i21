CREATE TABLE [dbo].[tblSCLastScaleSetup]
(
	[intLastScaleSetupId] [int] IDENTITY(1,1) NOT NULL,
	[intScaleSetupId] [int] NULL,
	[dtmScaleDate] [date] NULL,
	[strScaleOperator] [varchar](40) NULL,
	[intConcurrencyId] [int] NULL, 
    CONSTRAINT [PK_tblSCLastScaleSetup] PRIMARY KEY ([intLastScaleSetupId]), 
)
