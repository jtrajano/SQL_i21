GO
PRINT 'START TF tblTFValidOriginState'
GO

UPDATE tblTFValidOriginState SET strFilter = ISNULL(strFilter, '')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '61')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('61', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '62')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('62', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '64')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('64', '14', 'IN', '')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '60')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('60', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '64')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('64', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '65')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('65', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '67')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('67', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '68')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('68', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '66')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('66', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '63')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('63', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '13')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('13', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '14')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('14', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '15')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('15', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '16')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('16', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '17')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('17', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '18')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('18', '14', 'IN', 'Exclude')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '28')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('28', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '29')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('29', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '30')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('30', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '71')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('71', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '72')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('72', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '73')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('73', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '74')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('74', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '75')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('75', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '76')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('76', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '77')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('77', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '78')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('78', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '79')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('79', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '80')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('80', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '81')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('81', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '82')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('82', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '83')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('83', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '84')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('84', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '85')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('85', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '86')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('86', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '87')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('87', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '88')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('88', '14', 'IN', 'Include')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidOriginState WHERE intReportingComponentId = '49')BEGIN
INSERT INTO tblTFValidOriginState([intReportingComponentId],[intOriginDestinationStateId],[strOriginState],[strFilter]) 
VALUES('49', '14', 'IN', 'Exclude')
END

GO
PRINT 'END TF tblTFValidOriginState'
GO