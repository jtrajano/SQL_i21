
/*
Default settings for Cash Management
GL-8624
*/

GO

PRINT ('Begin updating company preference options default settings ')

GO

UPDATE tblCMCompanyPreferenceOption SET ysnRevalue_Forward = 0 WHERE ysnRevalue_Forward IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnRevalue_Swap = 0 WHERE ysnRevalue_Swap IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnRevalue_InTransit = 0 WHERE ysnRevalue_InTransit IS NULL


UPDATE tblCMCompanyPreferenceOption SET ysnAllowBetweenLocations_Forward = 1 WHERE ysnAllowBetweenLocations_Forward IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnAllowBetweenLocations_Swap = 1 WHERE ysnAllowBetweenLocations_Swap IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnAllowBetweenLocations_InTransit = 1 WHERE ysnAllowBetweenLocations_InTransit IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnAllowBetweenCompanies_Forward = 1 WHERE ysnAllowBetweenCompanies_Forward IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnAllowBetweenCompanies_Swap = 1 WHERE ysnAllowBetweenCompanies_Swap IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnAllowBetweenCompanies_InTransit = 1 WHERE ysnAllowBetweenCompanies_InTransit IS NULL


UPDATE tblCMCompanyPreferenceOption SET ysnOverrideCompanySegment_Forward = 0 WHERE ysnOverrideCompanySegment_Forward IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnOverrideCompanySegment_Swap = 0 WHERE ysnOverrideCompanySegment_Swap IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnOverrideCompanySegment_InTransit = 0 WHERE ysnOverrideCompanySegment_InTransit IS NULL


UPDATE tblCMCompanyPreferenceOption SET ysnOverrideLocationSegment_Forward = 0 WHERE ysnOverrideLocationSegment_Forward IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnOverrideLocationSegment_Swap = 0 WHERE ysnOverrideLocationSegment_Swap IS NULL

UPDATE tblCMCompanyPreferenceOption SET ysnOverrideLocationSegment_InTransit = 0 WHERE ysnOverrideLocationSegment_InTransit IS NULL

GO

PRINT ('Finished updating company preference options default settings ')

GO


