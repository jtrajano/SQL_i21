GO
PRINT 'START TF tblTFValidDestinationState'
GO

UPDATE tblTFValidDestinationState set strStatus = ISNULL(strStatus, '')

IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '61')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('61', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '62')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('62', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '60')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('60', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '63')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('63', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '64')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('64', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '65')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('65', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '67')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('67', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '68')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('68', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '66')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('66', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '13')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('13', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '14')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('14', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '15')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('15', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '16')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('16', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '17')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('17', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '18')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('18', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '28')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('28', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '29')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('29', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '30')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('30', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '71')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('71', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '72')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('72', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '73')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('73', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '74')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('74', '13', 'IL', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '75')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('75', '13', 'IL', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '76')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('76', '13', 'IL', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '77')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('77', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '78')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('78', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '79')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('79', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '80')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('80', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '81')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('81', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '82')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('82', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '83')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('83', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '84')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('84', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '85')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('85', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '86')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('86', '17', 'KY', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '87')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('87', '22', 'MI', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '88')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('88', '35', 'OH', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidDestinationState WHERE intReportingComponentId = '49')BEGIN
INSERT INTO tblTFValidDestinationState([intReportingComponentId],[intOriginDestinationStateId],[strDestinationState],[strStatus]) 
VALUES('49', '14', 'IN', 'Include')
END

GO
PRINT 'END TF tblTFValidDestinationState'
GO
