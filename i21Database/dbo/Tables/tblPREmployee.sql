CREATE TABLE [dbo].[tblPREmployee](
	[intEmployeeId] [int] NOT NULL IDENTITY,
	[strEmployeeId] [nvarchar](50) NOT NULL,
	[strCompany] [nvarchar](100) NULL,
	[strPhone] [nvarchar](50) NULL,
	[strEmail] [nvarchar](75) NULL,
	[strType] [nvarchar](50) NULL,
	[strTitle] [nvarchar](50) NULL,
	[strSalutation] [nvarchar](50) NULL,
	[strFirstName] [nvarchar](50) NULL,
	[strMiddleName] [nvarchar](50) NULL,
	[strLastName] [nvarchar](50) NULL,
	[strAddress] [nvarchar](MAX) NULL,
	[strZip] [nvarchar](15) NULL,
	[strCity] [nvarchar](50) NULL,
	[strState] [nvarchar](50) NULL,
	[strCountry] [nvarchar](50) NULL,
	[strSocialSecurity] [nvarchar](15) NULL,
	[ysn1099Employee] [bit] NULL,
	[strWorkPhone] [nvarchar](50) NULL,
	[strAltPhone] [nvarchar](50) NULL,
	[strOtherPhone] [nvarchar](50) NULL,
	[strMobile] [nvarchar](50) NULL,
	[strEmail2] [nvarchar](100) NULL,
	[strWebSite] [nvarchar](500) NULL,
	[strSupervisor] [nvarchar](50) NULL,
	[strDepartment] [nvarchar](50) NULL,
	[ysnActive] [bit] NOT NULL DEFAULT ((1)),
	[imgPhoto] [image] NULL,
	[strEmergencyContact] [nvarchar](25) NULL,
	[strEmergencyRelation] [nvarchar](25) NULL,
	[strEmergencyPhone] [nvarchar](25) NULL,
	[strEmergencyPhone2] [nvarchar](25) NULL,

	[strGender] [nvarchar](15) NULL,
	[strNickName] [nvarchar](50) NULL,
	[dtmDateHired] [datetime] NULL,
	[dtmBirthDate] [datetime] NULL ,
	[strMaritalStatus] [nvarchar](50) NULL,
	[strSpouse] [nvarchar](50) NULL,
	[intEthnicOriginId] [int] NULL,
	[intDivisionId] [int] NULL,
	[strTerritory] [nvarchar](50) NULL,
	[strEducation] [nvarchar](50) NULL,
	[strDegree] [nvarchar](50) NULL,
	[strAltContact] [nvarchar](50) NULL,
	[dtmTerminated] [datetime] NULL,
	[strTerminatedReason] [nvarchar](100) NULL,
	[dtmDateEntered] [datetime] NOT NULL DEFAULT (getdate()),
	[dtmLastModified] [datetime] NULL DEFAULT (getdate()),

	[strPayPeriod] [nvarchar](50) NULL DEFAULT ('Bi-Weekly'),
	[intCurrencyId] int NULL,
	[intPayGroupId] int NULL,
	[ysnDirectDeposit] [bit] NOT NULL DEFAULT ((0)),

	[dtmLastRaise] [datetime] NULL DEFAULT (getdate()),
	[dtmLastReview] [datetime] NULL DEFAULT (getdate()),
	[dtmLastPaid] [datetime] NULL,

	[intTaxGroupId] [int] NULL,
	[intEarningGroupId] [int] NULL,
	[intDeductionGroupId] [int] NULL,
	[intTimeOffGroupId] [int] NULL,
	
	[ysnStatutoryEmployee] [bit] NOT NULL DEFAULT ((0)),
	[ysnRetirementPlan] [bit] NOT NULL DEFAULT ((0)),
	[ysnThirdPartySickPay] [bit] NOT NULL DEFAULT ((0)),

	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployee] PRIMARY KEY ([intEmployeeId]), 
    CONSTRAINT [AK_tblPREmployee_strEmployeeId] UNIQUE ([strEmployeeId])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
    @value = N'Company',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strCompany'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Title',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strTitle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Salutation',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strSalutation'
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
    @value = N'Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strZip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
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
    @value = N'Alternate Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strAltPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Other Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strOtherPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mobile Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strMobile'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Alternate Email',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEmail2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Website',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strWebSite'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Supervisor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strSupervisor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strDepartment'
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
    @value = N'Photo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'imgPhoto'
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
    @value = N'Nick Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strNickName'
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
    @level2name = N'intEthnicOriginId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Division Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intDivisionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Territory',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strTerritory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Education Attained',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strEducation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Degree Attained',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strDegree'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Alternate Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'strAltContact'
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
    @value = N'Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intCurrencyId'
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
    @value = N'Date Last Raised',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastRaise'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Last Reviewed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastReview'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Last Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastPaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tac Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intTaxGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intEarningGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intTimeOffGroupId'
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
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployee',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'