
GO
PRINT 'START TF tblTFValidOriginState'
GO

DECLARE @tblTempSource TABLE (intReportingComponentId INT)

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 10) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(4, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('4')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 15) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(5, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('5')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 16) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(6, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('6')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 10) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(10, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('10')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 15) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(15, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('15')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 16) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(16, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('16')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 18) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(18, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('18')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 19) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(19, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('19')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 23) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(23, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('23')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 25) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(25, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('25')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 26) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(26, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('26')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 27) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(27, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('27')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 28) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(28, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('28')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 29) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(29, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('29')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 30) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(30, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('30')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 31) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(31, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('31')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 32) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(32, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('32')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 33) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(33, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('33')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 34) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(34, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('34')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 35) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(35, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('35')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 36) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(36, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('36')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 37) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(37, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('37')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 38) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(38, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('38')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 39) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(39, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('39')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 40) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(40, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('40')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 41) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(41, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('41')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 42) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(42, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('42')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 43) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(43, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('43')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 44) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(44, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('44')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 45) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(45, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('45')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 46) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(46, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('46')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 47) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(47, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('47')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 48) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(48, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('48')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 49) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(49, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('49')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 50) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(50, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('50')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 51) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(51, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('51')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 52) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(52, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('52')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 53) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(53, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('53')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 54) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(54, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('54')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 55) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(55, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('55')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = 56) BEGIN INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) VALUES(56, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('56')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFValidOriginState', intValidOriginStateId, intReportingComponentId, NULL, '', GETDATE() 
FROM tblTFValidOriginState A WHERE NOT EXISTS (SELECT intReportingComponentId FROM @tblTempSource B WHERE A.intReportingComponentId = B.intReportingComponentId)

GO
PRINT 'END TF tblTFValidOriginState'
GO