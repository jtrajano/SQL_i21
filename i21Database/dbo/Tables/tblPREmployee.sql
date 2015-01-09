CREATE TABLE [dbo].[tblPREmployee](
	[intEntityId]	[int] NOT NULL,
	[intEmployeeId] [int] NOT NULL IDENTITY (1, 1),
	[strEmployeeId] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strType] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[strFirstName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strMiddleName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLastName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strNameSuffix] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intSupervisorId] [int] NULL,
	[ysnActive] [bit] NOT NULL DEFAULT ((1)),
	[dtmDateHired] [datetime] NULL,
	[dtmBirthDate] [datetime] NULL,
	[strGender] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[strMaritalStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSpouse] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strWorkPhone] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strEthnicity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEEOCCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSocialSecurity] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[ysn1099Employee] [bit] NULL,
	[dtmTerminated] [datetime] NULL,
	[strTerminatedReason] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strEmergencyContact] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strEmergencyRelation] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strEmergencyPhone] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strEmergencyPhone2] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strPayPeriod] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Bi-Weekly'),
	[intPayGroupId] [int] NULL,
	[dtmReviewDate] [datetime] NULL DEFAULT (getdate()),
	[dtmNextReview] [datetime] NULL DEFAULT (getdate()),
	[ysnStatutoryEmployee] [bit] NOT NULL DEFAULT ((0)),
	[ysnRetirementPlan] [bit] NOT NULL DEFAULT ((0)),
	[ysnThirdPartySickPay] [bit] NOT NULL DEFAULT ((0)),
	[ysnDirectDeposit] [bit] NOT NULL DEFAULT ((0)),
	[dtmDateEntered] [datetime] NOT NULL DEFAULT (getdate()),
	[dtmLastModified] [datetime] NULL DEFAULT (getdate()),
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
	CONSTRAINT [PK_tblPREmployee] PRIMARY KEY ([intEntityId]),
    CONSTRAINT [UK_tblPREmployee] UNIQUE ([intEmployeeId]), 
    CONSTRAINT [AK_tblPREmployee_strEmployeeId] UNIQUE ([strEmployeeId]),
	CONSTRAINT [FK_tblPREmployee_tblPREmployee] FOREIGN KEY ([intSupervisorId]) REFERENCES [tblPREmployee]([intEmployeeId]),
	CONSTRAINT [FK_tblPREmployee_tblPRPayGroup] FOREIGN KEY ([intPayGroupId]) REFERENCES [tblPRPayGroup]([intPayGroupId])
) ON [PRIMARY]
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'First Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strFirstName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Middle Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strMiddleName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strLastName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Social Security',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strSocialSecurity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1099 Employee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'ysn1099Employee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strWorkPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Emergency Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmergencyContact'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Relation to Emergency Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmergencyRelation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone Number of Emergency Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmergencyPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Alternate Phone Number of Emergency Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmergencyPhone2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Gender',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strGender'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Hired',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateHired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BirthDate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmBirthDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Marital Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strMaritalStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Spouse Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strSpouse'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ethnic Origin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = 'strEthnicity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Terminated',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmTerminated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reason for Termination',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strTerminatedReason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Entered',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateEntered'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Last Modified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastModified'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strPayPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intPayGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Direct Deposit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'ysnDirectDeposit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Name Suffix',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strNameSuffix'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Supervisor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intSupervisorId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EEOC Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = 'strEEOCCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Review Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmReviewDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Review Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmNextReview'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Statutory Employee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'ysnStatutoryEmployee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Retirement Plan',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'ysnRetirementPlan'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Third Party Sick Pay',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'ysnThirdPartySickPay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strType'