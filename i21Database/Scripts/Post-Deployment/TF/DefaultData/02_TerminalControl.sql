PRINT ('Deploying Terminal Control Number')

-- Terminal Control Numbers
/* Generate script for Terminal Control Numbers. Specify Tax Authority Id to filter out specific Terminal Control Numbers only.
select 'UNION ALL SELECT intTerminalControlNumberId = ' + CAST(0 AS NVARCHAR(10)) 
	+ CASE WHEN strTerminalControlNumber IS NULL THEN ', strTerminalControlNumber = NULL' ELSE ', strTerminalControlNumber = ''' + strTerminalControlNumber + ''''  END
	+ CASE WHEN strName IS NULL THEN ', strName = NULL' ELSE ', strName = ''' + strName + ''''  END
	+ CASE WHEN strAddress IS NULL THEN ', strAddress = NULL' ELSE ', strAddress = ''' + strAddress + ''''  END
	+ CASE WHEN strCity IS NULL THEN ', strCity = NULL' ELSE ', strCity = ''' + strCity + '''' END 
	+ CASE WHEN dtmApprovedDate IS NULL THEN ', dtmApprovedDate = NULL' ELSE ', dtmApprovedDate = ''' + CAST(dtmApprovedDate AS NVARCHAR(50)) + '''' END 
	+ CASE WHEN strZip IS NULL THEN ', strZip = NULL' ELSE ', strZip = ''' + strZip + '''' END 
--	+ ', intMasterId = ' + CAST((CASE WHEN ISNULL(intMasterId, '') = '' THEN intTerminalControlNumberId ELSE intMasterId END) AS NVARCHAR(20)) -- Old Format
	+ ', intMasterId = ' + CASE WHEN intMasterId IS NULL THEN CAST(@TaxAuthorityId AS NVARCHAR(20)) + CAST(intTerminalControlNumberId AS NVARCHAR(20)) ELSE CAST(intMasterId AS NVARCHAR(20)) END -- First 2 digit for TaxAuthorityCodeID
from tblTFTerminalControlNumber
where intTaxAuthorityId = @TaxAuthorityId
*/

DECLARE @TerminalIN AS TFTerminalControlNumbers

-- IN Terminals
INSERT INTO @TerminalIN(
		intTerminalControlNumberId
		, strTerminalControlNumber
		, strName
		, strAddress
		, strCity
		, dtmApprovedDate
		, strZip
		, intMasterId
	)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3202', strName = 'Valero Terminaling & Distribution', strAddress = '1020 141st St', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320-', intMasterId = 14374
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3203', strName = 'Buckeye Terminals, LLC - Granger', strAddress = '12694 Adams Rd', strCity = 'Granger', dtmApprovedDate = NULL, strZip = '46530', intMasterId = 14375
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3204', strName = 'BP Products North America Inc', strAddress = '2500 N Tibbs Avenue', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222', intMasterId = 14376
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3205', strName = 'BP Products North America Inc', strAddress = '2530 Indianapolis Blvd.', strCity = 'Whiting', dtmApprovedDate = NULL, strZip = '46394', intMasterId = 14377
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3207', strName = 'Marathon Evansville', strAddress = '2500 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712', intMasterId = 14378
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3208', strName = 'Marathon Huntington', strAddress = '4648 N. Meridian Road', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14379
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3209', strName = 'CITGO Petroleum Corporation - East Chicago', strAddress = '2500 East Chicago Ave', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312', intMasterId = 14380
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3210', strName = 'CITGO - Huntington', strAddress = '4393 N Meridian Rd US 24', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14381
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3211', strName = 'Gladieux Trading & Marketing Co.', strAddress = '4757 US 24 E', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14382
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3212', strName = 'TransMontaigne - Kentuckiana', strAddress = '20 Jackson St.', strCity = 'New Albany', dtmApprovedDate = NULL, strZip = '47150', intMasterId = 14383
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3213', strName = 'TransMontaigne - Evansville', strAddress = '2630 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712', intMasterId = 14384
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3214', strName = 'Countrymark Cooperative LLP', strAddress = '1200 Refinery Road', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620', intMasterId = 14385
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3216', strName = 'HWRT Terminal - Seymour', strAddress = '9780 N US Hwy 31', strCity = 'Seymour', dtmApprovedDate = NULL, strZip = '47274', intMasterId = 14386
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3218', strName = 'Marathon Hammond', strAddress = '4206 Columbia Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327', intMasterId = 14387
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3219', strName = 'Marathon Indianapolis', strAddress = '4955 Robison Rd', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268-1040', intMasterId = 14388
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3221', strName = 'Marathon Muncie', strAddress = '2100 East State Road 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303-4773', intMasterId = 14389
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3222', strName = 'Marathon Speedway', strAddress = '1304 Olin Ave', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222-3294', intMasterId = 14390
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3224', strName = 'ExxonMobil Oil Corp.', strAddress = '1527 141th Street', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327', intMasterId = 14391
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3225', strName = 'Buckeye Terminals, LLC - East Chicago', strAddress = '400 East Columbus Dr', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312', intMasterId = 14392
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3226', strName = 'Buckeye Terminals, LLC - Raceway', strAddress = '3230 N Raceway Road', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234', intMasterId = 14393
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3227', strName = 'NuStar Terminals Operations Partnership L. P. - Indianapolis', strAddress = '3350 N. Raceway Rd.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234-1163', intMasterId = 14394
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3228', strName = 'Buckeye Terminals, LLC - East Hammond', strAddress = '2400 Michigan St.', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320', intMasterId = 14395
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3229', strName = 'Buckeye Terminals, LLC - Muncie', strAddress = '2000 East State Rd. 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303', intMasterId = 14396
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3230', strName = 'Buckeye Terminals, LLC - Zionsville', strAddress = '5405 West 96th St.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268', intMasterId = 14397
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3231', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4691 N Meridian St', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14398
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3232', strName = 'ERPC Princeton', strAddress = 'CR 950 E', strCity = 'Oakland City', dtmApprovedDate = NULL, strZip = '47660', intMasterId = 14399
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3234', strName = 'Lassus Bros. Oil, Inc. - Huntington', strAddress = '4413 North Meridian Rd', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14400
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3235', strName = 'Countrymark Cooperative LLP', strAddress = '17710 Mule Barn Road', strCity = 'Westfield', dtmApprovedDate = NULL, strZip = '46074', intMasterId = 14401
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3236', strName = 'Countrymark Cooperative LLP', strAddress = '1765 West Logansport Rd.', strCity = 'Peru', dtmApprovedDate = NULL, strZip = '46970', intMasterId = 14402
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3237', strName = 'Countrymark Cooperative LLP', strAddress = 'RR # 1, Box 119A', strCity = 'Switz City', dtmApprovedDate = NULL, strZip = '47465', intMasterId = 14403
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3238', strName = 'Buckeye Terminals, LLC - Indianapolis', strAddress = '10700 E County Rd 300N', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234', intMasterId = 14404
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3239', strName = 'Marathon Mt Vernon', strAddress = '129 South Barter Street ', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620-', intMasterId = 14405
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3243', strName = 'CSX Transportation Inc', strAddress = '491 S. County Road 800 E.', strCity = 'Avon', dtmApprovedDate = NULL, strZip = '46123-', intMasterId = 14406
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3245', strName = 'Norfolk Southern Railway Co End Terminal', strAddress = '2600 W. Lusher Rd.', strCity = 'Elkhart', dtmApprovedDate = NULL, strZip = '46516-', intMasterId = 14407
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3246', strName = 'Buckeye Terminals, LLC - South Bend', strAddress = '20630 W. Ireland Rd.', strCity = 'South Bend', dtmApprovedDate = NULL, strZip = '46614-', intMasterId = 14408
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3248', strName = 'West Shore Pipeline Company - Hammond', strAddress = '3900 White Oak Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320', intMasterId = 14409
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-35-IN-3249', strName = 'NGL Supply Terminal Company LLC - Lebanon', strAddress = '550 West County Road 125 South', strCity = 'Lebanon', dtmApprovedDate = NULL, strZip = '46052', intMasterId = 14410

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'IN' , @TerminalControlNumbers = @TerminalIN

-- IL Terminals
DECLARE @TerminalIL AS TFTerminalControlNumbers

INSERT INTO @TerminalIL(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3300', strName = 'Valero Terminaling & Distribution', strAddress = '3600 W 131st Street', strCity = 'Alsip', dtmApprovedDate = NULL, strZip = '60803', intMasterId = 13411
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3301', strName = 'BP Products North America Inc', strAddress = '1111 Elmhurst Rd', strCity = 'Elk Grove Village', dtmApprovedDate = NULL, strZip = '60007', intMasterId = 13412
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3302', strName = 'BP Products North America Inc', strAddress = '4811 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13413
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3303', strName = 'BP Products North America Inc', strAddress = '100 East Standard Oil Road', strCity = 'Rochelle', dtmApprovedDate = NULL, strZip = '61068', intMasterId = 13414
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3304', strName = 'CITGO - Mt.  Prospect', strAddress = '2316 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13415
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3305', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '8500 West 68th Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501-0409', intMasterId = 13416
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3306', strName = 'Buckeye Terminals, LLC - Rockford', strAddress = '1511 South Meridian Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102-', intMasterId = 13417
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3307', strName = 'Marathon Mt. Prospect', strAddress = '3231 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005-4610', intMasterId = 13418
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3308', strName = 'Marathon Oil Rockford', strAddress = '7312 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 13419
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3310', strName = 'NuStar Terminal Services, Inc - Blue Island', strAddress = '3210 West 131st Street', strCity = 'Blue Island', dtmApprovedDate = NULL, strZip = '60406-2364', intMasterId = 13420
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3311', strName = 'ExxonMobil Oil Corp.', strAddress = '2312 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13421
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3312', strName = 'Petroleum Fuel & Terminal - Forest View', strAddress = '4801 South Harlem', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13422
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3313', strName = 'Buckeye Terminals, LLC - Kankakee', strAddress = '275 North 2750 West Road', strCity = 'Kankakee', dtmApprovedDate = NULL, strZip = '60901', intMasterId = 13423
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3315', strName = 'Buckeye Terminals, LLC - Argo', strAddress = '8600 West 71st. Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501', intMasterId = 13424
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3316', strName = 'Shell Oil Products US', strAddress = '1605 E. Algonquin Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13425
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3317', strName = 'CITGO - Lemont', strAddress = '135th & New Avenue', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 13426
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3318', strName = 'CITGO - Arlington Heights', strAddress = '2304 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13427
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3320', strName = 'Magellan Pipeline Company, L.P.', strAddress = '10601 Franklin Avenue', strCity = 'Franklin Park', dtmApprovedDate = NULL, strZip = '60131', intMasterId = 13428
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3325', strName = 'Aircraft Service International, Inc.', strAddress = 'Chicago O''Hare Int''l Airport', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60666', intMasterId = 13429
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3326', strName = 'United Parcel Service Inc', strAddress = '3300 Airport Dr', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61109', intMasterId = 13430
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3375', strName = 'ExxonMobil Oil Corporation', strAddress = '12909 High Road', strCity = 'Lockport', dtmApprovedDate = NULL, strZip = '60441-', intMasterId = 13431
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3376', strName = 'Aircraft Service International, Inc.', strAddress = 'Midway Airport', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60638', intMasterId = 13432
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3377', strName = 'IMTT-Illinois', strAddress = '24420 W Durkee Road', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 13433
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-36-IL-3378', strName = 'Oiltanking Joliet', strAddress = '27100 South Frontage Rd', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 13434
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3351', strName = 'BP Products North America Inc', strAddress = '1000 BP Lane', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13435
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3353', strName = 'Phillips 66 PL - Hartford', strAddress = '2150 Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13436
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3354', strName = 'Hartford Wood River Terminal', strAddress = '900 North Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13437
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3356', strName = 'Buckeye Terminals, LLC - Hartford', strAddress = '220 E Hawthorne Street', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-', intMasterId = 13438
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3358', strName = 'Marathon Champaign', strAddress = '511 S. Staley Road', strCity = 'Champaign', dtmApprovedDate = NULL, strZip = '61821', intMasterId = 13439
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3360', strName = 'Marathon Robinson', strAddress = '12345 E 1050th Ave', strCity = 'Robinson', dtmApprovedDate = NULL, strZip = '62454', intMasterId = 13440
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3361', strName = 'HWRT Terminal - Norris City', strAddress = 'Rural Route 2', strCity = 'Norris City', dtmApprovedDate = NULL, strZip = '62869', intMasterId = 13441
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3364', strName = 'Growmark, Inc.', strAddress = 'Rt 49 South', strCity = 'Ashkum', dtmApprovedDate = NULL, strZip = '60911', intMasterId = 13442
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3365', strName = 'Buckeye Terminals, LLC - Decatur', strAddress = '266 E Shafer Drive', strCity = 'Forsyth', dtmApprovedDate = NULL, strZip = '62535', intMasterId = 13443
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3366', strName = 'Phillips 66 PL - E. St.  Louis', strAddress = '3300 Mississippi Ave', strCity = 'Cahokia', dtmApprovedDate = NULL, strZip = '62206', intMasterId = 13444
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3368', strName = 'Buckeye Terminals, LLC - Effingham', strAddress = '18264 N US Hwy 45', strCity = 'Effingham', dtmApprovedDate = NULL, strZip = '62401', intMasterId = 13445
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3369', strName = 'Buckeye Terminals, LLC - Harristown', strAddress = '600 E. Lincoln Memorial Pky', strCity = 'Harristown', dtmApprovedDate = NULL, strZip = '62537', intMasterId = 13446
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3371', strName = 'Magellan Pipeline Company, L.P.', strAddress = '16490 East 100 North Rd.', strCity = 'Heyworth', dtmApprovedDate = NULL, strZip = '61745', intMasterId = 13447
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-37-IL-3372', strName = 'Growmark, Inc.', strAddress = '18349 State Hwy 29', strCity = 'Petersburg', dtmApprovedDate = NULL, strZip = '62675', intMasterId = 13448
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-43-IL-3729', strName = 'Omega Partners III, LLC', strAddress = '1402 S Delmare', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-0065', intMasterId = 13449
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-IL-0001', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3400 South Badger Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13450
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-IL-0002', strName = 'West Shore Pipeline Company - Forest View', strAddress = '5027 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13451
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-IL-0003', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3223 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13452
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-IL-0004', strName = 'West Shore Pipeline Company - Rockford', strAddress = '7245 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 13453
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-IL-0005', strName = 'IMTT - Lemont', strAddress = '13589 Main Street', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 13454

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'IL', @TerminalControlNumbers = @TerminalIL

-- MS Terminals
DECLARE @TerminalMS AS TFTerminalControlNumbers

INSERT INTO @TerminalMS(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-59-MS-0001', strName = 'Scott Petroleum Corporation', strAddress = '942 N. Broadway', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701', intMasterId = 24852
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2401', strName = 'Chevron USA, Inc.- Collins', strAddress = 'Old Highway 49 South', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24853
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2402', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '31 Kola Road', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24854
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2404', strName = 'Motiva Enterprises LLC', strAddress = '49 So. & Kola Rd.', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24855
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2405', strName = 'TransMontaigne - Collins', strAddress = 'First Avenue South', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24856
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2406', strName = 'Transmontaigne - Greenville- S', strAddress = '310 Walthall Street', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24857
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2408', strName = 'TransMontaigne - Greenville - N', strAddress = '208 Short Clay Street', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24858
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2411', strName = 'MGC Terminals', strAddress = '101 65th Avenue', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39301-', intMasterId = 24859
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2412', strName = 'CITGO - Meridian', strAddress = '180 65th Avenue', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39305-', intMasterId = 24860
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2414', strName = 'Murphy Oil USA, Inc. - Meridian', strAddress = '6540 N. Frontage Rd.', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39301-', intMasterId = 24861
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2415', strName = 'TransMontaigne - Meridian', strAddress = '1401 65th Ave S', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39307-', intMasterId = 24862
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2416', strName = 'Chevron USA, Inc.- Pascagoula', strAddress = 'Industrial Road State Hwy 611', strCity = 'Pascagoula', dtmApprovedDate = NULL, strZip = '39568-1300', intMasterId = 24863
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2418', strName = 'Hunt-Southland Refining Co', strAddress = '2 mi N on Hwy 11 PO Drawer A', strCity = 'Sandersville', dtmApprovedDate = NULL, strZip = '39477-', intMasterId = 24864
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2419', strName = 'CITGO - Vicksburg', strAddress = '1585 Haining Rd', strCity = 'Vicksburg', dtmApprovedDate = NULL, strZip = '39180-', intMasterId = 24865
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2423', strName = 'Lone Star NGL Hattiesburg LLC', strAddress = '1234 Highway 11', strCity = 'Petal', dtmApprovedDate = NULL, strZip = '39465', intMasterId = 24866
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2424', strName = 'Hunt Southland Refining Company', strAddress = '2600 Dorsey Street', strCity = 'Vicksburg', dtmApprovedDate = NULL, strZip = '39180', intMasterId = 24867
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-64-MS-2425', strName = 'Kior Columbus LLC', strAddress = '600 Industrial Park Acces Rd ', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '39701', intMasterId = 24868
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-MS-2420', strName = 'Martin Operating Partnership, L.P.', strAddress = '5320 Ingalls Ave.', strCity = 'Pascagoula', dtmApprovedDate = NULL, strZip = '39581', intMasterId = 24869
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-MS-2421', strName = 'Delta Terminal, Inc.', strAddress = '2181 Harbor Front', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24870
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-MS-2422', strName = 'ERPC Aberdeen ', strAddress = '20096 Norm Connell Drive', strCity = 'Aberdeen', dtmApprovedDate = NULL, strZip = '39730', intMasterId = 24871

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MS', @TerminalControlNumbers = @TerminalMS

-- NE Terminals
DECLARE @TerminalNE AS TFTerminalControlNumbers

INSERT INTO @TerminalNE(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-39-NE-3604', strName = 'Signature Flight Support Corp.', strAddress = '3636 Wilbur Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27515
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-39-NE-3612', strName = 'Magellan Pipeline Company, L.P.', strAddress = '13029 S 13th St', strCity = 'Bellevue', dtmApprovedDate = NULL, strZip = '68123', intMasterId = 27516
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-39-NE-3613', strName = 'Truman Arnold Co. - TAC Air', strAddress = '3737 Orville Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27517
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-39-NE-3614', strName = 'Union Pacific Railroad Co.', strAddress = '6000 West Front St.', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101', intMasterId = 27518
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-39-NE-3615', strName = 'BNSF - Lincoln', strAddress = '201 North 7th Street', strCity = 'Lincoln', dtmApprovedDate = NULL, strZip = '68508', intMasterId = 27519
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3600', strName = 'NuStar Pipeline Operating Partnership, L.P. - Columbus', strAddress = 'R R 5, Box 27 BB', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '68601-', intMasterId = 27520
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3601', strName = 'NuStar Pipeline Operating Partnership, L.P. - Geneva', strAddress = 'U S Highway 81', strCity = 'Geneva', dtmApprovedDate = NULL, strZip = '68361-', intMasterId = 27521
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3602', strName = 'Magellan Pipeline Company, L.P.', strAddress = '12275 South US Hwy 281', strCity = 'Doniphan', dtmApprovedDate = NULL, strZip = '68832-', intMasterId = 27522
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3603', strName = 'Phillips 66 PL - Lincoln', strAddress = '1345 Saltillo Rd.', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430', intMasterId = 27523
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3605', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2000 Saltillo Road', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430', intMasterId = 27524
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3606', strName = 'NuStar Pipeline Operating Partnership, L.P. - Norfolk', strAddress = 'Highway 81', strCity = 'Norfolk', dtmApprovedDate = NULL, strZip = '68701', intMasterId = 27525
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3607', strName = 'NuStar Pipeline Operating Partnership, L.P. - North Platte', strAddress = 'Rural Route Four', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101', intMasterId = 27526
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3608', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2205 N 11th St', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27527
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-47-NE-3610', strName = 'NuStar Pipeline Operating Partnership, L.P. - Osceola', strAddress = 'Rural Route 1', strCity = 'Osceola', dtmApprovedDate = NULL, strZip = '68651', intMasterId = 27528

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NE', @TerminalControlNumbers = @TerminalNE

-- LA Terminals
DECLARE @TerminalLA AS TFTerminalControlNumbers

INSERT INTO @TerminalLA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2351', strName = 'Chevron USA, Inc.- Arcadia', strAddress = 'Highway 80 East', strCity = 'Arcadia', dtmApprovedDate = NULL, strZip = '71001-', intMasterId = 18970
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2353', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Highway 80 East', strCity = 'Arcadia', dtmApprovedDate = NULL, strZip = '71001-', intMasterId = 18971
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2356', strName = 'Aircraft Service International, Inc.', strAddress = 'Freight Road', strCity = 'Kenner', dtmApprovedDate = NULL, strZip = '70062', intMasterId = 18972
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2358', strName = 'ExxonMobil Oil Corp.', strAddress = '3329 Scenic Highway', strCity = 'Baton Rouge', dtmApprovedDate = NULL, strZip = '70805-', intMasterId = 18973
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2360', strName = 'Chalmette Refining, LLC', strAddress = '1700 Paris Rd Gate 50', strCity = 'Chalmette', dtmApprovedDate = NULL, strZip = '70043-', intMasterId = 18974
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2361', strName = 'Motiva Enterprises LLC', strAddress = 'Louisiana Street', strCity = 'Covent', dtmApprovedDate = NULL, strZip = '70723-', intMasterId = 18975
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2363', strName = 'Marathon Oil Garyville', strAddress = 'Highway 61', strCity = 'Garyville', dtmApprovedDate = NULL, strZip = '70051-', intMasterId = 18976
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2365', strName = 'Motiva Enterprises LLC', strAddress = '143 Firehouse Dr.', strCity = 'Kenner', dtmApprovedDate = NULL, strZip = '70062-', intMasterId = 18977
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2368', strName = 'CITGO - Lake Charles', strAddress = 'Cities Serv Hwy & LA Hwy 108', strCity = 'Lake Charles', dtmApprovedDate = NULL, strZip = '70601-', intMasterId = 18978
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2371', strName = 'Valero Refining - Meraux', strAddress = '2501 East St Bernard Hwy', strCity = 'Meraux', dtmApprovedDate = NULL, strZip = '70075-', intMasterId = 18979
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2375', strName = 'Buckeye Terminals, LLC - Opelousas', strAddress = 'Highway 182 South', strCity = 'Opelousas', dtmApprovedDate = NULL, strZip = '70571-', intMasterId = 18980
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2376', strName = 'Placid Refining Co. LLC', strAddress = '1940 Louisiana Hwy One North', strCity = 'Port Allen', dtmApprovedDate = NULL, strZip = '70767-', intMasterId = 18981
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2377', strName = 'IMTT - St Rose', strAddress = '11842 River Rd.', strCity = 'Saint Rose', dtmApprovedDate = NULL, strZip = '70087', intMasterId = 18982
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2378', strName = 'Shreveport Refinery', strAddress = '3333 Midway  PO Box 3099', strCity = 'Shreveport', dtmApprovedDate = NULL, strZip = '71133-3099', intMasterId = 18983
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2381', strName = 'Phillips 66 PL - Westlake', strAddress = '1980 Old Spanish Trail', strCity = 'Westlake', dtmApprovedDate = NULL, strZip = '70669-', intMasterId = 18984
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2388', strName = 'Calumet Lubricants Co., LP', strAddress = 'U. S. Hwy 371 South', strCity = 'Cotton Valley', dtmApprovedDate = NULL, strZip = '71018-', intMasterId = 18985
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2389', strName = 'Calumet Lubricants Co., LP', strAddress = '10234 Hwy 157', strCity = 'Princeton', dtmApprovedDate = NULL, strZip = '71067-9172', intMasterId = 18986
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2391', strName = 'LBC Baton Rouge LLC', strAddress = '1725 Highway 75', strCity = 'Sunshine', dtmApprovedDate = NULL, strZip = '70780-', intMasterId = 18987
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2392', strName = 'Archie Terminal Company', strAddress = '5010 Hwy 84', strCity = 'Jonesville', dtmApprovedDate = NULL, strZip = '71343', intMasterId = 18988
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2393', strName = 'Monroe Terminal Company LLC', strAddress = '486 Highway 165 South', strCity = 'Monroe', dtmApprovedDate = NULL, strZip = '71202', intMasterId = 18989
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2394', strName = 'ERPC Shreveport Area Truck Rack', strAddress = '4731 Viking Drive', strCity = 'Bossier City', dtmApprovedDate = NULL, strZip = '71111', intMasterId = 18990
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2395', strName = 'John W Stone Oil Distributor', strAddress = '87 1st Street', strCity = 'Gretna', dtmApprovedDate = NULL, strZip = '70053', intMasterId = 18991
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2397', strName = 'Five Star Fuels ', strAddress = '163 Gordy Rd', strCity = 'Baldwin', dtmApprovedDate = NULL, strZip = '70514', intMasterId = 18992
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2399', strName = 'Stolthaven New Orleans LLC', strAddress = '2444 English Turn Road', strCity = 'Braithwaite', dtmApprovedDate = NULL, strZip = '70040', intMasterId = 18993
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2400', strName = 'IMTT - Avondale', strAddress = '5450 River Road', strCity = 'Avondale', dtmApprovedDate = NULL, strZip = '70094', intMasterId = 18994
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2401', strName = 'IMTT - Gretna', strAddress = '1145 4th ST ', strCity = 'Harvey', dtmApprovedDate = NULL, strZip = '70058', intMasterId = 18995
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2402', strName = 'REG Geismar LLC', strAddress = '36187 Hwy 30', strCity = 'Geismer', dtmApprovedDate = NULL, strZip = '70734', intMasterId = 18996
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2403', strName = 'Martin Operating Partnership, L.P.', strAddress = '2254 S Talens Landing Rd ', strCity = 'Gueydan', dtmApprovedDate = NULL, strZip = '70542', intMasterId = 18997
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2404', strName = 'Martin Operating Partnership, L.P.', strAddress = '41937 Hwy 3147', strCity = 'Kaplan', dtmApprovedDate = NULL, strZip = '70548', intMasterId = 18998
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2406', strName = 'Martin Operating Partnership, L.P.', strAddress = '821 Henry Puch Blvd', strCity = 'Lake Charles', dtmApprovedDate = NULL, strZip = '70606', intMasterId = 18999
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2407', strName = 'Martin Operating Partnership, L.P.', strAddress = '300 Adam Ted Gisclair Rd ', strCity = 'Golden Meadow', dtmApprovedDate = NULL, strZip = '70357', intMasterId = 181000
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2408', strName = 'Valero Refining - New Orleans', strAddress = '14902 River Road ', strCity = 'Norco', dtmApprovedDate = NULL, strZip = '70087', intMasterId = 181001
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2409', strName = 'Martin Operating Partnership, L.P.', strAddress = '485 Jump Basin Rd', strCity = 'Venice ', dtmApprovedDate = NULL, strZip = '70091', intMasterId = 181002
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2410', strName = 'Martin Operating Partnership, L.P.', strAddress = '9576 Grand Caillou Rd', strCity = 'Dulac', dtmApprovedDate = NULL, strZip = '70354', intMasterId = 181003
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2412', strName = 'Martin Operating Partnership, L.P.', strAddress = '141 Offshore Lane ', strCity = 'Amelia', dtmApprovedDate = NULL, strZip = '70340', intMasterId = 181004
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2413', strName = 'Martin Operating Partnership, L.P.', strAddress = '24823 LA Hwy 333', strCity = 'Abbeville', dtmApprovedDate = NULL, strZip = '70510', intMasterId = 181005
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2414', strName = 'Martin Operating Partnership, L.P.', strAddress = '332 Davis Rd ', strCity = 'Cameron', dtmApprovedDate = NULL, strZip = '70631', intMasterId = 181006
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2415', strName = 'Martin Operating Partnership, L.P.', strAddress = '100 Spirit Lane ', strCity = 'Berwick', dtmApprovedDate = NULL, strZip = '70342', intMasterId = 181007
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2416', strName = 'Martin Operating Partnership, L.P.', strAddress = '199 Wakefield Rd ', strCity = 'Cameron', dtmApprovedDate = NULL, strZip = '70631', intMasterId = 181008
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-72-LA-2417', strName = 'Diamond Green Diesel LLC', strAddress = '14891 Airline Drive ', strCity = 'Norco', dtmApprovedDate = NULL, strZip = '70079', intMasterId = 181009

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'LA', @TerminalControlNumbers = @TerminalLA

-- MI Terminals
DECLARE @TerminalMI AS TFTerminalControlNumbers

INSERT INTO @TerminalMI(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3001', strName = 'U.S. Oil - Cheboygan', strAddress = '311 Coast Guard Drive', strCity = 'Cheyboygan', dtmApprovedDate = NULL, strZip = '49721', intMasterId = 22455
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3002', strName = 'U.S. Oil - Rogers City', strAddress = '1035 Calcite Rd.', strCity = 'Rogers City', dtmApprovedDate = NULL, strZip = '49779', intMasterId = 22456
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3003', strName = 'Waterfront Petroleum Terminal Co.', strAddress = '1071 Miller Rd.', strCity = 'Dearborn', dtmApprovedDate = NULL, strZip = '48120', intMasterId = 22457
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3004', strName = 'Buckeye Terminals, LLC - Napoleon', strAddress = '6777 Brooklyn Road', strCity = 'Napoleon', dtmApprovedDate = NULL, strZip = '49261', intMasterId = 22458
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3005', strName = 'Buckeye Terminals, LLC - River Rouge', strAddress = '205 Marion Street', strCity = 'River Rouge', dtmApprovedDate = NULL, strZip = '48218', intMasterId = 22459
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3006', strName = 'Buckeye Terminals, LLC - Dearborn', strAddress = '8503 South Inkster Rd.', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180-2114', intMasterId = 22460
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3007', strName = 'Buckeye Pipe Line Holdings, L.P - Taylor', strAddress = '24801 Ecorse Rd', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180', intMasterId = 22461
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3008', strName = 'CITGO - Ferrysburg', strAddress = '524 Third Street', strCity = 'Ferrysburg', dtmApprovedDate = NULL, strZip = '49409', intMasterId = 22462
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3009', strName = 'CITGO - Jackson', strAddress = '2001 Morrill Rd', strCity = 'Jackson', dtmApprovedDate = NULL, strZip = '49201', intMasterId = 22463
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3010', strName = 'CITGO - Niles', strAddress = '2233 South Third', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22464
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3011', strName = 'Marathon Niles', strAddress = '2140 South Third St.', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22465
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3012', strName = 'Cousins Petroleum - Taylor', strAddress = '7965 Holland', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180', intMasterId = 22466
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3013', strName = 'Buckeye Terminals, LLC - Ferrysburg', strAddress = '17806 North Shore Dr.', strCity = 'Ferrysburg', dtmApprovedDate = NULL, strZip = '49409', intMasterId = 22467
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3014', strName = 'Buckeye Terminals, LLC - Taylor East', strAddress = '24501 Ecorse Rd', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180', intMasterId = 22468
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3015', strName = 'Marathon Detroit', strAddress = '12700 Toronto St.', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 22469
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3016', strName = 'Marathon Flint', strAddress = '6065 North Dort Highway', strCity = 'Mt. Morris', dtmApprovedDate = NULL, strZip = '48458', intMasterId = 22470
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3017', strName = 'Marathon Jackson', strAddress = '2090 Morrill Rd', strCity = 'Jackson', dtmApprovedDate = NULL, strZip = '49201-8238', intMasterId = 22471
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3018', strName = 'Delta Fuel Facility - DTW Metro', strAddress = 'West. Service Rd.', strCity = 'Romulus', dtmApprovedDate = NULL, strZip = '48174', intMasterId = 22472
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3019', strName = 'Marathon Oil Niles', strAddress = '2216 South Third Street', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120-4010', intMasterId = 22473
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3020', strName = 'Marathon N. Muskegon', strAddress = '3005 Holton Rd', strCity = 'North Muskegon', dtmApprovedDate = NULL, strZip = '49445-2513', intMasterId = 22474
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3022', strName = 'Buckeye Terminals, LLC - Flint', strAddress = 'G5340 North Dort Highway', strCity = 'Flint', dtmApprovedDate = NULL, strZip = '48505', intMasterId = 22475
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3023', strName = 'Buckeye Terminals, LLC - Niles West', strAddress = '2150 South Third Street', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22476
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3024', strName = 'Buckeye Terminals, LLC - Woodhaven', strAddress = '20755 West Road', strCity = 'Woodhaven', dtmApprovedDate = NULL, strZip = '48183-', intMasterId = 22477
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3025', strName = 'Buckeye Terminals, LLC - Detroit', strAddress = '700 S. Deacon Street', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 22478
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3028', strName = 'Buckeye Terminals, LLC - Niles', strAddress = '2303 South Third Street', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22479
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3029', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4004 West Main Rd', strCity = 'Owosso', dtmApprovedDate = NULL, strZip = '48867', intMasterId = 22480
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3030', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '500 South Dix Avenue', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 22481
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3032', strName = 'Marathon Bay City', strAddress = '1806 Marquette', strCity = 'Bay City', dtmApprovedDate = NULL, strZip = '48706', intMasterId = 22482
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3033', strName = 'Marathon Lansing', strAddress = '6300 West Grand River', strCity = 'Lansing', dtmApprovedDate = NULL, strZip = '48906', intMasterId = 22483
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3034', strName = 'Marathon Romulus', strAddress = '28001 Citrin Drive', strCity = 'Romulus', dtmApprovedDate = NULL, strZip = '48174', intMasterId = 22484
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3037', strName = 'Sonoco Partners Marketing & Terminals LP', strAddress = '29120 Wick Road', strCity = 'Romulus', dtmApprovedDate = NULL, strZip = '48174', intMasterId = 22485
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3039', strName = 'Delta Fuels of Michigan', strAddress = '40600 Grand River', strCity = 'Novi', dtmApprovedDate = NULL, strZip = '48374', intMasterId = 22486
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3041', strName = 'Holland Terminal, Inc.', strAddress = '630 Ottawa Avenue', strCity = 'Holland', dtmApprovedDate = NULL, strZip = '49423', intMasterId = 22487
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3043', strName = 'Buckeye Terminals, LLC - Marshall', strAddress = '12451 Old US 27 South', strCity = 'Marshall', dtmApprovedDate = NULL, strZip = '49068', intMasterId = 22488
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3046', strName = 'Marysville Hydrocarbons', strAddress = '2510 Busha Highway', strCity = 'Marysville', dtmApprovedDate = NULL, strZip = '48040', intMasterId = 22489
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3047', strName = 'Waterfront Petroleum Terminal Co.', strAddress = '5431 W Jefferson', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48209', intMasterId = 22490
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-38-MI-3048', strName = 'Plains LPG Services LP', strAddress = '1575 Fred Moore Hwy', strCity = 'St Clair', dtmApprovedDate = NULL, strZip = '48079', intMasterId = 22491

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MI', @TerminalControlNumbers = @TerminalMI

-- NC Terminals
DECLARE @TerminalNC AS TFTerminalControlNumbers

INSERT INTO @TerminalNC(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2000', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '6801 Freedom Dr', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33712
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2001', strName = 'CITGO - Charlotte', strAddress = '7600 Mount Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214-', intMasterId = 33713
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2002', strName = 'Marathon Oil Charlotte', strAddress = '8035 Mt. Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28130', intMasterId = 33714
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2003', strName = 'Eco-Energy', strAddress = '7720 Mr. Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33715
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2004', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '502 Tom Sadler Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33716
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2005', strName = 'Motiva Enterprises LLC', strAddress = '6851 Freedom Dr.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33717
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2006', strName = 'Magellan Terminals Holdings LP', strAddress = '7145 Mount Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33718
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2007', strName = 'Motiva Enterprises LLC', strAddress = '410 Tom Sadler Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33719
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2008', strName = 'Marathon Charlotte (East)', strAddress = '7401 Old Mount Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214-', intMasterId = 33720
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2009', strName = 'Motiva Enterprises LLC', strAddress = '992 Shaw Mill Road', strCity = 'Fayetteville', dtmApprovedDate = NULL, strZip = '28311-', intMasterId = 33721
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2011', strName = 'Magellan Terminals Holdings LP', strAddress = '7109 West Market Street', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409', intMasterId = 33722
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2013', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '2101 West Oak St.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576', intMasterId = 33723
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2014', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '6907 West Market Street', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33724
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2015', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '6376 Burnt Poplar Rd', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33725
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2018', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '2200 West Oak St.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33726
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2019', strName = 'Center Point Terminal - Greensboro', strAddress = '6900 West Market St', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33727
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2020', strName = 'Magellan Terminals Holdings LP', strAddress = '115 Chimney Rock Road', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-9661', intMasterId = 33728
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2021', strName = 'Motiva Enterprises LLC', strAddress = '101 S. Chimney Rock Rd.', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409', intMasterId = 33729
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2022', strName = 'TransMontaigne - Greensboro', strAddress = '6801 West Market Street', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33730
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2023', strName = 'TransMontaigne - Charlotte/Paw Creek', strAddress = '7615 Old Mount Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214-', intMasterId = 33731
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2024', strName = 'Magellan Terminals Holdings LP', strAddress = '7924 Mt. Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33732
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2025', strName = 'Arc Terminals Holdings LLC', strAddress = '2999 W. Oak St.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33733
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2026', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '7325 Old Mount Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33734
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2027', strName = 'Motiva Enterprises LLC', strAddress = '2232 Ten-Ten.  Road', strCity = 'Apex', dtmApprovedDate = NULL, strZip = '27502-', intMasterId = 33735
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2028', strName = 'TransMontaigne - Selma - N', strAddress = '2600 W. Oak St. (SSR 1929)', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33736
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2029', strName = 'Marathon Selma', strAddress = '3707 Buffalo Road', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33737
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2030', strName = 'CITGO - Selma', strAddress = '4095 Buffalo Rd', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33738
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2031', strName = 'Marathon Selma', strAddress = '2555 West Oak Street', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33739
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2032', strName = 'Aircraft Service International, Inc.', strAddress = '6502 Old Dowd Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28219', intMasterId = 33740
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2033', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4383 Buffalo Rd.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33741
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2034', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4086 Buffalo Road', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33742
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2036', strName = 'Magellan Terminals Holdings LP', strAddress = '4414 Buffalo Road', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33743
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2037', strName = 'Buckeye Terminals, LLC - Wilmington', strAddress = '1312 S Front St.', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28401-', intMasterId = 33744
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2038', strName = 'Piedmont Aviation Services, Inc.', strAddress = '6427 Bryan Blvd.', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409', intMasterId = 33745
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2043', strName = 'Apex Oil Company', strAddress = '3314 River Road', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28403-', intMasterId = 33746
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2044', strName = 'Kinder Morgan Terminals Wilmington LLC', strAddress = '1710 Woodbine St.', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28402', intMasterId = 33747
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-56-NC-2045', strName = 'Raleigh-Durham Airport Authority', strAddress = '2800 W. Terminal Blvd.', strCity = 'Morrisville', dtmApprovedDate = NULL, strZip = '27560', intMasterId = 33748

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NC', @TerminalControlNumbers = @TerminalNC

-- OR Terminals
DECLARE @TerminalOR AS TFTerminalControlNumbers

INSERT INTO @TerminalOR(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-OR-4450', strName = 'Aircraft Service International, Inc.', strAddress = '8133 NE Airtrans Way', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97218', intMasterId = 371291
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-OR-4465', strName = 'Union Pacific Railroad Co.', strAddress = 'Route 1, Simplot Rd.', strCity = 'Hermiston', dtmApprovedDate = NULL, strZip = '97838', intMasterId = 371292
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4452', strName = 'Tidewater Terminal - Umatilla', strAddress = '535 Port Avenue', strCity = 'Umatilla', dtmApprovedDate = NULL, strZip = '97882-', intMasterId = 371293
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4454', strName = 'SFPP, LP', strAddress = '1765 Prairie Road', strCity = 'Eugene', dtmApprovedDate = NULL, strZip = '97402-', intMasterId = 371294
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4455', strName = 'BP West Coast Products LLC', strAddress = '9930 NW St Helens Rd', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97231-', intMasterId = 371295
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4456', strName = 'Chevron USA, Inc.- Portland', strAddress = '5524 NW Front Ave', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371296
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4457', strName = 'Kinder Morgan Liquid Terminals, LLC', strAddress = '5880 NW St. Helen''s Road', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97283-', intMasterId = 371297
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4458', strName = 'McCall Oil and Chemical Corp.', strAddress = '5480 NW Front Ave', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371298
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4459', strName = 'Shore Terminals LLC - Portland', strAddress = '9420 Northwest St Helen''s Rd', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97231-', intMasterId = 371299
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4461', strName = 'Shell Oil Products US', strAddress = '3800 NW St. Helen''s Road', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371300
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4464', strName = 'Phillips 66 PL - Portland', strAddress = '5528 Northwest Doane', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371301
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-93-OR-4465', strName = 'Arc Terminals Holdings LLC', strAddress = '5501 NW Front Ave ', strCity = 'Portland ', dtmApprovedDate = NULL, strZip = '97210', intMasterId = 371302

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'OR', @TerminalControlNumbers = @TerminalOR

-- WA Terminals
DECLARE @TerminalWA AS TFTerminalControlNumbers

INSERT INTO @TerminalWA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-33-WA-0001', strName = 'Petrogas', strAddress = '4100 Unick Road', strCity = 'Ferndale', dtmApprovedDate = NULL, strZip = '98248', intMasterId = 47349
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4400', strName = 'Shell Oil Products US', strAddress = 'Marches Point Five Miles', strCity = 'Anacortes', dtmApprovedDate = NULL, strZip = '98221-', intMasterId = 47350
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4401', strName = 'Phillips 66 PL - Moses Lake', strAddress = '3 miles north of Moses Lake', strCity = 'Moses Lake', dtmApprovedDate = NULL, strZip = '98837-', intMasterId = 47351
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4402', strName = 'Tesoro Logistics Operations LLC', strAddress = '3000 Sacajawea Park Road', strCity = 'Pasco', dtmApprovedDate = NULL, strZip = '99301-', intMasterId = 47352
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4404', strName = 'Phillips 66 PL - Renton', strAddress = '2423 Lind Avenue Southwest', strCity = 'Renton', dtmApprovedDate = NULL, strZip = '98055-', intMasterId = 47353
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4406', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '2720 13th Avenue SW', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '98134-', intMasterId = 47354
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4408', strName = 'Shell Oil Products US', strAddress = '2555 13th Ave. S W', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '98134-', intMasterId = 47355
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4410', strName = 'Phillips 66 PL - Spokane', strAddress = '6317 East Sharp Avenue', strCity = 'Spokane', dtmApprovedDate = NULL, strZip = '99206-', intMasterId = 47356
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4411', strName = 'ExxonMobil Oil Corp.', strAddress = '6311 East Sharp Avenue', strCity = 'Spokane', dtmApprovedDate = NULL, strZip = '99211-', intMasterId = 47357
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4412', strName = 'Holly Energy Partners - Operating LP', strAddress = '3225 East Lincoln Road', strCity = 'Spokane', dtmApprovedDate = NULL, strZip = '99217-', intMasterId = 47358
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4413', strName = 'Phillips 66 PL - Tacoma', strAddress = '520 E D Street', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98421-', intMasterId = 47359
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4414', strName = 'Targa Sound Terminal', strAddress = '2628 Marine View Drive', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98422', intMasterId = 47360
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4415', strName = 'Shore Terminals LLC - Tacoma', strAddress = '250 East D Street', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98421', intMasterId = 47361
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4417', strName = 'NuStar Terminals Operations Partnership L. P. - Vancouver', strAddress = '5420 Fruit Valley Road', strCity = 'Vancouver', dtmApprovedDate = NULL, strZip = '98660-', intMasterId = 47362
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4418', strName = 'BP West Coast Products LLC', strAddress = '4519 Grandview', strCity = 'Blaine', dtmApprovedDate = NULL, strZip = '98231-', intMasterId = 47363
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4419', strName = 'Tesoro Logistics Operations LLC', strAddress = '2211 West 26th Street', strCity = 'Vancouver', dtmApprovedDate = NULL, strZip = '98660-', intMasterId = 47364
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4420', strName = 'Tidewater Terminal - Snake River', strAddress = 'Tank Farm Road', strCity = 'Pasco', dtmApprovedDate = NULL, strZip = '99301-', intMasterId = 47365
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4421', strName = 'U.S. Oil & Refining Co.', strAddress = '3001 Marshall Ave', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98421-', intMasterId = 47366
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4425', strName = 'BP West Coast Products LLC', strAddress = '1652 SW Lander St', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '95124-', intMasterId = 47367
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4427', strName = 'Phillips 66 Co - Ferndale', strAddress = '3901 Unic Rd.', strCity = 'Ferndale', dtmApprovedDate = NULL, strZip = '98248-', intMasterId = 47368
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4428', strName = 'Tesoro Logistics Operations LLC', strAddress = 'West March Point Road', strCity = 'Anacortes', dtmApprovedDate = NULL, strZip = '98221', intMasterId = 47369
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4430', strName = 'NuStar Terminal Services, Inc - Vancouver', strAddress = 'Port of Vancouver Terminal #2', strCity = 'Vancouver', dtmApprovedDate = NULL, strZip = '98666', intMasterId = 47370
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4431', strName = 'Swissport Fueling, Inc.', strAddress = '2350 South 190th St.', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '98188', intMasterId = 47371
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4433', strName = 'Imperium Grays Harbor', strAddress = '3122 Port Industrial road ', strCity = 'Hoquian ', dtmApprovedDate = NULL, strZip = '98550', intMasterId = 47372
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T-91-WA-4434', strName = 'BNSF - Pasco', strAddress = '3490 N Railroad Avenue', strCity = 'Pasco', dtmApprovedDate = NULL, strZip = '99301', intMasterId = 47373

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'WA', @TerminalControlNumbers = @TerminalWA

GO


