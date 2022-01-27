CREATE TABLE [dbo].[tblCMCompanyPreferenceOption](
	intCompanyPreferenceOptionId int IDENTITY(1,1) NOT NULL,
	intBTPostReminderDays INT NULL,
	intUTCOffset int NULL,
	intBTForwardFromFXGLAccountId int NULL, -- receivable
	intBTForwardToFXGLAccountId int NULL, -- payable
	intBTSwapFromFXGLAccountId int NULL,
	intBTSwapToFXGLAccountId int NULL,
	intBTFeesAccountId int NULL,
	intBTBankFeesAccountId int NULL,
	intBTInTransitAccountId int NULL,
	intBTForexDiffAccountId INT NULL,
	ysnRevalue_Swap BIT NULL,
	ysnAllowBetweenLocations_Swap BIT NULL,
	ysnAllowBetweenCompanies_Swap BIT NULL,
	ysnOverrideLocationSegment_Swap BIT NULL,
	ysnOverrideCompanySegment_Swap BIT NULL,
	ysnRevalue_InTransit BIT NULL,
	ysnAllowBetweenLocations_InTransit BIT NULL,
	ysnAllowBetweenCompanies_InTransit BIT NULL,
	ysnOverrideLocationSegment_InTransit BIT NULL,
	ysnOverrideCompanySegment_InTransit BIT NULL,
	ysnRevalue_Forward BIT NULL,
	ysnAllowBetweenLocations_Forward BIT NULL,
	ysnAllowBetweenCompanies_Forward BIT NULL,
	ysnOverrideLocationSegment_Forward BIT NULL,
	ysnOverrideCompanySegment_Forward BIT NULL,
	intConcurrencyId int NULL,
 CONSTRAINT [PK_tblCMCompanyPreferenceOption] PRIMARY KEY CLUSTERED 
(
	[intCompanyPreferenceOptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO