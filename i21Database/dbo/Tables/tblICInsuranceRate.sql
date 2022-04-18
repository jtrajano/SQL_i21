CREATE TABLE [dbo].[tblICInsuranceRate](
	[intInsuranceRateId] [int] IDENTITY(1,1) NOT NULL,
	[dtmStartDateUTC] [datetime] NULL,
	[dtmEndDateUTC] [datetime] NULL,
	[intInsurerId] [int] NOT NULL,
	[strPolicyNumber] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT (N'Daily') ,
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblICInsuranceRate] PRIMARY KEY CLUSTERED ([intInsuranceRateId] ASC)
) 
GO

