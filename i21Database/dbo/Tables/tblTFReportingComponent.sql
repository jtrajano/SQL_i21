CREATE TABLE [dbo].[tblTFReportingComponent] (
    [intReportingComponentId] INT           IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]       INT           NOT NULL,
    [strFormCode]             VARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFormName]             VARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strScheduleCode]         VARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strScheduleName]         VARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                 VARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strNote]                 VARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT           CONSTRAINT [DF_tblTFReportingComponent_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponent] PRIMARY KEY CLUSTERED ([intReportingComponentId] ASC)
);

