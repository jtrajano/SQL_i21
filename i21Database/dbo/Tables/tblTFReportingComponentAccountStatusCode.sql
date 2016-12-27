CREATE TABLE [dbo].[tblTFReportingComponentAccountStatusCode] (
    [intReportingComponentAccountStatusCodeId] INT IDENTITY NOT NULL,
    [intReportingComponentId] INT NOT NULL,
    [intAccountStatusId] INT NOT NULL,
    [strType] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentAccountStatusCode] PRIMARY KEY CLUSTERED ([intReportingComponentAccountStatusCodeId]),
    CONSTRAINT [FK_tblTFReportingComponentAccountStatusCode_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTFReportingComponentAccountStatusCode_tblARAccountStatus] FOREIGN KEY ([intAccountStatusId]) REFERENCES [tblARAccountStatus]([intAccountStatusId])
);

