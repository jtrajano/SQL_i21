PRINT ('Deploying Terminal Control Number')

-- Terminal Control Numbers
/* Generate script for Terminal Control Numbers. Specify Tax Authority Id to filter out specific Terminal Control Numbers only.
select 'UNION ALL SELECT intTerminalControlNumberId = ' + CAST(intTerminalControlNumberId AS NVARCHAR(10)) 
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
SELECT intTerminalControlNumberId = 374, strTerminalControlNumber = 'T-35-IN-3202', strName = 'Valero Terminaling & Distribution', strAddress = '1020 141st St', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320-', intMasterId = 14374
UNION ALL SELECT intTerminalControlNumberId = 375, strTerminalControlNumber = 'T-35-IN-3203', strName = 'Buckeye Terminals, LLC - Granger', strAddress = '12694 Adams Rd', strCity = 'Granger', dtmApprovedDate = NULL, strZip = '46530', intMasterId = 14375
UNION ALL SELECT intTerminalControlNumberId = 376, strTerminalControlNumber = 'T-35-IN-3204', strName = 'BP Products North America Inc', strAddress = '2500 N Tibbs Avenue', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222', intMasterId = 14376
UNION ALL SELECT intTerminalControlNumberId = 377, strTerminalControlNumber = 'T-35-IN-3205', strName = 'BP Products North America Inc', strAddress = '2530 Indianapolis Blvd.', strCity = 'Whiting', dtmApprovedDate = NULL, strZip = '46394', intMasterId = 14377
UNION ALL SELECT intTerminalControlNumberId = 378, strTerminalControlNumber = 'T-35-IN-3207', strName = 'Marathon Evansville', strAddress = '2500 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712', intMasterId = 14378
UNION ALL SELECT intTerminalControlNumberId = 379, strTerminalControlNumber = 'T-35-IN-3208', strName = 'Marathon Huntington', strAddress = '4648 N. Meridian Road', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14379
UNION ALL SELECT intTerminalControlNumberId = 380, strTerminalControlNumber = 'T-35-IN-3209', strName = 'CITGO Petroleum Corporation - East Chicago', strAddress = '2500 East Chicago Ave', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312', intMasterId = 14380
UNION ALL SELECT intTerminalControlNumberId = 381, strTerminalControlNumber = 'T-35-IN-3210', strName = 'CITGO - Huntington', strAddress = '4393 N Meridian Rd US 24', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14381
UNION ALL SELECT intTerminalControlNumberId = 382, strTerminalControlNumber = 'T-35-IN-3211', strName = 'Gladieux Trading & Marketing Co.', strAddress = '4757 US 24 E', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14382
UNION ALL SELECT intTerminalControlNumberId = 383, strTerminalControlNumber = 'T-35-IN-3212', strName = 'TransMontaigne - Kentuckiana', strAddress = '20 Jackson St.', strCity = 'New Albany', dtmApprovedDate = NULL, strZip = '47150', intMasterId = 14383
UNION ALL SELECT intTerminalControlNumberId = 384, strTerminalControlNumber = 'T-35-IN-3213', strName = 'TransMontaigne - Evansville', strAddress = '2630 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712', intMasterId = 14384
UNION ALL SELECT intTerminalControlNumberId = 385, strTerminalControlNumber = 'T-35-IN-3214', strName = 'Countrymark Cooperative LLP', strAddress = '1200 Refinery Road', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620', intMasterId = 14385
UNION ALL SELECT intTerminalControlNumberId = 386, strTerminalControlNumber = 'T-35-IN-3216', strName = 'HWRT Terminal - Seymour', strAddress = '9780 N US Hwy 31', strCity = 'Seymour', dtmApprovedDate = NULL, strZip = '47274', intMasterId = 14386
UNION ALL SELECT intTerminalControlNumberId = 387, strTerminalControlNumber = 'T-35-IN-3218', strName = 'Marathon Hammond', strAddress = '4206 Columbia Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327', intMasterId = 14387
UNION ALL SELECT intTerminalControlNumberId = 388, strTerminalControlNumber = 'T-35-IN-3219', strName = 'Marathon Indianapolis', strAddress = '4955 Robison Rd', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268-1040', intMasterId = 14388
UNION ALL SELECT intTerminalControlNumberId = 389, strTerminalControlNumber = 'T-35-IN-3221', strName = 'Marathon Muncie', strAddress = '2100 East State Road 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303-4773', intMasterId = 14389
UNION ALL SELECT intTerminalControlNumberId = 390, strTerminalControlNumber = 'T-35-IN-3222', strName = 'Marathon Speedway', strAddress = '1304 Olin Ave', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222-3294', intMasterId = 14390
UNION ALL SELECT intTerminalControlNumberId = 391, strTerminalControlNumber = 'T-35-IN-3224', strName = 'ExxonMobil Oil Corp.', strAddress = '1527 141th Street', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327', intMasterId = 14391
UNION ALL SELECT intTerminalControlNumberId = 392, strTerminalControlNumber = 'T-35-IN-3225', strName = 'Buckeye Terminals, LLC - East Chicago', strAddress = '400 East Columbus Dr', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312', intMasterId = 14392
UNION ALL SELECT intTerminalControlNumberId = 393, strTerminalControlNumber = 'T-35-IN-3226', strName = 'Buckeye Terminals, LLC - Raceway', strAddress = '3230 N Raceway Road', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234', intMasterId = 14393
UNION ALL SELECT intTerminalControlNumberId = 394, strTerminalControlNumber = 'T-35-IN-3227', strName = 'NuStar Terminals Operations Partnership L. P. - Indianapolis', strAddress = '3350 N. Raceway Rd.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234-1163', intMasterId = 14394
UNION ALL SELECT intTerminalControlNumberId = 395, strTerminalControlNumber = 'T-35-IN-3228', strName = 'Buckeye Terminals, LLC - East Hammond', strAddress = '2400 Michigan St.', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320', intMasterId = 14395
UNION ALL SELECT intTerminalControlNumberId = 396, strTerminalControlNumber = 'T-35-IN-3229', strName = 'Buckeye Terminals, LLC - Muncie', strAddress = '2000 East State Rd. 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303', intMasterId = 14396
UNION ALL SELECT intTerminalControlNumberId = 397, strTerminalControlNumber = 'T-35-IN-3230', strName = 'Buckeye Terminals, LLC - Zionsville', strAddress = '5405 West 96th St.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268', intMasterId = 14397
UNION ALL SELECT intTerminalControlNumberId = 398, strTerminalControlNumber = 'T-35-IN-3231', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4691 N Meridian St', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14398
UNION ALL SELECT intTerminalControlNumberId = 399, strTerminalControlNumber = 'T-35-IN-3232', strName = 'ERPC Princeton', strAddress = 'CR 950 E', strCity = 'Oakland City', dtmApprovedDate = NULL, strZip = '47660', intMasterId = 14399
UNION ALL SELECT intTerminalControlNumberId = 400, strTerminalControlNumber = 'T-35-IN-3234', strName = 'Lassus Bros. Oil, Inc. - Huntington', strAddress = '4413 North Meridian Rd', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14400
UNION ALL SELECT intTerminalControlNumberId = 401, strTerminalControlNumber = 'T-35-IN-3235', strName = 'Countrymark Cooperative LLP', strAddress = '17710 Mule Barn Road', strCity = 'Westfield', dtmApprovedDate = NULL, strZip = '46074', intMasterId = 14401
UNION ALL SELECT intTerminalControlNumberId = 402, strTerminalControlNumber = 'T-35-IN-3236', strName = 'Countrymark Cooperative LLP', strAddress = '1765 West Logansport Rd.', strCity = 'Peru', dtmApprovedDate = NULL, strZip = '46970', intMasterId = 14402
UNION ALL SELECT intTerminalControlNumberId = 403, strTerminalControlNumber = 'T-35-IN-3237', strName = 'Countrymark Cooperative LLP', strAddress = 'RR # 1, Box 119A', strCity = 'Switz City', dtmApprovedDate = NULL, strZip = '47465', intMasterId = 14403
UNION ALL SELECT intTerminalControlNumberId = 404, strTerminalControlNumber = 'T-35-IN-3238', strName = 'Buckeye Terminals, LLC - Indianapolis', strAddress = '10700 E County Rd 300N', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234', intMasterId = 14404
UNION ALL SELECT intTerminalControlNumberId = 405, strTerminalControlNumber = 'T-35-IN-3239', strName = 'Marathon Mt Vernon', strAddress = '129 South Barter Street ', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620-', intMasterId = 14405
UNION ALL SELECT intTerminalControlNumberId = 406, strTerminalControlNumber = 'T-35-IN-3243', strName = 'CSX Transportation Inc', strAddress = '491 S. County Road 800 E.', strCity = 'Avon', dtmApprovedDate = NULL, strZip = '46123-', intMasterId = 14406
UNION ALL SELECT intTerminalControlNumberId = 407, strTerminalControlNumber = 'T-35-IN-3245', strName = 'Norfolk Southern Railway Co End Terminal', strAddress = '2600 W. Lusher Rd.', strCity = 'Elkhart', dtmApprovedDate = NULL, strZip = '46516-', intMasterId = 14407
UNION ALL SELECT intTerminalControlNumberId = 408, strTerminalControlNumber = 'T-35-IN-3246', strName = 'Buckeye Terminals, LLC - South Bend', strAddress = '20630 W. Ireland Rd.', strCity = 'South Bend', dtmApprovedDate = NULL, strZip = '46614-', intMasterId = 14408
UNION ALL SELECT intTerminalControlNumberId = 409, strTerminalControlNumber = 'T-35-IN-3248', strName = 'West Shore Pipeline Company - Hammond', strAddress = '3900 White Oak Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320', intMasterId = 14409
UNION ALL SELECT intTerminalControlNumberId = 410, strTerminalControlNumber = 'T-35-IN-3249', strName = 'NGL Supply Terminal Company LLC - Lebanon', strAddress = '550 West County Road 125 South', strCity = 'Lebanon', dtmApprovedDate = NULL, strZip = '46052', intMasterId = 14410

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
SELECT intTerminalControlNumberId = 411, strTerminalControlNumber = 'T-36-IL-3300', strName = 'Valero Terminaling & Distribution', strAddress = '3600 W 131st Street', strCity = 'Alsip', dtmApprovedDate = NULL, strZip = '60803', intMasterId = 13411
UNION ALL SELECT intTerminalControlNumberId = 412, strTerminalControlNumber = 'T-36-IL-3301', strName = 'BP Products North America Inc', strAddress = '1111 Elmhurst Rd', strCity = 'Elk Grove Village', dtmApprovedDate = NULL, strZip = '60007', intMasterId = 13412
UNION ALL SELECT intTerminalControlNumberId = 413, strTerminalControlNumber = 'T-36-IL-3302', strName = 'BP Products North America Inc', strAddress = '4811 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13413
UNION ALL SELECT intTerminalControlNumberId = 414, strTerminalControlNumber = 'T-36-IL-3303', strName = 'BP Products North America Inc', strAddress = '100 East Standard Oil Road', strCity = 'Rochelle', dtmApprovedDate = NULL, strZip = '61068', intMasterId = 13414
UNION ALL SELECT intTerminalControlNumberId = 415, strTerminalControlNumber = 'T-36-IL-3304', strName = 'CITGO - Mt.  Prospect', strAddress = '2316 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13415
UNION ALL SELECT intTerminalControlNumberId = 416, strTerminalControlNumber = 'T-36-IL-3305', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '8500 West 68th Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501-0409', intMasterId = 13416
UNION ALL SELECT intTerminalControlNumberId = 417, strTerminalControlNumber = 'T-36-IL-3306', strName = 'Buckeye Terminals, LLC - Rockford', strAddress = '1511 South Meridian Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102-', intMasterId = 13417
UNION ALL SELECT intTerminalControlNumberId = 418, strTerminalControlNumber = 'T-36-IL-3307', strName = 'Marathon Mt. Prospect', strAddress = '3231 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005-4610', intMasterId = 13418
UNION ALL SELECT intTerminalControlNumberId = 419, strTerminalControlNumber = 'T-36-IL-3308', strName = 'Marathon Oil Rockford', strAddress = '7312 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 13419
UNION ALL SELECT intTerminalControlNumberId = 420, strTerminalControlNumber = 'T-36-IL-3310', strName = 'NuStar Terminal Services, Inc - Blue Island', strAddress = '3210 West 131st Street', strCity = 'Blue Island', dtmApprovedDate = NULL, strZip = '60406-2364', intMasterId = 13420
UNION ALL SELECT intTerminalControlNumberId = 421, strTerminalControlNumber = 'T-36-IL-3311', strName = 'ExxonMobil Oil Corp.', strAddress = '2312 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13421
UNION ALL SELECT intTerminalControlNumberId = 422, strTerminalControlNumber = 'T-36-IL-3312', strName = 'Petroleum Fuel & Terminal - Forest View', strAddress = '4801 South Harlem', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13422
UNION ALL SELECT intTerminalControlNumberId = 423, strTerminalControlNumber = 'T-36-IL-3313', strName = 'Buckeye Terminals, LLC - Kankakee', strAddress = '275 North 2750 West Road', strCity = 'Kankakee', dtmApprovedDate = NULL, strZip = '60901', intMasterId = 13423
UNION ALL SELECT intTerminalControlNumberId = 424, strTerminalControlNumber = 'T-36-IL-3315', strName = 'Buckeye Terminals, LLC - Argo', strAddress = '8600 West 71st. Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501', intMasterId = 13424
UNION ALL SELECT intTerminalControlNumberId = 425, strTerminalControlNumber = 'T-36-IL-3316', strName = 'Shell Oil Products US', strAddress = '1605 E. Algonquin Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13425
UNION ALL SELECT intTerminalControlNumberId = 426, strTerminalControlNumber = 'T-36-IL-3317', strName = 'CITGO - Lemont', strAddress = '135th & New Avenue', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 13426
UNION ALL SELECT intTerminalControlNumberId = 427, strTerminalControlNumber = 'T-36-IL-3318', strName = 'CITGO - Arlington Heights', strAddress = '2304 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13427
UNION ALL SELECT intTerminalControlNumberId = 428, strTerminalControlNumber = 'T-36-IL-3320', strName = 'Magellan Pipeline Company, L.P.', strAddress = '10601 Franklin Avenue', strCity = 'Franklin Park', dtmApprovedDate = NULL, strZip = '60131', intMasterId = 13428
UNION ALL SELECT intTerminalControlNumberId = 429, strTerminalControlNumber = 'T-36-IL-3325', strName = 'Aircraft Service International, Inc.', strAddress = 'Chicago O''Hare Int''l Airport', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60666', intMasterId = 13429
UNION ALL SELECT intTerminalControlNumberId = 430, strTerminalControlNumber = 'T-36-IL-3326', strName = 'United Parcel Service Inc', strAddress = '3300 Airport Dr', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61109', intMasterId = 13430
UNION ALL SELECT intTerminalControlNumberId = 431, strTerminalControlNumber = 'T-36-IL-3375', strName = 'ExxonMobil Oil Corporation', strAddress = '12909 High Road', strCity = 'Lockport', dtmApprovedDate = NULL, strZip = '60441-', intMasterId = 13431
UNION ALL SELECT intTerminalControlNumberId = 432, strTerminalControlNumber = 'T-36-IL-3376', strName = 'Aircraft Service International, Inc.', strAddress = 'Midway Airport', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60638', intMasterId = 13432
UNION ALL SELECT intTerminalControlNumberId = 433, strTerminalControlNumber = 'T-36-IL-3377', strName = 'IMTT-Illinois', strAddress = '24420 W Durkee Road', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 13433
UNION ALL SELECT intTerminalControlNumberId = 434, strTerminalControlNumber = 'T-36-IL-3378', strName = 'Oiltanking Joliet', strAddress = '27100 South Frontage Rd', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 13434
UNION ALL SELECT intTerminalControlNumberId = 435, strTerminalControlNumber = 'T-37-IL-3351', strName = 'BP Products North America Inc', strAddress = '1000 BP Lane', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13435
UNION ALL SELECT intTerminalControlNumberId = 436, strTerminalControlNumber = 'T-37-IL-3353', strName = 'Phillips 66 PL - Hartford', strAddress = '2150 Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13436
UNION ALL SELECT intTerminalControlNumberId = 437, strTerminalControlNumber = 'T-37-IL-3354', strName = 'Hartford Wood River Terminal', strAddress = '900 North Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13437
UNION ALL SELECT intTerminalControlNumberId = 438, strTerminalControlNumber = 'T-37-IL-3356', strName = 'Buckeye Terminals, LLC - Hartford', strAddress = '220 E Hawthorne Street', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-', intMasterId = 13438
UNION ALL SELECT intTerminalControlNumberId = 439, strTerminalControlNumber = 'T-37-IL-3358', strName = 'Marathon Champaign', strAddress = '511 S. Staley Road', strCity = 'Champaign', dtmApprovedDate = NULL, strZip = '61821', intMasterId = 13439
UNION ALL SELECT intTerminalControlNumberId = 440, strTerminalControlNumber = 'T-37-IL-3360', strName = 'Marathon Robinson', strAddress = '12345 E 1050th Ave', strCity = 'Robinson', dtmApprovedDate = NULL, strZip = '62454', intMasterId = 13440
UNION ALL SELECT intTerminalControlNumberId = 441, strTerminalControlNumber = 'T-37-IL-3361', strName = 'HWRT Terminal - Norris City', strAddress = 'Rural Route 2', strCity = 'Norris City', dtmApprovedDate = NULL, strZip = '62869', intMasterId = 13441
UNION ALL SELECT intTerminalControlNumberId = 442, strTerminalControlNumber = 'T-37-IL-3364', strName = 'Growmark, Inc.', strAddress = 'Rt 49 South', strCity = 'Ashkum', dtmApprovedDate = NULL, strZip = '60911', intMasterId = 13442
UNION ALL SELECT intTerminalControlNumberId = 443, strTerminalControlNumber = 'T-37-IL-3365', strName = 'Buckeye Terminals, LLC - Decatur', strAddress = '266 E Shafer Drive', strCity = 'Forsyth', dtmApprovedDate = NULL, strZip = '62535', intMasterId = 13443
UNION ALL SELECT intTerminalControlNumberId = 444, strTerminalControlNumber = 'T-37-IL-3366', strName = 'Phillips 66 PL - E. St.  Louis', strAddress = '3300 Mississippi Ave', strCity = 'Cahokia', dtmApprovedDate = NULL, strZip = '62206', intMasterId = 13444
UNION ALL SELECT intTerminalControlNumberId = 445, strTerminalControlNumber = 'T-37-IL-3368', strName = 'Buckeye Terminals, LLC - Effingham', strAddress = '18264 N US Hwy 45', strCity = 'Effingham', dtmApprovedDate = NULL, strZip = '62401', intMasterId = 13445
UNION ALL SELECT intTerminalControlNumberId = 446, strTerminalControlNumber = 'T-37-IL-3369', strName = 'Buckeye Terminals, LLC - Harristown', strAddress = '600 E. Lincoln Memorial Pky', strCity = 'Harristown', dtmApprovedDate = NULL, strZip = '62537', intMasterId = 13446
UNION ALL SELECT intTerminalControlNumberId = 447, strTerminalControlNumber = 'T-37-IL-3371', strName = 'Magellan Pipeline Company, L.P.', strAddress = '16490 East 100 North Rd.', strCity = 'Heyworth', dtmApprovedDate = NULL, strZip = '61745', intMasterId = 13447
UNION ALL SELECT intTerminalControlNumberId = 448, strTerminalControlNumber = 'T-37-IL-3372', strName = 'Growmark, Inc.', strAddress = '18349 State Hwy 29', strCity = 'Petersburg', dtmApprovedDate = NULL, strZip = '62675', intMasterId = 13448
UNION ALL SELECT intTerminalControlNumberId = 449, strTerminalControlNumber = 'T-43-IL-3729', strName = 'Omega Partners III, LLC', strAddress = '1402 S Delmare', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-0065', intMasterId = 13449
UNION ALL SELECT intTerminalControlNumberId = 450, strTerminalControlNumber = 'T-72-IL-0001', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3400 South Badger Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13450
UNION ALL SELECT intTerminalControlNumberId = 451, strTerminalControlNumber = 'T-72-IL-0002', strName = 'West Shore Pipeline Company - Forest View', strAddress = '5027 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13451
UNION ALL SELECT intTerminalControlNumberId = 452, strTerminalControlNumber = 'T-72-IL-0003', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3223 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13452
UNION ALL SELECT intTerminalControlNumberId = 453, strTerminalControlNumber = 'T-72-IL-0004', strName = 'West Shore Pipeline Company - Rockford', strAddress = '7245 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 13453
UNION ALL SELECT intTerminalControlNumberId = 454, strTerminalControlNumber = 'T-72-IL-0005', strName = 'IMTT - Lemont', strAddress = '13589 Main Street', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 13454

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
SELECT intTerminalControlNumberId = 852, strTerminalControlNumber = 'T-59-MS-0001', strName = 'Scott Petroleum Corporation', strAddress = '942 N. Broadway', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701', intMasterId = 24852
UNION ALL SELECT intTerminalControlNumberId = 853, strTerminalControlNumber = 'T-64-MS-2401', strName = 'Chevron USA, Inc.- Collins', strAddress = 'Old Highway 49 South', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24853
UNION ALL SELECT intTerminalControlNumberId = 854, strTerminalControlNumber = 'T-64-MS-2402', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '31 Kola Road', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24854
UNION ALL SELECT intTerminalControlNumberId = 855, strTerminalControlNumber = 'T-64-MS-2404', strName = 'Motiva Enterprises LLC', strAddress = '49 So. & Kola Rd.', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24855
UNION ALL SELECT intTerminalControlNumberId = 856, strTerminalControlNumber = 'T-64-MS-2405', strName = 'TransMontaigne - Collins', strAddress = 'First Avenue South', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24856
UNION ALL SELECT intTerminalControlNumberId = 857, strTerminalControlNumber = 'T-64-MS-2406', strName = 'Transmontaigne - Greenville- S', strAddress = '310 Walthall Street', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24857
UNION ALL SELECT intTerminalControlNumberId = 858, strTerminalControlNumber = 'T-64-MS-2408', strName = 'TransMontaigne - Greenville - N', strAddress = '208 Short Clay Street', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24858
UNION ALL SELECT intTerminalControlNumberId = 859, strTerminalControlNumber = 'T-64-MS-2411', strName = 'MGC Terminals', strAddress = '101 65th Avenue', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39301-', intMasterId = 24859
UNION ALL SELECT intTerminalControlNumberId = 860, strTerminalControlNumber = 'T-64-MS-2412', strName = 'CITGO - Meridian', strAddress = '180 65th Avenue', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39305-', intMasterId = 24860
UNION ALL SELECT intTerminalControlNumberId = 861, strTerminalControlNumber = 'T-64-MS-2414', strName = 'Murphy Oil USA, Inc. - Meridian', strAddress = '6540 N. Frontage Rd.', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39301-', intMasterId = 24861
UNION ALL SELECT intTerminalControlNumberId = 862, strTerminalControlNumber = 'T-64-MS-2415', strName = 'TransMontaigne - Meridian', strAddress = '1401 65th Ave S', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39307-', intMasterId = 24862
UNION ALL SELECT intTerminalControlNumberId = 863, strTerminalControlNumber = 'T-64-MS-2416', strName = 'Chevron USA, Inc.- Pascagoula', strAddress = 'Industrial Road State Hwy 611', strCity = 'Pascagoula', dtmApprovedDate = NULL, strZip = '39568-1300', intMasterId = 24863
UNION ALL SELECT intTerminalControlNumberId = 864, strTerminalControlNumber = 'T-64-MS-2418', strName = 'Hunt-Southland Refining Co', strAddress = '2 mi N on Hwy 11 PO Drawer A', strCity = 'Sandersville', dtmApprovedDate = NULL, strZip = '39477-', intMasterId = 24864
UNION ALL SELECT intTerminalControlNumberId = 865, strTerminalControlNumber = 'T-64-MS-2419', strName = 'CITGO - Vicksburg', strAddress = '1585 Haining Rd', strCity = 'Vicksburg', dtmApprovedDate = NULL, strZip = '39180-', intMasterId = 24865
UNION ALL SELECT intTerminalControlNumberId = 866, strTerminalControlNumber = 'T-64-MS-2423', strName = 'Lone Star NGL Hattiesburg LLC', strAddress = '1234 Highway 11', strCity = 'Petal', dtmApprovedDate = NULL, strZip = '39465', intMasterId = 24866
UNION ALL SELECT intTerminalControlNumberId = 867, strTerminalControlNumber = 'T-64-MS-2424', strName = 'Hunt Southland Refining Company', strAddress = '2600 Dorsey Street', strCity = 'Vicksburg', dtmApprovedDate = NULL, strZip = '39180', intMasterId = 24867
UNION ALL SELECT intTerminalControlNumberId = 868, strTerminalControlNumber = 'T-64-MS-2425', strName = 'Kior Columbus LLC', strAddress = '600 Industrial Park Acces Rd ', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '39701', intMasterId = 24868
UNION ALL SELECT intTerminalControlNumberId = 869, strTerminalControlNumber = 'T-72-MS-2420', strName = 'Martin Operating Partnership, L.P.', strAddress = '5320 Ingalls Ave.', strCity = 'Pascagoula', dtmApprovedDate = NULL, strZip = '39581', intMasterId = 24869
UNION ALL SELECT intTerminalControlNumberId = 870, strTerminalControlNumber = 'T-72-MS-2421', strName = 'Delta Terminal, Inc.', strAddress = '2181 Harbor Front', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24870
UNION ALL SELECT intTerminalControlNumberId = 871, strTerminalControlNumber = 'T-72-MS-2422', strName = 'ERPC Aberdeen ', strAddress = '20096 Norm Connell Drive', strCity = 'Aberdeen', dtmApprovedDate = NULL, strZip = '39730', intMasterId = 24871

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
-- Insert generated script here. Remove first instance of "UNION ALL "
SELECT intTerminalControlNumberId = 515, strTerminalControlNumber = 'T-39-NE-3604', strName = 'Signature Flight Support Corp.', strAddress = '3636 Wilbur Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27515
UNION ALL SELECT intTerminalControlNumberId = 516, strTerminalControlNumber = 'T-39-NE-3612', strName = 'Magellan Pipeline Company, L.P.', strAddress = '13029 S 13th St', strCity = 'Bellevue', dtmApprovedDate = NULL, strZip = '68123', intMasterId = 27516
UNION ALL SELECT intTerminalControlNumberId = 517, strTerminalControlNumber = 'T-39-NE-3613', strName = 'Truman Arnold Co. - TAC Air', strAddress = '3737 Orville Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27517
UNION ALL SELECT intTerminalControlNumberId = 518, strTerminalControlNumber = 'T-39-NE-3614', strName = 'Union Pacific Railroad Co.', strAddress = '6000 West Front St.', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101', intMasterId = 27518
UNION ALL SELECT intTerminalControlNumberId = 519, strTerminalControlNumber = 'T-39-NE-3615', strName = 'BNSF - Lincoln', strAddress = '201 North 7th Street', strCity = 'Lincoln', dtmApprovedDate = NULL, strZip = '68508', intMasterId = 27519
UNION ALL SELECT intTerminalControlNumberId = 520, strTerminalControlNumber = 'T-47-NE-3600', strName = 'NuStar Pipeline Operating Partnership, L.P. - Columbus', strAddress = 'R R 5, Box 27 BB', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '68601-', intMasterId = 27520
UNION ALL SELECT intTerminalControlNumberId = 521, strTerminalControlNumber = 'T-47-NE-3601', strName = 'NuStar Pipeline Operating Partnership, L.P. - Geneva', strAddress = 'U S Highway 81', strCity = 'Geneva', dtmApprovedDate = NULL, strZip = '68361-', intMasterId = 27521
UNION ALL SELECT intTerminalControlNumberId = 522, strTerminalControlNumber = 'T-47-NE-3602', strName = 'Magellan Pipeline Company, L.P.', strAddress = '12275 South US Hwy 281', strCity = 'Doniphan', dtmApprovedDate = NULL, strZip = '68832-', intMasterId = 27522
UNION ALL SELECT intTerminalControlNumberId = 523, strTerminalControlNumber = 'T-47-NE-3603', strName = 'Phillips 66 PL - Lincoln', strAddress = '1345 Saltillo Rd.', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430', intMasterId = 27523
UNION ALL SELECT intTerminalControlNumberId = 524, strTerminalControlNumber = 'T-47-NE-3605', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2000 Saltillo Road', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430', intMasterId = 27524
UNION ALL SELECT intTerminalControlNumberId = 525, strTerminalControlNumber = 'T-47-NE-3606', strName = 'NuStar Pipeline Operating Partnership, L.P. - Norfolk', strAddress = 'Highway 81', strCity = 'Norfolk', dtmApprovedDate = NULL, strZip = '68701', intMasterId = 27525
UNION ALL SELECT intTerminalControlNumberId = 526, strTerminalControlNumber = 'T-47-NE-3607', strName = 'NuStar Pipeline Operating Partnership, L.P. - North Platte', strAddress = 'Rural Route Four', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101', intMasterId = 27526
UNION ALL SELECT intTerminalControlNumberId = 527, strTerminalControlNumber = 'T-47-NE-3608', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2205 N 11th St', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27527
UNION ALL SELECT intTerminalControlNumberId = 528, strTerminalControlNumber = 'T-47-NE-3610', strName = 'NuStar Pipeline Operating Partnership, L.P. - Osceola', strAddress = 'Rural Route 1', strCity = 'Osceola', dtmApprovedDate = NULL, strZip = '68651', intMasterId = 27528

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NE', @TerminalControlNumbers = @TerminalNE



