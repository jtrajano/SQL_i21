
GO
PRINT 'START TF tblTFValidProductCode'
GO

DECLARE @ProductCodeId INT
DECLARE @tblTempSource TABLE (intReportingComponentId INT, strProductCode NVARCHAR(5) COLLATE Latin1_General_CI_AS)

SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, 'B00') END
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 60 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(60, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('60', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 63 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(63, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('63', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 66 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(66, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('66', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 61 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(61, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('61', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '100')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '100')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '100') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '100')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '092')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '092')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '092') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '092')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 62 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(62, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('62', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 64 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(64, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('64', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 67 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(67, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('67', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '100')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '100')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '100') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '100')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '092')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '092')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '092') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '092')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 65 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(65, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('65', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '100')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '100')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '100') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '100')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '092')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '092')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '092') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '092')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 68 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(68, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('68', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 1 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(1, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('1', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 4 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(4, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('4', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 7 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(7, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('7', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 10 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(10, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('10', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 13 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(13, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('13', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 16 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(16, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('16', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 19 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(19, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('19', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 22 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(22, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('22', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 25 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(25, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('25', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 28 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(28, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('28', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 31 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(31, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('31', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 34 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(34, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('34', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 37 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(37, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('37', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 2 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(2, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('2', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 5 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(5, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('5', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 8 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(8, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('8', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 11 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(11, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('11', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 14 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(14, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('14', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 17 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(17, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('17', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 20 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(20, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('20', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 23 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(23, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('23', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 26 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(26, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('26', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 29 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(29, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('29', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 32 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(32, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('32', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 3 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(3, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('3', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 6 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(6, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('6', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 9 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(9, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('9', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 12 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(12, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('12', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 15 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(15, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('15', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 18 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(18, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('18', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 21 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(21, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('21', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 24 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(24, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('24', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 27 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(27, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('27', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 30 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(30, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('30', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 33 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(33, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('33', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 71 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(71, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('71', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 74 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(74, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('74', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '125')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = '125')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, '125') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', '125')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 77 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(77, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('77', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 72 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(72, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('72', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 75 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(75, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('75', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '145')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '145')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, @ProductCodeId, '145') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '145')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '147')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '147')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, @ProductCodeId, '147') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '147')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '073')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '073')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, @ProductCodeId, '073') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '073')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '074')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 78 AND strProductCode = '074')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(78, @ProductCodeId, '074') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('78', '074')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 73 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(73, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('73', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 76 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(76, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('76', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '090')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '090')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '090') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '090')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '248')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '248')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '248') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '248')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '198')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '198')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '198') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '198')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '249')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '249')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '249') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '249')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '052')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '052')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '052') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '052')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '196')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '196')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '196') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '196')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '058')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '058')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '058') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '058')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '265')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '265')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '265') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '265')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '126')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '126')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '126') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '126')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '059')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '059')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '059') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '059')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '075')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '075')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '075') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '075')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '223')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '223')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '223') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '223')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '121')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '121')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '121') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '121')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '199')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '199')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '199') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '199')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '091')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '091')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '091') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '091')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '076')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '076')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '076') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '076')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '231')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '231')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '231') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '231')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '150')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '150')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '150') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '150')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '282')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '282')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '282') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '282')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '152')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '152')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '152') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '152')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '130')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 79 AND strProductCode = '130')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(79, @ProductCodeId, '130') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('79', '130')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 46 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(46, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('46', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 47 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(47, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('47', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 48 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(48, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('48', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 49 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(49, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('49', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 50 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(50, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('50', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 51 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(51, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('51', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 52 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(52, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('52', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 53 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(53, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('53', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 54 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(54, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('54', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 55 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(55, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('55', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 56 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(56, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('56', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 57 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(57, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('57', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 58 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(58, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('58', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 80 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(80, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('80', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 81 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(81, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('81', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 82 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(82, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('82', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 83 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(83, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('83', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 84 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(84, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('84', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 85 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(85, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('85', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 86 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(86, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('86', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 87 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(87, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('87', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'B00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, 'B00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'B00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'B11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'B11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, 'B11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'B11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'D00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, 'D00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'D00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'D11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = 'D11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, 'D11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', 'D11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '226')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '226')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '226') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '226')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '227')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '227')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '227') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '227')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '232')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '232')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '232') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '232')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '153')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '153')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '153') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '153')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '161')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '161')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '161') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '161')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '167')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '167')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '167') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '167')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '154')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '154')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '154') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '154')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '283')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '283')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '283') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '283')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '224')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '224')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '224') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '224')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '225')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '225')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '225') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '225')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '146')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '146')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '146') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '146')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '148')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '148')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '148') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '148')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '285')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '285')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '285') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '285')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '101')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '101')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '101') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '101')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '093')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 88 AND strProductCode = '093')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(88, @ProductCodeId, '093') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('88', '093')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 41 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(41, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('41', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 41 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(41, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('41', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 42 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(42, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('42', 'M11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '061')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 43 AND strProductCode = '061')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(43, @ProductCodeId, '061') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('43', '061')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = '065')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 43 AND strProductCode = '065')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(43, @ProductCodeId, '065') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('43', '065')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'E00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, @ProductCodeId, 'E00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'E00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'E11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'E11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, @ProductCodeId, 'E11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'E11')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M00')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'M00')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, @ProductCodeId, 'M00') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'M00')
SET @ProductCodeId = (SELECT TOP 1 intProductCodeId FROM tblTFProductCode WHERE intTaxAuthorityId = 14 AND strProductCode = 'M11')
IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFValidProductCode WHERE intReportingComponentId = 44 AND strProductCode = 'M11')
BEGIN INSERT INTO tblTFValidProductCode([intReportingComponentId],[intProductCode],[strProductCode]) VALUES(44, @ProductCodeId, 'M11') END 
INSERT @tblTempSource (intReportingComponentId, strProductCode) VALUES ('44', 'M11')


INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFValidProductCode', intValidProductCodeId, strProductCode, NULL, '', GETDATE() 
FROM tblTFValidProductCode A WHERE NOT EXISTS (SELECT intReportingComponentId, strProductCode FROM @tblTempSource B WHERE A.strProductCode = B.strProductCode AND A.intReportingComponentId = B.intReportingComponentId)

GO
PRINT 'END TF tblTFValidProductCode'
GO