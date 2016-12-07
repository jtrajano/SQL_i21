GO
PRINT 'START TF tblTFValidProductCode'
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '60' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('60', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '63' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('63', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '66' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('66', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '61' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('61', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '100')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '310', '100')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '092')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '312', '092')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '62' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('62', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '64' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('64', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '67' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('67', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '100')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '310', '100')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '092')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '312', '092')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '65' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('65', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '100')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '310', '100')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '092')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '312', '092')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '68' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('68', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '1' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('1', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '4' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('4', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '7' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('7', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '10' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('10', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '13' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('13', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '16' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('16', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '19' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('19', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '22' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('22', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '25' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('25', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '28' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('28', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '31' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('31', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '34' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('34', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '37' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('37', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '2' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('2', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '5' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('5', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '8' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('8', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '11' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('11', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '14' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('14', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '17' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('17', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '20' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('20', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '23' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('23', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '26' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('26', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '29' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('29', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '32' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('32', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '3' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('3', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '6' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('6', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '9' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('9', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '12' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('12', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '15' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('15', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '18' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('18', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '21' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('21', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '24' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('24', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '27' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('27', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '30' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('30', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '33' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('33', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '71' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('71', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '74' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('74', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = '125')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '265', '125')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '77' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('77', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '72' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('72', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '75' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('75', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '145')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', '302', '145')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '147')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', '304', '147')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '073')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', '306', '073')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '78' AND strProductCode = '074')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('78', '307', '074')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '73' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('73', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '76' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('76', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '090')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '266', '090')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '248')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '267', '248')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '198')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '268', '198')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '249')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '269', '249')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '052')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '270', '052')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '196')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '271', '196')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '058')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '272', '058')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '265')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '273', '265')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '126')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '274', '126')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '059')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '275', '059')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '075')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '276', '075')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '223')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '277', '223')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '121')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '278', '121')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '199')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '279', '199')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '091')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '280', '091')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '076')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '281', '076')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '231')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '288', '231')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '150')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '293', '150')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '282')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '295', '282')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '152')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '299', '152')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '79' AND strProductCode = '130')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('79', '300', '130')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '46' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('46', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '47' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('47', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '48' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('48', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '49' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('49', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '50' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('50', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '51' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('51', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '52' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('52', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '56' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('56', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '57' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('57', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '58' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('58', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '80' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('80', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '81' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('81', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '82' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('82', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '83' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('83', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '84' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('84', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '85' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('85', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '86' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('86', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '87' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('87', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'B00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '282', 'B00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'B11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '283', 'B11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'D00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '284', 'D00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = 'D11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '285', 'D11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '226')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '286', '226')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '227')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '287', '227')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '232')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '289', '232')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '153')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '290', '153')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '161')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '291', '161')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '167')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '292', '167')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '154')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '294', '154')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '283')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '296', '283')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '224')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '297', '224')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '225')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '298', '225')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '146')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '303', '146')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '148')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '305', '148')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '285')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '309', '285')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '101')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '311', '101')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '88' AND strProductCode = '093')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('88', '313', '093')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '41' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('41', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '41' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('41', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '42' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('42', '264', 'M11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '43' AND strProductCode = '061')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('43', '308', '061')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '43' AND strProductCode = '065')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('43', '301', '065')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'E00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', '314', 'E00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'E11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', '315', 'E11')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'M00')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', '263', 'M00')
END
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = '44' AND strProductCode = 'M11')
BEGIN
INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode])
VALUES('44', '264', 'M11')
END

GO
PRINT 'END TF tblTFValidProductCode'
GO