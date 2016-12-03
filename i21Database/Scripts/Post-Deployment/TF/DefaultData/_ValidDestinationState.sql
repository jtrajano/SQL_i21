
GO
PRINT 'START TF tblTFValidDestinationState'
GO
DECLARE @tblTempSource TABLE (intReportingComponentId INT)

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 61) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(61, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('61')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 62) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(62, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('62')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 60) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(60, '14', 'IN', 'Exclude') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('60')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 63) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(63, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('63')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 64) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(64, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('64')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 65) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(65, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('65')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 67) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(67, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('67')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 68) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(68, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('68')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 66) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(66, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('66')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 13) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(13, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('13')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 14) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(14, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('14')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 15) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(15, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('15')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 16) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(16, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('16')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 17) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(17, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('17')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 18) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(18, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('18')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 28) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(28, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('28')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 29) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(29, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('29')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 30) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(30, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('30')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 71) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(71, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('71')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 72) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(72, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('72')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 73) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(73, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('73')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 74) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(74, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('74')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 75) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(75, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('75')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 76) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(76, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('76')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 77) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(77, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('77')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 78) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(78, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('78')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 79) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(79, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('79')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 53) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(53, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('53')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 80) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(80, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('80')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 81) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(81, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('81')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 82) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(82, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('82')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 54) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(54, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('54')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 83) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(83, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('83')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 84) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(84, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('84')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 85) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(85, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('85')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 55) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(55, '13', 'IL', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('55')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 86) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(86, '17', 'KY', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('86')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 87) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(87, '22', 'MI', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('87')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 88) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(88, '35', 'OH', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('88')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = 49) BEGIN INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) VALUES(49, '14', 'IN', 'Include') END 
	INSERT @tblTempSource (intReportingComponentId) VALUES ('49')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFValidDestinationState', intValidDestinationStateId, intReportingComponentId, NULL, '', GETDATE() 
FROM tblTFValidDestinationState A WHERE NOT EXISTS (SELECT intReportingComponentId FROM @tblTempSource B WHERE A.intReportingComponentId = B.intReportingComponentId)

GO
PRINT 'END TF tblTFValidDestinationState'
GO
