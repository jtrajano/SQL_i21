﻿CREATE TABLE [dbo].[tblCTCondition]
(
	[intConditionId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strConditionName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strConditionDesc] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnActive] BIT NULL,
	[ysnStandard] BIT NULL,
	intCertificationId INT,
	
	CONSTRAINT [PK_tblCTCondition_intConditionId] PRIMARY KEY CLUSTERED (intConditionId ASC), 
    CONSTRAINT [UK_tblCTCondition_strConditionName] UNIQUE ([strConditionName]),
	CONSTRAINT [FK_tblCTCondition_tblICCertification_intCertificationId] FOREIGN KEY ([intCertificationId]) REFERENCES [tblICCertification]([intCertificationId])
)