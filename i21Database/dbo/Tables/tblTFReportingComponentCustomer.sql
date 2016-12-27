﻿CREATE TABLE [dbo].[tblTFReportingComponentCustomer]
(
	[intReportingComponentCustomerId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[intEntityCustomerId] INT NOT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponentCustomer] PRIMARY KEY ([intReportingComponentCustomerId]), 
    CONSTRAINT [AK_tblTFReportingComponentCustomer] UNIQUE ([intReportingComponentId], [intEntityCustomerId]), 
    CONSTRAINT [FK_tblTFReportingComponentCustomer_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFReportingComponentCustomer_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId])
)
