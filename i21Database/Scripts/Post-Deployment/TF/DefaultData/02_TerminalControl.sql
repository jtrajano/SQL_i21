--PRINT ('Deploying Terminal Control Number')

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

-- AL Terminals
PRINT ('Deploying AL Terminal Control Number')

DECLARE @TerminalAL AS TFTerminalControlNumbers

INSERT INTO @TerminalAL(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2301', strName = 'Chevron USA, Inc.- Birmingham', strAddress = '2400 28th St Southwest', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211-', intMasterId = 11639
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2302', strName = 'CITGO - Birmingham', strAddress = '2200 25th St Southwest', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211-', intMasterId = 11640
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2304', strName = 'Buckeye Terminals, LLC - Montgomery', strAddress = 'Hwy 31 North', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '36108-', intMasterId = 11641
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2306', strName = 'MPLX Birmingham', strAddress = '2704 28th St Southwest', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211-', intMasterId = 11642
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2307', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '2635 Balsam Avenue', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211-', intMasterId = 11643
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2308', strName = 'Equilon Enterprises LLC', strAddress = '2601 Wilson Road', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35221-1352', intMasterId = 11644
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2309', strName = 'Magellan Terminals Holdings LP', strAddress = '2400 Nabors Road', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211-', intMasterId = 11645
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2312', strName = 'Buckeye Terminals, LLC - Birmingham', strAddress = '1600 Mims Ave SW', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211-', intMasterId = 11646
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2314', strName = 'Barcliff, LLC', strAddress = '145 Cochran Causeway', strCity = 'Mobile', dtmApprovedDate = NULL, strZip = '36601-', intMasterId = 11647
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2316', strName = 'Center Point Terminal Company', strAddress = '200 Viaduct Rd', strCity = 'Chichasaw', dtmApprovedDate = NULL, strZip = '36611', intMasterId = 11648
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2317', strName = 'Alabama Bulk Terminal', strAddress = 'Hwy 90195 Blakely Island', strCity = 'Mobile', dtmApprovedDate = NULL, strZip = '36633', intMasterId = 11649
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2322', strName = 'Magellan Terminals Holdings LP', strAddress = '3560 Well Rd', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '36108-', intMasterId = 11650
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2323', strName = 'South Florida Materials Corp dba Vecenergy', strAddress = '200 Hunter Loop Road', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '31608-', intMasterId = 11651
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2325', strName = 'MPLX Montgomery', strAddress = '320 Hunter Loop Rural Rt 6', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '36125-0395', intMasterId = 11652
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2326', strName = 'Epic Midstream LLC', strAddress = '520 Hunter Loop Road', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '36108-1827', intMasterId = 11653
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2327', strName = 'Murphy Oil USA Inc. - Montgomery', strAddress = '420 Hunter Loop Road', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '36108-', intMasterId = 11654
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2329', strName = 'Hunt Refining Co.', strAddress = '1855 Fairlawn RD', strCity = 'Tuscaloosa', dtmApprovedDate = NULL, strZip = '35401-', intMasterId = 11655
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2330', strName = 'Epic Midstream LLC', strAddress = '872 Second Ave.', strCity = 'Moundville', dtmApprovedDate = NULL, strZip = '35474-', intMasterId = 11656
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2333', strName = 'Murphy Oil USA, Inc. - Oxford', strAddress = '2625 Highway 78 East', strCity = 'Anniston', dtmApprovedDate = NULL, strZip = '36201-', intMasterId = 11657
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2334', strName = 'Shell Chemical LP - Mobil', strAddress = '400 Industrial Parkway', strCity = 'Saraland', dtmApprovedDate = NULL, strZip = '36571-', intMasterId = 11658
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2335', strName = 'Murphy Oil USA, Inc. - Sheffield', strAddress = '136 Blackwell Road', strCity = 'Sheffield', dtmApprovedDate = NULL, strZip = '35660-', intMasterId = 11659
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2336', strName = 'Barcliff, LLC', strAddress = '101 Bay Bridge Rd', strCity = 'Mobile', dtmApprovedDate = NULL, strZip = '36610-', intMasterId = 11660
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2338', strName = 'Plantation - Montgomery Transmix Tank', strAddress = '201 Hunter Loop Rd', strCity = 'Montgomery', dtmApprovedDate = NULL, strZip = '36108', intMasterId = 11661
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2339', strName = 'Center Point Terminal - Mobile', strAddress = '1257 Cochrane Causeway', strCity = 'Mobile', dtmApprovedDate = NULL, strZip = '36601', intMasterId = 11662
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T63AL2340', strName = 'Circle K Terminal Alabama', strAddress = '2529 28th Street SW', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211', intMasterId = 11663
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72AL2339', strName = 'Martin Energy Services', strAddress = 'Hwy 90/98 Blakeley Island', strCity = 'Mobile', dtmApprovedDate = NULL, strZip = '36618', intMasterId = 11664
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72AL2343', strName = 'Allied Energy Corporation', strAddress = '2700 Ishkooda Wenonah Rd.', strCity = 'Birmingham', dtmApprovedDate = NULL, strZip = '35211', intMasterId = 11665
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72AL2344', strName = 'Goodway Refining, LLC', strAddress = '4745 Ross Road', strCity = 'Atmore', dtmApprovedDate = NULL, strZip = '36502', intMasterId = 11666
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72AL2345', strName = 'Martin Operating Partnership, L.P.', strAddress = '7778 Dauphin Island Pkwy.', strCity = 'Theodore', dtmApprovedDate = NULL, strZip = '36582', intMasterId = 11667
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76AL0001', strName = 'ERPC Boligee', strAddress = '2081 County Rd 89', strCity = 'Boligee', dtmApprovedDate = NULL, strZip = '35443', intMasterId = 11668

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'AL' , @TerminalControlNumbers = @TerminalAL

DELETE @TerminalAL

-- AK Terminals
PRINT ('Deploying AK Terminal Control Number')
DECLARE @TerminalAK AS TFTerminalControlNumbers

INSERT INTO @TerminalAK(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4506', strName = 'Petro Star Inc - Kodiak Oil Sales', strAddress = '715 Shelikof', strCity = 'Kodiak', dtmApprovedDate = NULL, strZip = '99615', intMasterId = 21584
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4507', strName = 'Petro Star Inc - Valdez Petroleum Term', strAddress = '402 West Egan', strCity = 'Valdez', dtmApprovedDate = NULL, strZip = '99686', intMasterId = 21585
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4508', strName = 'Petro Star Inc - Captains Bay', strAddress = '2158 Captain''s Bay Rd.', strCity = 'Unalaska', dtmApprovedDate = NULL, strZip = '99685', intMasterId = 21586
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4509', strName = 'Petro Star Inc - Westward', strAddress = '1200 Captain''s Bay Rd.', strCity = 'Unalaska', dtmApprovedDate = NULL, strZip = '99685', intMasterId = 21587
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4510', strName = 'Petro Star Inc - Ballyhoo', strAddress = '647 Ballyhoo Rd.', strCity = 'Unalaska', dtmApprovedDate = NULL, strZip = '99685', intMasterId = 21588
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4511', strName = 'Petro Star Inc - Resoff', strAddress = '1787 Ballyhoo Rd.', strCity = 'Unalaska', dtmApprovedDate = NULL, strZip = '99685', intMasterId = 21589
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4512', strName = 'Petro 49', strAddress = '300 Front St.', strCity = 'Craig', dtmApprovedDate = NULL, strZip = '99921', intMasterId = 21590
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4513', strName = 'Delta Western - Haines', strAddress = 'Mile 0 Haines', strCity = 'Haines', dtmApprovedDate = NULL, strZip = '99827', intMasterId = 21591
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4514', strName = 'Petro 49', strAddress = '4755 Homer Spit Rd.', strCity = 'Homer', dtmApprovedDate = NULL, strZip = '99603', intMasterId = 21592
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4515', strName = 'Petro 49', strAddress = '3560 N. Douglas Hwy.', strCity = 'Juneau', dtmApprovedDate = NULL, strZip = '99802', intMasterId = 21593
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4516', strName = 'Petro 49', strAddress = '1100 Steadman St.', strCity = 'Ketchikan', dtmApprovedDate = NULL, strZip = '99901', intMasterId = 21594
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4517', strName = 'Petro 49', strAddress = '104 Marine Way', strCity = 'Kodiak', dtmApprovedDate = NULL, strZip = '99615', intMasterId = 21595
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4518', strName = 'Petro 49', strAddress = '901 S. Nordick St.', strCity = 'Petersburg', dtmApprovedDate = NULL, strZip = '99833', intMasterId = 21596
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4519', strName = 'Petro 49', strAddress = '#1 Lincoln St.', strCity = 'Sitka', dtmApprovedDate = NULL, strZip = '99835', intMasterId = 21597
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4521', strName = 'Nikiski Fuel, Inc.', strAddress = '53200 Nikiski Beach Rd.', strCity = 'Nikiski', dtmApprovedDate = NULL, strZip = '99735', intMasterId = 21598
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4522', strName = 'Aleutian Fuel Services', strAddress = 'Captain Bay', strCity = 'Unalaska', dtmApprovedDate = NULL, strZip = '99692', intMasterId = 21599
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4523', strName = 'ORCA Oil--Division of Shoreside Petroleum, Inc.', strAddress = '100 Ocean Dock Rd.', strCity = 'Cordova', dtmApprovedDate = NULL, strZip = '99574', intMasterId = 21600
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4524', strName = 'Delta Western, Inc. - Site 2', strAddress = '120 Mt. Roberts St.', strCity = 'Juneau', dtmApprovedDate = NULL, strZip = '99801', intMasterId = 21601
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4525', strName = 'Delta Western, Inc. - Haines', strAddress = '900 Main St.', strCity = 'Haines', dtmApprovedDate = NULL, strZip = '99827', intMasterId = 21602
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4526', strName = 'Delta Western, Inc. - Site 3', strAddress = '309 Main St.', strCity = 'Dillingham', dtmApprovedDate = NULL, strZip = '99576', intMasterId = 21603
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4527', strName = 'Delta Western, Inc. - Site 4', strAddress = 'Mile 0 Peninsula Way', strCity = 'Naknek', dtmApprovedDate = NULL, strZip = '99633', intMasterId = 21604
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4528', strName = 'Delta Western, Inc. - Dutch Harbor', strAddress = '1577 E. Point Loop Rd.', strCity = 'Dutch Harbor', dtmApprovedDate = NULL, strZip = '99692', intMasterId = 21605
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4530', strName = 'Delta Western, Inc. - Site 5', strAddress = 'Airport Drive', strCity = 'Yakutat', dtmApprovedDate = NULL, strZip = '99689', intMasterId = 21606
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4531', strName = 'Bonanza Fuel, Inc.', strAddress = 'Port of Nome', strCity = 'Nome', dtmApprovedDate = NULL, strZip = '99762', intMasterId = 21607
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4532', strName = 'St. Paul Fuel Co.', strAddress = 'UNKNOWN', strCity = 'St. Paul Island', dtmApprovedDate = NULL, strZip = '99660', intMasterId = 21608
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4533', strName = 'St. George Delta Fuel Co.', strAddress = 'Water Front Building', strCity = 'St. George Island', dtmApprovedDate = NULL, strZip = '99591', intMasterId = 21609
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4534', strName = 'Crowley Fuels LLC', strAddress = 'Airport Rd.', strCity = 'St. Marys', dtmApprovedDate = NULL, strZip = '99658', intMasterId = 21610
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4535', strName = 'Crowley Fuels LLC', strAddress = 'Village Rd.', strCity = 'Hooper Bay', dtmApprovedDate = NULL, strZip = '99604', intMasterId = 21611
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4538', strName = 'Crowley Fuels LLC', strAddress = '7th Avenue & H Street', strCity = 'Galena', dtmApprovedDate = NULL, strZip = '99741', intMasterId = 21612
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4540', strName = 'Crowley Fuels LLC', strAddress = 'William Loola St.', strCity = 'Ft. Yukon', dtmApprovedDate = NULL, strZip = '99740', intMasterId = 21613
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4541', strName = 'Adak Terminal', strAddress = 'Adak', strCity = 'Adak', dtmApprovedDate = NULL, strZip = '99546', intMasterId = 21614
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4542', strName = 'Crowley Fuels LLC', strAddress = '900 Stedman St.', strCity = 'Ketchikan', dtmApprovedDate = NULL, strZip = '99901-0858', intMasterId = 21615
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4543', strName = 'NA Holdings', strAddress = 'Melspelt St.', strCity = 'McGrath', dtmApprovedDate = NULL, strZip = '99627', intMasterId = 21616
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4544', strName = 'Crowley Fuels LLC', strAddress = 'River Rd.', strCity = 'Aniak', dtmApprovedDate = NULL, strZip = '99557', intMasterId = 21617
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4545', strName = 'Seldovia Fuel & Lube, Inc.', strAddress = '319 Main St.', strCity = 'Seldovia', dtmApprovedDate = NULL, strZip = '99663', intMasterId = 21618
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4546', strName = 'Crowley Fuels LLC', strAddress = '940 Third St.', strCity = 'Kotzebue', dtmApprovedDate = NULL, strZip = '99752', intMasterId = 21619
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4547', strName = 'Crowley Fuels LLC', strAddress = '316 W. First St.', strCity = 'Nome', dtmApprovedDate = NULL, strZip = '99762', intMasterId = 21620
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4574', strName = 'Petro 49', strAddress = '#10 Beach Rd.', strCity = 'Skagway', dtmApprovedDate = NULL, strZip = '99840', intMasterId = 21621
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4575', strName = 'Crowley Fuels LLC', strAddress = '1076 Jacobson Dr.', strCity = 'Juneau', dtmApprovedDate = NULL, strZip = '99801', intMasterId = 21622
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4576', strName = 'Red Dog Operations', strAddress = 'North of Kotzebue', strCity = 'UNKNOWN', dtmApprovedDate = NULL, strZip = '99752', intMasterId = 21623
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4578', strName = 'Frosty Fuels LLC', strAddress = 'Cold Bay', strCity = 'Anchorage', dtmApprovedDate = NULL, strZip = '99501', intMasterId = 21624
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4579', strName = 'Crowley Fuels LLC', strAddress = '1120 Standard Oil Road', strCity = 'Bethel', dtmApprovedDate = NULL, strZip = '99559', intMasterId = 21625
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4580', strName = 'Petro Star Inc. - North Pole Refinery', strAddress = '1200 H & H Lane', strCity = 'North Pole', dtmApprovedDate = NULL, strZip = '99705', intMasterId = 21626
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4581', strName = 'Petro Star Inc. - Valdez Refinery', strAddress = 'Mile 2.5 Dayville Rd.', strCity = 'Valdez', dtmApprovedDate = NULL, strZip = '99686', intMasterId = 21627
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4583', strName = 'Petro 49', strAddress = '1427 Peninsula St.', strCity = 'Wrangell', dtmApprovedDate = NULL, strZip = '99929', intMasterId = 21628
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4500', strName = 'Crowley Fuels LLC', strAddress = '459 W Bluff Rd', strCity = 'Anchorage', dtmApprovedDate = NULL, strZip = '99501', intMasterId = 21629
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4501', strName = 'Tesoro Logistics Operations LLC', strAddress = '1076 Ocean Dock Road', strCity = 'Anchorage', dtmApprovedDate = NULL, strZip = '99501-', intMasterId = 21630
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4503', strName = 'Flint Hills Resources Alaska- North Pole', strAddress = '1150 H & H Lane', strCity = 'North Pole', dtmApprovedDate = NULL, strZip = '99705-', intMasterId = 21631
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4504', strName = 'Tesoro Logistics Operations LLC', strAddress = '1522 Port Rd.', strCity = 'Anchorage', dtmApprovedDate = NULL, strZip = '99501-', intMasterId = 21632
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4505', strName = 'Tesoro Logistics Operations LLC', strAddress = '48775 Kenai Spur Hwy', strCity = 'Kenai', dtmApprovedDate = NULL, strZip = '99611-', intMasterId = 21633
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4577', strName = 'Bristol Alliance Fuels LLC', strAddress = '106 North Pacific Ct.', strCity = 'Dillingham', dtmApprovedDate = NULL, strZip = '99576', intMasterId = 21634
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4578', strName = 'ConocoPhillips Alaska Inc.', strAddress = 'Lat 70.3238 Lon -149.6051', strCity = 'Kuparuk', dtmApprovedDate = NULL, strZip = '99519', intMasterId = 21635
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4579', strName = 'Spruce Island Fuel', strAddress = 'PO Box 89', strCity = 'Ouzinkie', dtmApprovedDate = NULL, strZip = '99644', intMasterId = 21636
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4580', strName = 'Delta Western, Inc. - Sitka', strAddress = '5311 Hailibut Point Road', strCity = 'Sitka', dtmApprovedDate = NULL, strZip = '99835', intMasterId = 21637
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4581', strName = 'Shoreside Petroleum Inc', strAddress = '700 Port Avenue', strCity = 'Seward', dtmApprovedDate = NULL, strZip = '99664', intMasterId = 21638
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4536', strName = 'Iliamna Development Corporation', strAddress = '101 Airport Road', strCity = 'Iliamna', dtmApprovedDate = NULL, strZip = '99606', intMasterId = 21639
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T92AK4502', strName = 'Tesoro Logistics Operations LLC', strAddress = '1601 Tidewater Rd', strCity = 'Anchorage', dtmApprovedDate = NULL, strZip = '99501', intMasterId = 21640
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91AK4520', strName = 'Aircraft Service International, Inc.', strAddress = '6000 Dehaviland Ave.', strCity = 'Anchorage', dtmApprovedDate = NULL, strZip = '99502', intMasterId = 21641


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'AK' , @TerminalControlNumbers = @TerminalAK

DELETE @TerminalAK

-- AR Terminals
PRINT ('Deploying AR Terminal Control Number')
DECLARE @TerminalAR AS TFTerminalControlNumbers

INSERT INTO @TerminalAR(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2451', strName = 'Delek Logistics Operating', strAddress = '1000 McHenry', strCity = 'El Dorado', dtmApprovedDate = NULL, strZip = '71730-', intMasterId = 41670
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2453', strName = 'Magellan Pipeline Company, L.P.', strAddress = '8101 Hwy 71', strCity = 'Fort Smith', dtmApprovedDate = NULL, strZip = '72908-', intMasterId = 41671
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2456', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2725 Central Airport Rd.', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72117-', intMasterId = 41672
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2457', strName = 'Delek Logistics Operating', strAddress = '2724 Central Airport Rd', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72117-', intMasterId = 41673
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2458', strName = 'HWRT Terminal - N. Little Rock', strAddress = '2626 Central Airport Road', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72117-', intMasterId = 41674
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2459', strName = 'Magellan Pipeline Company, L.P.', strAddress = '3222 Central Airport Rd.', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72117-', intMasterId = 41675
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2460', strName = 'Martin Operating Partnership, L.P.', strAddress = '484 E. 6th Street', strCity = 'Smackover', dtmApprovedDate = NULL, strZip = '71762-', intMasterId = 41676
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2462', strName = 'Murphy Oil USA, Inc. - Bono', strAddress = '15211 US 63 North', strCity = 'Bono', dtmApprovedDate = NULL, strZip = '72416', intMasterId = 41677
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2463', strName = 'Valero Partners Operating Co LLC', strAddress = 'South 8th Street', strCity = 'West Memphis', dtmApprovedDate = NULL, strZip = '72303-', intMasterId = 41678
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2464', strName = 'JP Energy ATT LLC', strAddress = '2207 Central Airport Rd', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72117', intMasterId = 41679
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2465', strName = 'Center Point Terminal - N Little Rock', strAddress = '3206 Gribble Street', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72114', intMasterId = 41680
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2467', strName = 'TransMontaigne - Razorback', strAddress = '2801 West Hudson (Hwy 102)', strCity = 'Rogers', dtmApprovedDate = NULL, strZip = '72756-', intMasterId = 41681
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2469', strName = 'Bruce Oakley North Little Rock Terminal', strAddress = '300 River Park Rd', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72114', intMasterId = 41683
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2470', strName = 'NGL Supply Terminal company LLC - West Memphis', strAddress = '1241 South 8th Street', strCity = 'West Memphis', dtmApprovedDate = NULL, strZip = '72303', intMasterId = 41684
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73AR2450', strName = 'Union Pacific Railroad Co.', strAddress = '11th & Pike Ave.', strCity = 'North Little Rock', dtmApprovedDate = NULL, strZip = '72114', intMasterId = 41685
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73AR2455', strName = 'Union Pacific Railroad Co.', strAddress = '1400 East 2nd Ave.', strCity = 'Pine Bluff', dtmApprovedDate = NULL, strZip = '71601', intMasterId = 41686
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T71AR2471', strName = 'Petroleum Fuel & Terminal - Pine Bluff', strAddress = '4303 Emmett Sanders Road', strCity = 'Pine Bluff', dtmApprovedDate = NULL, strZip = '71601', intMasterId = 41687


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'AR' , @TerminalControlNumbers = @TerminalAR

DELETE @TerminalAR

-- AZ Terminals
PRINT ('Deploying AZ Terminal Control Number')
DECLARE @TerminalAZ AS TFTerminalControlNumbers

INSERT INTO @TerminalAZ(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4300', strName = 'Caljet of America, LLC', strAddress = '125 North 53rd Ave', strCity = 'Phoenix', dtmApprovedDate = NULL, strZip = '85043-', intMasterId = 31687
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4302', strName = 'Arizona Fueling Facilities Corporation', strAddress = '4200 East Airlane Dr.', strCity = 'Phoenix', dtmApprovedDate = NULL, strZip = '85034', intMasterId = 31688
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4303', strName = 'Pro Petroleum, Inc. - Phoenix', strAddress = '408 S 43rd Avenue', strCity = 'Phoenix', dtmApprovedDate = NULL, strZip = '85043', intMasterId = 31689
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4304', strName = 'SFPP, LP Phoenix Terminal', strAddress = '49 North 53rd Avenue', strCity = 'Phoenix', dtmApprovedDate = NULL, strZip = '85043-', intMasterId = 31690
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4310', strName = 'SFPP, LP', strAddress = '3841 East Refinery Way', strCity = 'Tucson', dtmApprovedDate = NULL, strZip = '85713-', intMasterId = 31692
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4313', strName = 'Circle K Terminal', strAddress = '5333 W Van Buren St', strCity = 'Phoenix', dtmApprovedDate = NULL, strZip = '85043-', intMasterId = 31693
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4318', strName = 'Pro Petroleum, Inc - El Mirage', strAddress = '12126 W Olive Avenue', strCity = 'El Mirage', dtmApprovedDate = NULL, strZip = '85333', intMasterId = 31695
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86AZ4319', strName = 'Lupton Petroleum Products', strAddress = 'I-40 Exit 359 Grant Rd', strCity = 'Lupton', dtmApprovedDate = NULL, strZip = '86508', intMasterId = 31696


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'AZ' , @TerminalControlNumbers = @TerminalAZ

DELETE @TerminalAZ

-- CA Terminals
PRINT ('Deploying CA Terminal Control Number')
DECLARE @TerminalCA AS TFTerminalControlNumbers

INSERT INTO @TerminalCA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4744', strName = 'Rancho LPG Holdings', strAddress = '2110 North Gaffey Street', strCity = 'San Pedro', dtmApprovedDate = NULL, strZip = '90731', intMasterId = 51697
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4745', strName = 'Vopak Terminal Los Angeles, Inc.', strAddress = '401 Canal Street', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '90744', intMasterId = 51698
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4746', strName = 'Shell Oil Products US', strAddress = '20945 South Wilmington Ave', strCity = 'Carson', dtmApprovedDate = NULL, strZip = '90810', intMasterId = 51699
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4747', strName = 'Buckeye Aviation (San Diego)', strAddress = '961 E. Harbor Dr.', strCity = 'San Diego', dtmApprovedDate = NULL, strZip = '92101', intMasterId = 51700
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4748', strName = 'BNSF - Commerce', strAddress = '6300 E Sheila St', strCity = 'Commerce', dtmApprovedDate = NULL, strZip = '90040', intMasterId = 51701
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4749', strName = 'BNSF - Barstow', strAddress = '200 North Avenue H', strCity = 'Barstow', dtmApprovedDate = NULL, strZip = '92311', intMasterId = 51702
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4750', strName = 'Torrance Logistics Company', strAddress = '1477 Jefferson', strCity = 'Anaheim', dtmApprovedDate = NULL, strZip = '92807', intMasterId = 51703
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4751', strName = 'Kinder Morgan Tank Storage Terminal LLC', strAddress = '2000 East Sepulveda Blvd.', strCity = 'Carson', dtmApprovedDate = NULL, strZip = '90810-1995', intMasterId = 51704
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4753', strName = 'Tesoro Logistics Operations LLC', strAddress = '2395 S Riverside Avenue', strCity = 'Bloomington', dtmApprovedDate = NULL, strZip = '92316-2931', intMasterId = 51705
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4757', strName = 'SFPP, LP', strAddress = '2359 S. Riverside Avenue', strCity = 'Bloomington', dtmApprovedDate = NULL, strZip = '92316-', intMasterId = 51706
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4758', strName = 'Shell Oil Products US', strAddress = '2307 S. Riverside Ave.', strCity = 'Colton', dtmApprovedDate = NULL, strZip = '92316-', intMasterId = 51707
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4760', strName = 'Phillips 66 PL - Colton', strAddress = '271 E Slover Avenue', strCity = 'Rialto', dtmApprovedDate = NULL, strZip = '92376-', intMasterId = 51708
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4761', strName = 'Calnev Pipe Line, LLC', strAddress = '34277 Yermo Daggett Rd', strCity = 'Daggett', dtmApprovedDate = NULL, strZip = '92327-', intMasterId = 51709
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4763', strName = 'SFPP, LP', strAddress = '345 W Aten Road', strCity = 'Imperial', dtmApprovedDate = NULL, strZip = '92251-', intMasterId = 51710
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4764', strName = 'Tesoro Logistics Operations LLC', strAddress = '5905 Paramount Blvd.', strCity = 'Long Beach', dtmApprovedDate = NULL, strZip = '90805-', intMasterId = 51711
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4767', strName = 'Petro-Diamond Terminal Company', strAddress = '1920 Lugger Way', strCity = 'Long Beach', dtmApprovedDate = NULL, strZip = '90813-2634', intMasterId = 51712
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4768', strName = 'Tesoro Logistics Operations LLC', strAddress = '1926 E. Pacific Coast Hwy', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '90744-', intMasterId = 51713
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4769', strName = 'Tesoro Logistics Operations LLC', strAddress = '2149 E. Sepulreda Blvd.', strCity = 'Carson', dtmApprovedDate = NULL, strZip = '90749-', intMasterId = 51714
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4771', strName = 'Chevron USA, Inc.- Huntington Beach', strAddress = '17881 Gothard St.', strCity = 'Huntington Beach', dtmApprovedDate = NULL, strZip = '92647-', intMasterId = 51715
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4772', strName = 'SFPP, LP', strAddress = '1350 North Main Street', strCity = 'Orange', dtmApprovedDate = NULL, strZip = '92667-', intMasterId = 51716
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4773', strName = 'Chevron USA, Inc.- San Diego', strAddress = '2351 E. Harbor Drive', strCity = 'San Diego', dtmApprovedDate = NULL, strZip = '92113-', intMasterId = 51717
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4776', strName = 'SFPP, LP', strAddress = '9950 San Diego Mission Road', strCity = 'San Diego', dtmApprovedDate = NULL, strZip = '92108-', intMasterId = 51718
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4779', strName = 'Chemoil Terminals Corporation', strAddress = '2365 E. Sepulveda Blvd.', strCity = 'Long Beach', dtmApprovedDate = NULL, strZip = '90810-', intMasterId = 51719
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4782', strName = 'Tesoro Logistics Operations LLC', strAddress = '2295 E. Harbor Drive', strCity = 'San Diego', dtmApprovedDate = NULL, strZip = '92113-', intMasterId = 51720
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4784', strName = 'Tesoro Logistics Operations LLC', strAddress = '2350 Hathaway Drive', strCity = 'Signal Hill', dtmApprovedDate = NULL, strZip = '90806-', intMasterId = 51721
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4785', strName = 'Shell Oil Products US', strAddress = '2457 Redondo Ave.', strCity = 'Signal Hill', dtmApprovedDate = NULL, strZip = '90806-', intMasterId = 51722
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4787', strName = 'Shore Terminals LLC - Wilmington', strAddress = '841 La Paloma', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '90744', intMasterId = 51723
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4788', strName = 'Allied Aviation Fueling Co., Inc.', strAddress = '3698 C Pacific Highway', strCity = 'San Diego', dtmApprovedDate = NULL, strZip = '92138', intMasterId = 51724
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4789', strName = 'Ultramar, Inc. - Wilmington', strAddress = '2402 E Anaheim St', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '90744-', intMasterId = 51725
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4791', strName = 'The Jankovich Company', strAddress = 'Berth 74 (Land)', strCity = 'San Pedro', dtmApprovedDate = NULL, strZip = '90733-', intMasterId = 51726
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4794', strName = 'Union Pacific Railroad Co.', strAddress = '19700 Slover Ave. PL25000', strCity = 'Colton', dtmApprovedDate = NULL, strZip = '92316', intMasterId = 51727
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4795', strName = 'Union Pacific Railroad Co.', strAddress = '#1 Union Pacific Blvd.', strCity = 'Yermo', dtmApprovedDate = NULL, strZip = '92398', intMasterId = 51728
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4796', strName = 'The Jankovich Company', strAddress = '961 East Harbor Dr.', strCity = 'San Diego', dtmApprovedDate = NULL, strZip = '92101', intMasterId = 51729
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4800', strName = 'Vopak Terminal Long Beach', strAddress = '3601 Dock Street', strCity = 'San Pedro', dtmApprovedDate = NULL, strZip = '90731', intMasterId = 51730
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4600', strName = 'SFPP, LP - Kinder Morgan', strAddress = '2570 Hegan Lane', strCity = 'Chico', dtmApprovedDate = NULL, strZip = '95927-', intMasterId = 51731
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4603', strName = 'Valero Refining Company - Benicia', strAddress = '3410 East Second Street', strCity = 'Benicia', dtmApprovedDate = NULL, strZip = '94510-', intMasterId = 51732
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4604', strName = 'Chevron USA, Inc.- Banta', strAddress = '22888 S. Kasson Rd.', strCity = 'Tracy', dtmApprovedDate = NULL, strZip = '95376-', intMasterId = 51733
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4605', strName = 'Shore Terminals LLC - Crockett', strAddress = '90 San Pablo Ave', strCity = 'Crockett', dtmApprovedDate = NULL, strZip = '94525-', intMasterId = 51734
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4606', strName = 'Chevron USA, Inc.- Eureka', strAddress = '3400 Christie Street', strCity = 'Eureka', dtmApprovedDate = NULL, strZip = '95501-', intMasterId = 51735
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4607', strName = 'Chevron USA, Inc. - Avon', strAddress = '611 Solano Way', strCity = 'Martinez', dtmApprovedDate = NULL, strZip = '94553-', intMasterId = 51736
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4609', strName = 'Buckeye Terminals, LLC - Stockton', strAddress = '27 West Washington St', strCity = 'Stockton', dtmApprovedDate = NULL, strZip = '95203-', intMasterId = 51737
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4610', strName = 'Shell Oil Products US - Martinez', strAddress = '1801 Marina Vista', strCity = 'Martinez', dtmApprovedDate = NULL, strZip = '94553-', intMasterId = 51738
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4611', strName = 'Tesoro Logistics Operations LLC', strAddress = '150 Solano Way', strCity = 'Martinez', dtmApprovedDate = NULL, strZip = '94553-', intMasterId = 51739
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4612', strName = 'Buckeye Terminals, LLC - Sacramento', strAddress = '1601 S. River Rd', strCity = 'West Sacramento', dtmApprovedDate = NULL, strZip = '95691-', intMasterId = 51740
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4613', strName = 'SFPP, LP', strAddress = '2901 Bradshaw Rd', strCity = 'Rancho Cordova', dtmApprovedDate = NULL, strZip = '95741-', intMasterId = 51741
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4614', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '1306 Canal Blvd', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '94807-', intMasterId = 51742
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4616', strName = 'Chevron USA, Inc.- Richmond', strAddress = '155 Castro St', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '94802-', intMasterId = 51743
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4617', strName = 'Phillips 66 PL - Richmond', strAddress = '1300 Canal Blvd', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '94804-', intMasterId = 51744
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4619', strName = 'IMTT Richmond, CA', strAddress = '100 Cutting Blvd.', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '94804-', intMasterId = 51745
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4621', strName = 'Chevron USA, Inc.- Sacramento', strAddress = '2420 Front Street', strCity = 'Sacramento', dtmApprovedDate = NULL, strZip = '95818-', intMasterId = 51746
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4622', strName = 'Shell Oil Products US - W Sacramento', strAddress = '1509 South River Road', strCity = 'West Sacramento', dtmApprovedDate = NULL, strZip = '95691-', intMasterId = 51747
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4624', strName = 'Phillips 66 PL - Sacramento', strAddress = '76 Broadway', strCity = 'Sacramento', dtmApprovedDate = NULL, strZip = '95818-', intMasterId = 51748
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4626', strName = 'NuStar Terminals Operations Partnership L. P. - Stockton', strAddress = '2941 Navy Drive', strCity = 'Stockton', dtmApprovedDate = NULL, strZip = '95206-1149', intMasterId = 51749
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4628', strName = 'Shell Oil Products US - Stockton', strAddress = '3515 Navy Dirve', strCity = 'Stockton', dtmApprovedDate = NULL, strZip = '95203-', intMasterId = 51750
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4629', strName = 'Tesoro Logistics Operations LLC', strAddress = '3003 Navy Drive', strCity = 'Stockton', dtmApprovedDate = NULL, strZip = '95205-', intMasterId = 51751
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T68CA4632', strName = 'Allied Aviation Fueling Co., Inc.', strAddress = '7330 Earhart Drive', strCity = 'Sacramento', dtmApprovedDate = NULL, strZip = '95837', intMasterId = 51752
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4650', strName = 'Chevron USA, Inc.- San Jose', strAddress = '1020 Berryessa Road', strCity = 'San Jose', dtmApprovedDate = NULL, strZip = '95133-', intMasterId = 51753
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4651', strName = 'SFPP, LP', strAddress = '4149 South Maple Avenue', strCity = 'Fresno', dtmApprovedDate = NULL, strZip = '93725-', intMasterId = 51754
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4652', strName = 'SFPP, LP', strAddress = '2150 Kruse Avenue', strCity = 'San Jose', dtmApprovedDate = NULL, strZip = '95131-', intMasterId = 51755
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4653', strName = 'Shell Oil Products US', strAddress = '2165 O''Toole Ave.', strCity = 'San Jose', dtmApprovedDate = NULL, strZip = '95131-', intMasterId = 51756
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4655', strName = 'Kern Oil & Refining Co.', strAddress = '7724 East Panama Lane', strCity = 'Bakersfield', dtmApprovedDate = NULL, strZip = '93307-', intMasterId = 51757
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4664', strName = 'San Joaquin Refining Co., Inc.', strAddress = '3542 Shell St.', strCity = 'Bakersfield', dtmApprovedDate = NULL, strZip = '93308-', intMasterId = 51759
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4665', strName = 'Seaport Refining & Environmental LLC', strAddress = '675 Seaport Blvd, 2nd Floor', strCity = 'Redwood City', dtmApprovedDate = NULL, strZip = '94063', intMasterId = 51760
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T77CA4666', strName = 'Swissport Fueling, Inc.', strAddress = '2500 Seaboard Ave', strCity = 'San Jose', dtmApprovedDate = NULL, strZip = '95131', intMasterId = 51761
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4700', strName = 'SFPP, LP', strAddress = '950 Tunnel Av.', strCity = 'Brisbane', dtmApprovedDate = NULL, strZip = '94005-', intMasterId = 51762
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4702', strName = 'Swissport Fueling, Inc.', strAddress = 'Oakland International Airport', strCity = 'Oakland', dtmApprovedDate = NULL, strZip = '94603-6366', intMasterId = 51763
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4705', strName = 'Plains Products Terminals LLC', strAddress = '488 Wright Ave.', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '94802-', intMasterId = 51764
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4706', strName = 'Union Pacific Railroad Co.', strAddress = '1717 Middle Harbor Rd.', strCity = 'Oakland', dtmApprovedDate = NULL, strZip = '94607', intMasterId = 51765
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4707', strName = 'Union Pacific Railroad Co.', strAddress = '9499 Atkinson St.', strCity = 'Roseville', dtmApprovedDate = NULL, strZip = '95678', intMasterId = 51766
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4708', strName = 'BNSF - Richmond', strAddress = '980 Hensley Street Bldg 417', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '94801', intMasterId = 51767
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4800', strName = 'Chevron USA, Inc.- El Segundo', strAddress = '324 West El Segundo Blvd', strCity = 'El Segundo', dtmApprovedDate = NULL, strZip = '90245-', intMasterId = 51768
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4803', strName = 'Phillips 66 PL - LA Terminal', strAddress = '13500 South Broadway', strCity = 'Los Angeles', dtmApprovedDate = NULL, strZip = '90061-', intMasterId = 51769
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4804', strName = 'Shell Oil Products US', strAddress = '8100 Haskell Ave.', strCity = 'Van Nuys', dtmApprovedDate = NULL, strZip = '91406-', intMasterId = 51770
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4805', strName = 'Torrance Logistics Company', strAddress = '2709 East 37th Street', strCity = 'Vernon', dtmApprovedDate = NULL, strZip = '90058-', intMasterId = 51771
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4807', strName = 'Tesoro Logistics Operations LLC', strAddress = '8601 S. Garfield Ave.', strCity = 'South Gate', dtmApprovedDate = NULL, strZip = '90280-', intMasterId = 51772
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4808', strName = 'Paramount Petroleum Corp.', strAddress = '8835 Sommerset Blvd.', strCity = 'Paramount', dtmApprovedDate = NULL, strZip = '90723', intMasterId = 51773
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4810', strName = 'Chevron USA, Inc.- Van Nuys', strAddress = '15359 Oxnard Street', strCity = 'Van Nuys', dtmApprovedDate = NULL, strZip = '91411-', intMasterId = 51774
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4811', strName = 'Chevron USA, Inc.- Montebella', strAddress = '601 South Vail Avenue', strCity = 'Montebella', dtmApprovedDate = NULL, strZip = '90640-', intMasterId = 51775
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T95CA4812', strName = 'Aircraft Service International, Inc.', strAddress = '9900 LAXFuel Rd.', strCity = 'Los Angeles', dtmApprovedDate = NULL, strZip = '90045', intMasterId = 51776
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4801', strName = 'Aircraft Service International, Inc.', strAddress = '390 Paulario Ave', strCity = 'Costa Mesa', dtmApprovedDate = NULL, strZip = '92626', intMasterId = 51777
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33CA4792', strName = 'Aircraft Service International, Inc.', strAddress = 'Airport Drive', strCity = 'Ontario', dtmApprovedDate = NULL, strZip = '91761', intMasterId = 51778
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T94CA4701', strName = 'Aircraft Service International, Inc.', strAddress = 'New Access Rd.', strCity = 'San Francisco', dtmApprovedDate = NULL, strZip = '94128', intMasterId = 51779


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'CA' , @TerminalControlNumbers = @TerminalCA

DELETE @TerminalCA

-- CO Terminals
PRINT ('Deploying CO Terminal Control Number')
DECLARE @TerminalCO AS TFTerminalControlNumbers

INSERT INTO @TerminalCO(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4100', strName = 'Magellan Pipeline Company, L.P.', strAddress = '15000 E. Smith Rd.', strCity = 'Aurora', dtmApprovedDate = NULL, strZip = '80011-', intMasterId = 61776
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4101', strName = 'Suncor Energy USA', strAddress = '5800 Brighton Boulevard', strCity = 'Commerce City', dtmApprovedDate = NULL, strZip = '80022-', intMasterId = 61777
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4102', strName = 'Suncor Energy USA - Denver', strAddress = '5575 Brighton Boulevard', strCity = 'Commerce City', dtmApprovedDate = NULL, strZip = '80022-', intMasterId = 61778
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4103', strName = 'NuStar Logistics, L. P. - Denver', strAddress = '3601 East 56th Street', strCity = 'Commerce City', dtmApprovedDate = NULL, strZip = '80022-', intMasterId = 61779
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4104', strName = 'Phillips 66 PL - Denver', strAddress = '3960 East 56th Avenue', strCity = 'Commerce City', dtmApprovedDate = NULL, strZip = '80022-', intMasterId = 61780
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4105', strName = 'Magellan Pipeline Company, L.P.', strAddress = '8160 Krameria', strCity = 'DuPont', dtmApprovedDate = NULL, strZip = '80024-', intMasterId = 61781
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4106', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1004 S. Sante Fe', strCity = 'Fountain', dtmApprovedDate = NULL, strZip = '80817-', intMasterId = 61782
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4107', strName = 'Golden Gate/SET Petroleum Partners', strAddress = '1493 Hwy 6 & 50', strCity = 'Fruita', dtmApprovedDate = NULL, strZip = '81521-', intMasterId = 61783
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4108', strName = 'NuStar Logistics, L. P. - Colorado Springs', strAddress = '7810 Drennan Road', strCity = 'Colorado Springs', dtmApprovedDate = NULL, strZip = '80925-', intMasterId = 61784
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4109', strName = 'Sinclair Transport.- Denver CO', strAddress = '8581 East 96th Ave', strCity = 'Commerce City', dtmApprovedDate = NULL, strZip = '80640-', intMasterId = 61785
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4110', strName = 'Phillips 66 PL - LaJunta Terminal', strAddress = '31610 East Hwy 50', strCity = 'LaJunta', dtmApprovedDate = NULL, strZip = '81050', intMasterId = 61786
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4112', strName = 'Golden Gate/SET Petroleum Partners', strAddress = '1629 21 Road', strCity = 'Fruita', dtmApprovedDate = NULL, strZip = '81521', intMasterId = 61787
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4113', strName = 'Union Pacific Railroad Co.', strAddress = '1400 West 52nd Ave', strCity = 'Denver', dtmApprovedDate = NULL, strZip = '80221', intMasterId = 61788
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84CO4111', strName = 'D.I.A. Facility', strAddress = '11110 Queensburg St.', strCity = 'DN', dtmApprovedDate = NULL, strZip = '80249', intMasterId = 61789


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'CO' , @TerminalControlNumbers = @TerminalCO

DELETE @TerminalCO

-- CT Terminals
PRINT ('Deploying CT Terminal Control Number')
DECLARE @TerminalCT AS TFTerminalControlNumbers

INSERT INTO @TerminalCT(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1251', strName = 'Sprague Operating Resources LLC - Stamford', strAddress = '10 Water St', strCity = 'Stamford', dtmApprovedDate = NULL, strZip = '06902-', intMasterId = 71789
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1252', strName = 'CITGO - Rocky Hill', strAddress = '109 Dividend Road', strCity = 'Rocky Hill', dtmApprovedDate = NULL, strZip = '06067-', intMasterId = 71790
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1254', strName = 'Equilon Enterprises LLC', strAddress = '481 East Shore Parkway', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06512-', intMasterId = 71791
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1255', strName = 'Buckeye Terminals, LLC - Groton', strAddress = '443 Eastern Point Road', strCity = 'Groton', dtmApprovedDate = NULL, strZip = '06340-', intMasterId = 71792
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1256', strName = 'Sprague Operating Resources LLC - Bridgeport', strAddress = '250 Eagles Nest Rd.', strCity = 'Bridgeport', dtmApprovedDate = NULL, strZip = '06607-', intMasterId = 71793
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1258', strName = 'New Haven Terminal, Inc.', strAddress = '100 Waterfront St', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06512-', intMasterId = 71794
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1259', strName = 'Buckeye Terminals, LLC - Wethersfield', strAddress = '50 Burbank Road', strCity = 'Wethersfield', dtmApprovedDate = NULL, strZip = '06109-9998', intMasterId = 71795
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1262', strName = 'Gulf Oil LP - New Haven', strAddress = '500 Waterfront Street', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06512-', intMasterId = 71796
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1263', strName = 'Magellan Terminals Holdings LP', strAddress = '134 Forbes Avenue', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06512-', intMasterId = 71797
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1264', strName = 'Waterfront Terminal', strAddress = '400 Waterfront St.', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06512-', intMasterId = 71798
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1265', strName = 'Magellan Terminals Holdings LP', strAddress = '85 East Street', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06536', intMasterId = 71799
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1267', strName = 'Global Companies LLC', strAddress = 'One Eagles Nest Rd', strCity = 'Bridgeport', dtmApprovedDate = NULL, strZip = '06605', intMasterId = 71800
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1270', strName = 'Global Companies LLC', strAddress = '80 Burbank Road', strCity = 'Wethersfield', dtmApprovedDate = NULL, strZip = '06109-', intMasterId = 71801
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1274', strName = 'Magellan Terminals Holdings LP', strAddress = '280 Waterfront St', strCity = 'New Haven', dtmApprovedDate = NULL, strZip = '06512-', intMasterId = 71802
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1279', strName = 'Inland Fuel Terminal, Inc.', strAddress = '154 Admiral St.', strCity = 'Bridgeport', dtmApprovedDate = NULL, strZip = '06605-', intMasterId = 71803
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1280', strName = 'B & B Petroleum, Inc.', strAddress = '22 Brownstone Ave', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '06480-', intMasterId = 71804
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1281', strName = 'Taylor Energy', strAddress = '152 Broad Brook Rd', strCity = 'Broad Brook', dtmApprovedDate = NULL, strZip = '06016-', intMasterId = 71805
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1285', strName = 'HOP Energy, LLC', strAddress = '410 Bank St.', strCity = 'New London', dtmApprovedDate = NULL, strZip = '06320-', intMasterId = 71806
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1286', strName = 'Sterling St. Terminal LLC', strAddress = '1351 Main Street', strCity = 'East Hartford', dtmApprovedDate = NULL, strZip = '06108', intMasterId = 71807
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1288', strName = 'New Haven Terminal, Inc.', strAddress = '119 Frontage Rd', strCity = 'East Haven', dtmApprovedDate = NULL, strZip = '06512', intMasterId = 71808
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06CT1271', strName = 'Aircraft Service International, Inc.', strAddress = 'Park Rd', strCity = 'Windsor Locks', dtmApprovedDate = NULL, strZip = '6096', intMasterId = 71809


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'CT' , @TerminalControlNumbers = @TerminalCT

DELETE @TerminalCT

-- DE Terminals
PRINT ('Deploying DE Terminal Control Number')
DECLARE @TerminalDE AS TFTerminalControlNumbers

INSERT INTO @TerminalDE(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T51DE1600', strName = 'Delaware City Logistics Company', strAddress = '4550 Wrangle Hill Road', strCity = 'Delaware City', dtmApprovedDate = NULL, strZip = '19706-', intMasterId = 81809
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52DE1602', strName = 'Delaware Storage & Pipeline Co.', strAddress = 'Port Mahon Rd.', strCity = 'Little Creek', dtmApprovedDate = NULL, strZip = '19961', intMasterId = 81810
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1574', strName = 'Magellan Terminals Holdings LP', strAddress = '1050 Christiana Ave.', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '19801', intMasterId = 81811

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'DE' , @TerminalControlNumbers = @TerminalDE

DELETE @TerminalDE

-- FL Terminals
PRINT ('Deploying FL Terminal Control Number')
DECLARE @TerminalFL AS TFTerminalControlNumbers

INSERT INTO @TerminalFL(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2100', strName = 'Murphy Oil USA, Inc. - Tampa', strAddress = '1306 Ingram Ave', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-', intMasterId = 91812
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2101', strName = 'TransMontaigne - Tampa', strAddress = '1523 Port Avenue', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-6745', intMasterId = 91813
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2102', strName = 'Buckeye Terminals, LLC - Jacksonville', strAddress = '2617 Heckscher Drive', strCity = 'Jacksonville', dtmApprovedDate = NULL, strZip = '32226-', intMasterId = 91814
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2105', strName = 'TransMontaigne - Jacksonville', strAddress = '3425 Talleyrand Avenue', strCity = 'Jacksonville', dtmApprovedDate = NULL, strZip = '32206', intMasterId = 91815
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2106', strName = 'MPLX Jacksonville', strAddress = '2101 Heckscher Dr', strCity = 'Jacksonville', dtmApprovedDate = NULL, strZip = '32218-6038', intMasterId = 91816
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2107', strName = 'Buckeye Terminals, LLC - Tampa', strAddress = '504 N 19th Street', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-', intMasterId = 91817
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2112', strName = 'NuStar Terminals Operations Partnership L. P. - Jacksonville', strAddress = '6531 Evergreen Avenue', strCity = 'Jacksonville', dtmApprovedDate = NULL, strZip = '32208-4911', intMasterId = 91818
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2114', strName = 'CITGO - Niceville', strAddress = '904 Bayshore Drive', strCity = 'Niceville', dtmApprovedDate = NULL, strZip = '32578-', intMasterId = 91819
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2115', strName = 'Murphy Oil USA, Inc. - Freeport', strAddress = '424 Madison St', strCity = 'Freeport', dtmApprovedDate = NULL, strZip = '32439-', intMasterId = 91820
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2116', strName = 'Chevron USA, Inc.- Panama City', strAddress = '525 West Beach Drive', strCity = 'Panama City', dtmApprovedDate = NULL, strZip = '32402-', intMasterId = 91821
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2120', strName = 'TransMontaigne - Pensacola', strAddress = '511 South Clubbs St.', strCity = 'Pensacola', dtmApprovedDate = NULL, strZip = '32501-', intMasterId = 91822
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2122', strName = 'TransMontaigne - Port Manatee', strAddress = '804 N Dock St.', strCity = 'Palmetto', dtmApprovedDate = NULL, strZip = '34220-', intMasterId = 91823
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2123', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '2101 GATX Drive', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-6863', intMasterId = 91824
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2124', strName = 'Motiva Enterprises LLC', strAddress = '6500 W. Commerce St', strCity = 'Port Tampa', dtmApprovedDate = NULL, strZip = '33616-', intMasterId = 91825
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2129', strName = 'Central Florida Pipeline LLC', strAddress = '9919 Orange Avenue', strCity = 'Orlando', dtmApprovedDate = NULL, strZip = '32824-8466', intMasterId = 91826
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2130', strName = 'Buckeye Terminals, LLC - Tampa', strAddress = '848 McCloskey Boulevard', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-6716', intMasterId = 91827
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2131', strName = 'Chevron USA, Inc.- Tampa', strAddress = '5500 Commerce Street', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33616-', intMasterId = 91828
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2133', strName = 'CITGO - Tampa', strAddress = '801 McCloskey Blvd', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-', intMasterId = 91829
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2136', strName = 'MPLX Tampa', strAddress = '425 South 20th Street', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33605-6025', intMasterId = 91830
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2138', strName = 'TransMontaigne - Cape Canaveral', strAddress = '8952 North Atlantic Ave', strCity = 'Cape Canaveral', dtmApprovedDate = NULL, strZip = '32920-', intMasterId = 91831
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2677', strName = 'Martin Operating Partnership, L.P.', strAddress = '4118 Pendola Point Rd.', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33617', intMasterId = 91832
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2678', strName = 'South Florida Materials Corp dba Vecenergy', strAddress = '300 Middle Road', strCity = 'Riviera Beach', dtmApprovedDate = NULL, strZip = '33404', intMasterId = 91833
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2679', strName = 'South Florida Materials Corp dba Vecenergy', strAddress = '1200 S. E. 32nd Street', strCity = 'Dania Beach', dtmApprovedDate = NULL, strZip = '33316', intMasterId = 91834
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2680', strName = 'Seaport Canaveral', strAddress = '555 Hwy 401', strCity = 'Cape Canaveral', dtmApprovedDate = NULL, strZip = '32920', intMasterId = 91835
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2681', strName = 'Center Point Terminal - Jacksonville', strAddress = '3101 Talley Rand Ave', strCity = 'Jacksonville', dtmApprovedDate = NULL, strZip = '32206', intMasterId = 91836
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2150', strName = 'TransMontaigne - Fort Lauderdale', strAddress = '2401 Eisenhower Blvd.', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91837
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2152', strName = 'Motiva Enterprises LLC', strAddress = '1180 Spangler Road', strCity = 'Ft Lauderdale', dtmApprovedDate = NULL, strZip = '33316', intMasterId = 91838
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2153', strName = 'Chevron USA, Inc. - Fort Lauderdale', strAddress = '1400 SE 24th St', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316', intMasterId = 91839
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2154', strName = 'Motiva Enterprises LLC', strAddress = '1500 SE 26 St', strCity = 'Ft. Lauderdale', dtmApprovedDate = NULL, strZip = '33316', intMasterId = 91840
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2156', strName = 'Buckeye Terminals, LLC - Fort Lauderdale', strAddress = '1501 SE 20th St.', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316', intMasterId = 91841
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2157', strName = 'CITGO Petroleum Corporation', strAddress = '801 SE 28th Street', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91842
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2159', strName = 'Allied Aviation Fueling of Miami', strAddress = '4450 NW 20th St. #201', strCity = 'Miami', dtmApprovedDate = NULL, strZip = '33122', intMasterId = 91843
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2160', strName = 'MPLX Ft Lauderdale Eisenhower', strAddress = '1601 SE 20th St', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91844
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2161', strName = 'ExxonMobil Oil Corp.', strAddress = '1150 Spangler Blvd', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91845
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2163', strName = 'MPLX Fort Lauderdale Spangler', strAddress = '909 SE 24th St.', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91846
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2164', strName = 'Motiva Enterprises LLC', strAddress = '1200 SE 28th St', strCity = 'Port Everglades', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91847
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2165', strName = 'TransMontaigne - Port Everglades', strAddress = '2701 SE 14th Ave', strCity = 'Fort Lauderdale', dtmApprovedDate = NULL, strZip = '33316-', intMasterId = 91848
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2166', strName = 'Transmontaigne - Fisher Island', strAddress = 'One B Street', strCity = 'Miami Beach', dtmApprovedDate = NULL, strZip = '33109', intMasterId = 91849
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2167', strName = 'Port Everglades Energy Center', strAddress = '8100 Eisenhower Blvd', strCity = 'Ft Lauderdale', dtmApprovedDate = NULL, strZip = '33316', intMasterId = 91850
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2682', strName = 'Buckeye Terminals, LLC - Jacksonville', strAddress = '10201 East Port Road', strCity = 'Jacksonville', dtmApprovedDate = NULL, strZip = '32218', intMasterId = 91851
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2110', strName = 'Aircraft Service International, Inc.', strAddress = '4720 North Westshore Bl.', strCity = 'Tampa', dtmApprovedDate = NULL, strZip = '33614', intMasterId = 91852
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T65FL2158', strName = 'Aircraft Service International, Inc.', strAddress = '3451 SW 2nd Ave.', strCity = 'Ft. Lauderdale', dtmApprovedDate = NULL, strZip = '33315', intMasterId = 91853
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59FL2111', strName = 'Aircraft Service International, Inc.', strAddress = '3800 Express St.', strCity = 'Orlando', dtmApprovedDate = NULL, strZip = '32827', intMasterId = 91854


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'FL' , @TerminalControlNumbers = @TerminalFL

DELETE @TerminalFL

-- GA Terminals
PRINT ('Deploying GA Terminal Control Number')
DECLARE @TerminalGA AS TFTerminalControlNumbers

INSERT INTO @TerminalGA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2500', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '1603 W Oakridge Dr', strCity = 'Albany', dtmApprovedDate = NULL, strZip = '31707-', intMasterId = 101851
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2501', strName = 'Magellan Terminals Holdings LP', strAddress = '1722 W Oakridge Dr', strCity = 'Albany', dtmApprovedDate = NULL, strZip = '31707-', intMasterId = 101852
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2502', strName = 'TransMontaigne - Albany', strAddress = '1162 Gillionville Rd', strCity = 'Albany', dtmApprovedDate = NULL, strZip = '31707-', intMasterId = 101853
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2505', strName = 'TransMontaigne - Americus', strAddress = 'Highway 280 West Plains Rd.', strCity = 'Americus', dtmApprovedDate = NULL, strZip = '31709-', intMasterId = 101854
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2506', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '3460 Jefferson Road', strCity = 'Athens', dtmApprovedDate = NULL, strZip = '30607-', intMasterId = 101855
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2507', strName = 'Epic Midstream LLC', strAddress = '2 Wahlstrom Rd.', strCity = 'Savannah', dtmApprovedDate = NULL, strZip = '31404-1033', intMasterId = 101856
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2508', strName = 'TransMontaigne - Athens', strAddress = '3450 Jefferson Road', strCity = 'Athens', dtmApprovedDate = NULL, strZip = '30607-', intMasterId = 101857
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2510', strName = 'Motiva Enterprises LLC', strAddress = '4127 Winters Chapel Rd.', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30360-', intMasterId = 101858
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2511', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '3132 Parrott Avenue N W', strCity = 'Atlanta', dtmApprovedDate = NULL, strZip = '30318-', intMasterId = 101859
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2514', strName = 'Motiva Enterprises LLC', strAddress = '1803 East Shotwell St.', strCity = 'Bainbridge', dtmApprovedDate = NULL, strZip = '39817', intMasterId = 101862
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2515', strName = 'TransMontaigne - Bainbridge', strAddress = '1909 East Shotwell Street', strCity = 'Bainbridge', dtmApprovedDate = NULL, strZip = '39817', intMasterId = 101863
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2517', strName = 'Epic Midstream LLC', strAddress = '870 Alabama Avenue', strCity = 'Bremen', dtmApprovedDate = NULL, strZip = '30110-2306', intMasterId = 101864
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2519', strName = 'Magellan Terminals Holdings LP', strAddress = '2970 Parrott Avenue', strCity = 'Atlanta', dtmApprovedDate = NULL, strZip = '30318-', intMasterId = 101865
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2520', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '5131 Miller Road', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '31908-', intMasterId = 101866
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2522', strName = 'Omega Partners III, LLC', strAddress = '5225 Miller Road', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '31904-', intMasterId = 101867
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2523', strName = 'MPLX Columbus', strAddress = '5030 Miller Road', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '31908-5561', intMasterId = 101868
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2525', strName = 'TransMontaigne - Doraville', strAddress = '2836 Woodwin Road', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30362-', intMasterId = 101870
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2526', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '6430 New Peachtree Road', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30340', intMasterId = 101871
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2528', strName = 'Chevron USA, Inc.- Doraville', strAddress = '4026 Winters Chapel Road', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30362-', intMasterId = 101872
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2529', strName = 'CITGO - Doraville', strAddress = '3877 Flowers Drive', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30362-', intMasterId = 101873
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2531', strName = 'Motiva Enterprises LLC', strAddress = '4143 Winters Chapel Rd', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30360-', intMasterId = 101874
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2532', strName = 'MPLX Doraville', strAddress = '6293 New Peachtree Road', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30341-1211', intMasterId = 101875
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2533', strName = 'Magellan Terminals Holdings LP', strAddress = '4149 Winters Chapel Road', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30360-', intMasterId = 101876
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2534', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '4064 Winters Chapel Rd', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30340-', intMasterId = 101877
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2535', strName = 'Magellan Terminals Holdings LP', strAddress = '2797 Woodwin Road', strCity = 'Doraville', dtmApprovedDate = NULL, strZip = '30360-', intMasterId = 101878
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2537', strName = 'TransMontaigne - Griffin', strAddress = '643B East McIntosh Road', strCity = 'Griffin', dtmApprovedDate = NULL, strZip = '30223-', intMasterId = 101880
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2538', strName = 'South Florida Materials Corp dba Vecenergy', strAddress = '2476 Allen Road', strCity = 'Macon', dtmApprovedDate = NULL, strZip = '31206-', intMasterId = 101881
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2541', strName = 'MPLX Macon', strAddress = '2445 Allen Road', strCity = 'Macon', dtmApprovedDate = NULL, strZip = '31206-6301', intMasterId = 101882
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2542', strName = 'Epic Midstream LLC', strAddress = '6225 Hawkinsville Road', strCity = 'Macon', dtmApprovedDate = NULL, strZip = '31216-5849', intMasterId = 101883
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2543', strName = 'Magellan Terminals Holdings LP', strAddress = '2505 Allen Road', strCity = 'Macon', dtmApprovedDate = NULL, strZip = '31206-', intMasterId = 101884
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2544', strName = 'TransMontaigne - Macon', strAddress = '5041 Forsyth Rd.', strCity = 'Macon', dtmApprovedDate = NULL, strZip = '31210-', intMasterId = 101885
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2545', strName = 'MPLX Powder Springs', strAddress = '3895 Anderson Farm Road NW', strCity = 'Powder Springs', dtmApprovedDate = NULL, strZip = '30073', intMasterId = 101886
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2547', strName = 'TransMontaigne - Rome', strAddress = '2671 Calhoun Road', strCity = 'Rome', dtmApprovedDate = NULL, strZip = '30161-', intMasterId = 101887
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2550', strName = 'Colonial Terminal, Inc.', strAddress = '101 North Lathrop Ave', strCity = 'Savannah', dtmApprovedDate = NULL, strZip = '31415-', intMasterId = 101888
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2551', strName = 'Vopak Terminal Savannah, Inc.', strAddress = 'Georgia Ports Garden City', strCity = 'Savannah', dtmApprovedDate = NULL, strZip = '31418-', intMasterId = 101889
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2553', strName = 'Norfolk Southern Railway Company', strAddress = '1550 Marietta Dr NW', strCity = 'Atlanta', dtmApprovedDate = NULL, strZip = '30318', intMasterId = 101890
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2554', strName = 'Norfolk Southern Railway Company', strAddress = '355 Turpin St', strCity = 'Macon', dtmApprovedDate = NULL, strZip = '31206', intMasterId = 101891
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2555', strName = 'Delta Terminal, Inc.', strAddress = '1500 Fuel Farm Road', strCity = 'Atlanta', dtmApprovedDate = NULL, strZip = '30320', intMasterId = 101892
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2556', strName = 'TransMontaigne - Lookout Mtn.', strAddress = '11 Highway 93', strCity = 'Flintstone', dtmApprovedDate = NULL, strZip = '30725', intMasterId = 101893
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T58GA2557', strName = 'Epic Midstream LLC', strAddress = '7 Foundation Drice', strCity = 'Savannah', dtmApprovedDate = NULL, strZip = '31408', intMasterId = 101894

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'GA' , @TerminalControlNumbers = @TerminalGA

DELETE @TerminalGA

-- HI Terminals
PRINT ('Deploying HI Terminal Control Number')
DECLARE @TerminalHI AS TFTerminalControlNumbers

INSERT INTO @TerminalHI(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91HI4570', strName = 'Signature Flight Support Corp.', strAddress = '200 Rodgers Blvd.', strCity = 'Honolulu', dtmApprovedDate = NULL, strZip = '96819', intMasterId = 111895
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91HI4571', strName = 'Kauai Petroleum Co., Ltd.', strAddress = '3185 Waapa Rd.', strCity = 'Lihue', dtmApprovedDate = NULL, strZip = '96766', intMasterId = 111896
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91HI4572', strName = 'Island Petroleum, Inc.', strAddress = 'Wharf Rd. & Beach Place #10', strCity = 'Kaunakakai', dtmApprovedDate = NULL, strZip = '96748', intMasterId = 111897
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4551', strName = 'Aloha Petroleum - Barber''s Point', strAddress = '91-119 Hanua Street', strCity = 'Kapolei', dtmApprovedDate = NULL, strZip = '96706', intMasterId = 111898
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4552', strName = 'IES Downstream LLC', strAddress = '666 Kalanianaole Avenue', strCity = 'Hilo', dtmApprovedDate = NULL, strZip = '96720-', intMasterId = 111899
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4553', strName = 'IES Downstream LLC', strAddress = '933 North Nimitz Highway', strCity = 'Honolulu', dtmApprovedDate = NULL, strZip = '96817-', intMasterId = 111900
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4554', strName = 'IES Downstream LLC', strAddress = '100 A Hobron Avenue', strCity = 'Kahului', dtmApprovedDate = NULL, strZip = '96732-', intMasterId = 111901
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4555', strName = 'IES Downstream LLC', strAddress = 'A & B Road, Port Allen', strCity = 'Eleele', dtmApprovedDate = NULL, strZip = '96705', intMasterId = 111902
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4557', strName = 'Aloha Petroleum Ltd.', strAddress = '789 N. Nimitz Hwy.', strCity = 'Honolulu', dtmApprovedDate = NULL, strZip = '96817-', intMasterId = 111903
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4558', strName = 'Aloha Petroleum Ltd.', strAddress = '661 Kalanianaole Ave.', strCity = 'Hilo', dtmApprovedDate = NULL, strZip = '96720-', intMasterId = 111904
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4559', strName = 'Tesoro Hawaii Corporation', strAddress = '607 Kalanianaole Ave.', strCity = 'Hilo', dtmApprovedDate = NULL, strZip = '96720', intMasterId = 111905
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4560', strName = 'Aloha Petroleum Ltd.', strAddress = '999 Kalanianaole Ave.', strCity = 'Hilo', dtmApprovedDate = NULL, strZip = '96720-', intMasterId = 111906
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4561', strName = 'Tesoro Hawaii Corporation', strAddress = '701 Kalanianaole Street', strCity = 'Hilo', dtmApprovedDate = NULL, strZip = '96720-', intMasterId = 111907
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4562', strName = 'Aloha Petroleum Ltd.', strAddress = '3145 Waapa Rd.', strCity = 'Lihue', dtmApprovedDate = NULL, strZip = '96766-', intMasterId = 111908
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4563', strName = 'Tesoro Hawaii Corporation', strAddress = '140 H Hobron Ave', strCity = 'Kahului', dtmApprovedDate = NULL, strZip = '96732', intMasterId = 111909
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4566', strName = 'Aloha Petroleum Ltd.', strAddress = '60 Hobron Ave.', strCity = 'Kahului', dtmApprovedDate = NULL, strZip = '96732-', intMasterId = 111910
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4567', strName = 'Midpac Petroleum Kawaihae Terminal', strAddress = '61-3651 Kawaihae Road', strCity = 'Kamuela', dtmApprovedDate = NULL, strZip = '96743', intMasterId = 111911
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4568', strName = 'Tesoro Hawaii Corporation', strAddress = '2 Sand Island Access Rd.', strCity = 'Honolulu', dtmApprovedDate = NULL, strZip = '96819', intMasterId = 111912
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T99HI4570', strName = 'IES Downstream LLC', strAddress = '91-480 Malakole Street', strCity = 'Kapolei', dtmApprovedDate = NULL, strZip = '96707', intMasterId = 111913

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'HI' , @TerminalControlNumbers = @TerminalHI

DELETE @TerminalHI

-- IA Terminals
PRINT ('Deploying IA Terminal Control Number')
DECLARE @TerminalIA AS TFTerminalControlNumbers

INSERT INTO @TerminalIA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39IA3475', strName = 'Sinclair Transport.- Montrose, IA', strAddress = '2506 260th St.', strCity = 'Montrose', dtmApprovedDate = NULL, strZip = '52639', intMasterId = 151914
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3450', strName = 'Buckeye Terminals, LLC - Bettendorf', strAddress = '75 South 31st Street', strCity = 'Bettendorf', dtmApprovedDate = NULL, strZip = '52722-', intMasterId = 151915
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3452', strName = 'U.S. Oil - Bettendorf Depot', strAddress = '2925 Depot Street', strCity = 'Bettendorf', dtmApprovedDate = NULL, strZip = '52722-', intMasterId = 151916
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3454', strName = 'Buckeye Terminals, LLC - Council Bluffs', strAddress = '829 Tank Farm Road', strCity = 'Council Bluffs', dtmApprovedDate = NULL, strZip = '51503', intMasterId = 151917
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3455', strName = 'CHS McPherson Refinery Inc - Council Bluffs Terminal', strAddress = '825 Tank Farm Road', strCity = 'Council Bluffs', dtmApprovedDate = NULL, strZip = '51503-', intMasterId = 151918
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3456', strName = 'Buckeye Terminals, LLC - Des Moines', strAddress = '1501 Northwest 86th Street', strCity = 'Des Moines', dtmApprovedDate = NULL, strZip = '50325-', intMasterId = 151919
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3457', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2503 Southeast 43rd Street', strCity = 'Des Moines', dtmApprovedDate = NULL, strZip = '50317-', intMasterId = 151920
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3458', strName = 'BP Products North America Inc', strAddress = '15393 Old Highway Road.', strCity = 'Peosta', dtmApprovedDate = NULL, strZip = '52068', intMasterId = 151921
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3460', strName = 'Magellan Pipeline Company, L.P.', strAddress = '8038 St Joe''s Prairie Rd', strCity = 'Dubuque', dtmApprovedDate = NULL, strZip = '52003-', intMasterId = 151922
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3461', strName = 'Growmark, Inc.', strAddress = '3140 Two Hundred Street', strCity = 'Duncombe', dtmApprovedDate = NULL, strZip = '50532-', intMasterId = 151923
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3463', strName = 'Magellan Pipeline Company, L.P.', strAddress = '912 First Avenue', strCity = 'Coralville', dtmApprovedDate = NULL, strZip = '52241-', intMasterId = 151924
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3464', strName = 'NuStar Pipeline Operating Partnership, L.P. - Le Mars', strAddress = '33035 C 12', strCity = 'Le Mars', dtmApprovedDate = NULL, strZip = '51031-', intMasterId = 151925
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3465', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2810 East Main', strCity = 'Clear Lake', dtmApprovedDate = NULL, strZip = '50428-', intMasterId = 151926
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3466', strName = 'NuStar Pipeline Operating Partnership, L.P. - Milford', strAddress = '2127 220th Street', strCity = 'Milford', dtmApprovedDate = NULL, strZip = '51351-', intMasterId = 151927
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3467', strName = 'Magellan Pipeline Company, L.P.', strAddress = 'RT #1', strCity = 'Milford', dtmApprovedDate = NULL, strZip = '51351-', intMasterId = 151928
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3468', strName = 'Buckeye Terminals, LLC - Cedar Rapids', strAddress = '2092 Hwy. 965 NE', strCity = 'North Liberty', dtmApprovedDate = NULL, strZip = '52317-', intMasterId = 151929
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3469', strName = 'Buckeye Terminals, LLC - Ottumwa', strAddress = '16848 87th St', strCity = 'Ottumwa', dtmApprovedDate = NULL, strZip = '52501-', intMasterId = 151930
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3470', strName = 'Phillips 66 PL - Pleasant Hill', strAddress = '4500 Vandalia', strCity = 'Pleasant Hill', dtmApprovedDate = NULL, strZip = '50327-', intMasterId = 151931
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3471', strName = 'Magellan Pipeline Company, L.P.', strAddress = '312 South Bellingham Street', strCity = 'Riverdale', dtmApprovedDate = NULL, strZip = '52722-', intMasterId = 151932
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3472', strName = 'NuStar Pipeline Operating Partnership, L.P. - Rock Rapids', strAddress = '3025 Highway 9 Street', strCity = 'Rock Rapids', dtmApprovedDate = NULL, strZip = '51246-', intMasterId = 151933
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3473', strName = 'Magellan Pipeline Company, L.P.', strAddress = '4300 41st Street', strCity = 'Sioux City', dtmApprovedDate = NULL, strZip = '51108-', intMasterId = 151934
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T42IA3474', strName = 'Magellan Pipeline Company, L.P.', strAddress = '5360 Eldora Rd', strCity = 'Waterloo', dtmApprovedDate = NULL, strZip = '50701-', intMasterId = 151935

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'IA' , @TerminalControlNumbers = @TerminalIA

DELETE @TerminalIA

-- ID Terminals
PRINT ('Deploying ID Terminal Control Number')
DECLARE @TerminalID AS TFTerminalControlNumbers

INSERT INTO @TerminalID(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T82ID4150', strName = 'Sinclair Transportation Company', strAddress = '321 North Curtis Road', strCity = 'Boise', dtmApprovedDate = NULL, strZip = '83707-', intMasterId = 121936
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T82ID4151', strName = 'Tesoro Logistics Operations LLC', strAddress = '201 N. Phillipi', strCity = 'Boise', dtmApprovedDate = NULL, strZip = '83706-', intMasterId = 121937
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T82ID4152', strName = 'United Products Terminal', strAddress = '70 North Philipi Road', strCity = 'Boise', dtmApprovedDate = NULL, strZip = '83706-', intMasterId = 121938
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T82ID4155', strName = 'Tesoro Logistics Operations LLC', strAddress = '421 East Highway 81', strCity = 'Burley', dtmApprovedDate = NULL, strZip = '83318-', intMasterId = 121939
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T82ID4157', strName = 'Sinclair Transport.- Burley, ID', strAddress = '425 East Hwy 81 PO Box 233', strCity = 'Burley', dtmApprovedDate = NULL, strZip = '83318-', intMasterId = 121940
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T82ID4159', strName = 'Tesoro Logistics Operations LLC', strAddress = '1189 Tank Farm Rd.', strCity = 'Pocatello', dtmApprovedDate = NULL, strZip = '83201-', intMasterId = 121941
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84ID4153', strName = 'Union Pacific Railroad Co.', strAddress = '237 East Day St.', strCity = 'Pocatello', dtmApprovedDate = NULL, strZip = '83204', intMasterId = 121942

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'ID' , @TerminalControlNumbers = @TerminalID

DELETE @TerminalID

-- IL Terminals
PRINT ('Deploying IL Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3300', strName = 'Valero Terminaling & Distribution', strAddress = '3600 W 131st Street', strCity = 'Alsip', dtmApprovedDate = NULL, strZip = '60803', intMasterId = 13411
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3301', strName = 'BP Products North America Inc', strAddress = '1111 Elmhurst Rd', strCity = 'Elk Grove Village', dtmApprovedDate = NULL, strZip = '60007', intMasterId = 13412
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3302', strName = 'BP Products North America Inc', strAddress = '4811 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13413
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3303', strName = 'BP Products North America Inc', strAddress = '100 East Standard Oil Road', strCity = 'Rochelle', dtmApprovedDate = NULL, strZip = '61068', intMasterId = 13414
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3304', strName = 'CITGO - Mt.  Prospect', strAddress = '2316 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13415
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3305', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '8500 West 68th Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501-0409', intMasterId = 13416
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3306', strName = 'Buckeye Terminals, LLC - Rockford', strAddress = '1511 South Meridian Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102-', intMasterId = 13417
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3307', strName = 'Marathon Mt. Prospect', strAddress = '3231 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005-4610', intMasterId = 13418
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3308', strName = 'Marathon Oil Rockford', strAddress = '7312 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 13419
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3310', strName = 'NuStar Terminal Services, Inc - Blue Island', strAddress = '3210 West 131st Street', strCity = 'Blue Island', dtmApprovedDate = NULL, strZip = '60406-2364', intMasterId = 13420
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3311', strName = 'ExxonMobil Oil Corp.', strAddress = '2312 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13421
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3312', strName = 'Petroleum Fuel & Terminal - Forest View', strAddress = '4801 South Harlem', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13422
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3313', strName = 'Buckeye Terminals, LLC - Kankakee', strAddress = '275 North 2750 West Road', strCity = 'Kankakee', dtmApprovedDate = NULL, strZip = '60901', intMasterId = 13423
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3315', strName = 'Buckeye Terminals, LLC - Argo', strAddress = '8600 West 71st. Street', strCity = 'Argo', dtmApprovedDate = NULL, strZip = '60501', intMasterId = 13424
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3316', strName = 'Shell Oil Products US', strAddress = '1605 E. Algonquin Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13425
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3317', strName = 'CITGO - Lemont', strAddress = '135th & New Avenue', strCity = 'Lemont', dtmApprovedDate = NULL, strZip = '60439', intMasterId = 13426
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3318', strName = 'CITGO - Arlington Heights', strAddress = '2304 Terminal Drive', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13427
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3326', strName = 'United Parcel Service Inc', strAddress = '3300 Airport Dr', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61109', intMasterId = 13430
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3375', strName = 'ExxonMobil Oil Corporation', strAddress = '12909 High Road', strCity = 'Lockport', dtmApprovedDate = NULL, strZip = '60441-', intMasterId = 13431
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3377', strName = 'IMTT-Illinois', strAddress = '24420 W Durkee Road', strCity = 'Channahon', dtmApprovedDate = NULL, strZip = '60410', intMasterId = 13433
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3351', strName = 'BP Products North America Inc', strAddress = '1000 BP Lane', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13435
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3353', strName = 'Phillips 66 PL - Hartford', strAddress = '2150 Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13436
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3354', strName = 'Hartford Wood River Terminal', strAddress = '900 North Delmar', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048', intMasterId = 13437
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3356', strName = 'Buckeye Terminals, LLC - Hartford', strAddress = '220 E Hawthorne Street', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-', intMasterId = 13438
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3358', strName = 'Marathon Champaign', strAddress = '511 S. Staley Road', strCity = 'Champaign', dtmApprovedDate = NULL, strZip = '61821', intMasterId = 13439
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3360', strName = 'Marathon Robinson', strAddress = '12345 E 1050th Ave', strCity = 'Robinson', dtmApprovedDate = NULL, strZip = '62454', intMasterId = 13440
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3361', strName = 'HWRT Terminal - Norris City', strAddress = 'Rural Route 2', strCity = 'Norris City', dtmApprovedDate = NULL, strZip = '62869', intMasterId = 13441
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3364', strName = 'Growmark, Inc.', strAddress = 'Rt 49 South', strCity = 'Ashkum', dtmApprovedDate = NULL, strZip = '60911', intMasterId = 13442
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3365', strName = 'Buckeye Terminals, LLC - Decatur', strAddress = '266 E Shafer Drive', strCity = 'Forsyth', dtmApprovedDate = NULL, strZip = '62535', intMasterId = 13443
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3366', strName = 'Phillips 66 PL - E. St.  Louis', strAddress = '3300 Mississippi Ave', strCity = 'Cahokia', dtmApprovedDate = NULL, strZip = '62206', intMasterId = 13444
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3368', strName = 'Buckeye Terminals, LLC - Effingham', strAddress = '18264 N US Hwy 45', strCity = 'Effingham', dtmApprovedDate = NULL, strZip = '62401', intMasterId = 13445
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3369', strName = 'Buckeye Terminals, LLC - Harristown', strAddress = '600 E. Lincoln Memorial Pky', strCity = 'Harristown', dtmApprovedDate = NULL, strZip = '62537', intMasterId = 13446
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3371', strName = 'Magellan Pipeline Company, L.P.', strAddress = '16490 East 100 North Rd.', strCity = 'Heyworth', dtmApprovedDate = NULL, strZip = '61745', intMasterId = 13447
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3372', strName = 'Growmark, Inc.', strAddress = '18349 State Hwy 29', strCity = 'Petersburg', dtmApprovedDate = NULL, strZip = '62675', intMasterId = 13448
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43IL3729', strName = 'Omega Partners III, LLC', strAddress = '1402 S Delmare', strCity = 'Hartford', dtmApprovedDate = NULL, strZip = '62048-0065', intMasterId = 13449
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72IL0001', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3400 South Badger Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13450
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72IL0002', strName = 'West Shore Pipeline Company - Forest View', strAddress = '5027 South Harlem Avenue', strCity = 'Forest View', dtmApprovedDate = NULL, strZip = '60402', intMasterId = 13451
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72IL0003', strName = 'West Shore Pipeline Company - Arlington Heights', strAddress = '3223 Busse Road', strCity = 'Arlington Heights', dtmApprovedDate = NULL, strZip = '60005', intMasterId = 13452
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72IL0004', strName = 'West Shore Pipeline Company - Rockford', strAddress = '7245 Cunningham Road', strCity = 'Rockford', dtmApprovedDate = NULL, strZip = '61102', intMasterId = 13453
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T37IL3374', strName = 'Marathon Robinson Refinery Rack', strAddress = '400 S Marathon Ave', strCity = 'Robinson', dtmApprovedDate = NULL, strZip = '62454', intMasterId = 131571
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3325', strName = 'Aircraft Service International, Inc.', strAddress = 'Patton Drive, Bldg 825', strCity = 'Chicago', dtmApprovedDate = NULL, strZip = '60666', intMasterId = 131572
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3376', strName = 'Aircraft Service International, Inc.', strAddress = '5401 S Laramie', strCity = 'Midway', dtmApprovedDate = NULL, strZip = '60638', intMasterId = 131573
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3319', strName = 'Growmark, Inc.', strAddress = '1222 U S Route 30', strCity = 'Amboy', dtmApprovedDate = NULL, strZip = '61310', intMasterId = 131574
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T36IL3324', strName = 'Oneok North System', strAddress = '4755 E Route 6', strCity = 'Morris', dtmApprovedDate = NULL, strZip = '60450', intMasterId = 131575


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'IL', @TerminalControlNumbers = @TerminalIL

DELETE @TerminalIL

-- IN Terminals
PRINT ('Deploying IN Terminal Control Number')
DECLARE @TerminalIN AS TFTerminalControlNumbers

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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3202', strName = 'Valero Terminaling & Distribution', strAddress = '1020 141st St', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320-', intMasterId = 14374
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3203', strName = 'Buckeye Terminals, LLC - Granger', strAddress = '12694 Adams Rd', strCity = 'Granger', dtmApprovedDate = NULL, strZip = '46530', intMasterId = 14375
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3204', strName = 'BP Products North America Inc', strAddress = '2500 N Tibbs Avenue', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222', intMasterId = 14376
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3205', strName = 'BP Products North America Inc', strAddress = '2530 Indianapolis Blvd.', strCity = 'Whiting', dtmApprovedDate = NULL, strZip = '46394', intMasterId = 14377
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3207', strName = 'Marathon Evansville', strAddress = '2500 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712', intMasterId = 14378
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3208', strName = 'Marathon Huntington', strAddress = '4648 N. Meridian Road', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14379
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3209', strName = 'CITGO Petroleum Corporation - East Chicago', strAddress = '2500 East Chicago Ave', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312', intMasterId = 14380
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3210', strName = 'CITGO - Huntington', strAddress = '4393 N Meridian Rd US 24', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14381
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3211', strName = 'Gladieux Trading & Marketing Co.', strAddress = '4757 US 24 E', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14382
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3212', strName = 'TransMontaigne - Kentuckiana', strAddress = '20 Jackson St.', strCity = 'New Albany', dtmApprovedDate = NULL, strZip = '47150', intMasterId = 14383
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3213', strName = 'TransMontaigne - Evansville', strAddress = '2630 Broadway', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '47712', intMasterId = 14384
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3214', strName = 'Countrymark Cooperative LLP', strAddress = '1200 Refinery Road', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620', intMasterId = 14385
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3216', strName = 'HWRT Terminal - Seymour', strAddress = '9780 N US Hwy 31', strCity = 'Seymour', dtmApprovedDate = NULL, strZip = '47274', intMasterId = 14386
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3218', strName = 'Marathon Hammond', strAddress = '4206 Columbia Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327', intMasterId = 14387
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3219', strName = 'Marathon Indianapolis', strAddress = '4955 Robison Rd', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268-1040', intMasterId = 14388
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3221', strName = 'Marathon Muncie', strAddress = '2100 East State Road 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303-4773', intMasterId = 14389
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3222', strName = 'Marathon Speedway', strAddress = '1304 Olin Ave', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46222-3294', intMasterId = 14390
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3224', strName = 'ExxonMobil Oil Corp.', strAddress = '1527 141th Street', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46327', intMasterId = 14391
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3225', strName = 'Buckeye Terminals, LLC - East Chicago', strAddress = '400 East Columbus Dr', strCity = 'East Chicago', dtmApprovedDate = NULL, strZip = '46312', intMasterId = 14392
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3226', strName = 'Buckeye Terminals, LLC - Raceway', strAddress = '3230 N Raceway Road', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234', intMasterId = 14393
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3227', strName = 'NuStar Terminals Operations Partnership L. P. - Indianapolis', strAddress = '3350 N. Raceway Rd.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234-1163', intMasterId = 14394
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3228', strName = 'Buckeye Terminals, LLC - East Hammond', strAddress = '2400 Michigan St.', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320', intMasterId = 14395
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3229', strName = 'Buckeye Terminals, LLC - Muncie', strAddress = '2000 East State Rd. 28', strCity = 'Muncie', dtmApprovedDate = NULL, strZip = '47303', intMasterId = 14396
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3230', strName = 'Buckeye Terminals, LLC - Zionsville', strAddress = '5405 West 96th St.', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46268', intMasterId = 14397
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3231', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4691 N Meridian St', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14398
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3232', strName = 'ERPC Princeton', strAddress = 'CR 950 E', strCity = 'Oakland City', dtmApprovedDate = NULL, strZip = '47660', intMasterId = 14399
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3234', strName = 'Lassus Bros. Oil, Inc. - Huntington', strAddress = '4413 North Meridian Rd', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 14400
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3235', strName = 'Countrymark Cooperative LLP', strAddress = '17710 Mule Barn Road', strCity = 'Westfield', dtmApprovedDate = NULL, strZip = '46074', intMasterId = 14401
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3236', strName = 'Countrymark Cooperative LLP', strAddress = '1765 West Logansport Rd.', strCity = 'Peru', dtmApprovedDate = NULL, strZip = '46970', intMasterId = 14402
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3237', strName = 'Countrymark Cooperative LLP', strAddress = 'RR # 1, Box 119A', strCity = 'Switz City', dtmApprovedDate = NULL, strZip = '47465', intMasterId = 14403
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3238', strName = 'Buckeye Terminals, LLC - Indianapolis', strAddress = '10700 E County Rd 300N', strCity = 'Indianapolis', dtmApprovedDate = NULL, strZip = '46234', intMasterId = 14404
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3239', strName = 'Marathon Mt Vernon', strAddress = '129 South Barter Street ', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '47620-', intMasterId = 14405
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3243', strName = 'CSX Transportation Inc', strAddress = '491 S. County Road 800 E.', strCity = 'Avon', dtmApprovedDate = NULL, strZip = '46123-', intMasterId = 14406
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3245', strName = 'Norfolk Southern Railway Co End Terminal', strAddress = '2600 W. Lusher Rd.', strCity = 'Elkhart', dtmApprovedDate = NULL, strZip = '46516-', intMasterId = 14407
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3246', strName = 'Buckeye Terminals, LLC - South Bend', strAddress = '20630 W. Ireland Rd.', strCity = 'South Bend', dtmApprovedDate = NULL, strZip = '46614-', intMasterId = 14408
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3248', strName = 'West Shore Pipeline Company - Hammond', strAddress = '3900 White Oak Avenue', strCity = 'Hammond', dtmApprovedDate = NULL, strZip = '46320', intMasterId = 14409
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3249', strName = 'NGL Supply Terminal Company LLC - Lebanon', strAddress = '550 West County Road 125 South', strCity = 'Lebanon', dtmApprovedDate = NULL, strZip = '46052', intMasterId = 14410
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3250', strName = 'Petrogas Inc', strAddress = '1800 Avenue H', strCity = 'Griffith', dtmApprovedDate = NULL, strZip = '46319', intMasterId = 141569
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T35IN3251', strName = 'Buckey Development & Logistics', strAddress = '226 East Hoster Road', strCity = 'Huntington', dtmApprovedDate = NULL, strZip = '46750', intMasterId = 141570

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'IN' , @TerminalControlNumbers = @TerminalIN

DELETE @TerminalIN

-- KS Terminals
PRINT ('Deploying KS Terminal Control Number')
DECLARE @TerminalKS AS TFTerminalControlNumbers

INSERT INTO @TerminalKS(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43KS3653', strName = 'Signature Flight Support Corp.', strAddress = '1980 Airport Rd.', strCity = 'Wichita', dtmApprovedDate = NULL, strZip = '67209', intMasterId = 161945
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43KS3672', strName = 'Phillips 66 PL - Kansas City', strAddress = '2029 Fairfax Trafficway', strCity = 'Kansas City', dtmApprovedDate = NULL, strZip = '66115', intMasterId = 161946
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3651', strName = 'Coffeyville Terminal Operations', strAddress = '400 N. Linden Street', strCity = 'Coffeyville', dtmApprovedDate = NULL, strZip = '67337', intMasterId = 161947
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3652', strName = 'NuStar Pipeline Operating Partnership, L.P. - Concordia', strAddress = '1612 Deer Road - US HWY 24', strCity = 'Delphos', dtmApprovedDate = NULL, strZip = '67436-', intMasterId = 161948
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3654', strName = 'Holly Energy Partners - Operating LP', strAddress = 'South Haverhill Road', strCity = 'El Dorado', dtmApprovedDate = NULL, strZip = '67042-', intMasterId = 161949
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3655', strName = 'Magellan Pipeline Company, L.P.', strAddress = '48 NE Highway 156', strCity = 'Great Bend', dtmApprovedDate = NULL, strZip = '67530-', intMasterId = 161950
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3656', strName = 'NuStar Pipeline Operating Partnership, L.P. - Hutchison', strAddress = '3300 East Avenue G', strCity = 'Hutchinson', dtmApprovedDate = NULL, strZip = '67501-', intMasterId = 161951
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3657', strName = 'BNSF - Argentine', strAddress = '2201 Argentine Blvd', strCity = 'Kansas City', dtmApprovedDate = NULL, strZip = '66106', intMasterId = 161952
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3658', strName = 'Sinclair Transport. - Kansas City', strAddress = '3401 Fairbanks Avenue', strCity = 'Kansas City', dtmApprovedDate = NULL, strZip = '66106-', intMasterId = 161953
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3659', strName = 'Magellan Pipeline Company, L.P.', strAddress = '401 East Donovan Road', strCity = 'Kansas City', dtmApprovedDate = NULL, strZip = '66115-', intMasterId = 161954
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3660', strName = 'CHS McPherson Refinery Inc - McPherson Terminal', strAddress = '1391 Iron Horse Rd.', strCity = 'McPherson', dtmApprovedDate = NULL, strZip = '67460-', intMasterId = 161955
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3661', strName = 'Magellan Pipeline Company, L.P.', strAddress = '13745 W 135th St', strCity = 'Olathe', dtmApprovedDate = NULL, strZip = '66062-', intMasterId = 161956
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3663', strName = 'NuStar Pipeline Operating Partnership, L.P. - Salina', strAddress = '2137 W Old Hwy 40', strCity = 'Salina', dtmApprovedDate = NULL, strZip = '67401-9798', intMasterId = 161957
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3664', strName = 'Magellan Pipeline Company, L.P.', strAddress = '100 Highway 4', strCity = 'Scott City', dtmApprovedDate = NULL, strZip = '67871-', intMasterId = 161958
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3665', strName = 'Magellan Pipeline Company, L.P.', strAddress = 'US Hwy 75 RFD 1', strCity = 'Wakarusa', dtmApprovedDate = NULL, strZip = '66546-', intMasterId = 161959
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3666', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1120 S Meridian', strCity = 'Valley Center', dtmApprovedDate = NULL, strZip = '67147-0376', intMasterId = 161960
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3667', strName = 'Growmark, Inc.', strAddress = '963 Vernon Rd', strCity = 'Wathena', dtmApprovedDate = NULL, strZip = '66090-', intMasterId = 161961
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3670', strName = 'Phillips 66 PL - Wichita South', strAddress = '8001 Oak Knoll Road', strCity = 'Wichita', dtmApprovedDate = NULL, strZip = '67207-', intMasterId = 161962
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3671', strName = 'Phillips 66 PL - Wichita North', strAddress = '2400 East 37th Street North', strCity = 'Wichita', dtmApprovedDate = NULL, strZip = '67219-', intMasterId = 161963
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T48KS3678', strName = 'Williams Hutch Rail Company', strAddress = '407 South Obee Road', strCity = 'Hutchinson', dtmApprovedDate = NULL, strZip = '67501', intMasterId = 161964

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'KS' , @TerminalControlNumbers = @TerminalKS

DELETE @TerminalKS

-- KY Terminals
PRINT ('Deploying KY Terminal Control Number')
DECLARE @TerminalKY AS TFTerminalControlNumbers

INSERT INTO @TerminalKY(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3262', strName = 'MPLX Viney Branch', strAddress = 'Old St Rt 23', strCity = 'Catlettsburg', dtmApprovedDate = NULL, strZip = '41129-', intMasterId = 171965
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3263', strName = 'MPLX Covington', strAddress = '230 East 33rd Street', strCity = 'Covington', dtmApprovedDate = NULL, strZip = '41015-', intMasterId = 171966
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3264', strName = 'TransMontaigne - Greater Cinci', strAddress = '700 River Rd. (Hwy 8)', strCity = 'Covington', dtmApprovedDate = NULL, strZip = '41017-', intMasterId = 171967
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3265', strName = 'Omega Partners III, LLC', strAddress = '2321 Old Geneva Road', strCity = 'Henderson', dtmApprovedDate = NULL, strZip = '42420-', intMasterId = 171968
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3266', strName = 'MPLX Lexington', strAddress = '1770 Old Frankfort Pike', strCity = 'Lexington', dtmApprovedDate = NULL, strZip = '40504-', intMasterId = 171969
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3267', strName = 'Valero Terminaling & Distribution', strAddress = '1750 Old Frankfort Pike', strCity = 'Lexington', dtmApprovedDate = NULL, strZip = '40504-', intMasterId = 171970
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3268', strName = 'MPLX Louisville (Algonquin)', strAddress = '4510 Algonquin Parkway', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40211-', intMasterId = 171971
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3269', strName = 'Buckeye Terminals, LLC - Louisville', strAddress = '1500 Southwestern Parkway', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40211', intMasterId = 171972
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3270', strName = 'Valero Terminaling & Distribution', strAddress = '4411 Bells Lane', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40211-', intMasterId = 171973
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3271', strName = 'TransMontaigne - Louisville', strAddress = '4510 Bells Lane', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40211-', intMasterId = 171974
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3272', strName = 'MPLX Louisville (Kramers Lane)', strAddress = '3920 Kramers Lane', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40216-4651', intMasterId = 171975
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3273', strName = 'Thornton Transportation, Inc.', strAddress = '7800 Cane Run Road', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40258-', intMasterId = 171976
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3274', strName = 'CITGO Equilon - Louisville', strAddress = '4724 Camp Ground Road', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40216-', intMasterId = 171977
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3276', strName = 'MPLX Paducah', strAddress = 'Highway 62 & MAPLLC Road', strCity = 'Paducah', dtmApprovedDate = NULL, strZip = '42003-', intMasterId = 171978
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3278', strName = 'TransMontaigne - Paducah', strAddress = '233 Elizabeth St.', strCity = 'Paducah', dtmApprovedDate = NULL, strZip = '42001-', intMasterId = 171979
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3279', strName = 'TransMontaigne - Henderson', strAddress = '2633 Sunset Lane', strCity = 'Henderson', dtmApprovedDate = NULL, strZip = '42420-', intMasterId = 171980
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3280', strName = 'Southern States Cooperative', strAddress = '150 Coast Guard Lane', strCity = 'Owensboro', dtmApprovedDate = NULL, strZip = '42302-0000', intMasterId = 171981
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3281', strName = 'Continental Refining Company', strAddress = '600 Monticello Street', strCity = 'Somerset', dtmApprovedDate = NULL, strZip = '42501', intMasterId = 171982
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3283', strName = 'TransMontaigne - Owensboro', strAddress = '900 Pleasant Valley Road', strCity = 'Owensboro', dtmApprovedDate = NULL, strZip = '42302-0000', intMasterId = 171983
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62KY2210', strName = 'UPS Fuel Farm Terminal', strAddress = '911 Grade Lane', strCity = 'Louisville', dtmApprovedDate = NULL, strZip = '40213', intMasterId = 171984
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62KY3285', strName = 'Catlettsburg Refining, LLC', strAddress = '8023 Crider Dr.', strCity = 'Catlettsburg', dtmApprovedDate = NULL, strZip = '41129-1492', intMasterId = 171985
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T61KY3277', strName = 'Aircraft Service International, Inc.', strAddress = '2462 Spence Dr.', strCity = 'Erlanger', dtmApprovedDate = NULL, strZip = '41017', intMasterId = 171986


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'KY' , @TerminalControlNumbers = @TerminalKY

DELETE @TerminalKY

-- LA Terminals
PRINT ('Deploying LA Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2351', strName = 'Chevron USA, Inc.- Arcadia', strAddress = 'Highway 80 East', strCity = 'Arcadia', dtmApprovedDate = NULL, strZip = '71001-', intMasterId = 18970
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2353', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Highway 80 East', strCity = 'Arcadia', dtmApprovedDate = NULL, strZip = '71001-', intMasterId = 18971
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2358', strName = 'ExxonMobil Oil Corp.', strAddress = '3329 Scenic Highway', strCity = 'Baton Rouge', dtmApprovedDate = NULL, strZip = '70805-', intMasterId = 18973
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2360', strName = 'Chalmette Refining, LLC', strAddress = '1700 Paris Rd Gate 50', strCity = 'Chalmette', dtmApprovedDate = NULL, strZip = '70043-', intMasterId = 18974
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2361', strName = 'Motiva Enterprises LLC', strAddress = 'Louisiana Street', strCity = 'Covent', dtmApprovedDate = NULL, strZip = '70723-', intMasterId = 18975
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2363', strName = 'Marathon Oil Garyville', strAddress = 'Highway 61', strCity = 'Garyville', dtmApprovedDate = NULL, strZip = '70051-', intMasterId = 18976
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2365', strName = 'Motiva Enterprises LLC', strAddress = '143 Firehouse Dr.', strCity = 'Kenner', dtmApprovedDate = NULL, strZip = '70062-', intMasterId = 18977
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2368', strName = 'CITGO - Lake Charles', strAddress = 'Cities Serv Hwy & LA Hwy 108', strCity = 'Lake Charles', dtmApprovedDate = NULL, strZip = '70601-', intMasterId = 18978
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2371', strName = 'Valero Refining - Meraux', strAddress = '2501 East St Bernard Hwy', strCity = 'Meraux', dtmApprovedDate = NULL, strZip = '70075-', intMasterId = 18979
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2375', strName = 'Buckeye Terminals, LLC - Opelousas', strAddress = 'Highway 182 South', strCity = 'Opelousas', dtmApprovedDate = NULL, strZip = '70571-', intMasterId = 18980
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2376', strName = 'Placid Refining Co. LLC', strAddress = '1940 Louisiana Hwy One North', strCity = 'Port Allen', dtmApprovedDate = NULL, strZip = '70767-', intMasterId = 18981
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2377', strName = 'IMTT - St Rose', strAddress = '11842 River Rd.', strCity = 'Saint Rose', dtmApprovedDate = NULL, strZip = '70087', intMasterId = 18982
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2378', strName = 'Shreveport Refinery', strAddress = '3333 Midway  PO Box 3099', strCity = 'Shreveport', dtmApprovedDate = NULL, strZip = '71133-3099', intMasterId = 18983
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2381', strName = 'Phillips 66 PL - Westlake', strAddress = '1980 Old Spanish Trail', strCity = 'Westlake', dtmApprovedDate = NULL, strZip = '70669-', intMasterId = 18984
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2388', strName = 'Calumet Lubricants Co., LP', strAddress = 'U. S. Hwy 371 South', strCity = 'Cotton Valley', dtmApprovedDate = NULL, strZip = '71018-', intMasterId = 18985
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2389', strName = 'Calumet Lubricants Co., LP', strAddress = '10234 Hwy 157', strCity = 'Princeton', dtmApprovedDate = NULL, strZip = '71067-9172', intMasterId = 18986
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2391', strName = 'LBC Baton Rouge LLC', strAddress = '1725 Highway 75', strCity = 'Sunshine', dtmApprovedDate = NULL, strZip = '70780-', intMasterId = 18987
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2392', strName = 'Archie Terminal Company', strAddress = '5010 Hwy 84', strCity = 'Jonesville', dtmApprovedDate = NULL, strZip = '71343', intMasterId = 18988
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2393', strName = 'Monroe Terminal Company LLC', strAddress = '486 Highway 165 South', strCity = 'Monroe', dtmApprovedDate = NULL, strZip = '71202', intMasterId = 18989
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2394', strName = 'ERPC Shreveport Area Truck Rack', strAddress = '4731 Viking Drive', strCity = 'Bossier City', dtmApprovedDate = NULL, strZip = '71111', intMasterId = 18990
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2395', strName = 'John W Stone Oil Distributor', strAddress = '87 1st Street', strCity = 'Gretna', dtmApprovedDate = NULL, strZip = '70053', intMasterId = 18991
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2397', strName = 'Five Star Fuels ', strAddress = '163 Gordy Rd', strCity = 'Baldwin', dtmApprovedDate = NULL, strZip = '70514', intMasterId = 18992
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2399', strName = 'Stolthaven New Orleans LLC', strAddress = '2444 English Turn Road', strCity = 'Braithwaite', dtmApprovedDate = NULL, strZip = '70040', intMasterId = 18993
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2400', strName = 'IMTT - Avondale', strAddress = '5450 River Road', strCity = 'Avondale', dtmApprovedDate = NULL, strZip = '70094', intMasterId = 18994
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2401', strName = 'IMTT - Gretna', strAddress = '1145 4th ST ', strCity = 'Harvey', dtmApprovedDate = NULL, strZip = '70058', intMasterId = 18995
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2402', strName = 'REG Geismar LLC', strAddress = '36187 Hwy 30', strCity = 'Geismer', dtmApprovedDate = NULL, strZip = '70734', intMasterId = 18996
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2403', strName = 'Martin Operating Partnership, L.P.', strAddress = '2254 S Talens Landing Rd ', strCity = 'Gueydan', dtmApprovedDate = NULL, strZip = '70542', intMasterId = 18997
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2408', strName = 'Valero Refining - New Orleans', strAddress = '14902 River Road ', strCity = 'Norco', dtmApprovedDate = NULL, strZip = '70087', intMasterId = 181001
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2412', strName = 'Martin Operating Partnership, L.P.', strAddress = '141 Offshore Lane ', strCity = 'Amelia', dtmApprovedDate = NULL, strZip = '70340', intMasterId = 181004
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2417', strName = 'Diamond Green Diesel LLC', strAddress = '14891 Airline Drive ', strCity = 'Norco', dtmApprovedDate = NULL, strZip = '70079', intMasterId = 181009
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2418', strName = 'Marathon Garyville Refinery Rack', strAddress = '155 Sugarcane Road', strCity = 'Garyville', dtmApprovedDate = NULL, strZip = '70051', intMasterId = 181573
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2419', strName = 'Retif Oil & Fuel - Harvey', strAddress = '527 Destrehan Ave', strCity = 'Harvey', dtmApprovedDate = NULL, strZip = '70058', intMasterId = 181574
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2420', strName = 'Martin Operating Partnership, L.P.', strAddress = '118 N Doucet Drive', strCity = 'Fourchon', dtmApprovedDate = NULL, strZip = '70357', intMasterId = 181575
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2421', strName = 'Alexandria Terminal Company', strAddress = '501 River Port Rd', strCity = 'Alexandria', dtmApprovedDate = NULL, strZip = '71301', intMasterId = 181576
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2356', strName = 'Aircraft Service International, Inc.', strAddress = 'Freight Road', strCity = 'Kenner', dtmApprovedDate = NULL, strZip = '70062', intMasterId = 181577
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2423', strName = 'Mt Airy Terminal', strAddress = '4006 Highway 44', strCity = 'Mt Airy', dtmApprovedDate = NULL, strZip = '70076', intMasterId = 181578
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72LA2422', strName = 'Kinder Morgan/Delta Terminal Services', strAddress = '3450 River Rd', strCity = 'Harvey', dtmApprovedDate = NULL, strZip = '70058', intMasterId = 181579


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'LA', @TerminalControlNumbers = @TerminalLA

DELETE @TerminalLA

-- MA Terminals
PRINT ('Deploying MA Terminal Control Number')
DECLARE @TerminalMA AS TFTerminalControlNumbers

INSERT INTO @TerminalMA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1151', strName = 'Sprague Operating Resources LLC - Springfield', strAddress = '615 St James Ave', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01109-', intMasterId = 211986
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1152', strName = 'Global Companies LLC', strAddress = '11 Broadway', strCity = 'Chelsea', dtmApprovedDate = NULL, strZip = '02150', intMasterId = 211987
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1153', strName = 'Gulf Oil LP - Chelsea', strAddress = '281 Eastern Ave.', strCity = 'Chelsea', dtmApprovedDate = NULL, strZip = '02150-', intMasterId = 211988
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1154', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '467 Chelsea Street', strCity = 'East Boston', dtmApprovedDate = NULL, strZip = '02128-', intMasterId = 211989
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1155', strName = 'CITGO Petroleum Corporation', strAddress = '385 Quincy Ave', strCity = 'Braintree', dtmApprovedDate = NULL, strZip = '02184-', intMasterId = 211990
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1156', strName = 'ExxonMobil Oil Corp.', strAddress = '52 Beacham Street', strCity = 'Everett', dtmApprovedDate = NULL, strZip = '02149-', intMasterId = 211991
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1158', strName = 'Roberts Energy', strAddress = '275 Albany Street', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01105', intMasterId = 211992
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1159', strName = 'Springfield Terminals, Inc.', strAddress = '1095 Page Blvd.', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01104', intMasterId = 211993
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1160', strName = 'Irving Oil Terminals, Inc.', strAddress = '41 Lee Burbank Highway', strCity = 'Revere', dtmApprovedDate = NULL, strZip = '02151-', intMasterId = 211994
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1162', strName = 'Global Companies LLC', strAddress = '140 Lee Burbank Hwy', strCity = 'Revere', dtmApprovedDate = NULL, strZip = '02454', intMasterId = 211995
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1164', strName = 'Global Companies LLC', strAddress = '3 Coast Guard Road', strCity = 'Sandwich', dtmApprovedDate = NULL, strZip = '02563-', intMasterId = 211996
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1166', strName = 'Global Companies LLC', strAddress = '160 Rocus St.', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01104-', intMasterId = 211997
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1167', strName = 'Sprague Operating Resources LLC - Springfield', strAddress = '195 Armory St.', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01105', intMasterId = 211998
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1168', strName = 'Buckeye Terminals, LLC - Springfield', strAddress = '145 Albany Street', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01105-', intMasterId = 211999
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1171', strName = 'Swissport Fueling, Inc.', strAddress = 'Boston Logan Intl Airport', strCity = 'East Boston', dtmApprovedDate = NULL, strZip = '02128', intMasterId = 212000
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1172', strName = 'Sprague Operating Resources LLC - New Bedford', strAddress = '30 Pine St.', strCity = 'New Bedford', dtmApprovedDate = NULL, strZip = '02740-', intMasterId = 212001
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1173', strName = 'Harbor Fuel Oil Corp.', strAddress = 'New Whale St', strCity = 'Nantucket', dtmApprovedDate = NULL, strZip = '02554-', intMasterId = 212002
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1174', strName = 'Albany Street Terminals LLC', strAddress = '167 Albany Street', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01105-', intMasterId = 212003
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1176', strName = 'Sprague Operating Resources LLC - Quincy', strAddress = '728 Southern Artery', strCity = 'Quincy', dtmApprovedDate = NULL, strZip = '02169', intMasterId = 212004
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1179', strName = 'Springfield Terminals, Inc.', strAddress = '1053 Page Blvd.', strCity = 'Springfield', dtmApprovedDate = NULL, strZip = '01104-1697', intMasterId = 212005
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1180', strName = 'Sprague Operating Resources LLC - Quincy', strAddress = '740 Washington St.', strCity = 'Quincy', dtmApprovedDate = NULL, strZip = '02169-7333', intMasterId = 212006
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T04MA1183', strName = 'Buckeye Pipe Line Company LP', strAddress = '39A Tank Farm Rd', strCity = 'Ludlow', dtmApprovedDate = NULL, strZip = '01056', intMasterId = 212008

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MA' , @TerminalControlNumbers = @TerminalMA

DELETE @TerminalMA

-- MD Terminals
PRINT ('Deploying MD Terminal Control Number')
DECLARE @TerminalMD AS TFTerminalControlNumbers

INSERT INTO @TerminalMD(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1550', strName = 'Buckeye Terminals, LLC - Baltimore', strAddress = '6200 Pennington Avenue', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226', intMasterId = 202009
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1551', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '801 East Ordance Rd', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226', intMasterId = 202010
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1552', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '2155 Northbridge Ave', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226-', intMasterId = 202011
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1554', strName = 'Petroleum Fuel & Terminal - Baltimore No', strAddress = '5101 Erdman Avenue', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21205-', intMasterId = 202012
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1559', strName = 'Petroleum Fuel & Terminal - Baltimore So', strAddress = '1622 South Clinton Street', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21224-', intMasterId = 202013
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1560', strName = 'NuStar Terminals Operations Partnership L.P. - Baltimore', strAddress = '1800 Frankfurst Avenue', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226-1024', intMasterId = 202014
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1561', strName = 'Motiva Enterprises LLC East', strAddress = '2400 Petrolia Ave.', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226-', intMasterId = 202015
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1562', strName = 'CITGO - Baltimore', strAddress = '2201 Southport Ave.', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226-', intMasterId = 202016
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1563', strName = 'Center Point Terminal - Baltimore West', strAddress = '3100 Vera Street', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21226-', intMasterId = 202017
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1565', strName = 'NuStar Terminals Operations Partnership L. P. - Piney Point', strAddress = '17877 Piney Point Road', strCity = 'Piney Point', dtmApprovedDate = NULL, strZip = '20674-', intMasterId = 202018
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1567', strName = 'CATO, Inc.', strAddress = '1030 Marine Road', strCity = 'Salisbury', dtmApprovedDate = NULL, strZip = '21801-1030', intMasterId = 202019
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1568', strName = 'Center Point Terminal - Salisbury', strAddress = '1134 Marine Road', strCity = 'Salisbury', dtmApprovedDate = NULL, strZip = '21801-', intMasterId = 202020
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T52MD1569', strName = 'Aircraft Service International, Inc.', strAddress = 'Balto/Wash. Airport', strCity = 'Baltimore', dtmApprovedDate = NULL, strZip = '21240', intMasterId = 202021


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MD' , @TerminalControlNumbers = @TerminalMD

DELETE @TerminalMD

-- ME Terminals
PRINT ('Deploying ME Terminal Control Number')
DECLARE @TerminalME AS TFTerminalControlNumbers

INSERT INTO @TerminalME(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1000', strName = 'Buckeye Terminals, LLC - Bangor', strAddress = '730 Lower Main Street', strCity = 'Bangor', dtmApprovedDate = NULL, strZip = '04401-', intMasterId = 192021
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1002', strName = 'Coldbrook Energy, Inc.', strAddress = '809 Main Road No', strCity = 'Hampden', dtmApprovedDate = NULL, strZip = '04444-', intMasterId = 192022
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1003', strName = 'Sprague Operating Resources LLC - So. Portland', strAddress = '59 Main Street', strCity = 'South Portland', dtmApprovedDate = NULL, strZip = '04106-', intMasterId = 192023
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1004', strName = 'Buckeye Development & Logistics II LLC', strAddress = '170 Lincoln Street', strCity = 'South Portland', dtmApprovedDate = NULL, strZip = '04106-', intMasterId = 192024
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1006', strName = 'Irving Oil Terminals, Inc', strAddress = 'Station Ave', strCity = 'Searsport', dtmApprovedDate = NULL, strZip = '04974-', intMasterId = 192025
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1008', strName = 'Gulf Oil LP - South Portland', strAddress = '175 Front St', strCity = 'South Portland', dtmApprovedDate = NULL, strZip = '04106-', intMasterId = 192026
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1009', strName = 'Global Companies LLC', strAddress = 'One Clarks Road', strCity = 'South Portland', dtmApprovedDate = NULL, strZip = '04106-', intMasterId = 192027
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1010', strName = 'CITGO - South Portland', strAddress = '102 Mechanic Street', strCity = 'South Portland', dtmApprovedDate = NULL, strZip = '04106-2828', intMasterId = 192028
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1012', strName = 'Webber Tanks, Inc. - Bucksport', strAddress = 'Drawer CC River Road', strCity = 'Bucksport', dtmApprovedDate = NULL, strZip = '04416-', intMasterId = 192029
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T01ME1015', strName = 'Sprague Operating Resources LLC - Mack Point', strAddress = '70 Trundy Road', strCity = 'Searsport', dtmApprovedDate = NULL, strZip = '04974', intMasterId = 192030

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'ME' , @TerminalControlNumbers = @TerminalME

DELETE @TerminalME

-- MI Terminals
PRINT ('Deploying MI Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3001', strName = 'U.S. Oil - Cheboygan', strAddress = '311 Coast Guard Drive', strCity = 'Cheyboygan', dtmApprovedDate = NULL, strZip = '49721', intMasterId = 22455
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3002', strName = 'U.S. Oil - Rogers City', strAddress = '1035 Calcite Rd.', strCity = 'Rogers City', dtmApprovedDate = NULL, strZip = '49779', intMasterId = 22456
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3003', strName = 'Waterfront Petroleum Terminal Co.', strAddress = '1071 Miller Rd.', strCity = 'Dearborn', dtmApprovedDate = NULL, strZip = '48120', intMasterId = 22457
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3004', strName = 'Buckeye Terminals, LLC - Napoleon', strAddress = '6777 Brooklyn Road', strCity = 'Napoleon', dtmApprovedDate = NULL, strZip = '49261', intMasterId = 22458
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3005', strName = 'Buckeye Terminals, LLC - River Rouge', strAddress = '205 Marion Street', strCity = 'River Rouge', dtmApprovedDate = NULL, strZip = '48218', intMasterId = 22459
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3006', strName = 'Buckeye Terminals, LLC - Dearborn', strAddress = '8503 South Inkster Rd.', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180-2114', intMasterId = 22460
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3007', strName = 'Buckeye Pipe Line Holdings, L.P - Taylor', strAddress = '24801 Ecorse Rd', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180', intMasterId = 22461
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3008', strName = 'CITGO - Ferrysburg', strAddress = '524 Third Street', strCity = 'Ferrysburg', dtmApprovedDate = NULL, strZip = '49409', intMasterId = 22462
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3009', strName = 'CITGO - Jackson', strAddress = '2001 Morrill Rd', strCity = 'Jackson', dtmApprovedDate = NULL, strZip = '49201', intMasterId = 22463
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3010', strName = 'CITGO - Niles', strAddress = '2233 South Third', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22464
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3011', strName = 'Marathon Niles', strAddress = '2140 South Third St.', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22465
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3012', strName = 'Cousins Petroleum - Taylor', strAddress = '7965 Holland', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180', intMasterId = 22466
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3013', strName = 'Buckeye Terminals, LLC - Ferrysburg', strAddress = '17806 North Shore Dr.', strCity = 'Ferrysburg', dtmApprovedDate = NULL, strZip = '49409', intMasterId = 22467
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3014', strName = 'Buckeye Terminals, LLC - Taylor East', strAddress = '24501 Ecorse Rd', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '48180', intMasterId = 22468
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3015', strName = 'Marathon Detroit', strAddress = '12700 Toronto St.', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 22469
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3016', strName = 'Marathon Flint', strAddress = '6065 North Dort Highway', strCity = 'Mt. Morris', dtmApprovedDate = NULL, strZip = '48458', intMasterId = 22470
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3017', strName = 'Marathon Jackson', strAddress = '2090 Morrill Rd', strCity = 'Jackson', dtmApprovedDate = NULL, strZip = '49201-8238', intMasterId = 22471
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3018', strName = 'Delta Fuel Facility - DTW Metro', strAddress = 'West. Service Rd.', strCity = 'Romulus', dtmApprovedDate = NULL, strZip = '48174', intMasterId = 22472
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3019', strName = 'Marathon Oil Niles', strAddress = '2216 South Third Street', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120-4010', intMasterId = 22473
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3020', strName = 'Marathon N. Muskegon', strAddress = '3005 Holton Rd', strCity = 'North Muskegon', dtmApprovedDate = NULL, strZip = '49445-2513', intMasterId = 22474
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3022', strName = 'Buckeye Terminals, LLC - Flint', strAddress = 'G5340 North Dort Highway', strCity = 'Flint', dtmApprovedDate = NULL, strZip = '48505', intMasterId = 22475
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3023', strName = 'Buckeye Terminals, LLC - Niles West', strAddress = '2150 South Third Street', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22476
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3024', strName = 'Buckeye Terminals, LLC - Woodhaven', strAddress = '20755 West Road', strCity = 'Woodhaven', dtmApprovedDate = NULL, strZip = '48183-', intMasterId = 22477
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3025', strName = 'Buckeye Terminals, LLC - Detroit', strAddress = '700 S. Deacon Street', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 22478
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3028', strName = 'Buckeye Terminals, LLC - Niles', strAddress = '2303 South Third Street', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '49120', intMasterId = 22479
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3029', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4004 West Main Rd', strCity = 'Owosso', dtmApprovedDate = NULL, strZip = '48867', intMasterId = 22480
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3030', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '500 South Dix Avenue', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 22481
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3032', strName = 'Marathon Bay City', strAddress = '1806 Marquette', strCity = 'Bay City', dtmApprovedDate = NULL, strZip = '48706', intMasterId = 22482
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3033', strName = 'Marathon Lansing', strAddress = '6300 West Grand River', strCity = 'Lansing', dtmApprovedDate = NULL, strZip = '48906', intMasterId = 22483
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3034', strName = 'Marathon Romulus', strAddress = '28001 Citrin Drive', strCity = 'Romulus', dtmApprovedDate = NULL, strZip = '48174', intMasterId = 22484
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3037', strName = 'Sonoco Partners Marketing & Terminals LP', strAddress = '29120 Wick Road', strCity = 'Romulus', dtmApprovedDate = NULL, strZip = '48174', intMasterId = 22485
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3039', strName = 'Delta Fuels of Michigan', strAddress = '40600 Grand River', strCity = 'Novi', dtmApprovedDate = NULL, strZip = '48374', intMasterId = 22486
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3041', strName = 'Holland Terminal, Inc.', strAddress = '630 Ottawa Avenue', strCity = 'Holland', dtmApprovedDate = NULL, strZip = '49423', intMasterId = 22487
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3043', strName = 'Buckeye Terminals, LLC - Marshall', strAddress = '12451 Old US 27 South', strCity = 'Marshall', dtmApprovedDate = NULL, strZip = '49068', intMasterId = 22488
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3046', strName = 'Marysville Hydrocarbons', strAddress = '2510 Busha Highway', strCity = 'Marysville', dtmApprovedDate = NULL, strZip = '48040', intMasterId = 22489
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3047', strName = 'Waterfront Petroleum Terminal Co.', strAddress = '5431 W Jefferson', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48209', intMasterId = 22490
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3048', strName = 'Plains LPG Services LP', strAddress = '1575 Fred Moore Hwy', strCity = 'St Clair', dtmApprovedDate = NULL, strZip = '48079', intMasterId = 22491
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T38MI3049', strName = 'Marathon Detroit Refinery Rack', strAddress = '1300 S Fort St', strCity = 'Detroit', dtmApprovedDate = NULL, strZip = '48217', intMasterId = 221581

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MI', @TerminalControlNumbers = @TerminalMI

DELETE @TerminalMI

-- MN Terminals
PRINT ('Deploying MN Terminal Control Number')
DECLARE @TerminalMN AS TFTerminalControlNumbers

INSERT INTO @TerminalMN(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3400', strName = 'NuStar Pipeline Operating Partnership, L.P. - Moorhead', strAddress = '1101 SE Main Avenue', strCity = 'Moorhead', dtmApprovedDate = NULL, strZip = '56560', intMasterId = 232051
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3401', strName = 'NuStar Pipeline Operating Partnership, L.P. - Sauk Centre', strAddress = '1833 Beltline Rd', strCity = 'Sauk Centre', dtmApprovedDate = NULL, strZip = '56378', intMasterId = 232052
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3402', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '14514 State Highway 16', strCity = 'Spring Valley', dtmApprovedDate = NULL, strZip = '55975', intMasterId = 232053
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3403', strName = 'NuStar Pipeline Operating Partnership, L.P. - Roseville', strAddress = '2288 West County Road C', strCity = 'Roseville', dtmApprovedDate = NULL, strZip = '55113', intMasterId = 232054
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3404', strName = 'Western Refining - St. Paul Park', strAddress = '201 Factory Street', strCity = 'St. Paul Park', dtmApprovedDate = NULL, strZip = '55071', intMasterId = 232055
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3405', strName = 'Magellan Pipeline Company, L.P.', strAddress = '10 Broadway Street', strCity = 'Wrenshall', dtmApprovedDate = NULL, strZip = '55797', intMasterId = 232056
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3406', strName = 'Newport Terminal Corporation', strAddress = '50 21st St', strCity = 'Newport', dtmApprovedDate = NULL, strZip = '55055', intMasterId = 232057
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3407', strName = 'Flint Hills Resources, LP-Pine Bend', strAddress = '13775 Clark Rd - Gate 1', strCity = 'Rosemount', dtmApprovedDate = NULL, strZip = '55068', intMasterId = 232058
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3410', strName = 'Superior Refining Company LLC', strAddress = '5746 Old Hwy 61', strCity = 'Proctor', dtmApprovedDate = NULL, strZip = '55810', intMasterId = 232059
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3412', strName = 'Magellan Pipeline Company, L.P.', strAddress = '709 Third Ave W', strCity = 'Alexandria', dtmApprovedDate = NULL, strZip = '56308', intMasterId = 232060
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3413', strName = 'Magellan Pipeline Company, L.P.', strAddress = '55199 State Hwy 68', strCity = 'Mankato', dtmApprovedDate = NULL, strZip = '56001', intMasterId = 232061
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3414', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1601 College Dr', strCity = 'Marshall', dtmApprovedDate = NULL, strZip = '56258', intMasterId = 232062
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3415', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2451 W County Rd C', strCity = 'St Paul', dtmApprovedDate = NULL, strZip = '55113', intMasterId = 232063
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3416', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1331 Hwy 42 Southeast', strCity = 'Eyota', dtmApprovedDate = NULL, strZip = '55934', intMasterId = 232064
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3417', strName = 'BNSF - Northtown', strAddress = '80-44th Ave, N.E.', strCity = 'Minneapolis', dtmApprovedDate = NULL, strZip = '55421', intMasterId = 232065
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3419', strName = 'Swissport Fueling Inc', strAddress = '5001 Post Road', strCity = 'Minneapolis', dtmApprovedDate = NULL, strZip = '55450', intMasterId = 232066
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3420', strName = 'Signature Flight Support Corp.', strAddress = '3800 East 70th St.', strCity = 'Minneapolis', dtmApprovedDate = NULL, strZip = '55450', intMasterId = 232067
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3426', strName = 'NGL Supply Terminal Company LLC - Rosemount', strAddress = '15938 Canada Circle Drive', strCity = 'Rosemount', dtmApprovedDate = NULL, strZip = '55068', intMasterId = 232068

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MN' , @TerminalControlNumbers = @TerminalMN

DELETE @TerminalMN

-- MO Terminals
PRINT ('Deploying MO Terminal Control Number')
DECLARE @TerminalMO AS TFTerminalControlNumbers

INSERT INTO @TerminalMO(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3701', strName = 'J D Streett - St. Louis', strAddress = '3800 S. 1st St.', strCity = 'St. Louis', dtmApprovedDate = NULL, strZip = '63118-', intMasterId = 252069
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3703', strName = 'Ayers Oil Company - Canton', strAddress = 'Fourth & Grant', strCity = 'Canton', dtmApprovedDate = NULL, strZip = '63435-', intMasterId = 252070
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3704', strName = 'TransMontaigne - Cape Girardeau', strAddress = '1400 S Giboney', strCity = 'Cape Girardeau', dtmApprovedDate = NULL, strZip = '63701-0704', intMasterId = 252071
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3705', strName = 'ERPC Cape Girardeau', strAddress = 'Rural Route 2, Hwy N', strCity = 'Scott City', dtmApprovedDate = NULL, strZip = '63780-', intMasterId = 252072
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3707', strName = 'Magellan Pipeline Company, L.P.', strAddress = '18195 County Rd 138', strCity = 'Jasper', dtmApprovedDate = NULL, strZip = '64755-', intMasterId = 252073
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3708', strName = 'Magellan Pipeline Company, L.P.', strAddress = '5531 South Hwy 63', strCity = 'Columbia', dtmApprovedDate = NULL, strZip = '65201-', intMasterId = 252074
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3709', strName = 'Phillips 66 PL - Jefferson City', strAddress = '2116 Idlewood', strCity = 'Jefferson City', dtmApprovedDate = NULL, strZip = '65109-', intMasterId = 252075
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3713', strName = 'Phillips 66 PL - Mount Vernon', strAddress = 'Rt. 2 Box 115', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '65712-', intMasterId = 252076
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3714', strName = 'American River Trans. Co., North', strAddress = '3854 South 1st. St.', strCity = 'St. Louis', dtmApprovedDate = NULL, strZip = '63118', intMasterId = 252077
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3716', strName = 'Magellan Pipeline Company, L.P.', strAddress = '66789 County Road 312', strCity = 'Palmyra', dtmApprovedDate = NULL, strZip = '63461-', intMasterId = 252078
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3718', strName = 'Magellan Pipeline Company, L.P.', strAddress = '3132 S State Hwy MM', strCity = 'Brookline', dtmApprovedDate = NULL, strZip = '65619-', intMasterId = 252079
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3720', strName = 'Buckeye Tank Terminals LLC - Sugar Creek', strAddress = '1315 North Sterling', strCity = 'Sugar Creek', dtmApprovedDate = NULL, strZip = '64054-0507', intMasterId = 252080
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3721', strName = 'Magellan Terminals Holdings LP', strAddress = '4695 South Service Road', strCity = 'St Peter', dtmApprovedDate = NULL, strZip = '63376-', intMasterId = 252081
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3722', strName = 'Swissport SA Fuel Services', strAddress = '10735 Old Natural Bridge', strCity = 'St. Louis', dtmApprovedDate = NULL, strZip = '63145', intMasterId = 252082
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3723', strName = 'Allied Aviation Service of Kansas City', strAddress = '217 Bern Street', strCity = 'Kansas City', dtmApprovedDate = NULL, strZip = '64153', intMasterId = 252083
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3725', strName = 'Buckeye Terminals, LLC - St. Louis North', strAddress = '239 East Prairie St.', strCity = 'St. Louis', dtmApprovedDate = NULL, strZip = '63147-', intMasterId = 252084
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3726', strName = 'Kinder Morgan Transmix Co., LLC', strAddress = '4070 South First Street', strCity = 'St Louis', dtmApprovedDate = NULL, strZip = '63118-', intMasterId = 252085
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3727', strName = 'TransMontaigne - Mt Vernon', strAddress = '15376 Hwy 96', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '65712', intMasterId = 252086
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3728', strName = 'Sinclair Transport.- East Carrollton, MO', strAddress = 'RR4, Box 48', strCity = 'Carrollton', dtmApprovedDate = NULL, strZip = '64633-0000', intMasterId = 252087
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T43MO3729', strName = 'Oakmar Terminal', strAddress = '2353 N State Hwy D', strCity = 'Hayti', dtmApprovedDate = NULL, strZip = '63851', intMasterId = 252088

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MO' , @TerminalControlNumbers = @TerminalMO

DELETE @TerminalMO

-- MS Terminals
PRINT ('Deploying MS Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T59MS0001', strName = 'Scott Petroleum Corporation', strAddress = '942 N. Broadway', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701', intMasterId = 24852
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2401', strName = 'Chevron USA, Inc.- Collins', strAddress = 'Old Highway 49 South', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24853
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2402', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '31 Kola Road', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24854
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2404', strName = 'Motiva Enterprises LLC', strAddress = '49 So. & Kola Rd.', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24855
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2405', strName = 'TransMontaigne - Collins', strAddress = 'First Avenue South', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428-', intMasterId = 24856
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2406', strName = 'Transmontaigne - Greenville- S', strAddress = '310 Walthall Street', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24857
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2408', strName = 'TransMontaigne - Greenville - N', strAddress = '208 Short Clay Street', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24858
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2411', strName = 'MGC Terminals', strAddress = '101 65th Avenue', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39301-', intMasterId = 24859
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2412', strName = 'CITGO - Meridian', strAddress = '180 65th Avenue', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39305-', intMasterId = 24860
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2414', strName = 'Murphy Oil USA, Inc. - Meridian', strAddress = '6540 N. Frontage Rd.', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39301-', intMasterId = 24861
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2415', strName = 'TransMontaigne - Meridian', strAddress = '1401 65th Ave S', strCity = 'Meridian', dtmApprovedDate = NULL, strZip = '39307-', intMasterId = 24862
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2416', strName = 'Chevron USA, Inc.- Pascagoula', strAddress = 'Industrial Road State Hwy 611', strCity = 'Pascagoula', dtmApprovedDate = NULL, strZip = '39568-1300', intMasterId = 24863
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2418', strName = 'Hunt-Southland Refining Co', strAddress = '2 mi N on Hwy 11 PO Drawer A', strCity = 'Sandersville', dtmApprovedDate = NULL, strZip = '39477-', intMasterId = 24864
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2419', strName = 'CITGO - Vicksburg', strAddress = '1585 Haining Rd', strCity = 'Vicksburg', dtmApprovedDate = NULL, strZip = '39180-', intMasterId = 24865
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2423', strName = 'Lone Star NGL Hattiesburg LLC', strAddress = '1234 Highway 11', strCity = 'Petal', dtmApprovedDate = NULL, strZip = '39465', intMasterId = 24866
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2424', strName = 'Hunt Southland Refining Company', strAddress = '2600 Dorsey Street', strCity = 'Vicksburg', dtmApprovedDate = NULL, strZip = '39180', intMasterId = 24867
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72MS2420', strName = 'Martin Operating Partnership, L.P.', strAddress = '5320 Ingalls Ave.', strCity = 'Pascagoula', dtmApprovedDate = NULL, strZip = '39581', intMasterId = 24869
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72MS2421', strName = 'Delta Terminal, Inc.', strAddress = '2181 Harbor Front', strCity = 'Greenville', dtmApprovedDate = NULL, strZip = '38701-', intMasterId = 24870
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72MS2422', strName = 'ERPC Aberdeen ', strAddress = '20096 Norm Connell Drive', strCity = 'Aberdeen', dtmApprovedDate = NULL, strZip = '39730', intMasterId = 24871
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2426', strName = 'Colonial Pipeline Company - Collins', strAddress = '35 Pump Station Rd', strCity = 'Collins', dtmApprovedDate = NULL, strZip = '39428', intMasterId = 24872
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T64MS2427', strName = 'Lincoln Terminal Company', strAddress = '125 LE Barry Road', strCity = 'Natchez', dtmApprovedDate = NULL, strZip = '39120', intMasterId = 24873


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MS', @TerminalControlNumbers = @TerminalMS

DELETE @TerminalMS

-- MT Terminals
PRINT ('Deploying MT Terminal Control Number')
DECLARE @TerminalMT AS TFTerminalControlNumbers

INSERT INTO @TerminalMT(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MT0001', strName = 'CHS Petroleum Terminal - Missoula', strAddress = '3576 Grand Creek Road', strCity = 'Missoula', dtmApprovedDate = NULL, strZip = '59808', intMasterId = 262089
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4000', strName = 'Phillips 66 PL - Billings', strAddress = '23rd & Fourth Ave South', strCity = 'Billings', dtmApprovedDate = NULL, strZip = '59107-', intMasterId = 262090
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4001', strName = 'Phillips 66 PL - Bozeman', strAddress = '318 West Griffin Drive', strCity = 'Bozeman', dtmApprovedDate = NULL, strZip = '59715', intMasterId = 262091
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4002', strName = 'Phillips 66 PL - Great Falls', strAddress = '1401 52nd N', strCity = 'Great Falls', dtmApprovedDate = NULL, strZip = '59405-', intMasterId = 262092
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4003', strName = 'Phillips 66 PL - Helena', strAddress = '3180 Highway 12 East', strCity = 'Helena', dtmApprovedDate = NULL, strZip = '59601', intMasterId = 262093
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4004', strName = 'Phillips 66 PL - Missoula', strAddress = '3330 Raser Drive', strCity = 'Missoula', dtmApprovedDate = NULL, strZip = '59802-', intMasterId = 262094
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4005', strName = 'CHS Petroleum Terminal - Laurel', strAddress = '803 Hwy 212 South', strCity = 'Laurel', dtmApprovedDate = NULL, strZip = '59044', intMasterId = 262095
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4006', strName = 'CHS Petroleum Terminal - Glendive', strAddress = 'P O Box 240', strCity = 'Glendive', dtmApprovedDate = NULL, strZip = '59330-', intMasterId = 262096
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4007', strName = 'ExxonMobil Oil Corp.', strAddress = '607 Exxon Rd.', strCity = 'Billings', dtmApprovedDate = NULL, strZip = '59101-', intMasterId = 262097
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4008', strName = 'ExxonMobil Oil Corp.', strAddress = '220 West Griffin Drive', strCity = 'Bozeman', dtmApprovedDate = NULL, strZip = '59715', intMasterId = 262098
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4009', strName = 'ExxonMobil Oil Corp.', strAddress = '3120 Highway 12 East', strCity = 'Helena', dtmApprovedDate = NULL, strZip = '59601-', intMasterId = 262099
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4011', strName = 'Calumet Montana Refining LLC', strAddress = '1900 10th Street', strCity = 'Great Falls', dtmApprovedDate = NULL, strZip = '59403', intMasterId = 262100
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4013', strName = 'Montana Rail Link Inc', strAddress = '1001 Defoe St.', strCity = 'Missoula', dtmApprovedDate = NULL, strZip = '59808', intMasterId = 262101
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T81MT4014', strName = 'Montana Rail Link Inc', strAddress = '1923 Shannon Road', strCity = 'Laurel', dtmApprovedDate = NULL, strZip = '59044', intMasterId = 262102
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T30MT0001', strName = 'Oneok Rockies Midstream LLC', strAddress = '34958 County Road 122', strCity = 'Sidney', dtmApprovedDate = NULL, strZip = '59270', intMasterId = 262103


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'MT' , @TerminalControlNumbers = @TerminalMT

DELETE @TerminalMT

-- NC Terminals
PRINT ('Deploying NC Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2000', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '6801 Freedom Dr', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33712
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2001', strName = 'CITGO - Charlotte', strAddress = '7600 Mount Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214-', intMasterId = 33713
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2002', strName = 'Marathon Oil Charlotte', strAddress = '8035 Mt. Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28130', intMasterId = 33714
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2003', strName = 'Eco-Energy', strAddress = '7720 Mr. Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33715
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2004', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '502 Tom Sadler Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33716
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2005', strName = 'Motiva Enterprises LLC', strAddress = '6851 Freedom Dr.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33717
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2006', strName = 'Magellan Terminals Holdings LP', strAddress = '7145 Mount Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33718
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2007', strName = 'Motiva Enterprises LLC', strAddress = '410 Tom Sadler Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33719
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2008', strName = 'Marathon Charlotte (East)', strAddress = '7401 Old Mount Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214-', intMasterId = 33720
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2009', strName = 'Motiva Enterprises LLC', strAddress = '992 Shaw Mill Road', strCity = 'Fayetteville', dtmApprovedDate = NULL, strZip = '28311-', intMasterId = 33721
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2011', strName = 'Magellan Terminals Holdings LP', strAddress = '7109 West Market Street', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409', intMasterId = 33722
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2013', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '2101 West Oak St.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576', intMasterId = 33723
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2014', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '6907 West Market Street', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33724
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2015', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '6376 Burnt Poplar Rd', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33725
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2018', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '2200 West Oak St.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33726
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2019', strName = 'Center Point Terminal - Greensboro', strAddress = '6900 West Market St', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33727
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2020', strName = 'Magellan Terminals Holdings LP', strAddress = '115 Chimney Rock Road', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-9661', intMasterId = 33728
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2021', strName = 'Motiva Enterprises LLC', strAddress = '101 S. Chimney Rock Rd.', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409', intMasterId = 33729
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2022', strName = 'TransMontaigne - Greensboro', strAddress = '6801 West Market Street', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409-', intMasterId = 33730
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2023', strName = 'TransMontaigne - Charlotte/Paw Creek', strAddress = '7615 Old Mount Holly Road', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214-', intMasterId = 33731
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2024', strName = 'Magellan Terminals Holdings LP', strAddress = '7924 Mt. Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33732
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2025', strName = 'Arc Terminals Holdings LLC', strAddress = '2999 W. Oak St.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33733
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2026', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '7325 Old Mount Holly Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28214', intMasterId = 33734
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2027', strName = 'Motiva Enterprises LLC', strAddress = '2232 Ten-Ten.  Road', strCity = 'Apex', dtmApprovedDate = NULL, strZip = '27502-', intMasterId = 33735
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2028', strName = 'TransMontaigne - Selma - N', strAddress = '2600 W. Oak St. (SSR 1929)', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33736
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2029', strName = 'Marathon Selma', strAddress = '3707 Buffalo Road', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33737
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2030', strName = 'CITGO - Selma', strAddress = '4095 Buffalo Rd', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33738
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2031', strName = 'Marathon Selma', strAddress = '2555 West Oak Street', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33739
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2033', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4383 Buffalo Rd.', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33741
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2034', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4086 Buffalo Road', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33742
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2036', strName = 'Magellan Terminals Holdings LP', strAddress = '4414 Buffalo Road', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576-', intMasterId = 33743
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2037', strName = 'Buckeye Terminals, LLC - Wilmington', strAddress = '1312 S Front St.', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28401-', intMasterId = 33744
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2038', strName = 'Piedmont Aviation Services, Inc.', strAddress = '6427 Bryan Blvd.', strCity = 'Greensboro', dtmApprovedDate = NULL, strZip = '27409', intMasterId = 33745
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2043', strName = 'Apex Oil Company', strAddress = '3314 River Road', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28403-', intMasterId = 33746
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2044', strName = 'Kinder Morgan Terminals Wilmington LLC', strAddress = '1710 Woodbine St.', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28402', intMasterId = 33747
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2045', strName = 'Raleigh-Durham Airport Authority', strAddress = '2800 W. Terminal Blvd.', strCity = 'Morrisville', dtmApprovedDate = NULL, strZip = '27560', intMasterId = 33748
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2039', strName = 'CTI of North Carolina Inc', strAddress = '1002 S Front Street', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28402', intMasterId = 331582
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2046', strName = 'Colonial Pipeline Company - Selma', strAddress = '2335 W Oak St', strCity = 'Selma', dtmApprovedDate = NULL, strZip = '27576', intMasterId = 331583
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2047', strName = 'Kinder Morgan Terminals Wilmington LLC', strAddress = '3340 River Rd', strCity = 'Wilmington', dtmApprovedDate = NULL, strZip = '28412', intMasterId = 331584
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T56NC2032', strName = 'Aircraft Service International, Inc.', strAddress = '6502 Old Dowd Rd.', strCity = 'Charlotte', dtmApprovedDate = NULL, strZip = '28219', intMasterId = 331585


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NC', @TerminalControlNumbers = @TerminalNC

DELETE @TerminalNC

-- ND Terminals
PRINT ('Deploying ND Terminal Control Number')
DECLARE @TerminalND AS TFTerminalControlNumbers

INSERT INTO @TerminalND(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3500', strName = 'Magellan Pipeline Company, L.P.', strAddress = '3930 Gateway Drive', strCity = 'Grand Forks', dtmApprovedDate = NULL, strZip = '58203', intMasterId = 342103
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3501', strName = 'Magellan Pipeline Company, L.P.', strAddress = '902 Main Avenue East', strCity = 'West Fargo', dtmApprovedDate = NULL, strZip = '58078', intMasterId = 342104
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3502', strName = 'NuStar Pipeline Operating Partnership, L.P. - Jamestown', strAddress = '3598 74th Avenue SE', strCity = 'Jamestown', dtmApprovedDate = NULL, strZip = '58401', intMasterId = 342105
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3503', strName = 'NuStar Pipeline Operating Partnership, L.P. - Jamestown', strAddress = '3790 Hwy 281 SE', strCity = 'Jamestown', dtmApprovedDate = NULL, strZip = '58401-', intMasterId = 342106
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3504', strName = 'CHS Petroleum Terminal - Minot', strAddress = '700 Second Street SW', strCity = 'Minot', dtmApprovedDate = NULL, strZip = '58701', intMasterId = 342107
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3505', strName = 'Tesoro Logistics Operations LLC', strAddress = '900 Old Red Trail NE', strCity = 'Mandan', dtmApprovedDate = NULL, strZip = '58554-5000', intMasterId = 342108
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3506', strName = 'BNSF - Mandan', strAddress = 'P. O. Box 1205', strCity = 'Mandan', dtmApprovedDate = NULL, strZip = '58554', intMasterId = 342109
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3508', strName = 'Hess North Dakota Export Logistics', strAddress = '10515 67th Street NW', strCity = 'Tioga', dtmApprovedDate = NULL, strZip = '58852', intMasterId = 342110
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T45ND3509', strName = 'Dakota Prairie Refining', strAddress = '3815 116th Ave SW', strCity = 'Dickinson', dtmApprovedDate = NULL, strZip = '58601', intMasterId = 342111

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'ND', @TerminalControlNumbers = @TerminalND

DELETE @TerminalND

-- NE Terminals
PRINT ('Deploying NE Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39NE3604', strName = 'Signature Flight Support Corp.', strAddress = '3636 Wilbur Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27515
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39NE3612', strName = 'Magellan Pipeline Company, L.P.', strAddress = '13029 S 13th St', strCity = 'Bellevue', dtmApprovedDate = NULL, strZip = '68123', intMasterId = 27516
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39NE3613', strName = 'Truman Arnold Co. - TAC Air', strAddress = '3737 Orville Plaza', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27517
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39NE3614', strName = 'Union Pacific Railroad Co.', strAddress = '6000 West Front St.', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101', intMasterId = 27518
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39NE3615', strName = 'BNSF - Lincoln', strAddress = '201 North 7th Street', strCity = 'Lincoln', dtmApprovedDate = NULL, strZip = '68508', intMasterId = 27519
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3600', strName = 'NuStar Pipeline Operating Partnership, L.P. - Columbus', strAddress = 'R R 5, Box 27 BB', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '68601-', intMasterId = 27520
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3601', strName = 'NuStar Pipeline Operating Partnership, L.P. - Geneva', strAddress = 'U S Highway 81', strCity = 'Geneva', dtmApprovedDate = NULL, strZip = '68361-', intMasterId = 27521
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3602', strName = 'Magellan Pipeline Company, L.P.', strAddress = '12275 South US Hwy 281', strCity = 'Doniphan', dtmApprovedDate = NULL, strZip = '68832-', intMasterId = 27522
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3603', strName = 'Phillips 66 PL - Lincoln', strAddress = '1345 Saltillo Rd.', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430', intMasterId = 27523
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3605', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2000 Saltillo Road', strCity = 'Roca', dtmApprovedDate = NULL, strZip = '68430', intMasterId = 27524
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3606', strName = 'NuStar Pipeline Operating Partnership, L.P. - Norfolk', strAddress = 'Highway 81', strCity = 'Norfolk', dtmApprovedDate = NULL, strZip = '68701', intMasterId = 27525
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3607', strName = 'NuStar Pipeline Operating Partnership, L.P. - North Platte', strAddress = 'Rural Route Four', strCity = 'North Platte', dtmApprovedDate = NULL, strZip = '69101', intMasterId = 27526
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3608', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2205 N 11th St', strCity = 'Omaha', dtmApprovedDate = NULL, strZip = '68110', intMasterId = 27527
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3610', strName = 'NuStar Pipeline Operating Partnership, L.P. - Osceola', strAddress = 'Rural Route 1', strCity = 'Osceola', dtmApprovedDate = NULL, strZip = '68651', intMasterId = 27528
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T47NE3609', strName = 'Holly Energy Partners - Operating LP', strAddress = '11712 US Highway 30', strCity = 'Sidney', dtmApprovedDate = NULL, strZip = '69162', intMasterId = 271572

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NE', @TerminalControlNumbers = @TerminalNE

DELETE @TerminalNE

-- NH Terminals
PRINT ('Deploying NH Terminal Control Number')
DECLARE @TerminalNH AS TFTerminalControlNumbers

INSERT INTO @TerminalNH(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T02NH1050', strName = 'Sprague Operating Resources LLC - Newington', strAddress = '372 Shattuck Way', strCity = 'Newington', dtmApprovedDate = NULL, strZip = '03801', intMasterId = 292112
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T02NH1056', strName = 'Irving Oil Terminals, Inc.', strAddress = '50 Preble Way', strCity = 'Portsmouth', dtmApprovedDate = NULL, strZip = '03801-', intMasterId = 292113

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NH', @TerminalControlNumbers = @TerminalNH

DELETE @TerminalNH

-- NJ Terminals
PRINT ('Deploying NJ Terminal Control Number')
DECLARE @TerminalNJ AS TFTerminalControlNumbers

INSERT INTO @TerminalNJ(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1500', strName = 'Buckeye Terminals, LLC - Bayonne', strAddress = 'Lower Hook Road', strCity = 'Bayonne', dtmApprovedDate = NULL, strZip = '07002-', intMasterId = 302114
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1502', strName = 'Buckeye Terminals, LLC - Newark', strAddress = '1111 Delanny St.', strCity = 'Newark', dtmApprovedDate = NULL, strZip = '07105-', intMasterId = 302115
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1503', strName = 'IMTT - Bayonne', strAddress = '250 East 22nd St.', strCity = 'Bayonne', dtmApprovedDate = NULL, strZip = '07002', intMasterId = 302116
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1504', strName = 'Interstate Storage & Pipeline Corp.', strAddress = '1715 Burlington-Jacksonville', strCity = 'Bordentown', dtmApprovedDate = NULL, strZip = '08505', intMasterId = 302117
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1506', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '760 Roosevelt Avenue', strCity = 'Carteret', dtmApprovedDate = NULL, strZip = '07008-', intMasterId = 302118
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1507', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '78 Lafayette Street', strCity = 'Carteret', dtmApprovedDate = NULL, strZip = '07008-', intMasterId = 302119
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1512', strName = 'Phillips 66 PL - Tremley PT', strAddress = 'Foot of South Wood Ave', strCity = 'Linden', dtmApprovedDate = NULL, strZip = '07036-', intMasterId = 302120
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1513', strName = 'CITGO Petroleum Corporation - Linden', strAddress = '4801 Foot of South Wood Avenue', strCity = 'Linden', dtmApprovedDate = NULL, strZip = '07036-', intMasterId = 302121
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1514', strName = 'Phillips 66 PL - Linden', strAddress = '1100 Rte # 1', strCity = 'Linden', dtmApprovedDate = NULL, strZip = '07036-', intMasterId = 302122
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1515', strName = 'Gulf Oil LP - Linden', strAddress = '2600 Marshdock Road', strCity = 'Linden', dtmApprovedDate = NULL, strZip = '07036-', intMasterId = 302123
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1516', strName = 'NuStar Terminals Operations Partnership L. P. - Linden', strAddress = '3700 South Wood Ave', strCity = 'Linden', dtmApprovedDate = NULL, strZip = '7731', intMasterId = 302124
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1517', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '825 Clonmell Rd.', strCity = 'Paulsboro', dtmApprovedDate = NULL, strZip = '08066', intMasterId = 302125
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1521', strName = 'Equilon Enterprises LLC', strAddress = '909 Delancy Street', strCity = 'Newark', dtmApprovedDate = NULL, strZip = '07105-', intMasterId = 302126
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1522', strName = 'Center Point Terminal Newark LP', strAddress = '678 Doremus Ave', strCity = 'Newark', dtmApprovedDate = NULL, strZip = '07105-', intMasterId = 302127
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1523', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '436 Doremus Avenue', strCity = 'Newark', dtmApprovedDate = NULL, strZip = '07105-', intMasterId = 302128
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1525', strName = 'PBF Logistics Products Terminals LLC', strAddress = '3rd St & Billingsport Road', strCity = 'Paulsboro', dtmApprovedDate = NULL, strZip = '08066-', intMasterId = 302129
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1526', strName = 'NuStar Logistics, L. P. - Paulsboro', strAddress = '7 N. Delaware St.', strCity = 'Paulsboro', dtmApprovedDate = NULL, strZip = '08066-', intMasterId = 302130
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1528', strName = 'Buckeye Terminals, LLC - Pennsauken', strAddress = '123 Derousse Avenue', strCity = 'Pennsauken', dtmApprovedDate = NULL, strZip = '08110-', intMasterId = 302131
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1531', strName = 'Buckeye Terminals, LLC - Perth Amboy', strAddress = '380 Mauer Road', strCity = 'Perth Amboy', dtmApprovedDate = NULL, strZip = '08861-', intMasterId = 302132
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1532', strName = 'Allied Aviation Service of New Jersey', strAddress = 'North Avenue & Division St.', strCity = 'Elizabeth', dtmApprovedDate = NULL, strZip = '07201', intMasterId = 302133
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1535', strName = 'Buckeye Terminals, LLC - Port Reading', strAddress = 'Cliff Road', strCity = 'Port Reading', dtmApprovedDate = NULL, strZip = '07064-', intMasterId = 302135
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1538', strName = 'Equilon Enterprises LLC', strAddress = '111 State Street', strCity = 'Sewaren', dtmApprovedDate = NULL, strZip = '07077-0188', intMasterId = 302136
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1540', strName = 'Gulf Oil LP - Thorofare', strAddress = '920 Kings Highway', strCity = 'Thorofare', dtmApprovedDate = NULL, strZip = '08086-', intMasterId = 302137
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1544', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '1000 Crown Point Rd', strCity = 'Westville', dtmApprovedDate = NULL, strZip = '08093', intMasterId = 302138
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1545', strName = 'Buckeye Terminals, LLC - Perth Amboy', strAddress = 'Smith Street & Convery Blvd.', strCity = 'Perth Amboy', dtmApprovedDate = NULL, strZip = '08861-', intMasterId = 302139
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1547', strName = 'Buckeye Terminals, LLC - Trenton', strAddress = '1463 Lamberton Road', strCity = 'Trenton', dtmApprovedDate = NULL, strZip = '08677-', intMasterId = 302140
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1548', strName = 'SLF, Inc. T/A Consumers Oil', strAddress = '1473 Lamberton Road', strCity = 'Trenton', dtmApprovedDate = NULL, strZip = '08611-', intMasterId = 302141
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1550', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '920 High Street', strCity = 'Perth Amboy', dtmApprovedDate = NULL, strZip = '08862', intMasterId = 302142
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T22NJ1551', strName = 'Repauno Port & Rail Terminal', strAddress = '200 North Repauno Ave', strCity = 'Gibbstown', dtmApprovedDate = NULL, strZip = '08027', intMasterId = 302143

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NJ', @TerminalControlNumbers = @TerminalNJ

DELETE @TerminalNJ

-- NM Terminals
PRINT ('Deploying NM Terminal Control Number')
DECLARE @TerminalNM AS TFTerminalControlNumbers

INSERT INTO @TerminalNM(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4251', strName = 'South Florida Materials Corp dba Vecenergy', strAddress = '3200 Broadway SE within city', strCity = 'Albuquerque', dtmApprovedDate = NULL, strZip = '87105-', intMasterId = 312144
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4253', strName = 'NuStar Logistics, L. P. - Albuquerque', strAddress = '6348 State Road 303', strCity = 'Albuquerque', dtmApprovedDate = NULL, strZip = '87105-', intMasterId = 312145
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4254', strName = 'Phillips 66 PL - Albuquerque', strAddress = '6356 Desert Road SE', strCity = 'Albuquerque', dtmApprovedDate = NULL, strZip = '87105-', intMasterId = 312146
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4255', strName = 'Western Refining - Albuquerque', strAddress = '3209 Broadway Southeast', strCity = 'Albuquerque', dtmApprovedDate = NULL, strZip = '87105', intMasterId = 312147
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4256', strName = 'Holly Energy Partners - Operating LP', strAddress = '501 E Main', strCity = 'Artesia', dtmApprovedDate = NULL, strZip = '88210-', intMasterId = 312148
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4257', strName = 'Western Refining - Bloomfield', strAddress = '# 50 County Road 4990', strCity = 'Bloomfield', dtmApprovedDate = NULL, strZip = '87413-', intMasterId = 312149
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4258', strName = 'Western Refining - Gallup', strAddress = 'I-40 Exit 39', strCity = 'Jamestown', dtmApprovedDate = NULL, strZip = '87347', intMasterId = 312150
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4259', strName = 'Epic Midstream LLC', strAddress = '6026 Hwy 54 South', strCity = 'Alamogordo', dtmApprovedDate = NULL, strZip = '88310-0109', intMasterId = 312151
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4262', strName = 'Union Pacific Railroad Co.', strAddress = '8920 Airport Road', strCity = 'Santa Teresa', dtmApprovedDate = NULL, strZip = '88008', intMasterId = 312152
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86NM4261', strName = 'USA Petroleum Southwest Terminal', strAddress = '3155 Hwy 80, I-10 Exit 5', strCity = 'Road Forks', dtmApprovedDate = NULL, strZip = '88045', intMasterId = 312153
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86NM4262', strName = 'Holly Energy Partners - Operating LP', strAddress = '1001 E. Martinez Road', strCity = 'Moriarty', dtmApprovedDate = NULL, strZip = '87035', intMasterId = 312154
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86NM4264', strName = 'BNSF - Belen', strAddress = '106 N. First St.', strCity = 'Belen', dtmApprovedDate = NULL, strZip = '87002', intMasterId = 312155
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T85NM4261', strName = 'Aircraft Service International, Inc.', strAddress = '3531 Access Road C SE', strCity = 'Albuquerque', dtmApprovedDate = NULL, strZip = '87106', intMasterId = 312156


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NM', @TerminalControlNumbers = @TerminalNM

DELETE @TerminalNM

-- NV Terminals
PRINT ('Deploying NV Terminal Control Number')
DECLARE @TerminalNV AS TFTerminalControlNumbers

INSERT INTO @TerminalNV(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86NV4352', strName = 'Reno Fueling Facilities Corporation', strAddress = '355 S. Rock Blvd.', strCity = 'Reno', dtmApprovedDate = NULL, strZip = '89502', intMasterId = 282156
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T86NV4355', strName = 'Swissport Fueling of Nevada, Inc', strAddress = '575 Kitty Hawk Way', strCity = 'Las Vegas', dtmApprovedDate = NULL, strZip = '89111', intMasterId = 282157
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4350', strName = 'Calnev Pipe Line, LLC', strAddress = '5049 N Sloan', strCity = 'Las Vegas', dtmApprovedDate = NULL, strZip = '89115', intMasterId = 282158
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4353', strName = 'SFPP, LP', strAddress = '301 Nugget Avenue', strCity = 'Sparks', dtmApprovedDate = NULL, strZip = '89431-', intMasterId = 282159
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4354', strName = 'OP Reno LLC', strAddress = '525 Nugget Avenue', strCity = 'Sparks', dtmApprovedDate = NULL, strZip = '89431-', intMasterId = 282160
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4359', strName = 'Rebel Oil Las Vegas Terminal', strAddress = '5054 N Sloane Lane', strCity = 'Las Vegas', dtmApprovedDate = NULL, strZip = '89115', intMasterId = 282161
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4362', strName = 'Pro Petroleum, Inc. - Las Vegas', strAddress = '4985 N Sloan LN', strCity = 'Las Vegas', dtmApprovedDate = NULL, strZip = '89115', intMasterId = 282162
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4364', strName = 'Golden Gate/SET Petroleum Partners', strAddress = '500 Ireland Drive', strCity = 'McCarran', dtmApprovedDate = NULL, strZip = '89434', intMasterId = 282163
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T88NV4365', strName = 'Holly Energy Partners - Operating LP', strAddress = '13420 Grand Valley Parkway', strCity = 'North Las Vegas', dtmApprovedDate = NULL, strZip = '89165', intMasterId = 282164

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NV', @TerminalControlNumbers = @TerminalNV

DELETE @TerminalNV

-- NY Terminals
PRINT ('Deploying NY Terminal Control Number')
DECLARE @TerminalNY AS TFTerminalControlNumbers

INSERT INTO @TerminalNY(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1301', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '125 Apollo St.', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11222-', intMasterId = 322165
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1302', strName = 'United Metro Energy Corp', strAddress = '498 Kingsland Avenue', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11222-', intMasterId = 322166
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1304', strName = 'Arc Terminals Holdings LLC', strAddress = '25 Paidge Ave.', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11222-', intMasterId = 322167
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1305', strName = 'Global Companies LLC', strAddress = '464 Doughty Blvd', strCity = 'Inwood', dtmApprovedDate = NULL, strZip = '11696-', intMasterId = 322168
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1306', strName = 'Lefferts Oil Terminal, Inc.', strAddress = '31-70 College Point Blvd', strCity = 'Flushing', dtmApprovedDate = NULL, strZip = '11354-', intMasterId = 322169
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1308', strName = 'Buckeye Terminals, LLC - Brooklyn', strAddress = '722 Court Street', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11231-', intMasterId = 322170
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1309', strName = 'Global Companies LLC', strAddress = 'Shore & Glenwood Rd', strCity = 'Glenwood Landing', dtmApprovedDate = NULL, strZip = '11547-', intMasterId = 322171
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1310', strName = 'Northville Industries Corp - Holtsville', strAddress = '586 Union Ave.', strCity = 'Holtsville', dtmApprovedDate = NULL, strZip = '11742-', intMasterId = 322172
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1312', strName = 'Equilon Enterprises LLC', strAddress = '74 East Avenue', strCity = 'Lawrence', dtmApprovedDate = NULL, strZip = '11559-', intMasterId = 322173
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1318', strName = 'United Riverhead Terminal', strAddress = '212 Sound Shore Road', strCity = 'Riverhead', dtmApprovedDate = NULL, strZip = '11901-', intMasterId = 322174
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1324', strName = 'Sprague Operating Resources LLC - Lawrence', strAddress = '1 Bay Blvd', strCity = 'Lawrence', dtmApprovedDate = NULL, strZip = '11559-', intMasterId = 322175
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1325', strName = 'Bayside Fuel Oil Depot Corp.', strAddress = '1100 Grand Street', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11211-', intMasterId = 322176
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1326', strName = 'Bayside Fuel Oil Depot Corp.', strAddress = '1776 Shore Parkway', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11214', intMasterId = 322177
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1332', strName = 'Bayside Fuel Oil Depot Corp.', strAddress = '537 Smith Street', strCity = 'Brooklyn', dtmApprovedDate = NULL, strZip = '11231', intMasterId = 322178
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1333', strName = 'The Energy Conservation Group LLC', strAddress = '119-02 23rd Ave.', strCity = 'College Point', dtmApprovedDate = NULL, strZip = '11356', intMasterId = 322179
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1334', strName = 'Allied New York Services Inc.', strAddress = 'Bldg. #90 (JFK Intl. Airport)', strCity = 'Jamaica', dtmApprovedDate = NULL, strZip = '11430', intMasterId = 322180
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1335', strName = 'Allied Aviation Service of New York', strAddress = 'Fuel Facility, Bldg #42', strCity = 'Flushing', dtmApprovedDate = NULL, strZip = '11371', intMasterId = 322181
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T11NY1336', strName = 'Global Commander Terminal', strAddress = 'One Commander Square', strCity = 'Oyster Bay', dtmApprovedDate = NULL, strZip = '11771', intMasterId = 322182
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T13NY1352', strName = 'Sprague Operating Resources LLC - Bronx', strAddress = '939 E. 138th St.', strCity = 'Bronx', dtmApprovedDate = NULL, strZip = '10454', intMasterId = 322183
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T13NY1353', strName = 'Buckeye Terminals, LLC - Bronx', strAddress = '1040 East 149th Street', strCity = 'Bronx', dtmApprovedDate = NULL, strZip = '10455-', intMasterId = 322184
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T13NY1356', strName = 'Sprague Operating Resources LLC - Mt. Vernon', strAddress = '40 Canal St.', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '10550-', intMasterId = 322185
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T13NY1357', strName = 'Fred M. Schildwachter & Sons', strAddress = '1400 Ferris Place', strCity = 'Bronx', dtmApprovedDate = NULL, strZip = '10461-', intMasterId = 322186
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T13NY1358', strName = 'Meenan Oil Co. - Peekskill', strAddress = '26 Bayview Drive', strCity = 'Cortlandt Manor', dtmApprovedDate = NULL, strZip = '10567', intMasterId = 322187
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T13NY1360', strName = 'Westmore Fuel Co., Inc.', strAddress = '2 Purdy Ave', strCity = 'Port Chester', dtmApprovedDate = NULL, strZip = '10573-', intMasterId = 322188
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1401', strName = 'Buckeye Albany Terminal LLC', strAddress = '301 Normanskill St.', strCity = 'Albany', dtmApprovedDate = NULL, strZip = '12202-', intMasterId = 322189
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1402', strName = 'CITGO Petroleum Corporation - Glenmont', strAddress = '495 River Road', strCity = 'Glenmont', dtmApprovedDate = NULL, strZip = '12077-', intMasterId = 322190
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1403', strName = 'Global Companies LLC', strAddress = '50 Church Street', strCity = 'Albany', dtmApprovedDate = NULL, strZip = '12202-', intMasterId = 322191
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1404', strName = 'Petroleum Fuel & Terminal - Albany', strAddress = '54 Riverside Avenue', strCity = 'Rensselaer', dtmApprovedDate = NULL, strZip = '12144-', intMasterId = 322192
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1405', strName = 'Center Point Terminal - Glenmont', strAddress = 'Route 144 552 River Road', strCity = 'Glenmont', dtmApprovedDate = NULL, strZip = '12077-', intMasterId = 322193
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1411', strName = 'Global Companies LLC', strAddress = '1096 River Rd.', strCity = 'New Windsor', dtmApprovedDate = NULL, strZip = '12553', intMasterId = 322194
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1413', strName = 'Global Companies LLC', strAddress = '1281 River Road', strCity = 'New Windsor', dtmApprovedDate = NULL, strZip = '12551-', intMasterId = 322195
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1414', strName = 'Global Companies LLC', strAddress = '1184 River Road', strCity = 'New Windsor', dtmApprovedDate = NULL, strZip = '12553-', intMasterId = 322196
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1415', strName = 'Buckeye Terminals, LLC - Rensselaer', strAddress = '367 American Oil Rd.', strCity = 'Rensselaer', dtmApprovedDate = NULL, strZip = '12144-', intMasterId = 322197
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1417', strName = 'Sprague Operating Resources LLC - Rensselaer', strAddress = '58 Riverside Avenue', strCity = 'Rensselaer', dtmApprovedDate = NULL, strZip = '12144-', intMasterId = 322198
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1421', strName = 'Buckeye Terminals, LLC - Newburgh', strAddress = '924 River Road', strCity = 'Newburgh', dtmApprovedDate = NULL, strZip = '12550', intMasterId = 322199
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1422', strName = 'Meenan Oil Co .- Poughkeepsie', strAddress = '99 Prospect St.', strCity = 'Poughkeepsie', dtmApprovedDate = NULL, strZip = '12601-', intMasterId = 322200
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T14NY1423', strName = 'New Hamburg Terminal Corp.', strAddress = 'Point Street', strCity = 'New Hamburg', dtmApprovedDate = NULL, strZip = '12590', intMasterId = 322201
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1454', strName = 'CITGO - Vestal', strAddress = '3212 Old Vestal Road', strCity = 'Vestal', dtmApprovedDate = NULL, strZip = '13850-', intMasterId = 322202
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1456', strName = 'Buckeye Terminals, LLC - Brewerton', strAddress = '777 River Road - Cty Rd 37', strCity = 'Brewerton', dtmApprovedDate = NULL, strZip = '13029-', intMasterId = 322203
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1457', strName = 'United Refining Co. - Tonawanda', strAddress = '4545 River Road', strCity = 'Tonawanda', dtmApprovedDate = NULL, strZip = '14150-', intMasterId = 322204
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1458', strName = 'Buckeye Terminals, LLC - Buffalo', strAddress = '625 Elk St.', strCity = 'Buffalo', dtmApprovedDate = NULL, strZip = '14210-', intMasterId = 322205
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1459', strName = 'Noco Energy Corp.', strAddress = '700 Grand Island Blvd.', strCity = 'Tonawanda', dtmApprovedDate = NULL, strZip = '14151-0086', intMasterId = 322206
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1461', strName = 'IPT, LLC', strAddress = 'End of Riverside Extension', strCity = 'Rennselaer', dtmApprovedDate = NULL, strZip = '12144', intMasterId = 322207
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1463', strName = 'Buckeye Terminals, LLC - Marcy', strAddress = '9586 River Road', strCity = 'Marcy', dtmApprovedDate = NULL, strZip = '13403-', intMasterId = 322208
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1468', strName = 'Buckeye Terminals, LLC - Rochester', strAddress = '754 Brooks Ave.', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14619-', intMasterId = 322209
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1469', strName = 'Buckeye Terminals, LLC - Rochester', strAddress = '1975 Lyell Avenue', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14606-', intMasterId = 322210
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1470', strName = 'Superior Plus Energy Services Inc. - Rochester', strAddress = '335 McKee Rd', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14611-', intMasterId = 322211
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1471', strName = 'Superior Plus Energy Services Inc. - Big Flats', strAddress = '3351 St. Rt. 352', strCity = 'Big Flats', dtmApprovedDate = NULL, strZip = '14814-', intMasterId = 322212
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1472', strName = 'Buckeye Terminals, LLC - Rochester II', strAddress = '675 Brooks Avenue', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14619-', intMasterId = 322213
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1473', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '1840 Lyell Avenue', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14606-', intMasterId = 322214
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1474', strName = 'United Refining Co. - Rochester', strAddress = '1075 Chili Avenue', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14624-', intMasterId = 322215
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1476', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '6700 Herman Rd.', strCity = 'Warners', dtmApprovedDate = NULL, strZip = '13164-', intMasterId = 322216
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1484', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '3733 River Road', strCity = 'Tonawanda', dtmApprovedDate = NULL, strZip = '14150-', intMasterId = 322217
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1486', strName = 'Buckeye Terminals, LLC - Utica', strAddress = '37 Wurz Avenue', strCity = 'Utica', dtmApprovedDate = NULL, strZip = '13502-', intMasterId = 322218
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1488', strName = 'Buckeye Terminals, LLC - Vestal', strAddress = '3113 Shippers Rd.', strCity = 'Vestal', dtmApprovedDate = NULL, strZip = '13851-', intMasterId = 322219
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1493', strName = 'Superior Plus Energy Services Inc. - Marcy', strAddress = '9678 River Road, Rt. 49', strCity = 'Marcy', dtmApprovedDate = NULL, strZip = '13403-', intMasterId = 322220
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1494', strName = 'Center Point Terminal - Rochester', strAddress = '1935 Lyell Avenue', strCity = 'Rochester', dtmApprovedDate = NULL, strZip = '14606-', intMasterId = 322221
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1497', strName = 'Heritagenergy Inc.', strAddress = '1 Deleware Ave.', strCity = 'Kingston', dtmApprovedDate = NULL, strZip = '12401-', intMasterId = 322222
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T16NY1499', strName = 'Global Companies LLC', strAddress = '1254 River Road', strCity = 'New Windsor', dtmApprovedDate = NULL, strZip = '12553', intMasterId = 322223

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'NY', @TerminalControlNumbers = @TerminalNY

DELETE @TerminalNY

-- OH Terminals
PRINT ('Deploying OH Terminal Control Number')
DECLARE @TerminalOH AS TFTerminalControlNumbers

INSERT INTO @TerminalOH(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3100', strName = 'MPLX Cincinnati', strAddress = '4015 River Road', strCity = 'Cincinnati', dtmApprovedDate = NULL, strZip = '45204', intMasterId = 352224
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3101', strName = 'MPLX Columbus (East)', strAddress = '3855 Fisher Road', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43228', intMasterId = 352225
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3102', strName = 'MPLX Heath', strAddress = '840 Heath Road', strCity = 'Heath', dtmApprovedDate = NULL, strZip = '43056', intMasterId = 352226
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3103', strName = 'MPLX Marietta', strAddress = 'Old Rt 7 Moores Junction', strCity = 'Marietta', dtmApprovedDate = NULL, strZip = '45750', intMasterId = 352227
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3104', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '930 Tennessee Avenue', strCity = 'Cincinnati', dtmApprovedDate = NULL, strZip = '45229', intMasterId = 352228
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3105', strName = 'Buckeye Terminals, LLC - Columbus', strAddress = '303 North Wilson Road', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43204', intMasterId = 352229
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3106', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '621 Brandt Pike', strCity = 'Dayton', dtmApprovedDate = NULL, strZip = '45404', intMasterId = 352230
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3111', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '3866 Fisher Rd', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43228', intMasterId = 352231
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3112', strName = 'MPLX Columbus (West)', strAddress = '4125 Fisher Rd', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43228-1021', intMasterId = 352232
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3114', strName = 'Buckeye Terminals, LLC - Columbus', strAddress = '3651 Fisher Rd.', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43228', intMasterId = 352234
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3115', strName = 'Buckeye Terminals, LLC - Dayton', strAddress = '801 Brandt Pike', strCity = 'Dayton', dtmApprovedDate = NULL, strZip = '45404', intMasterId = 352235
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3116', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '3499 West Broad Street', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43204', intMasterId = 352236
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3117', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '1708 Farr Drive', strCity = 'Dayton', dtmApprovedDate = NULL, strZip = '45404', intMasterId = 352237
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3118', strName = 'ERPC Lebanon', strAddress = '2700 Hart Road', strCity = 'Lebanon', dtmApprovedDate = NULL, strZip = '45036', intMasterId = 352238
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3119', strName = 'ERPC Todhunter', strAddress = '3590 Yankee Rd.', strCity = 'Middletown', dtmApprovedDate = NULL, strZip = '45044', intMasterId = 352239
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3120', strName = 'CITGO - Dublin', strAddress = '6433 Cosgray Road', strCity = 'Dublin', dtmApprovedDate = NULL, strZip = '43016-', intMasterId = 352240
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3121', strName = 'CITGO Petroleum Corporation - Dayton', strAddress = '1800 Farr Drive', strCity = 'Dayton', dtmApprovedDate = NULL, strZip = '45404', intMasterId = 352241
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3125', strName = 'Norfolk Southern Railway Co End Terminal', strAddress = '24424 N. Prairie Rd.', strCity = 'Bellevue', dtmApprovedDate = NULL, strZip = '44811', intMasterId = 352242
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3127', strName = 'Norfolk Southern Railway Co End Terminal', strAddress = '2435 8th Street', strCity = 'Portsmouth', dtmApprovedDate = NULL, strZip = '45662', intMasterId = 352243
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3128', strName = 'Buckeye Terminals, LLC - Cincinnati', strAddress = '5150 River Road', strCity = 'Cincinnati', dtmApprovedDate = NULL, strZip = '45233', intMasterId = 352244
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3129', strName = 'BenchMark Biodiesel', strAddress = '620 Phillipi Road', strCity = 'Columbus', dtmApprovedDate = NULL, strZip = '43228', intMasterId = 352245
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3140', strName = 'MPLX Canton', strAddress = '2419 Gambrinus Ave', strCity = 'Canton', dtmApprovedDate = NULL, strZip = '44706', intMasterId = 352246
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3143', strName = 'Buckeye Terminals, LLC - Canton', strAddress = '807 Hartford Southeast', strCity = 'Canton', dtmApprovedDate = NULL, strZip = '44707', intMasterId = 352247
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3144', strName = 'Buckeye Terminals, LLC - Cuyahoga Hts.', strAddress = '4850 E 49th Street', strCity = 'Cuyahoga Hts.', dtmApprovedDate = NULL, strZip = '44125', intMasterId = 352248
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3145', strName = 'Buckeye Terminals, LLC - Grafton', strAddress = '12545 S Avon Belden Rd', strCity = 'Grafton', dtmApprovedDate = NULL, strZip = '44044', intMasterId = 352249
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3146', strName = 'Buckeye Terminals, LLC - Lima North', strAddress = '817 West Vine Street', strCity = 'Lima', dtmApprovedDate = NULL, strZip = '45804', intMasterId = 352250
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3148', strName = 'Buckeye Terminals, LLC - Toledo', strAddress = '2450 Hill Avenue', strCity = 'Toledo', dtmApprovedDate = NULL, strZip = '43607', intMasterId = 352251
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3149', strName = 'Delta Fuels, Inc.', strAddress = '1820 South Front', strCity = 'Toledo', dtmApprovedDate = NULL, strZip = '43605', intMasterId = 352252
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3150', strName = 'Arc Terminals Holdings LLC', strAddress = '250 Mahoning Ave', strCity = 'Cleveland', dtmApprovedDate = NULL, strZip = '44113-2524', intMasterId = 352253
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3151', strName = 'MPLX Brecksville', strAddress = '10439 Brecksville Road', strCity = 'Brecksville', dtmApprovedDate = NULL, strZip = '44141-3395', intMasterId = 352254
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3152', strName = 'MPLX Lima', strAddress = '2990 South Dixie Highway', strCity = 'Lima', dtmApprovedDate = NULL, strZip = '45804-3721', intMasterId = 352255
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3153', strName = 'MPLX Oregon', strAddress = '4131 Seaman Road', strCity = 'Oregon', dtmApprovedDate = NULL, strZip = '43616-2448', intMasterId = 352256
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3154', strName = 'MPLX Steubenville', strAddress = '28371 Kingsdale Road', strCity = 'Steubenville', dtmApprovedDate = NULL, strZip = '43952-4318', intMasterId = 352257
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3155', strName = 'MPLX Youngstown', strAddress = '1140 Bears Den Road', strCity = 'Youngstown', dtmApprovedDate = NULL, strZip = '44511', intMasterId = 352258
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3157', strName = 'Buckeye Terminals, LLC - Cleveland', strAddress = '2201 West Third Street', strCity = 'Cleveland', dtmApprovedDate = NULL, strZip = '44113-2589', intMasterId = 352259
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3158', strName = 'Buckeye Terminals, LLC - Lima South', strAddress = '1500 W. Buckeye Road', strCity = 'Lima', dtmApprovedDate = NULL, strZip = '45804', intMasterId = 352260
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3159', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '999 Home Avenue', strCity = 'Akron', dtmApprovedDate = NULL, strZip = '44310', intMasterId = 352261
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3160', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '3200 Independence Road', strCity = 'Cleveland', dtmApprovedDate = NULL, strZip = '44105', intMasterId = 352262
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3161', strName = 'PBF Logistics Products Terminals LLC', strAddress = '1601 Woodvalle Road', strCity = 'Toledo', dtmApprovedDate = NULL, strZip = '43605', intMasterId = 352263
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3162', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '6331 Southern Boulevard', strCity = 'Youngstown', dtmApprovedDate = NULL, strZip = '44512', intMasterId = 352264
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3164', strName = 'CITGO - Tallmadge', strAddress = '1595 Southeast Avenue', strCity = 'Tallmadge', dtmApprovedDate = NULL, strZip = '44278', intMasterId = 352265
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3165', strName = 'CITGO Petroleum Corporation - Oregon', strAddress = '1840 Otter Creek Road', strCity = 'Oregon', dtmApprovedDate = NULL, strZip = '43616-7676', intMasterId = 352266
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3166', strName = 'MPLX Bellevue', strAddress = 'Rural Route 4', strCity = 'Bellevue', dtmApprovedDate = NULL, strZip = '44811', intMasterId = 352267
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3167', strName = 'Buckeye Terminals, LLC - Niles', strAddress = '1001 Youngstown Warren Rd', strCity = 'Niles', dtmApprovedDate = NULL, strZip = '41446-4620', intMasterId = 352268
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3168', strName = 'Guttman Realty Co. - BTS East', strAddress = 'DBA Bulk Terminal Storage', strCity = 'Aurora', dtmApprovedDate = NULL, strZip = '44202-', intMasterId = 352269
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3169', strName = 'Arc Terminals Holdings LLC', strAddress = '2844 Summit St', strCity = 'Toledo', dtmApprovedDate = NULL, strZip = '43611-', intMasterId = 352270
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3174', strName = 'TransMontaigne - E Liverpool', strAddress = '425 River Rd.', strCity = 'East Liverpool', dtmApprovedDate = NULL, strZip = '43920-0000', intMasterId = 352271
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3175', strName = 'BP Products North America Inc', strAddress = '5241 Secondary Road', strCity = 'Cleveland', dtmApprovedDate = NULL, strZip = '44135', intMasterId = 352272
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3176', strName = 'Lima Refining Company', strAddress = '1150 S Metcalf', strCity = 'Lima', dtmApprovedDate = NULL, strZip = '45804', intMasterId = 352273
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T34OH3177', strName = 'Marathon Canton Refinery Rack', strAddress = '2408 Gamfrinus Rd SW', strCity = 'Canton', dtmApprovedDate = NULL, strZip = '44707', intMasterId = 352274
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T31OH3109', strName = 'Aircraft Service International, Inc.', strAddress = '5912 Cargo Rd.', strCity = 'Cleveland', dtmApprovedDate = NULL, strZip = '44181', intMasterId = 352275


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'OH', @TerminalControlNumbers = @TerminalOH

DELETE @TerminalOH

-- OK Terminals
PRINT ('Deploying OK Terminal Control Number')
DECLARE @TerminalOK AS TFTerminalControlNumbers

INSERT INTO @TerminalOK(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2600', strName = 'Valero Refining Company - Oklahoma', strAddress = 'One Valero Way', strCity = 'Ardmore', dtmApprovedDate = NULL, strZip = '73401', intMasterId = 362275
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2606', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1401 North 30th Street', strCity = 'Enid', dtmApprovedDate = NULL, strZip = '73701-', intMasterId = 362276
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2608', strName = 'Phillips 66 PL - Glenpool', strAddress = '10600 S Elwood', strCity = 'Jenks', dtmApprovedDate = NULL, strZip = '74037-', intMasterId = 362277
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2612', strName = 'Phillips 66 PL - Oklahoma City', strAddress = '4700 NE Tenth', strCity = 'Oklahoma City', dtmApprovedDate = NULL, strZip = '73111-', intMasterId = 362278
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2613', strName = 'Magellan Pipeline Company, L.P.', strAddress = '251 N Sunny Lane', strCity = 'Oklahoma City', dtmApprovedDate = NULL, strZip = '73117-', intMasterId = 362279
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2614', strName = 'TransMontaigne - Oklahoma City', strAddress = '951 N. Vickie', strCity = 'Oklahoma City', dtmApprovedDate = NULL, strZip = '73117-', intMasterId = 362280
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2617', strName = 'Phillips 66 PL - Ponca City', strAddress = 'South Highway 60', strCity = 'Ponca City', dtmApprovedDate = NULL, strZip = '74601-', intMasterId = 362281
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2620', strName = 'Holly Energy Partners - Operating LP', strAddress = '1307 W 35th St', strCity = 'Tulsa', dtmApprovedDate = NULL, strZip = '74107-', intMasterId = 362282
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2621', strName = 'HollyFrontier Tulsa Refining LLC', strAddress = '1700 South Union', strCity = 'Tulsa', dtmApprovedDate = NULL, strZip = '74102-', intMasterId = 362283
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2622', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2120 S 33rd West Ave.', strCity = 'Tulsa', dtmApprovedDate = NULL, strZip = '74107-', intMasterId = 362284
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2624', strName = 'Wynnewood Energy Company, LLC', strAddress = '906 South Powell', strCity = 'Wynnewood', dtmApprovedDate = NULL, strZip = '73098-', intMasterId = 362285
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2626', strName = 'Oklahoma City Airport Trust', strAddress = '6131 South Meridian', strCity = 'Oklahoma City', dtmApprovedDate = NULL, strZip = '73159', intMasterId = 362286
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T73OK2628', strName = 'Kansas City Southern Railway - Heavener', strAddress = '403 West First Street', strCity = 'Heavener', dtmApprovedDate = NULL, strZip = '74937', intMasterId = 362287

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'OK', @TerminalControlNumbers = @TerminalOK

DELETE @TerminalOK

-- OR Terminals
PRINT ('Deploying OR Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91OR4465', strName = 'Union Pacific Railroad Co.', strAddress = 'Route 1, Simplot Rd.', strCity = 'Hermiston', dtmApprovedDate = NULL, strZip = '97838', intMasterId = 371292
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4452', strName = 'Tidewater Terminal - Umatilla', strAddress = '535 Port Avenue', strCity = 'Umatilla', dtmApprovedDate = NULL, strZip = '97882-', intMasterId = 371293
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4454', strName = 'SFPP, LP', strAddress = '1765 Prairie Road', strCity = 'Eugene', dtmApprovedDate = NULL, strZip = '97402-', intMasterId = 371294
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4455', strName = 'BP West Coast Products LLC', strAddress = '9930 NW St Helens Rd', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97231-', intMasterId = 371295
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4456', strName = 'Chevron USA, Inc.- Portland', strAddress = '5524 NW Front Ave', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371296
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4457', strName = 'Kinder Morgan Liquid Terminals, LLC', strAddress = '5880 NW St. Helen''s Road', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97283-', intMasterId = 371297
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4458', strName = 'McCall Oil and Chemical Corp.', strAddress = '5480 NW Front Ave', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371298
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4459', strName = 'Shore Terminals LLC - Portland', strAddress = '9420 Northwest St Helen''s Rd', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97231-', intMasterId = 371299
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4461', strName = 'Shell Oil Products US', strAddress = '3800 NW St. Helen''s Road', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371300
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4464', strName = 'Phillips 66 PL - Portland', strAddress = '5528 Northwest Doane', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97210-', intMasterId = 371301
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4465', strName = 'Arc Terminals Holdings LLC', strAddress = '5501 NW Front Ave ', strCity = 'Portland ', dtmApprovedDate = NULL, strZip = '97210', intMasterId = 371302
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T93OR4466', strName = 'Olympic Pipeline Company - Portland', strAddress = '9420 NW St Helens Road', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97231', intMasterId = 371303
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91OR4450', strName = 'Aircraft Service International, Inc.', strAddress = '8133 NE Airtrans Way', strCity = 'Portland', dtmApprovedDate = NULL, strZip = '97218', intMasterId = 371304


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'OR', @TerminalControlNumbers = @TerminalOR

DELETE @TerminalOR

-- PA Terminals
PRINT ('Deploying PA Terminal Control Number')
DECLARE @TerminalPA AS TFTerminalControlNumbers

INSERT INTO @TerminalPA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1700', strName = 'Buckeye Terminals, LLC - Macungie', strAddress = '5198 Buckeye Road', strCity = 'Macungie', dtmApprovedDate = NULL, strZip = '18062-', intMasterId = 382288
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1701', strName = 'Lucknow-Highspire Terminal - Allentown', strAddress = '1134 North Quebec Street', strCity = 'Allentown', dtmApprovedDate = NULL, strZip = '18103-', intMasterId = 382289
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1702', strName = 'Buckeye Terminals, LLC - Macungie BES', strAddress = '5285 Shipper Road', strCity = 'Macungie', dtmApprovedDate = NULL, strZip = '18062-', intMasterId = 382290
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1703', strName = 'Arc Terminals Holdings LLC', strAddress = '674 Suscon Rd', strCity = 'Pittston Township', dtmApprovedDate = NULL, strZip = '18641-', intMasterId = 382291
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1707', strName = 'Lucknow-Highspire Terminals - Du Pont', strAddress = '675 Suscon Road', strCity = 'Pittston', dtmApprovedDate = NULL, strZip = '18641', intMasterId = 382292
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1709', strName = 'Superior Plus Energy Services Inc. - Montoursville', strAddress = '112 Broad St', strCity = 'Montoursville', dtmApprovedDate = NULL, strZip = '17754-', intMasterId = 382293
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1710', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '601 East Lincoln Hwy', strCity = 'Exton', dtmApprovedDate = NULL, strZip = '19341-', intMasterId = 382294
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1711', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '2480 Main St', strCity = 'Whitehall', dtmApprovedDate = NULL, strZip = '18052-', intMasterId = 382295
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1713', strName = 'Lucknow-Highspire Terminals - Harrisburg', strAddress = '5140 Paxton Street', strCity = 'Harrisburg', dtmApprovedDate = NULL, strZip = '17111-', intMasterId = 382296
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1715', strName = 'Lucknow-Highspire Terminals - Mechanicsburg', strAddress = '127 Texaco Drive', strCity = 'Mechanicsburg', dtmApprovedDate = NULL, strZip = '17050-', intMasterId = 382297
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1716', strName = 'Lucknow-Highspire Terminals - Highspire', strAddress = '900 Eisenhower Blvd', strCity = 'Middletown', dtmApprovedDate = NULL, strZip = '17057-', intMasterId = 382298
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1718', strName = 'Buckeye Terminals, LLC - Malvern', strAddress = '8 South Malin Rd', strCity = 'Frazer', dtmApprovedDate = NULL, strZip = '19406-', intMasterId = 382299
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1720', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '60 S Wyoming Avenue', strCity = 'Edwardsville', dtmApprovedDate = NULL, strZip = '18704-3102', intMasterId = 382300
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1721', strName = 'Lucknow-Highspire Terminals - Lancaster', strAddress = '1360 Manheim Pike', strCity = 'Lancaster', dtmApprovedDate = NULL, strZip = '17604-', intMasterId = 382301
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1722', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Lincoln Hwy & Malin Road', strCity = 'Malvern', dtmApprovedDate = NULL, strZip = '19355-', intMasterId = 382302
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1725', strName = 'Arc Terminals Holdings LLC', strAddress = '5125 Simpson Ferry Rd', strCity = 'Mechanicsburg', dtmApprovedDate = NULL, strZip = '17055-', intMasterId = 382303
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1726', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '5145 Simpson Ferry Road', strCity = 'Mechanicsburg', dtmApprovedDate = NULL, strZip = '17055-3626', intMasterId = 382304
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1727', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Fritztown Road', strCity = 'Sinking Spring', dtmApprovedDate = NULL, strZip = '19608-', intMasterId = 382305
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1728', strName = 'Lucknow-Highspire Terminals - Northumberland', strAddress = 'Rt 11 North RD 1', strCity = 'Northumberland', dtmApprovedDate = NULL, strZip = '17857-', intMasterId = 382306
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1729', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Rt 11 North Rd 1', strCity = 'Northumberland', dtmApprovedDate = NULL, strZip = '17857-', intMasterId = 382307
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1730', strName = 'PBF Logistics Products Terminals LLC', strAddress = '1630 South 51st Street', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19143-', intMasterId = 382308
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1731', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '63rd & Passyunk Avenue', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19153-', intMasterId = 382309
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1732', strName = 'Monroe Energy LLC', strAddress = 'G Street & Hunting Park Ave.', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19124-', intMasterId = 382310
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1733', strName = 'Global Companies LLC', strAddress = 'Shippers Lane', strCity = 'Macungie', dtmApprovedDate = NULL, strZip = '18062-', intMasterId = 382311
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1734', strName = 'PBF Logistics Products Terminals LLC', strAddress = '6850 Essington Avenue', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19153-', intMasterId = 382312
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1736', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '2700 W Passyunk Avenue', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19145-', intMasterId = 382313
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1737', strName = 'PBF Logistics Products Terminals LLC', strAddress = '3400 S. 67th Street', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19153-', intMasterId = 382314
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1742', strName = 'Lucknow-Highspire Terminals - Sinking Spring', strAddress = '901 Mountain Home Rd', strCity = 'Sinking Spring', dtmApprovedDate = NULL, strZip = '19608-', intMasterId = 382315
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1743', strName = 'Buckeye Terminals, LLC - South Williamsport', strAddress = '1466 Sylvan Dell Road', strCity = 'South Williamsport', dtmApprovedDate = NULL, strZip = '17701-', intMasterId = 382316
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1744', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Tuscarora State Park Rd', strCity = 'Tamaqua', dtmApprovedDate = NULL, strZip = '18252-', intMasterId = 382317
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1746', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '4041 Market Street', strCity = 'Aston', dtmApprovedDate = NULL, strZip = '19014-', intMasterId = 382318
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1747', strName = 'Sunoco, LLC', strAddress = '100 Green St', strCity = 'Marcus Hook', dtmApprovedDate = NULL, strZip = '19061', intMasterId = 382319
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1748', strName = 'Lucknow-Highspire Terminals - Whitehall', strAddress = '2451 Main Street', strCity = 'Whitehall', dtmApprovedDate = NULL, strZip = '18052-', intMasterId = 382320
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1749', strName = 'Arc Terminals Holdings LLC', strAddress = 'Sylvan Dell Rd', strCity = 'Williamsport', dtmApprovedDate = NULL, strZip = '17703-', intMasterId = 382321
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1751', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '3290 Sunset Lane', strCity = 'Hatboro', dtmApprovedDate = NULL, strZip = '19040-', intMasterId = 382322
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1752', strName = 'Buckeye Terminals, LLC - Tuckerton', strAddress = '130 Whitman Road', strCity = 'Reading', dtmApprovedDate = NULL, strZip = '19605-', intMasterId = 382323
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1753', strName = 'Meenan Oil Co. - Tullytown', strAddress = '113 Main St.', strCity = 'Tullytown', dtmApprovedDate = NULL, strZip = '19007-', intMasterId = 382324
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1755', strName = 'HOP Energy, LLC', strAddress = '501 E. Hunting Park Ave.', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19124-', intMasterId = 382325
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1757', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Hewes Ave & Philadelphia Pike', strCity = 'Marcus Hook', dtmApprovedDate = NULL, strZip = '19061', intMasterId = 382326
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1761', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '3300 N. Deleware Avenue', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19134', intMasterId = 382327
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1764', strName = 'American Refining - Bradford', strAddress = '77 North Kendall Ave.', strCity = 'Bradford', dtmApprovedDate = NULL, strZip = '16701-', intMasterId = 382328
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1759', strName = 'Lucknow-Highspire Terminals - Coraopolis', strAddress = '520 University Blvd', strCity = 'Coraopolis', dtmApprovedDate = NULL, strZip = '15108', intMasterId = 382329
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1761', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '1734 Old Route 66', strCity = 'Delmont', dtmApprovedDate = NULL, strZip = '15626-', intMasterId = 382330
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1762', strName = 'Watco Transloading LLC', strAddress = '702 Washington Avenue', strCity = 'Dravosburg', dtmApprovedDate = NULL, strZip = '15034-', intMasterId = 382331
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1767', strName = 'Lucknow-Highspire Terminals - Eldorado', strAddress = 'Burns Avenue', strCity = 'Altoona', dtmApprovedDate = NULL, strZip = '16603-', intMasterId = 382332
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1769', strName = 'Buckeye Terminals, LLC - Greensburg', strAddress = 'Rural Delivery 6', strCity = 'Greensburg', dtmApprovedDate = NULL, strZip = '15601-', intMasterId = 382333
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1771', strName = 'Buckeye Terminals, LLC - Indianola', strAddress = 'State Route 910', strCity = 'Indianola', dtmApprovedDate = NULL, strZip = '15051-', intMasterId = 382334
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1773', strName = 'MPLX Midland', strAddress = '3852 Rt. 68', strCity = 'Midland', dtmApprovedDate = NULL, strZip = '15059-', intMasterId = 382335
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1776', strName = 'Lucknow-Highspire Terminals - Pittsburgh', strAddress = '2760 Neville Road', strCity = 'Pittsburgh', dtmApprovedDate = NULL, strZip = '15225-', intMasterId = 382336
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1778', strName = 'Lucknow-Highspire Terminals - Pittsburgh/Delmont', strAddress = '6433 Route 22', strCity = 'Delmont', dtmApprovedDate = NULL, strZip = '15626-', intMasterId = 382338
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1780', strName = 'Lucknow-Highspire Terminals - Corapolis', strAddress = '520 University Blvd', strCity = 'Coraopolis', dtmApprovedDate = NULL, strZip = '15108-', intMasterId = 382339
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1781', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '5733 Butler Street', strCity = 'Pittsburgh', dtmApprovedDate = NULL, strZip = '15201-', intMasterId = 382340
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1783', strName = 'United Refining Co. - Warren', strAddress = '15 Bradley St', strCity = 'Warren', dtmApprovedDate = NULL, strZip = '16365-', intMasterId = 382341
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1785', strName = 'Arc Terminals Holdings LLC', strAddress = '6033 Sixth Avenue', strCity = 'Altoona', dtmApprovedDate = NULL, strZip = '16602-', intMasterId = 382342
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1788', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Route 764 Sugar Run Road', strCity = 'Altoona', dtmApprovedDate = NULL, strZip = '16601-', intMasterId = 382343
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1790', strName = 'Guttman Realty Co. - Belle Vernon', strAddress = '200 Speers Road', strCity = 'Belle Vernon', dtmApprovedDate = NULL, strZip = '15012-', intMasterId = 382344
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1791', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = 'Freeport Road & Boyd Avenue', strCity = 'Pittsburgh', dtmApprovedDate = NULL, strZip = '15238-', intMasterId = 382345
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T25PA1792', strName = 'Buckeye Terminals, LLC - Pittsburgh', strAddress = 'Access State Route 51', strCity = 'Coraopolis', dtmApprovedDate = NULL, strZip = '15108-', intMasterId = 382346
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1766', strName = 'Aircraft Service International, Inc.', strAddress = '550 Tower Rd', strCity = 'Pittsburgh', dtmApprovedDate = NULL, strZip = '15231', intMasterId = 382347
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T23PA1770', strName = 'Aircraft Service International, Inc.', strAddress = 'Philadelphia Intern''l Airport', strCity = 'Philadelphia', dtmApprovedDate = NULL, strZip = '19153', intMasterId = 382348


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'PA', @TerminalControlNumbers = @TerminalPA

DELETE @TerminalPA

-- RI Terminals
PRINT ('Deploying RI Terminal Control Number')
DECLARE @TerminalRI AS TFTerminalControlNumbers

INSERT INTO @TerminalRI(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T05RI1201', strName = 'Sprague Operating Resources LLC - Providence', strAddress = '144 Allens Avenue', strCity = 'Providence', dtmApprovedDate = NULL, strZip = '02903-', intMasterId = 392347
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T05RI1202', strName = 'NE Petroleum Terminal LLC', strAddress = '130 Terminal Rd', strCity = 'Providence', dtmApprovedDate = NULL, strZip = '02905-', intMasterId = 392348
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T05RI1203', strName = 'Sprague Operating Resources LLC - East Providence', strAddress = '100 Dexter Road', strCity = 'East Providence', dtmApprovedDate = NULL, strZip = '02914-', intMasterId = 392349
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T05RI1205', strName = 'Equilon Enterprises LLC', strAddress = '520 Allens Avenue', strCity = 'Providence', dtmApprovedDate = NULL, strZip = '02905-', intMasterId = 392350
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T05RI1207', strName = 'ExxonMobil Oil Corp.', strAddress = '1001 Wampanoag Trail', strCity = 'East Providence', dtmApprovedDate = NULL, strZip = '02915-', intMasterId = 392351
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T06RI1208', strName = 'Inland Fuel Terminal, Inc.', strAddress = '25 State Ave.', strCity = 'Tiverton', dtmApprovedDate = NULL, strZip = '02878', intMasterId = 392352

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'RI', @TerminalControlNumbers = @TerminalRI

DELETE @TerminalRI

-- SC Terminals
PRINT ('Deploying SC Terminal Control Number')
DECLARE @TerminalSC AS TFTerminalControlNumbers

INSERT INTO @TerminalSC(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2051', strName = 'Buckeye Terminals, LLC - Belton', strAddress = 'Hwy 20 North', strCity = 'Belton', dtmApprovedDate = NULL, strZip = '29627-0647', intMasterId = 402353
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2052', strName = 'Buckeye Terminals, LLC - Spartansburg', strAddress = '680 Delmar Road', strCity = 'Spartansburg', dtmApprovedDate = NULL, strZip = '29302-', intMasterId = 402354
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2053', strName = 'MPLX Belton', strAddress = '14315 State Rt. 20', strCity = 'Belton', dtmApprovedDate = NULL, strZip = '29627-0488', intMasterId = 402355
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2054', strName = 'Kinder Morgan Operating LP "C"', strAddress = '1500 Greenleaf St.', strCity = 'Charleston', dtmApprovedDate = NULL, strZip = '29405-9308', intMasterId = 402356
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2059', strName = 'Magellan Terminals Holdings LP', strAddress = '217 Sweet Water Road', strCity = 'North Augusta', dtmApprovedDate = NULL, strZip = '29860', intMasterId = 402357
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2060', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '221 Laurel Lake Drive', strCity = 'North Augusta', dtmApprovedDate = NULL, strZip = '29841-', intMasterId = 402358
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2061', strName = 'Buckeye Terminals, LLC - North Augusta', strAddress = '221 Sweetwater Rd.', strCity = 'North Augusta', dtmApprovedDate = NULL, strZip = '29841-6427', intMasterId = 402359
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2062', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '205 Sweetwater Rd.', strCity = 'North Augusta', dtmApprovedDate = NULL, strZip = '29841-6669', intMasterId = 402360
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2063', strName = 'Magellan Terminals Holdings LP', strAddress = '1222 Sweetwater Road', strCity = 'North Augusta', dtmApprovedDate = NULL, strZip = '29841-', intMasterId = 402361
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2064', strName = 'Buckeye Terminals, LLC - North Charleston', strAddress = '5150 Virginia Ave.', strCity = 'North Charleston', dtmApprovedDate = NULL, strZip = '29406-5227', intMasterId = 402362
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2067', strName = 'TransMontaigne - Spartansburg', strAddress = '2300 South Port Rd.', strCity = 'Spartansburg', dtmApprovedDate = NULL, strZip = '29304-5021', intMasterId = 402363
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2068', strName = 'Magellan Terminals Holdings LP', strAddress = 'Old Union Rd Route 4', strCity = 'Spartansburg', dtmApprovedDate = NULL, strZip = '29304-3059', intMasterId = 402364
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2074', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '200 Nebo Street', strCity = 'Spartansburg', dtmApprovedDate = NULL, strZip = '29302-', intMasterId = 402365
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2075', strName = 'Motiva Enterprises LLC', strAddress = '300 Delmar Road', strCity = 'Spartansburg', dtmApprovedDate = NULL, strZip = '29302-', intMasterId = 402366
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2076', strName = 'Magellan Terminals Holdings LP', strAddress = '2430 Pine Street Ext', strCity = 'Spartanburg', dtmApprovedDate = NULL, strZip = '29302-', intMasterId = 402367
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T57SC2077', strName = 'CITGO - Spartanburg', strAddress = '2590 Southport Road', strCity = 'Spartanburg', dtmApprovedDate = NULL, strZip = '29302-', intMasterId = 402368

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'SC', @TerminalControlNumbers = @TerminalSC

DELETE @TerminalSC

-- SD Terminals
PRINT ('Deploying SD Terminal Control Number')
DECLARE @TerminalSD AS TFTerminalControlNumbers

INSERT INTO @TerminalSD(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3550', strName = 'NuStar Pipeline Operating Partnership, L.P. - Aberdeen', strAddress = '12948 386th Ave', strCity = 'Aberdeen', dtmApprovedDate = NULL, strZip = '57401-', intMasterId = 412369
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3551', strName = 'NuStar Pipeline Operating Partnership, L.P. - Mitchell', strAddress = '41408 SD Hwy 38', strCity = 'Mitchell', dtmApprovedDate = NULL, strZip = '57301-', intMasterId = 412370
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3552', strName = 'Magellan Pipeline Company, L.P.', strAddress = '3225 Eglin Street', strCity = 'Rapid City', dtmApprovedDate = NULL, strZip = '57701-', intMasterId = 412371
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3553', strName = 'NuStar Pipeline Operating Partnership, L.P. - Sioux Falls', strAddress = '3721 South Grange Avenue', strCity = 'Sioux Falls', dtmApprovedDate = NULL, strZip = '57105-', intMasterId = 412372
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3554', strName = 'Magellan Pipeline Company, L.P.', strAddress = '5300 West 12th Street', strCity = 'Sioux Falls', dtmApprovedDate = NULL, strZip = '57107-', intMasterId = 412373
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3555', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1000 17th Street SE', strCity = 'Watertown', dtmApprovedDate = NULL, strZip = '57201-', intMasterId = 412374
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3556', strName = 'NuStar Pipeline Operating Partnership, L.P. - Wolsey', strAddress = '20746 US Highway 281', strCity = 'Wolsey', dtmApprovedDate = NULL, strZip = '57384-', intMasterId = 412375
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T46SD3557', strName = 'NuStar Pipeline Operating Partnership, L.P. - Yankton', strAddress = '2608 E Hwy 50', strCity = 'Yankton', dtmApprovedDate = NULL, strZip = '57078-', intMasterId = 412376

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'SD', @TerminalControlNumbers = @TerminalSD

DELETE @TerminalSD

-- TN Terminals
PRINT ('Deploying TN Terminal Control Number')
DECLARE @TerminalTN AS TFTerminalControlNumbers

INSERT INTO @TerminalTN(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2200', strName = 'Magellan Terminals Holdings LP', strAddress = '4235 Jersey Pike', strCity = 'Chattanooga', dtmApprovedDate = NULL, strZip = '37416-', intMasterId = 422377
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2201', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4716 Bonny Oaks Drive', strCity = 'Chattanooga', dtmApprovedDate = NULL, strZip = '37416-', intMasterId = 422378
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2202', strName = 'CITGO - Chattanooga', strAddress = '4233 Jersey Pike', strCity = 'Chattanooga', dtmApprovedDate = NULL, strZip = '37416-', intMasterId = 422379
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2204', strName = 'Delek Logistics Operating', strAddress = '90 Van Buren St', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37208-', intMasterId = 422380
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2207', strName = 'Lincoln Terminal Company', strAddress = '4211 Cromwell Rd.', strCity = 'Chattanooga', dtmApprovedDate = NULL, strZip = '37421-', intMasterId = 422381
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2208', strName = 'Magellan Terminals Holdings LP', strAddress = '4326 Jersey Pike', strCity = 'Chattanooga', dtmApprovedDate = NULL, strZip = '37416-', intMasterId = 422382
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2211', strName = 'Magellan Terminals Holdings LP', strAddress = '5101 Middlebrook Pike NW', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37921-', intMasterId = 422383
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2212', strName = 'Swissport Fueling, Inc.', strAddress = '4096 Louis Carruthers Dr.', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38118', intMasterId = 422384
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2213', strName = 'CITGO - Knoxville', strAddress = '2409 Knott Road', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37921-', intMasterId = 422385
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2214', strName = 'Cummins Terminals - Knoxville', strAddress = '4715 Middlebrook Pike', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37921-5532', intMasterId = 422386
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2215', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '5009 Middlebrook Pike', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37921-', intMasterId = 422387
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2217', strName = 'MPLX Knoxville', strAddress = '2601 Knott Road', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37950-0094', intMasterId = 422388
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2218', strName = 'Equilon Enterprises LLC', strAddress = '5001 Middlebrook Pike NW', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37921-', intMasterId = 422389
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2219', strName = 'Magellan Terminals Holdings LP', strAddress = '4801 Middlebrook Pike', strCity = 'Knoxville', dtmApprovedDate = NULL, strZip = '37921-', intMasterId = 422390
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2220', strName = 'Federal Express Corporation', strAddress = '3051 Republican Blvd.', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38194', intMasterId = 422391
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2223', strName = 'Buckeye Aviation (Memphis) LLC', strAddress = '2640 Rental Road', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38118', intMasterId = 422392
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2225', strName = 'ExxonMobil Oil Corp.', strAddress = '454 Wisconsin Avenue', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38106-', intMasterId = 422393
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2226', strName = 'Delek Logistics Operating', strAddress = '1023 Riverside Dr', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38106-', intMasterId = 422394
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2227', strName = 'Valero Partners Operating Co LLC', strAddress = '321 W. Mallory Ave.', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38109-', intMasterId = 422395
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2228', strName = 'Center Point Terminal - Memphis', strAddress = '1232 Riverside', strCity = 'Memphis', dtmApprovedDate = NULL, strZip = '38106-', intMasterId = 422396
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2231', strName = 'Magellan Terminals Holdings LP', strAddress = '1441 51st Avenue North', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37209-', intMasterId = 422397
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2232', strName = 'MPLX Nashville (Downtown)', strAddress = 'Five Main Street', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37213-', intMasterId = 422398
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2233', strName = 'CITGO - Nashville', strAddress = '720 South Second Street', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37213-', intMasterId = 422399
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2234', strName = 'Cumberland Terminals', strAddress = '7260 Centennial Boulevard', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37209-', intMasterId = 422400
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2236', strName = 'ExxonMobil Oil Corp.', strAddress = '1741 Ed Temple Blvd', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37208-', intMasterId = 422401
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2237', strName = 'MPLX Nashville (51st Ave)', strAddress = '1409 51st Ave', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37209-', intMasterId = 422402
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2238', strName = 'MPLX Nashville (Bordeaux)', strAddress = '2920 Old Hydes Ferry Road', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37218', intMasterId = 422403
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2240', strName = 'Magellan Terminals Holdings LP', strAddress = '1609 63rd Avenue North', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37209-', intMasterId = 422404
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2241', strName = 'Equilon Enterprises LLC', strAddress = '1717 61st Ave. North', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37209-', intMasterId = 422405
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T62TN2222', strName = 'Aircraft Service International, Inc.', strAddress = '929 Airport Service Rd.', strCity = 'Nashville', dtmApprovedDate = NULL, strZip = '37214', intMasterId = 422406


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'TN', @TerminalControlNumbers = @TerminalTN

DELETE @TerminalTN

-- TX Terminals
PRINT ('Deploying TX Terminal Control Number')
DECLARE @TerminalTX AS TFTerminalControlNumbers

INSERT INTO @TerminalTX(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2658', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '11418 Abbott Rd', strCity = 'Hearne', dtmApprovedDate = NULL, strZip = '77859', intMasterId = 432406
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2700', strName = 'NuStar Logistics, L. P. - Edinburg', strAddress = '222 W. Ingle Rd.', strCity = 'Edinburg', dtmApprovedDate = NULL, strZip = '78359', intMasterId = 432407
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2702', strName = 'Motiva Enterprises LLC', strAddress = 'Highway 6 South', strCity = 'Hearne', dtmApprovedDate = NULL, strZip = '77859-', intMasterId = 432408
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2703', strName = 'CITGO - Victoria', strAddress = '1708 North Ben Jordan Blvd', strCity = 'Victoria', dtmApprovedDate = NULL, strZip = '77901-', intMasterId = 432409
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2705', strName = 'Motiva Enterprises LLC', strAddress = '420 South Lacy drive', strCity = 'Waco', dtmApprovedDate = NULL, strZip = '76705-', intMasterId = 432410
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2706', strName = 'Flint Hills Resources, LP-Austin', strAddress = '9011 Johnny Morris Rd', strCity = 'Austin', dtmApprovedDate = NULL, strZip = '78724-', intMasterId = 432411
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2707', strName = 'Flint Hills Resources, LP-Waco', strAddress = '2017 Kendall Lane', strCity = 'Waco', dtmApprovedDate = NULL, strZip = '76705-3366', intMasterId = 432412
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2709', strName = 'CITGO - Brownsville', strAddress = '11001 R.L. Ostos Rd.', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432413
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2712', strName = 'Calumet San Antonio Refining', strAddress = '7811 S. Presa', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78223', intMasterId = 432414
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2713', strName = 'U.S. Oil - Bryan Finfeather', strAddress = '1714 Finfeather Road', strCity = 'Bryan', dtmApprovedDate = NULL, strZip = '77801-', intMasterId = 432415
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2714', strName = 'Valero Refining Co. - Corpus Christi', strAddress = '5900 Up River Rd.', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78407', intMasterId = 432416
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2715', strName = 'NuStar Logistics, L. P. - Laredo', strAddress = '13380 S Unitec Drive', strCity = 'Laredo', dtmApprovedDate = NULL, strZip = '78044-', intMasterId = 432417
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2716', strName = 'CITGO - Corpus Christi', strAddress = '1308 Oak Park Street', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78407-', intMasterId = 432418
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2717', strName = 'TransMontaigne - SouthWest', strAddress = '10150 State Hwy 48', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432419
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2721', strName = 'Flint Hills Resources, LP-Corpus Christi', strAddress = '2825 Suntide Road', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78403-', intMasterId = 432420
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2724', strName = 'Western Refining - El Paso', strAddress = '6501 Trowbridge', strCity = 'El Paso', dtmApprovedDate = NULL, strZip = '79905-', intMasterId = 432421
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2725', strName = 'Union Pacific Railroad Co.', strAddress = '6200 N.E. Loop 410', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78218', intMasterId = 432422
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2726', strName = 'Holly Energy Partners- Operating LP', strAddress = '1000 Eastside & 897 Hawkins', strCity = 'El Paso', dtmApprovedDate = NULL, strZip = '79915-', intMasterId = 432423
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2729', strName = 'NuStar Logistics, L. P. - Harlingen', strAddress = '26306 FM 106', strCity = 'Harlingen', dtmApprovedDate = NULL, strZip = '78550-', intMasterId = 432424
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2737', strName = 'CITGO - San Antonio', strAddress = '4851 Emil Road', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78219-', intMasterId = 432425
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2738', strName = 'NuStar Logistics, L. P. - San Antonio East', strAddress = '4719 Corner Parkway #2', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78219-', intMasterId = 432426
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2739', strName = 'NuStar Logistics, L. P. - San Antonio North', strAddress = '10619 US HWY 281 S', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78221-', intMasterId = 432427
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2740', strName = 'ExxonMobil Oil Corp.', strAddress = '3214 North Pan Am Expressway', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78219-', intMasterId = 432428
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2742', strName = 'Flint Hills Resources, LP-San Antonio', strAddress = '498 and Pop Gun', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78219-', intMasterId = 432429
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2745', strName = 'Motiva Enterprises LLC', strAddress = '510 Petroleum Drive', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78219-', intMasterId = 432430
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2747', strName = 'Diamond Shamrock - Three Rivers', strAddress = '301 Leroy Street', strCity = 'Three Rivers', dtmApprovedDate = NULL, strZip = '78071-', intMasterId = 432431
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2748', strName = 'Holly Energy Partners - Operating LP', strAddress = '1000 South Access Rd.', strCity = 'Tye', dtmApprovedDate = NULL, strZip = '79563-', intMasterId = 432432
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2749', strName = 'Fikes Wholesale Inc', strAddress = '1600 South Loop Dr', strCity = 'Waco', dtmApprovedDate = NULL, strZip = '76705', intMasterId = 432433
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2750', strName = 'NuStar Logistics, L. P. - El Paso', strAddress = '4200 Justice Road', strCity = 'El Paso', dtmApprovedDate = NULL, strZip = '79938', intMasterId = 432434
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2751', strName = 'Magellan Pipeline Company, L.P.', strAddress = '13551 E. Montana Ave.', strCity = 'El Paso', dtmApprovedDate = NULL, strZip = '79938', intMasterId = 432435
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2752', strName = 'Flint Hills Resources, LP-Bastrop', strAddress = '115 Mt. Olive Road', strCity = 'Cedar Creek', dtmApprovedDate = NULL, strZip = '78612', intMasterId = 432436
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2754', strName = 'TransMontaigne - Border', strAddress = '8700 State Highway 48', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432437
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2755', strName = 'TransMontaigne - Tejano', strAddress = '6200 State Highway 48', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432438
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2758', strName = 'Mustang Ridge Fuels Terminal', strAddress = '1165 East Lone Star Dr.   ', strCity = 'Buda', dtmApprovedDate = NULL, strZip = '76610', intMasterId = 432439
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2759', strName = 'Lazarus Energy LLC', strAddress = '11372 US Highway 87 East', strCity = 'Nixon', dtmApprovedDate = NULL, strZip = '78140', intMasterId = 432440
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2760', strName = 'Flint Hills Resources, LP-San Antonio', strAddress = '4800 Corerway Blvd', strCity = 'San Antonio', dtmApprovedDate = NULL, strZip = '78219', intMasterId = 432441
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2761', strName = 'Maverick Terminal Brownsville', strAddress = '14301 R L Ostos Road', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432442
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2650', strName = 'NuStar Logistics, L. P. - Abernathy', strAddress = '1315 FM 54', strCity = 'Abernathy', dtmApprovedDate = NULL, strZip = '79311-', intMasterId = 432443
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2652', strName = 'Delek Marketing & Supply, LP', strAddress = 'Hwy 277 N Industrial District', strCity = 'Abilene', dtmApprovedDate = NULL, strZip = '79604-', intMasterId = 432444
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2653', strName = 'Nustar Logistics LP - Amarillo, TX', strAddress = '4200 West Cliffside', strCity = 'Amarillo', dtmApprovedDate = NULL, strZip = '79124-', intMasterId = 432445
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2654', strName = 'Phillips 66 PL - Amarillo', strAddress = '4300 Cliffside Dr', strCity = 'Amarillo', dtmApprovedDate = NULL, strZip = '79142-', intMasterId = 432446
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2656', strName = 'Alon Big Spring', strAddress = 'East IS-20 & Refinery Rd', strCity = 'Big Springs', dtmApprovedDate = NULL, strZip = '79721-', intMasterId = 432447
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2657', strName = 'Phillips 66 Co - Borger', strAddress = 'Spur 119 N.', strCity = 'Borger', dtmApprovedDate = NULL, strZip = '79007-', intMasterId = 432448
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2659', strName = 'JP Energy Caddo LLC', strAddress = '2738 County Rd 2168', strCity = 'Caddo Mills', dtmApprovedDate = NULL, strZip = '75135', intMasterId = 432449
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2660', strName = 'ExxonMobil Oil Corp.', strAddress = '1201 East Airport Freeway', strCity = 'Irving', dtmApprovedDate = NULL, strZip = '75062-', intMasterId = 432450
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2661', strName = 'Magellan Pipeline Company, L.P.', strAddress = '4200 Singleton Boulevard', strCity = 'Dallas', dtmApprovedDate = NULL, strZip = '75212-3433', intMasterId = 432451
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2662', strName = 'Motiva Enterprises LLC', strAddress = '3900 Singleton Blvd.', strCity = 'Dallas', dtmApprovedDate = NULL, strZip = '75212-', intMasterId = 432452
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2664', strName = 'Flint Hills Resources, LP-Ft. Worth', strAddress = 'Highway 157 and Trinity Blvd', strCity = 'Euless', dtmApprovedDate = NULL, strZip = '76040-', intMasterId = 432453
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2665', strName = 'Magellan Pipeline Company, L.P.', strAddress = '6000 I H 20', strCity = 'Aledo', dtmApprovedDate = NULL, strZip = '76008-', intMasterId = 432454
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2666', strName = 'Chevron USA, Inc.- Fort Worth', strAddress = '2525 Brennan Street', strCity = 'Fort Worth', dtmApprovedDate = NULL, strZip = '76106-', intMasterId = 432455
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2667', strName = 'U.S. Oil - Ft. Worth Terminal', strAddress = '301 Terminal Road', strCity = 'Fort Worth', dtmApprovedDate = NULL, strZip = '76106-', intMasterId = 432456
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2669', strName = 'Motiva Enterprises LLC', strAddress = '3200 N. Sylvania', strCity = 'Fort Worth', dtmApprovedDate = NULL, strZip = '76111-', intMasterId = 432457
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2671', strName = 'Magellan Pipeline Company, L.P.', strAddress = '3100 Highway 26 West', strCity = 'Grapevine', dtmApprovedDate = NULL, strZip = '76051-', intMasterId = 432458
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2673', strName = 'Allied Aviation Fueling of Dallas LP', strAddress = '2001 W. Airfield Dr. @ 20th St', strCity = 'Dallas', dtmApprovedDate = NULL, strZip = '75261', intMasterId = 432459
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2674', strName = 'Phillips 66 PL - Lubbock', strAddress = 'Clovis Road and Flint Avenue', strCity = 'Lubbock', dtmApprovedDate = NULL, strZip = '79408-', intMasterId = 432460
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2676', strName = 'Delek Marketing - Big Sandy', strAddress = '1503 West Ferguson', strCity = 'Mount Pleasant', dtmApprovedDate = NULL, strZip = '75455-', intMasterId = 432461
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2678', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '377 State Highway 87 South', strCity = 'Center', dtmApprovedDate = NULL, strZip = '75935-', intMasterId = 432462
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2680', strName = 'NuStar Logistics, L. P. - Southlake', strAddress = '1700 Mustang Court', strCity = 'Grapevine', dtmApprovedDate = NULL, strZip = '76092', intMasterId = 432463
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2681', strName = 'Delek Logistics Operating', strAddress = '425 McMurry Drive', strCity = 'Tyler', dtmApprovedDate = NULL, strZip = '75702-', intMasterId = 432464
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2682', strName = 'Diamond Shamrock - Sunray', strAddress = 'HCR 1, Box 36', strCity = 'Sunray', dtmApprovedDate = NULL, strZip = '79086-', intMasterId = 432465
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2683', strName = 'Holly Energy Partners - Operating LP', strAddress = '301 Sinclair Blvd.', strCity = 'Wichita Falls', dtmApprovedDate = NULL, strZip = '76307', intMasterId = 432466
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2685', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2700 S. Grandview', strCity = 'Odessa', dtmApprovedDate = NULL, strZip = '79760-', intMasterId = 432467
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2686', strName = 'Delek Marketing & Supply, LP', strAddress = '4008 U S Hwy 67N', strCity = 'San Angelo', dtmApprovedDate = NULL, strZip = '76905-', intMasterId = 432468
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2688', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '9 South', strCity = 'Waskom', dtmApprovedDate = NULL, strZip = '75692-', intMasterId = 432469
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2690', strName = 'Direct Fuels LLC', strAddress = '12625 Calloway Cemetary Rd', strCity = 'Euless', dtmApprovedDate = NULL, strZip = '76040-', intMasterId = 432470
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2691', strName = 'Chevron Phillips Chemical Co., LP', strAddress = 'Spur 119E - Philtex Plant', strCity = 'Borger', dtmApprovedDate = NULL, strZip = '79007', intMasterId = 432471
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2693', strName = 'BNSF - Amarillo East', strAddress = '7939 SE 3rd Avenue', strCity = 'Amarillo', dtmApprovedDate = NULL, strZip = '79118', intMasterId = 432472
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2694', strName = 'Pro Petroleum, Inc. - Lubbock', strAddress = '3002 Clovis Rd', strCity = 'Lubbock', dtmApprovedDate = NULL, strZip = '79416', intMasterId = 432473
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2695', strName = 'Valero Terminaling & Distribution', strAddress = '6647 County Road G', strCity = 'Sunray', dtmApprovedDate = NULL, strZip = '79086', intMasterId = 432474
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2780', strName = 'LBC Houston, LP', strAddress = '11666 Port Road', strCity = 'Seabrook', dtmApprovedDate = NULL, strZip = '77586-', intMasterId = 432475
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2782', strName = 'Motiva Enterprises LLC', strAddress = '1320 West Shaw St.', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77501-', intMasterId = 432476
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2783', strName = 'Motiva Enterprises LLC', strAddress = '9406 West Port Arthur Rd', strCity = 'Beaumont', dtmApprovedDate = NULL, strZip = '77705-', intMasterId = 432477
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2784', strName = 'Delek Marketing - Big Sandy', strAddress = 'Highway 155 and Sabine River', strCity = 'Big Sandy', dtmApprovedDate = NULL, strZip = '75755-', intMasterId = 432478
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2787', strName = 'Phillips 66 PL - Nederland', strAddress = 'Hwy 366', strCity = 'Nederland', dtmApprovedDate = NULL, strZip = '77627-', intMasterId = 432479
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2788', strName = 'KM Liquids Terminals, LLC', strAddress = '906 Clinton Drive', strCity = 'Galena Park', dtmApprovedDate = NULL, strZip = '77547-', intMasterId = 432480
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2789', strName = 'Chevron USA, Inc.- Galena Park', strAddress = '12523 American Petroleum Rd', strCity = 'Galena Park', dtmApprovedDate = NULL, strZip = '77547-', intMasterId = 432481
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2790', strName = 'Gulf Coast Energy LLC', strAddress = '17617 Aldine Westfield Rd.', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77073', intMasterId = 432482
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2792', strName = 'Magellan Terminals Holdings LP', strAddress = '12901 American Petroleum Rd.', strCity = 'Galena Park', dtmApprovedDate = NULL, strZip = '77547-', intMasterId = 432483
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2794', strName = 'U.S. Oil - Houston North Freeway', strAddress = '12325 North Fwy at Greens Rd', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77060-', intMasterId = 432485
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2798', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '15651 W. Port Arthur Rd.', strCity = 'Beaumont', dtmApprovedDate = NULL, strZip = '77705-', intMasterId = 432486
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2801', strName = 'Total Petrochemicals', strAddress = 'Hwy 366 & 32nd St', strCity = 'Port Arthur', dtmApprovedDate = NULL, strZip = '77642', intMasterId = 432487
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2802', strName = 'Enterprise Houston Ship Channel LP', strAddress = '15602 Jacinto Port Blvd.', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77015', intMasterId = 432488
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2805', strName = 'Petroleum Wholesale, Inc.', strAddress = '1801 Collingsworth', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77099', intMasterId = 432489
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2806', strName = 'Valero Refining Co. - Houston', strAddress = '9701 Manchester', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77262', intMasterId = 432490
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2808', strName = 'ExxonMobil Oil Corp.', strAddress = '8700 North Freeway', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77037-', intMasterId = 432491
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2809', strName = 'KM Liquids Terminals, LLC', strAddress = '530 North Witter', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77506-', intMasterId = 432492
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2811', strName = 'Phillips 66 PL - Pasadena', strAddress = '100 Jefferson Street', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77501-', intMasterId = 432493
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2812', strName = 'ExxonMobil Oil Corp.', strAddress = '10501 East Almeda', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77051-', intMasterId = 432494
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2813', strName = 'Phillips 66 Co - Sweeny', strAddress = 'Hwys 35 & 36 at West Columbia', strCity = 'Sweeny', dtmApprovedDate = NULL, strZip = '77480-', intMasterId = 432495
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2815', strName = 'Intercontinental Terminals Co.', strAddress = '1943 Independence Parkway', strCity = 'Deer Park', dtmApprovedDate = NULL, strZip = '77536-0698', intMasterId = 432496
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2817', strName = 'ERPC North Houston Terminal', strAddress = 'Corner of Ferrall and E. Hardy', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77063', intMasterId = 432497
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2818', strName = 'Allied Aviation Fueling of Houston LP', strAddress = '2050 Fuel Storage Rd.', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77205', intMasterId = 432498
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2819', strName = 'Kinder Morgan Galena Park West LLC', strAddress = '1500 Clinton Dr', strCity = 'Galena Park', dtmApprovedDate = NULL, strZip = '77547-', intMasterId = 432499
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2820', strName = 'Vopak Terminal Deer Park, Inc.', strAddress = '2759 Battleground Rd.', strCity = 'Deer Park', dtmApprovedDate = NULL, strZip = '77536', intMasterId = 432500
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2824', strName = 'BNSF - Temple', strAddress = '610 West Avenue D', strCity = 'Temple', dtmApprovedDate = NULL, strZip = '76504', intMasterId = 432501
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2826', strName = 'K-Solv L P', strAddress = '1015 Lakeside', strCity = 'Channelview', dtmApprovedDate = NULL, strZip = '77530', intMasterId = 432502
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2827', strName = 'Oiltanking Texas City, LP', strAddress = '2800 Loop 197 South', strCity = 'Texas City', dtmApprovedDate = NULL, strZip = '77592-0029', intMasterId = 432503
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2828', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '2450 FM 3057', strCity = 'Bay City', dtmApprovedDate = NULL, strZip = '77404', intMasterId = 432504
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2830', strName = 'KM Pasadena Truck Facility', strAddress = '400 N. Jefferson', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77506', intMasterId = 432505
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2831', strName = 'Magellan Pipeline Company, L.P.', strAddress = '7901 Wallisvile Road', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77029', intMasterId = 432506
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2832', strName = 'Lone Star NGL Mont Belvieu LP', strAddress = '12353 Eagle Point Dr.', strCity = 'Mont Belvieu', dtmApprovedDate = NULL, strZip = '77580', intMasterId = 432507
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2833', strName = 'Magellan Pipeline Company, L.P.', strAddress = '2115 East Highway 22', strCity = 'Mertens', dtmApprovedDate = NULL, strZip = '76666', intMasterId = 432508
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2834', strName = 'Enterprise Pasadena Products Terminal', strAddress = '1500 North South Street', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77503', intMasterId = 432509
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2836', strName = 'Martin Operating Partnership, L.P.', strAddress = '2420 Dowling Rd', strCity = 'Port Arthur', dtmApprovedDate = NULL, strZip = '77640', intMasterId = 432510
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2838', strName = 'Buckeye Texas Hub', strAddress = '7002 Marvin L Berry Rd', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78409', intMasterId = 432511
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2839', strName = 'Martin Operating Partnership, L.P.', strAddress = '1300 Coastwide Drive', strCity = 'Galveston', dtmApprovedDate = NULL, strZip = '77553', intMasterId = 432512
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2841', strName = 'Bluewing One', strAddress = '11700 Old Hwy 88', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78520', intMasterId = 432513
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2842', strName = 'Petromax Refining Company', strAddress = '1519 S Sheldon Company', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77015', intMasterId = 432514
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2843', strName = 'Intercontinental Terminals Co.', strAddress = '1030 Ethyl Road', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77503', intMasterId = 432515
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2844', strName = 'Buckeye Texas Processing LLC', strAddress = '1501 Southern Minerals Rd', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78409', intMasterId = 432516
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2845', strName = 'ABC Gulf Coast Terminal', strAddress = '15801 RL Ostos Road', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432517
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2846', strName = 'Magellan Terminals Holdings LP', strAddress = '1802 Poth Lane', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78407', intMasterId = 432518
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2847', strName = 'GT Logistics LLC', strAddress = '1998 Hwy 73 West', strCity = 'Port Arthur', dtmApprovedDate = NULL, strZip = '77640', intMasterId = 432519
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2848', strName = 'Martin Operating Partnership, L.P.', strAddress = 'Harbor Island Rd', strCity = 'Aransas Pass', dtmApprovedDate = NULL, strZip = '78336', intMasterId = 432520
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2849', strName = 'Port Isabel Logistical Offshore Terminal', strAddress = '1500 Port Road', strCity = 'Port Isabel', dtmApprovedDate = NULL, strZip = '78578', intMasterId = 432521
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2850', strName = 'Targa Terminals', strAddress = '16514 DeZavala Rd', strCity = 'Channelview', dtmApprovedDate = NULL, strZip = '77530', intMasterId = 432522
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2851', strName = 'ERPC Vidor', strAddress = '19295 Old Mansfield Ferry Rd', strCity = 'Vidor', dtmApprovedDate = NULL, strZip = '77662', intMasterId = 432523
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2852', strName = 'Petro Source - Rio Hondo', strAddress = '21076 Reynolds Ave', strCity = 'Rio Hondo', dtmApprovedDate = NULL, strZip = '78583', intMasterId = 432524
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2853', strName = 'Jefferson Railport Terminal', strAddress = '94 Old Hwy 90', strCity = 'Vidor', dtmApprovedDate = NULL, strZip = '77662', intMasterId = 432525
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2857', strName = 'Midstream Texas Operating', strAddress = '1269 Sunray Rd', strCity = 'Ingleside', dtmApprovedDate = NULL, strZip = '78362', intMasterId = 432526
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2858', strName = 'Greens Port CBR, LLC', strAddress = '1755 Federal Rd Gate 1', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77015', intMasterId = 432527
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2859', strName = 'Bluewing Royal LLC', strAddress = '1005 Anchor Rd', strCity = 'Brownsville', dtmApprovedDate = NULL, strZip = '78521', intMasterId = 432528
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2866', strName = 'Bay Ltd Redfish Bay Terminal', strAddress = '467 East Beasley', strCity = 'Aransas Pass', dtmApprovedDate = NULL, strZip = '78336', intMasterId = 432529
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2763', strName = 'Permian Advantage Toyah', strAddress = '300 Cr 413', strCity = 'Toyah', dtmApprovedDate = NULL, strZip = '75206', intMasterId = 432530
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2864', strName = 'Titan Fuel Terminal', strAddress = '24581 E Port Rd', strCity = 'Harlingen', dtmApprovedDate = NULL, strZip = '78550', intMasterId = 432531
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2854', strName = 'Premcor Refining Group', strAddress = '1801 Gulfway Dr', strCity = 'Port Arthur', dtmApprovedDate = NULL, strZip = '77646', intMasterId = 432532
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2663', strName = 'Aircraft Service International, Inc.', strAddress = 'Love Field', strCity = 'Dallas', dtmApprovedDate = NULL, strZip = '75235', intMasterId = 432533
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2863', strName = 'Texas Deepwater Terminal', strAddress = '5900 TX 225', strCity = 'Deer Park', dtmApprovedDate = NULL, strZip = '77536', intMasterId = 432534
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2856', strName = 'Nustar Terminals Partners', strAddress = '201 Dock Road', strCity = 'Texas City', dtmApprovedDate = NULL, strZip = '77590', intMasterId = 432535
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2865', strName = 'MVP Terminaling', strAddress = '3449 Pasadena Freeway', strCity = 'Pasadena', dtmApprovedDate = NULL, strZip = '77503', intMasterId = 432536
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2765', strName = 'Flint Hills Resources Taylor Terminal', strAddress = '11496 Chandler Rd', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '76574', intMasterId = 432537
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2762', strName = 'Holly Energy Partners - Operating LP', strAddress = '40231 FM 3541', strCity = 'Orla', dtmApprovedDate = NULL, strZip = '79770', intMasterId = 432538
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2793', strName = 'Swissport SA Fuel Services', strAddress = '8376 Monroe, Hobby Airport', strCity = 'Houston', dtmApprovedDate = NULL, strZip = '77061', intMasterId = 432539
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2861', strName = 'Port Harlingen Terminal', strAddress = '24581 Port Rd', strCity = 'Harlingen', dtmApprovedDate = NULL, strZip = '78550', intMasterId = 432540
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2855', strName = 'Maverick Terminal Corpus Christi', strAddress = '4669 Joe Fulton Intl TC', strCity = 'Corpus Christi', dtmApprovedDate = NULL, strZip = '78402', intMasterId = 432541
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2860', strName = 'GT Gulfway', strAddress = '2350 Gulfway', strCity = 'Port Arthur', dtmApprovedDate = NULL, strZip = '77640', intMasterId = 432542
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T74TX2764', strName = 'Sunoco Partners Marketing & Terminals', strAddress = '2927 I-20 Frontage Rd', strCity = 'Stanton', dtmApprovedDate = NULL, strZip = '79796', intMasterId = 432543
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T75TX2696', strName = 'Valero Taylor Terminal', strAddress = '12992 Chandler Rd', strCity = 'Taylor', dtmApprovedDate = NULL, strZip = '76574', intMasterId = 432544
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T76TX2862', strName = 'Keyera Energy', strAddress = '605 County Road E', strCity = 'Hull', dtmApprovedDate = NULL, strZip = '77564', intMasterId = 432545


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'TX', @TerminalControlNumbers = @TerminalTX

DELETE @TerminalTX

-- UT Terminals
PRINT ('Deploying UT Terminal Control Number')
DECLARE @TerminalUT AS TFTerminalControlNumbers

INSERT INTO @TerminalUT(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4200', strName = 'Big West Oil LLC', strAddress = '333 West Center St', strCity = 'North Salt Lake', dtmApprovedDate = NULL, strZip = '84054-0180', intMasterId = 442527
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4202', strName = 'Tesoro Logistics Operations LLC', strAddress = '474 West 900 N', strCity = 'Salt Lake City', dtmApprovedDate = NULL, strZip = '84103-', intMasterId = 442528
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4203', strName = 'Chevron USA, Inc.- Salt Lake City', strAddress = '2350 North 1100 W', strCity = 'Salt Lake City', dtmApprovedDate = NULL, strZip = '84116-', intMasterId = 442529
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4204', strName = 'Phillips 66 PL - North Salt Lake', strAddress = '245 East 1100 North', strCity = 'North Salt Lake City', dtmApprovedDate = NULL, strZip = '84054-', intMasterId = 442530
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4205', strName = 'Silver Eagle Refining Woods Cross Inc', strAddress = '2355 South 1100 West', strCity = 'Woods Cross', dtmApprovedDate = NULL, strZip = '84087-0298', intMasterId = 442531
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4206', strName = 'Holly Energy Partners - Operating LP', strAddress = '393 South 800 West', strCity = 'Woods Cross', dtmApprovedDate = NULL, strZip = '84087-1435', intMasterId = 442532
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4207', strName = 'UNEV Cedar City', strAddress = '4410 N Wecco Rd', strCity = 'Cedar City', dtmApprovedDate = NULL, strZip = '84721', intMasterId = 442533
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T87UT4208', strName = 'HollyFrontier Wood Cross Refining LLC', strAddress = '393 South 800 West', strCity = 'Woods Cross', dtmApprovedDate = NULL, strZip = '84087', intMasterId = 442534
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84UT4207', strName = 'Aircraft Service International, Inc.', strAddress = '1070 North 3930 West', strCity = 'Salt Lake City', dtmApprovedDate = NULL, strZip = '84116', intMasterId = 442535


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'UT', @TerminalControlNumbers = @TerminalUT

DELETE @TerminalUT

-- VA Terminals
PRINT ('Deploying VA Terminal Control Number')
DECLARE @TerminalVA AS TFTerminalControlNumbers

INSERT INTO @TerminalVA(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T50VA0001', strName = 'PAPCO Terminal', strAddress = '407 Jefferson Avenue', strCity = 'Newport News', dtmApprovedDate = NULL, strZip = '23607', intMasterId = 462535
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1650', strName = 'Buckeye Terminals, LLC - Chesapeake', strAddress = '4030 Buell Street', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462536
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1651', strName = 'Center Point Terminal - Chesapeake', strAddress = '428 Barnes Road', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462537
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1652', strName = 'CITGO - Chesapeake', strAddress = '110 Freeman Street', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462538
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1653', strName = 'Kinder Morgan Virginia Liquids Terminals LLC', strAddress = '502 Hill Street', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462539
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1654', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4115 Buell Street', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462540
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1657', strName = 'Kinder Morgan Transmix Co., LLC', strAddress = '3302 Deepwater Terminal Rd', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23234-', intMasterId = 462541
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1659', strName = 'Buckeye Terminals, LLC - Fairfax', strAddress = '9601 Colonial Avenue', strCity = 'Fairfax', dtmApprovedDate = NULL, strZip = '22031-', intMasterId = 462542
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1660', strName = 'TransMontaigne - Fairfax', strAddress = '3790 Pickett Road', strCity = 'Fairfax', dtmApprovedDate = NULL, strZip = '22031-', intMasterId = 462543
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1661', strName = 'CITGO - Fairfax', strAddress = '9600 Colonial Avenue', strCity = 'Fairfax', dtmApprovedDate = NULL, strZip = '22031-', intMasterId = 462544
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1662', strName = 'Motiva Enterprises LLC', strAddress = '3800 Pickett Road', strCity = 'Fairfax', dtmApprovedDate = NULL, strZip = '22031', intMasterId = 462545
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1663', strName = 'Sunoco Partners Marketing & Terminals LP', strAddress = '10315 Ballsford Road', strCity = 'Manassas', dtmApprovedDate = NULL, strZip = '23109', intMasterId = 462546
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1664', strName = 'TransMontaigne - Montvale', strAddress = '11685 W Lynchburg Salem Turnpi', strCity = 'Montvale', dtmApprovedDate = NULL, strZip = '24122-', intMasterId = 462547
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1665', strName = 'Buckeye Terminals, LLC - Roanoke', strAddress = '1070 Oil Terminal Rd', strCity = 'Montvale', dtmApprovedDate = NULL, strZip = '24122-', intMasterId = 462548
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1666', strName = 'TransMontaigne - Montvale', strAddress = '1147 Oil Terminal Rd. Hwy 460E', strCity = 'Montvale', dtmApprovedDate = NULL, strZip = '24122-', intMasterId = 462549
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1667', strName = 'IMTT-Chesapeake', strAddress = '2801 S. Military Hwy.', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23323', intMasterId = 462550
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1668', strName = 'Magellan Terminals Holdings LP', strAddress = '11851 West Lynchburg Turnpike', strCity = 'Montvale', dtmApprovedDate = NULL, strZip = '24122-', intMasterId = 462551
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1671', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '8200 Terminal Road', strCity = 'Newington', dtmApprovedDate = NULL, strZip = '22122-', intMasterId = 462552
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1673', strName = 'Arc Terminals Holdings LLC', strAddress = '801 Butt Street', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462553
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1674', strName = 'TransMontaigne - Norfolk', strAddress = '7600 Halifax Lane', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23324-', intMasterId = 462554
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1677', strName = 'Buckeye Terminals, LLC - Richmond', strAddress = '1636 Commerce Road', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23224-', intMasterId = 462555
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1678', strName = 'TransMontaigne - Richmond', strAddress = '700 Goodes Street', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23224-', intMasterId = 462556
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1679', strName = 'CITGO - Richmond', strAddress = 'Third & Maury Street', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23224-', intMasterId = 462557
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1681', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '2000 Trenton Avenue', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23234-', intMasterId = 462558
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1682', strName = 'First Energy Corporation', strAddress = 'Second & Maury Streets', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23224', intMasterId = 462559
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1683', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '4110 Deepwater Terminal Road', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23234-', intMasterId = 462560
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1684', strName = 'Magellan Terminals Holdings LP', strAddress = '204 East First Avenue', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23224-', intMasterId = 462561
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1685', strName = 'Motiva Enterprises LLC', strAddress = '5801 Jefferson Davis Hwy.', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23234-', intMasterId = 462562
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1686', strName = 'Allied Avia Fueling of National Airport, LLC', strAddress = '11 Air Cargo Rd.', strCity = 'Arlington', dtmApprovedDate = NULL, strZip = '22201', intMasterId = 462563
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1687', strName = 'TransMontaigne - Richmond', strAddress = '1314 Commerce Road', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23224-7510', intMasterId = 462564
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1688', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '835 Hollins Road Northeast', strCity = 'Roanoke', dtmApprovedDate = NULL, strZip = '24012-', intMasterId = 462565
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1689', strName = 'Magellan Terminals Holdings LP', strAddress = '5287 Terminal Road', strCity = 'Roanoke', dtmApprovedDate = NULL, strZip = '24014-4033', intMasterId = 462566
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1690', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '5280 Terminal Road SW', strCity = 'Roanoke', dtmApprovedDate = NULL, strZip = '24014-', intMasterId = 462567
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1691', strName = 'Motiva Enterprises LLC', strAddress = 'U.S. Highway 460', strCity = 'Montvale', dtmApprovedDate = NULL, strZip = '24122-', intMasterId = 462568
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1692', strName = 'Kinder Morgan Southeast Terminals LLC', strAddress = '8206 Terminal Road', strCity = 'Lorton', dtmApprovedDate = NULL, strZip = '22079-', intMasterId = 462569
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1694', strName = 'Plains Marketing, LP', strAddress = 'Route 73 East Entrance', strCity = 'Yorktown', dtmApprovedDate = NULL, strZip = '23690-', intMasterId = 462570
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1695', strName = 'Lincoln Terminal Company', strAddress = '3300 Beaulah Salisbury', strCity = 'Fredricksburg', dtmApprovedDate = NULL, strZip = '22402', intMasterId = 462571
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1696', strName = 'IMTT Richmond, Inc.', strAddress = '5501 Old Osborne Turnpike', strCity = 'Richmond', dtmApprovedDate = NULL, strZip = '23231', intMasterId = 462572
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1700', strName = 'Gas Supply Resources', strAddress = '2901 South Military Highway', strCity = 'Chesapeake', dtmApprovedDate = NULL, strZip = '23323', intMasterId = 462573
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T54VA1676', strName = 'Aircraft Service International, Inc.', strAddress = 'Rt 28 Gate317 Bldg 2 Tank Farm', strCity = 'Sterling', dtmApprovedDate = NULL, strZip = '20166', intMasterId = 462574


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'VA', @TerminalControlNumbers = @TerminalVA

DELETE @TerminalVA

-- WA Terminals
PRINT ('Deploying WA Terminal Control Number')
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
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T33WA0001', strName = 'Petrogas', strAddress = '4100 Unick Road', strCity = 'Ferndale', dtmApprovedDate = NULL, strZip = '98248', intMasterId = 47349
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4400', strName = 'Shell Oil Products US', strAddress = 'Marches Point Five Miles', strCity = 'Anacortes', dtmApprovedDate = NULL, strZip = '98221-', intMasterId = 47350
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4401', strName = 'Phillips 66 PL - Moses Lake', strAddress = '3 miles north of Moses Lake', strCity = 'Moses Lake', dtmApprovedDate = NULL, strZip = '98837-', intMasterId = 47351
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4402', strName = 'Tesoro Logistics Operations LLC', strAddress = '3000 Sacajawea Park Road', strCity = 'Pasco', dtmApprovedDate = NULL, strZip = '99301-', intMasterId = 47352
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4404', strName = 'Phillips 66 PL - Renton', strAddress = '2423 Lind Avenue Southwest', strCity = 'Renton', dtmApprovedDate = NULL, strZip = '98055-', intMasterId = 47353
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4406', strName = 'Kinder Morgan Liquids Terminals LLC', strAddress = '2720 13th Avenue SW', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '98134-', intMasterId = 47354
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4408', strName = 'Shell Oil Products US', strAddress = '2555 13th Ave. S W', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '98134-', intMasterId = 47355
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4410', strName = 'Phillips 66 PL - Spokane', strAddress = '6317 East Sharp Avenue', strCity = 'Spokane', dtmApprovedDate = NULL, strZip = '99206-', intMasterId = 47356
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4411', strName = 'ExxonMobil Oil Corp.', strAddress = '6311 East Sharp Avenue', strCity = 'Spokane', dtmApprovedDate = NULL, strZip = '99211-', intMasterId = 47357
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4412', strName = 'Holly Energy Partners - Operating LP', strAddress = '3225 East Lincoln Road', strCity = 'Spokane', dtmApprovedDate = NULL, strZip = '99217-', intMasterId = 47358
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4413', strName = 'Phillips 66 PL - Tacoma', strAddress = '520 E D Street', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98421-', intMasterId = 47359
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4414', strName = 'Targa Sound Terminal', strAddress = '2628 Marine View Drive', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98422', intMasterId = 47360
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4415', strName = 'Shore Terminals LLC - Tacoma', strAddress = '250 East D Street', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98421', intMasterId = 47361
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4417', strName = 'NuStar Terminals Operations Partnership L. P. - Vancouver', strAddress = '5420 Fruit Valley Road', strCity = 'Vancouver', dtmApprovedDate = NULL, strZip = '98660-', intMasterId = 47362
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4418', strName = 'BP West Coast Products LLC', strAddress = '4519 Grandview', strCity = 'Blaine', dtmApprovedDate = NULL, strZip = '98231-', intMasterId = 47363
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4419', strName = 'Tesoro Logistics Operations LLC', strAddress = '2211 West 26th Street', strCity = 'Vancouver', dtmApprovedDate = NULL, strZip = '98660-', intMasterId = 47364
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4420', strName = 'Tidewater Terminal - Snake River', strAddress = 'Tank Farm Road', strCity = 'Pasco', dtmApprovedDate = NULL, strZip = '99301-', intMasterId = 47365
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4421', strName = 'U.S. Oil & Refining Co.', strAddress = '3001 Marshall Ave', strCity = 'Tacoma', dtmApprovedDate = NULL, strZip = '98421-', intMasterId = 47366
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4425', strName = 'BP West Coast Products LLC', strAddress = '1652 SW Lander St', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '95124-', intMasterId = 47367
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4427', strName = 'Phillips 66 Co - Ferndale', strAddress = '3901 Unic Rd.', strCity = 'Ferndale', dtmApprovedDate = NULL, strZip = '98248-', intMasterId = 47368
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4428', strName = 'Tesoro Logistics Operations LLC', strAddress = 'West March Point Road', strCity = 'Anacortes', dtmApprovedDate = NULL, strZip = '98221', intMasterId = 47369
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4431', strName = 'Swissport Fueling, Inc.', strAddress = '2350 South 190th St.', strCity = 'Seattle', dtmApprovedDate = NULL, strZip = '98188', intMasterId = 47371
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4433', strName = 'Imperium Grays Harbor', strAddress = '3122 Port Industrial road ', strCity = 'Hoquian ', dtmApprovedDate = NULL, strZip = '98550', intMasterId = 47372
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4434', strName = 'BNSF - Pasco', strAddress = '3490 N Railroad Avenue', strCity = 'Pasco', dtmApprovedDate = NULL, strZip = '99301', intMasterId = 47373
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4436', strName = 'Olympic Pipe Line Company - Bayview', strAddress = '14879 Vernell Road', strCity = 'Mount Vernon', dtmApprovedDate = NULL, strZip = '98273', intMasterId = 47374
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4435', strName = 'Olympic Pipe Line Company - Renton', strAddress = '2319 Lind Ave', strCity = 'Renton', dtmApprovedDate = NULL, strZip = '98507', intMasterId = 47375
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T91WA4437', strName = 'Olympic Pipe Line Company - Vancouver', strAddress = '2251 Saint Francis Lane', strCity = 'Vancouver', dtmApprovedDate = NULL, strZip = '98660', intMasterId = 47376


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'WA', @TerminalControlNumbers = @TerminalWA

DELETE @TerminalWA

-- WI Terminals
PRINT ('Deploying WI Terminal Control Number')
DECLARE @TerminalWI AS TFTerminalControlNumbers

INSERT INTO @TerminalWI(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3061', strName = 'U.S. Oil - Green Bay Fox', strAddress = '1124 North Broadway', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54303', intMasterId = 492574
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3062', strName = 'Buckeye Terminals, LLC- Granville', strAddress = '9101 North 107th Street', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224', intMasterId = 492575
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3064', strName = 'CHS Petroleum Terminal - Chippewa Falls', strAddress = '2331 N Prairie View Rd', strCity = 'Chippewa Falls', dtmApprovedDate = NULL, strZip = '54729', intMasterId = 492576
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3065', strName = 'CHS Petroleum Terminal - McFarland', strAddress = '4103 Triangle St', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492577
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3066', strName = 'CITGO - Green Bay', strAddress = '1391 Bylsby Avenue', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54303', intMasterId = 492578
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3067', strName = 'CITGO - McFarland', strAddress = '4606 Terminal Drive', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492579
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3068', strName = 'CITGO - Milwaukee', strAddress = '9235 North 107th Street', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224', intMasterId = 492580
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3070', strName = 'U.S. Oil - Green Bay Quincy', strAddress = '2206 N Quincy St', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54306-', intMasterId = 492581
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3071', strName = 'Flint Hills Resources, LP-Junction City', strAddress = 'Junction US 10 & 34N', strCity = 'Junction City', dtmApprovedDate = NULL, strZip = '54443', intMasterId = 492582
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3072', strName = 'Flint Hills Resources, LP-Madison', strAddress = '4505 Terminal Drive', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492583
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3073', strName = 'Flint Hills Resources, LP-Milwaukee', strAddress = '9343 North 107th Street', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224', intMasterId = 492584
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3074', strName = 'Flint Hills Resources, LP-Waupun', strAddress = 'Route Two', strCity = 'Waupun', dtmApprovedDate = NULL, strZip = '53963', intMasterId = 492585
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3075', strName = 'Marathon Green Bay', strAddress = '1031 Hurlbut Street', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54303', intMasterId = 492586
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3076', strName = 'U.S. Oil - Milwaukee West', strAddress = '9125 North 107th St', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224-1508', intMasterId = 492587
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3077', strName = 'U.S. Oil - Green Bay Prairie', strAddress = '410 Prairie Ave', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54303', intMasterId = 492588
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3079', strName = 'U.S. Oil - Madison Sigglekow', strAddress = '4516 Sigglekow Road', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492589
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3080', strName = 'Superior Refining Company LLC', strAddress = '2407 Stinson Ave', strCity = 'Superior', dtmApprovedDate = NULL, strZip = '54880', intMasterId = 492590
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3081', strName = 'U.S. Oil - Milwaukee Jones Island', strAddress = '1626 South Harbor Drive', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53207-1020', intMasterId = 492591
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3082', strName = 'U.S. Oil - Chippewa Falls Prairieview', strAddress = '3689 N. Prairieview Road', strCity = 'Chippewa Falls', dtmApprovedDate = NULL, strZip = '54729', intMasterId = 492592
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3083', strName = 'Arc Terminals Holdings LLC', strAddress = '4009 Triangle St Hwy 51 S', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492593
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3084', strName = 'U.S. Oil - Milwaukee South', strAddress = '9135 North 107th Street', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224', intMasterId = 492594
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3085', strName = 'U.S. Oil - Madison North', strAddress = '4306 Terminal Dr', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492595
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3086', strName = 'U.S. Oil - Milwaukee North', strAddress = '9521 North 107th Street', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224', intMasterId = 492596
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3088', strName = 'U.S. Oil - Madison South', strAddress = '4402 Terminal Dr', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492597
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3089', strName = 'U.S. Oil - Green Bay Products', strAddress = '1075 Hurlbut Ct', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54303', intMasterId = 492598
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3090', strName = 'U.S. Oil - Milwaukee Central', strAddress = '9451 North 107th Street', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224-', intMasterId = 492599
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T41MN3425', strName = 'Northern States Power Co, Wisconsin', strAddress = '3008 - 80th Street', strCity = 'Eau Claire', dtmApprovedDate = NULL, strZip = '54703', intMasterId = 492600
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72WI0001', strName = 'West Shore Pipeline Company - Milwaukee', strAddress = '11115 West County Line Road', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53224', intMasterId = 492601
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72WI0002', strName = 'West Shore Pipeline Company - McFarland', strAddress = '4508 Terminal Road', strCity = 'McFarland', dtmApprovedDate = NULL, strZip = '53558', intMasterId = 492602
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T72WI0003', strName = 'West Shore Pipeline Company - Green Bay', strAddress = '2119 North Quincy Street', strCity = 'Green Bay', dtmApprovedDate = NULL, strZip = '54302', intMasterId = 492603
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T39WI3092', strName = 'Aircraft Service International, Inc.', strAddress = '4792 S Howell Ave', strCity = 'Milwaukee', dtmApprovedDate = NULL, strZip = '53207', intMasterId = 492604


EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'WI', @TerminalControlNumbers = @TerminalWI

DELETE @TerminalWI

-- WV Terminals
PRINT ('Deploying WV Terminal Control Number')
DECLARE @TerminalWV AS TFTerminalControlNumbers

INSERT INTO @TerminalWV(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T55WV3181', strName = 'MPLX Charleston', strAddress = 'Standard St & MacCorkle Ave', strCity = 'Charleston', dtmApprovedDate = NULL, strZip = '25314-', intMasterId = 482604
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T55WV3183', strName = 'Ergon West Virginia, Inc.', strAddress = 'Rt 2 South', strCity = 'Newell', dtmApprovedDate = NULL, strZip = '26050-', intMasterId = 482605
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T55WV3184', strName = 'Go-Mart', strAddress = '1Terminal Rd', strCity = 'St. Albans', dtmApprovedDate = NULL, strZip = '25177-', intMasterId = 482606
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T55WV3185', strName = 'St. Marys Refining Company', strAddress = '201 Barkwill St', strCity = 'St. Mary''s', dtmApprovedDate = NULL, strZip = '26170-', intMasterId = 482607
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T55WV3186', strName = 'Guttman Realty Co. - Star City', strAddress = '437 Industrial Ave', strCity = 'Star City', dtmApprovedDate = NULL, strZip = '26505-', intMasterId = 482608
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T55WV3188', strName = 'Baker Oil Co.', strAddress = '2076 Stephen Street', strCity = 'Hugheston', dtmApprovedDate = NULL, strZip = '25110-', intMasterId = 482609

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'WV', @TerminalControlNumbers = @TerminalWV

DELETE @TerminalWV

-- WY Terminals
PRINT ('Deploying WY Terminal Control Number')
DECLARE @TerminalWY AS TFTerminalControlNumbers

INSERT INTO @TerminalWY(
	intTerminalControlNumberId
	, strTerminalControlNumber
	, strName
	, strAddress
	, strCity
	, dtmApprovedDate
	, strZip
	, intMasterId
)
SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4050', strName = 'Phillips 66 PL - Sheridan', strAddress = '3404 Highway 87', strCity = 'Sheridan', dtmApprovedDate = NULL, strZip = '82801-', intMasterId = 502610
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4051', strName = 'Phillips 66 PL - Rock Springs', strAddress = '90 Foot Hill Blvd', strCity = 'Rock Springs', dtmApprovedDate = NULL, strZip = '82902-', intMasterId = 502611
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4052', strName = 'Sinclair Casper Refining Company', strAddress = '5700 E Hwy 20-26', strCity = 'Casper', dtmApprovedDate = NULL, strZip = '82609', intMasterId = 502612
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4053', strName = 'Magellan Pipeline Company, L.P.', strAddress = '1112 Parsley Blvd', strCity = 'Cheyenne', dtmApprovedDate = NULL, strZip = '82007-', intMasterId = 502613
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4054', strName = 'Sinclair Wyoming Refining Company', strAddress = '100 East Lincoln Highway', strCity = 'Sinclair', dtmApprovedDate = NULL, strZip = '82334-0000', intMasterId = 502614
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4055', strName = 'Holly Energy Partners - Operating LP', strAddress = '300 Morrie Ave', strCity = 'Cheyenne', dtmApprovedDate = NULL, strZip = '82007-', intMasterId = 502615
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4056', strName = 'Wyoming Refining Co. - Newcastle', strAddress = '740 W Main', strCity = 'Newcastle', dtmApprovedDate = NULL, strZip = '82701-', intMasterId = 502616
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4057', strName = 'Sinclair Transportation Company', strAddress = '100 East Lincoln Highway', strCity = 'Sinclair', dtmApprovedDate = NULL, strZip = '82334', intMasterId = 502617
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4058', strName = 'Sinclair Transportation Company', strAddress = '5700 East Highway 20-26', strCity = 'Casper', dtmApprovedDate = NULL, strZip = '82609', intMasterId = 502618
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T83WY4061', strName = 'Phillips 66 PL - Casper', strAddress = '5090 East Lathrop Road', strCity = 'Evansville', dtmApprovedDate = NULL, strZip = '82636', intMasterId = 502620
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84WY4057', strName = 'Equitable Oil Purchasing Co', strAddress = '9397 Highway 59 South', strCity = 'Gillette', dtmApprovedDate = NULL, strZip = '82717', intMasterId = 502621
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84WY4058', strName = 'Silver Eagle Refining Inc', strAddress = '2990 County Rd. #180', strCity = 'Evanston', dtmApprovedDate = NULL, strZip = '82930', intMasterId = 502622
UNION ALL SELECT intTerminalControlNumberId = 0, strTerminalControlNumber = 'T84WY4059', strName = 'Union Pacific Railroad Co.', strAddress = '400 West Front St.', strCity = 'Rawlins', dtmApprovedDate = NULL, strZip = '82301', intMasterId = 502623

EXEC uspTFUpgradeTerminalControlNumbers @TaxAuthorityCode = 'WY', @TerminalControlNumbers = @TerminalWY

DELETE @TerminalWY


GO
