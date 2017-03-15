CREATE TABLE [dbo].[tblTFReportingComponentAccountStatusCode] (
    [intReportingComponentAccountStatusCodeId] INT IDENTITY NOT NULL,
    [intReportingComponentId] INT NOT NULL,
    [intAccountStatusId] INT NOT NULL,
	[strAccountStatusCode] NVARCHAR (20) COLLATE Latin1_General_CI_AS NULL,
    [ysnInclude] [bit] NOT NULL,
    [intConcurrencyId] INT DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentAccountStatusCode] PRIMARY KEY CLUSTERED ([intReportingComponentAccountStatusCodeId]),
    CONSTRAINT [FK_tblTFReportingComponentAccountStatusCode_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTFReportingComponentAccountStatusCode_tblARAccountStatus] FOREIGN KEY ([intAccountStatusId]) REFERENCES [tblARAccountStatus]([intAccountStatusId])
);

