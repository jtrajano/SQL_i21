﻿GO
PRINT 'START TF tblTFTerminalControlNumber'
GO

DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'ME'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1000') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1000', 'Buckeye Terminals, LLC - Bangor', '730 Lower Main Street', 'Bangor', '04401-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1002') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1002', 'Coldbrook Energy, Inc.', '809 Main Road No', 'Hampden', '04444-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1003') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1003', 'Sprague Operating Resources LLC - So. Portland', '59 Main Street', 'South Portland', '04106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1004') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1004', 'Buckeye Development & Logistics II LLC', '170 Lincoln Street', 'South Portland', '04106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1006') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1006', 'Irving Oil Terminals, Inc', 'Station Ave', 'Searsport', '04974-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1008') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1008', 'Gulf Oil LP - South Portland', '175 Front St', 'South Portland', '04106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1009') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1009', 'Global Companies LLC', 'One Clarks Road', 'South Portland', '04106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1010') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1010', 'CITGO - South Portland', '102 Mechanic Street', 'South Portland', '04106-2828') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1012') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1012', 'Webber Tanks, Inc. -  Bucksport', 'Drawer CC River Road', 'Bucksport', '04416-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-01-ME-1015') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-01-ME-1015', 'Sprague Operating Resources LLC - Mack Point', '70 Trundy Road', 'Searsport', '04974') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NH'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-02-NH-1050') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-02-NH-1050', 'Sprague Operating Resources LLC - Newington', '372 Shattuck Way', 'Newington', '03801') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-02-NH-1056') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-02-NH-1056', 'Irving Oil Terminals, Inc.', '50 Preble Way', 'Portsmouth', '03801-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-NH-1057') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-NH-1057', 'Sprague Operating Resources LLC - Newington', '194 Shattuck Way', 'Newington', '03801') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1151') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1151', 'L. E. Belcher, Inc.', '615 St James Ave', 'Springfield', '01109-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1152') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1152', 'Global Companies LLC', '11 Broadway', 'Chelsea', '02150') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1153') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1153', 'Gulf Oil LP - Chelsea', '281 Eastern Ave.', 'Chelsea', '02150-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1154') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1154', 'Sunoco Partners Marketing & Terminals LP', '580 Chelsea Street', 'East Boston', '02128-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1155') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1155', 'CITGO Petroleum Corporation', '385 Quincy Ave', 'Braintree', '02184-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1156') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1156', 'ExxonMobil Oil Corp.', '52 Beacham Street', 'Everett', '02149-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1158') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1158', 'F L Roberts Inc', '275 Albany St.', 'Springfield', '01105') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1159') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1159', 'Springfield Terminals, Inc.', '1095 Page Blvd.', 'Springfield', '01104') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1160') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1160', 'Irving Oil Terminals, Inc.', '41 Lee Burbank Highway', 'Revere', '02151-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1162') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1162', 'Global Companies LLC', '140 Lee Burbank Hwy', 'Revere', '02454') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1164') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1164', 'Global Companies LLC', '3 Coast Guard Road', 'Sandwich', '02563-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1166') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1166', 'Global Companies LLC', '160 Rocus St.', 'Springfield', '01104-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1167') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1167', 'L. E. Belcher, Inc.', '195 Armory St.', 'Springfield', '01105') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1168') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1168', 'Buckeye Terminals, LLC - Springfield ', '145 Albany Street', 'Springfield', '01105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1171') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1171', 'Swissport Fueling, Inc.', 'Boston Logan Intl Airport', 'East Boston', '02128') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1172') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1172', 'Sprague Operating Resources LLC - New Bedford', '30 Pine St.', 'New Bedford', '02740-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1173') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1173', 'Harbor Fuel Oil Corp.', 'New Whale St', 'Nantucket', '02554-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1174') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1174', 'Albany Street Terminals LLC', '167 Albany Street', 'Springfield', '01105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1176') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1176', 'Sprague Operating Resources LLC - Quincy', '728 Southern Artery', 'Quincy', '02169') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1179') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1179', 'Springfield Terminals, Inc.', '1053 Page Blvd.', 'Springfield', '01104-1697') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1180') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1180', 'Sprague Operating Resources LLC - Quincy', '740 Washington St.', 'Quincy', '02169-7333') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-04-MA-1181') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-04-MA-1181', 'Suburban Heating ', '60 Hannon St.', 'Springfield', '01105') END

END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'RI'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-05-RI-1201') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-05-RI-1201', 'Sprague Operating Resources LLC - Providence', '144 Allens Avenue', 'Providence', '02903-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-05-RI-1202') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-05-RI-1202', 'NE Petroleum Terminal LLC', '130 Terminal Rd', 'Providence', '02905-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-05-RI-1203') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-05-RI-1203', 'Capitol Terminal Company', '100 Dexter Road', 'East Providence', '02914-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-05-RI-1205') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-05-RI-1205', 'Motiva Enterprises LLC', '520 Allens Avenue', 'Providence', '02905-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-05-RI-1207') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-05-RI-1207', 'ExxonMobil Oil Corp.', '1001 Wampanoag Trail', 'East Providence', '02915-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-RI-1208') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-RI-1208', 'Inland Fuel Terminal, Inc.', '25 State Ave.', 'Tiverton', '02878') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'CT'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1251') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1251', 'Sprague Operating Resources LLC - Stamford', '10 Water St', 'Stamford', '06902-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1252') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1252', 'CITGO - Rocky Hill', '109 Dividend Road', 'Rocky Hill', '06067-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1254') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1254', 'Motiva Enterprises LLC', '481 East Shore Parkway', 'New Haven', '06512-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1255') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1255', 'Buckeye Terminals, LLC  - Groton', '443 Eastern Point Road', 'Groton', '06340-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1256') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1256', 'Sprague Operating Resources LLC - Bridgeport', '250 Eagles Nest Rd.', 'Bridgeport', '06607-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1258') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1258', 'New Haven Terminal, Inc.', '100 Waterfront St', 'New Haven', '06512-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1259') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1259', 'Buckeye Terminals, LLC - Wethersfield', '50 Burbank Road', 'Wethersfield', '06109-9998') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1262') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1262', 'Gulf Oil LP - New Haven', '500 Waterfront Street', 'New Haven', '06512-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1263') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1263', 'Magellan Terminals Holdings LP', '134 Forbes Avenue', 'New Haven', '06512-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1264') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1264', 'Waterfront Terminal', '400 Waterfront St.', 'New Haven', '06512-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1265') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1265', 'Magellan Terminals Holdings LP', '85 East Street', 'New Haven', '06536') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1267') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1267', 'Global Companies LLC', 'One Eagles Nest Rd', 'Bridgeport', '06605') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1269') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1269', 'Safety-Kleen Systems ', '56 Brownstone Ave.', 'Portland', '06480') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1270') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1270', 'Global Companies LLC', '80 Burbank Road', 'Wethersfield', '06109-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1271') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1271', 'Aircraft Service International, Inc.', 'Park Rd', 'Windsor Locks', '06096') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1274') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1274', 'Magellan Terminals Holdings LP', '280 Waterfront St', 'New Haven', '06512-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1279') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1279', 'Inland Fuel Terminal, Inc.', '154 Admiral St.', 'Bridgeport', '06605-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1280') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1280', 'B & B Petroleum, Inc.', '22 Brownstone Ave', 'Portland', '06480-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1281') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1281', 'Hall & Muska, Inc.', '152 Broad Brook Rd', 'Broad Brook', '06016-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1282') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1282', 'Anthony Troiano & Sons, Inc.', '777 Enfield St.', 'Enfield', '06082-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1285') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1285', 'HOP Energy, LLC', '410 Bank St.', 'New London', '06320-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-06-CT-1286') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-06-CT-1286', 'Sterling St. Terminal LLC', '1351 Main Street', 'East Hartford', '06108') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NY'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1301') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1301', 'BP Products North America Inc', '125 Apollo St.', 'Brooklyn', '11222-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1302') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1302', 'United Metro Energy Corp', '498 Kingsland Avenue', 'Brooklyn', '11222-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1304') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1304', 'Arc Terminals Holdings LLC', '25 Paidge Ave.', 'Brooklyn', '11222-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1305') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1305', 'Global Companies LLC', '464 Doughty Blvd', 'Inwood', '11696-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1306') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1306', 'Lefferts Oil Terminal, Inc.', '31-70 College Point Blvd', 'Flushing', '11354-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1308') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1308', 'Buckeye Terminals, LLC - Brooklyn', '722 Court Street', 'Brooklyn', '11231-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1309') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1309', 'Global Companies LLC', 'Shore & Glenwood Rd', 'Glenwood Landing', '11547-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1310') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1310', 'Northville Industries Corp  - Holtsville', '586 Union Ave.', 'Holtsville', '11742-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1312') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1312', 'Motiva Enterprises LLC', '74 East Avenue', 'Lawrence', '11559-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1318') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1318', 'United Riverhead Terminal', '212 Sound Shore Road', 'Riverhead', '11901-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1324') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1324', 'Carbo Industries, Inc.', '1 Bay Blvd', 'Lawrence', '11559-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1325') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1325', 'Bayside Fuel Oil Depot Corp.', '1100 Grand Street', 'Brooklyn', '11211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1326') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1326', 'Bayside Fuel Oil Depot Corp.', '1776 Shore Parkway', 'Brooklyn', '11214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1332') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1332', 'Bayside Fuel Oil Depot Corp.', '537 Smith Street', 'Brooklyn', '11231') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1333') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1333', 'The Energy Conservation Group LLC', '119-02 23rd Ave.', 'College Point', '11356') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1334') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1334', 'Allied New York Services Inc.', 'Bldg. #90 (JFK Intl. Airport)', 'Jamaica', '11430') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1335') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1335', 'Allied Aviation Service of New York', 'Fuel Facility, Bldg #42', 'Flushing', '11371') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-11-NY-1336') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-11-NY-1336', 'Global Commander Terminal', 'One Commander Square', 'Oyster Bay', '11771') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-13-NY-1352') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-13-NY-1352', 'Sprague Operating Resources LLC - Bronx', '939 E. 138th St.', 'Bronx', '10454') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-13-NY-1353') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-13-NY-1353', 'Buckeye Terminals, LLC - Bronx', '1040 East 149th Street', 'Bronx', '10455-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-13-NY-1356') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-13-NY-1356', 'Sprague Operating Resources LLC - Mt. Vernon', '40 Canal St.', 'Mount Vernon', '10550-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-13-NY-1357') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-13-NY-1357', 'Fred M. Schildwachter & Sons', '1400 Ferris Place', 'Bronx', '10461-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-13-NY-1358') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-13-NY-1358', 'Meenan Oil Co. - Peekskill', '26 Bayview Drive', 'Cortlandt Manor', '10567') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-13-NY-1360') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-13-NY-1360', 'Westmore Fuel Co., Inc.', '2 Purdy Ave', 'Port Chester', '10573-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1401') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1401', 'Buckeye Albany Terminal LLC', '301 Normanskill St.', 'Albany', '12202-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1402') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1402', 'CITGO Petroleum Corporation - Glenmont', '495 River Road', 'Glenmont', '12077-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1403') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1403', 'Global Companies LLC', '50 Church Street', 'Albany', '12202-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1404') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1404', 'Petroleum Fuel & Terminal - Albany', '54 Riverside Avenue', 'Rensselaer', '12144-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1405') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1405', 'Center Point Terminal - Glenmont', 'Route 144 552 River Road', 'Glenmont', '12077-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1411') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1411', 'Global Companies LLC', '1096 River Rd.', 'New Windsor', '12553') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1413') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1413', 'Global Companies LLC', '1281 River Road', 'New Windsor', '12551-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1414') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1414', 'Global Companies LLC', '1184 River Road', 'New Windsor', '12553-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1415') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1415', 'Buckeye Terminals, LLC - Rensselaer', '367 American Oil Rd.', 'Rensselaer', '12144-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1417') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1417', 'Sprague Operating Resources LLC - Rensselaer', '58 Riverside Avenue', 'Rensselaer', '12144-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1421') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1421', 'Buckeye Terminals, LLC - Newburgh', '924 River Road', 'Newburgh', '12550') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1422') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1422', 'Meenan Oil Co .- Poughkeepsie', '99 Prospect St.', 'Poughkeepsie', '12601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-14-NY-1423') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-14-NY-1423', 'New Hamburg Terminal Corp.', 'Point Street', 'New Hamburg', '12590') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1451') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1451', 'Buckeye Terminals, LLC - Binghamton', '3301 Old Vestal Rd', 'Vestal', '13850-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1454') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1454', 'CITGO - Vestal', '3212 Old Vestal Road', 'Vestal', '13850-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1456') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1456', 'Buckeye Terminals, LLC - Brewerton', '777 River Road - Cty Rd 37', 'Brewerton', '13029-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1457') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1457', 'United Refining Co. - Tonawanda', '4545 River Road', 'Tonawanda', '14150-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1458') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1458', 'Buckeye Terminals, LLC - Buffalo', '625 Elk St.', 'Buffalo', '14210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1459') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1459', 'Noco Energy Corp.', '700 Grand Island Blvd.', 'Tonawanda', '14151-0086') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1461') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1461', 'IPT, LLC', 'End of Riverside Extension', 'Rennselaer', '12144') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1463') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1463', 'Buckeye Terminals, LLC - Marcy', '9586 River Road', 'Marcy', '13403-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1468') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1468', 'Buckeye Terminals, LLC - Rochester', '754 Brooks Ave.', 'Rochester', '14619-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1469') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1469', 'Buckeye Terminals, LLC - Rochester ', '1975 Lyell Avenue', 'Rochester', '14606-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1470') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1470', 'Superior Plus Energy Services Inc. - Rochester', '335 McKee Rd', 'Rochester', '14611-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1471') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1471', 'Superior Plus Energy Services Inc. - Big Flats', '3351 St. Rt. 352', 'Big Flats', '14814-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1472') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1472', 'Buckeye Terminals, LLC - Rochester II', '675 Brooks Avenue', 'Rochester', '14619-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1473') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1473', 'Sunoco Partners Marketing & Terminals LP', '1840 Lyell Avenue', 'Rochester', '14606-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1474') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1474', 'United Refining Co. - Rochester', '1075 Chili Avenue', 'Rochester', '14624-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1476') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1476', 'Sunoco Partners Marketing & Terminals LP', '6700 Herman Rd.', 'Warners', '13164-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1484') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1484', 'Sunoco Partners Marketing & Terminals LP', '3733 River Road', 'Tonawanda', '14150-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1486') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1486', 'Buckeye Terminals, LLC - Utica', '37 Wurz Avenue', 'Utica', '13502-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1488') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1488', 'Buckeye Terminals, LLC - Vestal', '3113 Shippers Rd.', 'Vestal', '13851-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1493') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1493', 'Superior Plus Energy Services Inc. - Marcy', '9678 River Road, Rt. 49', 'Marcy', '13403-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1494') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1494', 'Center Point Terminal - Rochester', '1935 Lyell Avenue', 'Rochester', '14606-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1497') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1497', 'Heritagenergy Inc.', '1 Deleware Ave.', 'Kingston', '12401-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-16-NY-1499') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-16-NY-1499', 'Global Companies LLC', '1254 River Road', 'New Windsor', '12553') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NJ'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1500') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1500', 'Buckeye Terminals, LLC - Bayonne', 'Lower Hook Road', 'Bayonne', '07002-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1502') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1502', 'Buckeye Terminals, LLC - Newark ', '1111 Delanny St.', 'Newark', '07105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1503') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1503', 'IMTT - Bayonne', '250 East 22nd St.', 'Bayonne', '07002') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1504') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1504', 'Interstate Storage & Pipeline Corp.', '1715 Burlington-Jacksonville', 'Bordentown', '08505') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1506') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1506', 'BP Products North America Inc', '760 Roosevelt Avenue', 'Carteret', '07008-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1507') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1507', 'Kinder Morgan Liquids Terminals LLC', '78 Lafayette Street', 'Carteret', '07008-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1512') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1512', 'Phillips 66 PL - Tremley PT', 'Foot of South Wood Ave', 'Linden', '07036-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1513') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1513', 'CITGO Petroleum Corporation - Linden', '4801 Foot of South Wood Avenue', 'Linden', '07036-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1514') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1514', 'Phillips 66 PL - Linden', '1100 Rte # 1', 'Linden', '07036-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1515') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1515', 'Gulf Oil LP - Linden', '2600 Marshdock Road', 'Linden', '07036-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1516') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1516', 'NuStar Terminals Operations Partnership L. P. - Linden', '3700 Ft. of S. Wood Avenue', 'Linden', '07036-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1517') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1517', 'Sunoco Partners Marketing & Terminals LP', '825 Clonmell Rd.', 'Paulsboro', '08066') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1521') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1521', 'Motiva Enterprises LLC', '909 Delancy Street', 'Newark', '07105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1522') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1522', 'Center Point Terminal - Newark', '678 Doremus Ave', 'Newark', '07105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1523') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1523', 'Sunoco Partners Marketing & Terminals LP', '436 Doremus Avenue', 'Newark', '07105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1525') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1525', 'Plains Products Terminals LLC', '3rd St & Billingsport Road', 'Paulsboro', '08066-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1526') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1526', 'NuStar Logistics, L. P. - Paulsboro', 'N. Delaware St.', 'Paulsboro', '08066-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1528') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1528', 'Buckeye Terminals, LLC - Pennsauken', '123 Derousse  Avenue', 'Pennsauken', '08110-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1531') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1531', 'Buckeye Terminals, LLC - Perth Amboy', '380 Mauer Road ', 'Perth Amboy', '08861-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1532') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1532', 'Allied Aviation Service of New Jersey', 'North Avenue & Division St.', 'Elizabeth', '07201') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1534') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1534', 'Sunoco Partners Marketing & Terminals LP', '1028 Stelton Road', 'Piscataway', '08854-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1535') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1535', 'Buckeye Terminals, LLC - Port Reading', 'Cliff Road', 'Port Reading', '07064-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1538') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1538', 'Motiva Enterprises LLC', '111 State Street', 'Sewaren', '07077-0188') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1540') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1540', 'Gulf Oil LP - Thorofare', '920 Kings Highway', 'Thorofare', '08086-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1544') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1544', 'Sunoco Partners Marketing & Terminals LP', '1000 Crown Point Rd', 'Westville', '08093') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1545') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1545', 'Buckeye Terminals, LLC - Perth Amboy', 'Smith Street & Convery Blvd.', 'Perth Amboy', '08861-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1547') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1547', 'Duck Island Terminal, Inc.', '1463 Lamberton Road', 'Trenton', '08677-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-22-NJ-1548') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-22-NJ-1548', 'SLF, Inc. T/A Consumers Oil', '1473 Lamberton Road', 'Trenton', '08611-') END

END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'PA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1700') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1700', 'Buckeye Terminals, LLC - Macungie', '5198 Buckeye Road', 'Macungie', '18062-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1701') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1701', 'Pyramid LLC - Allentown', '1134 North Quebec Street', 'Allentown', '18103-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1702') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1702', 'Buckeye Terminals, LLC - Macungie BES ', '5285 Shipper Road', 'Macungie', '18062-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1703') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1703', 'Gulf Oil LP  - Dupont', '674  Suscon Rd', 'Pittston Township', '18641-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1707') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1707', 'Pyramid LLC - Du Pont', '675 Suscon Road', 'Pittston', '18641') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1709') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1709', 'Superior Plus Energy Services Inc. - Montoursville', '112 Broad St', 'Montoursville', '17754-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1710') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1710', 'Sunoco Partners Marketing & Terminals LP', '601 East Lincoln Hwy', 'Exton', '19341-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1711') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1711', 'Sunoco Partners Marketing & Terminals LP', '2480 Main St', 'Whitehall', '18052-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1713') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1713', 'Pyramid LLC - Harrisburg', '5140 Paxton Street', 'Harrisburg', '17111-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1715') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1715', 'Pyramid LLC - Mechanicsburg', '127 Texaco Drive', 'Mechanicsburg', '17050-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1716') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1716', 'Pyramid LLC - Highspire', '900 Eisenhower Blvd', 'Middletown', '17057-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1718') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1718', 'Buckeye Terminals, LLC - Malvern', '8 South Malin Rd', 'Frazer', '19406-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1720') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1720', 'Sunoco Partners Marketing & Terminals LP', '60 S Wyoming Avenue', 'Edwardsville', '18704-3102') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1721') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1721', 'Pyramid LLC - Lancaster', '1360 Manheim Pike', 'Lancaster', '17604-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1722') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1722', 'Sunoco Partners Marketing & Terminals LP', 'Lincoln Hwy & Malin Road', 'Malvern', '19355-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1725') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1725', 'Gulf Oil LP - Mechanicsburg', '5125 Simpson Ferry Rd', 'Mechanicsburg', '17055-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1726') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1726', 'Sunoco Partners Marketing & Terminals LP', '5145 Simpson Ferry Road', 'Mechanicsburg', '17055-3626') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1727') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1727', 'Sunoco Partners Marketing & Terminals LP', 'Fritztown Road', 'Sinking Spring', '19608-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1728') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1728', 'Pyramid LLC - Northumberland', 'Rt 11 North RD 1', 'Northumberland', '17857-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1729') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1729', 'Sunoco Partners Marketing & Terminals LP', 'Rt 11 North Rd 1', 'Northumberland', '17857-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1730') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1730', 'Plains Products Terminals LLC', '1630 South 51st Street', 'Philadelphia', '19143-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1731') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1731', 'Kinder Morgan Liquids Terminals LLC', '63rd & Passyunk Avenue', 'Philadelphia', '19153-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1732') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1732', 'Monroe Energy LLC', 'G Street & Hunting Park Ave.', 'Philadelphia', '19124-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1733') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1733', 'Global Companies LLC', 'Shippers Lane', 'Macungie', '18062-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1734') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1734', 'Plains Products Terminals LLC', '6850 Essington Avenue', 'Philadelphia', '19153-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1736') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1736', 'Sunoco Partners Marketing & Terminals LP', '2700 W Passyunk Avenue', 'Philadelphia', '19145-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1737') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1737', 'Plains Products Terminals LLC', '3400 S. 67th Street', 'Philadelphia', '19153-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1742') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1742', 'Pyramid LLC - Sinking Spr', '901 Mountain Home Rd', 'Sinking Spring', '19608-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1743') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1743', 'Buckeye Terminals, LLC - South Williamsport', '1466 Sylvan Dell Road', 'South Williamsport', '17701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1744') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1744', 'Sunoco Partners Marketing & Terminals LP', 'Tuscarora State  Park Rd', 'Tamaqua', '18252-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1746') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1746', 'Sunoco Partners Marketing & Terminals LP', '4041 Market Street', 'Aston', '19014-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1747') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1747', 'Sunoco, LLC', '100 Green St', 'Marcus Hook', '19061') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1748') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1748', 'Gulf Oil LP - Whitehall', '2451 Main Street', 'Whitehall', '18052-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1749') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1749', 'Gulf Oil LP - Williamsport', 'Sylvan Dell Rd', 'Williamsport', '17703-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1751') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1751', 'Sunoco Partners Marketing & Terminals LP', '3290 Sunset Lane', 'Hatboro', '19040-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1752') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1752', 'Buckeye Terminals, LLC - Tuckerton', '130 Whitman Road', 'Reading', '19605-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1753') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1753', 'Meenan Oil Co. - Tullytown', '113 Main St.', 'Tullytown', '19007-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1755') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1755', 'HOP Energy, LLC', '501 E. Hunting Park Ave.', 'Philadelphia', '19124-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1757') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1757', 'Sunoco Partners Marketing & Terminals LP', 'Hewes Ave & Philadelphia Pike', 'Marcus Hook', '19061') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1761') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1761', 'Kinder Morgan Liquids Terminals LLC', '3300 N. Deleware Avenue', 'Philadelphia', '19134') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1764') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1764', 'American Refining - Bradford', '77 North Kendall Ave.', 'Bradford', '16701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1766') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1766', 'Aircraft Service International, Inc.', '550 Tower Rd ', 'Pittsburgh', '15231') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-23-PA-1770') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-23-PA-1770', 'Aircraft Service International, Inc.', 'Philadelphia Internl Airport', 'Philadelphia', '19153') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1759') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1759', 'Pyramid LLC - Coraopolis', '520 University Blvd', 'Coraopolis', '15108') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1760') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1760', 'Buckeye Pipe Holdings, L.P. - Coraopolis', '520 University Blvd', 'Coraopolis', '15108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1761') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1761', 'Sunoco Partners Marketing & Terminals LP', '1734 Old Route 66 ', 'Delmont', '15626-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1762') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1762', 'Watco Transloading LLC', '702 Washington Avenue', 'Dravosburg', '15034-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1767') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1767', 'Pyramid LLC - Eldorado', 'Burns Avenue', 'Altoona', '16603-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1769') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1769', 'Buckeye Terminals, LLC - Greensburg', 'Rural Delivery 6', 'Greensburg', '15601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1771') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1771', 'Kinder Morgan Transmix Co., LLC', 'State Route 910', 'Indianola', '15051-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1773') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1773', 'Marathon Petroleum - Midland', '3852 Rt. 68', 'Midland', '15059-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1776') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1776', 'Pyramid LLC - Pittsburgh', '2760 Neville Road', 'Pittsburgh', '15225-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1777') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1777', 'Gulf Oil LP - Pittsburgh', '400 Grand Ave', 'Pittsburgh', '15225-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1778') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1778', 'Gulf Oil LP - Pittsburgh/Delmont', '6433 Route 22', 'Delmont', '15626-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1780') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1780', 'Pyramid LLC - Corapolis', '520 University Blvd', 'Coraopolis', '15108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1781') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1781', 'Sunoco Partners Marketing & Terminals LP', '5733 Butler Street', 'Pittsburgh', '15201-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1783') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1783', 'United Refining Co. - Warren', '15 Bradley St', 'Warren', '16365-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1785') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1785', 'Gulf Oil LP - Altoona', '6033 Sixth Avenue', 'Altoona', '16602-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1788') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1788', 'Sunoco Partners Marketing & Terminals LP', 'Route 764 Sugar Run Road', 'Altoona', '16601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1789') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1789', 'Sunoco Partners Marketing & Terminals LP', 'Route 68 & Division Lane', 'Vanport', '15009-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1790') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1790', 'Guttman Realty Co. - Belle Vernon', '200 Speers Road', 'Belle Vernon', '15012-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1791') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1791', 'Sunoco Partners Marketing & Terminals LP', 'Freeport Road & Boyd Avenue', 'Pittsburgh', '15238-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-25-PA-1792') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-25-PA-1792', 'Buckeye Terminals, LLC - Pittsburgh', 'Access State Route 51', 'Coraopolis', '15108-') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3100') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3100', 'Marathon Cincinnati', '4015 River Road', 'Cincinnati', '45204') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3101') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3101', 'Marathon Columbus - East', '3855 Fisher Road', 'Columbus', '43228') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3102') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3102', 'Marathon Heath', '840 Heath Road', 'Heath', '43056') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3103') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3103', 'Marathon Marietta', 'Old Rt 7 Moores Junction', 'Marietta', '45750') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3104') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3104', 'BP Products North America Inc', '930 Tennessee Avenue', 'Cincinnati', '45229') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3105') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3105', 'Buckeye Terminals, LLC - Columbus', '303 North Wilson Road', 'Columbus', '43204') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3106') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3106', 'BP Products North America Inc', '621 Brandt Pike', 'Dayton', '45404') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3109') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3109', 'Aircraft Service International, Inc.', '5912 Cargo Rd.', 'Cleveland', '44181') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3111') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3111', 'Sunoco Partners Marketing & Terminals LP', '3866 Fisher Rd', 'Columbus', '43228') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3112') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3112', 'Marathon Columbus - West', '4125 Fisher Rd', 'Columbus', '43228-1021') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3113') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3113', 'Marathon Lebanon', '999 West State Rt.122', 'Lebanon', '45036') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3114') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3114', 'Buckeye Terminals, LLC - Columbus', '3651 Fisher Rd.', 'Columbus', '43228') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3115') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3115', 'Buckeye Terminals, LLC - Dayton', '801 Brandt Pike', 'Dayton', '45404') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3116') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3116', 'Sunoco Partners Marketing & Terminals LP ', '3499 West Broad Street', 'Columbus', '43204') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3117') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3117', 'Sunoco Partners Marketing & Terminals LP', '1708 Farr Drive', 'Dayton', '45404') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3118') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3118', 'ERPC Lebanon', '2700 Hart Road', 'Lebanon', '45036') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3119') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3119', 'ERPC Todhunter', '3590 Yankee Rd.', 'Middletown', '45044') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3120') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3120', 'CITGO - Dublin', '6433 Cosgray Road', 'Dublin', '43016-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3121') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3121', 'CITGO Petroleum Corporation - Dayton', '1800 Farr Drive', 'Dayton', '45404') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3125') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3125', 'Norfolk Southern Railway Co End Terminal', '24424 N. Prairie Rd.', 'Bellevue', '44811') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3127') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3127', 'Norfolk Southern Railway Co End Terminal', '2435 8th Street', 'Portsmouth', '45662') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3128') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3128', 'Buckeye Terminals, LLC - Cincinnati', '5150 River Road', 'Cincinnati', '45233') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-31-OH-3129') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-31-OH-3129', 'BenchMark Biodiesel', '620 Phillipi Road', 'Columbus', '43228') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3140') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3140', 'Marathon Refinery Canton', '2408 Gamfrinus Rd SW', 'Canton', '44706') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3143') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3143', 'Buckeye Terminals, LLC - Canton', '807 Hartford Southeast', 'Canton', '44707') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3144') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3144', 'Buckeye Terminals, LLC - Cuyahoga Hts.', '4850 E 49th Street', 'Cuyahoga Hts.', '44125') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3145') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3145', 'Buckeye Terminals, LLC - Grafton', '12545 S Avon Belden Rd', 'Grafton', '44044') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3146') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3146', 'Buckeye Terminals, LLC - Lima North', '817 West Vine Street', 'Lima', '45804') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3148') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3148', 'Buckeye Terminals, LLC - Toledo', '2450 Hill Avenue', 'Toledo', '43607') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3149') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3149', 'Delta Fuels, Inc.', '1820 South Front', 'Toledo', '43605') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3150') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3150', 'Arc Terminals Holdings LLC', '250 Mahoning Ave', 'Cleveland', '44113-2524') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3151') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3151', 'Marathon Brecksville', '10439 Brecksville Road', 'Brecksville', '44141-3395') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3152') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3152', 'Marathon Lima', '2990 South Dixie Highway', 'Lima', '45804-3721') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3153') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3153', 'Marathon Oregon', '4131 Seaman Road', 'Oregon', '43616-2448') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3154') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3154', 'Marathon Steubenville', '28371 Kingsdale Road', 'Steubenville', '43952-4318') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3155') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3155', 'Marathon Youngstown', '1140 Bears Den Road', 'Youngstown', '44511') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3157') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3157', 'Buckeye Terminals, LLC - Cleveland', '2201 West Third Street', 'Cleveland', '44113-2589') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3158') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3158', 'Buckeye Terminals, LLC - Lima South', '1500 W. Buckeye Road', 'Lima', '45804') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3159') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3159', 'Sunoco Partners Marketing & Terminals LP', '999 Home Avenue', 'Akron', '44310') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3160') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3160', 'Sunoco Partners Marketing & Terminals LP', '3200 Independence Road', 'Cleveland', '44105') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3161') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3161', 'Sunoco Partners Marketing & Terminals LP', '1601 Woodvalle Road', 'Toledo', '43605') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3162') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3162', 'Sunoco Partners Marketing & Terminals LP', '6331 Southern Boulevard', 'Youngstown', '44512') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3164') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3164', 'CITGO - Tallmadge', '1595 Southeast Avenue', 'Tallmadge', '44278') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3165') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3165', 'CITGO Petroleum Corporation - Oregon', '1840 Otter Creek Road', 'Oregon', '43616-7676') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3166') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3166', 'Marathon Bellevue', 'Rural Route 4', 'Bellevue', '44811') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3167') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3167', 'Buckeye Terminals, LLC - Niles', '1001 Youngstown  Warren Rd', 'Niles', '41446-4620') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3168') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3168', 'Guttman Realty Co. - BTS East', 'DBA Bulk Terminal Storage', 'Aurora', '44202-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3169') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3169', 'Arc Terminals Holdings LLC', '2844 Summit St', 'Toledo', '43611-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3174') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3174', 'TransMontaigne - E Liverpool', '425 River Rd.', 'East Liverpool', '43920-0000') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3175') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3175', 'BP Products North America Inc', '5241 Secondary Road', 'Cleveland', '44135') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-34-OH-3176') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-34-OH-3176', 'Lima Refining Company', '1150 S Metcalf', 'Lima', '45804') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'CA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4744') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4744', 'Rancho LPG Holdings', '2110 North Gaffey Street', 'San Pedro', '90731') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4745') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4745', 'Vopak Terminal Los Angeles, Inc.', '401 Canal Street', 'Wilmington', '90744') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4746') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4746', 'Shell Oil Products US', '20945 South Wilmington Ave', 'Carson', '90810') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4747') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4747', 'Wespac Pipelines - San Diego Ltd', '961 E. Harbor Dr.', 'San Diego', '92101') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4748') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4748', 'BNSF - Commerce', '6300 E Sheila St', 'Commerce', '90040') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4749') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4749', 'BNSF - Barstow', '200 North Avenue H', 'Barstow', '92311') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4750') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4750', 'ExxonMobil Oil Corp.', '1477 Jefferson', 'Anaheim', '92807') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4751') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4751', 'Kinder Morgan Tank Storage Terminal LLC', '2000 East Sepulveda Blvd.', 'Carson', '90810-1995') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4753') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4753', 'Tesoro Logistics Operations LLC', '2395 S Riverside Avenue', 'Bloomington', '92316-2931') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4757') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4757', 'SFPP, LP', '2359 S. Riverside Avenue', 'Bloomington', '92316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4758') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4758', 'Shell Oil Products US', '2307 S. Riverside Ave.', 'Colton', '92316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4760') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4760', 'Phillips 66 PL - Colton', '271 E Slover Avenue', 'Rialto', '92376-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4761') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4761', 'Calnev Pipe Line, LLC', '34277 Yermo Daggett Rd', 'Daggett', '92327-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4763') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4763', 'SFPP, LP', '345 W Aten Road', 'Imperial', '92251-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4764') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4764', 'Tesoro Logistics Operations LLC', '5905 Paramount Blvd.', 'Long Beach', '90805-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4765') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4765', 'Paramount Petroleum Corp.', '2400 E. Artesia Bl.', 'Long Beach', '90805') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4767') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4767', 'Petro-Diamond Terminal Company', '1920 Lugger Way', 'Long Beach', '90813-2634') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4768') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4768', 'Tesoro Logistics Operations LLC', '1926 E. Pacific Coast Hwy', 'Wilmington', '90744-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4769') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4769', 'Tesoro Logistics Operations LLC', '2149 E. Sepulreda Blvd.', 'Carson', '90749-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4771') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4771', 'Chevron USA, Inc.- Huntington Beach', '17881 Gothard St.', 'Huntington Beach', '92647-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4772') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4772', 'SFPP, LP', '1350 North Main Street', 'Orange', '92667-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4773') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4773', 'Chevron USA, Inc.- San Diego', '2351 E. Harbor Drive', 'San Diego', '92113-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4776') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4776', 'SFPP, LP', '9950 San Diego Mission Road', 'San Diego', '92108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4779') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4779', 'Chemoil Terminals Corporation', '2365 E. Sepulveda Blvd.', 'Long Beach', '90810-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4782') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4782', 'Tesoro Logistics Operations LLC', '2295 E. Harbor Drive', 'San Diego', '92113-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4784') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4784', 'Tesoro Logistics Operations LLC', '2350 Hathaway Drive', 'Signal Hill', '90806-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4785') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4785', 'Shell Oil Products US', '2457 Redondo Ave.', 'Signal Hill', '90806-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4786') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4786', 'ExxonMobil Oil Corp.', '3700 West 190th Street', 'Torrance', '90509-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4787') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4787', 'Shore Terminals LLC - Wilmington', '841 La Paloma', 'Wilmington', '90744') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4788') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4788', 'Allied Aviation Fueling Co., Inc.', '3698 C Pacific Highway', 'San Diego', '92138') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4789') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4789', 'Ultramar, Inc. -  Wilmington', '2402 E Anaheim St', 'Wilmington', '90744-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4791') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4791', 'The Jankovich Company', 'Berth 74  (Land)', 'San Pedro', '90733-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4792') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4792', 'Aircraft Service International, Inc.', 'Airport Drive', 'Ontario', '91761') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4794') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4794', 'Union Pacific Railroad Co.', '19700 Slover Ave. PL25000', 'Colton', '92316') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4795') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4795', 'Union Pacific Railroad Co.', '#1 Union Pacific Blvd.', 'Yermo', '92398') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4796') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4796', 'The Jankovich Company', '961 East Harbor Dr.', 'San Diego', '92101') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-CA-4800') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-CA-4800', 'Vopak Terminal Long Beach', '3601 Dock Street', 'San Pedro', '90731') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4600') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4600', 'SFPP, LP - Kinder Morgan', '2570 Hegan Lane', 'Chico', '95927-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4603') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4603', 'Valero Refining Company - Benicia', '3410 East Second Street', 'Benicia', '94510-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4604') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4604', 'Chevron USA, Inc.- Banta', '22888 S. Kasson Rd.', 'Tracy', '95376-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4605') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4605', 'Shore Terminals LLC - Crockett', '90 San Pablo Ave', 'Crockett', '94525-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4606') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4606', 'Chevron USA, Inc.- Eureka', '3400 Christie Street', 'Eureka', '95501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4607') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4607', 'Chevron USA, Inc. - Avon', '611 Solano Way', 'Martinez', '94553-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4609') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4609', 'Buckeye Terminals, LLC - Stockton', '27 West Washington St', 'Stockton', '95203-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4610') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4610', 'Shell Oil Products US - Martinez', '1801 Marina Vista', 'Martinez', '94553-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4611') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4611', 'Tesoro Logistics Operations LLC', '150 Solano Way', 'Martinez', '94553-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4612') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4612', 'Buckeye Terminals, LLC - Sacramento ', '1601 S. River Rd', 'West Sacramento', '95691-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4613') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4613', 'SFPP, LP', '2901 Bradshaw Rd', 'Rancho Cordova', '95741-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4614') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4614', 'BP West Coast Products LLC', '1306 Canal Blvd', 'Richmond', '94807-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4616') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4616', 'Chevron USA, Inc.- Richmond', '155 Castro St', 'Richmond', '94802-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4617') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4617', 'Phillips 66 PL - Richmond', '1300 Canal Blvd', 'Richmond', '94804-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4619') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4619', 'IMTT Richmond, CA', '100 Cutting Blvd.', 'Richmond', '94804-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4621') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4621', 'Chevron USA, Inc.- Sacramento', '2420 Front Street', 'Sacramento', '95818-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4622') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4622', 'Shell Oil Products US - W Sacramento', '1509 South River Road', 'West Sacramento', '95691-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4624') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4624', 'Phillips 66 PL - Sacramento', '76 Broadway', 'Sacramento', '95818-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4626') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4626', 'NuStar Terminals Operations Partnership L. P. - Stockton', '2941 Navy Drive', 'Stockton', '95206-1149') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4628') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4628', 'Shell Oil Products US - Stockton', '3515 Navy Dirve', 'Stockton', '95203-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4629') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4629', 'Tesoro Logistics Operations LLC', '3003 Navy Drive', 'Stockton', '95205-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-68-CA-4632') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-68-CA-4632', 'Allied Aviation Fueling Co., Inc.', '7330 Earhart Drive', 'Sacramento', '95837') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4650') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4650', 'Chevron USA, Inc.- San Jose', '1020 Berryessa Road', 'San Jose', '95133-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4651') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4651', 'SFPP, LP', '4149 South Maple Avenue', 'Fresno', '93725-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4652') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4652', 'SFPP, LP', '2150 Kruse Avenue', 'San Jose', '95131-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4653') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4653', 'Shell Oil Products US', '2165 O Toole Ave.', 'San Jose', '95131-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4655') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4655', 'Kern Oil & Refining Co.', '7724 East Panama Lane', 'Bakersfield', '93307-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4657') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4657', 'Alon Bakersfield', '2436 Fruitvale Avenue', 'Bakersfield', '93302-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4664') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4664', 'San Joaquin Refining Co., Inc.', '3542 Shell St.', 'Bakersfield', '93308-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4665') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4665', 'Seaport Refining & Environmental LLC', '675 Seaport Blvd, 2nd Floor', 'Redwood City', '94063') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-77-CA-4666') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-77-CA-4666', 'Swissport Fueling, Inc.', '2500 Seaboard Ave ', 'San Jose', '95131') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4700') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4700', 'SFPP, LP', '950 Tunnel Av.', 'Brisbane', '94005-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4701') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4701', 'Aircraft Service International, Inc.', 'New Access Rd.', 'San Francisco', '94128') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4702') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4702', 'Swissport Fueling, Inc.', 'Oakland International Airport', 'Oakland', '94603-6366') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4705') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4705', 'Plains Products Terminals LLC', '488 Wright Ave.', 'Richmond', '94802-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4706') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4706', 'Union Pacific Railroad Co.', '1717 Middle Harbor Rd.', 'Oakland', '94607') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4707') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4707', 'Union Pacific Railroad Co.', '9499 Atkinson St.', 'Roseville', '95678') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-94-CA-4708') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-94-CA-4708', 'BNSF - Richmond', '980 Hensley Street Bldg 417', 'Richmond', '94801') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4800') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4800', 'Chevron USA, Inc.- El Segundo', '324 West El Segundo Blvd', 'El Segundo', '90245-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4803') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4803', 'Phillips 66 PL - LA Terminal', '13500 South Broadway', 'Los Angeles', '90061-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4804') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4804', 'Shell Oil Products US', '8100 Haskell Ave.', 'Van Nuys', '91406-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4805') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4805', 'ExxonMobil Oil Corp.', '2709 East 37th Street', 'Vernon', '90058-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4807') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4807', 'Tesoro Logistics Operations LLC', '8601 S. Garfield Ave.', 'South Gate', '90280-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4808') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4808', 'Paramount Petroleum Corp.', '8835 Sommerset Blvd.', 'Paramount', '90723') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4810') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4810', 'Chevron USA, Inc.- Van Nuys', '15359 Oxnard Street', 'Van Nuys', '91411-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4811') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4811', 'Chevron USA, Inc.- Montebella', '601 South Vail Avenue', 'Montebella', '90640-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-95-CA-4812') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-95-CA-4812', 'Aircraft Service International, Inc.', '9900 LAXFuel Rd.', 'Los Angeles', '90045') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-33-WA-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-33-WA-0001', 'Petrogas', '4100 Unick Road', 'Ferndale', '98248') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4400') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4400', 'Shell Oil Products US', 'Marches Point Five Miles', 'Anacortes', '98221-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4401') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4401', 'Phillips 66 PL - Moses Lake', '3 miles north of Moses Lake', 'Moses Lake', '98837-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4402') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4402', 'Tesoro Logistics Operations LLC', '3000 Sacajawea Park Road', 'Pasco', '99301-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4404') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4404', 'Phillips 66 PL - Renton', '2423 Lind Avenue Southwest', 'Renton', '98055-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4406') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4406', 'Kinder Morgan Liquids Terminals LLC', '2720 13th Avenue SW', 'Seattle', '98134-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4408') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4408', 'Shell Oil Products US', '2555 13th Ave. S W', 'Seattle', '98134-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4410') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4410', 'Phillips 66 PL - Spokane', '6317 East Sharp Avenue', 'Spokane', '99206-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4411') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4411', 'ExxonMobil Oil Corp.', '6311 East Sharp Avenue', 'Spokane', '99211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4412') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4412', 'Holly Energy Partners - Operating LP', '3225 East Lincoln Road', 'Spokane', '99217-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4413') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4413', 'Phillips 66 PL - Tacoma', '520 E D Street', 'Tacoma', '98421-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4414') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4414', 'Targa Sound Terminal', '2628 Marine View Drive', 'Tacoma', '98422') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4415') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4415', 'Shore Terminals LLC - Tacoma', '250 East D Street', 'Tacoma', '98421') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4417') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4417', 'NuStar Terminals Operations Partnership L. P. - Vancouver', '5420 Fruit Valley Road', 'Vancouver', '98660-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4418') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4418', 'BP West Coast Products LLC', '4519 Grandview', 'Blaine', '98231-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4419') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4419', 'Tesoro Logistics Operations LLC', '2211 West 26th Street', 'Vancouver', '98660-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4420') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4420', 'Tidewater Terminal - Snake River', 'Tank Farm Road', 'Pasco', '99301-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4421') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4421', 'U.S. Oil & Refining Co.', '3001 Marshall Ave', 'Tacoma', '98421-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4425') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4425', 'BP West Coast Products LLC', '1652 SW Lander St', 'Seattle', '95124-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4427') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4427', 'Phillips 66 Co - Ferndale', '3901 Unic Rd.', 'Ferndale', '98248-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4428') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4428', 'Tesoro Logistics Operations LLC', 'West March Point Road', 'Anacortes', '98221') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4430') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4430', 'NuStar Terminal Services, Inc - Vancouver', 'Port of Vancouver Terminal #2', 'Vancouver', '98666') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4431') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4431', 'Swissport Fueling, Inc.', '2350 South 190th St.', 'Seattle', '98188') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4433') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4433', 'Imperium Grays Harbor', '3122 Port Industrial road ', 'Hoquian ', '98550') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-WA-4434') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-WA-4434', 'BNSF - Pasco', '3490 N Railroad Avenue', 'Pasco', '99301') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3202') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3202', 'Valero Terminaling & Distribution', '1020 141st St', 'Hammond', '46320-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3203') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3203', 'Buckeye Terminals, LLC - Granger', '12694 Adams Rd', 'Granger', '46530') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3204') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3204', 'BP Products North America Inc', '2500 N Tibbs Avenue', 'Indianapolis', '46222') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3205') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3205', 'BP Products North America Inc', '2530 Indianapolis Blvd.', 'Whiting', '46394') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3207') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3207', 'Marathon Evansville', '2500 Broadway', 'Evansville', '47712') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3208') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3208', 'Marathon Huntington', '4648 N. Meridian Road', 'Huntington', '46750') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3209') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3209', 'CITGO Petroleum Corporation - East Chicago', '2500 East Chicago Ave', 'East Chicago', '46312') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3210') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3210', 'CITGO - Huntington', '4393 N Meridian Rd US 24', 'Huntington', '46750') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3211') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3211', 'Gladieux Trading & Marketing Co.', '4757 US 24 E', 'Huntington', '46750') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3212') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3212', 'TransMontaigne - Kentuckiana', '20 Jackson St.', 'New Albany', '47150') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3213') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3213', 'TransMontaigne - Evansville', '2630 Broadway', 'Evansville', '47712') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3214') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3214', 'Countrymark Cooperative LLP', '1200 Refinery Road', 'Mount Vernon', '47620') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3216') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3216', 'HWRT Terminal - Seymour', '9780 N US Hwy 31', 'Seymour', '47274') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3218') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3218', 'Marathon Hammond', '4206 Columbia Avenue', 'Hammond', '46327') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3219') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3219', 'Marathon Indianapolis', '4955 Robison Rd', 'Indianapolis', '46268-1040') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3221') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3221', 'Marathon Muncie', '2100 East State Road 28', 'Muncie', '47303-4773') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3222') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3222', 'Marathon Speedway', '1304 Olin Ave', 'Indianapolis', '46222-3294') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3224') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3224', 'ExxonMobil Oil Corp.', '1527 141th Street', 'Hammond', '46327') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3225') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3225', 'Buckeye Terminals, LLC - East Chicago', '400 East Columbus Dr', 'East Chicago', '46312') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3226') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3226', 'Buckeye Terminals, LLC - Raceway', '3230 N Raceway Road', 'Indianapolis', '46234') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3227') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3227', 'NuStar Terminals Operations Partnership L. P. - Indianapolis', '3350 N. Raceway Rd.', 'Indianapolis', '46234-1163') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3228') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3228', 'Buckeye Terminals, LLC - East Hammond', '2400 Michigan St.', 'Hammond', '46320') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3229') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3229', 'Buckeye Terminals, LLC - Muncie', '2000 East State Rd. 28', 'Muncie', '47303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3230') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3230', 'Buckeye Terminals, LLC - Zionsville', '5405 West 96th St.', 'Indianapolis', '46268') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3231') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3231', 'Sunoco Partners Marketing & Terminals LP', '4691 N Meridian St', 'Huntington', '46750') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3232') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3232', 'ERPC Princeton', 'CR 950 E', 'Oakland City', '47660') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3234') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3234', 'Lassus Bros. Oil, Inc. - Huntington', '4413 North Meridian Rd', 'Huntington', '46750') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3235') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3235', 'Countrymark Cooperative LLP', '17710 Mule Barn Road', 'Westfield', '46074') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3236') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3236', 'Countrymark Cooperative LLP', '1765 West Logansport Rd.', 'Peru', '46970') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3237') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3237', 'Countrymark Cooperative LLP', 'RR # 1, Box 119A', 'Switz City', '47465') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3238') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3238', 'Buckeye Terminals, LLC - Indianapolis', '10700 E County Rd 300N', 'Indianapolis', '46234') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3239') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3239', 'Marathon Mt Vernon', '129 South Barter Street ', 'Mount Vernon', '47620-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3243') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3243', 'CSX Transportation Inc', '491 S. County Road 800 E.', 'Avon', '46123-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3245') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3245', 'Norfolk Southern Railway Co End Terminal', '2600 W. Lusher Rd.', 'Elkhart', '46516-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3246') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3246', 'Buckeye Terminals, LLC - South Bend', '20630 W. Ireland Rd.', 'South Bend', '46614-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3248') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3248', 'West Shore Pipeline Company - Hammond', '3900 White Oak Avenue', 'Hammond', '46320') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-35-IN-3249') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-35-IN-3249', 'NGL Supply Terminal Company LLC - Lebanon', '550 West County Road 125 South', 'Lebanon', '46052') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3300') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3300', 'Valero Terminaling & Distribution', '3600 W 131st Street', 'Alsip', '60803') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3301') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3301', 'BP Products North America Inc', '1111 Elmhurst Rd', 'Elk Grove Village', '60007') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3302') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3302', 'BP Products North America Inc', '4811 South Harlem Avenue', 'Forest View', '60402') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3303') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3303', 'BP Products North America Inc', '100 East Standard Oil Road', 'Rochelle', '61068') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3304') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3304', 'CITGO - Mt.  Prospect', '2316 Terminal Drive', 'Arlington Heights', '60005') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3305') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3305', 'Kinder Morgan Liquids Terminals LLC', '8500 West 68th Street', 'Argo', '60501-0409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3306') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3306', 'Buckeye Terminals, LLC - Rockford', '1511 South Meridian Road', 'Rockford', '61102-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3307') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3307', 'Marathon Mt. Prospect', '3231 Busse Road', 'Arlington Heights', '60005-4610') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3308') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3308', 'Marathon Oil Rockford', '7312 Cunningham Road', 'Rockford', '61102') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3310') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3310', 'NuStar Terminal Services, Inc - Blue Island', '3210 West 131st Street', 'Blue Island', '60406-2364') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3311') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3311', 'ExxonMobil Oil Corp.', '2312 Terminal Drive', 'Arlington Heights', '60005') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3312') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3312', 'Petroleum Fuel & Terminal - Forest View', '4801 South Harlem', 'Forest View', '60402') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3313') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3313', 'Buckeye Terminals, LLC - Kankakee', '275 North 2750 West Road', 'Kankakee', '60901') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3315') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3315', 'Buckeye Terminals, LLC - Argo', '8600 West 71st. Street', 'Argo', '60501') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3316') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3316', 'Shell Oil Products US', '1605 E. Algonquin Road', 'Arlington Heights', '60005') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3317') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3317', 'CITGO - Lemont', '135th & New Avenue', 'Lemont', '60439') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3318') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3318', 'CITGO - Arlington Heights', '2304 Terminal Drive', 'Arlington Heights', '60005') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3320') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3320', 'Magellan Pipeline Company, L.P.', '10601 Franklin Avenue', 'Franklin Park', '60131') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3325') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3325', 'Aircraft Service International, Inc.', 'Chicago O Hare Intl Airport', 'Chicago', '60666') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3326') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3326', 'United Parcel Service Inc', '3300 Airport Dr', 'Rockford', '61109') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3375') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3375', 'ExxonMobil Oil Corporation', '12909 High Road', 'Lockport', '60441-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3376') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3376', 'Aircraft Service International, Inc.', 'Midway Airport', 'Chicago', '60638') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3377') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3377', 'IMTT-Illinois', '24420 W Durkee Road', 'Channahon', '60410') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-36-IL-3378') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-36-IL-3378', 'Oiltanking Joliet', '27100 South Frontage Rd', 'Channahon', '60410') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3351') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3351', 'BP Products North America Inc', '1000 BP Lane', 'Hartford', '62048') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3353') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3353', 'Phillips 66 PL - Hartford', '2150 Delmar', 'Hartford', '62048') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3354') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3354', 'Hartford Wood River Terminal', '900 North Delmar', 'Hartford', '62048') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3356') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3356', 'Buckeye Terminals, LLC - Hartford', '220 E Hawthorne Street', 'Hartford', '62048-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3358') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3358', 'Marathon Champaign', '511 S. Staley Road', 'Champaign', '61821') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3360') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3360', 'Marathon Robinson', '12345 E 1050th Ave', 'Robinson', '62454') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3361') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3361', 'HWRT Terminal - Norris City', 'Rural Route 2', 'Norris City', '62869') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3364') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3364', 'Growmark, Inc.', 'Rt 49 South', 'Ashkum', '60911') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3365') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3365', 'Buckeye Terminals, LLC - Decatur', '266 E Shafer Drive', 'Forsyth', '62535') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3366') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3366', 'Phillips 66 PL - E. St.  Louis', '3300 Mississippi Ave', 'Cahokia', '62206') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3368') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3368', 'Buckeye Terminals, LLC - Effingham', '18264 N US Hwy 45', 'Effingham', '62401') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3369') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3369', 'Buckeye Terminals, LLC - Harristown', '600 E. Lincoln Memorial Pky', 'Harristown', '62537') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3371') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3371', 'Magellan Pipeline Company, L.P.', '16490 East 100 North Rd.', 'Heyworth', '61745') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-37-IL-3372') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-37-IL-3372', 'Growmark, Inc.', '18349 State Hwy 29', 'Petersburg', '62675') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-IL-3729') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-IL-3729', 'Omega Partners III, LLC', '1402 S Delmare', 'Hartford', '62048-0065') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-IL-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-IL-0001', 'West Shore Pipeline Company - Arlington Heights', '3400 South Badger Road', 'Arlington Heights', '60005') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-IL-0002') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-IL-0002', 'West Shore Pipeline Company - Forest View', '5027 South Harlem Avenue', 'Forest View', '60402') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-IL-0003') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-IL-0003', 'West Shore Pipeline Company - Arlington Heights', '3223 Busse Road', 'Arlington Heights', '60005') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-IL-0004') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-IL-0004', 'West Shore Pipeline Company - Rockford', '7245 Cunningham Road', 'Rockford', '61102') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-IL-0005') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-IL-0005', 'IMTT - Lemont', '13589 Main Street', 'Lemont', '60439') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MI'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3001', 'U.S. Oil - Cheboygan', '311 Coast Guard Drive', 'Cheyboygan', '49721') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3002') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3002', 'U.S. Oil - Rogers City', '1035 Calcite Rd.', 'Rogers City', '49779') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3003') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3003', 'Waterfront Petroleum Terminal Co.', '1071 Miller Rd.', 'Dearborn', '48120') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3004') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3004', 'Buckeye Terminals, LLC - Napoleon', '6777 Brooklyn Road', 'Napoleon', '49261') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3005') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3005', 'Buckeye Terminals, LLC - River Rouge', '205 Marion Street', 'River Rouge', '48218') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3006') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3006', 'Buckeye Terminals, LLC - Dearborn', '8503 South Inkster Rd.', 'Taylor', '48180-2114') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3007') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3007', 'Buckeye Pipe Line Holdings, L.P - Taylor', '24801 Ecorse Rd', 'Taylor', '48180') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3008') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3008', 'CITGO - Ferrysburg', '524 Third Street', 'Ferrysburg', '49409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3009') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3009', 'CITGO - Jackson', '2001 Morrill Rd', 'Jackson', '49201') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3010') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3010', 'CITGO - Niles', '2233 South Third', 'Niles', '49120') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3011') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3011', 'Marathon Niles', '2140 South Third St.', 'Niles', '49120') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3012') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3012', 'Cousins Petroleum - Taylor', '7965 Holland', 'Taylor', '48180') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3013') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3013', 'Buckeye Terminals, LLC - Ferrysburg', '17806 North Shore Dr.', 'Ferrysburg', '49409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3014') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3014', 'Buckeye Terminals, LLC - Taylor East', '24501 Ecorse Rd', 'Taylor', '48180') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3015') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3015', 'Marathon Detroit', '12700 Toronto St.', 'Detroit', '48217') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3016') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3016', 'Marathon Flint', '6065 North Dort Highway', 'Mt. Morris', '48458') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3017') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3017', 'Marathon Jackson', '2090 Morrill Rd', 'Jackson', '49201-8238') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3018') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3018', 'Delta Fuel Facility - DTW Metro', 'West. Service Rd.', 'Romulus', '48174') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3019') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3019', 'Marathon Oil Niles', '2216 South Third Street', 'Niles', '49120-4010') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3020') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3020', 'Marathon N. Muskegon', '3005 Holton Rd', 'North Muskegon', '49445-2513') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3022') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3022', 'Buckeye Terminals, LLC - Flint', 'G5340 North Dort Highway', 'Flint', '48505') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3023') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3023', 'Buckeye Terminals, LLC - Niles West', '2150 South Third Street', 'Niles', '49120') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3024') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3024', 'Buckeye Terminals, LLC - Woodhaven', '20755 West Road', 'Woodhaven', '48183-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3025') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3025', 'Buckeye Terminals, LLC - Detroit', '700 S. Deacon Street', 'Detroit', '48217') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3028') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3028', 'Buckeye Terminals, LLC - Niles', '2303 South Third Street', 'Niles', '49120') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3029') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3029', 'Sunoco Partners Marketing & Terminals LP', '4004 West Main Rd', 'Owosso', '48867') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3030') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3030', 'Sunoco Partners Marketing & Terminals LP', '500 South Dix Avenue', 'Detroit', '48217') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3032') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3032', 'Marathon Bay City', '1806 Marquette', 'Bay City', '48706') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3033') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3033', 'Marathon Lansing', '6300 West Grand River', 'Lansing', '48906') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3034') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3034', 'Marathon Romulus', '28001 Citrin Drive', 'Romulus', '48174') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3037') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3037', 'Sonoco Partners Marketing & Terminals LP', '29120 Wick Road', 'Romulus', '48174') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3039') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3039', 'Delta Fuels of Michigan', '40600 Grand River', 'Novi', '48374') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3041') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3041', 'Holland Terminal, Inc.', '630 Ottawa Avenue', 'Holland', '49423') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3043') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3043', 'Buckeye Terminals, LLC - Marshall', '12451 Old US 27 South', 'Marshall', '49068') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3046') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3046', 'Marysville Hydrocarbons', '2510 Busha Highway', 'Marysville', '48040') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-Mi-3047') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-Mi-3047', 'Waterfront Petroleum Terminal Co.', '5431 W Jefferson', 'Detroit', '48209') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-38-MI-3048') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-38-MI-3048', 'Plains LPG Services LP', '1575 Fred Moore Hwy', 'St Clair', '48079') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-IA-3475') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-IA-3475', 'Sinclair Transport.- Montrose, IA', '2506 260th St.', 'Montrose', '52639') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3450') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3450', 'Buckeye Terminals, LLC - Bettendorf', '75 South 31st Street', 'Bettendorf', '52722-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3451') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3451', 'Flint Hills Resources Renewables', '4100 Elm St', 'Bettendorf', '52722-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3452') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3452', 'U.S. Oil - Bettendorf Depot', '2925 Depot Street', 'Bettendorf', '52722-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3454') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3454', 'Buckeye Terminals, LLC - Council Bluffs', '829 Tank Farm Road', 'Council Bluffs', '51503') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3455') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3455', 'National Coop. Refinery', '825 Tank Farm Road', 'Council Bluffs', '51503-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3456') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3456', 'Buckeye Terminals, LLC - Des Moines', '1501 Northwest 86th Street', 'Des Moines', '50325-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3457') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3457', 'Magellan Pipeline Company, L.P.', '2503 Southeast 43rd Street', 'Des Moines', '50317-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3458') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3458', 'BP Products North America Inc', '15393 Old Highway Road.', 'Peosta', '52068') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3460') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3460', 'Magellan Pipeline Company, L.P.', '8038 St Joes Prairie Rd', 'Dubuque', '52003-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3461') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3461', 'Growmark, Inc.', '3140 Two Hundred Street', 'Duncombe', '50532-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3463') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3463', 'Magellan Pipeline Company, L.P.', '912 First Avenue', 'Coralville', '52241-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3464') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3464', 'NuStar Pipeline Operating Partnership, L.P. - Le Mars', 'US Hwy 75/7 Miles N of LeMars', 'Le Mars', '51031-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3465') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3465', 'Magellan Pipeline Company, L.P.', '2810 East Main', 'Clear Lake', '50428-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3466') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3466', 'NuStar Pipeline Operating Partnership, L.P. - Milford', '1 mile W of Milford & Hwy 71', 'Milford', '51351-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3467') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3467', 'Magellan Pipeline Company, L.P.', 'RT #1', 'Milford', '51351-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3468') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3468', 'Buckeye Terminals, LLC - Cedar Rapids', '2092 Hwy. 965 NE', 'North Liberty', '52317-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3469') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3469', 'Buckeye Terminals, LLC - Ottumwa', 'Three miles west on US 34', 'Ottumwa', '52501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3470') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3470', 'Phillips 66 PL - Pleasant Hill', '4500 Vandalia', 'Pleasant Hill', '50327-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3471') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3471', 'Magellan Pipeline Company, L.P.', '312 South Bellingham Street', 'Riverdale', '52722-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3472') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3472', 'NuStar Pipeline Operating Partnership, L.P. - Rock Rapids', 'State Hwy 9', 'Rock Rapids', '51246-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3473') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3473', 'Magellan Pipeline Company, L.P.', '4300 41st Street', 'Sioux City', '51108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-42-IA-3474') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-42-IA-3474', 'Magellan Pipeline Company, L.P.', '5360 Eldora Rd', 'Waterloo', '50701-') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NE'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-NE-3604') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-NE-3604', 'Signature Flight Support Corp.', '3636 Wilbur Plaza', 'Omaha', '68110') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-NE-3612') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-NE-3612', 'Magellan Pipeline Company, L.P.', '13029 S 13th St', 'Bellevue', '68123') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-NE-3613') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-NE-3613', 'Truman Arnold Co. - TAC Air', '3737 Orville Plaza', 'Omaha', '68110') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-NE-3614') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-NE-3614', 'Union Pacific Railroad Co.', '6000 West Front St.', 'North Platte', '69101') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-NE-3615') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-NE-3615', 'BNSF - Lincoln', '201 North 7th Street', 'Lincoln', '68508') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3600') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3600', 'NuStar Pipeline Operating Partnership, L.P. - Columbus', 'R R 5, Box 27 BB', 'Columbus', '68601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3601') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3601', 'NuStar Pipeline Operating Partnership, L.P. - Geneva', 'U S Highway 81', 'Geneva', '68361-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3602') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3602', 'Magellan Pipeline Company, L.P.', '12275 South US Hwy 281', 'Doniphan', '68832-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3603') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3603', 'Phillips 66 PL - Lincoln', '1345 Saltillo Rd.', 'Roca', '68430') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3605') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3605', 'Magellan Pipeline Company, L.P.', '2000 Saltillo Road', 'Roca', '68430') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3606') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3606', 'NuStar Pipeline Operating Partnership, L.P. - Norfolk', 'Highway 81', 'Norfolk', '68701') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3607') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3607', 'NuStar Pipeline Operating Partnership, L.P. - North Platte', 'Rural Route Four', 'North Platte', '69101') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3608') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3608', 'Magellan Pipeline Company, L.P.', '2205 N 11th St', 'Omaha', '68110') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-47-NE-3610') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-47-NE-3610', 'NuStar Pipeline Operating Partnership, L.P. - Osceola', 'Rural Route 1', 'Osceola', '68651') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WI'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3061') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3061', 'U.S. Oil - Green Bay Fox', '1124 North Broadway', 'Green Bay', '54303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3062') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3062', 'Buckeye Terminals, LLC- Granville', '9101 North 107th Street', 'Milwaukee', '53224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3064') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3064', 'CHS Petroleum Terminal - Chippewa Falls', '2331 N Prairie View Rd', 'Chippewa Falls', '54729') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3065') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3065', 'CHS Petroleum Terminal - McFarland', '4103 Triangle St', 'McFarland', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3066') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3066', 'CITGO - Green Bay', '1391 Bylsby Avenue', 'Green Bay', '54303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3067') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3067', 'CITGO - McFarland', '4606 Terminal Drive', 'McFarland', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3068') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3068', 'CITGO - Milwaukee', '9235 North 107th Street', 'Milwaukee', '53224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3070') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3070', 'U.S. Oil - Green Bay Quincy', '2020 N Quincy St', 'Green Bay', '54306-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3071') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3071', 'Flint Hills Resources, LP-Junction City', 'Junction US 10 & 34N', 'Junction City', '54443') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3072') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3072', 'Flint Hills Resources, LP-Madison', '4505 Terminal Drive', 'McFarland', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3073') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3073', 'Flint Hills Resources, LP-Milwaukee', '9343 North 107th Street', 'Milwaukee', '53224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3074') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3074', 'Flint Hills Resources, LP-Waupun', 'Route Two', 'Waupun', '53963') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3075') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3075', 'Marathon Green Bay', '1031 Hurlbut Street', 'Green Bay', '54303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3076') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3076', 'U.S. Oil - Milwaukee West', '9125 North 107th St', 'Milwaukee', '53224-1508') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3077') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3077', 'U.S. Oil - Green Bay Prairie', '410 Prairie Ave', 'Green Bay', '54303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3079') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3079', 'U.S. Oil - Madison Sigglekow', '4516 Sigglekow Road', 'McFarland', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3080') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3080', 'Calumet Superior LLC', '2407 Stinson Ave', 'Superior', '54880') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3081') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3081', 'U.S. Oil - Milwaukee Jones Island', '1626 South Harbor Drive', 'Milwaukee', '53207-1020') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3082') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3082', 'U.S. Oil - Chippewa Falls Prairieview', '3689 N. Prairieview Road', 'Chippewa Falls', '54729') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3083') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3083', 'Arc Terminals Holdings LLC', '4009 Triangle St Hwy 51 S', 'McFarland', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3084') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3084', 'U.S. Oil - Milwaukee South', '9135 North 107th Street', 'Milwaukee', '53224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3086') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3086', 'U.S. Oil - Milwaukee North', '9521 North 107th Street', 'Milwaukee', '53224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3088') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3088', 'U.S. Oil - Madison South', '4402 Terminal Dr', 'Madison', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3089') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3089', 'U.S. Oil - Green Bay Produsts', '1075 Hurlbut Ct', 'Green Bay', '54303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3090') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3090', 'U.S. Oil - Milwaukee Central', '9451 North 107th Street', 'Milwaukee', '53224-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-39-WI-3092') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-39-WI-3092', 'Aircraft Service International, Inc.', '4792 S Howell Ave', 'Milwaukee', '53207') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-WI-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-WI-0001', 'West Shore Pipeline Company - Milwaukee', '11115 West County Line Road', 'Milwaukee', '53224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-WI-0002') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-WI-0002', 'West Shore Pipeline Company - McFarland', '4508 Terminal Road', 'McFarland', '53558') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-WI-0003') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-WI-0003', 'West Shore Pipeline Company - Green Bay', '2119 North Quincy Street', 'Green Bay', '54302') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3400') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3400', 'NuStar Pipeline Operating Partnership, L.P. - Moorhead', '1101 Southeast Main', 'Moorhead', '56560') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3401') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3401', 'NuStar Pipeline Operating Partnership, L.P. - Sauk Centre', '1833 Beltline Rd', 'Sauk Centre', '56378') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3402') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3402', 'BP Products North America Inc', '2 Miles East of U S 16', 'Spring Valley', '55975') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3403') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3403', 'NuStar Pipeline Operating Partnership, L.P. - Roseville', '2288 West County Road C', 'Roseville', '55113') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3404') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3404', 'St Paul Park Refining Co. LLC', '201 Factory Street', 'St. Paul Park', '55071') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3405') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3405', 'Magellan Pipeline Company, L.P.', '10 Broadway Street', 'Wrenshall', '55797') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3406') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3406', 'Newport Terminal Corporation', '50 21st St', 'Newport', '55055') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3407') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3407', 'Flint Hills Resources, LP-Pine Bend', '13775 Clark Rd - Gate 1', 'Rosemount', '55068') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3410') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3410', 'Calumet Superior LLC', '5746 Old Hwy 61', 'Proctor', '55810') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3412') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3412', 'Magellan Pipeline Company, L.P.', '709 Third Ave W', 'Alexandria', '56308') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3413') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3413', 'Magellan Pipeline Company, L.P.', '55199 State Hwy 68', 'Mankato', '56001') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3414') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3414', 'Magellan Pipeline Company, L.P.', '1601 College Dr ', 'Marshall', '56258') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3415') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3415', 'Magellan Pipeline Company, L.P.', '2451 W County Rd C', 'St Paul', '55113') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3416') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3416', 'Magellan Pipeline Company, L.P.', '1331 Hwy 42 Southeast', 'Eyota', '55934') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3417') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3417', 'BNSF - Northtown', '80-44th Ave, N.E.', 'Minneapolis', '55421') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3419') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3419', 'Swissport Fueling Inc', '5001 Post Road ', 'Minneapolis', '55450') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3420') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3420', 'Signature Flight Support Corp.', '3800 East 70th St.', 'Minneapolis', '55450') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3425') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3425', 'Northern States Power Co, Wisconsin', '3008 - 80th Street', 'Eau Claire', '54703') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MN-3426') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MN-3426', 'NGL Supply Terminal Company LLC - Rosemount', '15938 Canada Circle Drive ', 'Rosemount', '55068') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MT'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-41-MT-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-41-MT-0001', 'CHS Petroleum Terminal - Missoula', '3576 Grand Creek Road', 'Missoula', '59808') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4000') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4000', 'Phillips 66 PL - Billings', '23rd & Fourth Ave South', 'Billings', '59107-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4001', 'Phillips 66 PL - Bozeman', '318 West Griffin Drive', 'Bozeman', '59715') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4002') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4002', 'Phillips 66 PL - Great Falls', '1401 52nd N', 'Great Falls', '59405-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4003') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4003', 'Phillips 66 PL - Helena', '3180 Highway 12 East', 'Helena', '59601') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4004') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4004', 'Phillips 66 PL - Missoula', '3330 Raser Drive', 'Missoula', '59802-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4005') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4005', 'CHS Petroleum Terminal - Laurel', '803 Hwy 212 South', 'Laurel', '59044') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4006') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4006', 'CHS Petroleum Terminal - Glendive', 'P O Box 240', 'Glendive', '59330-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4007') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4007', 'ExxonMobil Oil Corp.', '607 Exxon Rd.', 'Billings', '59101-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4008') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4008', 'ExxonMobil Oil Corp.', '220 West Griffin Drive', 'Bozeman', '59715') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4009') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4009', 'ExxonMobil Oil Corp.', '3120 Highway 12 East', 'Helena', '59601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4011') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4011', 'Calumet Montana Refining LLC', '1900 10th Street', 'Great Falls', '59403') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4013') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4013', 'Montana Rail Link Inc', '1001 Defoe St.', 'Missoula', '59808') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4014') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4014', 'Montana Rail Link Inc', '1923 Shannon Road', 'Laurel', '59044') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-81-MT-4017') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-81-MT-4017', 'NGL Supply Terminal Company LLC - Sidney', '35251 South County Road 128', 'Sidney', '59270') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'KS'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-KS-3653') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-KS-3653', 'Signature Flight Support Corp.', '1980 Airport Rd.', 'Wichita', '67209') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-KS-3672') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-KS-3672', 'Phillips 66 PL - Kansas City', '2029 Fairfax Trafficway', 'Kansas City', '66115') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3651') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3651', 'Coffeyville Terminal Operations', '400 N. Linden Street', 'Coffeyville', '67337') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3652') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3652', 'NuStar Pipeline Operating Partnership, L.P. - Concordia', 'Route 1', 'Delphos', '67436-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3654') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3654', 'Holly Energy Partners - Operating LP', 'South Haverhill Road', 'El Dorado', '67042-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3655') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3655', 'Magellan Pipeline Company, L.P.', '48 NE Highway 156', 'Great Bend', '67530-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3656') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3656', 'NuStar Pipeline Operating Partnership, L.P. - Hutchison', '3300 East Avenue G', 'Hutchison', '67501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3657') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3657', 'BNSF - Argentine', '2201 Argentine Blvd', 'Kansas City', '66106') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3658') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3658', 'Sinclair Transport. - Kansas City', '3401 Fairbanks Avenue', 'Kansas City', '66106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3659') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3659', 'Magellan Pipeline Company, L.P.', '401 East Donovan Road', 'Kansas City', '66115-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3660') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3660', 'National Coop. Refinery', '1391 Iron Horse Rd.', 'McPherson', '67460-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3661') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3661', 'Magellan Pipeline Company, L.P.', '13745 W 135th St', 'Olathe', '66062-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3663') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3663', 'NuStar Pipeline Operating Partnership, L.P. - Salina', '2137 W Old Hwy 40', 'Salina', '67401-9798') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3664') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3664', 'Magellan Pipeline Company, L.P.', '100 Highway 4', 'Scott City', '67871-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3665') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3665', 'Magellan Pipeline Company, L.P.', 'US Hwy 75 RFD 1', 'Wakarusa', '66546-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3666') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3666', 'Magellan Pipeline Company, L.P.', '7452 N Meridian', 'Valley Center', '67147-0376') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3667') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3667', 'Growmark, Inc.', 'Rt 2 Box 112', 'Wathena', '66090-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3670') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3670', 'Phillips 66 PL - Wichita South', '8001 Oak Knoll Road', 'Wichita', '67207-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3671') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3671', 'Phillips 66 PL - Wichita North', '2400 East 37th Street North', 'Wichita', '67219-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-48-KS-3678') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-48-KS-3678', 'Williams Hutch Rail Company ', '407 South Obee Road', 'Hutchinson', '67501') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MO'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3701') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3701', 'J D Streett - St. Louis', '3800 S. 1st St.', 'St. Louis', '63118-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3703') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3703', 'Ayers Oil Company - Canton', 'Fourth & Grant', 'Canton', '63435-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3704') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3704', 'TransMontaigne - Cape Girardeau', '1400 S Giboney', 'Cape Girardeau', '63701-0704') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3705') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3705', 'ERPCO Cape Girardeau', 'Rural Route 2, Hwy N', 'Scott City', '63780-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3707') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3707', 'Magellan Pipeline Company, L.P.', '18195 County Rd 138', 'Jasper', '64755-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3708') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3708', 'Magellan Pipeline Company, L.P.', '5531 South Hwy 63', 'Columbia', '65201-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3709') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3709', 'Phillips 66 PL - Jefferson City', '2116 Idlewood', 'Jefferson City', '65109-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3713') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3713', 'Phillips 66 PL - Mount Vernon', 'Rt. 2 Box 115', 'Mount Vernon', '65712-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3714') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3714', 'American River Trans. Co., North', '3854 South 1st. St.', 'St. Louis', '63118') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3716') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3716', 'Magellan Pipeline Company, L.P.', '66789 County Road 312', 'Palmyra', '63461-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3718') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3718', 'Magellan Pipeline Company, L.P.', '3132 S State Hwy MM', 'Brookline', '65619-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3720') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3720', 'Buckeye Tank Terminals LLC - Sugar Creek', '1315 North Sterling', 'Sugar Creek', '64054-0507') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3721') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3721', 'Magellan Terminals Holdings, LP', '4695 South Service Road', 'St Peter', '63376-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3722') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3722', 'Swissport SA Fuel Services', '10735 Old Natural Bridge', 'St. Louis', '63145') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3723') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3723', 'Allied Aviation Service of Kansas City', '217 Bern Street', 'Kansas City', '64153') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3725') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3725', 'Buckeye Terminals, LLC - St. Louis North', '239 East Prairie St.', 'St. Louis', '63147-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3726') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3726', 'Kinder Morgan Transmix Co., LLC', '4070 South First Street', 'St Louis', '63118-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3727') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3727', 'TransMontaigne - Mt Vernon', '15376 Hwy 96', 'Mount Vernon', '65712') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3728') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3728', 'Sinclair Transport.- East Carrollton, MO', 'RR4, Box 48', 'Carrollton', '64633-0000') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-43-MO-3729') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-43-MO-3729', 'Oakmar Terminal', '2353 N State Hwy D ', 'Hayti', '63851') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'ND'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3500') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3500', 'Magellan Pipeline Company, L.P.', '3930 Gateway Drive', 'Grand Forks', '58203') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3501') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3501', 'Magellan Pipeline Company, L.P.', '902 Main Avenue East', 'West Fargo', '58078') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3502') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3502', 'NuStar Pipeline Operating Partnership, L.P. - Jamestown', '10 Mi West on I-94 Stand Spur', 'Jamestown', '58401') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3503') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3503', 'NuStar Pipeline Operating Partnership, L.P. - Jamestown', '3790 Hwy 281 SE', 'Jamestown', '58401-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3504') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3504', 'CHS Petroleum Terminal - Minot', '700 Second Street SW', 'Minot', '58701') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3505') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3505', 'Tesoro Logistics Operations LLC', '900 Old Red Trail NE', 'Mandan', '58554-5000') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3506') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3506', 'BNSF - Mandan', 'P. O. Box 1205', 'Mandan', '58554') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3508') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3508', 'Hess North Dakota Export Logistics', '10515 67th Street NW', 'Tioga', '58852') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-45-ND-3509') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-45-ND-3509', 'Dakota Prairie Refining', '3815 116th Ave SW', 'Dickinson', '58601') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'SD'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3550') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3550', 'NuStar Pipeline Operating Partnership, L.P. - Aberdeen', 'Hwy 281', 'Aberdeen', '57401-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3551') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3551', 'NuStar Pipeline Operating Partnership, L.P. - Mitchell', 'Hwy 38', 'Mitchell', '57301-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3552') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3552', 'Magellan Pipeline Company, L.P.', '3225 Eglin Street', 'Rapid City', '57701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3553') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3553', 'NuStar Pipeline Operating Partnership, L.P. - Sioux Falls', '3721 S. Grange', 'Sioux Falls', '57105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3554') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3554', 'Magellan Pipeline Company, L.P.', '5300 West 12th Street', 'Sioux Falls', '57107-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3555') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3555', 'Magellan Pipeline Company, L.P.', '1000 17th Street SE', 'Watertown', '57201-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3556') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3556', 'NuStar Pipeline Operating Partnership, L.P. - Wolsey', 'US Hwy 14 & 281', 'Wolsey', '57384-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-46-SD-3557') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-46-SD-3557', 'NuStar Pipeline Operating Partnership, L.P. - Yankton', 'Star Rte 50', 'Yanton', '57078-') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'VA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-50-VA-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-50-VA-0001', 'PAPCO Terminal', '407 Jefferson Avenue', 'Newport News', '23607') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1650') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1650', 'Buckeye Terminals, LLC - Chesapeake', '4030 Buell Street', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1651') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1651', 'Center Point Terminal - Chesapeake', '428 Barnes Road', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1652') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1652', 'CITGO - Chesapeake', '110 Freeman Street', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1653') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1653', 'Kinder Morgan Virginia Liquids Terminals LLC', '502 Hill Street', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1654') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1654', 'Kinder Morgan Southeast Terminals LLC', '4115 Buell Street', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1656') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1656', 'TransMontaigne - Norfolk', '7600 Halifax Lane', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1657') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1657', 'Kinder Morgan Transmix Co., LLC', '3302 Deepwater Terminal Rd', 'Richmond', '23234-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1659') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1659', 'Buckeye Terminals, LLC - Fairfax', '9601 Colonial Avenue', 'Fairfax', '22031-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1660') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1660', 'TransMontaigne - Fairfax', '3790 Pickett Road', 'Fairfax', '22031-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1661') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1661', 'CITGO - Fairfax', '9600 Colonial Avenue', 'Fairfax', '22031-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1662') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1662', 'Motiva Enterprises LLC', '3800 Pickett Road', 'Fairfax', '22031') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1663') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1663', 'Sunoco Partners Marketing & Terminals LP', '10315 Ballsford Road', 'Manassas', '23109') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1664') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1664', 'TransMontaigne - Montvale', '11685 W Lynchburg Salem Turnpi', 'Montvale', '24122-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1665') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1665', 'Buckeye Terminals, LLC - Roanoke', '1070 Oil Terminal Rd', 'Montvale', '24122-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1666') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1666', 'TransMontaigne - Montvale', '1147 Oil Terminal Rd. Hwy 460E', 'Montvale', '24122-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1667') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1667', 'IMTT-Chesapeake', '2801 S. Military Hwy.', 'Chesapeake', '23323') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1668') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1668', 'Magellan Terminals Holdings LP', '11851 West Lynchburg Turnpike', 'Montvale', '24122-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1671') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1671', 'Kinder Morgan Southeast Terminals LLC', '8200 Terminal Road', 'Newington', '22122-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1673') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1673', 'Arc Terminals Holdings LLC', '801 Butt Street', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1674') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1674', 'TransMontaigne - Chesapeake', 'Halifax Lane', 'Chesapeake', '23324-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1676') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1676', 'Aircraft Service International, Inc.', 'Rt 28 Gate317 Bldg 2 Tank Farm', 'Sterling', '20166') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1677') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1677', 'Buckeye Terminals, LLC - Richmond', '1636 Commerce Road', 'Richmond', '23224-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1678') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1678', 'TransMontaigne - Richmond', '700 Goodes Street', 'Richmond', '23224-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1679') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1679', 'CITGO - Richmond', 'Third & Maury Street', 'Richmond', '23224-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1681') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1681', 'Kinder Morgan Southeast Terminals LLC', '2000 Trenton Avenue', 'Richmond', '23234-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1682') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1682', 'First Energy Corporation', 'Second & Maury Streets', 'Richmond', '23224') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1683') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1683', 'Kinder Morgan Southeast Terminals LLC', '4110 Deepwater Terminal Road', 'Richmond', '23234-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1684') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1684', 'Magellan Terminals Holdings LP', '204 East First Avenue', 'Richmond', '23224-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1685') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1685', 'Motiva Enterprises LLC', '5801 Jefferson Davis Hwy.', 'Richmond', '23234-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1686') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1686', 'Allied Avia Fueling of National Airport, LLC', '11 Air Cargo Rd.', 'Arlington   ', '22201') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1687') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1687', 'TransMontaigne - Richmond', '1314 Commerce Road', 'Richmond', '23224-7510') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1688') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1688', 'Kinder Morgan Southeast Terminals LLC', '835 Hollins Road Northeast', 'Roanoke', '24012-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1689') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1689', 'Magellan Terminals Holdings LP', '5287 Terminal Road', 'Roanoke', '24014-4033') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1690') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1690', 'Kinder Morgan Southeast Terminals LLC', '5280 Terminal Road SW', 'Roanoke', '24014-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1691') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1691', 'Motiva Enterprises LLC', 'U.S. Highway 460', 'Montvale', '24122-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1692') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1692', 'Kinder Morgan Southeast Terminals LLC', '8206 Terminal Road', 'Lorton', '22079-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1694') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1694', 'Plains Marketing, LP ', 'Route 73 East Entrance', 'Yorktown', '23690-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1695') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1695', 'Lincoln Terminal Company', '3300 Beaulah Salisbury', 'Fredricksburg', '22402') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1696') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1696', 'IMTT Richmond, Inc.', '5501 Old Osborne Turnpike', 'Richmond', '23231') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-54-VA-1700') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-54-VA-1700', 'Atlantic Energy', '2901 South Military Highway', 'Chesapeake', '23323') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'DE'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-51-DE-1600') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-51-DE-1600', 'Delaware City Refining Company LLC', '4550 Wrangle Hill Road', 'Delaware City', '19706-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-DE-1602') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-DE-1602', 'Delaware Storage & Pipeline Co.', 'Port Mahon Rd.', 'Little Creek', '19961') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MD'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1550') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1550', 'Buckeye Terminals, LLC - Baltimore', '6200 Pennington Avenue', 'Baltimore', '21226') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1551') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1551', 'BP Products North America Inc', '801 East Ordance Rd', 'Baltimore', '21226') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1552') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1552', 'Sunoco Partners Marketing & Terminals LP', '2155 Northbridge Ave', 'Baltimore', '21226-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1554') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1554', 'Petroleum Fuel & Terminal - Baltimore No', '5101 Erdman Avenue', 'Baltimore', '21205-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1559') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1559', 'Petroleum Fuel & Terminal - Baltimore So', '1622 South Clinton Street', 'Baltimore', '21224-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1560') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1560', 'NuStar Terminals Operations Partnership L.P. - Baltimore', '1800 Frankfurst Avenue', 'Baltimore', '21226-1024') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1561') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1561', 'Motiva Enterprises LLC East', '2400 Petrolia Ave.', 'Baltimore', '21226-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1562') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1562', 'CITGO - Baltimore', '2201 Southport Ave.', 'Baltimore', '21226-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1563') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1563', 'Center Point Terminal - Baltimore West', '3100 Vera Street', 'Baltimore', '21226-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1565') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1565', 'NuStar Terminals Operations Partnership L. P. - Piney Point', '17877 Piney Point Road', 'Piney Point', '20674-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1567') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1567', 'CATO, Inc.', '1030 Marine Road', 'Salisbury', '21801-1030') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1568') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1568', 'Blackwater Maryland LLC', '1134 Marine Road', 'Salisbury', '21801-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1569') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1569', 'Aircraft Service International, Inc.', 'Balto/Wash. Airport', 'Baltimore', '21240') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-52-MD-1574') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-52-MD-1574', 'Magellan Terminals Holdings LP', '1050 Christiana Ave.', 'Wilmington', '19801') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WV'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-55-WV-3181') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-55-WV-3181', 'Marathon Charleston', 'Standard St & MacCorkle Ave', 'Charleston', '25314-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-55-WV-3183') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-55-WV-3183', 'Ergon West Virginia, Inc.', 'Rt 2 South', 'Newell', '26050-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-55-WV-3184') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-55-WV-3184', 'Go-Mart', '1Terminal Rd', 'St. Albans', '25177-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-55-WV-3185') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-55-WV-3185', 'St. Marys Refining Company', '201 Barkwill St', 'St. Marys', '26170-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-55-WV-3186') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-55-WV-3186', 'Guttman Realty Co. - Star City', '437 Industrial Ave', 'Star City', '26505-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-55-WV-3188') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-55-WV-3188', 'Baker Oil Co.', '2076 Stephen Street', 'Hugheston', '25110-') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NC'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2000') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2000', 'Kinder Morgan Southeast Terminals LLC', '6801 Freedom Dr', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2001', 'CITGO - Charlotte', '7600 Mount Holly Road', 'Charlotte', '28214-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2002') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2002', 'Marathon Oil Charlotte', '8035 Mt. Holly Rd.', 'Charlotte', '28130') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2003') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2003', 'Eco-Energy', '7720 Mr. Holly Road', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2004') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2004', 'Kinder Morgan Southeast Terminals LLC', '502 Tom Sadler Rd.', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2005') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2005', 'Motiva Enterprises LLC', '6851 Freedom Dr.', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2006') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2006', 'Magellan Terminals Holdings LP', '7145 Mount Holly Rd.', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2007') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2007', 'Motiva Enterprises LLC', '410 Tom Sadler Rd.', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2008') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2008', 'Marathon Charlotte (East)', '7401 Old Mount Holly Road', 'Charlotte', '28214-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2009') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2009', 'Motiva Enterprises LLC', '992 Shaw Mill Road', 'Fayetteville', '28311-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2011') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2011', 'Magellan Terminals Holdings LP', '7109 West Market Street', 'Greensboro', '27409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2013') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2013', 'Kinder Morgan Southeast Terminals LLC', '2101 West Oak St.', 'Selma', '27576') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2014') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2014', 'Kinder Morgan Southeast Terminals LLC', '6907 West Market Street', 'Greensboro', '27409-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2015') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2015', 'Kinder Morgan Southeast Terminals LLC', '6376 Burnt Poplar Rd', 'Greensboro', '27409-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2018') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2018', 'Kinder Morgan Southeast Terminals LLC', '2200 West Oak St.', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2019') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2019', 'Center Point Terminal - Greensboro', '6900 West Market St', 'Greensboro', '27409-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2020') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2020', 'Magellan Terminals Holdings LP', '115 Chimney Rock Road', 'Greensboro', '27409-9661') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2021') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2021', 'Motiva Enterprises LLC', '101 S. Chimney Rock Rd.', 'Greensboro', '27409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2022') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2022', 'TransMontaigne - Greensboro', '6801 West Market Street', 'Greensboro', '27409-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2023') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2023', 'TransMontaigne - Charlotte/Paw Creek', '7615 Old Mount Holly Road', 'Charlotte', '28214-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2024') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2024', 'Magellan Terminals Holdings LP', '7924 Mt. Holly Rd.', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2025') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2025', 'Arc Terminals Holdings LLC', '2999 W. Oak St.', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2026') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2026', 'Kinder Morgan Southeast Terminals LLC', '7325 Old Mount Holly Rd.', 'Charlotte', '28214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2027') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2027', 'Motiva Enterprises LLC', '2232 Ten-Ten.  Road', 'Apex', '27502-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2028') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2028', 'TransMontaigne - Selma - N', '2600 W. Oak St. (SSR 1929)', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2029') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2029', 'Marathon Selma', '3707 Buffalo Road', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2030') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2030', 'CITGO - Selma', '4095 Buffalo Rd', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2031') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2031', 'Marathon Selma', '2555 West Oak Street', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2032') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2032', 'Aircraft Service International, Inc.', '6502 Old Dowd Rd.', 'Charlotte', '28219') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2033') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2033', 'Kinder Morgan Southeast Terminals LLC', '4383 Buffalo Rd.', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2034') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2034', 'Kinder Morgan Southeast Terminals LLC', '4086 Buffalo Road', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2036') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2036', 'Magellan Terminals Holdings LP', '4414 Buffalo Road', 'Selma', '27576-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2037') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2037', 'Buckeye Terminals, LLC - Wilmington', '1312 S Front St.', 'Wilmington', '28401-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2038') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2038', 'Piedmont Aviation Services, Inc.', '6427 Bryan Blvd.', 'Greensboro', '27409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2043') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2043', 'Apex Oil Company', '3314 River Road', 'Wilmington', '28403-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2044') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2044', 'Kinder Morgan Terminals Wilmington LLC', '1710 Woodbine St.', 'Wilmington', '28402') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-56-NC-2045') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-56-NC-2045', 'Raleigh-Durham Airport Authority', '2800 W. Terminal Blvd.', 'Morrisville', '27560') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'SC'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2050') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2050', 'TransMontaigne - Belton', '14033 Highway 20 North', 'Belton', '29627-0250') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2051') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2051', 'Buckeye Terminals, LLC - Belton', 'Hwy 20 North', 'Belton', '29627-0647') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2052') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2052', 'Buckeye Terminals, LLC - Spartansburg', '680 Delmar Road', 'Spartansburg', '29302-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2053') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2053', 'Marathon Oil Belton', '14315 State Rt. 20', 'Belton', '29627-0488') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2054') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2054', 'Kinder Morgan Operating LP "C"', '1500 Greenleaf St.', 'Charleston', '29405-9308') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2059') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2059', 'Magellan Terminals Holdings LP', '217 Sweet Water Road', 'North Augusta', '29860') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2060') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2060', 'Kinder Morgan Southeast Terminals LLC', '221 Laurel Lake Drive', 'North Augusta', '29841-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2061') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2061', 'Buckeye Terminals, LLC - North Augusta', '221 Sweetwater Rd.', 'North Augusta', '29841-6427') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2062') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2062', 'Kinder Morgan Southeast Terminals LLC', '205 Sweetwater Rd.', 'North Augusta', '29841-6669') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2063') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2063', 'Magellan Terminals Holdings LP', '1222 Sweetwater Road', 'North Augusta', '29841-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2064') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2064', 'Buckeye Terminals, LLC - North Charleston', '5150 Virginia Ave.', 'North Charleston', '29406-5227') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2066') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2066', 'Kinder Morgan Operating LP "C"', '5165 Virginia Ave', 'North Charleston', '29406-3616') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2067') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2067', 'TransMontaigne - Spartansburg', '2300 South Port Rd.', 'Spartansburg', '29304-5021') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2068') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2068', 'Magellan Terminals Holdings LP', 'Old Union Rd Route 4', 'Spartansburg', '29304-3059') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2074') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2074', 'Kinder Morgan Southeast Terminals LLC', '200 Nebo Street', 'Spartansburg', '29302-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2075') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2075', 'Motiva Enterprises LLC', '300 Delmar Road', 'Spartansburg', '29302-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2076') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2076', 'Magellan Terminals Holdings LP', '2430 Pine Street Ext', 'Spartanburg', '29302-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-57-SC-2077') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-57-SC-2077', 'CITGO - Spartanburg', '2590 Southport Road', 'Spartanburg', '29302-') END
END
		
SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'GA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2500') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2500', 'Kinder Morgan Southeast Terminals LLC', '1603 W Oakridge Dr', 'Albany', '31707-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2501') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2501', 'Magellan Terminals Holdings LP', '1722 W Oakridge Dr', 'Albany', '31707-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2502') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2502', 'TransMontaigne - Albany', '1162 Gillionville Rd', 'Albany', '31707-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2505') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2505', 'TransMontaigne - Americus', 'Highway 280 West Plains Rd.', 'Americus', '31709-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2506') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2506', 'Kinder Morgan Southeast Terminals LLC', '3460 Jefferson Road', 'Athens', '30607-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2507') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2507', 'Epic Midstream LLC', '2 Wahlstrom Rd.', 'Savannah', '31404-1033') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2508') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2508', 'TransMontaigne - Athens', '3450 Jefferson Road', 'Athens', '30607-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2510') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2510', 'Motiva Enterprises LLC', '4127 Winters Chapel Rd.', 'Doraville', '30360-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2511') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2511', 'BP Products North America Inc', '3132 Parrott Avenue N W', 'Atlanta', '30318-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2512') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2512', 'Allied Aviation Fueling of Atlanta Inc.', '#1 Fuel Farm Road (No Cgo.)', 'Atlanta', '30320') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2513') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2513', 'Allied Aviation Fueling of Atlanta Inc.', '1360 NLVR Road (FIS)', 'Atlanta', '30320') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2514') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2514', 'Motiva Enterprises LLC', '1803 East Shotwell St.', 'Bainbridge', '39817') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2515') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2515', 'TransMontaigne - Bainbridge', '1909 East Shotwell Street', 'Bainbridge', '39817') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2517') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2517', 'Epic Midstream LLC', '870 Alabama Avenue', 'Bremen', '30110-2306') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2519') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2519', 'Magellan Terminals Holdings LP', '2970 Parrott Avenue', 'Atlanta', '30318-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2520') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2520', 'Kinder Morgan Southeast Terminals LLC', '5131 Miller Road', 'Columbus', '31908-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2522') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2522', 'Omega Partners III, LLC', '5225 Miller Road', 'Columbus', '31904-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2523') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2523', 'Marathon Oil Columbus', '5030 Miller Road', 'Columbus', '31908-5561') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2524') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2524', 'Omega Partners III, LLC', '800 Lumpkin Blvd.', 'Columbus', '31901-3130') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2525') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2525', 'TransMontaigne - Doraville', '2836 Woodwin Road', 'Doraville', '30362-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2526') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2526', 'BP Products North America Inc', '6430 New Peachtree Road', 'Doraville', '30340') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2528') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2528', 'Chevron USA, Inc.- Doraville', '4026 Winters Chapel Road', 'Doraville', '30362-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2529') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2529', 'CITGO - Doraville', '3877 Flowers Drive', 'Doraville', '30362-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2531') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2531', 'Motiva Enterprises LLC', '4143 Winters Chapel Rd', 'Doraville', '30360-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2532') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2532', 'Marathon Oil Doraville', '6293 New Peachtree Road', 'Doraville', '30341-1211') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2533') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2533', 'Magellan Terminals Holdings LP', '4149 Winters Chapel Road', 'Doraville', '30360-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2534') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2534', 'BP Products North America Inc', '4064 Winters Chapel Rd', 'Doraville', '30340-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2535') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2535', 'Magellan Terminals Holdings LP', '2797 Woodwin Road', 'Doraville', '30360-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2536') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2536', 'Allied Aviaition Fueling of Atlanta, Inc', '1625 Fuel Farm Rd. (City)', 'Atlanta', '30320') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2537') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2537', 'TransMontaigne - Griffin', '643B East McIntosh Road', 'Griffin', '30223-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2538') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2538', 'South Florida Materials Corp dba Vecenergy', '2476 Allen Road', 'Macon', '31206-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2541') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2541', 'Marathon Oil Macon', '2445 Allen Road', 'Macon', '31206-6301') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2542') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2542', 'Epic Midstream LLC', '6225 Hawkinsville Road', 'Macon', '31216-5849') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2543') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2543', 'Magellan Terminals Holdings LP', '2505 Allen Road', 'Macon', '31206-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2544') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2544', 'TransMontaigne - Macon', '5041 Forsyth Rd.', 'Macon', '31210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2545') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2545', 'Marathon Oil Powder Springs', '3895 Anderson Farm Road NW', 'Powder Springs', '30073') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2547') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2547', 'TransMontaigne - Rome', '2671 Calhoun Road', 'Rome', '30161-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2550') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2550', 'Colonial Terminal, Inc.', '101 North Lathrop Ave', 'Savannah', '31415-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2551') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2551', 'Vopak Terminal Savannah, Inc.', 'Georgia Ports Garden City', 'Savannah', '31418-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2553') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2553', 'Norfolk Southern Railway Company', '1550 Marietta Dr NW', 'Atlanta', '30318') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2554') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2554', 'Norfolk Southern Railway Company', '355 Turpin St', 'Macon', '31206') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2555') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2555', 'Delta Terminal, Inc.', '1500 Fuel Farm Road', 'Atlanta', '30320') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-58-GA-2556') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-58-GA-2556', 'TransMontaigne - Lookout Mtn.', '11 Highway 93', 'Flintstone', '30725') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'FL'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2100') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2100', 'Murphy Oil USA, Inc. - Tampa', '1306 Ingram Ave', 'Tampa', '33605-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2101') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2101', 'TransMontaigne - Tampa', '1523 Port Avenue', 'Tampa', '33605-6745') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2102') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2102', 'Buckeye Terminals, LLC - Jacksonville', '2617 Heckscher Drive', 'Jacksonville', '32226-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2105') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2105', 'TransMontaigne - Jacksonville', '3425 Talleyrand Avenue', 'Jacksonville', '32206') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2106') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2106', 'Marathon Jacksonville', '2101 Heckscher Dr', 'Jacksonville', '32218-6038') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2107') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2107', 'Buckeye Terminals, LLC - Tampa', '504 N 19th Street', 'Tampa', '33605-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2110') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2110', 'Aircraft Service International, Inc.', '4720 North Westshore Bl.', 'Tampa', '33614') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2111') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2111', 'Aircraft Service International, Inc.', '3800 Express St.', 'Orlando', '32827') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2112') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2112', 'NuStar Terminals Operations Partnership L. P. - Jacksonville', '6531 Evergreen Avenue', 'Jacksonville', '32208-4911') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2114') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2114', 'CITGO - Niceville', '904 Bayshore Drive', 'Niceville', '32578-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2115') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2115', 'Murphy Oil USA, Inc. - Freeport', '424 Madison St', 'Freeport', '32439-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2116') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2116', 'Chevron USA, Inc.- Panama City', '525 West Beach Drive', 'Panama City', '32402-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2120') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2120', 'TransMontaigne - Pensacola', '511 South Clubbs St.', 'Pensacola', '32501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2122') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2122', 'TransMontaigne - Port Manatee', '804 N Dock St.', 'Palmetto', '34220-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2123') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2123', 'Kinder Morgan Liquids Terminals LLC', '2101 GATX Drive', 'Tampa', '33605-6863') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2124') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2124', 'Motiva Enterprises LLC', '6500 W. Commerce St', 'Port Tampa', '33616-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2129') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2129', 'Central Florida Pipeline LLC', '9919 Orange Avenue', 'Orlando', '32824-8466') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2130') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2130', 'Buckeye Terminals, LLC - Tampa', '848 McCloskey Boulevard', 'Tampa', '33605-6716') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2131') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2131', 'Chevron USA, Inc.- Tampa', '5500 Commerce Street', 'Tampa', '33616-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2133') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2133', 'CITGO - Tampa', '801 McCloskey Blvd', 'Tampa', '33605-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2136') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2136', 'Marathon Oil Tampa', '425 South 20th Street', 'Tampa', '33605-6025') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2138') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2138', 'TransMontaigne - Cape Canaveral', '8952 North Atlantic Ave', 'Cape Canaveral', '32920-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2677') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2677', 'Martin Operating Partnership, L.P.', '4118 Pendola Point Rd.', 'Tampa', '33617') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2678') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2678', 'South Florida Materials Corp dba Vecenergy', '300 Middle Road', 'Riviera Beach', '33404') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2679') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2679', 'South Florida Materials Corp dba Vecenergy', '1200 S. E. 32nd Street', 'Dania Beach', '33316') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2680') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2680', 'Seaport Canaveral', '555 Hwy 401', 'Cape Canaveral', '32920') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-FL-2681') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-FL-2681', 'Center Point Terminal - Jacksonville', '3101 Talley Rand Ave ', 'Jacksonville', '32206') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2150') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2150', 'TransMontaigne - Fort Lauderdale', '2401 Eisenhower Blvd.', 'Fort Lauderdale', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2152') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2152', 'BP Products North America Inc', '1180 Spangler Road', 'Ft Lauderdale', '33316') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2153') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2153', 'Chevron USA, Inc. - Fort Lauderdale', '1400 SE 24th St', 'Fort Lauderdale', '33316') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2154') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2154', 'Motiva Enterprises LLC', '1500 SE 26 St', 'Ft. Lauderdale', '33316') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2156') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2156', 'Buckeye Terminals, LLC - Fort Lauderdale', '1501 SE 20th St.', 'Fort Lauderdale', '33316') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2157') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2157', 'CITGO Petroleum Corporation', '801 SE 28th Street', 'Fort Lauderdale', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2158') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2158', 'Aircraft Service International, Inc.', '3451 SW 2nd Ave.', 'Ft. Lauderdale', '33315') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2159') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2159', 'Allied Aviation Fueling of Miami', '4450 NW 20th St. #201', 'Miami', '33122') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2160') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2160', 'Marathon Ft Lauderdale Eisenhower', '1601 SE 20th St', 'Fort Lauderdale', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2161') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2161', 'ExxonMobil Oil Corp.', '1150 Spangler Blvd', 'Fort Lauderdale', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2163') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2163', 'Marathon Fort Lauderdale Spangler', '909 SE 24th St.', 'Fort Lauderdale', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2164') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2164', 'Motiva Enterprises LLC', '1200 SE 28th St', 'Port Everglades', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2165') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2165', 'TransMontaigne - Port Everglades', '2701 SE 14th Ave', 'Fort Lauderdale', '33316-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2166') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2166', 'Transmontaigne Product Services, Inc.', 'One B Street', 'Miami Beach', '33109') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-65-FL-2167') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-65-FL-2167', 'Port Everglades Energy Center', '8100 Eisenhower Blvd', 'Ft Lauderdale', '33316') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-59-MS-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-59-MS-0001', 'Scott Petroleum Corporation', '942 N. Broadway', 'Greenville', '38701') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2401') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2401', 'Chevron USA, Inc.- Collins', 'Old Highway 49 South', 'Collins', '39428-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2402') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2402', 'Kinder Morgan Southeast Terminals LLC', '31 Kola Road', 'Collins', '39428-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2404') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2404', 'Motiva Enterprises LLC', '49 So. & Kola Rd.', 'Collins', '39428-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2405') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2405', 'TransMontaigne - Collins', 'First Avenue South', 'Collins', '39428-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2406') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2406', 'Transmontaigne - Greenville- S', '310 Walthall Street', 'Greenville', '38701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2408') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2408', 'TransMontaigne - Greenville - N', '208 Short Clay Street', 'Greenville', '38701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2411') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2411', 'MGC Terminals', '101 65th Avenue', 'Meridian', '39301-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2412') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2412', 'CITGO - Meridian', '180 65th Avenue', 'Meridian', '39305-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2414') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2414', 'Murphy Oil USA, Inc. - Meridian', '6540 N. Frontage Rd.', 'Meridian', '39301-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2415') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2415', 'TransMontaigne - Meridian', '1401 65th Ave S', 'Meridian', '39307-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2416') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2416', 'Chevron USA, Inc.- Pascagoula', 'Industrial Road State Hwy 611', 'Pascagoula', '39568-1300') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2418') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2418', 'Hunt-Southland Refining Co', '2 mi N on Hwy 11 PO Drawer A', 'Sandersville', '39477-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2419') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2419', 'CITGO - Vicksburg', '1585 Haining Rd', 'Vicksburg', '39180-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2423') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2423', 'Lone Star NGL Hattiesburg LLC', '1234 Highway 11', 'Petal', '39465') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2424') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2424', 'Hunt Southland Refining Company', '2600 Dorsey Street', 'Vicksburg', '39180') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-64-MS-2425') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-64-MS-2425', 'Kior Columbus LLC', '600 Industrial Park Acces Rd ', 'Columbus', '39701') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-MS-2420') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-MS-2420', 'Martin Operating Partnership, L.P.', '5320 Ingalls Ave.', 'Pascagoula', '39581') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-MS-2421') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-MS-2421', 'Delta Terminal, Inc.', '2181 Harbor Front', 'Greenville', '38701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-MS-2422') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-MS-2422', 'ERPC Aberdeen ', '20096 Norm Connell Drive', 'Aberdeen', '39730') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'KY'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3262') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3262', 'Marathon Viney Branch', 'Old St Rt 23', 'Catlettsburg', '41129-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3263') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3263', 'MAPLLC  Covington', '230 East 33rd Street', 'Covington', '41015-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3264') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3264', 'TransMontaigne - Greater Cinci', '700 River Rd. (Hwy 8)', 'Covington', '41017-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3265') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3265', 'Countrymark Cooperative LLP', '2321 Old Geneva Road', 'Henderson', '42420-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3266') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3266', 'Marathon Lexington', '1770 Old Frankfort Pike', 'Lexington', '40504-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3267') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3267', 'Valero Terminaling & Distribution', '1750 Old Frankfort Pike', 'Lexington', '40504-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3268') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3268', 'Marathon Louisville', '4510 Algonquin Parkway', 'Louisville', '40211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3269') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3269', 'Buckeye Terminals, LLC - Louisville ', '1500 Southwestern Parkway', 'Louisville', '40211') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3270') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3270', 'Valero Terminaling & Distribution', '4411 Bells Lane', 'Louisville', '40211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3271') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3271', 'TransMontaigne - Louisville', '4510 Bells Lane', 'Louisville', '40211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3272') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3272', 'Marathon Oil Louisville', '3920 Kramers Lane', 'Louisville', '40216-4651') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3273') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3273', 'Thornton Transportation, Inc.', '7800 Cane Run Road', 'Louisville', '40258-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3274') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3274', 'CITGO Equilon - Louisville', '4724 Camp Ground Road', 'Louisville', '40216-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3276') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3276', 'Marathon Paducah', 'Highway 62 & MAPLLC Road', 'Paducah', '42003-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3277') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3277', 'Aircraft Service International, Inc.', '2462 Spence Dr.', 'Erlanger', '41017') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3278') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3278', 'TransMontaigne - Paducah', '233 Elizabeth St.', 'Paducah', '42001-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3279') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3279', 'TransMontaigne - Henderson', '2633 Sunset Lane', 'Henderson', '42420-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3280') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3280', 'Southern States Cooperative', '150 Coast Guard Lane', 'Owensboro', '42302-0000') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3281') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3281', 'Continental Refining Company', '600 Monticello Street', 'Somerset', '42501') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-61-KY-3283') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-61-KY-3283', 'TransMontaigne - Owensboro', '900 Pleasant Valley Road', 'Owensboro', '42302-0000') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-KY-2210') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-KY-2210', 'UPS Fuel Farm Terminal', '911 Grade Lane', 'Louisville', '40213') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-KY-3285') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-KY-3285', 'Catlettsburg Refining, LLC', '8023 Crider Dr.', 'Catlettsburg', '41129-1492') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'TN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2200') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2200', 'Magellan Terminals Holdings LP', '4235 Jersey Pike', 'Chattanooga', '37416-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2201') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2201', 'Kinder Morgan Southeast Terminals LLC', '4716 Bonny Oaks Drive', 'Chattanooga', '37416-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2202') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2202', 'CITGO - Chattanooga', '4233 Jersey Pike', 'Chattanooga', '37416-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2204') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2204', 'Delek Logistics Operating', '90 Van Buren St', 'Nashville', '37208-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2207') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2207', 'Lincoln Terminal Company', '4211 Cromwell Rd.', 'Chattanooga', '37421-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2208') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2208', 'Magellan Terminals Holdings LP', '4326 Jersey Pike', 'Chattanooga', '37416-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2211') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2211', 'Magellan Terminals Holdings, LP', '5101 Middlebrook Pike NW', 'Knoxville', '37921-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2212') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2212', 'Swissport Fueling, Inc.', '4096 Louis Carruthers Dr.', 'Memphis', '38118') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2213') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2213', 'CITGO - Knoxville', '2409 Knott Road', 'Knoxville', '37921-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2214') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2214', 'Cummins Terminals - Knoxville', '4715 Middlebrook Pike', 'Knoxville', '37921-5532') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2215') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2215', 'Kinder Morgan Southeast Terminals LLC', '5009 Middlebrook Pike', 'Knoxville', '37921-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2217') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2217', 'Marathon Oil Knoxville', '2601 Knott Road', 'Knoxville', '37950-0094') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2218') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2218', 'Motiva Enterprises LLC', '5001 Middlebrook Pike NW', 'Knoxville', '37921-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2219') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2219', 'Magellan Terminals Holdings LP', '4801 Middlebrook Pike', 'Knoxville', '37921-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2220') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2220', 'Federal Express Corporation', '3051 Republican Blvd.', 'Memphis', '38194') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2222') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2222', 'Aircraft Service International, Inc.', '929 Airport Service Rd.', 'Nashville', '37214') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2223') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2223', 'Wespac Pipelines - Memphis LLC', '2640 Rental Road', 'Memphis', '38118') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2225') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2225', 'ExxonMobil Oil Corp.', '454 Wisconsin Avenue', 'Memphis', '38106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2226') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2226', 'Delek Logistics Operating', '1023 Riverside Dr', 'Memphis', '38106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2227') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2227', 'Valero Partners Operating Co LLC', '321 W. Mallory Ave.', 'Memphis', '38109-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2228') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2228', 'Center Point Terminal - Memphis', '1232 Riverside', 'Memphis', '38106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2231') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2231', 'Magellan Terminals Holdings LP', '1441 51st Avenue North', 'Nashville', '37209-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2232') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2232', 'Marathon Nashville', 'Five Main Street', 'Nashville', '37213-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2233') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2233', 'CITGO - Nashville', '720 South Second Street', 'Nashville', '37213-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2234') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2234', 'Cumberland Terminals', '7260 Centennial Boulevard', 'Nashville', '37209-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2236') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2236', 'ExxonMobil Oil Corp.', '1741 Ed Temple Blvd', 'Nashville', '37208-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2237') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2237', 'Marathon Nashville', '1409 51st Ave', 'Nashville', '37209-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2238') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2238', 'Marathon Oil Nashville', '2920 Old Hydes Ferry Road', 'Nashville', '37218') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2240') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2240', 'Magellan Terminals Holdings LP', '1609 63rd Avenue North', 'Nashville', '37209-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-62-TN-2241') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-62-TN-2241', 'Motiva Enterprises LLC', '1717 61st Ave. North', 'Nashville', '37209-') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AL'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2301') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2301', 'Chevron USA, Inc.- Birmingham', '2400 28th St Southwest', 'Birmingham', '35211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2302') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2302', 'CITGO - Birmingham', '2200 25th St Southwest', 'Birmingham', '35211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2304') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2304', 'Buckeye Terminals, LLC - Montgomery', 'Hwy 31 North', 'Montgomery', '36108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2306') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2306', 'Marathon Birmingham', '2704 28th St Southwest', 'Birmingham', '35211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2307') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2307', 'Kinder Morgan Southeast Terminals LLC', '2635 Balsam Avenue', 'Birmingham', '35211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2308') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2308', 'Motiva Enterprises LLC', '2601 Wilson Road', 'Birmingham', '35221-1352') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2309') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2309', 'Magellan Terminals Holdings LP', '2400 Nabors Road', 'Birmingham', '35211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2312') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2312', 'Buckeye Terminals, LLC - Birmingham', '1600 Mims Ave SW', 'Birmingham', '35211-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2314') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2314', 'Barcliff, LLC', '145 Cochran Causeway', 'Mobile', '36601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2317') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2317', 'Alabama Bulk Terminal', 'Hwy 90195 Blakely Island', 'Mobile', '36633') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2322') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2322', 'Magellan Terminals Holdings LP', '3560 Well Rd', 'Montgomery', '36108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2323') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2323', 'South Florida Materials Corp dba Vecenergy', '200 Hunter Loop Road', 'Montgomery', '31608-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2325') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2325', 'Marathon Montgomery', '320 Hunter Loop Rural Rt 6', 'Montgomery', '36125-0395') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2326') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2326', 'Epic Midstream LLC', '520 Hunter Loop Road', 'Montgomery', '36108-1827') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2327') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2327', 'Murphy Oil USA Inc. - Montgomery', '420 Hunter Loop Road', 'Montgomery', '36108-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2329') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2329', 'Hunt Refining Co.', '1855 Fairlawn RD', 'Tuscaloosa', '35401-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2330') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2330', 'Epic Midstream LLC', '872 Second  Ave.', 'Moundville', '35474-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2333') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2333', 'Murphy Oil USA, Inc. - Oxford', '2625 Highway 78 East', 'Anniston', '36201-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2334') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2334', 'Shell Chemical LP - Mobil', '400 Industrial Parkway', 'Saraland', '36571-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2335') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2335', 'Murphy Oil USA, Inc. - Sheffield', '136 Blackwell Road', 'Sheffield', '35660-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2336') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2336', 'Barcliff, LLC', '101 Bay Bridge Rd', 'Mobile', '36610-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2338') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2338', 'Plantation - Montgomery Transmix Tank', '201 Hunter Loop Rd', 'Montgomery', '36108') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2339') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2339', 'Center Point Terminal - Mobile', '1257 Cochrane Causeway', 'Mobile', '36601') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-63-AL-2340') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-63-AL-2340', 'Bama Terminaling and Trading LLC', '2529 28th Street SW', 'Birmingham', '35211') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-AL-2339') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-AL-2339', 'Martin  Energy Services', 'Hwy 90/98 Blakeley Island', 'Mobile', '36618') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-AL-2343') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-AL-2343', 'Allied Energy Corporation', '2700 Ishkooda Wenonah Rd.', 'Birmingham', '35211') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-AL-2344') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-AL-2344', 'Goodway Refining, LLC', '4745 Ross Road', 'Atmore', '36502') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-AL-2345') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-AL-2345', 'Martin Operating Partnership, L.P.', '7778 Dauphin Island Pkwy.', 'Theodore', '36582') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-AL-0001') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-AL-0001', 'ERPC Boligee', '2081 County Rd 89', 'Boligee', '35443') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AR'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2451') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2451', 'Lion Oil Co. -  El Dorado', '1000 McHenry', 'El Dorado', '71730-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2453') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2453', 'Magellan Pipeline Company, L.P.', '8101 Hwy 71', 'Fort Smith', '72908-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2456') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2456', 'Magellan Terminals Holdings LP', '2725 Central Airport Rd.', 'North Little Rock', '72117-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2457') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2457', 'Delek Logistics Operating', '2724 Central Airport Rd', 'North Little Rock', '72117-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2458') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2458', 'HWRT Terminal - N. Little Rock', '2626 Central Airport Road', 'North Little Rock', '72117-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2459') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2459', 'Magellan Terminals Holdings LP', '3222 Central Airport Rd.', 'North Little Rock', '72117-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2460') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2460', 'Martin Operating Partnership, L.P.', '484 E. 6th Street', 'Smackover', '71762-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2462') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2462', 'Murphy Oil USA, Inc. - Bono', '15211 US 63 North', 'Bono', '72416') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2463') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2463', 'Valero Partners Operating Co LLC', 'South 8th Street', 'West Memphis', '72303-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2464') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2464', 'JP Energy ATT LLC', '2207 Central Airport Rd', 'North Little Rock', '72117') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2465') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2465', 'Center Point Terminal - N Little Rock', '3206 Gribble Street', 'North Little Rock', '72114') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2467') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2467', 'TransMontaigne - Razorback', '2801 West Hudson (Hwy 102)', 'Rogers', '72756-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2468') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2468', 'Midcon Fuel Services', 'Port of Little Rock  8401 Lindsey Rd ', 'Little Rock ', '72206') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2469') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2469', 'Bruce Oakley North Little Rock Terminal', '300 River Park Rd ', 'North Little Rock', '72114') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-71-AR-2470') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-71-AR-2470', 'NGL Supply Terminal company LLC - West Memphis', '1241 South 8th Street', 'West Memphis', '72303') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-AR-2450') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-AR-2450', 'Union Pacific Railroad Co.', '11th & Pike Ave.', 'North Little Rock', '72114') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-AR-2455') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-AR-2455', 'Union Pacific Railroad Co.', '1400 East 2nd Ave.', 'Pine Bluff', '71601') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'LA'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2351') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2351', 'Chevron USA, Inc.- Arcadia', 'Highway 80 East', 'Arcadia', '71001-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2353') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2353', 'Sunoco Partners Marketing & Terminals LP', 'Highway 80 East', 'Arcadia', '71001-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2356') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2356', 'Aircraft Service International, Inc.', 'Freight Road', 'Kenner', '70062') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2358') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2358', 'ExxonMobil Oil Corp.', '3329 Scenic Highway', 'Baton Rouge', '70805-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2360') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2360', 'Chalmette Refining, LLC', '1700 Paris Rd Gate 50', 'Chalmette', '70043-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2361') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2361', 'Motiva Enterprises LLC', 'Louisiana Street', 'Covent', '70723-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2363') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2363', 'Marathon Oil Garyville', 'Highway 61', 'Garyville', '70051-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2365') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2365', 'Motiva Enterprises LLC', '143 Firehouse Dr.', 'Kenner', '70062-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2368') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2368', 'CITGO - Lake Charles', 'Cities Serv Hwy & LA Hwy 108', 'Lake Charles', '70601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2371') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2371', 'Valero Refining - Meraux', '2501 East St Bernard Hwy', 'Meraux', '70075-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2375') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2375', 'Buckeye Terminals, LLC - Opelousas', 'Highway 182 South', 'Opelousas', '70571-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2376') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2376', 'Placid Refining Co. LLC', '1940 Louisiana Hwy One North', 'Port Allen', '70767-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2377') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2377', 'IMTT - St Rose', '11842 River Rd.', 'Saint Rose', '70087') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2378') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2378', 'Shreveport Refinery', '3333 Midway  PO Box 3099', 'Shreveport', '71133-3099') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2381') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2381', 'Phillips 66 PL - Westlake', '1980 Old Spanish Trail', 'Westlake', '70669-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2388') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2388', 'Calumet Lubricants Co., LP', 'U. S. Hwy 371 South', 'Cotton Valley', '71018-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2389') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2389', 'Calumet Lubricants Co., LP', '10234 Hwy 157', 'Princeton', '71067-9172') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2391') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2391', 'LBC Baton Rouge LLC', '1725 Highway 75', 'Sunshine', '70780-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2392') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2392', 'Archie Terminal Company', '5010 Hwy 84', 'Jonesville', '71343') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2393') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2393', 'Monroe Terminal Company LLC', '486 Highway 165 South', 'Monroe', '71202') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2394') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2394', 'ERPC Shreveport Area Truck Rack', '4731 Viking Drive', 'Bossier City', '71111') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2395') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2395', 'John W Stone Oil Distributor', '87 1st Street', 'Gretna', '70053') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2397') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2397', 'Five Star Fuels ', '163 Gordy Rd', 'Baldwin', '70514') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2399') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2399', 'Stolthaven New Orleans LLC', '2444 English Turn Road', 'Braithwaite', '70040') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2400') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2400', 'IMTT - Avondale', '5450 River Road', 'Avondale', '70094') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2401') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2401', 'IMTT - Gretna', '1145 4th ST ', 'Harvey', '70058') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2402') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2402', 'REG Geismar LLC', '36187 Hwy 30', 'Geismer', '70734') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2403') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2403', 'Martin Operating Partnership, L.P.', '2254 S Talens Landing Rd ', 'Gueydan', '70542') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2404') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2404', 'Martin Operating Partnership, L.P.', '41937 Hwy 3147', 'Kaplan', '70548') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2406') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2406', 'Martin Operating Partnership, L.P.', '821 Henry Puch Blvd', 'Lake Charles', '70606') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2407') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2407', 'Martin Operating Partnership, L.P.', '300 Adam Ted Gisclair Rd ', 'Golden Meadow', '70357') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2408') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2408', 'Valero Refining - New Orleans', '14902 River Road ', 'Norco', '70087') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2409') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2409', 'Martin Operating Partnership, L.P.', '485 Jump Basin Rd', 'Venice ', '70091') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2410') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2410', 'Martin Operating Partnership, L.P.', '9576 Grand Caillou Rd', 'Dulac', '70354') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2412') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2412', 'Martin Operating Partnership, L.P.', '141 Offshore Lane ', 'Amelia', '70340') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2413') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2413', 'Martin Operating Partnership, L.P.', '24823 LA Hwy 333', 'Abbeville', '70510') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2414') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2414', 'Martin Operating Partnership, L.P.', '332 Davis Rd ', 'Cameron', '70631') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2415') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2415', 'Martin Operating Partnership, L.P.', '100 Spirit Lane ', 'Berwick', '70342') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2416') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2416', 'Martin Operating Partnership, L.P.', '199 Wakefield Rd ', 'Cameron', '70631') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-72-LA-2417') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-72-LA-2417', 'Diamond Green Diesel LLC', '14891 Airline Drive ', 'Norco', '70079') END

END
		
SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OK'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2600') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2600', 'Valero Refining Company - Oklahoma', 'One Valero Way', 'Ardmore', '73401') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2606') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2606', 'Magellan Pipeline Company, L.P.', '1401 North 30th Street', 'Enid', '73701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2608') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2608', 'Phillips 66 PL - Glenpool', '10600 S Elwood', 'Jenks', '74037-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2612') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2612', 'Phillips 66 PL - Oklahoma City', '4700 NE Tenth', 'Oklahoma City', '73111-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2613') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2613', 'Magellan Pipeline Company, L.P.', '251 N Sunny Lane', 'Oklahoma City', '73117-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2614') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2614', 'TransMontaigne - Oklahoma City', '951 N. Vickie', 'Oklahoma City', '73117-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2617') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2617', 'Phillips 66 PL - Ponca City', 'South Highway 60', 'Ponca City', '74601-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2620') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2620', 'Holly Energy Partners - Operating LP', '1307 W 35th St', 'Tulsa', '74107-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2621') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2621', 'Holly Refining and Marketing - Tulsa LLC', '1700 South Union', 'Tulsa', '74102-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2622') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2622', 'Magellan Pipeline Company, L.P.', '2120 S 33rd West Ave.', 'Tulsa', '74107-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2624') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2624', 'Wynnewood Energy Company, LLC', '906 South Powell', 'Wynnewood', '73098-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2626') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2626', 'Oklahoma City Airport Trust', '6131 South Meridian', 'Oklahoma City', '73159') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-73-OK-2628') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-73-OK-2628', 'Kansas City Southern Railway - Heavener', '403 West First Street', 'Heavener', '74937') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'TX'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2658') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2658', 'Sunoco Partners Marketing & Terminals LP', 'Highway 6 South', 'Hearne', '77859') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2700') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2700', 'NuStar Logistics, L. P. - Edinburg', '222 W. Ingle Rd.', 'Edinburg', '78359') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2702') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2702', 'Motiva Enterprises LLC', 'Highway 6 South', 'Hearne', '77859-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2703') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2703', 'CITGO - Victoria', '1708 North Ben Jordan Blvd', 'Victoria', '77901-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2705') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2705', 'Motiva Enterprises LLC', '420 South Lacy drive', 'Waco', '76705-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2706') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2706', 'Flint Hills Resources, LP-Austin', '9011 Johnny Morris Rd', 'Austin', '78724-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2707') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2707', 'Flint Hills Resources, LP-Waco', '2017 Kendall Lane', 'Waco', '76705-3366') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2709') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2709', 'CITGO - Brownsville', '11001 R.L. Ostos Rd.', 'Brownsville', '78521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2712') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2712', 'Calumet San Antonio Refining', '7811 S. Presa', 'San Antonio', '78223') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2713') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2713', 'U.S. Oil - Bryan Finfeather', '1714 Finfeather Road', 'Bryan', '77801-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2714') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2714', 'Valero Refining Co. - Corpus Christi', '5900 Up River Rd.', 'Corpus Christi', '78407') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2715') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2715', 'NuStar Logistics, L. P. - Laredo', '13380 S Unitec Drive', 'Laredo', '78044-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2716') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2716', 'CITGO - Corpus Christi', '1308 Oak Park Street', 'Corpus Christi', '78407-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2717') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2717', 'TransMontaigne - SouthWest', '10150 State Hwy 48', 'Brownsville', '78521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2721') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2721', 'Flint Hills Resources, LP-Corpus Christi', '2825 Suntide Road', 'Corpus Christi', '78403-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2724') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2724', 'Western El Paso', '6501 Trowbridge', 'El Paso', '79905-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2725') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2725', 'Union Pacific Railroad Co.', '6200 N.E. Loop 410', 'San Antonio', '78218') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2726') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2726', 'Holly Energy Partners- Operating LP', '1000 Eastside & 897 Hawkins', 'El Paso', '79915-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2729') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2729', 'NuStar Logistics, L. P. - Harlingen', '4.5 miles east on highway 106', 'Harlingen', '78550-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2737') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2737', 'CITGO - San Antonio', '4851 Emil Road', 'San Antonio', '78219-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2738') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2738', 'NuStar Logistics, L. P. - San Antonio East', '4719 Corner Parkway #2', 'San Antonio', '78219-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2739') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2739', 'NuStar Logistics, L. P. - San Antonio North', '10619 Highway 281 South', 'San Antonio', '78221-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2740') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2740', 'ExxonMobil Oil Corp.', '3214 North Pan Am Expressway', 'San Antonio', '78219-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2742') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2742', 'Flint Hills Resources, LP-San Antonio', '498 and Pop Gun', 'San Antonio', '78219-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2745') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2745', 'Motiva Enterprises LLC', '510 Petroleum Drive', 'San Antonio', '78219-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2747') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2747', 'Diamond Shamrock - Three Rivers', '301 Leroy Street', 'Three Rivers', '78071-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2748') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2748', 'Holly Energy Partners - Operating LP', '1000 South Access Rd.', 'Tye', '79563-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2749') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2749', 'Fikes Wholesale Inc', '1600 South Loop Dr ', 'Waco', '76705') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2750') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2750', 'NuStar Logistics, L. P. - El Paso', '4200 Justice Road', 'El Paso', '79938') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2751') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2751', 'Magellan Pipeline Company, L.P.', '13551 E. Montana Ave.', 'El Paso', '79938') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2752') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2752', 'Flint Hills Resources, LP-Bastrop', '115 Mt. Olive Road', 'Cedar Creek', '78612') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2753') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2753', 'TransMontaigne - Brownsville', '14701 R. L. Ostos Road', 'Brownsville', '78521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2754') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2754', 'TransMontaigne - Border', '8700 State Highway 48', 'Brownsville', '78521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2755') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2755', 'TransMontaigne - Tejano', '6200 State Highway 48', 'Brownsville', '78521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2756') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2756', 'TransMontaigne - Intercoastal', '8701 R. L. Ostos Road', 'Brownsville', '78521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2758') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2758', 'Mustang Ridge Fuels Terminal', '1165 East Lone Star Dr.   ', 'Buda', '76610') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2759') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2759', 'Lazarus Energy LLC', '11372 US Highway 87 East', 'Nixon', '78140') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-74-TX-2760') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-74-TX-2760', 'Flint Hills Resources, LP-San Antonio', '4800 Corerway Blvd', 'San Antonio', '78219') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2650') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2650', 'NuStar Logistics, L. P. - Abernathy', 'Highway 54 - RT. 2, Box 104', 'Abernathy', '79311-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2652') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2652', 'Delek Marketing & Supply, LP', 'Hwy 277 N Industrial District', 'Abilene', '79604-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2653') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2653', 'Nustar Logistics LP - Amarillo, TX', '4200 West Cliffside', 'Amarillo', '79124-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2654') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2654', 'Phillips 66 PL - Amarillo', '4300 Cliffside Dr', 'Amarillo', '79142-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2656') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2656', 'Alon Big Spring', 'East IS-20 & Refinery Rd', 'Big Springs', '79721-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2657') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2657', 'Phillips 66 Co - Borger', 'Spur 119 N.', 'Borger', '79007-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2659') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2659', 'JP Energy Caddo LLC', '2738 County Rd 2168', 'Caddo Mills', '75135') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2660') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2660', 'ExxonMobil Oil Corp.', '1201 East Airport Freeway', 'Irving', '75062-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2661') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2661', 'Magellan Pipeline Company, L.P.', '4200 Singleton Boulevard', 'Dallas', '75212-3433') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2662') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2662', 'Motiva Enterprises LLC', '3900 Singleton Blvd.', 'Dallas', '75212-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2663') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2663', 'Aircraft Service International, Inc.', 'Love Field', 'Dallas', '75235') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2664') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2664', 'Flint Hills Resources, LP-Ft. Worth', 'Highway 157 and Trinity Blvd', 'Euless', '76040-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2665') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2665', 'Magellan Pipeline Company, L.P.', '6000 I H 20', 'Aledo', '76008-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2666') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2666', 'Chevron USA, Inc.- Fort Worth', '2525 Brennan Street', 'Fort Worth', '76106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2667') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2667', 'U.S. Oil - Ft. Worth Terminal', '301 Terminal Road', 'Fort Worth', '76106-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2669') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2669', 'Motiva Enterprises LLC', '3200 N. Sylvania', 'Fort Worth', '76111-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2671') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2671', 'Magellan Pipeline Company, L.P.', '3100 Highway 26 West', 'Grapevine', '76051-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2673') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2673', 'Allied Aviation Fueling of Dallas LP', '2001 W. Airfield Dr. @ 20th St', 'Dallas', '75261') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2674') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2674', 'Phillips 66 PL -  Lubbock', 'Clovis Road and Flint Avenue', 'Lubbock', '79408-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2676') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2676', 'Delek Marketing - Big Sandy', '1503 West Ferguson', 'Mount Pleasant', '75455-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2678') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2678', 'Sunoco Partners Marketing & Terminals LP', '377 State Highway 87 South', 'Center', '75935-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2680') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2680', 'NuStar Logistics, L. P. - Southlake', '1700 Hwy 26', 'Grapevine', '76051-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2681') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2681', 'Delek Refining, LTD.', '425 McMurry Drive', 'Tyler', '75702-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2682') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2682', 'Diamond Shamrock - Sunray', 'HCR 1, Box 36', 'Sunray', '79086-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2683') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2683', 'Holly Energy Partners - Operating LP', '301 Sinclair Blvd.', 'Wichita Falls', '76307') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2684') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2684', 'Phillips 66 PL - Wichita Falls', '1214 North Eastside', 'Wichita Falls', '76304-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2685') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2685', 'Magellan Pipeline Company, L.P.', '2700 S. Grandview', 'Odessa', '79760-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2686') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2686', 'Delek Marketing & Supply, LP', '4008 U S Hwy 67N', 'San Angelo', '76905-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2688') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2688', 'Sunoco Partners Marketing & Terminals LP', '9 South', 'Waskom', '75692-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2690') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2690', 'Direct Fuels LLC', '12625 Calloway Cemetary Rd', 'Euless', '76040-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2691') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2691', 'Chevron Phillips Chemical Co., LP', 'Spur 119E - Philtex Plant', 'Borger', '79007') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2693') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2693', 'BNSF - Amarillo East', '7939 SE 3rd Avenue', 'Amarillo', '79118') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2694') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2694', 'Pro Petroleum, Inc. - Lubbock', '3002 Clovis Rd ', 'Lubbock', '79416') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-75-TX-2695') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-75-TX-2695', 'Valero Terminaling & Distribution', '6647 County Road G ', 'Sunray', '79086') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2780') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2780', 'LBC Houston, LP', '11666 Port Road', 'Seabrook', '77586-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2782') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2782', 'Motiva Enterprises LLC', '1320 West Shaw St.', 'Pasadena', '77501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2783') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2783', 'Motiva Enterprises LLC', '9406 West Port Arthur Rd', 'Beaumont', '77705-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2784') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2784', 'Delek Marketing - Big Sandy', 'Highway 155 and Sabine River', 'Big Sandy', '75755-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2787') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2787', 'Phillips 66 PL - Nederland', 'Hwy 366', 'Nederland', '77627-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2788') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2788', 'KM Liquids Terminals, LLC', '906 Clinton Drive', 'Galena Park', '77547-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2789') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2789', 'Chevron USA, Inc.- Galena Park', '12523 American Petroleum Rd', 'Galena Park', '77547-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2790') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2790', 'Gulf Coast Energy LLC', '17617 Aldine Westfield Rd.', 'Houston', '77073') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2792') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2792', 'Magellan Terminals Holdings LP', '12901 American Petroleum Rd.', 'Galena Park', '77547-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2793') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2793', 'Swissport SA Fuel Services', '8376 Monroe', 'Houston', '77061') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2794') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2794', 'U.S. Oil -Houston North Freeway', '12325 North Fwy at Greens Rd', 'Houston', '77060-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2798') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2798', 'Sunoco Partners Marketing & Terminals LP', '15651 W. Port Arthur Rd.', 'Beaumont', '77705-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2801') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2801', 'Total Petrochemicals', 'Hwy 366 & 32nd St', 'Port Arthur', '77642') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2802') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2802', 'Oil Tanking Houston, Inc.', '15602 Jacinto Port Blvd.', 'Houston', '77015') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2805') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2805', 'Petroleum Wholesale, Inc.', '1801 Collingsworth', 'Houston', '77099') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2806') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2806', 'Valero Refining Co. - Houston', '9701 Manchester', 'Houston', '77262') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2808') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2808', 'ExxonMobil Oil Corp.', '8700 North Freeway', 'Houston', '77037-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2809') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2809', 'KM Liquids Terminals, LLC', '530 North Witter', 'Pasadena', '77506-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2811') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2811', 'Phillips 66 PL - Pasadena', '100 Jefferson Street', 'Pasadena', '77501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2812') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2812', 'ExxonMobil Oil Corp.', '10501 East Almeda', 'Houston', '77051-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2813') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2813', 'Phillips 66 Co - Sweeny', 'Hwys 35 & 36 at West Columbia', 'Sweeny', '77480-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2815') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2815', 'Intercontinental Terminals Co.', '1943 Battleground Rd.', 'Deer Park', '77536-0698') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2817') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2817', 'ERPC North Houston Terminal', 'Corner of Ferrall and E. Hardy', 'Houston', '77063') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2818') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2818', 'Allied Aviation Fueling of Houston LP', '2050 Fuel Storage Rd.', 'Houston', '77205') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2819') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2819', 'Kinder Morgan Galena Park West LLC', '1500 Clinton Dr', 'Galena Park', '77547-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2820') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2820', 'Vopak Terminal Deer Park, Inc.', '2759 Battleground Rd.', 'Deer Park', '77536') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2824') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2824', 'BNSF - Temple', '610 West Avenue D', 'Temple', '76504') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2826') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2826', 'K-Solv L P', '1015 Lakeside', 'Channelview', '77530') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2827') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2827', 'Oiltanking Texas City, LP', '2800 Loop 197 South', 'Texas City', '77592-0029') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2828') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2828', 'Sunoco Partners Marketing & Terminals LP', '2450 FM 3057', 'Bay City', '77404') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2829') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2829', 'Swissport SA Fuel Services', '7690 Airport Boulevard', 'Houston', '77061') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2830') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2830', 'KM Pasadena Truck Facility', '400 N. Jefferson', 'Pasadena', '77506') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2831') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2831', 'Magellan Pipeline Company, L.P.', '7901 Wallisvile Road', 'Houston', '77029') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2832') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2832', 'Lone Star NGL Mont Belvieu LP', '10303 FM 1942', 'Mont Belvieu', '77580') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2833') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2833', 'Magellan Pipeline Company, L.P.', '2115 East Highway 22', 'Mertens ', '76666') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2834') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2834', 'Enterprise Pasadena Products Terminal', '1500 North South Street', 'Pasadena', '77503') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2835') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2835', 'Martin Operating Partnership, L.P.', '200 Pennzoil Road', 'Galveston', '77554') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2836') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2836', 'Martin Operating Partnership, L.P.', '2420 Dowling Rd ', 'Port Arthur', '77640') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2838') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2838', 'Buckeye Texas Hub', '7002 Marvin L Berry Rd ', 'Corpus Christi', '78409') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2839') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2839', 'Martin Operating Partnership, L.P.', '1300 Coastwide Drive ', 'Galveston', '77553') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2840') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2840', 'Martin Operating Partnership, L.P.', '1122 Marlin Lane ', 'Freeport', '77542') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2841') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2841', 'One Cypress Terminals', '11700 Old Hwy 88', 'Brownsville', '78520') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2842') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2842', 'Petromax Refining Company', '1519 S Sheldon Company', 'Houston', '77015') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2843') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2843', 'Intercontinental Terminals Co.', '1030 Ethyl Road ', 'Pasadena', '77503') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-76-TX-2844') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-76-TX-2844', 'Buckeye Texas Processing LLC', '1501 Southern Minerals Rd ', 'Corpus Christi', '78409') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'ID'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-82-ID-4150') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-82-ID-4150', 'Sinclair Transportation Company', '321 North Curtis Road', 'Boise', '83707-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-82-ID-4151') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-82-ID-4151', 'Tesoro Logistics Operations LLC', '201 N. Phillipi', 'Boise', '83706-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-82-ID-4152') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-82-ID-4152', 'United Products Terminal', '70 North Philipi Road', 'Boise', '83706-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-82-ID-4155') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-82-ID-4155', 'Tesoro Logistics Operations LLC', '421 East Highway 81', 'Burley', '83318-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-82-ID-4157') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-82-ID-4157', 'Sinclair Transport.- Burley, ID', '425 East Hwy 81 PO Box 233', 'Burley', '83318-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-82-ID-4159') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-82-ID-4159', 'Tesoro Logistics Operations LLC', '1189 Tank Farm Rd.', 'Pocatello', '83201-') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-ID-4153') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-ID-4153', 'Union Pacific Railroad Co.', '237 East Day St.', 'Pocatello', '83204') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'WY'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4050') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4050', 'Phillips 66 PL - Sheridan', '3404 Highway 87', 'Sheridan', '82801-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4051') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4051', 'Phillips 66 PL - Rock Springs', '90 Foot Hill Blvd', 'Rock Springs', '82902-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4052') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4052', 'Sinclair Casper Refining Company', '5700 E Hwy 20-26', 'Casper', '82609') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4053') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4053', 'Magellan Pipeline Company, L.P.', '1112 Parsley Blvd', 'Cheyenne', '82007-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4054') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4054', 'Sinclair Wyoming Refining Company', '100 East Lincoln Highway', 'Sinclair', '82334-0000') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4055') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4055', 'Holly Energy Partners - Operating LP', '300 Morrie Ave ', 'Cheyenne', '82007-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4056') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4056', 'Wyoming Refining Co. - Newcastle', '740 W Main', 'Newcastle', '82701-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4057') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4057', 'Sinclair Transportation Company', '100 East Lincoln Highway', 'Sinclair', '82334') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4058') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4058', 'Sinclair Transportation Company', '5700 East Highway 20-26', 'Casper ', '82609') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-83-WY-4060') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-83-WY-4060', 'Antelope Refining', '2079 Hwy 59', 'Douglas', '82633') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-WY-4057') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-WY-4057', 'Equitable Oil Purchasing Co', '9397 Highway 59 South', 'Gillette', '82717') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-WY-4058') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-WY-4058', 'Silver Eagle Refining Inc', '2990 County Rd. #180', 'Evanston', '82930') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-WY-4059') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-WY-4059', 'Union Pacific Railroad Co.', '400 West Front St.', 'Rawlins', '82301') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'CO'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4100') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4100', 'Magellan Pipeline Company, L.P.', '15000 E. Smith Rd.', 'Aurora', '80011-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4101') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4101', 'Suncor Energy USA', '5800 Brighton Boulevard', 'Commerce City', '80022-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4102') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4102', 'Suncor Energy USA - Denver', '5575 Brighton Boulevard', 'Commerce City', '80022-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4103') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4103', 'NuStar Logistics, L. P. - Denver', '3601 East 56th Street', 'Commerce City', '80022-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4104') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4104', 'Phillips 66 PL - Denver', '3960 East 56th Avenue', 'Commerce City', '80022-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4105') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4105', 'Magellan Pipeline Company, L.P.', '8160 Krameria', 'DuPont', '80024-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4106') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4106', 'Magellan Pipeline Company, L.P.', '1004 S. Sante Fe', 'Fountain', '80817-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4107') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4107', 'Golden Gate/SET Petroleum Partners', '1493 Hwy 6 & 50', 'Fruita', '81521-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4108') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4108', 'NuStar Logistics, L. P. - Colorado Springs', '7810 Drennan', 'Colorado Springs', '80925-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4109') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4109', 'Sinclair Transport.- Denver CO', '8581 East 96th Ave', 'Henderson', '80640-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4110') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4110', 'Phillips 66 PL - LaJunta Terminal', '31610 East Hwy 50', 'LaJunta', '81050') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4111') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4111', 'Aircraft Service International, Inc.', '11110 Queensburg St.', 'Denver', '80249') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4112') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4112', 'Golden Gate/SET Petroleum Partners', '1629 21 Road', 'Fruita', '81521') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-CO-4113') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-CO-4113', 'Union Pacific Railroad Co.', '1400 West 52nd Ave', 'Denver', '80221') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NM'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4251') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4251', 'South Florida Materials Corp dba Vecenergy', '3200 Broadway SE within city', 'Albuquerque', '87105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4253') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4253', 'NuStar Logistics, L. P. - Albuquerque', '6348 State Rd. 303 SW', 'Albuquerque', '87105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4254') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4254', 'Phillips 66 PL - Albuquerque', '6356 Desert Road SE', 'Albuquerque', '87105-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4255') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4255', 'Giant Mid-Continent Inc. - Albuquerque', '3209 Broadway Southeast', 'Albuquerque', '87105') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4256') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4256', 'Holly Energy Partners - Operating LP', '501 E Main', 'Artesia', '88210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4257') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4257', 'Giant Refining - Bloomfield', '# 50 County Road 4990', 'Bloomfield', '87413-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4258') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4258', 'Giant Refining Company', 'I-40 Exit 39', 'Jamestown', '87347') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4259') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4259', 'Epic Midstream LLC', '6026 Hwy 54 South', 'Alamogordo', '88310-0109') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4261') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4261', 'Aircraft Service International, Inc.', '3531 Access Road C SE ', 'Albuquerque', '87106') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-85-NM-4262') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-85-NM-4262', 'Union Pacific Railroad Co.', '8920 Airport Road ', 'Santa Teresa', '88008') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-NM-4261') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-NM-4261', 'USA Petroleum Southwest Terminal', '3155 Hwy 80, I-10 Exit 5', 'Road Forks', '88045') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-NM-4262') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-NM-4262', 'Holly Energy Partners - Operating LP', '1001 E. Martinez Road', 'Moriarty', '87035') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-NM-4264') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-NM-4264', 'BNSF - Belen', '106 N. First St.', 'Belen', '87002') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AZ'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4300') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4300', 'Caljet of America, LLC', '125 North 53rd Ave', 'Phoenix', '85043-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4302') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4302', 'Arizona Fueling Facilities Corporation', '4200 East Airlane Dr.', 'Phoenix', '85034') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4303') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4303', 'Pro Petroleum, Inc. - Phoenix', '408 S 43rd Avenue', 'Phoenix', '85043') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4304') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4304', 'SFPP, LP Phoenix Terminal', '49 North 53rd Avenue', 'Phoenix', '85043-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4309') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4309', 'Holly Energy Partners - Operating LP', '3605 South Dodge Blvd.', 'Tucson', '85713-5421') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4310') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4310', 'SFPP, LP', '3841 East Refinery Way', 'Tucson', '85713-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4313') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4313', 'Circle K Terminal', '5333 W Van Buren St', 'Phoenix', '85043-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4316') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4316', 'Liquidtitan, LLC', '31645 Industrial Lane', 'Parker', '85344-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4318') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4318', 'Pro Petroleum, Inc - El Mirage ', '12126 W Olive Avenue ', 'El Mirage ', '85333') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-AZ-4319') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-AZ-4319', 'Lupton Petroleum Products', 'I-40 Exit 359 Grant Rd', 'Lupton', '86508') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'NV'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-NV-4352') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-NV-4352', 'Reno Fueling Facilities Corporation', '355 S. Rock Blvd.', 'Reno', '89502') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-86-NV-4355') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-86-NV-4355', 'Swissport Fueling of Nevada, Inc', '575 Kitty Hawk Way', 'Las Vegas', '89111') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4350') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4350', 'Calnev Pipe Line, LLC', '5049 N Sloan', 'Las Vegas', '89115') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4353') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4353', 'SFPP, LP', '301 Nugget Avenue', 'Sparks', '89431-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4354') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4354', 'OP Reno LLC', '525 Nugget Avenue', 'Sparks', '89431-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4359') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4359', 'Rebel Oil Las Vegas Terminal', '5054 N Sloane Lane', 'Las Vegas', '89115') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4362') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4362', 'Pro Petroleum, Inc. - Las Vegas', '4985 N Sloan LN', 'Las Vegas', '89115') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4364') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4364', 'Golden Gate/SET Petroleum Partners', '500 Ireland Drive', 'McCarran', '89434') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-88-NV-4365') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-88-NV-4365', 'Holly Energy Partners - Operating LP', '13420 Grand Valley Parkway', 'North Las Vegas ', '89165') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'UT'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4200') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4200', 'Big West Oil LLC', '333 West Center St', 'North Salt Lake', '84054-0180') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4202') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4202', 'Tesoro Logistics Operations LLC', '474 West 900 N', 'Salt Lake City', '84103-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4203') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4203', 'Chevron USA, Inc.- Salt Lake City', '2350 North 1100 W', 'Salt Lake City', '84116-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4204') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4204', 'Phillips 66 PL - North Salt Lake', '245 East 1100 North', 'North Salt Lake City', '84054-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4205') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4205', 'Silver Eagle Refining Woods Cross Inc', '2355 South 1100 West', 'Woods Cross', '84087-0298') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4206') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4206', 'Holly Energy Partners - Operating LP', '393 South 800 West', 'Woods Cross', '84087-1435') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4207') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4207', 'UNEV Cedar City ', '4410 N Wecco Rd', 'Cedar City ', '84721') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-87-UT-4208') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-87-UT-4208', 'Holly Refining & Marketing Company - Wood Cross', '393 South 800 West', 'Woods Cross', '84087') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-84-UT-4207') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-84-UT-4207', 'Aircraft Service International, Inc.', '1070 North 3930 West', 'Salt Lake City', '84116') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'AK'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4506') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4506', 'Petro Star Inc - Kodiak Oil Sales', '715 Shelikof', 'Kodiak', '99615') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4507') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4507', 'Petro Star Inc - Valdez Petroleum Term', '402 West Egan', 'Valdez', '99686') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4508') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4508', 'Petro Star Inc - Captains Bay', '2158 Captains Bay Rd.', 'Unalaska', '99685') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4509') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4509', 'Petro Star Inc - Westward', '1200 Captains Bay Rd.', 'Unalaska', '99685') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4510') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4510', 'Petro Star Inc - Ballyhoo', '647 Ballyhoo Rd.', 'Unalaska', '99685') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4511') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4511', 'Petro Star Inc - Resoff', '1787 Ballyhoo Rd.', 'Unalaska', '99685') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4512') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4512', 'Harbor Enterprises', '300 Front St.', 'Craig', '99921') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4513') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4513', 'Delta Western - Haines', 'Mile 0 Haines', 'Haines', '99827') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4514') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4514', 'Harbor Enterprises', '4755 Homer Spit Rd.', 'Homer', '99603') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4515') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4515', 'Harbor Enterprises', '3560 N. Douglas Hwy.', 'Juneau', '99802') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4516') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4516', 'Harbor Enterprises', '1100 Steadman St.', 'Ketchikan', '99901') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4517') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4517', 'Harbor Enterprises', '104 Marine Way', 'Kodiak', '99615') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4518') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4518', 'Harbor Enterprises', '901 S. Nordick St.', 'Petersburg', '99833') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4519') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4519', 'Harbor Enterprises', '#1 Lincoln St.', 'Sitka', '99835') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4520') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4520', 'Aircraft Service International, Inc.', '6000 Dehaviland Ave.', 'Anchorage', '99502') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4521') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4521', 'Nikiski Fuel, Inc.', '53200 Nikiski Beach Rd.', 'Nikiski', '99735') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4522') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4522', 'Aleutian Fuel Services', 'Captain Bay', 'Unalaska', '99692') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4523') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4523', 'ORCA Oil--Division of Shoreside Petroleum, Inc.', '100 Ocean Dock Rd.', 'Cordova', '99574') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4524') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4524', 'Delta Western, Inc. - Site 2', '120 Mt. Roberts St.', 'Juneau', '99801') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4525') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4525', 'Delta Western, Inc. - Haines', '900 Main St.', 'Haines', '99827') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4526') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4526', 'Delta Western, Inc. - Site 3', '309 Main St.', 'Dillingham', '99576') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4527') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4527', 'Delta Western, Inc. - Site 4', 'Mile 0 Peninsula Way', 'Naknek', '99633') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4528') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4528', 'Delta Western, Inc. -  Dutch Harbor', '1577 E. Point Loop Rd.', 'Dutch Harbor', '99692') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4529') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4529', 'Delta Western, Inc. - Site 6', '1417 Peninsula St.', 'Wrangell', '99929') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4530') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4530', 'Delta Western, Inc. -  Site 5', 'Airport Drive', 'Yakutat', '99689') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4531') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4531', 'Bonanza Fuel, Inc.', 'Port of Nome', 'Nome', '99762') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4532') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4532', 'St. Paul Delta Fuel Co.', 'UNKNOWN', 'St. Paul Island', '99660') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4533') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4533', 'St. George Delta Fuel Co.', 'Water Front Building', 'St. George Island', '99591') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4534') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4534', 'CPD Alaska LLC', 'Airport Rd.', 'St. Marys', '99658') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4535') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4535', 'CPD Alaska LLC', 'Village Rd.', 'Hooper Bay', '99604') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4538') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4538', 'CPD Alaska LLC', '7th Avenue & H Street', 'Galena', '99741') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4540') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4540', 'CPD Alaska LLC', 'William Loola St.', 'Ft. Yukon', '99740') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4541') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4541', 'Adak Terminal', 'Adak', 'Adak', '99546') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4542') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4542', 'CPD Alaska LLC', '900 Stedman St.', 'Ketchikan', '99901-0858') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4543') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4543', 'CPD Alaska LLC', 'Melspelt St.', 'McGrath', '99627') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4544') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4544', 'CPD Alaska LLC', 'River Rd.', 'Aniak', '99557') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4545') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4545', 'Seldovia Fuel & Lube, Inc.', '319 Main St.', 'Seldovia', '99663') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4546') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4546', 'CPD Alaska LLC', '940 Third St.', 'Kotzebue', '99752') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4547') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4547', 'CPD Alaska LLC', '316 W. First St.', 'Nome', '99762') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4548') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4548', 'Petro Alaska, Inc.', '4161Tongass Ave.', 'Ketchikan', '99901') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4549') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4549', 'Petro Alaska, Inc.', 'Copper River Meridian', 'Thorne Bay', '99919') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4574') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4574', 'Harbor Enterprises', '#10 Beach Rd.', 'Skagway', '99840') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4575') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4575', 'CPD Alaska LLC', '1076 Jacobson Dr.', 'Juneau', '99801') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4576') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4576', 'Red Dog Operations', 'North of Kotzebue', 'UNKNOWN', '99752') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4578') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4578', 'Frosty Fuels LLC', 'Cold Bay', 'Anchorage', '99501') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4579') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4579', 'CPD Alaska LLC', '1120 Standard Oil Road', 'Bethel', '99559') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4580') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4580', 'Petro Star Inc. - North Pole Refinery', '1200 H & H Lane', 'North Pole ', '99705') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4581') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4581', 'Petro Star Inc. - Valdez Refinery', 'Mile 2.5 Dayville Rd.', 'Valdez', '99686') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-AK-4583') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-AK-4583', 'Harbor Enterprises', '1427 Peninsula St.', 'Wrangell', '99929') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4501') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4501', 'Flint Hills Resources Alaska - Anchorage', '1076 Ocean Dock Road', 'Anchorage', '99501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4503') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4503', 'Flint Hills Resources Alaska- North Pole', '1150 H & H Lane', 'North Pole', '99705-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4504') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4504', 'Tesoro Logistics Operations LLC', '1522  Port Rd.', 'Anchorage', '99501-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4505') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4505', 'Tesoro Logistics Operations LLC', '48775 Kenai Spur Hwy', 'Kenai', '99611-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4577') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4577', 'Bristol Alliance Fuels LLC', '106 North Pacific Ct.', 'Dillingham', '99576') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4578') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4578', 'ConocoPhillips Alaska Inc.', 'Lat 70.3238  Lon -149.6051', 'Kuparuk', '99519') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4579') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4579', 'Spruce Island Fuel ', 'PO Box 89', 'Ouzinkie', '99644') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-92-AK-4580') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-92-AK-4580', 'Delta Western, Inc. - Sitka', '5311 Hailibut Point Road ', 'Sitka', '99835') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'HI'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-HI-4570') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-HI-4570', 'Aircraft Service International, Inc.', '200 Rodgers Blvd.', 'Honolulu', '96819') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-HI-4571') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-HI-4571', 'Kauai Petroleum Co., Ltd.', '3185 Waapa Rd.', 'Lihue', '96766') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-HI-4572') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-HI-4572', 'Island Petroleum, Inc.', 'Wharf Rd. & Beach Place #10', 'Kaunakakai', '96748') END
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4551') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4551', 'Aloha Petroleum - Barbers Point', '91-119 Hanua Street', 'Kapolei', '96706') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4552') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4552', 'Chevron USA, Inc.- Hilo', '666 Kalanianaole Avenue', 'Hilo', '96720-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4553') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4553', 'Chevron USA, Inc.- Honolulu', '933 North Nimitz Highway', 'Honolulu', '96817-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4554') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4554', 'Chevron USA, Inc.- Kahului', '100 A Hobron Avenue', 'Kahului', '96732-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4555') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4555', 'Chevron USA, Inc.- Port Allen', 'A & B Road, Port Allen', 'Eleele', '96705') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4557') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4557', 'Aloha Petroleum Ltd.', '789 N. Nimitz Hwy.', 'Honolulu', '96817-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4558') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4558', 'Aloha Petroleum Ltd.', '661 Kalanianaole Ave.', 'Hilo', '96720-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4559') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4559', 'Tesoro Hawaii Corporation', '607 Kalanianaole Ave.', 'Hilo', '96720') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4560') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4560', 'Aloha Petroleum Ltd.', '999 Kalanianaole Ave.', 'Hilo', '96720-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4561') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4561', 'Tesoro Hawaii Corporation', '701 Kalanianaole Street', 'Hilo', '96720-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4562') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4562', 'Aloha Petroleum Ltd.', '3145 Waapa Rd.', 'Lihue', '96766-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4563') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4563', 'Tesoro Hawaii Corporation', '140 H Hobron Ave', 'Kahului', '96732') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4566') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4566', 'Aloha Petroleum Ltd.', '60 Hobron Ave.', 'Kahului', '96732-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4567') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4567', 'Midpac Petroleum Kawaihae Terminal', '61-3651 Kawaihae Road', 'Kamuela', '96743') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4568') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4568', 'Tesoro Hawaii Corporation', '2 Sand Island Access Rd.', 'Honolulu', '96819') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-99-HI-4570') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-99-HI-4570', 'Chevron USA, Inc.- Kapolei', '91-480 Malakole Street', 'Kapolei', '96707') END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OR'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-OR-4450') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-OR-4450', 'Aircraft Service International, Inc.', '8133 NE Airtrans Way', 'Portland', '97218') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-91-OR-4465') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-91-OR-4465', 'Union Pacific Railroad Co.', 'Route 1, Simplot Rd.', 'Hermiston', '97838') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4452') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4452', 'Tidewater Terminal - Umatilla', '535 Port Avenue', 'Umatilla', '97882-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4454') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4454', 'SFPP, LP', '1765 Prairie Road', 'Eugene', '97402-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4455') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4455', 'BP West Coast Products LLC', '9930 NW St Helens Rd', 'Portland', '97231-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4456') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4456', 'Chevron USA, Inc.- Portland', '5524 NW Front Ave', 'Portland', '97210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4457') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4457', 'Kinder Morgan Liquid Terminals, LLC', '5880 NW St. Helens Road', 'Portland', '97283-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4458') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4458', 'McCall Oil and Chemical Corp.', '5480 NW Front Ave', 'Portland', '97210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4459') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4459', 'Shore Terminals LLC - Portland', '9420 Northwest St Helens Rd', 'Portland', '97231-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4461') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4461', 'Shell Oil Products US', '3800 NW St. Helens Road', 'Portland', '97210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4464') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4464', 'Phillips 66 PL - Portland', '5528 Northwest Doane', 'Portland', '97210-') END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTerminalControlNumber WHERE strTerminalControlNumber = 'T-93-OR-4465') BEGIN INSERT INTO tblTFTerminalControlNumber([intTaxAuthorityId],[strTerminalControlNumber],[strName],[strAddress],[strCity],[strZip])
	 VALUES(@intTaxAuthorityId, 'T-93-OR-4465', 'Arc Terminals Holdings LLC', '5501 NW Front Ave ', 'Portland ', '97210') END
END

GO
PRINT 'END TF tblTFTerminalControlNumber'
GO

GO
PRINT 'START TF TCN Deployment Note'
GO

DECLARE @tblTempSource TABLE (strTerminalControlNumber NVARCHAR(30) COLLATE Latin1_General_CI_AS)

	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1000')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1002')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1003')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1004')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1006')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1008')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1009')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1010')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1012')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-01-ME-1015')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-02-NH-1050')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-02-NH-1056')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1151')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1152')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1153')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1154')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1155')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1156')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1158')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1159')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1160')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1162')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1164')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1166')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1167')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1168')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1171')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1172')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1173')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1174')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1176')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1179')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1180')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-MA-1181')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-04-NH-1057')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-05-RI-1201')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-05-RI-1202')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-05-RI-1203')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-05-RI-1205')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-05-RI-1207')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1251')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1252')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1254')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1255')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1256')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1258')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1259')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1262')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1263')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1264')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1265')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1267')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1269')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1270')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1271')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1274')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1279')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1280')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1281')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1282')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1285')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-CT-1286')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-06-RI-1208')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1301')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1302')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1304')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1305')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1306')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1308')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1309')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1310')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1312')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1318')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1324')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1325')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1326')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1332')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1333')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1334')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1335')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-11-NY-1336')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-13-NY-1352')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-13-NY-1353')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-13-NY-1356')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-13-NY-1357')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-13-NY-1358')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-13-NY-1360')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1401')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1402')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1403')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1404')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1405')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1411')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1413')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1414')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1415')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1417')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1421')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1422')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-14-NY-1423')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1451')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1454')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1456')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1457')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1458')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1459')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1461')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1463')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1468')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1469')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1470')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1471')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1472')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1473')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1474')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1476')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1484')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1486')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1488')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1493')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1494')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1497')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-16-NY-1499')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1500')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1502')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1503')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1504')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1506')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1507')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1512')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1513')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1514')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1515')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1516')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1517')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1521')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1522')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1523')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1525')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1526')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1528')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1531')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1532')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1534')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1535')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1538')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1540')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1544')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1545')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1547')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-22-NJ-1548')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1700')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1701')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1702')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1703')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1707')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1709')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1710')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1711')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1713')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1715')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1716')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1718')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1720')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1721')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1722')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1725')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1726')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1727')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1728')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1729')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1730')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1731')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1732')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1733')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1734')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1736')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1737')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1742')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1743')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1744')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1746')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1747')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1748')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1749')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1751')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1752')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1753')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1755')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1757')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1761')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1764')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1766')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-23-PA-1770')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1759')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1760')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1761')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1762')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1767')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1769')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1771')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1773')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1776')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1777')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1778')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1780')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1781')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1783')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1785')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1788')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1789')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1790')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1791')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-25-PA-1792')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3100')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3101')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3102')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3103')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3104')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3105')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3106')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3109')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3111')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3112')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3113')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3114')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3115')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3116')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3117')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3118')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3119')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3120')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3121')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3125')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3127')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3128')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-31-OH-3129')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4744')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4745')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4746')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4747')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4748')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4749')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4750')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4751')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4753')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4757')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4758')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4760')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4761')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4763')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4764')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4765')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4767')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4768')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4769')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4771')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4772')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4773')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4776')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4779')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4782')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4784')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4785')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4786')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4787')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4788')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4789')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4791')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4792')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4794')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4795')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4796')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-CA-4800')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-33-WA-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3140')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3143')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3144')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3145')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3146')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3148')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3149')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3150')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3151')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3152')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3153')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3154')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3155')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3157')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3158')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3159')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3160')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3161')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3162')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3164')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3165')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3166')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3167')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3168')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3169')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3174')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3175')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-34-OH-3176')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3202')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3203')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3204')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3205')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3207')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3208')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3209')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3210')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3211')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3212')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3213')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3214')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3216')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3218')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3219')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3221')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3222')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3224')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3225')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3226')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3227')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3228')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3229')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3230')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3231')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3232')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3234')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3235')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3236')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3237')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3238')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3239')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3243')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3245')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3246')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3248')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-35-IN-3249')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3300')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3301')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3302')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3303')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3304')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3305')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3306')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3307')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3308')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3310')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3311')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3312')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3313')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3315')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3316')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3317')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3318')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3320')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3325')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3326')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3375')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3376')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3377')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-36-IL-3378')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3351')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3353')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3354')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3356')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3358')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3360')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3361')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3364')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3365')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3366')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3368')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3369')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3371')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-37-IL-3372')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3002')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3003')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3004')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3005')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3006')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3007')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3008')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3009')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3010')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3011')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3012')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3013')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3014')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3015')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3016')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3017')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3018')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3019')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3020')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3022')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3023')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3024')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3025')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3028')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3029')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3030')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3032')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3033')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3034')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3037')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3039')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3041')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3043')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3046')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-Mi-3047')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-38-MI-3048')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-IA-3475')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-NE-3604')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-NE-3612')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-NE-3613')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-NE-3614')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-NE-3615')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3061')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3062')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3064')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3065')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3066')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3067')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3068')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3070')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3071')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3072')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3073')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3074')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3075')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3076')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3077')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3079')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3080')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3081')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3082')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3083')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3084')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3086')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3088')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3089')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3090')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-39-WI-3092')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3400')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3401')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3402')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3403')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3404')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3405')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3406')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3407')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3410')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3412')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3413')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3414')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3415')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3416')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3417')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3419')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3420')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3425')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MN-3426')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-41-MT-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3450')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3451')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3452')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3454')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3455')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3456')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3457')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3458')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3460')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3461')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3463')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3464')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3465')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3466')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3467')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3468')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3469')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3470')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3471')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3472')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3473')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-42-IA-3474')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-IL-3729')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-KS-3653')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-KS-3672')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3701')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3703')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3704')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3705')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3707')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3708')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3709')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3713')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3714')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3716')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3718')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3720')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3721')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3722')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3723')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3725')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3726')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3727')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3728')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-43-MO-3729')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3500')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3501')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3502')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3503')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3504')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3505')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3506')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3508')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-45-ND-3509')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3550')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3551')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3552')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3553')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3554')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3555')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3556')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-46-SD-3557')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3600')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3601')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3602')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3603')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3605')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3606')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3607')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3608')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-47-NE-3610')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3651')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3652')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3654')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3655')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3656')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3657')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3658')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3659')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3660')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3661')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3663')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3664')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3665')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3666')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3667')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3670')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3671')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-48-KS-3678')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-50-VA-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-51-DE-1600')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-DE-1602')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1550')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1551')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1552')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1554')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1559')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1560')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1561')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1562')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1563')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1565')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1567')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1568')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1569')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-52-MD-1574')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1650')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1651')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1652')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1653')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1654')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1656')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1657')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1659')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1660')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1661')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1662')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1663')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1664')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1665')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1666')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1667')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1668')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1671')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1673')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1674')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1676')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1677')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1678')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1679')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1681')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1682')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1683')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1684')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1685')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1686')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1687')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1688')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1689')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1690')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1691')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1692')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1694')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1695')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1696')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-54-VA-1700')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-55-WV-3181')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-55-WV-3183')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-55-WV-3184')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-55-WV-3185')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-55-WV-3186')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-55-WV-3188')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2000')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2002')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2003')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2004')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2005')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2006')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2007')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2008')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2009')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2011')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2013')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2014')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2015')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2018')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2019')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2020')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2021')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2022')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2023')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2024')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2025')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2026')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2027')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2028')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2029')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2030')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2031')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2032')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2033')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2034')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2036')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2037')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2038')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2043')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2044')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-56-NC-2045')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2050')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2051')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2052')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2053')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2054')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2059')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2060')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2061')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2062')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2063')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2064')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2066')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2067')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2068')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2074')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2075')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2076')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-57-SC-2077')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2500')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2501')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2502')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2505')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2506')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2507')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2508')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2510')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2511')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2512')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2513')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2514')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2515')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2517')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2519')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2520')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2522')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2523')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2524')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2525')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2526')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2528')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2529')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2531')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2532')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2533')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2534')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2535')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2536')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2537')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2538')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2541')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2542')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2543')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2544')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2545')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2547')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2550')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2551')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2553')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2554')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2555')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-58-GA-2556')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2100')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2101')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2102')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2105')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2106')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2107')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2110')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2111')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2112')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2114')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2115')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2116')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2120')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2122')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2123')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2124')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2129')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2130')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2131')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2133')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2136')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2138')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2677')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2678')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2679')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2680')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-FL-2681')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-59-MS-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3262')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3263')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3264')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3265')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3266')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3267')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3268')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3269')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3270')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3271')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3272')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3273')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3274')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3276')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3277')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3278')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3279')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3280')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3281')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-61-KY-3283')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-KY-2210')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-KY-3285')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2200')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2201')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2202')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2204')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2207')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2208')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2211')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2212')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2213')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2214')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2215')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2217')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2218')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2219')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2220')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2222')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2223')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2225')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2226')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2227')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2228')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2231')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2232')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2233')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2234')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2236')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2237')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2238')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2240')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-62-TN-2241')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2301')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2302')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2304')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2306')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2307')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2308')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2309')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2312')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2314')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2317')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2322')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2323')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2325')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2326')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2327')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2329')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2330')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2333')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2334')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2335')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2336')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2338')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2339')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-63-AL-2340')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2401')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2402')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2404')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2405')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2406')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2408')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2411')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2412')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2414')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2415')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2416')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2418')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2419')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2423')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2424')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-64-MS-2425')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2150')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2152')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2153')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2154')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2156')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2157')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2158')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2159')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2160')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2161')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2163')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2164')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2165')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2166')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-65-FL-2167')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4600')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4603')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4604')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4605')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4606')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4607')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4609')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4610')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4611')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4612')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4613')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4614')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4616')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4617')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4619')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4621')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4622')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4624')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4626')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4628')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4629')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-68-CA-4632')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2451')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2453')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2456')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2457')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2458')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2459')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2460')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2462')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2463')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2464')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2465')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2467')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2468')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2469')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-71-AR-2470')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-AL-2339')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-AL-2343')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-AL-2344')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-AL-2345')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-IL-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-IL-0002')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-IL-0003')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-IL-0004')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-IL-0005')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2351')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2353')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2356')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2358')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2360')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2361')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2363')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2365')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2368')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2371')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2375')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2376')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2377')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2378')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2381')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2388')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2389')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2391')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2392')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2393')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2394')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2395')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2397')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2399')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2400')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2401')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2402')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2403')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2404')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2406')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2407')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2408')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2409')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2410')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2412')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2413')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2414')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2415')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2416')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-LA-2417')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-MS-2420')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-MS-2421')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-MS-2422')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-WI-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-WI-0002')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-72-WI-0003')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-AR-2450')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-AR-2455')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2600')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2606')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2608')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2612')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2613')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2614')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2617')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2620')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2621')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2622')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2624')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2626')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-73-OK-2628')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2658')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2700')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2702')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2703')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2705')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2706')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2707')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2709')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2712')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2713')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2714')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2715')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2716')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2717')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2721')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2724')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2725')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2726')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2729')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2737')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2738')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2739')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2740')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2742')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2745')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2747')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2748')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2749')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2750')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2751')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2752')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2753')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2754')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2755')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2756')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2758')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2759')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-74-TX-2760')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2650')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2652')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2653')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2654')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2656')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2657')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2659')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2660')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2661')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2662')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2663')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2664')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2665')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2666')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2667')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2669')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2671')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2673')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2674')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2676')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2678')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2680')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2681')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2682')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2683')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2684')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2685')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2686')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2688')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2690')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2691')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2693')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2694')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-75-TX-2695')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-AL-0001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2780')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2782')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2783')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2784')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2787')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2788')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2789')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2790')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2792')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2793')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2794')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2798')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2801')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2802')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2805')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2806')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2808')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2809')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2811')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2812')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2813')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2815')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2817')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2818')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2819')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2820')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2824')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2826')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2827')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2828')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2829')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2830')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2831')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2832')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2833')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2834')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2835')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2836')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2838')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2839')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2840')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2841')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2842')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2843')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-76-TX-2844')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4650')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4651')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4652')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4653')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4655')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4657')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4664')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4665')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-77-CA-4666')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4000')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4001')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4002')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4003')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4004')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4005')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4006')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4007')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4008')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4009')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4011')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4013')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4014')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-81-MT-4017')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-82-ID-4150')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-82-ID-4151')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-82-ID-4152')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-82-ID-4155')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-82-ID-4157')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-82-ID-4159')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4050')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4051')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4052')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4053')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4054')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4055')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4056')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4057')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4058')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-83-WY-4060')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4100')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4101')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4102')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4103')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4104')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4105')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4106')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4107')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4108')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4109')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4110')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4111')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4112')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-CO-4113')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-ID-4153')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-UT-4207')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-WY-4057')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-WY-4058')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-84-WY-4059')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4251')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4253')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4254')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4255')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4256')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4257')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4258')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4259')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4261')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-85-NM-4262')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4300')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4302')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4303')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4304')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4309')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4310')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4313')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4316')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4318')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-AZ-4319')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-NM-4261')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-NM-4262')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-NM-4264')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-NV-4352')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-86-NV-4355')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4200')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4202')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4203')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4204')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4205')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4206')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4207')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-87-UT-4208')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4350')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4353')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4354')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4359')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4362')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4364')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-88-NV-4365')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4506')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4507')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4508')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4509')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4510')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4511')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4512')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4513')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4514')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4515')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4516')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4517')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4518')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4519')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4520')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4521')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4522')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4523')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4524')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4525')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4526')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4527')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4528')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4529')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4530')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4531')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4532')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4533')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4534')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4535')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4538')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4540')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4541')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4542')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4543')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4544')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4545')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4546')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4547')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4548')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4549')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4574')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4575')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4576')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4578')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4579')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4580')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4581')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-AK-4583')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-HI-4570')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-HI-4571')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-HI-4572')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-OR-4450')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-OR-4465')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4400')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4401')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4402')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4404')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4406')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4408')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4410')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4411')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4412')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4413')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4414')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4415')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4417')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4418')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4419')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4420')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4421')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4425')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4427')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4428')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4430')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4431')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4433')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-91-WA-4434')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4501')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4503')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4504')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4505')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4577')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4578')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4579')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-92-AK-4580')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4452')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4454')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4455')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4456')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4457')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4458')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4459')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4461')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4464')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-93-OR-4465')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4700')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4701')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4702')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4705')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4706')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4707')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-94-CA-4708')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4800')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4803')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4804')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4805')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4807')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4808')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4810')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4811')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-95-CA-4812')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4551')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4552')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4553')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4554')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4555')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4557')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4558')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4559')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4560')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4561')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4562')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4563')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4566')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4567')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4568')
	INSERT @tblTempSource (strTerminalControlNumber) VALUES ('T-99-HI-4570')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFTerminalControlNumber', intTerminalControlNumberId, strTerminalControlNumber, intTaxAuthorityId, '', GETDATE() 
FROM tblTFTerminalControlNumber A WHERE NOT EXISTS (SELECT strTerminalControlNumber FROM @tblTempSource B WHERE A.strTerminalControlNumber = B.strTerminalControlNumber)

GO
PRINT 'END TF TCN Deployment Note'
GO


