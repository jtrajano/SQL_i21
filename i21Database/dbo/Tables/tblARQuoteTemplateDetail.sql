﻿CREATE TABLE [dbo].[tblARQuoteTemplateDetail]
(
	[intQuoteTemplateDetailId]	INT NOT NULL IDENTITY , 
    [intQuoteTemplateId]		INT NOT NULL,     
    [strSectionName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strPageTitle]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPageDescription]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPageBody]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnDisplayTitle]			BIT NULL, 
	[intConcurrencyId]			INT NOT NULL,	
	[intSort]					INT NULL DEFAULT 0,
    CONSTRAINT [PK_tblARQuoteTemplateDetail_intQuoteTemplateDetailId] PRIMARY KEY CLUSTERED ([intQuoteTemplateDetailId] ASC),
    CONSTRAINT [FK_tblARQuoteTemplateDetail_tblARQuoteTemplate] FOREIGN KEY ([intQuoteTemplateId]) REFERENCES [dbo].[tblARQuoteTemplate]([intQuoteTemplateId]) ON DELETE CASCADE
)
