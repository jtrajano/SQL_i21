CREATE TABLE [dbo].[tblHDTimeOffRequest]
(
	[intTimeOffRequestId] [int] IDENTITY(1,1) NOT NULL,
	[intPRTimeOffRequestId] [int] not null,
	[intPREntityEmployeeId] [int] not null,
	[strPRRequestId] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmPRDate] [datetime] not null,
	[strPRDayName] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblPRRequest] [numeric](18,6) null,
	[intPRNoOfDays] [int] null,
	[ysnSent] [bit] default convert(bit,0),
	[intConcurrencyId] [int] NOT NULL default convert(bit,1),
    CONSTRAINT [PK_tblHDTimeOffRequest_intTimeOffRequestId] PRIMARY KEY CLUSTERED ([intTimeOffRequestId] ASC)
)
