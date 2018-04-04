CREATE TABLE [dbo].[tblTFReportingComponent] (
    [intReportingComponentId] INT           IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]       INT           NOT NULL,
    [strFormCode]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFormName]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strScheduleCode]         NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strScheduleName]         NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                 NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strNote]                 NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    intSort           INT           NULL,
	[strStoredProcedure] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intComponentTypeId] INT NULL,
	[ysnIncludeSalesFreightOnly] BIT NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId] INT DEFAULT((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponent] PRIMARY KEY ([intReportingComponentId] ASC), 
    CONSTRAINT [FK_tblTFReportingComponent_tblTFComponentType] FOREIGN KEY ([intComponentTypeId]) REFERENCES [tblTFComponentType]([intComponentTypeId]), 
    CONSTRAINT [UK_tblTFReportingComponent_1] UNIQUE ([intTaxAuthorityId], [strFormCode], [strScheduleCode], [strType]), 
    CONSTRAINT [FK_tblTFReportingComponent_tblTFTaxAuthority] FOREIGN KEY (intTaxAuthorityId) REFERENCES [tblTFTaxAuthority]([intTaxAuthorityId])
)

GO
